/**
 * The Class XC_TR_Config_U_CustomInter_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 01/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : TEST Class for XC_TR_Config_U_CustomerInteraction
 **/ 


@isTest
public without sharing class XC_TR_Config_U_CustomInter_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }


    static testmethod void testCreateCustInterForAcceptedQuote() {

        NE__Order__c quote = XC_DF_Order.createOrder('InOrder');
        quote.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        quote.XC_Status__c = 'Draft';
        update quote;

        List<XC_Document_to_sign__c> docList = new List<XC_Document_to_sign__c>();
        XC_Document_to_sign__c doc1 = new XC_Document_to_sign__c();
        doc1.XC_Doxee_URL__c = 'URL1';
        doc1.XC_Doxee_ID_external__c = 'ID1';
        doc1.XC_ConfigurationID__c = quote.Id;
        doc1.XC_Signed__c = true;
        docList.add(doc1);
        XC_Document_to_sign__c doc2 = new XC_Document_to_sign__c();
        doc2.XC_Doxee_URL__c = 'URL2';
        doc2.XC_Doxee_ID_external__c = 'ID2';
        doc2.XC_ConfigurationID__c = quote.Id;
        doc2.XC_Signed__c = true;
        docList.add(doc2);
        insert docList;      

        Test.startTest();
        quote.XC_Status__c = 'Accepted';
        update quote;
        Test.stopTest();

        System.assertEquals('Send_Documents', [SELECT Id, XC_Communication_Type__c FROM XC_Customer_Interaction__c WHERE XC_OrderId__c =: quote.Id].XC_Communication_Type__c, 'Wrong assert result');
    }
}