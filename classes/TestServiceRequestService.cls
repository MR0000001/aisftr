/**
 * Created by SNEKKANTI00 on 13/05/2021.
 */

@isTest
public with sharing class TestServiceRequestService {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        TestDataFactory.createServiceRequests(accounts, contacts);
    }

    @isTest
    public static void closeServiceRequestsTest() {
        List<Service_Request__c> serviceRequests = [SELECT CheckStatus__c FROM Service_Request__c];
        Test.startTest();
        ServiceRequestService.closeAndUpdateServiceRequests(serviceRequests);
        Test.stopTest();
    }
}