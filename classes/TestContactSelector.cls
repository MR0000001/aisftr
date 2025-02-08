/**
 * Created by snekkanti002 on 18/10/2021.
 */

@IsTest
public with sharing class TestContactSelector {

    @TestSetup
    public static void setup() {
        List<Account> personAccounts = TestDataFactory.createAccounts();
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
    }

    @IsTest
    public static void getLegalEntitiesContactsByAccountIds() {
        Test.startTest();
        ContactSelector.getLegalEntitiesContactsByAccountIds(new List<String>());
        Test.stopTest();
    }

    @IsTest
    public static void upsertContacts() {
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        ContactSelector.upsertContacts(contacts, Schema.Contact.ContactKey__c, false);
        Test.stopTest();
    }

    @IsTest
    public static void updateContacts() {
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        ContactSelector.updateContacts(contacts, false);
        Test.stopTest();
    }

    @IsTest
    public static void getContactsToDeactivate() {
        List<String> contactIds = new List<String>();
        List<Contact> contacts = [SELECT Id FROM Contact];

        for(Contact c : contacts) {
            contactIds.add(c.Id);
        }

        Test.startTest();
        ContactSelector.getContactsToDeactivate(contactIds);
        Test.stopTest();
    }
}