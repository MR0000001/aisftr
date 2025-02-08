/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2020
* @description XC_LCC185_PendingOrder – Apex Controller for component XC_LCP185_PendingOrder
*/

public without sharing class XC_LCC185_PendingOrder {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC185_PendingOrder');

    /** @description PendingOrderWrapper */
    public class PendingOrderWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String message = '';
    }

    /*
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 02/05/2020
    * @description Method to update SA/WO for Pending Order
    */
    @AuraEnabled
    public static PendingOrderWrapper managePendingOrder(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Apex Controller XC_LCC185_PendingOrder');
        PendingOrderWrapper wr = new PendingOrderWrapper();

        // Retrieve and check for SA and WO:
        List<ServiceAppointment> listSa = new List<ServiceAppointment>([
            SELECT Id  
            FROM ServiceAppointment
            WHERE ParentRecordId = :recordId
        ]);
        if(listSa.isEmpty()) {
            wr.message = Label.XC_CL_NoServiceAppointment;
            return wr;
        }
        List<WorkOrder> listWo = new List<WorkOrder>([
            SELECT Id, Status  
            FROM WorkOrder
            WHERE Id = :recordId
        ]);
        if(listWo[0].Status != Label.XC_CL_WorkOrder_InProgress) {
            wr.message = Label.XC_CL_ErrorPendingOrderStatus;
            return wr;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder: ' + listWo[0]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ServiceAppointment: ' + listSa[0]);

        // Update WO:
        listWo[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        listWo[0].XC_StatusReason__c = Label.XC_CL_StatusReason_PendingOrder;
        XC_UTIL_Sobject.WrapperResult dmlResult = XC_UTIL_Sobject.updateRecord(listWo[0]);
        if(!dmlResult.success) {
            wr.message = dmlResult.errorMessage;
            return wr;
        }

        // Update SA:
        listSa[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        listSa[0].XC_StatusReason__c = Label.XC_CL_StatusReason_PendingOrder;
        dmlResult = XC_UTIL_Sobject.updateRecord(listSa[0]);
        if(!dmlResult.success) {
            wr.message = dmlResult.errorMessage;
            return wr;
        }

        return wr;
    }

}