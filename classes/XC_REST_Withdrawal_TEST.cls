/**
 * The Class XC_IN031_DeactAutRenewal_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/05/2020
 * @date Modification : 
 * @description       : TEST class for XC_REST_Withdrawal
 **/

@isTest 
public without sharing class XC_REST_Withdrawal_TEST {

    @testSetup
    private static void setup() {
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Withdrawal;
        ic.XC_interfaceName__c = Label.XC_CL_Withdrawal;
        insert ic;    
    }

    static testMethod void requestWithdrawal(){
        
        Test.setMock(HttpCalloutMock.class, new ZuoraWithDrawal_Mock_200());

        XC_REST_Withdrawal.WrapperRequest wrReq = new XC_REST_Withdrawal.WrapperRequest();
        wrReq.legalEntity='EndesaX';
        wrReq.stream = 'B2C';
        Test.startTest();
        XC_REST_Withdrawal.WrapperResponse wr = XC_REST_Withdrawal.requestWithdrawal(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }

    static testMethod void requestWithdrawalKO(){
        
        Test.setMock(HttpCalloutMock.class, new ZuoraWithDrawal_Mock_400());

        XC_REST_Withdrawal.WrapperRequest wrReq = new XC_REST_Withdrawal.WrapperRequest();
        wrReq.legalEntity='EndesaX';
        wrReq.stream = 'B2C';
        Test.startTest();
        XC_REST_Withdrawal.WrapperResponse wr = XC_REST_Withdrawal.requestWithdrawal(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }

    static testMethod void requestWithdrawalNoStream(){
        
        Test.setMock(HttpCalloutMock.class, new ZuoraWithDrawal_Mock_400());

        XC_REST_Withdrawal.WrapperRequest wrReq = new XC_REST_Withdrawal.WrapperRequest();
        wrReq.legalEntity='EndesaX';
        Test.startTest();
        XC_REST_Withdrawal.WrapperResponse wr = XC_REST_Withdrawal.requestWithdrawal(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }
    
    
    public without sharing class ZuoraWithDrawal_Mock_200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"results":[{"SubscriptionId":"8adcd9eb6cfb231d016cfcba06da0c87","Success":true}]}');
            return response;
        }
    }

    public without sharing class ZuoraWithDrawal_Mock_400 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"results":[{"SubscriptionId":"8adcd9eb6cfb231d016cfcba06da0c87","Success":false}, "errors":["status": "KO"]]}');
            return response;
        }
    }

}