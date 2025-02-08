/**
* @author Monica Cutillo - monica.cutillo@nttdata.com 
* @date Creation 29/05/2019
* @date Modification 
* @description XC_UTIL_Task – Task UTIL Class
*/ 
public without sharing class XC_UTIL_Task {
    
    /**
     * @description Class Wrapper to create new Task
     */
    public class TaskWrapper{
        public String subject;
        public String caseId;
        public String whatId;
        public String ownerId;
    }

    /**
    * @description Get Task Record Type from Case Record Type
    * @param listNew List<Case>
    * @return Map<String,String> Case RT Id -> Task RT Id
    **/
    public static Map<String,String> getTaskRecordTypeByParentCase(List<Case> listNew){
        Map<String,String> result = new Map<String,String>();
        List<String> caseRT = XC_UTIL_Sobject.getListFieldValues(listNew, 'RecordTypeId');
        Set<String> caseRTSet  = new Set<String>(caseRT);
        Map<Id,XC_CM_CaseReasonRtMapping__mdt> caseRTMappingMtd = new Map<Id,XC_CM_CaseReasonRtMapping__mdt>(
            [ SELECT id, XC_CaseRecordType__c, XC_TaskRecordType__c 
                FROM XC_CM_CaseReasonRtMapping__mdt 
               WHERE XC_CaseRecordType__c IN: caseRTSet]);
        
        for(XC_CM_CaseReasonRtMapping__mdt cr : caseRTMappingMtd.values() ){
            String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(cr.XC_CaseRecordType__c).getRecordTypeId();
            String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(cr.XC_TaskRecordType__c).getRecordTypeId();
            result.put(caseRecordTypeId, taskRecordTypeId);
        }
        return result;
    } 

    /**
    * @description Get Task Record Type from Legal Entity
    * @param leList LE API names
    * @return Map<String,String> LE API Name -> Task RT Id
    **/
    public static Map<String,String> getTaskRecordTypeByLegalEntity(Set<String> leList, Set<String> streamList){
        Map<String,String> result = new Map<String,String>();
        Map<Id,XC_CM_CaseReasonRtMapping__mdt> caseRTMappingMtd = new Map<Id,XC_CM_CaseReasonRtMapping__mdt>(
            [ SELECT id, XC_LegalEntity__c, XC_TaskRecordType__c, XC_Stream__c 
                FROM XC_CM_CaseReasonRtMapping__mdt 
               WHERE XC_LegalEntity__c IN: leList AND XC_Stream__c IN :streamList]);
        
        for(XC_CM_CaseReasonRtMapping__mdt cr : caseRTMappingMtd.values() ){
            String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(cr.XC_TaskRecordType__c).getRecordTypeId();
            result.put(cr.XC_LegalEntity__c+cr.XC_Stream__c, taskRecordTypeId);
        }
        return result;
    } 
    
    /**
     * @description getNewTask
     * @param taskW the TaskWrapper
     * @return new task to insert
     **/
    public static Task getNewTask(TaskWrapper taskW){
        //String taskRT = XC_AT_Constants.TASK_RECORD_TYPE_XC_ATTENTION_ESPANA;
        Task task = new Task();
        task.WhatId = taskW.whatId;
        //task.RelatedCase__c = taskW.caseId;
        task.OwnerId = taskW.ownerId;
        task.Subject = taskW.subject;
        //task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(taskRT).getRecordTypeId();
        task.IsReminderSet = true;
        task.ReminderDateTime = System.now();
        task.ActivityDate = Date.today();
        return task;
    }
}