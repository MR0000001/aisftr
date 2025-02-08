/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

public without sharing class WizardCreateRSService {

    @InvocableMethod
    public static void futureUpdateObjectFromWizardCreateRSService(List<Task> tasks) {
        system.debug('tasks -> '+ tasks);
        for ( Task singleTask: tasks)
        updateMe(singleTask.Id, singleTask.WhatId, singleTask.WhoId, singleTask.UpdateStatusAutomatic__c);
    }

    @future
    private static void updateMe(Id taskId, String valWhatId, String valWhoId, Boolean valUpdateStatusAutomatic) {

        Task taskToUpdate = [SELECT Id, WhatId, WhoId, UpdateStatusAutomatic__c FROM Task WHERE Id =: taskId];

        taskToUpdate.WhatId = valWhatId;
        taskToUpdate.UpdateStatusAutomatic__c = valUpdateStatusAutomatic;
        taskToUpdate.WhoId = valWhoId;
        system.debug('taskToUpdate -> '+ taskToUpdate);

        Database.SaveResult result =  Database.update(taskToUpdate, false);
        system.debug('result -> '+ result);
//        if (!result.isSuccess()) {
//            Task_Lock__c taskToInsert = new Task_Lock__c();
//            taskToInsert.Name = result.getId();
//            insert taskToInsert;
//        }

    }

}