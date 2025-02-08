/**
* @author sbarbera
* @date Creation 14/09/2021
* @description  – Class to manage Product Reservation in B2B segment  -  
*/
public without sharing class XC_LCC255_CancelProductReservation {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC255_CancelProductReservation');

    /**
    * @author sbarbera
    * @date Creation 14/09/2021
    * @description Method to check and update WOLI
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper cancelProducReservationStep1(String workOrderLineItemId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In cancelProducReservationStep1');
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        if(workOrderLineItemId != null && workOrderLineItemId != '') {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'woli not empty: ' + workOrderLineItemId);
            List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(workOrderLineItemId);
            WorkOrderLineItem woli = lstWOLI.get(0);
            if(woli.Status == Label.XC_CL_WorkOrder_Canceled || woli.Status == Label.XC_CL_WorkOrder_CannotComplete || woli.Status == Label.XC_CL_WorkOrder_Completed){
                return generateResponse(Label.XC_CL_CancelProductReservationAlreadyPerformed, false, 'Error', Label.XC_CL_Error);
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE,'lstWOLI.get(0): ' + lstWOLI.get(0));
            XC_UTIL_Debug.debug(DEBUGACTIVE,'set woli.XC_ReCalculateSalesOrder__c = true');
            WorkOrderLineItem woliToUpdate = new WorkOrderLineItem(
                Id = woli.XC_MaterialRequest__c,
                XC_RecalculateSalesOrder__c = true
            );
            //turn off the trigger
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
    
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(woliToUpdate);
            if(!dmlResult.success){
                return generateResponse(dmlResult.errorMessage, false, 'Error', Label.XC_CL_Error);
            }
            //turn on the trigger
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);  
            
            return generateResponse('Step 1 ok', true, 'Success', Label.XC_CL_Success);            
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'woli empty');
            return generateResponse('Work Order Line Item is empty!', false, 'Error', Label.XC_CL_Error);
        }
    }

    /**
    * @author sbarbera
    * @date Creation 14/09/2021
    * @description  – Class to manage Product Reservation in B2B segment  -  
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper cancelProducReservationStep2(String workOrderLineItemId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In cancelProducReservationStep2');
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        if(workOrderLineItemId != null && workOrderLineItemId != '') {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'woli not empty: ' + workOrderLineItemId);
            List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(workOrderLineItemId);
            WorkOrderLineItem woli = lstWOLI.get(0);
            if(woli.Status == Label.XC_CL_WorkOrder_Canceled || woli.Status == Label.XC_CL_WorkOrder_CannotComplete || woli.Status == Label.XC_CL_WorkOrder_Completed){
                return generateResponse(Label.XC_CL_CancelProductReservationAlreadyPerformed, false, 'Error', Label.XC_CL_Error);
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE,'lstWOLI.get(0): ' + lstWOLI.get(0));
            XC_UTIL_Debug.debug(DEBUGACTIVE,'calling createGoodIssueFromSalesOrder');
            List<XC_UTIL_Sobject.WrapperResult> resWrapp = XC_UTIL_WOLICreateGoodIssue.createGoodIssueFromSalesOrder(lstWOLI);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'createGoodIssueFromSalesOrder called');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'resWrap: ' + resWrapp);

            if(!XC_UTIL_Sobject.checkDMLResults(resWrapp)) {
                return generateResponse('Error from Glovia: ' + resWrapp[0].errorMessage, false, 'Error', Label.XC_CL_Error);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'set woli.XC_ReCalculateSalesOrder__c = false');
            woli.XC_ReCalculateSalesOrder__c = false;
            XC_UTIL_Debug.debug(DEBUGACTIVE,'woli.Status = Label.XC_CL_WorkOrder_Cancelled');
            woli.Status = Label.XC_CL_WorkOrder_Cancelled;

            WorkOrderLineItem woliToUpdate = new WorkOrderLineItem(
                Id = woli.XC_MaterialRequest__c,
                XC_RecalculateSalesOrder__c = false
            );
            //turn off the trigger
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
            XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(woliToUpdate);
            if(!dmlResult.success){
                return generateResponse('Error updadating woli: ' + dmlResult.errorMessage, false, 'Error', Label.XC_CL_Error);
            }

            dmlResult = XC_UTIL_Sobject.updateRecord(woli);
            if(!dmlResult.success){
                return generateResponse('Error updadating woli: ' + dmlResult.errorMessage, false, 'Error', Label.XC_CL_Error);
            }

            //turn on the trigger
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);   
            Id workOrderId = lstWOLI.get(0).WorkOrderId;
            List<gii__SalesOrderLine__c> salesOrderLineList = [select id, gii__SalesOrder__c from gii__SalesOrderline__c where gii__SalesOrder__r.giic_WorkOrder__r.Id = :workOrderId and gii__Status__c = 'Cancelled'];
            XC_UTIL_Debug.debug(DEBUGACTIVE,'salesOrderLineList.isEmpty() ' + salesOrderLineList.isEmpty());
            if(!salesOrderLineList.isEmpty()){
                Id idSo = salesOrderLineList[0].gii__SalesOrder__c;
                gii__SalesOrder__c salesOrder = new gii__SalesOrder__c();
                salesOrder.Id = idSo;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'salesOrder: '+ salesOrder);
                salesOrder.giic_FSLWorkOrder__c = '';
                salesOrder.giic_FSLWorkOrderLineItem__c = '';
                salesOrder.giic_WorkOrder__c = null;
                salesOrder.giic_WorkOrderLineItem__c = null;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'update salesOrder');
                //update salesOrder;

                dmlResult = XC_UTIL_Sobject.updateRecord(salesOrder);
                if(!dmlResult.success){
                    return generateResponse(dmlResult.errorMessage, false, 'Error', Label.XC_CL_Error);
                }
                return generateResponse('Cancel Reservation correctly completed', true, 'Success', Label.XC_CL_Success);
            } else{
                return generateResponse('Sales Order not found', false, 'Error', Label.XC_CL_Error);
            }
        } else{
            return generateResponse('Work Order Line Item is empty!', false, 'Error', Label.XC_CL_Error);
        }
    }

    /**
    * @author sbarbera
    * @date Creation 14/09/2021
    * @description Method to generate response 
    */
    public static XC_UTIL_ResultWrapper generateResponse(String resultMessage, Boolean success, String typeMessage, String title) {
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        rAndM.resultMessage = resultMessage;
        rAndM.success = success;
        rAndM.typeMessage = typeMessage;
        rAndM.titleMessage = title;
        return rAndM;
    }

}