/**
 * Created by snekkanti002 on 19/05/2022.
 */

@IsTest
public with sharing class TestBatchBonificaConsensi {
    @TestSetup
    public static void setup() {
        TestDataFactory.createAccounts();
        TestDataFactory.createConsentsBatchSetting();
    }

    @IsTest
    public static void batchBonificaConsensi() {

        Test.startTest();
        BatchBonificaConsensi batch = new BatchBonificaConsensi();
        Database.executeBatch(batch, 200);

        System.schedule('TestBatchBonificaConsensi', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}