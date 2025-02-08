/**
 * The Class XC_TR_Task_U_CaseParent.
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @description Class for manage Task parent status
 */

public without sharing class XC_TR_Task_U_CaseParent {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Task_Handler');
    
     /**
      * @description Check and set parent.
      * @param taskList the task list
      */
     public static void checkAndSetParent(Task[] taskList){
        //XC_TR_Task_U_Care_SetParentCaseStatus.setParentCaseStatus(taskList);
        //XC_TR_Task_U_Care_IsParentCasePending.isParentCasePending(taskList); //fix MCutillo 30/04/2019
        XC_TR_Task_U_Care_AddCountTaskWorkOrder.addCountTaskWorkOrder(taskList);
        XC_TR_Task_U_Care_createOpWoByCScoverage.createOpWoByCScoverage(taskList);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Deny creation of tasks related to Closed or Cancelled Cases
     *
     * @param listNew the list new
     */
    public static void checkIfDenyCreations(List<Task> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Task_U_CaseParent CALL checkIfDenyCreations');
        if(!Trigger.isInsert){
            return;
        }
        
        Set<Id> relatedIds = new Set<Id>();
        for(Task newtask : listNew) {
            if (newtask.WhatId != null){
                relatedIds.add(newtask.WhatId);
            }
        }
        Map<Id,Case> idToCase = new Map<Id,Case>([
            SELECT Id, Status 
            FROM Case 
            WHERE Id IN: relatedIds 
               AND (Status =: XC_AT_Constants.TRIGGER_STATUS_ESTA007 OR Status =: XC_AT_Constants.TRIGGER_STATUS_ESTA008) ]);

        if(idToCase.keySet().isEmpty()) {
            return;
        }
        for(Task newtask : listNew) {
            if(idToCase.get(newtask.WhatId) != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'addError on Task Label.XC_CL_TaskCreationBlockedMess');
                newtask.addError(Label.XC_CL_TaskCreationBlockedMess);
            }
        }
    }

}