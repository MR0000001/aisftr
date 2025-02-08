/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  04/06/2019 
* @description XC_REST_Case_Outbound_TEST – Test class for XC_REST_Case_Outbound
*/
@isTest
public with sharing class XC_REST_Case_Outbound_TEST {
    
    @TestSetup
	static void setup(){
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<XC_CS001_InterfaceConfiguration__c> interfaces = new List<XC_CS001_InterfaceConfiguration__c>();  
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound; 
        interfaces.add(ic);
        insert interfaces;
         
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
    }
    
    /*TEST WITH INACTIVE INTERFACE*/
    
    static testMethod void callInitReadCaseRequest(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        
        Test.startTest();  
            Map<String, String> paramsMap = new Map<String, String>();
            HttpRequest req = XC_REST_Case_Outbound.initReadCaseRequest(paramsMap);
            System.assert(req!=null);
        Test.stopTest();
    }
    
     static testMethod void callToCreateCaseActiveY(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CaseOutboundYourban';
        ic.XC_interfaceName__c = 'CaseOutboundYourban';
        insert ic;
        
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        String caseId= c[0].Id; 
        Test.setMock(HttpCalloutMock.class, new XC_REST_Case_Outbound_Mock());


        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest();  
        XC_REST_Case_W.WrapperCaseResponseUpsert result=XC_REST_Case_Outbound.callToCreateCase(caseWr);
        System.assert( result!=null);
        Test.stopTest();
    }
    
    static testMethod void callToUpdateCaseActiveY(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CaseOutboundYourban';
        ic.XC_interfaceName__c = 'CaseOutboundYourban';
        insert ic;
        
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        String caseId= c[0].Id; 
        Test.setMock(HttpCalloutMock.class, new XC_REST_Case_Outbound_Mock());


        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest();  
        XC_REST_Case_W.WrapperCaseResponseUpsert result=XC_REST_Case_Outbound.callToUpdateCase(caseWr);
        System.assert( result!=null);
        Test.stopTest();
    }
    
    static testMethod void callToCreateCaseActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        
        List<Case> c = XC_DF_Case.createCases(1);
        insert c;
        String caseId= c[0].Id; 
        Test.setMock(HttpCalloutMock.class, new XC_REST_Case_Outbound_Mock());


        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest();  
        XC_REST_Case_W.WrapperCaseResponseUpsert result=XC_REST_Case_Outbound.callToCreateCase(caseWr);
        System.assert( result!=null);
        Test.stopTest();
    }

    static testMethod void callToUpdateCaseActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        List<Case> c = XC_DF_Case.createCases(1);
        String caseId= c[0].Id;
        XC_UTIL_Case.CaseRESTWrapper caseX = new XC_UTIL_Case.CaseRESTWrapper();
        caseX.Province = 'Almeria';
        caseX.Country = 'Spain';
        String jsonUpdate = JSON.serialize(caseX);
        Test.setMock(HttpCalloutMock.class, new XC_REST_Case_Outbound_Mock());

        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseUpsert result =XC_REST_Case_Outbound.callToUpdateCase(caseWr);
        System.assert( result!=null); 
        Test.stopTest();
    }

        static testMethod void callToUpdateCaseActive2(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        List<Case> c = XC_DF_Case.createCases(1);
        String caseId= c[0].Id;
        XC_UTIL_Case.CaseRESTWrapper caseX = new XC_UTIL_Case.CaseRESTWrapper();
        caseX.Province = 'Almeria';
        caseX.Country = 'Spain';
        String jsonUpdate = JSON.serialize(caseX);

        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseUpsert result =XC_REST_Case_Outbound.callToUpdateCase(caseWr);
        System.assert( result!=null); 
        Test.stopTest();
    }

    static testMethod void callToGetCaseActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        Map<String, String> queryStringParameters = NEW Map<String, String>(); 
        queryStringParameters.put('AccountId', '111111');
        queryStringParameters.put ('PrimaryEmail', 'test@test.it');
        queryStringParameters.put('IdentityNumberAccount', 'Y1120679H');
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_Case_Outbound_Mock());
        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseGET result =XC_REST_Case_Outbound.callToGetCase(queryStringParameters);
        System.assert( result!=null); 
        Test.stopTest();
    }

    static testMethod void callToGetCaseActive2(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        Map<String, String> queryStringParameters = NEW Map<String, String>();
        queryStringParameters.put('AccountId', '111111');
        queryStringParameters.put ('PrimaryEmail', 'test@test.it');
        queryStringParameters.put('IdentityNumberAccount', 'Y1120679H');
        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseGET result =XC_REST_Case_Outbound.callToGetCase(queryStringParameters);
        System.assert( result!=null); 
        Test.stopTest();
    }
    
    /*TEST WITH INACTIVE INTERFACE*/
    
    static testMethod void callToCreateCaseInActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        
        List<XC_CS001_InterfaceConfiguration__c> ic = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE Name =: Label.XC_CL_CaseOutbound ];
        ic[0].XC_activeInterface__c = false;
        update ic;
        
        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();
        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseUpsert result =XC_REST_Case_Outbound.callToCreateCase(caseWr);
        System.assert( result!=null); 
        Test.stopTest();
    }
    
    static testMethod void callToUpdateCaseInActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        XC_UTIL_Case.CaseRESTWrapper caseX = new XC_UTIL_Case.CaseRESTWrapper();
        caseX.Province = 'Almeria';
        caseX.Country = 'Spain';
        String jsonUpdate = JSON.serialize(caseX);
        List<Case> c = XC_DF_Case.createCases(1);
        String caseId= c[0].Id;

        XC_UTIL_Case.CaseRESTWrapper caseWr = new XC_UTIL_Case.CaseRESTWrapper();

        Test.startTest(); 
        XC_REST_Case_W.WrapperCaseResponseUpsert result =XC_REST_Case_Outbound.callToUpdateCase(caseWr);
        System.assert( result!=null); 
        Test.stopTest();
    }
    
    static testMethod void callToGetCaseInActive(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound; 
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
        
        Map<String, String> queryStringParameters = NEW Map<String, String>();
        queryStringParameters.put('AccountId', '111111');
        queryStringParameters.put ('PrimaryEmail', 'test@test.it');
        queryStringParameters.put('IdentityNumberAccount', 'Y1120679H');
        
        Test.startTest(); 
         XC_REST_Case_W.WrapperCaseResponseGET result =XC_REST_Case_Outbound.callToGetCase(queryStringParameters);
        System.assert( result!=null); 
        result =XC_REST_Case_Outbound.callToGetCase(queryStringParameters, 'Spain', false);
        Test.stopTest();
    }
    
    static testMethod void manageResponseUPSERT(){
        /*insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CaseOutbound; 
        ic.XC_interfaceName__c = Label.XC_CL_CaseOutbound;
        insert ic;*/
       
        
        Test.startTest(); 
       	XC_REST_Case_Outbound.manageResponseUPSERT(new Httpresponse());
        Test.stopTest();
    }
    
}