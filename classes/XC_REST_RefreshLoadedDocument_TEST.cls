/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  24/11/2020 
* @description XC_REST_RefreshLoadedDocument_TEST – Test class for XC_REST_RefreshLoadedDocument
*/ 

@isTest
public with sharing class XC_REST_RefreshLoadedDocument_TEST {
    
    @isTest
    static void callToDoxeeInactive(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'RefreshLoadedDocument';
        ic.XC_interfaceName__c = 'RefreshLoadedDocument';
        insert ic;
        
        XC_REST_RefreshLoadedDocument.RequestWrapper rw = new XC_REST_RefreshLoadedDocument.RequestWrapper();
        test.startTest();
        XC_REST_RefreshLoadedDocument.callToDoxee(rw);
        test.stopTest();
    }
    
    @isTest
    static void callToDoxee(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'RefreshLoadedDocument';
        ic.XC_interfaceName__c = 'RefreshLoadedDocument';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_RefreshLoadedDocument_MOCK());
        
        XC_REST_RefreshLoadedDocument.RequestWrapper rw = new XC_REST_RefreshLoadedDocument.RequestWrapper();
        test.startTest();
        XC_REST_RefreshLoadedDocument.callToDoxee(rw);
        test.stopTest();
    }

    
}