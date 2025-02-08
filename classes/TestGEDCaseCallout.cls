/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestGEDCaseCallout {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void gedCaseCallout() {
        List<String> caseIds = new List<String>();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();

        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGEDCase(caseIds));
        GEDCaseCallout.gedCaseCallout(cases);
        Test.stopTest();
    }
}