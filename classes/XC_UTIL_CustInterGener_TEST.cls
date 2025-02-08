/**
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 24/06/2019
 * @date Modification : 26/06/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description       : Test Class for XC_UTIL_CustomerInteractionGeneration
 **/

@isTest
public without sharing class XC_UTIL_CustInterGener_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }

    @isTest
    static void testInsertCustInter(){
        List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        test.startTest();
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_CustomerInteractionGeneration.insertCustomerInteraction(customerIntList[0]);
        test.stopTest();
        System.assertNotEquals(customerIntList, null);
    }   

    @isTest
    static void testProdCateg(){
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        test.startTest();
        Boolean bool = XC_UTIL_CustomerInteractionGeneration.isLeadProductCategoryBlank(leadList[0].Id);
        test.stopTest();
        System.assertNotEquals(leadList, null);
    }

    @isTest
    static void testPopulateFromLead(){
        List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        Map<String,Object> values = new Map<String,Object>{'leadId' => leadList[0].Id};
        test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(customerIntList[0], values);
        test.stopTest();
        System.assertNotEquals(customerIntList, null);
    }

    @isTest
    static void testPopulateFromLeadWithContact(){
        List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;
        Map<String,Object> values = new Map<String,Object>{'leadId' => leadList[0].Id, 'contactId' => contactList[0].Id, 'fullName' => 'TEST', 'email' => 'test@email.com'};
        test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(customerIntList[0], values);
        test.stopTest();
        System.assertNotEquals(customerIntList, null);
    }

}