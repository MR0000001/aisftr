/**
 * @File Name          : XC_LCC183_CreditAssignmentView_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 11-23-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@IsTest
public  class XC_LCC183_CreditAssignmentView_TEST {

    @TestSetup
    static void setup(){

        List<NE__Order__c> orders = XC_DF_Order.createOrders(1,'InOrder');
        insert orders[0];

        NE__OrderItem__c bundleOi = XC_DF_OrderItem.createOrderItem(orders[0]);
        insert bundleOi;

        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(orders[0]);
        oi.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        oi.NE__Bundle_Configuration__c = bundleOi.Id;
        oi.XC_CreditAssignmentSurvey__c = 'https://test.salesforce.com';
        insert oi;

        NE__OrderItem__c bundleOi2 = XC_DF_OrderItem.createOrderItem(orders[0]);
        insert bundleOi2;

        NE__OrderItem__c oi2 = XC_DF_OrderItem.createOrderItem(orders[0]);
        oi2.XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        oi2.NE__Bundle_Configuration__c = bundleOi2.Id;
        oi2.XC_CreditAssignmentSurvey__c = 'https://test.salesforce.com';
        insert oi2;
        
    }

    @IsTest
    static void test1(){
        NE__Order__c ord = [SELECT ID FROM NE__Order__c LIMIT 1];
        Test.startTest();
            XC_LCC183_CreditAssignmentView.getIncentiveItems(ord.Id);
        Test.stopTest();
    }

    @isTest
    static void test2(){
        Map<String,Object> paramsMap = new Map<String,Object>();
        paramsMap.put('orderId',[SELECT Id FROM NE__Order__c LIMIT 1].Id);
        paramsMap.put('updatedItemId',[SELECT Id FROM NE__OrderItem__c LIMIT 1].Id);
        paramsMap.put('cityCode','123');
        paramsMap.put('urbanSection','1');
        paramsMap.put('subordinate','2');
        paramsMap.put('sheet','1');
        paramsMap.put('particle','3');
        Test.startTest();
            XC_LCC183_CreditAssignmentView.propagateAdditionalInfos(paramsMap);
        Test.stopTest();
    }


}