/**
 * @File Name          : XC_UTIL_PaymentMethodFilter_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 29/5/2020, 18:39:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    29/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
public without sharing class XC_UTIL_PaymentMethodFilter_TEST {

    @TestSetup
    static void setup(){
        
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c oi2 = XC_DF_OrderItem.createOrderItem(ord);
        oi2.XC_BillingModel__c = 'One Shot';
        oi2.XC_Product_Subtype__c = 'Boiler';
        insert oi2;

    }


    @isTest
    static void getAvailableMopsForLeTest(){
        Test.startTest();
            XC_UTIL_PaymentMethodFilter.getAvailableMopsForLe('EnelXItalia', 'B2C');
        Test.stopTest();
    }

    @isTest
    static void getAvailabeMopsForOrderItems_TEST(){
        List<NE__OrderItem__c> orderItems = [SELECT ID,XC_Product_Subtype__c,XC_BillingModel__c, NE__Billing_Account__c, NE__Account__c FROM NE__OrderItem__c];
        Test.startTest();
            XC_UTIL_PaymentMethodFilter.getAvailabeMopsForOrderItems('EnelXItalia', 'B2C', orderItems);
        Test.stopTest();
    }

}