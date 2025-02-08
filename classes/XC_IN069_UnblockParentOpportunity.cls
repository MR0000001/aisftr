/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 13/01/2021
* @date Modification dd/mm/yyyy
* @description  – XC_IN069_UnblockParentOpportunity: Class invoked by flow XC_FL_Provisioning_UnblockParentOpportunityByCampaignCode
*/ 
public without sharing class XC_IN069_UnblockParentOpportunity {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN069_UnblockParentOpportunity');
    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }
    
    /** 
     * @description Cancel previous provisioning. 
     * @param inputWrapperList the input wrapper list.
     */
    @InvocableMethod
    public static void closeRelatedStep(List<InputWrapper> inputWrapperList) {
        List<String> listStepIds = new List<String>(); 
		for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 
        XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id=inputWrapperList[0].stepId);
        Map<String, String> opportunityMap = getOpportunityInfo(stepToUpdate, listStepIds);
        if(opportunityMap == null || opportunityMap.isEmpty()){
            completeMyStep(stepToUpdate, Label.XC_CL_Step_CompletedKO);
            return;
        }
        List<XC_Provisioning_Step__c> stepsToUpdateList = getStepsToClose(opportunityMap);
        if(stepsToUpdateList.isEmpty()){
            completeMyStep(stepToUpdate, Label.XC_CL_Step_CompletedKO);
            return;
        }
        List<Opportunity> opportunityToUpdateList = populateOpportunity(opportunityMap);

        List<XC_UTIL_Sobject.WrapperResult> listDMLResultSteps = XC_UTIL_Sobject.updateListRecords(stepsToUpdateList);
        if(!XC_UTIL_Sobject.checkDMLResults(listDMLResultSteps)){
            stepToUpdate.XC_ErrorMessage__c=listDMLResultSteps[0].errorMessage;
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return;
        }
        List<XC_UTIL_Sobject.WrapperResult> listDMLResultOpp = XC_UTIL_Sobject.updateListRecords(opportunityToUpdateList);
        if(!XC_UTIL_Sobject.checkDMLResults(listDMLResultOpp)){
            stepToUpdate.XC_ErrorMessage__c=listDMLResultOpp[0].errorMessage;
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return;
        } else {
            completeMyStep(stepToUpdate, Label.XC_CL_Completed_Ok);
        }
    }

    private static Map<String, String> getOpportunityInfo(XC_Provisioning_Step__c stepToUpdate, List<String> listStepIds){
        Map<String, String> opportunityMap = new Map<String, String>();
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>([SELECT Id, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CampaignCode__c
                                                                                        FROM XC_Provisioning_Step__c
                                                                                        WHERE Id IN: listStepIds]);
        for(XC_Provisioning_Step__c step : stepList){
            String objectValue = '';
            String campaingCode = step.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_CampaignCode__c;
            try{
                objectValue = XC_UTIL_SObject.getObjectType(campaingCode);
            } catch (Exception e) {
                return null;
            }
            if(objectValue!= '' && objectValue == Label.XC_CL_OpportunityLabel){
                opportunityMap.put(step.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c, campaingCode);
            } else {
                return null;
            }
        }
        return opportunityMap;
    }

    private static List<XC_Provisioning_Step__c> getStepsToClose(Map<String, String> opportunityMap) {
        List<XC_Provisioning_Step__c> stepsToCompleteList = new List<XC_Provisioning_Step__c>([SELECT Id, XC_Status__c
                                                                                                FROM XC_Provisioning_Step__c
                                                                                                WHERE XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress
                                                                                                AND XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningWaitOpportunityByCampaignCode_Flow
                                                                                                AND XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c IN: opportunityMap.values()]);   
        for(XC_Provisioning_Step__c stepToUpdate : stepsToCompleteList){
            stepToUpdate.XC_Status__c = Label.XC_CL_Completed_Ok;
        }   
        return stepsToCompleteList;                                                                              
    }

    private static List<Opportunity> populateOpportunity(Map<String, String> opportunityMap){
        List<Opportunity> opportunityToUpdateList = new List<Opportunity>();
        for(String opportunityId : opportunityMap.keySet()){
            if(!String.isEmpty(opportunityMap.get(opportunityId))){
                Opportunity opp = new Opportunity(Id = opportunityId);
                opp.XC_RelatedOpportunity__c = opportunityMap.get(opportunityId);
                opportunityToUpdateList.add(opp);
            }
        }
        return opportunityToUpdateList;
    }

    private static void completeMyStep(XC_Provisioning_Step__c stepToUpdate, String status){
        stepToUpdate.XC_Status__c = status;
        if(status == Label.XC_CL_Step_CompletedKO ){
            stepToUpdate.XC_ErrorMessage__c = Label.XC_CL_Provisioning_ErrorOnUnblockParentOpportunity;
        }
        XC_UTIL_Sobject.updateRecord(stepToUpdate);
    }
}