/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

public without sharing class UpdateTaskFromCTIService {

    @InvocableMethod
    public static void futureUpdateObjectFromUpdateTaskFromCTIService(List<String> taskId) {
        system.debug('taskId -> '+ taskId);
        updateMe(taskId[0]);
    }

    @future
    private static void updateMe(String taskId) {
        Task[] tasks = [SELECT Id, WhatId, Status, UpdateStatusAutomatic__c FROM Task WHERE Id=: taskId];
        system.debug('tasks -> ' + tasks);
        if ( tasks.size() == 1 ) {
            tasks[0].Status = 'Completed';
            tasks[0].UpdateStatusAutomatic__c = true;

            Database.SaveResult[] result =  Database.update(tasks, false);
            system.debug('tasks -> '+ tasks);
            system.debug('result after update -> '+ result[0]);
//            if (!result[0].isSuccess()) {
//                Task_Lock__c taskToInsert = new Task_Lock__c();
//                taskToInsert.Name = result[0].getId();
//                insert taskToInsert;
//            }
        }
    }

}