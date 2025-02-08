/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 07-06-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   07-06-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_LCC196_RetryQRS {


    /**
    * @description retry the current queued request step starting again the flow
    * @author Francesco Imperioli - fimperioli@deloitte.it | 07-06-2020 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> retryCurrentQRS(String recordId){

        Map<String,Object> result = new Map<String,Object>();
        try{
            List<XC_QueuedRequestStep__c> fullCurrentStep = (List<XC_QueuedRequestStep__c>) XC_UTIL_Sobject.selectAllFields(recordId);
            fullCurrentStep[0].XC_ErrorMessage__c = '';
            fullCurrentStep[0].XC_Retried__c = true;
            List<XC_QueuedRequest__c> currentQueuedRequest = (List<XC_QueuedRequest__c>) XC_UTIL_Sobject.selectAllFields(fullCurrentStep[0].XC_QueuedRequest__c);
            currentQueuedRequest[0].XC_Status__c = 'In Progress';
             XC_UTIL_Sobject.updateListRecords(currentQueuedRequest);
            XC_UTIL_Sobject.updateListRecords(fullCurrentStep);
            XC_UTIL_QueuedRequestStep.setStepInProgressAndEmitEvent(fullCurrentStep);
            result.put('success',true);
        }catch(Exception e){
            result.put('success',false);
            result.put('errorMsg',e.getMessage() + ' TRACE ' + e.getStackTraceString());
        }
        return result;

    }

}