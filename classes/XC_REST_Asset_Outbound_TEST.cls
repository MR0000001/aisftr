/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  04/06/2019 
* @description XC_REST_Asset_Outbound_TEST – Test class for XC_REST_Asset_Outbound
*/
@isTest
public with sharing class XC_REST_Asset_Outbound_TEST {
    static testMethod void callToGetAssetActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_AssetOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_AssetOutbound;
        insert ic;
        Map<String,String> queryStringParams = new Map<String,String>();
        queryStringParams.put('AccountId', '111111');
        queryStringParams.put ('PrimaryEmail', 'test@test.it');
        queryStringParams.put('IdentityNumberAccount', 'Y1120679H');
        //Test.setMock(HttpCalloutMock.class, new XC_REST_NotifyPayment_Mock());
        Test.startTest(); 
        String result =XC_REST_Asset_Outbound.callToGetAsset(queryStringParams);
        System.assert( result!=null); 
        Test.stopTest();
    } 

        static testMethod void callToGetAssetInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_AssetOutbound;
        ic.XC_interfaceName__c = Label.XC_CL_AssetOutbound;
        insert ic;
        Map<String,String> queryStringParams = new Map<String,String>();
        queryStringParams.put('AccountId', '111111');
        queryStringParams.put ('PrimaryEmail', 'test@test.it');
        queryStringParams.put('IdentityNumberAccount', 'Y1120679H');
        //Test.setMock(HttpCalloutMock.class, new XC_REST_NotifyPayment_Mock());
        Test.startTest(); 
        String result =XC_REST_Asset_Outbound.callToGetAsset(queryStringParams);
        System.assert( result!=null); 
        Test.stopTest();
    }

}