/**
 * Created by snekkanti002 on 16/03/2022.
 */

@IsTest
public without sharing class TestBatchCalloutLogCleaner {

    @TestSetup
    public static void setup() {
        TestDataFactory.createCalloutLoggers(5);
    }

    @IsTest
    public static void batchCalloutLogCleaner() {
        TestDataFactory.createLogCleanerSetting();

        Test.startTest();
        BatchCalloutLogCleaner batch = new BatchCalloutLogCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchCalloutLogCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }


    @IsTest
    public static void batchCalloutLogCleanerException() {
        Test.startTest();
        BatchCalloutLogCleaner batch = new BatchCalloutLogCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchCalloutLogCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}