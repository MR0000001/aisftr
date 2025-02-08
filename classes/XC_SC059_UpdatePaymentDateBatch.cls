/**
 * @description       : XC_SC059_UpdatePaymentDateBatch to check if the payment is done
 * @author            : Nicola Mariniello - nmariniello@deloitte.it
 * @created date      : 23-07-2021
 * @last modified on  : 
 * @last modified by  : 
 **/


public without sharing class XC_SC059_UpdatePaymentDateBatch implements Database.Batchable<Sobject>,Schedulable {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC059_UpdatePaymentDateBatch');


    public void execute(SchedulableContext sc) {
        Id batchId = Database.executeBatch(new XC_SC059_UpdatePaymentDateBatch(),50);
    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC059_UpdatePaymentDateBatch.start');
    
        String segment = 'B2C';
        String billingModel = 'One Shot';
        String query = 'SELECT Id, XC_Configuration_Item__c, XC_InvoiceDate__c, XC_InvoiceNumber__c, XC_SubscriptionName__c, XC_PaymentMethod__c, XC_BillingModel__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c '+
                        'FROM Asset ' + 
                        'WHERE XC_BillingModel__c = \''+ billingModel + '\' AND  XC_Segment__c= \'' + segment + '\' AND Status In (\'Active\', \'Purchased\') ' +
                        'AND XC_InvoiceNumber__c <> NULL AND XC_SubscriptionName__c <> NULL AND (NE__Bundle_Configuration__c <> NULL OR XC_Product_Type__c = \'Bundle\') ' + 
                        'AND (XC_PaymentDate__c = NULL OR XC_Configuration_Item__r.XC_PaymentDate__c = NULL)';

        System.Debug('BATCH QUERY ' + query);
        return Database.getQueryLocator(query);
    }


    public void execute(Database.BatchableContext bc, List<Asset> scope) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC059_UpdatePaymentDateBatch.execute');

        Set<String> subscriptionNames = new Set<String>();
        for(Asset asset : scope) {
            if(String.isNotBlank(asset.XC_SubscriptionName__c)) {
                subscriptionNames.add(asset.XC_SubscriptionName__c);
            }
        }

        if(!subscriptionNames.isEmpty()) {
            Map<Id, Zuora__ZInvoice__c> invoiceMap = new Map<Id, Zuora__ZInvoice__c>([SELECT Id, Zuora__Balance2__c, Zuora__PaymentAmount__c, 
                                                                                            (SELECT Id, Zuora__Invoice__c, XC_SubscriptionNumber__c FROM Zuora__Invoice_Items__r)
                                                                                        FROM Zuora__ZInvoice__c
                                                                                        WHERE Id IN (SELECT Zuora__Invoice__c FROM Zuora__InvoiceItem__c WHERE XC_SubscriptionNumber__c IN: subscriptionNames)]);

            Map<String, Boolean> checkCACoveredInvoicesMap = XC_TR_ZuoraZInvoice_U_CompleteStep.checkCreditAssignmentInvoiceCoverage(invoiceMap.values(), null);
            Set<String> subscriptionNameToProcess = new Set<String>();
            for(Zuora__ZInvoice__c invoice : invoiceMap.values()) {
                for(Zuora__InvoiceItem__c ii : invoice.Zuora__Invoice_Items__r) { 
                    if(String.isNotBlank(ii.XC_SubscriptionNumber__c) && 
                        ((invoice.Zuora__Balance2__c == 0 && invoice.Zuora__PaymentAmount__c > 0) ||
                        (checkCACoveredInvoicesMap.containsKey(invoice.Id) && checkCACoveredInvoicesMap.get(invoice.Id)))) {
                            subscriptionNameToProcess.add(ii.XC_SubscriptionNumber__c);
                    }
                }
            }

            if(!subscriptionNameToProcess.isEmpty()) {
                XC_TR_ZuoraZInvoice_U_CompleteStep.updateRelatedRecordsForPaymentDone(subscriptionNameToProcess);
            }
        }

    }


    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC059_UpdatePaymentDateBatch.finish');
    }

}