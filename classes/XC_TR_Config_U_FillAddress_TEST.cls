/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  21/05/2019 
* @date Modification 26/06/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Config_U_FillAddress_TEST – Test class for XC_TR_Configuration_U_FillAddress
*/ 
    @isTest
public with sharing class XC_TR_Config_U_FillAddress_TEST {

    //Test method populateAddressFromOpportunity
    static testMethod void populateAddressFromOpportunity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Order__c> o = XC_DF_Order.createOrders(1, 'InOrder'); 
        List<XC_Address__c> address = [SELECT Id FROM XC_Address__c];
        System.debug('@@@ address --> ' + address);
        address[0].XC_BillingAddress__c = true;
        address[0].XC_DeliveryAddress__c = true;
        address[0].XC_InstallationAddress__c = true;
        update address;
        o[0].XC_DeliveryAddress__c = address[0].Id;
        insert o;  
        System.assertNotEquals(o, null);
        Test.stopTest();
    }

}