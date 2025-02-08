/**
 * @description XC_TR_ZuoraCustAccount_U_CreateBillProf
 */

public without sharing class XC_TR_ZuoraCustAccount_U_CreateBillProf {

    /**
     * @description debug active or not
     */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZuoraCustAccount_U_CreateBillProf');


    /**
     * @description normalizePaymentMethodType 
     * @return String
     * @param acc Zuora__CustomerAccount__c
     */
    @TestVisible
    private static String normalizePaymentMethodType(Zuora__CustomerAccount__c acc){
        Map<String, String> transform = new Map<String,String>{
            'Cash' => 'Cash', 
            'BankTransfer' => 'Direct Debt',
            'CreditCard' => 'Credit Card'
            //'Other' => 'Commodity Bill' //commentato per la gestione di più valori associati ad Other (Barcode)
        };
                     
        if(transform.containsKey(acc.Zuora__DefaultPaymentMethod__c)){
            return transform.get(acc.Zuora__DefaultPaymentMethod__c);
        } else if ('Other' == acc.Zuora__DefaultPaymentMethod__c) {
            return acc.otherPaymentMethodType__c;
        } else {
            return '';
        }
    }


    /**
    * @description createLineItemLookup
    * @param accList List<Zuora__CustomerAccount__c>
    */
    public static void createLineItemLookup(List<Zuora__CustomerAccount__c> accList){ 
        for(Zuora__CustomerAccount__c ca : accList) {
            if(
            String.isNotBlank(ca.XC_BillingProfileLineItemID__c) && 
            XC_UTIL_Sobject.checkIfIsSFDCID(ca.XC_BillingProfileLineItemID__c, XC_BillingProfileLineItem__c.class)
            ){
                ca.XC_BillingProfLineItem_LookUp__c = ca.XC_BillingProfileLineItemID__c;
            }
        }
    }
    

    /**
     * BillingProfileCreation.
     *
     * @description billingProfileCreation
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param listNew list of Zuora__CustomerAccount__c
     */
    public static void billingProfileCreation(List<Zuora__CustomerAccount__c> listNew){
    
        Map<Id, Zuora__CustomerAccount__c> zuoraCustomerAccounts =
                    new Map<Id, Zuora__CustomerAccount__c>([SELECT XC_BillingProfLineItem_LookUp__c, XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__c, 
                                                                    Zuora__Default_Payment_Method__c, otherPaymentMethodType__c,XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__r.XC_Status__c
                                                            FROM Zuora__CustomerAccount__c
                                                            WHERE Id IN : listNew]);
        System.debug('Zuora Customer Account Map = ' + zuoraCustomerAccounts);

        Map<Id, NE__Billing_Profile__c> bpToUpdateMap = new Map<Id, NE__Billing_Profile__c>();
        Map<Id, XC_BillingProfileLineItem__c> bpliToUpdateMap = new Map<Id, XC_BillingProfileLineItem__c>();

        for(Id accountId : zuoraCustomerAccounts.keySet()){
            Zuora__CustomerAccount__c a = zuoraCustomerAccounts.get(accountId);

            if(String.isNotBlank(a.XC_BillingProfLineItem_LookUp__c)) {
                XC_BillingProfileLineItem__c billingProfLineItem = new XC_BillingProfileLineItem__c(Id = a.XC_BillingProfLineItem_LookUp__c);
                billingProfLineItem.XC_CustomerAccount__c = accountId;

                if(String.isNotBlank(a.Zuora__Default_Payment_Method__c) || String.isNotBlank(a.otherPaymentMethodType__c)) {

                    String bpStatus = a.XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__r.XC_Status__c == Label.XC_CL_BillingProfileWaiting ?
                    Label.XC_CL_BillingProfileWaiting : Label.XC_CL_BillingProfileActive;

                    billingProfLineItem.XC_Status__c = bpStatus;
                    NE__Billing_Profile__c bp = new NE__Billing_Profile__c(Id = a.XC_BillingProfLineItem_LookUp__r.XC_BillingProfile__c, XC_Status__c = bpStatus);
                    bpToUpdateMap.put(bp.Id, bp);
                }
                
                bpliToUpdateMap.put(billingProfLineItem.Id, billingProfLineItem);
            }
        }

        XC_UTIL_Sobject.updateListRecords(bpToUpdateMap.values(), false);
        XC_UTIL_Sobject.updateListRecords(bpliToUpdateMap.values(), false);
    }


    /**
     * UpdateBillingProfile.
     *
     * @description update Billing Profile and Billing Profile Line Item
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateBillingProfile(List<Zuora__CustomerAccount__c> listNew, Map<Id, Zuora__CustomerAccount__c> mapOld, Map<Id, Zuora__CustomerAccount__c> mapNew){
        
        List<String> fieldList = new List<String>{'Zuora__Default_Payment_Method__c', 'otherPaymentMethodType__c', 'XC_BillingProfileLineItemID__c'};
        List<Zuora__CustomerAccount__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        if(listChanged.isEmpty()) {
            return;
        }

        billingProfileCreation(listChanged);
    }
    

    /**
     * ManageBadPayer.
     *
     * @description manage the BadPayer flag
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void manageBadPayer(List<Zuora__CustomerAccount__c> listNew, Map<Id, Zuora__CustomerAccount__c> mapOld, Map<Id, Zuora__CustomerAccount__c> mapNew) {
        List<String> fieldList = new List<String>{'isBadPayer__c'};
        List<Zuora__CustomerAccount__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        if(listChanged.isEmpty()) {
            return;
        }

        Set<Id> sfdcAccIds = XC_UTIL_Sobject.getSetIdsOnField(listChanged, 'Zuora__Account__c');
        Map<Id, Zuora__CustomerAccount__c> zAccMap = new Map<Id, Zuora__CustomerAccount__c>([SELECT Id, Zuora__Account__c, isBadPayer__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN :sfdcAccIds]);

        Map<Id, Boolean> sfdcAccBadPayer = new Map<Id, Boolean>();
        for(Zuora__CustomerAccount__c zAcc : zAccMap.values()) {
            if(sfdcAccBadPayer.get(zAcc.Zuora__Account__c) != true && zAcc.isBadPayer__c != null) {
                sfdcAccBadPayer.put(zAcc.Zuora__Account__c, Boolean.valueOf(zAcc.isBadPayer__c));
            }   
        }

        List<Account> accListToUpdate = new List<Account>();
        for(Id accId : sfdcAccBadPayer.keySet()) {
            accListToUpdate.add(new Account(Id = accId, XC_BadPayer__c = sfdcAccBadPayer.get(accId)));
        }
        XC_UTIL_Sobject.updateListRecords(accListToUpdate);
    }
}