/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 23-07-2021
 * @last modified by  : Nicola Mariniello - nmariniello@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   23-23-2021   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/


public without sharing class XC_SC044_UpdateInvoiceNumbersBatch implements Database.Batchable<Sobject>,Schedulable {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC044_UpdateInvoiceNumbersBatch');


    public void execute(SchedulableContext sc){
        Id batchId = Database.executeBatch(new XC_SC044_UpdateInvoiceNumbersBatch(),50);
    }



    public Database.QueryLocator start(Database.BatchableContext bc) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC044_UpdateInvoiceNumbersBatch.start');
    
        String legalEntity = Label.XC_CL_LegalEntity_Italy;
        String segment = 'B2C';
        String billingModel = 'One Shot';
        String query = 'SELECT Id, XC_Configuration_Item__c, XC_InvoiceDate__c, XC_InvoiceNumber__c, XC_SubscriptionName__c, XC_PaymentMethod__c, XC_BillingModel__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c '+
                        'FROM Asset ' + 
                        'WHERE XC_LegalEntity__c = \'' + legalEntity + '\' AND XC_BillingModel__c= \''+ billingModel + '\' AND  XC_Segment__c= \'' + segment +
                        '\' AND XC_InvoiceDate__c = NULL AND XC_InvoiceNumber__c = NULL AND (NE__Bundle_Configuration__c <> NULL OR XC_Product_Type__c = \'Bundle\') AND XC_SubscriptionName__c <> NULL';

        System.Debug('BATCH QUERY ' + query);
        return Database.getQueryLocator(query);
    }


    public void execute(Database.BatchableContext bc, List<Asset> scope) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC044_UpdateInvoiceNumbersBatch.execute');

        Set<String> subscriptionNames = new Set<String>();
        for(Asset asset : scope) {
            if(String.isNotBlank(asset.XC_SubscriptionName__c)) {
                subscriptionNames.add(asset.XC_SubscriptionName__c);
            }
        }

        if(!subscriptionNames.isEmpty()) {

            Map<Id, Zuora__ZInvoice__c> invoicesMap = new Map<Id,Zuora__ZInvoice__c>();
            Map<String, String> subscriptionNumbersSetMap = new Map<String, String>();

            List<Zuora__InvoiceItem__c> invoiceItems = [SELECT Id, Zuora__Invoice__c, Zuora__Invoice__r.Name, Zuora__Invoice__r.Zuora__InvoiceDate__c, XC_SubscriptionNumber__c 
                                                        FROM Zuora__InvoiceItem__c 
                                                        WHERE XC_SubscriptionNumber__c IN :subscriptionNames
                                                            AND Zuora__Invoice__c <> null
                                                            AND Zuora__Invoice__r.Zuora__Status__c = 'Posted'];
            if(invoiceItems.isEmpty()) {
                return;
            }

            for(Zuora__InvoiceItem__c ii : invoiceItems) {
                invoicesMap.put(ii.Zuora__Invoice__c, new Zuora__ZInvoice__c(Id = ii.Zuora__Invoice__c,
                                                                                Name = ii.Zuora__Invoice__r.Name,
                                                                                Zuora__InvoiceDate__c = ii.Zuora__Invoice__r.Zuora__InvoiceDate__c));
                subscriptionNumbersSetMap.put(ii.XC_SubscriptionNumber__c, ii.Zuora__Invoice__c);
            }

            XC_TR_ZuoraInvItem_U_FillInvoiceNum.updateRecordsForInvoice(scope, invoicesMap, subscriptionNumbersSetMap);
        }

    }


    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC044_UpdateInvoiceNumbersBatch.finish');
    }

}