/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

public with sharing class FlowCreateSRIService {

    @future
    public static void futureUpdateObjectFromFlowCreateSRI(String taskId, String serviceRequestId, String customSettingValueForTaskWhoId) {
        system.debug('taskId -> '+ taskId);
        system.debug('serviceRequestId -> '+ serviceRequestId);
        Task[] tasks = [SELECT Id, WhatId, Status, UpdateStatusAutomatic__c FROM Task WHERE Id=: taskId];
        system.debug('tasks -> ' + tasks);
        if ( tasks.size() == 1 ) {
            tasks[0].WhatId = serviceRequestId;
            tasks[0].Status = 'Completed';
            tasks[0].UpdateStatusAutomatic__c = true;
            tasks[0].WhoId = customSettingValueForTaskWhoId;

            Database.SaveResult[] result =  Database.update(tasks, false);
            system.debug('result after update -> '+ result[0]);
//            if (!result[0].isSuccess()) {
//                Task_Lock__c taskToInsert = new Task_Lock__c();
//                taskToInsert.Name = result[0].getId();
//                taskToInsert.WhatId__c = serviceRequestId;
//                taskToInsert.WhoId__c = customSettingValueForTaskWhoId;
//                insert taskToInsert;
//            }
        }

    }

}