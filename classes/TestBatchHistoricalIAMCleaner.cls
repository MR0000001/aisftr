/**
 * Created by snekkanti002 on 22/11/2022.
 */

@IsTest
public without sharing class TestBatchHistoricalIAMCleaner {
    @TestSetup
    public static void setup() {
        TestDataFactory.createHistoricalIAMs(5);
    }

    @IsTest
    public static void batchHistoricalIAMCleaner() {
        TestDataFactory.createLogCleanerSetting();

        Test.startTest();
        BatchHistoricalIAMCleaner batch = new BatchHistoricalIAMCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchHistoricalIAMCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }

    @IsTest
    public static void batchHistoricalIAMCleanerException() {
        Test.startTest();
        BatchHistoricalIAMCleaner batch = new BatchHistoricalIAMCleaner();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchHistoricalIAMCleaner', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}