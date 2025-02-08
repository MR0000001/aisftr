/**
 * @description       : Controller of the XC_LCP267_ContractAmendmentRetry component
 * @author            : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @group             : 
 * @last modified on  : 29-10-2021
 * @last modified by  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   29-10-2021   Eleni Tsiolaki - etsiolaki@deloitte.gr   Initial Version
**/
public with sharing class XC_LCC267_ContractAmendmentRetry {

    /**
    * @description Change the status of the Contract Amendment to 'New'
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param recordId String 
    * @return XC_UTIL_ResultWrapper
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper changeStatus(String recordId) {
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        List<XC_ContractAmendment__c> contr = [SELECT Id, XC_Status__c FROM XC_ContractAmendment__c WHERE Id =: recordId];

        if(contr.size() > 0) {
            contr[0].XC_Status__c = 'New';
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.updateRecords(contr);
        XC_UTIL_Sobject.WrapperResult globalRes = XC_UTIL_Sobject.getGlobalDMLResults(dmlRes);
        result.success = globalRes.success;
        
        if(!result.success) {
            result.resultMessage = globalRes.errorMessage;
        }    
        return result;
    }
}