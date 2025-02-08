/**
 * The Class XC_REST_Disconnection_TEST
 *
 * @author            : Dario Tramontin dtramontin@deloitte.it
 * @date Creation     : 03/06/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Test Rest Resourse to Manage Discconection
 **/

@isTest
public without sharing class XC_REST_Disconnection_TEST {

    static testMethod void disconnectSubscription(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraDisconnection;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraDisconnection;
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
        
        XC_REST_Disconnection.WrapperRequest wrReq = new XC_REST_Disconnection.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        wrReq.subscriptionId = 'fake';
        wrReq.cancellationDate = '2020-03-04T13:45:39.357+02:00';
        wrReq.subType = 'Rethinking';
        Test.startTest();
        XC_REST_Disconnection.WrapperResponse rw  = XC_REST_Disconnection.manageDisconnection(wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }

    static testMethod void disconnectNoLegalEntity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraDisconnection;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraDisconnection;
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
        
        XC_REST_Disconnection.WrapperRequest wrReq = new XC_REST_Disconnection.WrapperRequest();
        wrReq.subscriptionId = 'fake';
        wrReq.cancellationDate = '2020-03-04T13:45:39.357+02:00';
        wrReq.subType = 'Rethinking';
        Test.startTest();
        XC_REST_Disconnection.WrapperResponse rw  = XC_REST_Disconnection.manageDisconnection(wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }

    //Test Method cancelSubscription
    static testMethod void cancelSubscriptionInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraDisconnection;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraDisconnection;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_Disconnection.WrapperRequest wrReq = new XC_REST_Disconnection.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        wrReq.subscriptionId = 'fake';
        wrReq.cancellationDate = '2020-03-04T13:45:39.357+02:00';
        wrReq.subType = 'Rethinking';
        Test.startTest();
        XC_REST_Disconnection.WrapperResponse rw  = XC_REST_Disconnection.manageDisconnection(wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
        
    static testMethod void cancelSubscriptionActiveWrongCode(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraDisconnection;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraDisconnection;
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
        
        XC_REST_Disconnection.WrapperRequest wrReq = new XC_REST_Disconnection.WrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        wrReq.subscriptionId = 'fake';
        wrReq.cancellationDate = '2020-03-04T13:45:39.357+02:00';
        wrReq.subType = 'Rethinking';
        Test.startTest();
        XC_REST_Disconnection.WrapperResponse rw  = XC_REST_Disconnection.manageDisconnection(wrReq);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    static testMethod void cancelSubscriptionQueued(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'ZuoraQueuedFlow';
        ic.XC_interfaceName__c = 'ZuoraQueuedFlow';
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
        
        XC_REST_Disconnection.QFWrapperRequest wrReq = new XC_REST_Disconnection.QFWrapperRequest();
        wrReq.legalEntity = 'EndesaX';
        wrReq.stream = 'B2C';
        Test.startTest();
        XC_REST_Disconnection.WrapperResponse rw  = XC_REST_Disconnection.manageDisconnection(wrReq);
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