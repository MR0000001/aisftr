/**
 *  
 * ===================================================================================.
 *
 * @author           AJJL
 * @version          V0.1
 * @className        XC_TR_Task_U_Care_AddCountTaskWorkOrder
 * @description      Handler class for Case object ENEL X PROYECT
 * @email            ajimenez@deloitte.es
 * @testClass        N/A
 * @dateCreated      2019/01/16
 * ==============================================================================================================================
 */
public class XC_TR_Task_U_Care_AddCountTaskWorkOrder {
	
	/**
	 * Adds the count task work order.
	 *
	 * @author           AJJL
	 * @param taskList the task list
	 * @name           addCountTaskWorkOrder 
	 * @description    //aj: aumentar el numero de tareas asociadas a la workorder
	 * @email            ajimenez@deloitte.es
	 * @lastChange       vbarquero , this method will be executed by Trigger
	 */
	public static void addCountTaskWorkOrder(List<Task> taskList) {
		Set<Id> workOrderId = new Set<Id>();
		if (Trigger.isInsert){
			for(task newtask : taskList){
				//aj. obtener las WO asociadas a las tareas
            	if(newtask.WhatId!=null) {
            		workOrderId.add(newtask.WhatId);
            		}			
			}
			//vb métodos asincronos desd trigger
			if(!System.isFuture()){
				try{
					//aj: aumentar el numero de tareas asociadas a la workorder
                	System.debug('XC_TR_Task_Care_Handler allwaysAfter, aumentar el contador de la WO relacionada a la tarea');
                	XC_TR_Task_U_Care.addCounterTaskinWorkOrder(workOrderId);
				}catch(Exception e){
					System.debug('XC_TR_Task_Care_Handler allwaysAfter addCounterTaskinWorkOrder' +e);
				}
			}
		}
	}

}