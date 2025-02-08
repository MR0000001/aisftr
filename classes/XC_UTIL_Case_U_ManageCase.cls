/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Case_U_ManageCase – Util class to manage Case
*/

public without sharing class XC_UTIL_Case_U_ManageCase {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Case');

    /**
    * @description method for update Case Parent Status: inProgress if all sons have the same Owner, else InPending  
    * @param tasks  - List<Task>
    * @param mapOld
    * @param mapNew
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @modify 30/04/2019 - Monica Cutillo - monica.cutillo@nttdata.com (fix)
    **/
    public static void manageCasePendingTask(List<Task> tasks,Map<Id,Task> mapOld, Map<Id,Task> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '################ manageCasePendingTask');
        List<String> fieldList = new List<String>{'Status','OwnerId'};
        List<Task> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '################ Status,OwnerId not changed');
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '################ Task input to isParentCasePendingTask ---> listChanged=' + listChanged);
        isParentCasePendingTask(listChanged);
    }

    /**
    * @description Manage Case Pending from Related Case
    * @param cases - List<Case>
    * @param mapOld
    * @param mapNew
    * @modify 30/04/2019 - Monica Cutillo - monica.cutillo@nttdata.com (fix)
    **/
    public static void manageCasePendingFromRelatedCase(List<Case> cases,Map<Id,Case> mapOld, Map<Id,Case> mapNew){
        List<String> fieldList = new List<String>{'Status','OwnerId'};
        List<Case> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<Case> casesToManage = new List<Case>();
        for(Case caso : listChanged){
            if(caso.Status.equals(Label.XC_CL_Case_Status007) || caso.Status.equals(Label.XC_CL_Case_Status008)){
                casesToManage.add(caso);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '################ Case input to isParentCasePendingCase ---> casesToManage=' + casesToManage);
        isParentCasePendingFromRelatedCase(casesToManage);
    }

    public static void manageCasePendingConf(List<NE__Order__c> listNew,Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '################ manageCasePendingConf');
        List<String> fieldList = new List<String>{'XC_Status__c','OwnerId'};
        List<NE__Order__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '################ XC_Status__c,OwnerId not changed');
            return;
        }
        isParentCasePendingConf(listChanged);
    }

    /**
    * @description Check if is Parent
    * @param tasks - List<NE__Order__c>
    **/
    public static void isParentCasePendingConf(List<NE__Order__c> listNew){
        Set<Id> caseIdsToPending = new Set<Id>();
        for(NE__Order__c newConf : listNew){
            if (newConf.XC_CaseId__c != null && newConf.XC_Status__c != null){
                if(newConf.XC_Status__c.equals(Label.XC_CL_Configuration_Closed) || newConf.XC_Status__c.equals(Label.XC_CL_Configuration_Cancelled)){
                    caseIdsToPending.add(newConf.XC_CaseId__c);
                }
            }
        }
        if(!caseIdsToPending.isEmpty()){
            XC_UTIL_Case_U_Check.updateParentCaseStatus(caseIdsToPending);
        }

    }


    public static void manageCasePendingOpp(List<Opportunity> listNew,Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '################ manageCasePendingOpp');
        List<String> fieldList = new List<String>{'StageName','OwnerId'};
        List<Opportunity> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '################ Status,OwnerId not changed');
            return;
        }
        isParentCasePendingOpp(listChanged);
    }

    /**
    * @description Check if is Parent
    * @param tasks - List<Opportunity>
    **/
    public static void isParentCasePendingOpp(List<Opportunity> listNew){
        Set<Id> caseIdsToPending = new Set<Id>();
        for(Opportunity opp : listNew){
            if (opp.XC_CaseId__c != null && opp.StageName != null){
                if(opp.StageName.equals(Label.XC_CL_Opportunity_ClosedLost ) || opp.StageName.equals(Label.XC_CL_Opportunity_ClosedWon) ){
                    caseIdsToPending.add(opp.XC_CaseId__c);
                }
            }
        }
        if(!caseIdsToPending.isEmpty()){
            XC_UTIL_Case_U_Check.updateParentCaseStatus(caseIdsToPending);
        }
    }

    /**
    * @description Check if is Parent
    * @param tasks - List<Task>
    **/
    public static void isParentCasePendingTask(List<Task> tasks){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in isParentCasePending Task');
        List<Task> tasksToManage = new List<Task>();
        for(Task t : tasks){
            if(t.Status.equals(XC_AT_Constants.TASK_STATUS_COMPLETED) || t.Status.equals(XC_AT_Constants.TASK_STATUS_REJECTED) || t.Status.equals(Label.XC_CL_Case_OnHold)){
                tasksToManage.add(t);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'tasksToManage = '+tasksToManage);
        if(tasksToManage.isEmpty()){
            return;
        }
        List<id> caseId = XC_UTIL_Sobject.getListFieldValues(tasksToManage, 'WhatId');
        XC_UTIL_Case_U_Check.isParentCasePending(new Set<id>(caseId));
    }

    /**
    * @description Check if is Parent
    * @param cases - List<Case>
    **/
    public static void isParentCasePendingFromRelatedCase(List<Case> cases){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in isParentCasePending FromRelatedCase');
        List<Case> notComplianCases = new List<Case>();
        for(Case caso: cases){
            if(!XC_UTIL_Case_U_Check.isComplianCase(caso)){
                notComplianCases.add(caso);
            }
        }
        if(notComplianCases.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ComplianCase >>> not update parent!!!');
            return;
        }

        List<Id> caseId = XC_UTIL_Sobject.getListFieldValues(notComplianCases, 'ParentId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ notComplianCases >>> '+notComplianCases);

        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Case_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_UTIL_Case_U_Check.updateParentCaseStatus( new Set<Id>(caseId) );
    }

}