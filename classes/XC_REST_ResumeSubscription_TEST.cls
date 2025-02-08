/**
* @author Luca Tedeschi - ltedeschi@deloitte.it
* @date Creation  07/06/2019 
* @description XC_REST_ResumeSubscription_TEST – Test class for XC_REST_ResumeSubscription
*/
@isTest
public with sharing class XC_REST_ResumeSubscription_TEST {
    	
    	//Test method to send ResumeSubscriptionActive
        static testMethod void ResumeSubscriptionActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ResumeSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_ResumeSubscription;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String subscriptionId='11111'; 
        XC_REST_ResumeSubscription.WrapperRequest wrReq = new XC_REST_ResumeSubscription.WrapperRequest();
        wrReq.invoice=true;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_ResumeSubscription.WrapperResponse result =XC_REST_ResumeSubscription.resumeSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 

  
    //Test method to send ResumeSubscriptionActive2
        static testMethod void ResumeSubscriptionActive2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ResumeSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_ResumeSubscription;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String subscriptionId='11111'; 
        XC_REST_ResumeSubscription.WrapperRequest wrReq = new XC_REST_ResumeSubscription.WrapperRequest();
        wrReq.runBilling=true;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_ResumeSubscription.WrapperResponse result =XC_REST_ResumeSubscription.resumeSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 
    
    
    //Test method to send ResumeSubscriptionInActive
        static testMethod void ResumeSubscriptionInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ResumeSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_ResumeSubscription;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String subscriptionId='11111'; 
        XC_REST_ResumeSubscription.WrapperRequest wrReq = new XC_REST_ResumeSubscription.WrapperRequest();
        wrReq.invoice=true;
        wrReq.collectX = true;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_ResumeSubscription.WrapperResponse result =XC_REST_ResumeSubscription.resumeSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    }
   static testMethod void manageResponse(){
         Map<String, Object> resp = new Map<String, Object>();
        resp.put('access_token','test');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resp, true));
        res.setStatusCode(200);  
        HttpResponse resNull = new HttpResponse();
       test.startTest();
      XC_REST_ResumeSubscription.WrapperResponse result =XC_REST_ResumeSubscription.manageResponse(res);
      XC_REST_ResumeSubscription.WrapperResponse resultNull =XC_REST_ResumeSubscription.manageResponse(resNull);
       test.stopTest();
    }
    //Test method to send ResumeSubscriptionActive
        static testMethod void ResumeSubscriptionActiveVNic(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ResumeSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_ResumeSubscription;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String subscriptionId='11111'; 
        XC_REST_ResumeSubscription.WrapperRequest wrReq = new XC_REST_ResumeSubscription.WrapperRequest();
        wrReq.invoice=true;
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_ResumeSubscription.WrapperResponse result =XC_REST_ResumeSubscription.resumeSubscription(subscriptionId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 
}