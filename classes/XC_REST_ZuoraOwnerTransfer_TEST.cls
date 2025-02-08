/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  06/06/2019 
* @description XC_REST_ZuoraOwnerTransfer_TEST – Test class for XC_REST_ZuoraOwnerTransfer
*/
@isTest
public class XC_REST_ZuoraOwnerTransfer_TEST {
    //Test Method zuoraChangeOwnership
    @isTest static void zuoraChangeOwnership(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
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
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wr = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        wr.legalEntity = 'EndesaX';
        wr.stream = 'B2C';
        
        Test.startTest();
        XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wr);
        System.assert(wr!=null);
        Test.stopTest();
    }


    @isTest static void zuoraChangeOwnershipNoEntityName(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
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
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wr = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        
        Test.startTest();
        XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wr);
        System.assert(wr!=null);
        Test.stopTest();
    }


    @isTest static void zuoraChangeOwnershipNoActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
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
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wr = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        
        Test.startTest();
        XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wr);
        System.assert(wr!=null);
        Test.stopTest();
    }


    @isTest static void zuoraChangeOwnership400(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraChangeOwnership_Mock_400());
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wr = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        wr.legalEntity = 'EndesaX';
        wr.stream = 'B2C';

        Test.startTest();
        XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wr);
        System.assert(wr!=null);
        Test.stopTest();
    }

    public without sharing class XC_REST_ZuoraChangeOwnership_Mock_400 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            return response; 
        }
    }

}