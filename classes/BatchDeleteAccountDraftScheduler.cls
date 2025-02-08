/**
 * Created by FMARCHEGIA00 on 09/02/2021.
 */

global with sharing class BatchDeleteAccountDraftScheduler implements Schedulable{

    private static FisicalDeleteBatch_Setting__c setting = FisicalDeleteBatch_Setting__c.getValues('BatchDeleteAccountDraft');

    global static void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchDeleteAccountDraft(), Integer.valueOf(setting.Batch_Size__c));
    }
}