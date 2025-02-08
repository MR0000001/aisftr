/**
* @author Federico Amici - federico.amici@nttdata.com & Giulio Serra - giserra@deloitte.it
* @date Creation 12/09/2018
* @date Modification 09/01/2019 by Nicola Mariniello - Luisana Rocco
* @date Modification 28/05/2019 by Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_SC001_AutoCloseLead – Batch used to automatically close a lead based on the LastModifyDate field according to
*                                       the region base custom metadata value XC_CM001_DaysToLeadClosure__mdt
*/

public with sharing class XC_SC001_AutoCloseLead implements Schedulable, Database.Batchable<sObject>{
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC001_AutoCloseLead');
    
    /**
	* @description execute method
	* @param sc - SchedulableContext 
	*/ 
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC001_AutoCloseLead());
    }
    
    /**
    * @description start method
    * @param bc - BatchableContext 
    * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC001_AutoCloseLead'); 
        /*DateTime dateToCompare = DateTime.newInstance(1900, 01, 01, 00, 00, 00);
        List<XC_CM_Lead_Default_Values__mdt> defaultValuesLeadList = [SELECT id, Label, XC_Days_for_Automatic_Closure__c, XC_Country__c FROM XC_CM_Lead_Default_Values__mdt WHERE XC_Country__c = 'SPAIN'];
        if(defaultValuesLeadList.size() > 0) {
            String daysString = defaultValuesLeadList.get(0).XC_Days_for_Automatic_Closure__c;
            Integer days = Integer.valueOf(daysString);
            dateToCompare = DateTime.Now().AddDays(-days);
        }*/
        String query = 'SELECT Id, XC_Why_not_converted__c, XC_LeadToBeClosed__c, Status ' + 
            'FROM Lead ' +
            'WHERE Status != \'' + Label.XC_CL_Lead_ClosedNotConverted + '\' AND ' +
            'Status != \'' + Label.XC_CL_Lead_ClosedConverted + '\' AND ' +
            'XC_Channel__c != \'' + Label.XC_CL_Lead_Promoter + '\'';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query ---> ' + query); 

        if(!Test.isRunningTest()) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Is not a TEST'); 
            query = query + ' AND XC_LeadToBeClosed__c = true';
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final Query ---> ' + query); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC001_AutoCloseLead'); 
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Lead> scope) {   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in execute method');   
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        List<Lead> listLeadToProcess = new List<Lead>();
        for(Lead ld : scope) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Lead ---> ' + ld); 
            ld.XC_Why_not_converted__c = Label.XC_CL_Lead_ClosedFromBatch;
            ld.Status = Label.XC_CL_Lead_ClosedNotConverted;
            listLeadToProcess.add(ld);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listLeadToProcess ---> ' + listLeadToProcess); 
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listLeadToProcess, false);
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = getErrorLog(wr.errorMessage, wr.errorObjectId);
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
        
    }   
    
    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC001_AutoCloseLead');
    }
    public static XC_BatchErrorLog__c getErrorLog(String errorMessage, String errorObjectId) {
        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = 'XC_SC001_AutoCloseLead';
        bel.XC_ErrorMessage__c = errorMessage;
        bel.XC_TypeOfOperation__c = 'Close Lead based on LastModifyDate';
        bel.XC_RecordId__c = errorObjectId;
        return bel;
    }
}