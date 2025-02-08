/**
 * Created by snekkanti002 on 22/11/2022.
 */

@IsTest
public without sharing class TestHistoricalIAMService {

    @TestSetup
    public static void setup() {
        TestDataFactory.createHistoricalIAMs(5);
    }

    @IsTest
    public static void insertHistoricalIAMs() {
        Test.startTest();
        HistoricalIAMService.insertHistoricalIAMs(new List<Historical_IAM__c>{new Historical_IAM__c()}, false);
        Test.stopTest();
    }

    @IsTest
    public static void deleteHistoricalIAMs() {
        List<Historical_IAM__c> historicalIAMs = [SELECT Id FROM Historical_IAM__c];

        Test.startTest();
        HistoricalIAMService.deleteHistoricalIAMs(historicalIAMs, false);
        Test.stopTest();
    }
}