/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
 * @date 17-08-2021
 * @date Modification XX-XX-XXXX
 * @description XC_TR_WorkOrder_U_AssignedPartner - Class to manage the update of the assigned partner on the WO
 */   

public without sharing class XC_TR_WorkOrder_U_AssignedPartner {
	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_AssignedPartner');
    
     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to verify that the assigned partener is changed, update the flag and relaunch reservation step
     */
    public static void updateAssignedPartner(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'XC_AssignedPartner__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        } 
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        List<String> orderIdList = new List<String>();
        for(WorkOrder wo : listChanged){
            if(wo.XC_Segment__c == 'B2C' && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && String.isEmpty(wo.ParentWorkOrderId) &&  !String.isEmpty(wo.XC_Configuration__c)
            && !String.isEmpty(wo.XC_AssignedPartner__c) && !String.isEmpty(mapOld.get(wo.Id).XC_AssignedPartner__c) ){
                WorkOrder woToUpdate = new WorkOrder(Id = wo.Id, XC_ReCalculateSalesOrder__c = true);
                woToUpdateList.add(woToUpdate);
				orderIdList.add(wo.XC_Configuration__c);             	   
            }
        }
        if(!orderIdList.isEmpty()){
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(woToUpdateList);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            List<XC_Provisioning_Step__c> stepListToBeRelauched = getReservationStepsToBeRelauched(orderIdList);
            if(!stepListToBeRelauched.isEmpty()){
                XC_UTIL_ProvisioningStep.insertEvent(stepListToBeRelauched);
            }
        }
    }
    
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @param orderIdList 
    * @return List<XC_Provisioning_Step__c> 
    **/
    private static List<XC_Provisioning_Step__c> getReservationStepsToBeRelauched (List<String> orderIdList) {
        List<XC_Provisioning_Step__c> stepListToBeRealuched = new List<XC_Provisioning_Step__c>();
        List<String> orderItemVerifiedList = new List<String> ();
        List<String> reservationFlowsList = new List<String>{Label.XC_CL_ProvisioningReservationSpareParts_Flow, Label.XC_CL_ProvisioningProductReservation_Flow};
        List<String> flowToCheckList = new List<String>{Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow};
        String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_Provisioning_Step__c'));
        query += String.escapeSingleQuotes(' FROM XC_Provisioning_Step__c WHERE XC_Configuration_Item__r.NE__OrderId__c IN: orderIdList AND (XC_Flow_API_Name__c IN: reservationFlowsList OR XC_Flow_API_Name__c IN: flowToCheckList) AND XC_MasterofProductReservation__c = true');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stepsQuery---> ' + query);
        List<XC_Provisioning_Step__c> stepList = Database.query(query);
        for(XC_Provisioning_Step__c step : stepList){
            if(flowToCheckList.contains(step.XC_Flow_API_Name__c)){
                orderItemVerifiedList.add(step.XC_Configuration_Item__c);
            }
        }
        if(stepList.isEmpty()){
            return new List<XC_Provisioning_Step__c>();
        }
        for(XC_Provisioning_Step__c step : stepList ){
            if(orderItemVerifiedList.contains(step.XC_Configuration_Item__c) &&  reservationFlowsList.contains(step.XC_Flow_API_Name__c) ){
                step.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
                stepListToBeRealuched.add(step);
            }
        }
        XC_UTIL_Sobject.updateListRecords(stepListToBeRealuched);
        return stepListToBeRealuched;
    }
}