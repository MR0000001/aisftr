/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  05/06/2019 
* @description XC_REST_SuspendSubscription_TEST – Test class for XC_REST_SuspendSubscription
*/
@isTest
public with sharing class XC_REST_SuspendSubscription_TEST {

        @TestSetup
        static void testSetup(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;  
            ic.XC_URL_Required__c = 'test';
            ic.Name = Label.XC_CL_SuspendSubscription;
            ic.XC_interfaceName__c = Label.XC_CL_SuspendSubscription;         
            insert ic;
        }


        @isTest
    static void legalEntityNotFound() {
        String subscriptionId='11111'; 
        XC_REST_SuspendSubscription.WrapperRequest wrReq = new XC_REST_SuspendSubscription.WrapperRequest();
        wrReq.legalEntity='Test';
        wrReq.stream='Test';
        Test.startTest();
            XC_REST_SuspendSubscription.WrapperResponse result =XC_REST_SuspendSubscription.suspendSubscription(subscriptionId,wrReq);
        System.assert(result.success==false);    
        Test.stopTest();
    }

    static testMethod void suspendSubscription400Statuscode(){
     
        String subscriptionId='11111'; 
        XC_REST_SuspendSubscription.WrapperRequest wrReq = new XC_REST_SuspendSubscription.WrapperRequest();
        wrReq.invoice=true;
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock400());
            Test.startTest(); 
            XC_REST_SuspendSubscription.WrapperResponse result =XC_REST_SuspendSubscription.suspendSubscription(subscriptionId,wrReq);
            System.assert(result!=null);    
        Test.stopTest();
    } 

    
    static testMethod void suspendSubscription200(){
        String subscriptionId='11111'; 
        XC_REST_SuspendSubscription.WrapperRequest wrReq = new XC_REST_SuspendSubscription.WrapperRequest();
        wrReq.invoice=true;
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());
        Test.startTest(); 
        XC_REST_SuspendSubscription.WrapperResponse result =XC_REST_SuspendSubscription.suspendSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 

    
    static testMethod void suspendSubscription200RunAndBill(){
        String subscriptionId='11111'; 
        XC_REST_SuspendSubscription.WrapperRequest wrReq = new XC_REST_SuspendSubscription.WrapperRequest();
        wrReq.invoice=null;
        wrReq.runBilling=true;
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());
        Test.startTest(); 
        XC_REST_SuspendSubscription.WrapperResponse result =XC_REST_SuspendSubscription.suspendSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 


    
    public without sharing class XC_REST_CallPayAndBill_Mock implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"subscriptionId": "12345","suspendDate" : "2020-01-01","resumeDate":"2020-01-01","termEndDate" : "2020-10-01","totalDeltaTcv": 10.0,"invoiceId": "test01","reasons" : [{"code": "0","message":"test"}] }');
            res.setStatusCode(200);

            return res;
        }
    }

     public without sharing class XC_REST_CallPayAndBill_Mock400 implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody();
            res.setStatusCode(400);
            
            return res;    
        }
    }

     public without sharing class XC_REST_CallPayAndBill_MockNullRes implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody();
            res.setStatusCode(400);
            res=null;
            return res;    
        }
    }


}