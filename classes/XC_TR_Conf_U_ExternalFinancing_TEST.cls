/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 04/03/2020
* @date Modification 
* @description XC_TR_Conf_U_ExternalFinancing_TEST - Test class for XC_TR_Configuration_U_ExternalFinancing
*/
@isTest
public without sharing class XC_TR_Conf_U_ExternalFinancing_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @isTest
    static void updateExternalFinancingCase(){
        List<Account> listOfAcc = XC_DF_Account.createResidentialAccounts(1);
        insert listOfAcc;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        List<XC_Address__c> listOfAddress = XC_DF_Address.createAddress(listOfAcc);
        insert listOfAddress;
        NE__Order__c ord = XC_DF_Order.createOrderWithAddress('InOrder', listOfAddress[0].Id, listOfAcc[0].Id, listOfOpp[0].Id);
        NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = 'TEST', Name ='TEST' );
        insert catalog;
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: ord.Id]);
        List<NE__Billing_Profile__c> listOfBp = XC_DF_BillingProfile.createBillingProfile(1);
        listOfBp[0].NE__Payment__c = 'External Financing';
        update listOfBp;
        List<XC_BillingProfileLineItem__c> listOfBpItem = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =: listOfBp[0].Id]);
        for(NE__OrderItem__c oi : listOfOrderItem){
            oi.NE__Catalog__c = catalog.Id;
            oi.XC_PaymentMethod__c = 'External Financing';
            oi.XC_BillingProfileLineItem__c = listOfBpItem[0].Id;
            oi.XC_ForcePaymentMethodEdit__c = true;
        }
        update listOfOrderItem;
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        ord.RecordTypeId = rtOrder;
        Test.startTest();
        update ord;
        Test.stopTest();
    }
}