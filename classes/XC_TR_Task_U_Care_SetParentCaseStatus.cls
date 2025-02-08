/**
 * The Class XC_TR_Task_U_Care_SetParentCaseStatus.
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @description Class for update Case Parent Status: inProgress if all sons have the same Owner, else InPending
 */
public without sharing class XC_TR_Task_U_Care_SetParentCaseStatus {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Task_Handler');
    
    /**
     * Sets the parent case status.
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param taskList the new parent case status
     * @description Method for update Case Parent Status: inProgress if all sons have the same Owner, else InPending
     * @modify 22/03/2019 monica.cutillo@nttdata.com - add Subject check to change Case Status > On Hold
     */
    public static void setParentCaseStatus(List<Task> taskList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in setParentCaseStatus for task');
        Set<Case> caseParentdIsSet = new Set<Case>();
        List<String> listWhatIds = XC_UTIL_Sobject.getListFieldValues(taskList, 'WhatId');
        Map<Id,Case> mapParentCases = new Map<Id,Case>([SELECT id, Status,OwnerId FROM Case WHERE Id IN: listWhatIds]);
        for(Task newtask : taskList){
            XC_UTIL_Debug.debug(DEBUGACTIVE,LoggingLevel.FINEST,'@TASK-->'+ newtask.Status +'---' + newtask.WhatId);
            if (newtask.Status.equals(XC_AT_Constants.TRIGGER_TASK_STATUS_NEW) && newtask.WhatId!=null  ){
                /* Fix MCutillo 04/02/2019*/
                //String whatId = String.valueOf(newtask.WhatId);
                Case c = mapParentCases.get(newtask.WhatId);
                //if(whatId.startsWith('500')){
                    //Case c = new Case(id=newtask.WhatId);
                
                if(c==null){
                    continue;
                }
                if(isCaseToChangeOnHold(newtask)){
                    c.Status = Label.XC_CL_Case_OnHold;
                } else {
                    if(newtask.OwnerId==c.OwnerId ){
                        continue;
                    }
                    if(c.Status ==null){
                        c.Status = Label.XC_CL_Case_InProgress;
                    }
                    changeCaseStatus(c,newtask);
                }
                //c.Status = (isCaseToChangeOnHold(newtask)) ? Label.XC_CL_Case_OnHold : Label.XC_CL_Case_InProgress;
                caseParentdIsSet.add(c);
                //}
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'setParentCaseStatus caseParentdIsSet to upd = '+caseParentdIsSet);
        if(!caseParentdIsSet.isEmpty()){
            List<XC_UTIL_SObject.WrapperResult> dmlResult = XC_UTIL_SObject.updateListRecords(new List<Case>(caseParentdIsSet));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'setParentCaseStatus dmlResult = ' + dmlResult);
        }
    }

    /**
     * @description Parent case status set and remove pending.
     * @param listNew the list new
     */
    public static void parentCaseStatusSetAndRemovePending(List<Task> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in parentCaseStatusSetAndRemovePending for task');
        Set<Case> caseParentdIsSet = new Set<Case>();
        List<Case> caseParentdIsList = new List<Case>();
        
        List<String> listWhatIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'WhatId');
        
        Map<Id,Case> mapParentCases = new Map<Id,Case>([SELECT id, Status,OwnerId FROM Case WHERE Id IN: listWhatIds]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapParentCases= ' + mapParentCases);
        for(Task t : listNew){ 
            Case c = mapParentCases.get(t.WhatId);
            if(c==null || t.Status==null || t.OwnerId==c.OwnerId ){
                continue;
            }
            changeCaseStatus(c,t);
            caseParentdIsSet.add(c);
        } 
        for(Case caseObj : caseParentdIsSet){
            caseParentdIsList.add(caseObj);
        }
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_SObject.updateListRecords(caseParentdIsList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'dmlResult= ' + dmlResult);
    }

    /**
     * @description Set the Status Case depending on Task in input
     * @param c the case
     * @param t the task
     */
    private static void changeCaseStatus(Case c, Task t){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ changeCaseStatus - c.Status = '+c.Status);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ changeCaseStatus - t.Status = '+t.Status);
        if(c.Status.equals(Label.XC_CL_Case_Pending) || c.Status.equals(Label.XC_CL_Case_OnHold)){
            c.Status = Label.XC_CL_Case_InProgress;
        } else if(c.Status.equals(Label.XC_CL_Case_InProgress)){
            if(!t.Status.equals(Label.XC_CL_Task_Completed) && !t.Status.equals(Label.XC_CL_Task_Rejected)){
                c.Status = Label.XC_CL_Case_Pending;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ changeCaseStatus - NEW c.Status = '+c.Status);
    }

     /**
      * @description Check if newTask Subject in input contains a specific Label to change Case Statun in On Hold.
      * @param newtask the newtask
      * @return the boolean
      */
     private static Boolean isCaseToChangeOnHold(Task newtask){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ newtask='+newtask);
        if(newtask==null || newtask.Subject==null || String.isEmpty(newtask.Subject)){
             return false;
        }
        String targetSubject = (Label.XC_CL_TaskSubjectCaseOnHold).toUpperCase();
        String taskSubject = (newtask.Subject).toUpperCase();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ isCaseToChangeOnHold - targetSubject='+targetSubject);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ isCaseToChangeOnHold - taskSubject='+taskSubject);

        return taskSubject.contains(targetSubject);
     }

    /*
        //vb métodos asincronos desd trigger
        if(!System.isFuture()){
            try{
                //vb . si el caso padre esta pendiente lo pasaremos a en progreso cuando su wo este cerrado
                //vb ,cierre del caso sea automático, es decir que el trigger cierre el caso automáticamente si esas 3 entidades que puede tener relacionadas estén o bien cerradas o bien canceladas.
                System.debug('XC_TR_Task_Care_Handler allwaysAfter, casos padres a en progreso o cerrado');
                XC_AT_Utils.setParentCaseStatus(caseParentdIsInProgress);
            }catch(Exception e){
                System.debug('XC_TR_Task_Care_Handler allwaysAfter setParentCaseStatus' +e);
            }
        }
    }*/
}