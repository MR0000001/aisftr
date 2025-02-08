/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  05/06/2019 
* @description XC_REST_PayAndBill_TEST – Test class for XC_REST_PayAndBill
*/
@isTest
public class XC_REST_PayAndBill_TEST {
    //Test Method createPayAndBill
    static testMethod void createPayAndBill(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PayAndBill;
        ic.XC_interfaceName__c = Label.XC_CL_PayAndBill;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());
        
        XC_REST_PayAndBill.WrapperRequest wrReq = new XC_REST_PayAndBill.WrapperRequest();
        Test.startTest();
        XC_REST_PayAndBill.WrapperResponse wr = XC_REST_PayAndBill.createPayAndBill(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }
    
    //Test Method createPayAndBillInActive
    static testMethod void createPayAndBillInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PayAndBill;
        ic.XC_interfaceName__c = Label.XC_CL_PayAndBill;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());
        
        XC_REST_PayAndBill.WrapperRequest wrReq = new XC_REST_PayAndBill.WrapperRequest();
        
        Test.startTest();
        XC_REST_PayAndBill.WrapperResponse wr = XC_REST_PayAndBill.createPayAndBill(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }

    static testMethod void createPayAndBillLegalEntity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PayAndBill;
        ic.XC_interfaceName__c = Label.XC_CL_PayAndBill;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());

        XC_REST_PayAndBill.WrapperRequest wrReq = new XC_REST_PayAndBill.WrapperRequest();
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.startTest();
        XC_REST_PayAndBill.WrapperResponse wr = XC_REST_PayAndBill.createPayAndBill(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }

    static testMethod void createPayAndBillBadReq(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'badReq';
        ic.Name = Label.XC_CL_PayAndBill;
        ic.XC_interfaceName__c = Label.XC_CL_PayAndBill;
        insert ic;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_CallPayAndBill_Mock());

        XC_REST_PayAndBill.WrapperRequest wrReq = new XC_REST_PayAndBill.WrapperRequest();
        wrReq.legalEntity='EndesaX';
        wrReq.stream='B2C';
        Test.startTest();
        XC_REST_PayAndBill.WrapperResponse wr = XC_REST_PayAndBill.createPayAndBill(wrReq);
        System.assert(wr!=null,'WrapperResult is not null');
        Test.stopTest();
        
    }

    public without sharing class XC_REST_CallPayAndBill_Mock implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            Map<String, Object> resp = new Map<String, Object>();
            resp.put('access_token','test');
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(resp, true));
            
            if(req.getEndpoint().endsWith('badReq')) {
                res.setStatusCode(400);
            }else{
                 res.setStatusCode(200);
            }
            
            return res;    
        }
    }





}