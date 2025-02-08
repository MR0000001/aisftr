/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  05/06/2019 
* @description XC_REST_CreateAmendment_TEST – Test class for XC_REST_CreateAmendment
*/
@isTest
public with sharing class XC_REST_CreateAmendment_TEST {
    
     static testMethod void createAmendmentActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreateAmendment;
        ic.XC_interfaceName__c = Label.XC_CL_CreateAmendment;
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        XC_REST_CreateAmendment_U.WrapperRequest wrapperAmendment = new XC_REST_CreateAmendment_U.WrapperRequest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_CreateAmendment_U.WrapperResponse result =XC_REST_CreateAmendment.createAmendment(wrapperAmendment);
        System.assert(result!=null); 
        Test.stopTest();
    } 
        static testMethod void createAmendmentInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreateAmendment;
        ic.XC_interfaceName__c = Label.XC_CL_CreateAmendment;
        insert ic;
        XC_REST_CreateAmendment_U.WrapperRequest wrapperAmendment = new XC_REST_CreateAmendment_U.WrapperRequest();
        Test.startTest(); 
        XC_REST_CreateAmendment_U.WrapperResponse result =XC_REST_CreateAmendment.createAmendment(wrapperAmendment);
        System.assert(result!=null); 
        Test.stopTest();
    } 


}