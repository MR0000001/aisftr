/**
 * Created by snekkanti002 on 18/10/2021.
 */

@IsTest
public with sharing class TestContactService {

    @TestSetup
    public static void setup() {
        List<Account> personAccounts = TestDataFactory.createAccounts();
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
    }

    @IsTest
    public static void getLegalEntitiesContacts() {
        String accId = [SELECT id FROM Account LIMIT 1].Id;

        Test.startTest();
        ContactService.getLegalEntitiesContacts(new List<String>{accId});
        Test.stopTest();
    }

    @IsTest
    public static void upsertContacts() {
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        ContactService.upsertContacts(contacts, Schema.Contact.ContactKey__c, false);
        Test.stopTest();
    }

    @IsTest
    public static void deactivateContactsNotInSigeud() {
        String conId = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.startTest();
        ContactService.deactivateContactsNotInSigeud(new List<String>{conId});
        Test.stopTest();
    }

    @IsTest
    public static void setContactFieldsSigeud() {
        LegalEntitiesController.SigeudContact sigeudContact = new LegalEntitiesController.SigeudContact();
        sigeudContact.firstName = 'test first name';
        sigeudContact.lastName = 'test last name';
        sigeudContact.role = 'test role';
        sigeudContact.roleDescription = 'test role description';
        sigeudContact.startDate = System.today();
        sigeudContact.endDate = System.today()+1;
        sigeudContact.sigeudDate = System.today();
        sigeudContact.isDeleted = false;
        sigeudContact.contactKey = 'FRRGNN41S21G513Y';

        Test.startTest();
        ContactService.setContactFieldsSigeud(sigeudContact);
        Test.stopTest();
    }
}