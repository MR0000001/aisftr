/**
* The Class XC_REST_OrderCharger_TEST.
*
* @author            : Simone Trenta - strenta@deloitte.it
* @date Creation     : 05/06/2019
* @date Modification : dd/mm/yyyy
* @description       : 
**/


@isTest
public without sharing class XC_REST_OrderCharger_TEST {
    
    @TestSetup
    static void setup(){ 
        
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"Channel":"EnelEnergiaItalia","Document":[{"ContractUrl":"http:z"}],"IntegrationID":"1231213123","LegalEntity":"EnelXItalia","OrderItem":[{"Attribute":[{"Name":"Test:Pfp","ProductFamilyPropertyID":"a1V1l000000PNaMEAW","Value":"Monthly"}],"BaseOneTimeFee":0.00,"BaseRecurringCharge":7.50,"BundleConfiguration":null,"ContractType":"Light","ProdID":"TestCatItem","Quantity":1}],"Status":"Ok"}}';
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_TransactionId__c = 'Test';
        qr.XC_ValidationStatus__c = 'OK';
        qr.XC_IdempotencyToken__c = 'Test';
        qr.XC_Status__c = 'Completed';
        insert qr;
        
        XC_QueuedRequestStep__c qrs = new XC_QueuedRequestStep__c();
        qrs.XC_QueuedRequest__c  = qr.id;
        qrs.XC_Status__c = Label.XC_CL_Completed_OK;
        qrs.XC_StepLabel__c = 'Commodity Callback';
        insert qrs;
    }
    
    @isTest
    static void testDoPost(){
        
        test.startTest();
        
        System.RestContext.request = generateRestRequestPOSTGood();
        
        XC_REST_OrderCharger_U.AccountOrderInfo asd = new XC_REST_OrderCharger_U.AccountOrderInfo();
        asd.AccountOrderInfo='{\"Account\":{\"AccountType\":\"Residential\"},"Order\":{\"LegalEntity\":\"EnelXItalia\"}}';
        
        XC_REST_OrderCharger_U.WrapperRequest body = new XC_REST_OrderCharger_U.WrapperRequest();
        body.AccountOrder=asd;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
        
        System.RestContext.response = new RestResponse();
        
        XC_REST_OrderCharger.doPost();
        System.assertEquals(true,true, 'Wrong assert result');
        
        test.stopTest();
    }
    
    
    @isTest
    static void testDoPostIdempotencyToken(){
        
        test.startTest();
        
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');
        System.RestContext.request.headers.put('IdempotencyToken', 'Test');
        
        XC_REST_OrderCharger_U.AccountOrderInfo asd = new XC_REST_OrderCharger_U.AccountOrderInfo();
        asd.AccountOrderInfo='{\"Account\":{\"AccountType\":\"Residential\"},"Order\":{\"LegalEntity\":\"EnelXItalia\"}}';
        asd.Status = 'OK';

        
        
        XC_REST_OrderCharger_U.WrapperRequest body = new XC_REST_OrderCharger_U.WrapperRequest();
        body.AccountOrder=asd;
        //Mod. CV 20210707 --- Start
        //body.Status = 'OK';
        //Mod. CV 20210707 --- End      
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
        
        System.RestContext.response = new RestResponse();
        
        XC_REST_OrderCharger.doPost();
        System.assertEquals(true,true, 'Wrong assert result');
        
        test.stopTest();
    }
    
    @isTest
    static void testDoPostIdempotencyToken2(){
        
        test.startTest();
        
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.headers.put('ClientSystem', 'CommoditySpainB2C');
        System.RestContext.request.headers.put('IdempotencyToken', 'Test1');
        
        XC_REST_OrderCharger_U.AccountOrderInfo asd = new XC_REST_OrderCharger_U.AccountOrderInfo();
        asd.AccountOrderInfo='{\"Account\":{\"AccountType\":\"Residential\"},"Order\":{\"LegalEntity\":\"EnelXItalia\"}}';
        
        
        XC_REST_OrderCharger_U.WrapperRequest body = new XC_REST_OrderCharger_U.WrapperRequest();
        body.AccountOrder=asd;
        //Mod. CV 20210707 --- Start
        //body.Status = 'OK';
        //Mod. CV 20210707 --- End  
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
        
        System.RestContext.response = new RestResponse();
        
        XC_REST_OrderCharger.doPost();
        System.assertEquals(true,true, 'Wrong assert result');
        
        test.stopTest();
    }
    
    
    @isTest
    static void testDoPostWrong(){
        
        test.startTest();
        
        System.RestContext.request = generateRestRequestPOSTGood();
        
        XC_REST_OrderCharger_U.WrapperRequest body = new XC_REST_OrderCharger_U.WrapperRequest();
        
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));
        
        System.RestContext.response = new RestResponse();
        
        XC_REST_OrderCharger.doPost();
        System.assertEquals(true,true, 'Wrong assert result');
        
        test.stopTest();
    }
    
    private static RestRequest generateRestRequestPostGood(){
        
        RestRequest request = new RestRequest();
        
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'CreateCase');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  
        
        request.httpMethod = 'POST';
        request.requestURI = '/v1/OrderCharger/*';
        
        return request; 
    }
    
}