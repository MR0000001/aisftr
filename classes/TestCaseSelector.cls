/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestCaseSelector {

    @TestSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
    }

    @isTest
    public static void caseSelectorTest() {
        Case cs = new Case();
        List<String> caseIds = new List<String>();

        List<Case> cases = [SELECT id FROM Case];

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        CaseSelector.getCasesByCaseIds(caseIds);
        CaseSelector.getCasesForPDFById(caseIds);
        CaseSelector.getCaseById(cases[0].id);
        CaseSelector.updateCases(cases, true);
        cases.add(cs);
        CaseSelector.updateCases(cases, true);
        CaseSelector.deleteCases(cases, true);
        Test.stopTest();
    }
}