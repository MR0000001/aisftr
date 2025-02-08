/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creaton  04/06/2019 
* @description XC_REST_NotifyPayment_TEST – Test class for XC_REST_NotifyPayment
*/
@isTest
public with sharing class XC_REST_NotifyPayment_TEST {
     @isTest static void createPaymentActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreatePayment;
        ic.XC_interfaceName__c = Label.XC_CL_CreatePayment;
        insert ic;
        XC_REST_NotifyPayment_U.WrapperRequest wrapperPayment = new XC_REST_NotifyPayment_U.WrapperRequest();
       Test.setMock(HttpCalloutMock.class, new XC_REST_NotifyPayment_Mock());
        Test.startTest(); 
        XC_REST_NotifyPayment.WrapperResult result =XC_REST_NotifyPayment.createPayment(wrapperPayment);
        System.assert( result!=null); 
        Test.stopTest();
    }

        @isTest static void createPaymentInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreatePayment;
        ic.XC_interfaceName__c = Label.XC_CL_CreatePayment;
        insert ic;
        XC_REST_NotifyPayment_U.WrapperRequest wrapperPayment = new XC_REST_NotifyPayment_U.WrapperRequest();
       
        Test.startTest(); 
        XC_REST_NotifyPayment.WrapperResult result =XC_REST_NotifyPayment.createPayment(wrapperPayment);
        System.assert( result!=null); 
        Test.stopTest();
    }

    @isTest
    private static void testWrapper() {
        Test.startTest();
        	XC_REST_NotifyPayment_U.WrapperRequest wr = new XC_REST_NotifyPayment_U.WrapperRequest();
        Test.stopTest();
    }
    
}