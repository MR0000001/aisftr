/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation: 08/04/2020
* @description XC_TR_ServiceAppointment_U_WoliClosure Check the status of the Work Order Line Item
*/
public without sharing class XC_TR_ServiceAppointment_U_WoliClosure {
    
    
    /**
     * @author  Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     * @description Method to populate the field of actual start and actual end of service appointment
     */
    public static void checkWOLIBeforeClosure(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldList = new List<String>{'Status'};
		List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        checkOnWOLIClosure(listChanged);
    }

    
    /**
     * @author  Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     * @description Method to populate the field of actual start and actual end of service appointment
     */
    public static void checkOnWOLIClosure(List<ServiceAppointment> listNew){
        List<Id> workOrderIdList = XC_UTIL_Sobject.getListFieldValues(listNew, 'ParentRecordId');
        List<Id> woChildListId = new List<Id>();
        Map<Id, WorkOrder> mapWorkOrderToCheck = new Map<Id, WorkOrder>([
                										SELECT Id, XC_NumberOfOpenWOLI__c,XC_ConfigurationItemIncentive__c,XC_ProductSubType__c,
            												(SELECT Id, XC_WorkOrder__c FROM Technical_Sheet__r),
            												(SELECT Id, XC_ConfigurationItemIncentive__c, WorkOrderNumber FROM ChildWorkOrders)
                										FROM WorkOrder
                										WHERE Id IN: workOrderIdList]);
        for(WorkOrder wo: mapWorkOrderToCheck.values()){
            if(!mapWorkOrderToCheck.get(wo.Id).ChildWorkOrders.isEmpty()){
                for(WorkOrder woChild : mapWorkOrderToCheck.get(wo.Id).ChildWorkOrders){
                    woChildListId.add(woChild.Id);
                }
            }
        }
        Map<Id, WorkOrder> tsMap = new Map<Id, WorkOrder>();
        if(!woChildListId.isEmpty()){
             tsMap = new Map<Id, WorkOrder>([SELECT Id, XC_NumberOfOpenWOLI__c,XC_ConfigurationItemIncentive__c,XC_ProductSubType__c,
                                             	(SELECT Id, XC_WorkOrder__c FROM Technical_Sheet__r)
                                             FROM WorkOrder
                                             WHERE Id IN: woChildListId]);
        }
        List<String> childWrong = new List<String>();
        List<String> childWrongWoli = new List<String>();
        for(ServiceAppointment sa : listNew){
            if((sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && sa.Status == Label.XC_CL_WorkOrder_Completed){
                if(mapWorkOrderToCheck.get(sa.ParentRecordId).XC_NumberOfOpenWOLI__c > 0){
                    sa.addError(Label.XC_CL_CannotCloseSA);
                }else if(sa.XC_WorkTypeCategory__c == 'Delivery & Installation' && String.isNotBlank(mapWorkOrderToCheck.get(sa.ParentRecordId).XC_ConfigurationItemIncentive__c) && mapWorkOrderToCheck.get(sa.ParentRecordId).Technical_Sheet__r.isEmpty()
                         && !checkProductSubtypeWallBox(mapWorkOrderToCheck.get(sa.ParentRecordId))){
                     sa.addError(Label.XC_CL_CannotCloseTechSheet);        
                } else if(sa.XC_WorkTypeCategory__c == 'Delivery & Installation' && !mapWorkOrderToCheck.get(sa.ParentRecordId).ChildWorkOrders.isEmpty()){
                    for(WorkOrder woChildren : mapWorkOrderToCheck.get(sa.ParentRecordId).ChildWorkOrders){
                        if(tsMap.get(woChildren.Id).XC_NumberOfOpenWOLI__c > 0){
                            childWrongWoli.add(woChildren.WorkOrderNumber);
                        }else if(String.isNotBlank(woChildren.XC_ConfigurationItemIncentive__c) && tsMap.get(woChildren.Id).Technical_Sheet__r.isEmpty()
                         && !checkProductSubtypeWallBox(tsMap.get(woChildren.Id))){
                            childWrong.add(woChildren.WorkOrderNumber);
                        }
                    }
                    if(!childWrongWoli.isEmpty()){
                        sa.addError(Label.XC_CL_CannotCloseSAWoli + ' ' + childWrongWoli[0]);
                    }else if(!childWrong.isEmpty()){
                        sa.addError(Label.XC_CL_CannotCloseTechSheetChild + ' ' + childWrong[0] );
                    }
                }
            }
        }
    }

    private static Boolean checkProductSubtypeWallBox(WorkOrder wo) {
        return  String.isNotBlank(wo.XC_ProductSubType__c) && wo.XC_ProductSubType__c.equals(Label.XC_CL_ProductSubtypeWallbox);
    }

}