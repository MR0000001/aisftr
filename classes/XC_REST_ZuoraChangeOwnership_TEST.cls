/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  06/06/2019 
* @description XC_REST_ZuoraChangeOwnership_TEST – Test class for XC_REST_ZuoraChangeOwnership
*/
@isTest
public class XC_REST_ZuoraChangeOwnership_TEST {
    //Test Method resumeSubscription
    static testMethod void resumeSubscriptionActive(){
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
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_ZuoraChangeOwnership.WrapperRequest wr = new XC_REST_ZuoraChangeOwnership.WrapperRequest();        
        
        Test.startTest();
        XC_REST_ZuoraChangeOwnership.WrapperResponse rw = XC_REST_ZuoraChangeOwnership.resumeSubscription('test',wr);
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method resumeSubscription
    static testMethod void resumeSubscriptionInActive(){
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
        zws.apiToken__c ='headerDefinitions';
        insert zws; 
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        
        XC_REST_ZuoraChangeOwnership.WrapperRequest wr = new XC_REST_ZuoraChangeOwnership.WrapperRequest();        
        
        Test.startTest();
        XC_REST_ZuoraChangeOwnership.WrapperResponse rw = XC_REST_ZuoraChangeOwnership.resumeSubscription('test',wr);
        System.assert(rw!=null);
        Test.stopTest();
        
    }


}