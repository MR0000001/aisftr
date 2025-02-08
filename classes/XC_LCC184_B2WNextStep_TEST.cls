/**
 * @File Name          : XC_LCC184_B2WNextStep_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 8/6/2020, 16:47:38
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
public without sharing class XC_LCC184_B2WNextStep_TEST {

    @TestSetup
    static void setup(){
        XC_DF_Order.createOrder('InOrder');
        XC_DF_DataMap.createDataMap('Order2Order');
    }

    @isTest
    static void b2wOrderToOrder_TEST(){

        List<NE__Order__c> currentOrd = [SELECT ID FROM NE__Order__c LIMIT 1];
        Map<String,Object> params = new Map<String,Object>{'recordId'=>currentOrd[0].Id,'rtName'=>'Order'};
        Test.startTest();
            XC_LCC184_B2WNextStep.b2wOrderToOrder(params);
        Test.stopTest();
    }

    @isTest
    static void checkLEBusinessProcess_TEST(){
        List<NE__Order__c> currentOrd = [SELECT ID FROM NE__Order__c LIMIT 1];
        Test.startTest();
            XC_LCC184_B2WNextStep.checkLEBusinessProcess(currentOrd[0].Id);
        Test.stopTest();
    }

    @isTest
    static void checkCapexModelItemsAmount(){
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        
        oppList[0].XC_Segment__c = 'B2G';
        oppList[0].XC_IndustrialKPI__c = 'Work Contract';
        oppList[0].XC_LegalEntity__c = 'EnelSole';
        oppList[0].XC_Invited_Checkbox__c = false;
        oppList[0].StageName = 'Abandoned';    
        oppList[0].XC_BusinessLine__c = 'eCity';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        oppList[0].XC_ProductCategory__c = 'Optimize';
        oppList[0].XC_ProductCategoryOfInterest__c = 'Architectural Lighting';
        update oppList;
        

        List<Account> acc = [SELECT Id FROM Account];
        List<XC_Address__c> address = [SELECT Id FROM XC_Address__c];

        Test.startTest();
        List<NE__Order__c> currentOrd = [SELECT ID FROM NE__Order__c LIMIT 1];
        currentOrd[0].RecordTypeId = Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        currentOrd[0].XC_Segment__c = 'B2G';
        currentOrd[0].XC_LegalEntity__c = 'EnelSole';
        currentOrd[0].XC_DeliveryAddress__c = address[0].Id;
        currentOrd[0].XC_InstallationAddress__c = address[0].Id;
        currentOrd[0].NE__AccountId__c = acc[0].Id;
        currentOrd[0].NE__OptyId__c = oppList[0].Id;

        update currentOrd;

        NE__OrderItem__c configItem = XC_DF_OrderItem.createOrderItem(currentOrd[0]);
        configItem.XC_BillingModel__c = 'Capex';
        configItem.NE__Account__c = acc[0].Id;
        configItem.XC_Installation_Address__c = address[0].Id;

        insert configItem;

        Map<String,Object> params = new Map<String,Object>{'recordId'=>currentOrd[0].Id,'rtName'=>'Order'};
        
            XC_LCC184_B2WNextStep.b2wOrderToOrder(params);
        Test.stopTest();
    }

}