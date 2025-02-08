/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  10/06/2019 
* @description XC_TR_ConfigurationItem_U_CancelO_TEST – Test class for XC_TR_ConfigurationItem_U_CancelOrder
*/ 
@isTest
public with sharing class XC_TR_ConfigurationItem_U_CancelO_TEST {
    //Test method checkConfigurationItemStatus
    static testMethod void checkConfigurationItemStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'InOrder');
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].NE__Status__c = Label.XC_CL_Configuration_Pending;
        insert oi;
        oi[0].NE__Status__c = 'Completed';
        update oi; 

        System.assertEquals(1, oi.size());
        Test.stopTest();
    }

        //Test method checkConfigurationItemStatus2
    static testMethod void checkConfigurationItemStatus2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'InOrder');
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].NE__Status__c = Label.XC_CL_Configuration_Pending;
        insert oi;
        oi[0].NE__Status__c = Label.XC_CL_Configuration_OrderCancelled;
        update oi; 

        System.assertEquals(1, oi.size());
        Test.stopTest();
    }

        //Test method checkConfigurationItemStatus3
    static testMethod void checkConfigurationItemStatus3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'InOrder');
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].NE__Status__c ='Active' ;
        insert oi;
        oi[0].NE__Status__c = Label.XC_CL_Configuration_Pending;
        update oi; 

        System.assertEquals(1, oi.size());
        Test.stopTest();
    }

}