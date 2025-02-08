/**
 *  
 * ===================================================================================.
 *
 * @author           AJJL
 * @version          V0.1
 * @className        XC_TR_Task_U_Care_createOpWoByCScoverage
 * @description      Handler class for Case object ENEL X PROYECT
 * @email            ajimenez@deloitte.es
 * @testClass        N/A
 * @dateCreated      2019/01/16
 * ==============================================================================================================================
 */

public class XC_TR_Task_U_Care_createOpWoByCScoverage {
private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_AT_Constants');
	
	/**
	 * Creates the op wo by C scoverage.
	 *
	 * @author           AJJL
	 * @param taskList the task list 
	 * @name           createOpWoByCScoverage
	 * @description    // vb - XC_CS001_CaseTypologyAndCoverage caso 3 
	 * @email            ajimenez@deloitte.es
	 * @lastChange       vbarquero , this method will be executed by Trigger
	 */
	public static void createOpWoByCScoverage(List<Task> taskList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### In createOpWoByCScoverage### ' );
		Set<Id> casesToAssingOpWoByCoverage = new Set<Id>();
		for(task newtask : taskList){
			//vb . si la tarea es VideoLlamada y pasa a cancelada  XC_CS001_CaseTypologyAndCoverage Caso 3
            if (newtask.Status!=null && newtask.WhatId!=null && (newtask.Status.equals(XC_AT_Constants.TASK_STATUS_CANCELED) )) {

                casesToAssingOpWoByCoverage.add(newtask.WhatId);    
            }  
		}
		/*
		if(!System.isFuture()){
			try{
                /*** vb - XC_CS001_CaseTypologyAndCoverage caso 3
                if(!casesToAssingOpWoByCoverage.isEmpty()){
               // XC_TR_Case_U_Care.createOpWoByCScoverage(XC_AT_Utils.getRelatedParentCasesByCaseIds(casesToAssingOpWoByCoverage));
               XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_AT_Constants');
                }
            }catch(Exception e){
                System.debug('XC_TR_Task_Care_Handler allwaysAfter createOpWoByCScoverage' +e);
            }
		} */
	}

}