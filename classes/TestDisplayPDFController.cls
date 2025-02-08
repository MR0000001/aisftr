/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestDisplayPDFController {

    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        TestDataFactory.createCasesWithAccountContact(accounts[0].Id, contacts[0].Id);
    }

    @IsTest
    public static void displayPDFController() {

        List<Case> cases = [SELECT Id, AccountId, Case_Business_Account__c FROM Case];
        for(Case c : cases) {
            c.Case_Business_Account__c = true;
        }

        update cases;

        PageReference pageRef = Page.renderAsPdf;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('caseId', cases[0].Id);
        pageRef.getParameters().put('accountId', cases[0].AccountId);
        pageRef.getParameters().put('structure', 'some structure');
        pageRef.getParameters().put('owner', 'urp');
        pageRef.getParameters().put('type', '');
        pageRef.getParameters().put('origin', 'call');
        pageRef.getParameters().put('subject', 'test');
        pageRef.getParameters().put('address', 'via roma');

        Test.startTest();
        DisplayPDFController d = new DisplayPDFController();
        Test.stopTest();
    }
}