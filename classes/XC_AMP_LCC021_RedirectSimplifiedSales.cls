/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 22/04/2021
* @date Modification dd/mm/yyyy
* @description XC_AMP_LCP021_RedirectSimplifiedSales Controller
*/ 
public without sharing class XC_AMP_LCC021_RedirectSimplifiedSales {

    @AuraEnabled
    public static XC_UTIL_ResultWrapper evaluateRedirect(String oppId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        if(String.isBlank(oppId)){
            rw.resultMessage = Label.XC_CL_Opportunity_NoFound;
            return rw;
        }

        Map<Id,Opportunity> opps = new Map<Id,Opportunity>([
            SELECT Id, AccountId, XC_IsSimplifiedSales__c, XC_AMP_Order__c
            FROM Opportunity
            WHERE Id =: oppId
        ]);
        if(opps.isEmpty()){
            rw.resultMessage = Label.XC_CL_Opportunity_NoFound;
            return rw;
        }

        if(opps.values()[0].XC_IsSimplifiedSales__c){
            Map<String,Object> objData = new Map<String,Object>();
            objData.put('accountId',opps.values()[0].AccountId);
            objData.put('opportunityId',opps.values()[0].Id);
            if(String.isNotBlank(opps.values()[0].XC_AMP_Order__c)){
                objData.put('orderId',opps.values()[0].XC_AMP_Order__c);
            }
            rw.objectInfo = JSON.serialize(objData);
            rw.success = true;
        }else{
            rw.resultMessage = Label.XC_CL_OperationNotAllowed;
            return rw;
        }

        return rw;
    }

}