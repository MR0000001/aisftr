/**
*@author Francesco Imperioli - fimperioli@deloitte.it
*@description manage creation of zquotes for penalty items in disconnect change orders
*@creation 23/12/2019
*/

public without sharing class XC_IN039_ManagePenaltyZQuote {


    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

    public class PenaltyQuoteCreationWrapper{
        public XC_Provisioning_Step__c step;
        public String orderId;
        public String orderItemId;
    }


    /**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@description check if there are positive penalties and eventually create the zquote on zuora
    *@param inputwrapper list
    */
    @InvocableMethod
    public static void managePenaltyZQuote(List<InputWrapper> wrapperList){

        if(!wrapperList.isEmpty()){

            List<String> stepIds = new List<String>();
            for(InputWrapper iw : wrapperList){
                stepIds.add(iw.stepId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(stepIds);
            String orderId;
            String orderItemId;
            XC_Provisioning_Step__c stepRecord;

            for(InputWrapper iw : wrapperList){
                stepRecord = mapSteps.get(iw.stepId);
                orderId = stepRecord.XC_Configuration_Item__r.NE__OrderId__c;
                orderItemId = stepRecord.XC_Configuration_Item__c;
            }

            PenaltyQuoteCreationWrapper pqcw = new PenaltyQuoteCreationWrapper();
            pqcw.step = stepRecord;
            pqcw.orderId = orderId;
            pqcw.orderItemId = orderItemId;

            System.Debug('PENALTY CREATION ZQUOTE WRAPPER ::: ' + JSON.serialize(pqcw));
            checkOrderPenaltyAndCreateQuote(pqcw);

        }
    }


    private static void checkOrderPenaltyAndCreateQuote(PenaltyQuoteCreationWrapper pqcw){

        if(String.isNotBlank(pqcw.orderId)){

            Map<Id,NE__Order__c> mapOrder = new Map<Id,NE__Order__c>([
                SELECT Id,
                    (SELECT Id, XC_Configuration_Item__c FROM NE__Assets__r WHERE XC_Product_Name_LIC__c =: Label.XC_CL_Asset_Penalty), 
                    (SELECT Id,NE__OneTimeFeeOv__c,NE__Parent_Order_Item__c  FROM NE__Order_Items__r  
                        WHERE NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c =: Label.XC_CL_Asset_Penalty AND NE__OneTimeFeeOv__c > 0.01) 
                FROM NE__Order__c WHERE ID = :pqcw.orderId LIMIT 1]);

            if(!mapOrder.values()[0].NE__Order_Items__r.isEmpty()){

                //mapping all penalties elements
                List<String> penaltyItemsIds = new List<String>();
                List<String> parentItemsIds = new List<String>();
                for(NE__OrderItem__c penalty: mapOrder.values()[0].NE__order_Items__r){
                    penaltyItemsIds.add(penalty.Id);
                    parentItemsIds.add(penalty.NE__Parent_Order_Item__c);
                }

                Map<Id, NE__OrderItem__c> items = getOrderItems(penaltyItemsIds, parentItemsIds);

                Map<Id,NE__OrderItem__c> penaltyItemMap = new Map<Id,NE__OrderItem__c>();
                Map<Id,NE__OrderItem__c> parentItemMap = new Map<Id,NE__OrderItem__c>();
                for(NE__OrderItem__c item : items.values()) {
                    if(penaltyItemsIds.contains(item.Id)) {
                        penaltyItemMap.put(item.Id, item);
                    } else {
                        parentItemMap.put(item.Id, item);
                    }
                }

                /*List<NE__OrderItem__c> penaltyItems = (List<NE__OrderItem__c>) XC_UTIL_Sobject.selectAllFields(penaltyItemsIds,'NE__OrderItem__c');
                List<NE__OrderItem__c> parentItems = (List<NE__OrderItem__c>) XC_UTIL_Sobject.selectAllFields(parentItemsIds,'NE__OrderItem__c');

                Map<Id,NE__OrderItem__c> penaltyItemMap = new Map<Id,NE__OrderItem__c>(penaltyItems);
                Map<Id,NE__OrderItem__c> parentItemMap = new Map<Id,NE__OrderItem__c>(parentItems);*/

                Map<Id, Asset> confItemIdAssetMap = new Map<Id, Asset>();
                for(Asset a : mapOrder.values()[0].NE__Assets__r){
                   confItemIdAssetMap.put(a.XC_Configuration_Item__c, a);
                }

                // String penaltyItemId = mapOrder.values()[0].NE__Order_Items__r[0].Id;
                // NE__OrderItem__c penaltyItem = (NE__OrderItem__c) XC_UTIL_Sobject.selectAllFields(penaltyItemId)[0];
                Map<Id, NE__OrderItem__c> oisToUpdate = new Map<Id, NE__OrderItem__c>();
                List<Asset> assetsToUpdate = new List<Asset>();
                for(NE__OrderItem__c penaltyItem : penaltyItemMap.values()){

                    NE__OrderItem__c sourceOrderItem = parentItemMap.get(penaltyItem.NE__Parent_Order_Item__c);
                    String penaltyWbeString = sourceOrderItem.XC_Wbe__c.subString(0,16) + 'A' + sourceOrderItem.XC_Wbe__c.subString(17,sourceOrderItem.XC_Wbe__c.length());

                    //if(penaltyItem.NE__OneTimeFeeOv__c > 0.01){

                    penaltyItem.XC_BillingModel__c = 'One Shot';
                    penaltyItem.XC_BillingProfileLineItem__c = sourceOrderItem.XC_BillingProfileLineItem__c;
                    penaltyItem.XC_PaymentMethod__c = sourceOrderItem.XC_PaymentMethod__c;
                    penaltyItem.XC_ForcePaymentMethodEdit__c = true;
                    penaltyItem.XC_Wbe__c = penaltyWbeString;
                    penaltyItem.XC_CMCostCenter__c = sourceOrderItem.XC_CMCostCenter__c;
                    penaltyItem.XC_CMProfitCenter__c = sourceOrderItem.XC_CMProfitCenter__c;
                    oisToUpdate.put(penaltyItem.Id, penaltyItem);

                    if(confItemIdAssetMap.containsKey(penaltyItem.Id)){
                        Asset a = confItemIdAssetMap.get(penaltyItem.Id);
                        a.XC_BillingModel__c = 'One Shot';
                        a.XC_BillingProfileLineItem__c = sourceOrderItem.XC_BillingProfileLineItem__c;
                        a.XC_PaymentMethod__c = sourceOrderItem.XC_PaymentMethod__c;
                        a.XC_WBE__c = penaltyWbeString;
                        a.XC_CMCostCenter__c = sourceOrderItem.XC_CMCostCenter__c;
                        a.XC_CMProfitCenter__c = sourceOrderItem.XC_CMProfitCenter__c;
                        assetsToUpdate.add(a);
                    }
                }


                List<XC_UTIL_Sobject.WrapperResult> updateAssetResults = XC_UTIL_Sobject.updateListRecords(assetsToUpdate);
                
                List<XC_UTIL_Sobject.WrapperResult> updateItemsResults = XC_UTIL_Sobject.updateListRecords(oisToUpdate.values());
                List<XC_IN018_CreateZQuote.ExternalWrapper> wrList = new  List<XC_IN018_CreateZQuote.ExternalWrapper>();

                for(XC_UTIL_Sobject.WrapperResult updateRes : updateItemsResults){
                    if(updateRes.success){
                        XC_IN018_CreateZQuote.ExternalWrapper ew = new XC_IN018_CreateZQuote.ExternalWrapper();
                        ew.stepId = pqcw.step.Id;
                        ew.generateInvoice = true;
                        ew.separateInvoice = false;
                        ew.autoRenew = false;
                        ew.initialTerm = 1;
                        ew.configurationItemId = updateRes.recordId;
                        ew.item = oisToUpdate.get(updateRes.recordId);
                        wrList.add(ew);

                        System.Debug('ENTER CREATE PENALTY QUOTE FLOW ' + JSON.serialize(ew));
                        
                    }else{
                        System.Debug('ERROR ON UPDATE CONFITEM::: ' + updateRes.recordId + ' ERROR ' + updateRes.errorMessage);
                    }
                }

                XC_IN018_CreateZQuote.createZquote(wrList);
               
                /*}else{
                    //SKIP STEP IF NO PENALTY FOUND OVER 0.01Euro
                    XC_Provisioning_Step__c currentStep = pqcw.step;
                    currentStep.XC_Status__c = 'Skipped';
                    XC_UTIL_Sobject.WrapperResult updateStep = XC_UTIL_Sobject.updateRecord(currentStep);
                }*/
            }else{
                //SKIP STEP IF NO PENALTY FOUND OVER 0.01Euro
                XC_Provisioning_Step__c currentStep = pqcw.step;
                currentStep.XC_Status__c = 'Skipped';
                XC_UTIL_Sobject.WrapperResult updateStep = XC_UTIL_Sobject.updateRecord(currentStep);
           }
        }

    }


    private static Map<Id, NE__OrderItem__c> getOrderItems(List<String> penaltyItemsIds, List<String> parentItemsIds) {
        return new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderId__c, NE__Parent_Order_Item__c, XC_BillingModel__c, XC_BillingProfileLineItem__c,
                                                    XC_PaymentMethod__c, XC_Wbe__c, XC_CMCostCenter__c, XC_CMProfitCenter__c
                                                FROM NE__OrderItem__c 
                                                WHERE Id IN: penaltyItemsIds OR Id IN: parentItemsIds]);
    }

}