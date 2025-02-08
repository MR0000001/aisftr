/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  03/06/2019  
* @description XC_REST_PaymentMethodSIA_TEST – Test class for XC_REST_PaymentMethodSIA
*/

@isTest
public with sharing class XC_REST_PaymentMethodSIA_TEST { 

    static testMethod void callToPaymentSIAActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        insert XC_DF_Contact.createResidentialContacts(1);
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'PaymentMethodSIA_SEPA';
        ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
        insert ic;
        XC_REST_PaymentMethodSIA_U.requestWrapper reqWrapp = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        reqWrapp.Email ='test@test.it';
        reqWrapp.typeX='test';
        reqWrapp.typeX = 'ONE_SHOT';
        reqWrapp.typeX = 'RECURRENT';
        Test.setMock(HttpCalloutMock.class, new XC_REST_PaymentMethodSIA_Mock());
        Test.startTest(); 
        XC_REST_PaymentMethodSIA_U.ResponseWrapper result =XC_REST_PaymentMethodSIA.callForSEPA(new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA());
        System.assert( result!=null);
        Test.stopTest();
    }
 
    static testMethod void callToPaymentSIACCInactive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Contact.createResidentialContacts(1);
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PaymentMethodSIA;
        ic.XC_interfaceName__c = Label.XC_CL_PaymentMethodSIA;
        insert ic;
        XC_REST_PaymentMethodSIA_U.requestWrapper reqWrapp = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        reqWrapp.Email ='test@test.it';
        reqWrapp.typeX='test';
        reqWrapp.typeX = 'ONE_SHOT';
        reqWrapp.typeX = 'RECURRENT';
        Test.startTest(); 
        try{
            XC_REST_PaymentMethodSIA.ResultWrapper result =XC_REST_PaymentMethodSIA.callForCreditCard(reqWrapp, [select id from contact][0].id, 'test');
        } catch(exception e){
            System.assert( e!=null);
        }
        
        
        Test.stopTest();
    }

    
    static testMethod void callToPaymentSIAInactive3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Contact.createResidentialContacts(1);
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PaymentMethodSIA;
        ic.XC_interfaceName__c = Label.XC_CL_PaymentMethodSIA;
        insert ic;
        XC_REST_PaymentMethodSIA_U.requestWrapper reqWrapp = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        reqWrapp.Email ='test@test.it';
        reqWrapp.typeX='test';
        reqWrapp.typeX = 'ONE_SHOT';
        reqWrapp.typeX = 'RECURRENT';
        Test.startTest(); 
        XC_REST_PaymentMethodSIA.ResultWrapper result =XC_REST_PaymentMethodSIA.callForCreditCard(reqWrapp, [select id from contact][0].id, 'test');
        System.assert( result!=null);
        Test.stopTest();
    }
    
    static testMethod void callToPaymentSIAActive1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Contact.createResidentialContacts(1);
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_PaymentMethodSIA;
        ic.XC_interfaceName__c = Label.XC_CL_PaymentMethodSIA;
        insert ic;
        XC_REST_PaymentMethodSIA_U.requestWrapper reqWrapp = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        reqWrapp.Email ='test@test.it';
        reqWrapp.typeX='test';
        reqWrapp.typeX = '   ';
        reqWrapp.typeX = '   ';
        Test.startTest(); 
        XC_REST_PaymentMethodSIA.ResultWrapper result =XC_REST_PaymentMethodSIA.callForCreditCard(reqWrapp, [select id from contact][0].id, 'test');
        System.assert( result!=null);
        Test.stopTest();
    }

    static testMethod void callToPaymentSIAInactive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Contact.createResidentialContacts(1);
            
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'PaymentMethodSIA_SEPA';
        ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
        insert ic;
        XC_REST_PaymentMethodSIA_U.requestWrapper reqWrapp = new XC_REST_PaymentMethodSIA_U.requestWrapper();
        reqWrapp.Email ='test@test.it';
        reqWrapp.typeX='test';
        reqWrapp.typeX = 'ONE_SHOT';
        reqWrapp.typeX = 'RECURRENT';
        Test.startTest(); 
        XC_REST_PaymentMethodSIA_U.ResponseWrapper result =XC_REST_PaymentMethodSIA.callForSEPA(new XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA());
        System.assert( result!=null);
        Test.stopTest();
    }

    @isTest
    private static void checkRequiredParametersTEST() {
        XC_REST_PaymentMethodSIA_U.RequestWrapper wr = new XC_REST_PaymentMethodSIA_U.RequestWrapper();
        wr.Email = '';

        Test.startTest();
           XC_UTIL_Integration.Result res = XC_REST_PaymentMethodSIA_U.checkRequiredParameters(wr);
        Test.stopTest();
    }

    @isTest
    private static void checkRequiredParametersTEST2() {
        XC_REST_PaymentMethodSIA_U.RequestWrapper wr = new XC_REST_PaymentMethodSIA_U.RequestWrapper();
        wr.Email = 'esdvg';
		wr.typeX = 'ojsdkjfjk';
        
        Test.startTest();
           XC_UTIL_Integration.Result res = XC_REST_PaymentMethodSIA_U.checkRequiredParameters(wr);
        Test.stopTest();
    }
    
    @isTest
    private static void manageResponse() {
        Test.startTest();
        XC_REST_PaymentMethodSIA.ResultWrapper res = XC_REST_PaymentMethodSIA.manageResponse(new HttpResponse());
        res = XC_REST_PaymentMethodSIA.manageResponse(null);
        Test.stopTest();
    }
}