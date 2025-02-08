/**
 * Created by SNEKKANTI00 on 28/04/2021.
 */

@isTest
public with sharing class TestCTIUtility {

    @isTest
    public static void getMysterySettings() {
        Test.startTest();
        CTIUtility.getMysterySettings();
        Test.stopTest();
    }
}