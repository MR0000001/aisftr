/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 15/06/2021
 * @description  – public class with invocable method. It is invoked by a flow related to the step "Manage product price and invoice delivery preference"
 */
public class XC_IN079_ManageProductPrice {
	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN079_ManageProductPrice');
    
          /** 
       * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
       * @date 15/06/2021
       * @description Wrapper used by flow
       */
      public class InputWrapper{ 
            @Invocablevariable
            public String stepId; 
      }    
    
      private class UtilWrapper{
            String checkDifference = '';
            Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>();
      }
          /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021
      * @param inputWrapperList 
      **/
      @InvocableMethod
      public static void manageProductPriceInvoiceDeliveryPreference(List<InputWrapper> inputWrapperList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN079_ManageProductPrice');
            if(inputWrapperList.isEmpty()) {
                return;
            }
            List<String> listStepIds = new List<String>(); 
            for(InputWrapper inputWr : inputWrapperList){                
                  listStepIds.add(inputWr.stepId);
            } 
            List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>([SELECT Id, XC_LegalEntity__c,XC_Segment__c,   XC_Configuration_Item__r.XC_BillingProfileLineItem__c, XC_Configuration_Item__c, XC_ConfigurationId__c, XC_Status__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c, 
                                                                                          XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c, XC_Configuration_Item__r.NE__OrderId__r.XC_InvoiceDeliveryPreference__c, XC_Configuration_Item__r.NE__OrderId__c
                                                                                                  FROM XC_Provisioning_Step__c 
                                                                                                  WHERE Id IN: listStepIds]);
            if(stepList.isEmpty()){
                  return;
            }
            XC_Provisioning_Step__c step = stepList[0];
            String oiId = step.XC_Configuration_Item__c;
            String legalEntity = step.XC_LegalEntity__c;
            String segment = step.XC_Segment__c;
            
            Decimal valueToAdd = XC_IN078_ManageInvoiceType.getLegalEntityConfigurationInfo(legalEntity, segment);
            if(valueToAdd == null || valueToAdd == 0 ){
                  completeStep(step, Label.XC_CL_Step_Skipped, '');
                  return;
            }
            UtilWrapper wrapper =  getInfoFromOrderItemId(oiId); 
            String checkDifference = wrapper.checkDifference;  
            if(String.isEmpty(checkDifference)){
                  completeStep(step, Label.XC_CL_Step_Skipped, '');
                  return;    
            }    
            Map<Id, NE__OrderItem__c> orderItemMap = wrapper.orderItemMap;
            if(checkDifference == 'increase'){
                  updateConfigurationItemAndAsset(step, orderItemMap, valueToAdd);
            } else if(checkDifference == 'decrease') {
                  updateConfigurationItemAndAsset(step, orderItemMap, -valueToAdd);
            }
      }

            /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021
      * @param oiId 
      * @param bundleOiId 
      * @return Map<Id, NE__OrderItem__c> 
      **/
      private static UtilWrapper getInfoFromOrderItemId(String oiId){
            UtilWrapper wrapper = new UtilWrapper();
            String checkDifference = '';
            Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__OrderId__c, NE__OrderId__r.NE__Recurring_Charge_Total__c,
                                                                                    NE__OrderId__r.XC_InvoiceDeliveryPreference__c, 
                                                                                    (SELECT Id, XC_InvoiceDeliveryPreference__c,NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c FROM Assets__r) 
                                                                              FROM NE__OrderItem__c
                                                                              WHERE Id =: oiId ]); 
            List<NE__OrderItem__c> orderItemList = orderItemMap.values();
            if(!orderItemList.isEmpty() && !orderItemList[0].Assets__r.isEmpty()){
                  String invoiceDeliveryPrefOnAsset = orderItemList[0].Assets__r[0].XC_InvoiceDeliveryPreference__c;
                  String invoiceDeliveryPrefOnOrder = orderItemList[0].NE__OrderId__r.XC_InvoiceDeliveryPreference__c;
                  if(invoiceDeliveryPrefOnAsset == 'Print' && invoiceDeliveryPrefOnOrder == 'Email' ){
                        checkDifference = 'decrease';
                  } else if(invoiceDeliveryPrefOnAsset == 'Email' && invoiceDeliveryPrefOnOrder == 'Print'){
                        checkDifference = 'increase';
                  }
            }    
            wrapper.checkDifference = checkDifference;
            wrapper.orderItemMap = orderItemMap;
            return wrapper;                        
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021 
      * @param step 
      * @param orderItemsMap 
      * @param valueToAdd 
      **/
      private static void updateConfigurationItemAndAsset(XC_Provisioning_Step__c step, Map<Id, NE__OrderItem__c> orderItemsMap, Decimal valueToAdd){
            String invoiceDeliveryPreference = step.XC_Configuration_Item__r.NE__OrderId__r.XC_InvoiceDeliveryPreference__c;
            List<NE__OrderItem__c> oiListToUpdate = new List<NE__OrderItem__c>(); 
            List<NE__Order__c> orderList = new List<NE__Order__c>();
            List<Asset> assetList = new List<Asset>();
            NE__OrderItem__c orderItem = new NE__OrderItem__c();
            if(orderItemsMap.containsKey(step.XC_Configuration_Item__c)){
                  orderItem = orderItemsMap.get(step.XC_Configuration_Item__c);
                  orderItem.NE__BaseRecurringCharge__c += valueToAdd;
                  orderItem.NE__RecurringChargeOv__c += valueToAdd;
                  orderItem.NE__Action__c = 'Change';
                  oiListToUpdate.add(orderItem);
                  if( !orderItem.Assets__r.isEmpty() && orderItem.Assets__r[0].NE__BaseRecurringCharge__c != null && orderItem.Assets__r[0].NE__RecurringChargeOv__c != null){
                        Asset ast = new Asset (Id = orderItem.Assets__r[0].Id, NE__BaseRecurringCharge__c =  orderItem.Assets__r[0].NE__BaseRecurringCharge__c + valueToAdd, NE__RecurringChargeOv__c = orderItem.Assets__r[0].NE__RecurringChargeOv__c + valueToAdd, XC_InvoiceDeliveryPreference__c = invoiceDeliveryPreference);
                        assetList.add(ast);
                  }
            }
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(oiListToUpdate);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            String errorMessage = '';
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : dMLResult){
                  if(!wrapperResult.success){
                        errorMessage = 'Error in configuration item update: ' + wrapperResult.errorMessage;
                        break;
                  }
            }
            if(!String.isEmpty(errorMessage)){
                  completeStep(step, Label.XC_CL_Step_CompletedKO, errorMessage);
                  return;
            }
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            dMLResult = XC_UTIL_SObject.updateListRecords(assetList);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : dMLResult){
                  if(!wrapperResult.success){
                        errorMessage = 'Error in asset update: ' + wrapperResult.errorMessage;
                        break;
                  }
            }
            if(!String.isEmpty(errorMessage)){
                  completeStep(step, Label.XC_CL_Step_CompletedKO, errorMessage);
                  return;
            }
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c;
            String generateResult = B2WExtCat.WS_WorkOrders.generateWorkOrders(orderId);
            XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateResult, orderId, 'GenerateWorkOrder-XC_IN079_ManageProductPrice');
            completeStep(step, Label.XC_CL_Completed_Ok, '');
      }

    /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021 
      * @param step 
      * @param status 
      * @param errorMessage 
      **/
      private static void completeStep(XC_Provisioning_Step__c step, String status, String errorMessage) {
            step.XC_Status__c = status;
            step.XC_ErrorMessage__c = errorMessage;
            XC_UTIL_Sobject.updateRecord(step);
      }

}