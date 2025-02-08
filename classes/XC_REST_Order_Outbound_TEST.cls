@isTest
public with sharing class XC_REST_Order_Outbound_TEST {

   static testMethod void callToOrderOutboundPOSTActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_OrderOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_OrderOutbound;
        insert ic;
        XC_REST_Order_U.WrapperPOSTRequest  postWrapper =new XC_REST_Order_U.WrapperPOSTRequest ();
        Test.startTest(); 
        XC_REST_Order_Outbound.WrapperResponse result =XC_REST_Order_Outbound.callToOrderOutboundPOST(postWrapper);
         System.assert( result!=null);
        Test.stopTest();
   }


   static testMethod void callToOrderOutboundPOSTInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_OrderOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_OrderOutbound;
        insert ic;
        XC_REST_Order_U.WrapperPOSTRequest  postWrapper =new XC_REST_Order_U.WrapperPOSTRequest ();
        Test.startTest(); 
        XC_REST_Order_Outbound.WrapperResponse result =XC_REST_Order_Outbound.callToOrderOutboundPOST(postWrapper);
         System.assert( result!=null);
        Test.stopTest();
   }



      static testMethod void callToOrderOutboundPUTActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_OrderOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_OrderOutbound;
        insert ic;
        XC_REST_Order_U.WrapperPUTRequest putWrapper =new XC_REST_Order_U.WrapperPUTRequest ();
        Test.startTest(); 
        XC_REST_Order_Outbound.WrapperResponse result =XC_REST_Order_Outbound.callToOrderOutboundPUT(putWrapper);
         System.assert( result!=null);
        Test.stopTest();
   }


   static testMethod void callToOrderOutboundPUTInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_OrderOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_OrderOutbound;
        insert ic;
        XC_REST_Order_U.WrapperPUTRequest putWrapper =new XC_REST_Order_U.WrapperPUTRequest ();
        Test.startTest(); 
        XC_REST_Order_Outbound.WrapperResponse result =XC_REST_Order_Outbound.callToOrderOutboundPUT(putWrapper);
         System.assert( result!=null);
        Test.stopTest(); 
   }
}