/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
 * @date Creation 14/11/2019
 * @date Mod 05/02/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_WorkOrder_U_updateStatusChildWO - Update Child WorkOrder 
 */

public without sharing class XC_TR_WorkOrder_U_updateStatusChildWO {
       
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_updateStatusChildWO');
    
    /**
    * @description Method to update Work Order child
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com 
    * @date 19/11/2019
    * @date Mod 05/02/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listNew - List<WorkOrder>
    * @param mapOld - List<WorkOrder>
    * @param mapNew - List<WorkOrder> 
    **/
    public static void updateChildWorkOrderSubstitution(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }
        List<String> listWorkOrderIdFiltered = new List<String>();
        for(WorkOrder workOrder : listNew) {  
            Boolean checkDigitalized = workOrder.XC_ToBeManuallyDigitalized__c && (workOrder.XC_LegalEntity__c == Label.XC_CL_EndesaX || workOrder.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain);
            Boolean wtSubstitution = workOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution && (workOrder.XC_Check_Final_Status__c || workOrder.Status == Label.XC_CL_WorkOrder_InProgress);
            Boolean checkItaly = workOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && (workOrder.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || workOrder.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia);
            Boolean conditionWorkableDunningProcess = (workOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic || workOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance) && (workOrder.XC_StatusReason__c == Label.XC_CL_Workable || workOrder.XC_StatusReason__c == Label.XC_CL_DunningProcess);
            String woId = workOrder.Id;
            if(wtSubstitution || conditionWorkableDunningProcess || checkItaly || checkDigitalized) {    
                listWorkOrderIdFiltered.add(woId);
            }             
        }
        if(listWorkOrderIdFiltered.isEmpty()) {
            return;
        }
        String returnWT = Label.XC_CL_WorkType_Return;
        String deliveryInstallation = Label.XC_CL_WorkType_DeliveryInstallation;
        String diagnostic = Label.XC_CL_WorkType_Diagnostic;
        String plannedMaintenance = Label.XC_CL_WorkType_PlannedMaintenance;
        String selectAllFields = XC_UTIL_Sobject.selectAllFieldsGetSelect('WorkOrder');
        String query = 'SELECT Id, Status,XC_UpdatedByApp__c, XC_SerialNumber__c, XC_StatusReason__c,XC_WorkTypeCategory__c, XC_Digitized__c, XC_ToBeManuallyDigitalized__c, XC_LegalEntity__c,XC_Segment__c,XC_ProductSubType__c, XC_ExtraCost__c,XC_WasteDisposal__c,WorkOrderNumber, ';
        query += '(' + selectAllFields + ' FROM ChildWorkOrders ' ;
        query += ' WHERE XC_WorkTypeCategory__c =: returnWT OR XC_WorkTypeCategory__c = :deliveryInstallation OR XC_WorkTypeCategory__c =: diagnostic OR XC_WorkTypeCategory__c =: plannedMaintenance )';
        query += ' FROM WorkOrder ';
        query += 'WHERE Id IN :listWorkOrderIdFiltered';
        List<Workorder> listWorkOrderWithChild = Database.query(query);
        /*List<WorkOrder> listWorkOrderWithChild = new List<WorkOrder>([
            SELECT Id, Status, XC_SerialNumber__c, XC_StatusReason__c,XC_WorkTypeCategory__c, XC_Digitized__c, XC_ToBeManuallyDigitalized__c, XC_LegalEntity__c,XC_Segment__c,XC_ProductSubType__c, XC_ExtraCost__c,XC_WasteDisposal__c,WorkOrderNumber,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Configuration_Item__c, Status, XC_Check_Final_Status__c, XC_LegalEntity__c, XC_Segment__c, XC_ProductSubType__c, XC_ExtraCost__c, XC_WasteDisposal__c, WorkOrderNumber 
                FROM ChildWorkOrders 
                WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_Return OR XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_DeliveryInstallation
                OR XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Diagnostic OR XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_PlannedMaintenance) 
            FROM WorkOrder 
            WHERE Id IN :listWorkOrderIdFiltered
        ]);*/
        List<WorkOrder> listWorkOrderToUpdate = updateChidWorkOrder(listWorkOrderWithChild, listNew);
    }

    /**
    * @description Method to update Work Orders
    * @author Valeria Martino - valeria.martino@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 19/11/2019
    * @param listWorkOrderWithChild - List<WorkOrder>
    * @param listNew - List<WorkOrder> 
    * @return List<WorkOrder>
    **/
    public static List<WorkOrder> updateChidWorkOrder(List<WorkOrder> listWorkOrderWithChild, List<WorkOrder> listNew) {
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        for(WorkOrder wo: listWorkOrderWithChild) {
            if(!wo.ChildWorkOrders.isEmpty()){
                for(WorkOrder child: wo.ChildWorkOrders) {
                    if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution){
                        child.XC_UpdatedByApp__c = wo.XC_UpdatedByApp__c;
                        child.Status = wo.Status;
                    }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance ||
                             wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
                        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.Status == Label.XC_CL_WorkOrder_Completed){
                            child.XC_InstallationDate__c = Date.today();    
                        }
                        if(wo.Status != Label.XC_CL_WorkOrder_Assigned){
                            child.Status = wo.Status;
                            child.XC_StatusReason__c = wo.XC_StatusReason__c;
                       }
                    }
                    if(wo.XC_Digitized__c) {
                        child.XC_Digitized__c = true;
                    }
                    if(wo.XC_ToBeManuallyDigitalized__c) {
                        child.XC_ToBeManuallyDigitalized__c = true;
                    }
                    listWorkOrderToUpdate.add(child);
                }
            }    
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        if(!listWorkOrderToUpdate.isEmpty()){
            XC_TR_WorkOrder_U_FinalStatus.checkWorkOrderCompliance(listWorkOrderToUpdate, listNew);
        }
        List<XC_UTIL_Sobject.WrapperResult> listResult = XC_UTIL_SObject.updateListRecords(listWorkOrderToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        if(!XC_UTIL_Sobject.checkDMLResults(listResult)) {
            listNew[0].addError(listResult[0].errorMessage);
        }

        // Check for Provisioning Step for Child WorkOrder:
        List<WorkOrder> workOrderinFinalStatusList = new List<WorkOrder>();
        for(WorkOrder woToUpdate : listWorkOrderToUpdate){
            if(woToUpdate.Status == Label.XC_CL_Completed || woToUpdate.Status == Label.XC_CL_CannotComplete || woToUpdate.Status == Label.XC_CL_WorkOrder_Canceled){
                workOrderinFinalStatusList.add(woToUpdate);
            }
        }
        if(!workOrderinFinalStatusList.isEmpty()){
            XC_TR_WorkOrder_U_FinalStatus.updateSteps(workOrderinFinalStatusList);
        }
        return listWorkOrderToUpdate;
    }
    
}