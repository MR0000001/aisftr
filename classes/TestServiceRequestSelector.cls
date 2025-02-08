/**
 * Created by SNEKKANTI00 on 13/05/2021.
 */

@IsTest
public with sharing class TestServiceRequestSelector {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        TestDataFactory.createServiceRequests(accounts, contacts);
    }

    @isTest
    public static void updateServiceRequestsTest() {
        List<Service_Request__c> serviceRequests = [SELECT CheckStatus__c FROM Service_Request__c];
        Test.startTest();
        ServiceRequestSelector.updateServiceRequests(serviceRequests, false);
        ServiceRequestSelector.updateServiceRequests(null, true);
        Test.stopTest();
    }
}