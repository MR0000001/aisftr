@isTest
public with sharing class XC_REST_ShippingCost_TEST {
    
    @testSetup
    static void setup() {
        List<XC_ShippingCostZone__c> shippingCostZones = new List<XC_ShippingCostZone__c>();
        shippingCostZones.add(new XC_ShippingCostZone__c(XC_Country__c = 'Italy', XC_KeyValue__c = 'Roma', XC_Area__c = 'Test Area'));
        insert shippingCostZones;
    }

    @isTest
    static void postFail_NullRequest() {

        test.startTest();

        System.RestContext.request = generateGETRequest(null, 'err_header');

        XC_REST_ShippingCost.doGet();

    }
    
    @isTest
    static void postFail_missingHeader() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'err_header');

        XC_REST_ShippingCost.doGet();

    }

    @isTest
    static void postFail_emptyBody() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'empty');

        XC_REST_ShippingCost.doGet();

    }

    @isTest
    static void postFail_missingRequired() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('Address', 'Via Roma'); 
        System.RestContext.request.addParameter('StreetNumber', '5'); 
        System.RestContext.request.addParameter('City', 'Roma'); 

        XC_REST_ShippingCost.doGet();
    }
    
    @isTest
    static void postFail_missingRequired2() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('Address', 'Via Roma'); 
        System.RestContext.request.addParameter('City', 'Roma'); 

        XC_REST_ShippingCost.doGet();
    }
    
        @isTest
    static void postFail_missingRequired3() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('City', 'Roma'); 

        XC_REST_ShippingCost.doGet();
    }

    @isTest
    static void postFail_ShippingCostNotFound() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        delete [SELECT Id FROM XC_ShippingCostZone__c WHERE XC_Country__c = 'Italy'];

        test.startTest();
        
        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('Address', 'Via Roma'); 
        System.RestContext.request.addParameter('StreetNumber', '5'); 
        System.RestContext.request.addParameter('City', 'Roma'); 
        System.RestContext.request.addParameter('Country', 'Italy'); 

        XC_REST_ShippingCost.doGet();

    }

    @isTest
    static void postFail_AssocNotFound() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        
        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('Address', 'Via Roma'); 
        System.RestContext.request.addParameter('StreetNumber', '5'); 
        System.RestContext.request.addParameter('City', 'Roma'); 
        System.RestContext.request.addParameter('Country', 'WrongCountry'); 

        XC_REST_ShippingCost.doGet();

     
    }

    @isTest
    static void postOK() {
        XC_REST_ShippingCost_W.WrapperRequest wrReq = new XC_REST_ShippingCost_W.WrapperRequest();

        test.startTest();
        
        System.RestContext.request = generateGETRequest(wrReq, 'OK');
        System.RestContext.request.addParameter('StreetType', 'Highway'); 
        System.RestContext.request.addParameter('Address', 'Via Roma'); 
        System.RestContext.request.addParameter('StreetNumber', '5'); 
        System.RestContext.request.addParameter('City', 'Roma'); 
        System.RestContext.request.addParameter('Country', 'Italy'); 

        XC_REST_ShippingCost.doGet();

    }

    static RestRequest generateGETRequest(XC_REST_ShippingCost_W.WrapperRequest wrReq, String operation) {
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();

        request.httpMethod = 'GET';
    	request.requestURI = '/v1/ShippingCost/';

        if(operation!='err_header'){
            request = addHeader(request);
        }

        return request;

    }

    static RestRequest addHeader(RestRequest request) {
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'getShippingCostArea');
        request.addHeader('DateTimeMessage', '20210101000000000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test'); 
        return request;
    }
}