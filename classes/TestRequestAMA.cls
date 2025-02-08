/**
 * Created by snekkanti002 on 18/07/2022.
 */

@IsTest
public without sharing class TestRequestAMA {
    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        TestDataFactory.createCasesWithAccountContact(accounts[0].Id, contacts[0].Id);
    }

    @IsTest
    public static void requestAMA() {
        Case c = [
                SELECT Id, CaseNumber, Account.FirstName, Account.LastName, Account.Name, checkAnonymous__c, ContactPhone, ContactEmail, Case_Specification__c, Street_Address__c, Number_Address__c, Letter_Address__c, CreatedDate FROM Case LIMIT 1
        ];
        c.Case_Business_Account__c = true;
        update c;

        Test.startTest();
        RequestAMA r = new RequestAMA(c);

        c.Case_Business_Account__c = false;
        update c;
        RequestAMA r1 = new RequestAMA(c);
        Test.stopTest();
    }
}