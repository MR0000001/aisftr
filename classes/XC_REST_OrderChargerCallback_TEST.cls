/**
 * The Class XC_REST_OrderChargerCallback_TEST.
 *
 * @author            : Simone Trenta strenta@deloitte.it
 * @date Creation     : 02/07/2020
 * @date Modification : 
 * @description       : TEST Class for XC_REST_OrderChargerCallback
 */

@isTest
public without sharing class XC_REST_OrderChargerCallback_TEST {

    static testMethod void requestNotActive(){
        XC_REST_OrderChargerCallback.OrderCallbackRequest req = new XC_REST_OrderChargerCallback.OrderCallbackRequest();

        test.startTest();
        XC_REST_OrderChargerCallback.OrderCallbackResponse wr = XC_REST_OrderChargerCallback.sendCallback(req, 'test', 'test');
        system.assertEquals(false, wr.success);
        test.stopTest();
    }

    static testMethod void requestActive(){
        XC_REST_OrderChargerCallback.OrderCallbackRequest req = new XC_REST_OrderChargerCallback.OrderCallbackRequest();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = 'OrderChargerCallback';
        ic.name = 'OrderChargerCallback';
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        insert ic;

        test.startTest();
        XC_REST_OrderChargerCallback.OrderCallbackResponse wr = XC_REST_OrderChargerCallback.sendCallback(req, 'test', 'test');
        system.assert(wr!=null);
        test.stopTest();
    }

}