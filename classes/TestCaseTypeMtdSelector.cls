/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestCaseTypeMtdSelector {
    @isTest
    public static void caseTypeMtdSelectoTest() {
        Test.startTest();
        CaseTypeMtdSelector.getCaseTypesByRTDeveloperName('');
        Test.stopTest();
    }
}