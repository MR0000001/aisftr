/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  05/06/2019 
* @description XC_REST_UpdateCreditCardPaymentMet_TEST – Test class for XC_REST_UpdateCreditCardPaymentMethod
*/
@isTest
public with sharing class XC_REST_UpdateCreditCardPaymentMet_TEST {
    
        @isTest static void updateCreditCardPaymentMethodActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_UpdateCreditCardPaymentMethod;
        ic.XC_interfaceName__c = Label.XC_CL_UpdateCreditCardPaymentMethod;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String paymentMethodId='1111';
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest wrReq = new XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest();
        wrReq.expirationYear='11111';
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse result =XC_REST_UpdateCreditCardPaymentMethod.updateCreditCardPaymentMethod(paymentMethodId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 
        @isTest static void updateCreditCardPaymentMethodActive1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_UpdateCreditCardPaymentMethod;
        ic.XC_interfaceName__c = Label.XC_CL_UpdateCreditCardPaymentMethod;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String paymentMethodId='1111';
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest wrReq = new XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_ZuoraToken_Mock());
        Test.startTest(); 
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse result =XC_REST_UpdateCreditCardPaymentMethod.updateCreditCardPaymentMethod(paymentMethodId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    } 

        @isTest static void updateCreditCardPaymentMethodInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_UpdateCreditCardPaymentMethod;
        ic.XC_interfaceName__c = Label.XC_CL_UpdateCreditCardPaymentMethod;         
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='Spain'; 
        zws.EntityId__c= '8adce421661fcddc01664460d73d41c2';
        zws.Client_Secret__c='qzeQayHZPUQFRsuSSprAFfP6mgRe4sviHtE5wAFa' ; 
        zws.Client_Id__c = 'aaf997e3-4edd-4008-a5ba-f778e6d83149	';
        zws.Host__c= 'rest.sandbox.eu.zuora.com';
        insert zws; 
        String paymentMethodId='111';
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest wrReq = new XC_REST_UpdateCreditCardPaymentMethod_U.WrapperRequest();
        Test.startTest(); 
        XC_REST_UpdateCreditCardPaymentMethod_U.WrapperResponse result =XC_REST_UpdateCreditCardPaymentMethod.updateCreditCardPaymentMethod(paymentMethodId,wrReq);
        System.assert(result!=null);    
        Test.stopTest();
    }

}