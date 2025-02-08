@isTest(SeeAllData=false)
public with sharing class TA_LWCC265_CustomLookupTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'TestName';
        acc.Rating = 'Hot';
        acc.PrimaryEmail__c = 'test@test.it';
        insert acc;
    }

    
    @isTest
    public static void test_with_condition() {
        String objectName = 'Account';
        String objectIdentifier = 'Name';
        String filterField = 'Name';
        String searchString = 'Test';
        String value = '';
        String condition = 'Rating = \'Hot\'';
        String recordLimit = '10';

        Test.startTest();
        TA_LWCC265_CustomLookup.RecordsData recordData = new TA_LWCC265_CustomLookup.RecordsData('test', 'test');
        TA_LWCC265_CustomLookup.fetchRecords(objectName, objectIdentifier, filterField, searchString, value, condition, recordLimit);
        Test.stopTest();
    }

    @isTest
    public static void test_whithout_condition() {
        String objectName = 'Account';
        String objectIdentifier = 'Name';
        String filterField = 'Name';
        String searchString = 'Test';
        String value = '';
        String condition = '';
        String recordLimit = '10';

        Test.startTest();
        TA_LWCC265_CustomLookup.fetchRecords(objectName, objectIdentifier, filterField, searchString, value, condition, recordLimit);
        Test.stopTest();
    }

    @isTest
    public static void test_exception() {
        Test.startTest();
        try {
            TA_LWCC265_CustomLookup.fetchRecords(null, null, null, null, null, null, null);
        } catch(Exception e) {
            System.assert(e != null, e != null);
        }
        Test.stopTest();
    }
}