/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */
@isTest
public with sharing class TestRTFieldMtdSelector {
    @isTest
    public static void rtFieldMtdSelectorTest() {
        Test.startTest();
        RTFieldMtdSelector.getCaseTypesByRTDeveloperName('');
        Test.stopTest();
    }

}