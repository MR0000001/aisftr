/**
 *  
 * ===================================================================================.
 *
 * @author           AJJL
 * @version          V0.1
 * @className        XC_TR_Task_U_Care
 * @description      Class with general methods to ENEL X application
 * @email            ajimenez@deloitte.es
 * @testClass        pte
 * @dateCreated      2019/01/10
 * @date Modification 01/02/2009 Monica Cutillo - monica.cutillo@nttdata.com
 * ===================================================================================
 */
public with sharing class XC_TR_Task_U_Care {

  /** The Constant DEBUGACTIVE. */
  public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Task_U_Care');

	//public XC_TR_Task_U_Care() {
		
	//}

	/**
	 * Adds the counter taskin work order.
	 *
	 * @author           AJJL
	 * @param workOrderId the work order id
	 * @name           addCounterTaskinWorkOrder
	 * @description    method that add one in the name field
	 * @params 
	 * @email            ajimenez@deloitte.es
	 * @date Modification 01/02/2009 Monica Cutillo - monica.cutillo@nttdata.com
	 */
    public static void addCounterTaskinWorkOrder(Set<Id> workOrderId){
      if(workOrderId != null && !workOrderId.isEmpty()){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'addCounterTaskinWorkOrder, workOrderId'+workOrderId);
        List<WorkOrder> workOrderList = XC_TR_Task_U_Care_D.getWorkOrders(workOrderId);
        for(WorkOrder wo : workOrderList){
          if(wo.XC_ReclamationCounter__c==null){
            wo.XC_ReclamationCounter__c=0;
          }
          wo.XC_ReclamationCounter__c++;
          wo.Priority = Label.XC_CL_Priority_High; /* ESCEP-427 MCutillo*/
        }
        XC_UTIL_Sobject.upsertListRecords(workorderList);
      }
    }
}