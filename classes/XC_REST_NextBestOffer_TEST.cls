/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_NextBestOffer_TEST – Test class for XC_REST_NextBestOffer
*/
@isTest
public with sharing class XC_REST_NextBestOffer_TEST {
    static testMethod void callToGetNextBestOfferActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_NextBestOffer;
        ic.XC_interfaceName__c = Label.XC_CL_NextBestOffer;
        insert ic;
        XC_UTIL_Account.AccountIFWrapper wrAccount = new XC_UTIL_Account.AccountIFWrapper();
        List<XC_REST_NextBestOffer.WrapperParameter> offerParameters = new List<XC_REST_NextBestOffer.WrapperParameter>();
       
        Test.startTest(); 
        XC_REST_NextBestOffer.WrapperResult result =XC_REST_NextBestOffer.callToGetNextBestOffer(wrAccount, offerParameters);
        System.assert( result!=null); 
        Test.stopTest();
    }

        static testMethod void callToGetNextBestOfferInActive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_NextBestOffer;
        ic.XC_interfaceName__c = Label.XC_CL_NextBestOffer;
        insert ic;
        XC_UTIL_Account.AccountIFWrapper wrAccount = new XC_UTIL_Account.AccountIFWrapper();
        wrAccount.AccountID='1111';
        wrAccount.PrimaryEmail='test';
        wrAccount.IdentityNumber='68686';
        List<XC_REST_NextBestOffer.WrapperParameter> offerParameters = new List<XC_REST_NextBestOffer.WrapperParameter>();
        XC_REST_NextBestOffer.WrapperParameter offerPar= new XC_REST_NextBestOffer.WrapperParameter();
        offerPar.ParameterName = 'test';
        offerParameters.add(offerPar);
        Test.startTest(); 
        XC_REST_NextBestOffer.WrapperResult result =XC_REST_NextBestOffer.callToGetNextBestOffer(wrAccount, offerParameters);
        System.assert( result!=null);
        Test.stopTest();
    }

    
    static testMethod void callToGetNextBestOfferActive2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_NextBestOffer;
        ic.XC_interfaceName__c = Label.XC_CL_NextBestOffer;
        insert ic;
        XC_UTIL_Account.AccountIFWrapper wrAccount = new XC_UTIL_Account.AccountIFWrapper();
        wrAccount.AccountID='1111';
        wrAccount.PrimaryEmail='test';
        wrAccount.IdentityNumber='68686';

        List<XC_REST_NextBestOffer.WrapperParameter> offerParameters = new List<XC_REST_NextBestOffer.WrapperParameter>();
        Test.startTest(); 
        XC_REST_NextBestOffer.WrapperResult result =XC_REST_NextBestOffer.callToGetNextBestOffer(wrAccount, offerParameters);
        System.assert( result!=null); 
        Test.stopTest();
    }

        static testMethod void callToGetNextBestOfferActive5(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_NextBestOffer;
        ic.XC_interfaceName__c = Label.XC_CL_NextBestOffer;
        insert ic;
        XC_UTIL_Account.AccountIFWrapper wrAccount = new XC_UTIL_Account.AccountIFWrapper();
        wrAccount.AccountID='1111';
        wrAccount.PrimaryEmail='test';
        wrAccount.IdentityNumber='68686';

        List<XC_REST_NextBestOffer.WrapperParameter> offerParameters = new List<XC_REST_NextBestOffer.WrapperParameter>();
        XC_REST_NextBestOffer.WrapperParameter offerPar= new XC_REST_NextBestOffer.WrapperParameter();
        offerPar.ParameterName = 'test';
        offerParameters.add(offerPar);
        Test.setMock(HttpCalloutMock.class, new XC_REST_NextBestOffer_Mock());
        Test.startTest(); 
        XC_REST_NextBestOffer.WrapperResult result =XC_REST_NextBestOffer.callToGetNextBestOffer(wrAccount, offerParameters);
        System.assert( result!=null); 
        Test.stopTest();
    }



}