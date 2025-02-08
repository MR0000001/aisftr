/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 16/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SafetyPointWalletHistory_TEST – Test class for XC_UTIL_SafetyPointWalletHistory class
 */
@IsTest
private without sharing class XC_UTIL_SafetyPointWalletHistory_TEST {
    
    @TestSetup
    private static void testSetup() {
        Account account1 = new Account();
        account1.Name = 'Account Test 1';
        account1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        account1.XC_SafetyPointsLicenseEnabled__c = true;
        account1.Country__c = 'Italy';
        insert account1;

        List<XC_Safety_Point_Wallet_History__c> histories = new List<XC_Safety_Point_Wallet_History__c>();
        XC_Safety_Point_Wallet_History__c history1 = new XC_Safety_Point_Wallet_History__c();
        history1.XC_Account__c = account1.Id;
        history1.RecordTypeId = Schema.SObjectType.XC_Safety_Point_Wallet_History__c.getRecordTypeInfosByDeveloperName().get('XC_SPW_History_License_Changes').getRecordTypeId();
        history1.XC_Previous_SafetyPointLicense_Suspended__c = false;
        history1.XC_Actual_Safety_Point_License_Suspended__c = true;
        histories.add(history1);

        XC_Safety_Point_Wallet_History__c history2 = new XC_Safety_Point_Wallet_History__c();
        history2.XC_Account__c = account1.Id;
        history2.RecordTypeId = Schema.SObjectType.XC_Safety_Point_Wallet_History__c.getRecordTypeInfosByDeveloperName().get('XC_SPW_History_License_Changes').getRecordTypeId();
        history2.XC_Previous_SafetyPointLicense_Suspended__c = true;
        history2.XC_Actual_Safety_Point_License_Suspended__c = false;
        histories.add(history2);

        XC_Safety_Point_Wallet_History__c history3 = new XC_Safety_Point_Wallet_History__c();
        history3.XC_Account__c = account1.Id;
        history3.RecordTypeId = Schema.SObjectType.XC_Safety_Point_Wallet_History__c.getRecordTypeInfosByDeveloperName().get('XC_SPW_History_License_Changes').getRecordTypeId();
        history3.XC_Previous_SafetyPointLicense_Suspended__c = false;
        history3.XC_Actual_Safety_Point_License_Suspended__c = true;
        histories.add(history3);

        insert histories;
    }

    @IsTest
    private static void getSuspensionRangesTest() {
        Account a = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        XC_UTIL_SafetyPointWalletHistory.DateRanges dateRanges = XC_UTIL_SafetyPointWalletHistory.getSuspensionRanges(a.Id);
        Test.stopTest();

        System.assertEquals(2, dateRanges.values().size(), 'Suspension date ranges computed are wrong');
    }

    @IsTest
    private static void isInsideRangeTest() {
        List<XC_UTIL_SafetyPointWalletHistory.DateRange> dateRangesList = new List<XC_UTIL_SafetyPointWalletHistory.DateRange>();
        dateRangesList.add(new XC_UTIL_SafetyPointWalletHistory.DateRange(System.now().addDays(-10), System.now().addDays(-5)));
        dateRangesList.add(new XC_UTIL_SafetyPointWalletHistory.DateRange(System.now().addDays(-1), System.now()));
        XC_UTIL_SafetyPointWalletHistory.DateRanges dateRanges = new XC_UTIL_SafetyPointWalletHistory.DateRanges(dateRangesList);

        Test.startTest();
        Boolean insideRange = dateRanges.isInsideRange(System.now().addDays(-8));
        Boolean outsideRange = dateRanges.isInsideRange(System.now().addDays(-3));
        Test.stopTest();

        System.assertEquals(true, insideRange, 'Failed on datetime inside the range defined');
        System.assertEquals(false, outsideRange, 'Failed on datetime outside the range defined');
    }
}