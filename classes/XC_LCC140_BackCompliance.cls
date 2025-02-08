/**
 * The Class XC_LCC140_BackCompliance.
 *
 * @author Anna Maria Rosanova - annamaria.rosanova@nttadata.com
 * @date Creation 02/08/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC140_BackCompliance – Controller for XC_LCC140_BackCompliance Component
 */
public without sharing class XC_LCC140_BackCompliance {    
    /**
    * @description
    * @author Anna Maria Rosanova - 02/08/2019
    * @param recordId String 
    * @return XC_LCC139_DocumentVerification.XC_LCC139_DocumentVerification.ResultWrapper
    */
    public static Boolean isTest = false;
    @AuraEnabled
    public static XC_LCC139_DocumentVerification.ResultWrapper backCompliance (String recordId){
        XC_LCC139_DocumentVerification.ResultWrapper rw = new XC_LCC139_DocumentVerification.ResultWrapper();
        List <XC_OrderItemCompliance__c> listOfOICInstallation = new List <XC_OrderItemCompliance__c> ();
        List <Case> listOfCase = new List <Case>([SELECT Id, XC_Order__r.CreatedById, XC_OrderItem__c, ParentId, Status, AccountId, XC_FirstCheckOnCompliance__c,
                                                XC_Order__c, Reason, Subject, Type,
                                            (SELECT Id, XC_Status__c, XC_RecoveryResponsible__c, XC_KoCriticality__c FROM Order_Item_Compliance__r), 
                                            (SELECT Id, Status FROM Cases WHERE ParentId =: recordId)
                                            FROM Case 
                                            WHERE Id =: recordId]);
        Case caseChild = listOfCase[0];
        caseChild.Status = Label.XC_CL_Case_Status007;
        List<XC_OrderItemCompliance__c> listOfOIC = new List<XC_OrderItemCompliance__c>();
        for(XC_OrderItemCompliance__c oic : caseChild.Order_Item_Compliance__r){
            oic.XC_Case__c = caseChild.ParentId;
            oic.XC_Status__c = '';
            oic.XC_KoCriticality__c = '';
            oic.XC_RecoveryResponsible__c = '';
            oic.XC_KoReason__c = '';
            listOfOIC.add(oic);
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlResults= XC_UTIL_Sobject.updateListRecords(listOfOIC);
        if(!XC_UTIL_Sobject.checkDMLResults(dmlResults) || isTest){
            rw.success = false;
            rw.message = dmlResults[0].errorMessage;
            return rw;
        }
        XC_UTIL_Sobject.WrapperResult dmlResult= XC_UTIL_Sobject.updateRecord(caseChild);
        if(checkDML(dmlResult)) {
            rw.success = false; 
            rw.message = dmlResult.errorMessage;
            return rw;                
        }
        Case caseFather = new Case(Id=listOfCase[0].ParentId);
        listOfCase = new List <Case>([SELECT Id, XC_Order__r.CreatedById, XC_OrderItem__c, ParentId, Status, AccountId, XC_FirstCheckOnCompliance__c,
                                                XC_Order__c, Reason, Subject, Type, ContactId, XC_LegalEntity__c, Country__c,
                                        (SELECT Id, XC_Status__c, XC_RecoveryResponsible__c, XC_KoCriticality__c FROM Order_Item_Compliance__r)
                                      FROM Case
                                      WHERE Id =: caseFather.Id]);
        caseFather = listOfCase[0];
        for(XC_OrderItemCompliance__c oic : caseFather.Order_Item_Compliance__r){
            if(checkRecoveryResponsible(oic)){
                listOfOICInstallation.add(oic);
            }
        }
        if(listOfOICInstallation.isEmpty()){
            caseFather.Status = 'ESTA001';
            XC_UTIL_Sobject.WrapperResult dmlResultCaseFather= XC_UTIL_Sobject.updateRecord(caseFather);
            if(!dmlResultCaseFather.success) {
                rw.message = dmlResultCaseFather.errorMessage;
                return rw;               
            }
            rw.success = true;
            rw.message = Label.XC_CL_DocumentVerification_CaseChildClose;
            return rw;
        }
        rw = XC_LCC139_DocumentVerification_U.installationPartnerQueueKo(listOfOICInstallation, caseFather);
        return rw;
    }
    private static Boolean checkDML( XC_UTIL_Sobject.WrapperResult dmlResult){
        return (!dmlResult.success || isTest);
    }
    private static Boolean checkRecoveryResponsible(XC_OrderItemCompliance__c oic){
        return (!String.isBlank(oic.XC_RecoveryResponsible__c) && Label.XC_CL_DocumentVerification_InstallationQueue.equals(oic.XC_RecoveryResponsible__c));
    }
}