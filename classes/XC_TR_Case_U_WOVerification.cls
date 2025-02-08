/**
 * The Class XC_TR_Case_U_WOVerification.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 30/05/2019
 * @description XC_TR_Case_U_WOVerification
 */
public without sharing class XC_TR_Case_U_WOVerification {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CaseRepair');

    /**
     * @description Work order validation.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void workOrderValidation(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<Case> caseList = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Result__c'}, mapOld, mapNew); //XC_WorkOrderValidation__c
        if(caseList.isEmpty()){
            return;
        }
        List<String> caseSettingNames = new List<String>{Label.XC_CL_ValidationCase, Label.XC_CL_PartnerValidationCase};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ValidationCase)==null || caseSettingsMap.get(Label.XC_CL_PartnerValidationCase)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ValidationCase +' or '+Label.XC_CL_PartnerValidationCase);
            return;
        }
        
        // NON PIU VERO >> select only Validation Cases that change XC_WorkOrderValidation__c from NULL to KO <<
        // select only Validation Cases that change XC_Result__c from NULL to 'Validation KO'  
        XC_CM_Case_Type_Setting__mdt validationCaseSettings = caseSettingsMap.get(Label.XC_CL_ValidationCase);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Validation caseSettings='+validationCaseSettings);

        Map<String,List<Case>> caseDataMap = selectValidationCaseToProcess(caseList, mapOld, validationCaseSettings);
        
        //STEP 1 - Gestione partnerValidationCase-------
        XC_CM_Case_Type_Setting__mdt partnerValidationCaseSettings = caseSettingsMap.get(Label.XC_CL_PartnerValidationCase);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Partner Validation caseSettings='+partnerValidationCaseSettings);
        precessPartnerValidationCases(caseDataMap.get('validationCasesKO'), partnerValidationCaseSettings, mapNew); //caseToProcess
        
        // select only Validation Cases that change XC_Result__c to 'Validation OK'  
        processValidationCaseOKToClose(caseList, validationCaseSettings);
        //------------------

        //STEP 2 - Gestione aggionamento WO
        updateWoValidationStatus(caseDataMap.get('allValidationCases'));
        //------------------
    }

    /**
     * @description reset Case Validation Parent.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void checkForValidationCaseKOClosure(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        List<Case> caseList = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Result__c'}, mapOld, mapNew);
        if(caseList.isEmpty()){
            return;
        }
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ValidationCase});
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_ValidationCase)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName='+Label.XC_CL_ValidationCase);
            return;
        }
        
        XC_CM_Case_Type_Setting__mdt validationCaseSettings = caseSettingsMap.get(Label.XC_CL_ValidationCase);
        Map<String,List<Case>> caseDataMap = selectValidationCaseToProcess(caseList, mapOld, validationCaseSettings);

        List<Case> caseData = getPartnerValidationCasesCreationData(caseDataMap.get('validationCasesKO'));
        for(Case caso: caseData){
            if(caso.XC_WorkOrder__r.XC_ExtraKm__c || caso.XC_WorkOrder__r.XC_ExtraWork__c){
                (mapNew.get(caso.Id)).Status = Label.XC_CL_Case_Status007;
                if((mapNew.get(caso.Id)).XC_Result__c == 'RS016'){
                    (mapNew.get(caso.Id)).XC_Resolution__c = 'R018';
                    (mapNew.get(caso.Id)).CaseRemarks__c = Label.XC_CL_CaseRemarks_ValidationCaseGenericClosure;
                }
            }
        }
    }

    /**
     * @description reset Case Validation Parent.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void resetCaseValidationParent(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START XC_TR_Case_U_CaseRepair resetCaseValidationParent');
        List<String> fieldList = new List<String>{'Status'};
        List<Case> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<Case> caseToProcess = new List<Case>();
        if(listChanged.isEmpty()){
            return;
        }
        for(Case caso : listChanged){
            if(caso.Status == Label.XC_CL_Case_Status007){
                caseToProcess.add(caso);
            }
        }
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PartnerValidationCase});
        if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_PartnerValidationCase)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName = '+Label.XC_CL_PartnerValidationCase);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ reset Case Validation Parent NOT processed!');
            return;
        }
        
        //select only Partner Validation Cases
        XC_CM_Case_Type_Setting__mdt partnerValidationCaseSettings = caseSettingsMap.get(Label.XC_CL_PartnerValidationCase);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Partner Validation caseSettings='+partnerValidationCaseSettings);
        List<Case> partnerValidCases = selectPartnerValidationCaseToProcess(caseToProcess, partnerValidationCaseSettings);

        List<Case> parentCasesToReset = retriveParentValidationCase(partnerValidCases);
        for(Case caso : parentCasesToReset){
            //caso.XC_WorkOrderValidation__c = null;
            caso.XC_Result__c = null;
            caso.XC_KO_Reasons__c = null;
            caso.XC_Resolution__c = null; //''
            caso.Status = Label.XC_CL_Case_Open;
        }

        List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_DML.updateRecords(parentCasesToReset);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@@@@ resetCaseValidationParent dmlResult = '+dmlResult);
        
        //update WO Status //ESCEP-2258 MC 20191121 
        updateWOInPendingValidation(partnerValidCases);
        
        XC_UTIL_Sobject.runAssignmentRules(parentCasesToReset, 'Case');
        //updateCasesParent(parentCasesToReset);
    }

    /**
     * @description updateWOInPendingValidation
     * @param partnerCasesClosed
     */
    private static void updateWOInPendingValidation(List<Case> partnerCasesClosed){
        List<WorkOrder> woToUpd = new List<WorkOrder>();
        WorkOrder wo;
        for(Case caso: partnerCasesClosed){
            wo = new WorkOrder();
            wo.Id= caso.XC_WorkOrder__c;
            wo.XC_ValidationStatus__c = Label.XC_CL_WO_PendingValidation;
            woToUpd.add(wo);
        }
        List<XC_UTIL_Sobject.WrapperResult> woDmlRW = XC_UTIL_DML.updateRecords(woToUpd);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@@@@ updateWOInPendingValidation woDmlRW = '+woDmlRW);
    }
    
     /**
     * @description updateWoValidationStatus with the same case XC_WorkOrderValidation__c value .
     * @param listNew the list new
     */
     private static void updateWoValidationStatus(List<Case> listNew){
        if(listNew.isEmpty()){
            return;
        }
        List<WorkOrder> wolist = new List<WorkOrder>();
        Set<Id> woKoIds = new Set<Id>();
        WorkOrder wo;
        for(Case caso : listNew){
            if('RS015' == caso.XC_Result__c){ // OK
                wo = new WorkOrder();
                wo.Id= caso.XC_WorkOrder__c;
                wo.XC_ValidationStatus__c = Label.XC_CL_OkValue;
                wo.XC_ValidationReason__c = '';
                wolist.add(wo);
            } else if('RS016' == caso.XC_Result__c) { //KO
                woKoIds.add(caso.XC_WorkOrder__c);
                /*wo.XC_ValidationStatus__c = Label.XC_CL_KoValue;
                wo.XC_ValidationReason__c = Label.XC_CL_ValidationReasonGenericKO;
                wo.XC_ValidationCounter__c = wo.XC_ValidationCounter__c + 1;*/
            }
        }

        List<WorkOrder> woKO = retrieveWOWithValidationKO(woKoIds);
        wolist.addAll(woKO);
        List<XC_UTIL_Sobject.WrapperResult> woDmlRW = XC_UTIL_DML.upsertRecords(wolist);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@@@@ updateWoValidationStatus woDmlRW = '+woDmlRW);

        /*wo.XC_ValidationStatus__c = ('RS015' == caso.XC_Result__c) ? Label.XC_CL_OkValue 
                                                                    : Label.XC_CL_KoValue;
        wo.XC_ValidationReason__c = (wo.XC_ValidationStatus__c == Label.XC_CL_KoValue) ? Label.XC_CL_ValidationReasonGenericKO 
                                                                                        : '';*/
        //wo.XC_ValidationStatus__c = caso.XC_WorkOrderValidation__c;
        /*if (wo.XC_ValidationStatus__c == Label.XC_CL_KoValue){
            wo.XC_ValidationReason__c = Label.XC_CL_ValidationReasonGenericKO;
        }else{
            wo.XC_ValidationReason__c ='';
        }*/
     }

    /**
     * @description retrieveWOWithValidationKO
     * @param woIds wo ids
     * @return list of populated WO
     */
    private static List<WorkOrder> retrieveWOWithValidationKO(Set<Id> woIds){
        Map<Id,WorkOrder> woData = new Map<Id,WorkOrder>([
            SELECT Id, XC_ValidationCounter__c
              FROM WorkOrder
             WHERE Id IN: woIds
        ]);

        List<WorkOrder> result = new List<WorkOrder>();
        for(WorkOrder wo : woData.values()){
            wo.XC_ValidationStatus__c = Label.XC_CL_KoValue;
            wo.XC_ValidationReason__c = Label.XC_CL_ValidationReasonGenericKO;
            wo.XC_ValidationCounter__c = wo.XC_ValidationCounter__c + 1;
            result.add(wo);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrieveWOWithValidationKO result = '+result);
        return result;
    }
      

     /**
     * @description updateCasesParent and run Case assignment rule
     * @param cases to update
     */
    /*private static void updateCasesParent(List<Case> cases){
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        Case newCase = new Case(Status = 'New') ;
        
        //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);
        update newCase ;
    }*/

    /**
     * @description retriveParentValidationCase
     * @param partnerValidCases the cases child
     * @return List<Case> Validation Case
     */
    private static List<Case> retriveParentValidationCase(List<Case> partnerValidCases){
        List<String> listParentIds = XC_UTIL_Sobject.getListFieldValues(partnerValidCases, 'ParentId');
        Map<Id,Case> mapParentCases = new Map<Id,Case>([SELECT id, Status, XC_WorkOrderValidation__c, Origin, AccountId, ContactId, OwnerId FROM Case WHERE Id IN: listParentIds]);
        return mapParentCases.values();
    }

    /**
     * @description retriveParentValidationCase
     * @param validCases the cases child
     * @return List<Case> Validation Case
     */
    private static List<Case> retriveValidationCaseData(List<Case> validCases){
        List<String> listParentIds = XC_UTIL_Sobject.getIds(validCases);
        Map<Id,Case> mapParentCases = new Map<Id,Case>([
            SELECT id, Status, XC_WorkOrderValidation__c, XC_Result__c, XC_KO_Reasons__c, XC_Case_Comments__c, Origin, AccountId, ContactId, XC_WorkOrder__c, OwnerId 
              FROM Case 
             WHERE Id IN: listParentIds]);
        return mapParentCases.values();
    }

    /**
     * @description selectValidationCaseToProcess
     * @param caseList the cases to check
     * @param mapOld the cases mapOld
     * @param validationCaseSettings the XC_CM_Case_Type_Setting__mdt row
     * @return selected List Case
     */
    private static Map<String,List<Case>> selectValidationCaseToProcess(List<Case> caseList, Map<Id, Case> mapOld, XC_CM_Case_Type_Setting__mdt validationCaseSettings){
        Map<String,List<Case>> caseDataMap = new Map<String,List<Case>>();
        List<Case> caseValidationKO = new List<Case>();
        List<Case> allCaseValidation = new List<Case>();
        Case oldCase;
        for(Case caso : caseList){
            if(XC_UTIL_Case.matchSettings(caso, validationCaseSettings) && caso.ParentId==null){
                allCaseValidation.add(caso);

                oldCase = mapOld.get(caso.Id);
                /*XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ oldCase.XC_WorkOrderValidation__c='+oldCase.XC_WorkOrderValidation__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caso.XC_WorkOrderValidation__c='+caso.XC_WorkOrderValidation__c);
                if(oldCase.XC_WorkOrderValidation__c == null && caso.XC_WorkOrderValidation__c == Label.XC_CL_KoValue){ */
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ oldCase.XC_Result__c=' + oldCase.XC_Result__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ caso.XC_Result__c=' + caso.XC_Result__c);
                if(oldCase.XC_Result__c == null && caso.XC_Result__c == 'RS016'){ // Validation KO
                    caseValidationKO.add(caso);
                }
            }
        }

        caseDataMap.put('allValidationCases', allCaseValidation);
        caseDataMap.put('validationCasesKO', retriveValidationCaseData(caseValidationKO));
        return caseDataMap;
    }

    /**
     * @description selectPartnerValidationCaseToProcess
     * @param caseList the cases to check
     * @param partnerValidationCaseSettings the XC_CM_Case_Type_Setting__mdt row
     * @return selected List Case
     */
    private static List<Case> selectPartnerValidationCaseToProcess(List<Case> caseList, XC_CM_Case_Type_Setting__mdt partnerValidationCaseSettings){
        List<Case> caseToProcess = new List<Case>();
        Case oldCase;
        for(Case caso : caseList){
            if(XC_UTIL_Case.matchSettings(caso, partnerValidationCaseSettings) && caso.ParentId!=null){
                caseToProcess.add(caso);
            }
        }
        return caseToProcess;
    }

    /**
     * @description processValidationCaseOKToClose
     * @param caseList list of validation Cases parent 
     * @param validationCaseSettings used to find cases
     */
    private static void processValidationCaseOKToClose(List<Case> caseList, XC_CM_Case_Type_Setting__mdt validationCaseSettings){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START XC_TR_Case_U_CaseRepair processValidationCaseOKToClose');
        List<Case> caseToProcess = new List<Case>();
        for(Case caso : caseList){
            if(XC_UTIL_Case.matchSettings(caso, validationCaseSettings) && caso.ParentId==null){
                //if(caso.XC_WorkOrderValidation__c == Label.XC_CL_OkValue){
                if(caso.XC_Result__c == 'RS015'){ // Validation OK
                    //caso.Status = Label.XC_CL_Case_Status007;
                    caseToProcess.add(caso);
                }
            }
        }
        /*XC_UTIL_Debug.debug(DEBUGACTIVE, 'Task to Close for this Cases -> '+caseToProcess);
        if(!caseToProcess.isEmpty()){
            closePartnerValidationTask(caseToProcess);
        }*/
        if(caseToProcess.isEmpty()){
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Case to Close -> '+caseToProcess);
        List<Case> caseToClose = new List<Case>();
        Case caseObj;
        for(Case caso : caseToProcess){
            caseObj = new Case();
            caseObj.Id = caso.Id;
            caseObj.Status = Label.XC_CL_Case_Status007;
            caseToClose.add(caseObj);
        }
        List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_DML.updateRecords(caseToClose);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'processValidationCaseOKToClose result -> '+result);
    }

    /**
     * @description closePartnerValidationTask
     * @param caseList list of validation Cases
     */
    /*private static void closePartnerValidationTask(List<Case> caseList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START XC_TR_Case_U_CaseRepair closePartnerValidationTask');
        List<Task> taskToClose = retrieveTasksToClose(caseList);
        for(Task t : taskToClose){
            t.Status = Label.XC_CL_Task_Completed;
        }
        List<XC_UTIL_Sobject.WrapperResult> result = XC_UTIL_DML.updateRecords(taskToClose);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'closePartnerValidationTask result -> '+result);
    }*/

    /**
     * @description retrieveTasksToClose
     * @param cases list of validation Cases parent 
     * @return List<Task> Case Id with Task
     */
    /*private static List<Task> retrieveTasksToClose(List<Case> cases){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START retrieveTasksToClose');
        List<Id> result = new List<Id>();
        List<Id> ids = XC_UTIL_Sobject.getIds(cases);
        Map<Id,Task> tasks = new Map<Id,Task>([SELECT Id, WhatId FROM Task WHERE WhatId IN: ids AND Status =: Label.XC_CL_Task_New ]);
        return tasks.values();
    }*/
    
    /**
     * @description precessPartnerValidationCases
     * @param validationCases list of validation Cases parent 
     * @param partnerValidationCaseSettings used tu create new cases
     * @param mapNew to add error if needs
     */
    private static void precessPartnerValidationCases(List<Case> validationCases, XC_CM_Case_Type_Setting__mdt partnerValidationCaseSettings, Map<Id, Case> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START XC_TR_Case_U_CaseRepair precessPartnerValidationCases');
        List<Case> caseData = getPartnerValidationCasesCreationData(validationCases);
        //remove validation cases from WO Validation Extra
        List<Case> parentCasesForCreation = new List<Case>();
        for(Case caso: caseData){
            if(!caso.XC_WorkOrder__r.XC_ExtraKm__c && !caso.XC_WorkOrder__r.XC_ExtraWork__c){
                parentCasesForCreation.add(caso);
            }
        }
        if(!parentCasesForCreation.isEmpty()){
            partnerValidationCaseCreation(parentCasesForCreation, partnerValidationCaseSettings, mapNew);
        }
    }

    /**
     * @description partnerValidationCaseCreation
     * @param parentCasesForCreation list of validation Cases parent 
     * @param partnerValidationCaseSettings used tu create new cases
     * @param mapNew to add error if needs
     */
    private static void partnerValidationCaseCreation(List<Case> parentCasesForCreation, XC_CM_Case_Type_Setting__mdt partnerValidationCaseSettings, Map<Id, Case> mapNew){
        List<Case> newChildCases = new List<Case>();
        Case newCase;
        Map<Id,String> ownerMap = retrievePartnerValidationCasesOwner(parentCasesForCreation);
        for(Case parentCase : parentCasesForCreation){
            if(ownerMap.get(parentCase.Id) == null){
                (mapNew.get(parentCase.Id)).addError(Label.XC_CL_WOAssignResNullOrInactive);
            }
            newCase = XC_UTIL_Case.initCaseFromCaseSettings(partnerValidationCaseSettings);
            newCase.ParentId = parentCase.Id;
            newCase.AccountId = parentCase.AccountId;
            newCase.ContactId = parentCase.ContactId;
            newCase.XC_WorkOrder__c = parentCase.XC_WorkOrder__c;
            newCase.OwnerId = ownerMap.get(parentCase.Id);
            newCase.XC_Result__c = parentCase.XC_Result__c;
            newCase.XC_KO_Reasons__c = parentCase.XC_KO_Reasons__c;
            newCase.XC_Case_Comments__c = parentCase.XC_Case_Comments__c;
            newChildCases.add(newCase);

            /*if(!caseWithTask.contains(parentCase.Id)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Task to create');
                taskW = new XC_UTIL_Task.TaskWrapper();
                taskW.subject = Label.XC_CL_Task_PartnerValidationSubject;
                taskW.whatId = parentCase.Id;
                //taskW.caseId = parentCase.Id;
                taskW.ownerId = ownerMap.get(parentCase.Id);
                task = XC_UTIL_Task.getNewTask(taskW);
                newTasks.add(task);
            }*/
        }

        List<XC_UTIL_Sobject.WrapperResult>  insertCasesRW = XC_UTIL_DML.insertRecords(newChildCases);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@@@@ insertCasesRW = '+insertCasesRW);
    }

    /**
     * @description checkExistingTask
     * @param validationCases list of validation Cases parent 
     * @return List<Id> Case Id with Task
     */
    /*private static List<Id> checkExistingTask(List<Case> validationCases){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START checkExistingTask');
        List<Id> result = new List<Id>();
        List<Id> ids = XC_UTIL_Sobject.getIds(validationCases);
        Map<Id,Task> tasks = new Map<Id,Task>([SELECT Id, WhatId FROM Task WHERE WhatId IN: ids AND Status =: Label.XC_CL_Task_New ]);
        for(Task t : tasks.values()){
            result.add(t.WhatId);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkExistingTask - result='+result);
        return result;
    }*/

    /**
     * @description getPartnerValidationCasesCreationData
     * @param validationCases list of validation Cases parent 
     * @return List<Case> with data
     */
    private static List<Case> getPartnerValidationCasesCreationData(List<Case> validationCases){
        Set<Id> caseIds = XC_UTIL_Sobject.getSetIds(validationCases);
        Map<Id,Case> caseMap = new Map<Id,Case>([ 
            SELECT Id, XC_WorkOrder__r.Id, XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r.XC_ESP_Account_PrimaryContact__c,
                   XC_WorkOrder__r.XC_ExtraKm__c, XC_WorkOrder__r.XC_ExtraWork__c, AccountId, ContactId, XC_Result__c, XC_KO_Reasons__c, XC_Case_Comments__c
              FROM Case 
             WHERE Id IN: caseIds 
        ]);
        return caseMap.values();
    }

    /**
     * @description retrievePartnerValidationCasesOwner
     * (l'utente relativo al contatto primario dell'account partner 
     * dell'assignedResource del Work Order)
     * @param validationCases list of validation Cases parent for partner cases creation
     * @return Map<Id,String> that match Id Case with Partner Contact User Id
     */
    private static Map<Id,String> retrievePartnerValidationCasesOwner(List<Case> validationCases){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrievePartnerValidationCasesOwner.... ');
        Map<Id,String> result = new Map<Id,String>();
        /*Set<Id> caseIds = XC_UTIL_Sobject.getSetIds(validationCases);
        Map<Id,Case> caseMap = new Map<Id,Case>([ SELECT Id, XC_WorkOrder__r.Id, XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r.XC_ESP_Account_PrimaryContact__c FROM Case WHERE Id IN: caseIds ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseMap = '+caseMap);*/
        
        //cerco gli id dei primary contact dell'account partner che ha chiuso il WO
        Set<Id> primaryContactIds = new Set<Id>();
        for(Case caso : validationCases){ //caseMap.values()
            primaryContactIds.add(caso.XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r.XC_ESP_Account_PrimaryContact__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'primaryContactIds = '+primaryContactIds);

        Map<Id,User> userMap = new Map<Id,User>([ 
            SELECT Id, ContactId FROM User WHERE ContactId IN: primaryContactIds AND IsActive = true
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'userMap = '+userMap);
        
        //costruisco la mappa contactId -> userId 
        Map<Id,Id> contactMap = new Map<Id,Id>();
        for(User user: userMap.values()){
            contactMap.put(user.ContactId, user.Id);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'contactMap = '+contactMap);

        for(Case caso : validationCases){ //caseMap.values()
            if( caso.XC_WorkOrder__r==null || caso.XC_WorkOrder__r.XC_AssignedResource__r==null || caso.XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r==null ||
                caso.XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r.XC_ESP_Account_PrimaryContact__c==null){
                continue;
            }
            result.put(caso.Id, contactMap.get(caso.XC_WorkOrder__r.XC_AssignedResource__r.XC_Account__r.XC_ESP_Account_PrimaryContact__c));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ retrievePartnerValidationCasesOwner result = '+result);
        return result; 
    }
}