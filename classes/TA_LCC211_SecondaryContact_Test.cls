@isTest
public with sharing class TA_LCC211_SecondaryContact_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    static void initialize_Test() {
        TA_LCC211_SecondaryContact instance = new TA_LCC211_SecondaryContact();
        User u = new User(id = UserInfo.getUserId());

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Contact contact = XC_DF_Contact.createResidentialContacts(new List<Account>{accountToInsert})[0];
        insert contact;

        XC_ConsentDescription__c consentDesc = new XC_ConsentDescription__c(
            XC_LegalEntity__c = workOrderTest.XC_LegalEntity__c,
            XC_ConsentStatus__c = 'Active',
            XC_Country__c = 'Spain',
            XC_ConsentVersion__c = '2.0',
            XC_DescriptionLanguage__c = UserInfo.getLanguage()
        );
        insert consentDesc;

        workOrderTest.AccountId = accountToInsert.Id;
        update workOrderTest;

        String jsonTest = '{ "object":"Contact", "fields":["FirstName","LastName","Email","XC_ContactDocumentCountry__c","XC_ContactDocumentType__c","XC_ContactDocumentNumber__c"] }';

        test.startTest();
        TA_LCC211_SecondaryContact.initialize(jsonTest, workOrderTest.Id);
        test.stopTest();
    }

    @isTest
    static void loadContact_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Contact contactTest = XC_DF_Contact.createResidentialContacts(new List<Account>{accountToInsert})[0];
        insert contactTest;

        workOrderTest.AccountId = accountToInsert.Id;

        String jsonTest = '{ "object":"Contact", "fields":["FirstName","LastName","Email","XC_ContactDocumentCountry__c","XC_ContactDocumentType__c","XC_ContactDocumentNumber__c"] }';

        test.startTest();
        TA_LCC211_SecondaryContact.loadContact(jsonTest, accountToInsert.Id, contactTest.Id);
        test.stopTest();
    }

    @isTest
    static void updateContact_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Contact contactTest = XC_DF_Contact.createResidentialContacts(new List<Account>{accountToInsert})[0];
        insert contactTest;

        workOrderTest.AccountId = accountToInsert.Id;

        String jsonTest = '{ "object":"Contact", "fields":["FirstName","LastName","Email","XC_ContactDocumentCountry__c","XC_ContactDocumentType__c","XC_ContactDocumentNumber__c"] }';

        test.startTest();
        TA_LCC211_SecondaryContact.updateContact(jsonTest, workOrderTest.Id, contactTest.Id);
        test.stopTest();
    }

    @isTest
    static void saveNewContact_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Contact contactTest = XC_DF_Contact.createResidentialContacts(new List<Account>{accountToInsert})[0];
        insert contactTest;

        workOrderTest.AccountId = accountToInsert.Id;

        String jsonTest = '{ "object":"Contact", "fields":["FirstName","LastName","Email","XC_ContactDocumentCountry__c","XC_ContactDocumentType__c","XC_ContactDocumentNumber__c"] }';

        test.startTest();
        TA_LCC211_SecondaryContact.saveNewContact(jsonTest, accountToInsert.Id);
        test.stopTest();
    }
}