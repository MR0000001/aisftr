/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC041_StartProvisioning_TEST – Test class for XC_LCC041_StartProvisioning
*/ 
@isTest
public with sharing class XC_LCC041_StartProvisioning_TEST {
    //Test Method checkCondition
    static testMethod void checkCondition(){
    insert XC_DF_OneOrg.createOneOrg('Spain');   

        XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItems = [SELECT Id FROM NE__OrderItem__c];
        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c() ;
        ps.XC_Configuration_Item__c = orderItems[0].Id; 
        ps.XC_Step_Order__c = 1;
        ps.XC_Status__c = 'In Progress';
        insert ps;
        Test.startTest();
        XC_LCC041_StartProvisioning.resultWrapper rw = XC_LCC041_StartProvisioning.checkCondition(orderItems[0].Id);
        XC_LCC041_StartProvisioning.startStepsAura(orderItems[0].Id);
        System.assertEquals(orderItems.size(),1);
        Test.stopTest();
    }

}