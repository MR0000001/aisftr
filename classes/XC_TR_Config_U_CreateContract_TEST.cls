/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  21/05/2019 
    * @description XC_TR_Config_U_CreateContract_TEST – Test class for XC_TR_Configuration_U_CreateContract
    */ 
    @isTest
public with sharing class XC_TR_Config_U_CreateContract_TEST {
    //Test method handleCreationContract
    static testMethod void handleCreationContract(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    List<NE__Order__c> o = XC_DF_Order.createOrders(1, 'InOrder');
    o[0].NE__OrderStatus__c ='Pending'; 
    insert o; 
    o[0].NE__OrderStatus__c ='Completed'; 
    update o; 
    System.assertEquals(1, o.size());
    Test.stopTest();
    }

    //Test method handleCreationContract1
    static testMethod void handleCreationContract1(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    List<NE__Order__c> o = XC_DF_Order.createOrders(1, 'InOrder');
    insert o;  
    o[0].NE__Configuration_Type__c =Label.XC_CL_Configuration_TypeNew; 
    update o; 
    System.debug('@@@-LISTA CONF'+ o);
    System.assertEquals(1, o.size());
    Test.stopTest();
    }

     //Test method handleCreationContract2
    static testMethod void handleCreationContract2(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    List<NE__Order__c> o = XC_DF_Order.createOrders(1, 'InOrder');
    insert o;  
    o[0].NE__Configuration_Type__c =Label.XC_CL_Configuration_TypeNew; 
    o[0].NE__OrderStatus__c =Label.XC_CL_Order_StatusSent; 
    update o; 
    System.assertEquals(1, o.size());
    Test.stopTest();
    }

}