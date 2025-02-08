/**
 * @description XC_TR_Task_U_DefaultSettings – Class that applay default settings on taskd before creation
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 30/07/2019
 * @date Modification  
 */
public without sharing class XC_TR_Task_U_DefaultSettings {
	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Task_Handler');

    /**
     * @description data wrapper class
     */
   private class DefaultSettingsTaskWrapper{
        Set<Id> parentCaseIds = new Set<Id>();
        Set<Id> parentWOIds = new Set<Id>();
        Set<Id> parentLeadIds = new Set<Id>();
        
        Map<String,String> rtCaseTaskMapping = new Map<String,String>();
        Map<String,String> rtLETaskMapping = new Map<String,String>();

        Map<Id,WorkOrder> woData = new Map<Id,WorkOrder>();
        Map<Id,Case> caseData = new Map<Id,Case>();
        Map<Id,Lead> leadData = new Map<Id,Lead>();
        Map<Id,Id> woCaseMapping = new Map<Id,Id>();
    }
    
    /**
     * @param listNew the list new
     * @description set tasks record type
     */
    public static void setTaskRecordType(List<Task> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START setTaskRecordType');
        DefaultSettingsTaskWrapper dsWrapper = populateParentIdsLists(listNew);

        if(!dsWrapper.parentWOIds.isEmpty()){
            dsWrapper.woData = retrieveWOData(dsWrapper.parentWOIds);
            for(WorkOrder wo: dsWrapper.woData.values()){
                dsWrapper.woCaseMapping.put(wo.Id, wo.CaseId);
            }
            //aggiungo i parent case dei wo alla lista dei parent case dei task x recuperare tutte le info insieme
            dsWrapper.parentCaseIds.addAll(dsWrapper.woCaseMapping.values());
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ dsWrapper.parentCaseIds after wo analisys = '+dsWrapper.parentCaseIds);
        //mapping tra RT Case -> RT Task
        if(!dsWrapper.parentCaseIds.isEmpty()){
            dsWrapper.caseData = retrieveCaseData(dsWrapper.parentCaseIds);
            dsWrapper.rtCaseTaskMapping = XC_UTIL_Task.getTaskRecordTypeByParentCase(dsWrapper.caseData.values());
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ dsWrapper.rtCaseTaskMapping = '+dsWrapper.rtCaseTaskMapping);
        //mapping tra LE dei Lead -> RT Task
        if(!dsWrapper.parentLeadIds.isEmpty()){
            dsWrapper.leadData = retrieveLeadData(dsWrapper.parentLeadIds);
            List<String> leList = XC_UTIL_Sobject.getListFieldValues(dsWrapper.leadData.values(), 'XC_ListOfLegalEntity__c');
            List<String> streamList = XC_UTIL_Sobject.getListFieldValues(dsWrapper.leadData.values(), 'XC_Segment__c');
            dsWrapper.rtLETaskMapping = XC_UTIL_Task.getTaskRecordTypeByLegalEntity(new Set<String>(leList), new Set<String>(streamList));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ dsWrapper.rtLETaskMapping = '+dsWrapper.rtLETaskMapping);

        taskRTSettins(listNew, dsWrapper);
    }

    /**
     * @param listNew the list new
     * @param dsWrapper data needed
     * @description set tasks record type
     */
    private static void taskRTSettins(List<Task> listNew, DefaultSettingsTaskWrapper dsWrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START taskRTSettins');
        Id caseId;
        Case caso;
        WorkOrder wo;
        Lead lead;
        String taskRTName;
        for(Task task : listNew){
            if(String.isBlank(String.valueOf(task.WhatId)) && String.isBlank(String.valueOf(task.WhoId))){
                continue;
            }
            if(String.isNotBlank(String.valueOf(task.WhatId)) && 'Case' == task.WhatId.getSObjectType().getDescribe().getName()){
                caso = dsWrapper.caseData.get(task.WhatId);
                if(caso!=null && dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId) != null){
                    /*taskRTName = dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId);
                    task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(taskRTName).getRecordTypeId();*/
                    task.RecordTypeId = dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId);
                }
            }else if(String.isNotBlank(String.valueOf(task.WhatId)) && 'WorkOrder' == task.WhatId.getSObjectType().getDescribe().getName()){
                wo = dsWrapper.woData.get(task.WhatId);
                caseId = dsWrapper.woCaseMapping.get(wo.Id);
                caso = dsWrapper.caseData.get(caseId);
                if(caso!=null && dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId) != null){
                    /*taskRTName = dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId);
                    task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(taskRTName).getRecordTypeId();*/
                    task.RecordTypeId = dsWrapper.rtCaseTaskMapping.get(caso.RecordTypeId);
                }
            }else if(String.isNotBlank(String.valueOf(task.WhoId)) && 'Lead' == task.WhoId.getSObjectType().getDescribe().getName()){
                lead = dsWrapper.leadData.get(task.WhoId);
                if(lead!=null && dsWrapper.rtLETaskMapping.get(lead.XC_ListOfLegalEntity__c+lead.XC_Segment__c) != null){
                    /*taskRTName = dsWrapper.rtLETaskMapping.get(lead.XC_ListOfLegalEntity__c);
                    task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(taskRTName).getRecordTypeId();*/
                    task.RecordTypeId = dsWrapper.rtLETaskMapping.get(lead.XC_ListOfLegalEntity__c+lead.XC_Segment__c);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ task.WhoId = '+task.WhoId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ task.WhatId = '+task.WhatId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ task.RecordTypeId = '+task.RecordTypeId);
        }
    }

    /**
     * @description populateParentIdsLists
     * @param listNew task list
     * @return the result wrapper
     **/
    private static DefaultSettingsTaskWrapper populateParentIdsLists(List<Task> listNew){
        DefaultSettingsTaskWrapper result = new DefaultSettingsTaskWrapper();
        for(Task task : listNew){
            if(String.isBlank(String.valueOf(task.WhatId)) && String.isBlank(String.valueOf(task.WhoId))){
                continue;
            }
            if(String.isNotBlank(String.valueOf(task.WhatId)) && 'Case' == task.WhatId.getSObjectType().getDescribe().getName()){
                result.parentCaseIds.add(task.WhatId);
            }else if(String.isNotBlank(String.valueOf(task.WhatId)) && 'WorkOrder' == task.WhatId.getSObjectType().getDescribe().getName()){
                result.parentWOIds.add(task.WhatId);
            }else if(String.isNotBlank(String.valueOf(task.WhoId)) && 'Lead' == task.WhoId.getSObjectType().getDescribe().getName()){
                result.parentLeadIds.add(task.WhoId);
            }
            /*else{
                task.addError(Label.XC_CL_Task_CannotMapRecordType);
            }*/
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ populateParentIdsLists result = '+result);
        return result;
    }

    /**
     * @description retrieveWOData
     * @param parentWOIds WO Ids
     * @return Map<Id,WorkOrder> retrieved data
     **/
    private static Map<Id,WorkOrder> retrieveWOData(Set<Id> parentWOIds){
        return new Map<Id,WorkOrder>([SELECT Id, CaseId FROM WorkOrder WHERE Id IN: parentWOIds]);
    }

    /**
     * @description retrieveCaseData
     * @param parentCaseIds Case Ids
     * @return Map<Id,Case> retrieved data
     **/
    private static Map<Id,Case> retrieveCaseData(Set<Id> parentCaseIds){
        return new Map<Id,Case>([SELECT Id, RecordTypeId FROM Case WHERE Id IN: parentCaseIds]);
    }

    /**
     * @description retrieveLeadData
     * @param parentLeadIds Lead Ids
     * @return Map<Id,Lead> retrieved data
     **/
    private static Map<Id,Lead> retrieveLeadData(Set<Id> parentLeadIds){
        return new Map<Id,Lead>([SELECT Id, RecordTypeId, XC_ListOfLegalEntity__c, XC_Segment__c FROM Lead WHERE Id IN: parentLeadIds]);
    }
}