/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@isTest
public with sharing class XC_TR_PPM_Project_Handler_Test {
    @isTest
    static void insertTest() {
        project_cloud__Project__c z = new project_cloud__Project__c();
        List<project_cloud__Project__c> listZ = new List<project_cloud__Project__c>();
        Map<Id,project_cloud__Project__c> mapNew = new Map<id,project_cloud__Project__c>();
        XC_TR_PPM_Project_Handler zu = new XC_TR_PPM_Project_Handler();
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