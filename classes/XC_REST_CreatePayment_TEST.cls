/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  05/06/2019 
* @description XC_REST_CreatePayment_TEST – Test class for XC_REST_CreatePayment
*/
@isTest
public with sharing class XC_REST_CreatePayment_TEST {

    
    @TestSetup
    static void testSetup(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreatePayment;
        ic.XC_interfaceName__c = Label.XC_CL_CreatePayment;      
        insert ic;
    }

    static testMethod void createPaymentActive(){

        XC_REST_CreatePayment_U.WrapperRequest wrapperPayment= new XC_REST_CreatePayment_U.WrapperRequest();
        wrapperPayment.legalEntity='EndesaX';
        wrapperPayment.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_CreatePayment_U.WrapperResponse result = XC_REST_CreatePayment.createPayment(wrapperPayment);
        System.assert(result!=null);    
        Test.stopTest();
    } 

   
    static testMethod void createPaymentWrongEntityName(){

        XC_REST_CreatePayment_U.WrapperRequest wrapperPayment= new XC_REST_CreatePayment_U.WrapperRequest();
        wrapperPayment.legalEntity='Test';
        wrapperPayment.stream='Test';
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_CreatePayment_U.WrapperResponse result = XC_REST_CreatePayment.createPayment(wrapperPayment);
        System.assert(result!=null);    
        Test.stopTest();
    } 

    static testMethod void createPaymentStatusCode(){

        XC_REST_CreatePayment_U.WrapperRequest wrapperPayment= new XC_REST_CreatePayment_U.WrapperRequest();
        wrapperPayment.legalEntity='EndesaX';
        wrapperPayment.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.setMock(HttpCalloutMock.class, new XC_REST_CreatePayment_MockStatusCode());
        Test.startTest(); 
        XC_REST_CreatePayment_U.WrapperResponse result = XC_REST_CreatePayment.createPayment(wrapperPayment);
        System.assert(result != null);    
        Test.stopTest();
    } 


    public without sharing class XC_REST_CreatePayment_MockStatusCode implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            return res;    
        }
    }

}