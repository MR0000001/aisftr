/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@isTest
public with sharing class XC_TR_wbe_tracking_Test {
    static testMethod void submitTest(){
        XC_WbeTracking__c tw = new XC_WbeTracking__c();
        tw.XC_ConfigurationItemId__c = 'DL';
        tw.XC_ConfigurationId__c = 'DL';
        tw.XC_OrderNumber__c = 'DL';
        tw.XC_SalesOrder__c = 'DL';
        tw.XC_Wbe__c = 'DL';
        tw.XC_CompanyCode__c = 'CL25';
        tw.XC_ProductLine__c = 'E600';
        tw.XC_ProductService__c = 'DL';
        tw.XC_WBS__c = 'DL';
        tw.XC_WbeI__c = 'DL';
        tw.XC_WbeII__c = 'DL';
        tw.XC_WbeIII__c = 'DL';
        tw.XC_BusinessModelCode__c = '2';
        tw.XC_Market__c = '002';
        tw.XC_CostCenterResponsible__c = 'DL';
        tw.XC_CostCenter__c = 'DL';
        tw.XC_ProfitCenter__c = 'DL';
        tw.XC_SapPillar__c = 'S4P';
        tw.XC_Scope__c = 'B2B/G';
        tw.XC_TypeOfSending__c = 'Order Submit';
        tw.XC_Status__c = 'Sent';
        Insert tw;
        update tw;
        Delete tw;

    }
}