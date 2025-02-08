/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  06/06/2019 
* @description XC_REST_ZuoraCancelSubscription_TEST – Test class for XC_REST_ZuoraCancelSubscription
*/

@isTest
public class XC_REST_ZuoraCancelSubscription_TEST {
    
    //Test Method cancelSubscription
    static testMethod void cancelSubscriptionActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CancelSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_CancelSubscription;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_ZuoraCancelSubscription_U.WrapperRequest wrReq = new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        
        Test.startTest();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse rw  = XC_REST_ZuoraCancelSubscription.cancelSubscription('test',wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    
    //Test Method cancelSubscription
    static testMethod void cancelSubscriptionActiveNoLegalEntity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CancelSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_CancelSubscription;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_ZuoraCancelSubscription_U.WrapperRequest wrReq = new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
        
        Test.startTest();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse rw  = XC_REST_ZuoraCancelSubscription.cancelSubscription('test',wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    
    //Test Method cancelSubscription
    static testMethod void cancelSubscriptionInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CancelSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_CancelSubscription;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_ZuoraCancelSubscription_U.WrapperRequest wrReq = new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
        
        Test.startTest();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse rw  = XC_REST_ZuoraCancelSubscription.cancelSubscription('test',wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    
    //Test Method cancelSubscription
    static testMethod void cancelSubscriptionActiveWrongCode(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CancelSubscription;
        ic.XC_interfaceName__c = Label.XC_CL_CancelSubscription;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraTokenWrongCode_Mock());
        
        XC_REST_ZuoraCancelSubscription_U.WrapperRequest wrReq = new XC_REST_ZuoraCancelSubscription_U.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        
        Test.startTest();
        XC_REST_ZuoraCancelSubscription_U.WrapperResponse rw  = XC_REST_ZuoraCancelSubscription.cancelSubscription('test',wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    public with sharing class XC_REST_ZuoraTokenWrongCode_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
    
            Map<String, Object> resp = new Map<String, Object>();
            resp.put('access_token','test');
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(resp, true));
            
            if(req.getEndpoint().endsWith('token')) {
                res.setStatusCode(200);
            } else {
                res.setStatusCode(400);
            }
            
            return res;    
        }
    }

}