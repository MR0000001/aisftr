/**
 * Created by FMARCHEGIA00 on 09/02/2021.
 */

@IsTest
private class BatchDeleteAccountDraftSchedulerTest {

    @TestSetup static void setup() {
        FisicalDeleteBatch_Setting__c BatchDeleteAccountDraft = new FisicalDeleteBatch_Setting__c();
        BatchDeleteAccountDraft.Name = 'BatchDeleteAccountDraft';
        BatchDeleteAccountDraft.Batch_Size__c = 200;
        insert BatchDeleteAccountDraft;
    }

    @IsTest static void testClass() {
        Test.startTest();
        System.schedule('BatchDeleteAccountDraftSchedulerTest', '0 17 * ? * * *', new BatchDeleteAccountDraftScheduler());
        Test.stopTest();
    }

}