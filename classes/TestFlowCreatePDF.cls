/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestFlowCreatePDF {
    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        TestDataFactory.createCasesWithoutCities();
    }

    @IsTest
    public static void checkCase() {
        List<Case> cases = [SELECT id, AccountId FROM Case];
        List<Account> accounts = [SELECT id FROM Account];

        FlowCreatePDF.FlowInput input = new FlowCreatePDF.FlowInput();
        input.theCase = cases[0];
        input.structureName = 'structure';
        input.newAccountId = accounts[0].Id;
        input.urpProtocol = 'urp';
        input.caseType = 'call';
        input.caseOrigin = 'call';
        input.caseSubject = 'Test';
        input.numberAddress = 12;
        input.streetAddress = 'Via Roma';
        input.letterAddress = 'A';

        Test.startTest();
        FlowCreatePDF.checkCase(new List<FlowCreatePDF.FlowInput>{input});
        Test.stopTest();

    }
}