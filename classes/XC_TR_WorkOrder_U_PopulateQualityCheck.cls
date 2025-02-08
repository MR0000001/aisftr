/**
 * @author: Roberta Cossiga - rcossiga@deloitte.it
 * @date:21-11-2019
 * @description Class to populate fields on Quality Check Inspection WorkOrder
*/  

public without sharing class XC_TR_WorkOrder_U_PopulateQualityCheck {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_PopulateQualityCheck');
        
    /**
    * @author: Roberta Cossiga - rcossiga@deloitte.it
 	* @description Method to  check if the WorkOrder is of the necessary type
    * @param listNew - List<WorkOrder>  
    */
	public static void retrieveOnlyQualityCheck(List<WorkOrder> listNew){
        List<WorkOrder> woListToPopulate = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(!String.isBlank(wo.ParentWorkOrderId) && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_QualityCheckInspection){
                woListToPopulate.add(wo);
            }
        }
        fillFieldsOnQualityCheck(woListToPopulate);
    }

    /**
    * @author: Roberta Cossiga - rcossiga@deloitte.it
 	* @description Method to populate fields on QI WorkOrder
    * @param woListToPopulate - List<WorkOrder>  
    */
	private static void fillFieldsOnQualityCheck(List<WorkOrder> woListToPopulate){
        List<String> parentWoIds = XC_UTIL_Sobject.getListFieldValues(woListToPopulate, 'ParentWorkOrderId');
        Map<Id, WorkOrder> mapParentWo = new Map<Id, WorkOrder>(
                                        [SELECT Id, AccountId, ContactId 
                                         FROM WorkOrder
                                         WHERE Id IN: parentWoIds]);
        for(WorkOrder wo: woListToPopulate){
            wo.AccountId = mapParentWo.get(wo.ParentWorkOrderId).AccountId;
            wo.ContactId = mapParentWo.get(wo.ParentWorkOrderId).ContactId;
        }
    }

}