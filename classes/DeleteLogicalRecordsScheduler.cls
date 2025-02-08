/**
 * Created by LCONATO00 on 07/05/2020.
 */

global without sharing class DeleteLogicalRecordsScheduler implements Schedulable{
    global static void execute(SchedulableContext ctx) {
        LogicalDeleteBatch_Setting__c employeeLogicalDeleteBatchCustomSetting = LogicalDeleteBatch_Setting__c.getValues('EmployeeLogicalDeleteBatch');
        LogicalDeleteBatch_Setting__c roleLogicalDeleteBatchCustomSetting = LogicalDeleteBatch_Setting__c.getValues('RoleLogicalDeleteBatch');
        LogicalDeleteBatch_Setting__c structureLogicalDeleteBatchCustomSetting = LogicalDeleteBatch_Setting__c.getValues('StructureLogicalDeleteBatch');
        
        Database.executeBatch(new RoleLogicalDeleteBatch(), Integer.valueOf(roleLogicalDeleteBatchCustomSetting.Batch_Size__c));
        Database.executeBatch(new StructureLogicalDeleteBatch(), Integer.valueOf(structureLogicalDeleteBatchCustomSetting.Batch_Size__c));
        Database.executeBatch(new EmployeeLogicalDeleteBatch(), Integer.valueOf(employeeLogicalDeleteBatchCustomSetting.Batch_Size__c));
    }

    global static List<String> executeEveryDay() {
        List<String> jobIds = new List<String>();
        jobIds.add(System.schedule('DeleteLogicalRecords', '0 00 05 * * ?', new DeleteLogicalRecordsScheduler()));
        return jobIds;
    }

}