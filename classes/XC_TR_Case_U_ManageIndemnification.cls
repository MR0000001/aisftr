/**
 * XC_TR_Case_U_ManageIndemnification Class.
 *
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 31/10/2019
 * @date Last Modification 
 * @description XC_TR_Case_U_ManageIndemnification - Util class for manage indemnification
 */

public without sharing class XC_TR_Case_U_ManageIndemnification {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_ManageIndemnification');


    /**
     * ManageIndemnification.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param the mapmapOld old
     * @param mapNew the map new
     * @description manage indemnification process
     */
    public static void manageIndemnification(Map<Id, Case> mapOld, Map<Id, Case> mapNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_BillingProfileLineItem_U_Address.changeBillingAddressOnZuora');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + mapNew.values());

        List<String> fieldList = new List<String>{'XC_ApprovalStatus__c'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);

        if(!listChanged.isEmpty()) {

            Set<Id> bpliIdList = XC_UTIL_Sobject.getSetIdsOnField(listChanged, 'XC_Billing_Profile_Line_Item__c');
            Map<Id,XC_BillingProfileLineItem__c> bpliMap = new  Map<Id, XC_BillingProfileLineItem__c>([SELECT XC_ZuoraId__c FROM XC_BillingProfileLineItem__c WHERE Id IN :bpliIdList]);
                    
            for(Case c : listChanged) {
                callZuoraAndUpdateCase(JSON.serialize(c), bpliMap.get(c.XC_Billing_Profile_Line_Item__c).XC_ZuoraId__c);
            }
        }
    }


    /**
     * CallZuoraAndUpdateCase.
     * 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param caseSerialized the case
     * @param zuoraAccountId the zuoraAccountId
     * @description call zuora for indemnification
     */
    @future(callout=true)
    public static void callZuoraAndUpdateCase(String caseSerialized, String zuoraAccountId) {

        Case c = (Case) JSON.deserialize(caseSerialized, Case.class);

        if(c.XC_ApprovalStatus__c == Label.XC_CL_Configuration_Approved && c.XC_SentToZuora__c != Label.XC_CL_Yes) {
            
            c.XC_SentToZuora__c = Label.XC_CL_Yes;

            Map<String, String> params = new Map<String, String>{'XC_Amount__c' => String.valueOf(c.XC_Amount__c),
                                                                    'XC_IndemnificationReason__c' => c.XC_IndemnificationReason__c,
                                                                    'XC_Case_Comments__c' => c.XC_Case_Comments__c,
                                                                    'XC_Automatic_Refund__c' => String.valueOf(c.XC_Automatic_Refund__c),
                                                                    'XC_LegalEntity__c' => c.XC_LegalEntity__c,
                                                                    'zuoraAccountId' => zuoraAccountId};

            XC_LCC136_UpCompliantCaseIndemnif.callZuora(params, c.Id, c);
        }
    }
    
    /**
     * ManageIndemnification.
     * 
     * @author Dario Tramontin dtramontin@deloitte.it
     * @param the mapmapOld old
     * @param mapNew the map new
     * @description manage indemnification process
     */
    public static void manageApprovalStatus(Map<Id, Case> mapOld, Map<Id, Case> mapNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_ManageIndemnification.manageApprovalStatus');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + mapNew.values());

        List<String> fieldList = new List<String>{'XC_ApprovalStatus__c'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);

        if(!listChanged.isEmpty()) {          
            for(Case c : listChanged) {
                if(c.XC_ApprovalStatus__c==Label.XC_CL_ApprovalProcessRefused){
                    c.Status = Label.XC_CL_Case_Status007;
                    c.XC_Result__c =Label.XC_CL_Case_Result002;
                    c.XC_Resolution__c =Label.XC_CL_Case_Resolution034;
                    c.CaseRemarks__c = Label.XC_CL_CaseRemark_RefundRejected;
                }
            }
        }
    }

}