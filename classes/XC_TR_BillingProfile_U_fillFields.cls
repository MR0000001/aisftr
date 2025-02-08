/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 16/12/2019
* @date Modification dd/mm/yyyy
* @description  –
*/ 
public without sharing class XC_TR_BillingProfile_U_fillFields { 

    /**
     * @description
     * @author Simone Trenta - strenta@deloitte.it
     * @param listNew List<NE__Billing_Profile__c> 
     */
    public static void populateAccountId(List<NE__Billing_Profile__c> listNew) {
        List<String> listOfAcc = new List<String>();
        for(NE__Billing_Profile__c bp : listNew){
            bp.XC_AccountId__c = bp.NE__Account__c;
            listOfAcc.add(bp.XC_AccountId__c);
        }
        List<Account> listOfAccBp = new List<Account>([SELECT Id, XC_isGuestUser__c, XC_Segment__c FROM Account WHERE Id =:listOfAcc]);
        for(NE__Billing_Profile__c bp : listNew){
            for(Account acc : listOfAccBp){
                if(bp.XC_AccountId__c.equals(acc.Id) && String.isBlank(bp.XC_IsGuest__c)){
                    bp.XC_IsGuest__c = String.valueOf(acc.XC_isGuestUser__c);
                    bp.XC_Segment__c = acc.XC_Segment__c;
                }
            }
        }
    }

    /**
     * @description
     * @author Simone Trenta - strenta@deloitte.it
     * @param listNew List<NE__Billing_Profile__c> 
     * @param mapOld Map<Id, NE__Billing_Profile__c>
     * @param mapNew Map<Id, NE__Billing_Profile__c>
     */
    public static void populateAccountIdOnUpdate(List<NE__Billing_Profile__c> listNew, Map<Id, NE__Billing_Profile__c> mapOld, Map<Id, NE__Billing_Profile__c> mapNew) {   
        List<String> fieldToCheck = new List<String> {'NE__Account__c'}; 
        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        populateAccountId(listNew);
    }

    /**
     * @description populate BPName On BPLI for update
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param listNew List<NE__Billing_Profile__c> 
     * @param mapOld Map<Id, NE__Billing_Profile__c>
     * @param mapNew Map<Id, NE__Billing_Profile__c>
     */
    public static void populateBPNameOnUpdate(List<NE__Billing_Profile__c> listNew, Map<Id, NE__Billing_Profile__c> mapOld, Map<Id, NE__Billing_Profile__c> mapNew) {   
        List<String> fieldToCheck = new List<String> {'Name'}; 
        List<NE__Billing_Profile__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }

        Set<Id> bpIds = XC_UTIL_SObject.getSetIds(listChanged);
        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_BillingProfileName__c, XC_BillingProfile__c
                                                                                                    FROM XC_BillingProfileLineItem__c
                                                                                                    WHERE XC_BillingProfile__c IN: bpIds]);
        if(!bpliMap.isEmpty()) {
            for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
                bpli.XC_BillingProfileName__c = mapNew.get(bpli.XC_BillingProfile__c).Name;
            }

            XC_UTIL_SObject.updateListRecords(bpliMap.values());
        }
        
    }


}