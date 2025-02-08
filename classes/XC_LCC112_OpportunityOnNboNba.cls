/**
 * The Class XC_LCC112_OpportunityOnNboNba.
 *
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 16/05/2019
 * @description XC_LCC112_OpportunityOnNboNba –  Controller for XC_LCP112_OpportunityOnNboNba Component
 */

public without sharing class XC_LCC112_OpportunityOnNboNba {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC112_OpportunityOnNboNba');

/*
* @param recordId the record id
* @description Create Opportunity
* @return XC_UTIL_ResultWrapper - the result wrapper
*/
    @AuraEnabled
        public static XC_UTIL_ResultWrapper createOpportunity(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Map<Id,XC_NbaNbo__c> nbaNboMap = new Map<Id,XC_NbaNbo__c>([SELECT Id,XC_AccountId__c,XC_ContactId__c,XC_AddressId__c, 
                                                                XC_RuleDescription__c,XC_Used__c,XC_LegalEntity__c,XC_ReceivingChannel__c,
                                                                XC_ProductCategory__c,XC_OpportunityId__c
                                                                FROM XC_NbaNbo__c WHERE Id =:recordId LIMIT 1]);
        List<XC_NbaNbo__c> nbaNbo = nbaNboMap.values();
        If(!nbaNbo[0].XC_Used__c){
            Opportunity opp = new Opportunity();
            opp.StageName = label.xC_CL_Opportunity_Draft;
            opp.Name = 'OpportunityName';
            opp.CloseDate = Date.today()+7;
            opp.AccountId = nbaNbo[0].XC_AccountId__c; 
            opp.XC_Contact__c = nbaNbo[0].XC_ContactId__c;
            opp.XC_Address__c = nbaNbo[0].XC_AddressId__c;
            opp.XC_LegalEntity__c = nbaNbo[0].XC_LegalEntity__c;
            opp.XC_ReceivingChannel__c = nbaNbo[0].XC_ReceivingChannel__c;
            opp.XC_ProductCategoryOfInterest__c = nbaNbo[0].XC_ProductCategory__c;
             XC_UTIL_Sobject.WrapperResult w = XC_UTIL_Sobject.insertRecord(opp);
             System.debug('@@@success'+w.success);
            if(!w.success){ 
                rw.success = false;
                rw.resultMessage = w.errorMessage;
                return rw;

            }else{
                nbaNbo[0].XC_OpportunityId__c = opp.Id;
                nbaNbo[0].XC_Used__c = true; 
                nbaNbo[0].XC_UsedDate__c = DateTime.now();
                // nbaNbo[0].XC_Result__c = opp.StageName;
                XC_UTIL_Sobject.updateListRecords(nbaNbo);
           } 
            rw = new XC_UTIL_ResultWrapper(w);
            rw.resultMessage = Label.XC_CL_OpportunityCreated;
        }else{
            rw.success = false;
            rw.resultMessage = Label.XC_CL_Opportunity_AlreadyExists;
           
        }
        return rw;
        
    }

}