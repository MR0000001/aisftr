/**
* @author dpalamides
* @date 10/06/2020
* @description: classes.XC_LCC192_BillingPreview
*/


public with sharing class XC_LCC192_BillingPreview {

    public class PreviewBillingModel implements Queueable , Database.AllowsCallouts{
        String recordId;
        String orderItemId;

        public void execute(QueueableContext context) {
            try {
                XC_LCC192_BillingPreview.createPreviewZQuote(recordId, orderItemId);
            }catch(Exception e){
                NE__Order__c theOrder = (NE__Order__c) XC_UTIL_Sobject.selectAllFields(recordId)[0];
                theOrder.XC_BillingPreviewStatus__c = 'Error';
                theOrder.XC_BillingPreviewMessage__c = e.getMessage();
                XC_UTIL_Sobject.updateRecord(theOrder);
            }
        }
    }


    @AuraEnabled
    public static String refreshBillingPreview(String recordId){
        if (recordId == null) {
            return null;
        }

        NE__Order__c theOrder = getOrderById(recordId);
        Map<id,NE__OrderItem__c> ordItemToClear = new Map<id,NE__OrderItem__c>([
                select id, XC_PaymentMethod__c, XC_BillingModel__c from NE__OrderItem__c
                where NE__OrderId__c = :recordId and RecordType.DeveloperName != 'Technical_Item' and XC_BillingModel__c != 'Capex' and (NE__Parent_Order_Item__c != null or XC_BillingModel__c = 'Milestone' OR NE__CatalogItem__r.NE__Item_Header__c = null)
        ]);
        System.debug('ordItemToClear: ' + ordItemToClear);

        if((theOrder.XC_Segment__c == 'B2B' || theOrder.XC_Segment__c == 'B2G') && String.isBlank(theOrder.XC_InvoiceType__c)) {
            return Label.XC_CL_BillingPreviewInvoiceType;
        }
        
        if(theOrder.XC_BillingPreviewStatus__c == 'OK') {
            return Label.XC_CL_PreviewStillValid;
        }

        if(!checkOrderStatus(theOrder)) {
           return Label.XC_CL_Configuration_ErrorStatus;
        }

        if(!checkQuoteStatus(theOrder)) {
            return Label.XC_CL_InvalidQuoteStatusPreview;
        }

        if(checkPaymentMethodIsFilled(ordItemToClear.values())){
            return Label.XC_CL_PaymentMethodsRequiredMess;
        }

        theOrder.XC_BillingPreviewStatus__c = 'Waiting';
        theOrder.XC_BillingPreviewMessage__c = null;
        theOrder.XC_Charge_Amount__c = null;
        theOrder.XC_TexVAT__c = null;
        XC_UTIL_Sobject.updateRecord(theOrder);

        Map<id,zqu__Quote__c> oldZQuotes = new Map<id,zqu__Quote__c>([
                select id from zqu__Quote__c
                where CRMConfiguration__c = :recordId and XC_isPreviewQuote__c = true
        ]);

        XC_UTIL_Sobject.deleteListRecords(oldZQuotes.values());


        for(NE__OrderItem__c oi : ordItemToClear.values() ){
            oi.XC_Charge_Amount__c = null;
            oi.XC_Tax_AmountBillingPreviw__c = null;
        }

        XC_UTIL_Sobject.updateListRecords(ordItemToClear.values());

        System.debug('theOrder.NE__Order_Items__r: ' + theOrder.NE__Order_Items__r);
        for(NE__OrderItem__c ordItem : theOrder.NE__Order_Items__r){
            //createPreviewZQuote(recordId,bm);
            PreviewBillingModel previewJob = new PreviewBillingModel();
            previewJob.recordId = recordId;
            previewJob.orderItemId = ordItem.Id;
            System.enqueueJob(previewJob);
        }
        return 'OK';
    }



    private static void createPreviewZQuote(String recordId, String orderItemId) {

        if (recordId == null) {
            return;
        }

        NE__Order__c theOrder = getOrderByIdAndItem(recordId,orderItemId);

        List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper> wrList = new List<XC_UTIL_CreateZQuotePPM.MilestoneWrapper>();
        String orderId = null;
        for (NE__OrderItem__c ordItem : theOrder.NE__Order_Items__r) {

            XC_UTIL_CreateZQuotePPM.MilestoneWrapper ew = new XC_UTIL_CreateZQuotePPM.MilestoneWrapper();
            ew.generateInvoice = true;
            ew.separateInvoice = false;
            ew.autoRenew = false;
            ew.initialTerm = 1;
            ew.configurationItemId = ordItem.Id;
            ew.item = ordItem;
            ew.isPreview = true;
            orderId = ordItem.NE__OrderId__c;
            wrList.add(ew);

        }

        String generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(orderId);
        XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, orderId, 'GenerateWorkOrder-XC_LCC192_BillingPreview');

        XC_UTIL_CreateZQuotePPM.createZquote(wrList);
    }


    private static NE__Order__c getOrderById(String recordId) {
        if (!Schema.sObjectType.NE__OrderItem__c.isAccessible() || !Schema.sObjectType.NE__Order__c.isAccessible() ) {
            return null;
        }

        Map<Id, NE__Order__c> ordMap = new Map<Id, NE__Order__c>([ select id, XC_Status__c,XC_BillingPreviewStatus__c, XC_InvoiceType__c,XC_Segment__c,(select id, NE__OrderId__c, XC_BillingModel__c, XC_PaymentMethod__c From NE__Order_Items__r where RecordType.DeveloperName != 'Technical_Item' and XC_BillingModel__c != 'Capex' and (NE__Parent_Order_Item__c != null or XC_BillingModel__c = 'Milestone' OR NE__CatalogItem__r.NE__Item_Header__c = null)) from NE__Order__c where id = :recordId]);

        return ordMap.values()[0];

    }

    private static NE__Order__c getOrderByIdAndItem(String recordId, String orderItemId) {
        if (!Schema.sObjectType.NE__OrderItem__c.isAccessible() || !Schema.sObjectType.NE__Order__c.isAccessible() ) {
            return null;
        }

        Map<Id, NE__Order__c> ordMap = new Map<Id, NE__Order__c>(
        [
                select id,(select id, NE__OrderId__c, XC_BillingModel__c From NE__Order_Items__r where id = :orderItemId)
                from NE__Order__c
                where id = :recordId
        ]
        );

        return ordMap.values()[0];

    }


    private static Boolean checkOrderStatus(NE__Order__c order) {
        List<String> listStatusForError = new List<String>{
                Label.XC_CL_Configuration_OrderInProvisioning,
                Label.XC_CL_Configuration_Closed,
                Label.XC_CL_Configuration_OrderCancelled
        };
        if(listStatusForError.contains(order.XC_Status__c)) {
            return false;
        }
        return true;
    }
    private static Boolean checkQuoteStatus(NE__Order__c order) {
        List<String> listStatusForError = new List<String>{
                'Accepted','Rejected'
        };
        if(listStatusForError.contains(order.XC_Status__c)) {
            return false;
        }
        return true;
    }

    private static Boolean checkPaymentMethodIsFilled(List<NE__OrderItem__c> quoeryOnOrderItems){
        Boolean check = False;
        for (NE__OrderItem__c ne : quoeryOnOrderItems){
            if(ne.XC_PaymentMethod__c == Null){
                check = True;
            }
        }
        return check;

    }
}