/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  16/11/2020 
* @description XC_REST_Subscription_Outbound_TEST – Test class for XC_REST_Subscription_Outbound
*/ 

@isTest
public class XC_REST_Subscription_Outbound_TEST {
    
    @isTest
    static void activateCall(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'ActivateSubscription';
        ic.XC_interfaceName__c = 'ActivateSubscription';
        insert ic;
        
        XC_REST_Subscription_Outbound.RequestWrapper rw = new XC_REST_Subscription_Outbound.RequestWrapper();
        test.startTest();
        XC_REST_Subscription_Outbound.activateCall(rw);
        test.stopTest();
    }
    
    @isTest
    static void activateCallActive(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'ActivateSubscription';
        ic.XC_interfaceName__c = 'ActivateSubscription';
        insert ic;
        
        XC_REST_Subscription_Outbound.RequestWrapper rw = new XC_REST_Subscription_Outbound.RequestWrapper();
        test.startTest();
        XC_REST_Subscription_Outbound.activateCall(rw);
        test.stopTest();
    }
    
    @isTest
    static void deactivateCall(){
        XC_REST_Subscription_Outbound.RequestWrapper rw = new XC_REST_Subscription_Outbound.RequestWrapper();
        test.startTest();
        XC_REST_Subscription_Outbound.deactivateCall(rw);
        test.stopTest();
    }
    
    @isTest
    static void deactivateCallActive(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'DeactivateSubscription';
        ic.XC_interfaceName__c = 'DeactivateSubscription';
        insert ic;
        
        XC_REST_Subscription_Outbound.RequestWrapper rw = new XC_REST_Subscription_Outbound.RequestWrapper();
        test.startTest();
        XC_REST_Subscription_Outbound.deactivateCall(rw);
        test.stopTest();
    }
    
    
}