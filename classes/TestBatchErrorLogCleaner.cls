/**
 * Created by snekkanti002 on 16/03/2022.
 */

@IsTest
public without sharing class TestBatchErrorLogCleaner {

    @TestSetup
    public static void setup() {
        TestDataFactory.createErrorLogs(5);
    }

    @IsTest
    public static void batchErrorLogCleaner() {
        TestDataFactory.createLogCleanerSetting();

        Test.startTest();
        BatchErrorLogCleaner batch = new BatchErrorLogCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchErrorLogCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }

    @IsTest
    public static void batchErrorLogCleanerException() {
        Test.startTest();
        BatchErrorLogCleaner batch = new BatchErrorLogCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchErrorLogCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}