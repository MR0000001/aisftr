/**
 * Created by dolombardi on 15/12/2020.
 */
@isTest
public with sharing class XC_TR_ProductConsumed_Handler_Test {
    @isTest
    static void insertTest() {
        XC_ProductConsumed__c z = new XC_ProductConsumed__c();
        List<XC_ProductConsumed__c> listZ = new List<XC_ProductConsumed__c>();
        Map<Id,XC_ProductConsumed__c> mapNew = new Map<id,XC_ProductConsumed__c>();
        XC_TR_ProductConsumed_Handler zu = new XC_TR_ProductConsumed_Handler();
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