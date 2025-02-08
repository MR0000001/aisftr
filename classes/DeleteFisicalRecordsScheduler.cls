/**
 * Created by LCONATO00 on 08/10/2020.
 */

global with sharing class DeleteFisicalRecordsScheduler implements Schedulable{
    global static void execute(SchedulableContext ctx) {
        FisicalDeleteBatch_Setting__c employeeFisicalDeleteBatchCustomSetting = FisicalDeleteBatch_Setting__c.getValues('EmployeeFisicalDeleteBatch');
        FisicalDeleteBatch_Setting__c roleFisicalDeleteBatchCustomSetting = FisicalDeleteBatch_Setting__c.getValues('RoleFisicalDeleteBatch');
        FisicalDeleteBatch_Setting__c structureFisicalDeleteBatchCustomSetting = FisicalDeleteBatch_Setting__c.getValues('StructureFisicalDeleteBatch');
                
        Database.executeBatch(new EmployeeFisicalDeleteBatch(), Integer.valueOf(employeeFisicalDeleteBatchCustomSetting.Batch_Size__c));
        Database.executeBatch(new RoleFisicalDeleteBatch(), Integer.valueOf(roleFisicalDeleteBatchCustomSetting.Batch_Size__c));
        Database.executeBatch(new StructureFisicalDeleteBatch(), Integer.valueOf(structureFisicalDeleteBatchCustomSetting.Batch_Size__c));
    }
}