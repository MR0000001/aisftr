/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */
@isTest
public with sharing class TestCaseExtension {
    @isTest
    public static void caseExtensionTest() {
        Test.startTest();
        CaseExtension c = new CaseExtension(new ApexPages.StandardController(new Case()));
        Test.stopTest();
    }
}