/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 11/02/2020
* @date Modification 23/07/2021
* @description XC_TR_ZuoraZInvoice_U_CompleteStep 
*/


public without sharing class XC_TR_ZuoraInvItem_U_FillSubscriptionNum {


    /**
    * @description onBeforeInsert
    * @author Simone Trenta - strenta@deloitte.it 
    * @param listNew - List<Zuora__InvoiceItem__c>
    */
    private static void fillSubscriptionNum(List<Zuora__InvoiceItem__c> listNew) {

        Set<String> subid = new Set<String>();
        for(Zuora__InvoiceItem__c item:listNew) {
            if(String.isNotBlank(item.Zuora__Subscription__c)) {
                subid.add(item.Zuora__Subscription__c);
            }
        }
        if(subid.isEmpty()) {
            return;
        }

        Map<Id,Zuora__Subscription__c> subMap = new Map<Id,Zuora__Subscription__c>([SELECT Id, Name
                                                                                    FROM Zuora__Subscription__c
                                                                                    WHERE Id IN: subid]);

        Map<String,String> mapIdNum = new Map<String,String>();
        for(Zuora__Subscription__c sub : subMap.values()) {
            mapIdNum.put(sub.id, sub.Name);
        }

        for(Zuora__InvoiceItem__c item : listNew) {
            if(String.isNotBlank(item.Zuora__Subscription__c)) {
                item.XC_SubscriptionNumber__c = mapIdNum.get(item.Zuora__Subscription__c);
            }
        }
    }


    /**
    * @description onBeforeInsert
    * @author Simone Trenta - strenta@deloitte.it 
    * @param listNew - List<Zuora__InvoiceItem__c>
    */
    public static void onBeforeInsert(List<Zuora__InvoiceItem__c> listNew){
        fillSubscriptionNum(listNew);
    }


    /**
    * @description onBeforeUpdate
    * @author Simone Trenta - strenta@deloitte.it 
    * @param mapOld - List<Zuora__InvoiceItem__c>
    * @param mapNew - List<Zuora__InvoiceItem__c>
    */
    public static void onBeforeUpdate(Map<Id, Zuora__InvoiceItem__c> mapOld, Map<Id, Zuora__InvoiceItem__c> mapNew) {
        List<String> fieldToCheck = new List<String>{'Zuora__Subscription__c'};
        List<Zuora__InvoiceItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            fillSubscriptionNum(listChanged);
        }
    }


    /**
    * @description updateRelatedRecordsOnInsert
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @param listNew - List<Zuora__InvoiceItem__c>
    */
    public static void updateRelatedRecordsOnInsert(List<Zuora__InvoiceItem__c> listNew) {

        Set<Id> invoiceIds = new Set<Id>();
        for(Zuora__InvoiceItem__c item : listNew) {
            if(String.isNotBlank(item.XC_SubscriptionNumber__c) && String.isNotBlank(item.Zuora__Invoice__c)) {
                invoiceIds.add(item.Zuora__Invoice__c);
            }
        }
        if(invoiceIds.isEmpty()) {
            return;
        }

        Map<Id, Zuora__ZInvoice__c> invoiceMap = new Map<Id, Zuora__ZInvoice__c>([SELECT Id, Zuora__Balance2__c, Zuora__PaymentAmount__c
                                                                                    FROM Zuora__ZInvoice__c
                                                                                    WHERE Id IN: invoiceIds]);

        Map<String, Boolean> checkCACoveredInvoicesMap = XC_TR_ZuoraZInvoice_U_CompleteStep.checkCreditAssignmentInvoiceCoverage(invoiceMap.values(), null);
        Set<String> subscriptionNameSet = new Set<String>();
        for(Zuora__InvoiceItem__c item : listNew){ 
            if(String.isNotBlank(item.XC_SubscriptionNumber__c) && String.isNotBlank(item.Zuora__Invoice__c) && invoiceMap.get(item.Zuora__Invoice__c) != null && 
                ((invoiceMap.get(item.Zuora__Invoice__c).Zuora__Balance2__c == 0 && invoiceMap.get(item.Zuora__Invoice__c).Zuora__PaymentAmount__c > 0) ||
                (checkCACoveredInvoicesMap.containsKey(item.Zuora__Invoice__c) && checkCACoveredInvoicesMap.get(item.Zuora__Invoice__c)))) {
                    subscriptionNameSet.add(item.XC_SubscriptionNumber__c);
            }
        }

        if(!subscriptionNameSet.isEmpty()) {
            XC_TR_ZuoraZInvoice_U_CompleteStep.updateRelatedRecordsForPaymentDone(subscriptionNameSet);
        }
    }


    /**
    * @description updateRelatedRecordsOnUpdate
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @param mapOld - List<Zuora__InvoiceItem__c>
    * @param mapNew - List<Zuora__InvoiceItem__c>
    */
    public static void updateRelatedRecordsOnUpdate(Map<Id, Zuora__InvoiceItem__c> mapOld, Map<Id, Zuora__InvoiceItem__c> mapNew) {

        List<String> fieldToCheck = new List<String>{'Zuora__Subscription__c', 'Zuora__Invoice__c'};
        List<Zuora__InvoiceItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            updateRelatedRecordsOnInsert(listChanged);
        }
    }

}