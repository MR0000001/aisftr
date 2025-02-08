/**
 * Created by SNEKKANTI00 on 22/12/2020.
 */

@isTest
private class TestScheduledBatchCloseServiceRequest {
    @testSetup static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts();
        Contact c = [SELECT Id FROM Contact WHERE Account.Id =: accounts[0].Id];
        List<Contact> contacts = new List<Contact>{c};
        List<Service_Request__c> serviceRequests = TestDataFactory.createServiceRequests(accounts, contacts);

        Test.setCreatedDate(serviceRequests[0].Id, System.now().addHours(-2));
    }

    @isTest
    private static void withServiceRequest() {
        Test.startTest();
        Database.executeBatch(new ScheduledBatchCloseServiceRequest());
        Test.stopTest();
    }

    @isTest
    private static void scheduleBatch() {
        Test.startTest();
        System.schedule('HourlyBatchCloseServiceRequest', '0 17 * ? * * *', new ScheduledBatchCloseServiceRequest());
        Test.stopTest();
    }
}