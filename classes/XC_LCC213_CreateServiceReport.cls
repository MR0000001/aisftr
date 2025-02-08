/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/10/2020
  * @description XC_LCC213_CreateServiceReport - Apex Controller for component XC_LCP213_CreateServiceReport
*/

public without sharing class XC_LCC213_CreateServiceReport {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC213_CreateServiceReport');

    /** @description OutputWrapper */
    public class OutputWrapper {
        @AuraEnabled
        public String message = '';
        @AuraEnabled
        public Boolean success = false;
    }

    /** 
      * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
      * @date Creation 15/10/2020
      * @description Method to create service report for Work Order
      * @param workOrderId - String
      * @return OutputWrapper
      */
    @AuraEnabled
    public static OutputWrapper createServiceReport(String workOrderId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create request for Service Report');
        OutputWrapper wr = new OutputWrapper();
        List<WorkOrder> listWo = new List<WorkOrder>([
            SELECT Id, XC_CreateReducedReport__c, XC_CongaDynamicAPI__c, Status,
                (SELECT Id FROM ChildWorkOrders)   
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        List<String> listWorkOrderIdsWithChild = new List<String>();
        for(WorkOrder wo : listWo) {
            listWorkOrderIdsWithChild.add(wo.Id);
            for(WorkOrder woChild : wo.ChildWorkOrders) {
                listWorkOrderIdsWithChild.add(woChild.Id);
            }
        }
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>([
            SELECT Id 
            FROM WorkOrderLineItem
            WHERE   (Status = :Label.XC_CL_InProgress OR Status = :Label.XC_CL_WorkOrderLineItem_Closed) AND
                    WorkOrderId IN :listWorkOrderIdsWithChild
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder/WorkOrderLineItems retrieved: ' + listWo);
        if(!listWo.isEmpty()) {
            WorkOrder wo = listWo[0];
            List<String> listStatusPermetted = new List<String>{Label.XC_CL_InProgress, Label.XC_CL_Completed};
            if(!listStatusPermetted.contains(wo.Status)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error: Report already sent');
                wr.success = false;
                wr.message = Label.XC_CL_ErrorCreateSRStatus + ' ' +  wo.Status;
                return wr;
            }
            if(wo.XC_CreateReducedReport__c) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error: Report already sent');
                wr.success = false;
                wr.message = Label.XC_CL_RequestAlreadySent;
                return wr;
            }
            if(String.isNotBlank(wo.XC_CongaDynamicAPI__c)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error: Document already exists');
                wr.success = false;
                wr.message = Label.XC_CL_DocumentAlreadyCreated;
                return wr;
            }
            if(listWoli.isEmpty()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error: No Work Order Line Items with status In Progress/Closed');
                wr.success = false;
                wr.message = Label.XC_CL_RequestSubmittedDoc;
                return wr;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Work Order can be updated');
            wo.XC_CreateReducedReport__c = true;
            XC_UTIL_Sobject.WrapperResult wrUpdate = XC_UTIL_Sobject.updateRecord(wo);
            if(!wrUpdate.success) {
                wr.success = false;
                wr.message = wrUpdate.errorMessage;
                return wr;
            } else {
                wr.success = true;
                return wr;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ No Work Order found');
        return wr;        
    }

}