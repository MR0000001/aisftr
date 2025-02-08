/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 17/09/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Lead_U_CreateTaskLead – This class deals with the creation of
 * 				of a task when the lead has changed the status in Working - Not Contacted
 */

public class XC_TR_Lead_U_CreateTaskLead {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_CreateTaskLead');

	/**
	 * @param listNew the list new
	 * @param mapOld the map old
	 * @param mapNew the map new
     * @description createTask creates the task
	 */
	public static void createTask(List<Lead> listNew, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ START createTask');
		Task taskTmp = new Task();
        List<Task> listLeadTasked = new List<Task>();
        List<Id> listIdLead = new List<Id>();

        List<String> listFields = new List<String>{'Status'};

        /**************** Check list changed **********************/
        List<Lead> listLead = XC_UTIL_Sobject.getListChanged(listFields, mapOld, mapNew);
        if(listLead.isEmpty()){
            return;
        }
        /**************************** ****************************/

        //Id espTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('XC_Task_Spain').getRecordTypeId();

        for(Lead ld : listLead) {
            listIdLead.add(ld.Id);
        }

		listLeadTasked = XC_TR_Lead_U_AssignLead_D.getTaskByLeadId(listIdLead);

        Map<Id, Task> mapIdTaskLead = populateMapTaskLead(listLeadTasked);
        List<Task> taskToInsert = new List<Task>(); //GS 8/2/19 to resolve 
        List<Task> taskToUpdate = new List<Task>();
        
        for(Lead ld : listLead) {

			Lead oldLead = mapOld.get(ld.Id);
			Id currentUserId = UserInfo.getUserId();

        	if((oldLead.Status != ld.Status) && (ld.Status == Label.XC_CL_Lead_TakeCharge )) { //Label.XC_CL_Lead_WorkingNotContacted
                taskTmp = mapIdTaskLead.get(oldLead.Id);

                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Label.XC_CL_OPEN ' + Label.XC_CL_Task_Open);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ id lead in control task ' + oldLead.Id);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ taskTmp ' + taskTmp);

                if((taskTmp == null) || (taskTmp.Status == Label.XC_CL_Task_Completed)) { //Avoid NullPointerException

                        Task t = new Task();
                        t.OwnerId = currentUserId;
                        t.Subject = Label.XC_CL_Task_CallTheCustomer;
                        t.Status = Label.XC_CL_Task_New; // Label.XC_CL_Task_Open;
                        t.WhoId = oldLead.Id;
                        t.ActivityDate = Date.Today() + 7;
                        //t.RecordTypeId = espTaskRT;
                        taskToInsert.add(t);

                } else {
                    
                     if(taskTmp.Status == Label.XC_CL_Task_Open) {
                        taskTmp.OwnerId = currentUserId;
                        taskTmp.ActivityDate = Date.Today() + 7;
                        taskToUpdate.add(taskTmp);
                    }
                }
            }

        }
		
        XC_UTIL_SObject.insertListRecords(taskToInsert);
        XC_UTIL_SObject.updateListRecords(taskToUpdate);
	}

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
	 * @param listLeadTasked - List<Task>
     * @description Method to populate mapIdTaskLead
     * @return Map<Id, Task> 
	 */
	private static Map<Id, Task> populateMapTaskLead(List<Task> listLeadTasked) {
        Map<Id, Task> mapIdTaskLead = new Map<Id, Task>();
        for(Task t : listLeadTasked) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Lead id - task ' + t.WhoId + ' ' + t);
            mapIdTaskLead.put(t.WhoId, t);
        }
        return mapIdTaskLead;
    }
}