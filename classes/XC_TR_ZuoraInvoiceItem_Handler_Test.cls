/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@isTest
public with sharing class XC_TR_ZuoraInvoiceItem_Handler_Test {
    @isTest
    static void insertTest() {
        Zuora__InvoiceItem__c z = new Zuora__InvoiceItem__c();
        List<Zuora__InvoiceItem__c> listZ = new List<Zuora__InvoiceItem__c>();
        Map<Id,Zuora__InvoiceItem__c> mapNew = new Map<id,Zuora__InvoiceItem__c>();
        XC_TR_ZuoraInvoiceItem_Handler zu = new XC_TR_ZuoraInvoiceItem_Handler();
        //zu.onAfterUpdate();
        zu.onBeforeInsert(listZ);
        zu.onBeforeUpdate(mapNew,mapNew);
        zu.onAfterInsert(mapNew);
        zu.onAfterUpdate(mapNew,mapNew);
        zu.onAfterDelete(mapNew);
        zu.onAfterUnDelete(mapNew);
        zu.onBeforeDelete(mapNew);
        zu.executedTrigger();
        


    }
}