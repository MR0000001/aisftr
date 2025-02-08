/**
 * The Class XC_LCC113_CaseOnNbaNbo.
 *
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 16/05/2019
 * @description XC_LCC113_CaseOnNbaNbo –  Controller for XC_LCP113_CaseOnNbaNbo Component
 */

public without sharing class XC_LCC113_CaseOnNbaNbo {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC113_CaseOnNbaNbo');

/**
* @param recordId the record id
* @description Create Case
* @return XC_UTIL_ResultWrapper - the result wrapper
 */
    @AuraEnabled
        public static XC_UTIL_ResultWrapper createCase(String recordId){
            
            
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Map<Id,XC_NbaNbo__c> nbaNboMap = new Map<Id,XC_NbaNbo__c>([SELECT Id,XC_AccountId__c,XC_ContactId__c,XC_AddressId__c, 
                                                                XC_RuleDescription__c,XC_Used__c,XC_LegalEntity__c,XC_ReceivingChannel__c,
                                                                XC_Status__c,XC_Reason__c,XC_Subtype__c,XC_Subcause__c,XC_AssetId__c,XC_Description__c,XC_CaseId__c
                                                                FROM XC_NbaNbo__c WHERE Id =:recordId LIMIT 1]);
        List<XC_NbaNbo__c> nbaNbo = nbaNboMap.values();
        If(!nbaNbo[0].XC_Used__c){
            Case caseToCreate = new Case();
            caseToCreate.AccountId = nbaNbo[0].XC_AccountId__c; 
            caseToCreate.ContactId = nbaNbo[0].XC_ContactId__c;
            caseToCreate.Status = nbaNbo[0].XC_Status__c;
            caseToCreate.Reason = nbaNbo[0].XC_Reason__c;
            caseToCreate.SubCause__c = nbaNbo[0].XC_Subcause__c; 
            caseToCreate.AssetId = nbaNbo[0].XC_AssetId__c;
            caseToCreate.XC_FromNbaNbo__c = true;
            if(String.isNotBlank(nbaNbo[0].XC_Subtype__c)){
                caseToCreate.XC_Subtype__c = nbaNbo[0].XC_SubType__c;
            }

            XC_UTIL_Sobject.WrapperResult w = XC_UTIL_Sobject.insertRecord(caseToCreate);
            System.debug('@@@success'+w.success);
            if(!w.success){ 
                rw.success = false;
                rw.resultMessage = w.errorMessage;
                return rw;
            }else{         
                nbaNbo[0].XC_CaseId__c = caseToCreate.Id;
                nbaNbo[0].XC_Used__c = true; 
                nbaNbo[0].XC_UsedDate__c = DateTime.now();
                // nbaNbo[0].XC_Result__c = caseToCreate.Status;
                XC_UTIL_Sobject.updateListRecords(nbaNbo); 
            } 
            rw = new XC_UTIL_ResultWrapper(w);
            rw.resultMessage = 'Case created';
        }else{
            rw.success = false;
            rw.resultMessage = 'Case already exists';
        }
        return rw;
        
    }

}