/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC208_OdaCancellation {
    @AuraEnabled
    /**
   * @author: Donato Lombardi
   * @date Creation Date 09/09/2019
   * @description method calculate WBE
   * @param recordId Id
   * @return errorMsg String
   */
    public static String submit(Id recordId) {

        XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper result = new XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper();
        List<WorkOrderLineItem> listRecordID = XC_UTIL_Sobject.selectAllFields(recordId);
        if(listRecordID[0].XC_Oda_Cancellation_Sent__c){
            return Label.XC_CL_WOLI_Oda_Cancellation_just_sent;
        }

        if(listRecordID[0].Status!='Completed'){
            return Label.XC_CL_WOLI_Error_Oda_Canc_StatusCompleted;
        }


        List<WorkOrderLineItem> listWOLIaprroved = new List<WorkOrderLineItem>();
        listWOLIaprroved = checkWOLIApproved(recordId);

        if(!listWOLIaprroved.isEmpty()){
            return Label.XC_CL_WOLI_Error_Oda_Canc_StatusCompleted;
        }

        result = sendToSAP(recordId,listRecordID);

        if(String.isBlank(result.result.result.error_code) || result.result.result.error_code == '1' ) {
            return 'Error: ' + result.result.result.message;
        }

    listRecordID[0].XC_Oda_Cancellation_Sent__c = True;
    XC_UTIL_Sobject.updateRecord(listRecordID[0]);
    return 'OK';


    }

    private static List<WorkOrderLineItem> checkWOLIApproved(Id recordId){
        List<WorkOrderLineItem> listWOLIaprroved = new List<WorkOrderLineItem>();
        if(Schema.SObjectType.WorkOrderLineItem.isAccessible()){
            listWOLIaprroved = [select id, XC_PartnerEngagement__r.id, XC_PartnerEngagement__c, RecordType.DeveloperName, Status, XC_Segment__c  from WorkOrderLineItem where XC_PartnerEngagement__c =:recordId and( RecordType.DeveloperName = 'XC_B2BEnelXItaliaPartnerPayment' OR RecordType.DeveloperName = 'XC_B2GEnelXItaliaPartnerPayment') AND Status = 'Approved' ];

        }
        return listWOLIaprroved;


    }
    private static XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper  sendToSAP(String recordId, List<WorkOrderLineItem> listRecordID){

        WorkOrderLineItem woli = [select id, XC_ContractId__r.XC_IDSYSSAP__c from WorkOrderLineItem where id =:recordId];
        String serverSystem = woli.XC_ContractId__r.XC_IDSYSSAP__c!=null && woli.XC_ContractId__r.XC_IDSYSSAP__c.startsWith('D4')? 'D4P': 'S4P';//'S4P';

        XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper result = new XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper();
        XC_REST_DeleteODA_Outbound_U.RequestWrapper wrapperInput = new XC_REST_DeleteODA_Outbound_U.RequestWrapper();
        wrapperInput.purchase_order = new XC_REST_DeleteODA_Outbound_U.ODAWrapper();
        wrapperInput.purchase_order.sfdc_id = recordId;

        wrapperInput.purchase_order.source_system ='XCustomerB2C';
        wrapperInput.purchase_order.target_system = serverSystem;
        wrapperInput.purchase_order.po_number = listRecordID[0].XC_PurchaseOrderCode__c;
        result = XC_REST_DeleteODA_Outbound.callToPostDeleteODA(wrapperInput,serverSystem);

        return result;

    }
}