/**
 *  
 * ===================================================================================.
 *
 * @author           AJJL
 * @version          V0.1
 * @className        XC_TR_Task_U_Care_ModifyTaskByActionPlan
 * @description      Handler class for Case object ENEL X PROYECT
 * @email            ajimenez@deloitte.es
 * @testClass        N/A
 * @dateCreated      2019/01/16
 * ==============================================================================================================================
 */
public class XC_TR_Task_U_Care_ModifyTaskByActionPlan {
	
	/**
	 * The Constant DEBUGACTIVE.
	 *
	 * @author           AJJL
	 * @return         -
	 * @name           validationByAccount
	 * @description    //vb Tarea que viene de Action plan
	 * @email            ajimenez@deloitte.es
	 * @lastChange       vbarquero , this method will be executed by Trigger
	 */

	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Task_Handler'); //XC_TR_Task_U_Care_ModifyTaskByActionPlan

	/**
	 * @description Modify task by action plan.
	 * @param taskList the task list
	 */
	public static void modifyTaskByActionPlan(List<Task> taskList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Task_U_Care_ModifyTaskByActionPlan CALL modifyTaskByActionPlan');
		for(task newtask : taskList){
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@ newtask='+newtask);
			if(newtask.Description != null && newtask.Description.equals(XC_AT_Constants.TRIGGER_COMMENT_ACTION_PLAN)){
				XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Task_Care_Handler allwaysBefore, Task created from an ActionPlan');
				newtask.Description = '';
				newTask.Status = XC_AT_Constants.TRIGGER_TASK_STATUS_NEW;
			}
		}
	}
}