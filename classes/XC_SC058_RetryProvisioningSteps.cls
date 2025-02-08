/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 22/06/2021
* @description XC_SC058_RetryProvisioningSteps – Batch to relaunch Provisioning Steps for a certain number of times
* @update XC_Provisioning_RetryConfiguration__c replaces XC_ProvisioningRetryConfiguration__mdt
*/

public without sharing class XC_SC058_RetryProvisioningSteps implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC058_RetryProvisioningSteps');
    public Map<String, List<XC_Provisioning_RetryConfiguration__c>> mapConfigurationKO = new Map<String, List<XC_Provisioning_RetryConfiguration__c>>();
    public Map<String, XC_Provisioning_RetryConfiguration__c> mapConfigurationInProgress = new Map<String, XC_Provisioning_RetryConfiguration__c>();

    /**
     * @description Method to schedule Batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC058_RetryProvisioningSteps());
    }  
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        // Retrieve configuration on CMDT
        List<XC_Provisioning_RetryConfiguration__c> listCMDT = getListConfigurations();
                       
        if(Test.isRunningTest()){
            XC_Provisioning_RetryConfiguration__c cmdtKOTest = new XC_Provisioning_RetryConfiguration__c();
            cmdtKOTest.XC_Flow_API_Name__c = 'flowAPIKO';
            cmdtKOTest.XC_ErrorMessage__c =  'errorMessageKO';
            cmdtKOTest.XC_Max_Number_of_Relaunches__c = 3;
            cmdtKOTest.XC_RetryKO__c = true;
            XC_Provisioning_RetryConfiguration__c cmdtInProgressTest = new XC_Provisioning_RetryConfiguration__c();
            cmdtInProgressTest.XC_Flow_API_Name__c = 'flowAPIInProgress';
            cmdtInProgressTest.XC_MinDaysToRelaunchInProgress__c = 0;
            cmdtInProgressTest.XC_Max_Number_of_Relaunches__c = 3;
            cmdtInProgressTest.XC_RetryInProgress__c = true; 
            listCMDT.add(cmdtKOTest);
            listCMDT.add(cmdtInProgressTest);
        }
        
        for(XC_Provisioning_RetryConfiguration__c cmdt : listCMDT ){
            if(cmdt.XC_RetryKO__c){ 
                // map: XC_Flow_API_Name__c ---> list of CMDT related to XC_Flow_API_Name__c                
                if(!mapConfigurationKO.containsKey(cmdt.XC_Flow_API_Name__c)){
                    mapConfigurationKO.put(cmdt.XC_Flow_API_Name__c, new List<XC_Provisioning_RetryConfiguration__c>());
                }
                mapConfigurationKO.get(cmdt.XC_Flow_API_Name__c).add(cmdt);
            } else if(cmdt.XC_RetryInProgress__c){ 
                // map: XC_Flow_API_Name__c ---> the CMDT related to XC_Flow_API_Name__c    
                mapConfigurationInProgress.put(cmdt.XC_Flow_API_Name__c, cmdt);
            }
        }  
        
        this.mapConfigurationKO = mapConfigurationKO;
        this.mapConfigurationInProgress = mapConfigurationInProgress; 
        
        Set<String> setFlowRetryKO = mapConfigurationKO.keySet();
        Set<String> setFlowRetryInProgress = mapConfigurationInProgress.keySet();
        // Retrieve steps to be processed
        String query =  '';
        query += ' SELECT Id, XC_PlatformEventName__c, XC_LegalEntity__c, XC_Segment__c, XC_Flow_API_Name__c, XC_RelaunchCount__c, XC_ErrorMessage__c, XC_Status__c, LastModifiedDate';
        query += ' FROM XC_Provisioning_Step__c';
        query += ' WHERE XC_ReLaunchCountExceeded__c = false AND (';
        query += ' ( XC_Status__c = \'Completed KO\' AND XC_Flow_API_Name__c IN: setFlowRetryKO  )';
        query += ' OR '; 
        query += ' ( XC_Status__c = \'In Progress\' AND XC_Flow_API_Name__c IN: setFlowRetryInProgress  )';
        query += ' )';
        query += ' AND XC_Configuration_Item__r.NE__OrderId__r.XC_Status__c =\'In Provisioning\'';
        query += ' Order By LastModifiedDate';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ query: ' + query ); 
        return Database.getQueryLocator(query);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Execute method for batch
     * @param bc - BatchableContext
     * @param scope - List<XC_Provisioning_Step__c> 
    */
    public void execute(Database.BatchableContext bc, List<XC_Provisioning_Step__c> scope) { 
        List<XC_Provisioning_Step__c> stepToRelaunch = new List<XC_Provisioning_Step__c>(); 
        List<XC_Provisioning_Step__c> stepToUpdate = new List<XC_Provisioning_Step__c>();
        
        
        // Retrieve configuration on CMDT
        Map<String, List<XC_Provisioning_RetryConfiguration__c>> mapConfigurationKO = this.mapConfigurationKO;
        Map<String, XC_Provisioning_RetryConfiguration__c> mapConfigurationInProgress = this.mapConfigurationInProgress;
     
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ map: ' + mapConfigurationKO ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ map: ' + mapConfigurationInProgress );  
        //Process steps in scope:
        for(XC_Provisioning_Step__c step: scope){
            Integer relaunchCount = (step.XC_RelaunchCount__c == null) ? 0 : Integer.valueOf(step.XC_RelaunchCount__c);
            if(step.XC_status__c == 'Completed KO'){ 
                if(mapConfigurationKO.containsKey(step.XC_Flow_API_Name__c)){
                    List<XC_Provisioning_RetryConfiguration__c> listCmdt = mapConfigurationKO.get(step.XC_Flow_API_Name__c);
                    for(XC_Provisioning_RetryConfiguration__c cmdt : listCmdt){
                        String stepErrorMessage = step.XC_ErrorMessage__c == null ? '' : step.XC_ErrorMessage__c;
                        if(!String.isBlank(cmdt.XC_ErrorMessage__c) && stepErrorMessage.contains(cmdt.XC_ErrorMessage__c)){ 
                            if(relaunchCount < cmdt.XC_Max_Number_of_Relaunches__c){
                                step.XC_RelaunchCount__c = relaunchCount + 1;
                                step.XC_Status__c = 'In Progress';
                                step.XC_ErrorMessage__c = '';
                                stepToRelaunch.add(step);
                            } else {
                                step.XC_ReLaunchCountExceeded__c = true;
                            }
                            stepToUpdate.add(step);
                            break;
                        }
                    }
                } 
            } else if(step.XC_status__c == 'In Progress'){
                if(mapConfigurationInProgress.containsKey(step.XC_Flow_API_Name__c)){
                    XC_Provisioning_RetryConfiguration__c cmdt = mapConfigurationInProgress.get(step.XC_Flow_API_Name__c);
                    Integer numDays = Integer.valueOf(cmdt.XC_MinDaysToRelaunchInProgress__c);
                    Integer daysFromLastEdit = Date.valueOf(step.LastModifiedDate).daysBetween(Date.today()); 

                    if(daysFromLastEdit >= numDays || relaunchCount > 0){
                        if(relaunchCount < cmdt.XC_Max_Number_of_Relaunches__c){
                            step.XC_RelaunchCount__c = relaunchCount + 1;
                            stepToRelaunch.add(step);
                        } else {
                            step.XC_ReLaunchCountExceeded__c = true;
                        }
                        stepToUpdate.add(step);
                    }                
                }
            }
        }
        
        //update steps:
        List<XC_UTIL_Sobject.WrapperResult> listDMLResult = XC_UTIL_Sobject.updateListRecords(stepToUpdate);
        List<XC_BatchErrorLog__c > listErrorLog = new List<XC_BatchErrorLog__c>();
        
        for(XC_UTIL_Sobject.WrapperResult wr : listDMLResult ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result DML: ' + wr); 
            if(!wr.success){                
                listErrorLog.add(createErrorLog(wr.errorMessage, wr.recordId));
            }
        }
        XC_UTIL_Sobject.insertListRecords(listErrorLog);
        
        //relaunch steps:
        XC_UTIL_ProvisioningStep.insertEvent(stepToRelaunch);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ FINISH batch XC_SC058_RetryProvisioningSteps'); 
    } 
    
    
    private static List<XC_Provisioning_RetryConfiguration__c> getListConfigurations(){
        return new List<XC_Provisioning_RetryConfiguration__c>([
            SELECT Id, XC_Flow_API_Name__c, XC_ErrorMessage__c, XC_RetryKO__c, XC_RetryInProgress__c, XC_MinDaysToRelaunchInProgress__c, XC_Max_Number_of_Relaunches__c
            FROM XC_Provisioning_RetryConfiguration__c 
        ]);
    }

    @TestVisible
    private static XC_BatchErrorLog__c createErrorLog(String errormessage, String recordId){
        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = 'XC_SC058_RetryProvisioningSteps';
        bel.XC_ErrorMessage__c = errorMessage;
        bel.XC_TypeOfOperation__c = 'Error on Update of Step before Re-Launching';
        bel.XC_RecordId__c = recordId;
        return bel;
    }
}