/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 15/06/2021
 * @description  – public class with invocable method. It is invoked by a flow related to the step "Manage Invoice Type"
 */
public without sharing class XC_IN078_ManageInvoiceType {
      private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN078_ManageInvoiceType');

      /** 
       * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
       * @date 15/06/2021
       * @description Wrapper used by flow
       */
      public class InputWrapper{ 
            @Invocablevariable
            public String stepId; 
      }    

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021
      * @param inputWrapperList 
      **/
      @InvocableMethod
      public static void manageInvoiceType(List<InputWrapper> inputWrapperList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN078_ManageInvoiceType');
            if(inputWrapperList.isEmpty()) {
                return;
            }
            List<String> listStepIds = new List<String>(); 
            for(InputWrapper inputWr : inputWrapperList){                
                  listStepIds.add(inputWr.stepId);
            } 
            List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>([SELECT Id, XC_LegalEntity__c,XC_Segment__c,   XC_Configuration_Item__r.XC_BillingProfileLineItem__c, XC_Configuration_Item__c, XC_ConfigurationId__c, XC_Status__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c
                                                                                                  FROM XC_Provisioning_Step__c 
                                                                                                  WHERE Id IN: listStepIds]);
            if(stepList.isEmpty()){
                  return;
            }
            XC_Provisioning_Step__c step = stepList[0];
            String oiId = step.XC_Configuration_Item__c;
            String bundleOiId = step.XC_Configuration_Item__r.NE__Bundle_Configuration__c;
            String invoiceDeliveryPreference = '';
            if(!String.isEmpty(step.XC_Configuration_Item__r.XC_BillingProfileLineItem__c)){
                  invoiceDeliveryPreference = step.XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c;
            }
            String legalEntity = step.XC_LegalEntity__c;
            String segment = step.XC_Segment__c;
            Decimal valueToAdd = getLegalEntityConfigurationInfo(legalEntity, segment);
            if(valueToAdd == null || valueToAdd == 0 ){
                  completeStep(step, Label.XC_CL_Step_Skipped, '');
                  return;
            }
            Map<Id, NE__OrderItem__c> orderItemsMap =  getInfoFromOrderItemId(oiId, bundleOiId);
            List<Asset> assetList = retrieveAllAsset(orderItemsMap.keySet());
            Boolean successOnFirstUpdate = updateInvoiceDeliveryPreferenceOnAsset(step, invoiceDeliveryPreference, assetList);
            if(invoiceDeliveryPreference != 'Print' && successOnFirstUpdate){
                  completeStep(step, Label.XC_CL_Completed_Ok, '');
                  return;
            }
            Boolean success = updateAsset(step, invoiceDeliveryPreference, assetList, valueToAdd);
            if(!success){
                  return;
            }
            updateConfigurationAndConfigurationItem(step, orderItemsMap, valueToAdd);
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021
      * @param oiId 
      * @param bundleOiId 
      * @return Map<Id, NE__OrderItem__c> 
      **/
      private static Map<Id, NE__OrderItem__c> getInfoFromOrderItemId(String oiId, String bundleOiId){
            Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>();
            if(!String.isEmpty(bundleOiId)){
                  orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__OrderId__c, NE__OrderId__r.NE__Recurring_Charge_Total__c
                                                                              FROM NE__OrderItem__c
                                                                              WHERE NE__Bundle_Configuration__c =: bundleOiId OR Id =: bundleOiId]);
            } else {
                  orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c, NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c, NE__OrderId__c, NE__OrderId__r.NE__Recurring_Charge_Total__c
                                                                              FROM NE__OrderItem__c
                                                                              WHERE Id =: oiId ]);       
            }
            return orderItemMap;                        
      }
      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021 
      * @param oiIdSet 
      * @return List<Asset> 
      **/
      private static List<Asset> retrieveAllAsset(Set<Id> oiIdSet){
            List<Asset> assetList = new List<Asset>([SELECT Id,XC_Configuration_Item__c, XC_Configuration_Item__r.NE__BaseRecurringCharge__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c,
                                                                        NE__Order_Config__c, NE__Order_Config__r.NE__Recurring_Charge_Total__c, NE__BaseRecurringCharge__c, NE__RecurringChargeOv__c
                                                                        FROM Asset 
                                                                        WHERE XC_Configuration_Item__c IN: oiIdSet]);
            return assetList;            
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021
      * @param legalEntity 
      * @param segment 
      * @return Decimal 
      **/
      public static Decimal getLegalEntityConfigurationInfo(String legalEntity, String segment){
            Decimal valueToAdd = 0;
            List<XC_CM_LegalEntity_Configuration__mdt> legalEntityConfigCMDT = new List<XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_PaperInvoicePrice__c
                                                                                                                              FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                              WHERE XC_LegalEntity__c =: legalEntity AND XC_Stream__c  =: segment AND XC_PaperInvoicePrice__c != null]);
            if(!legalEntityConfigCMDT.isEmpty() && legalEntityConfigCMDT[0].XC_PaperInvoicePrice__c != null && legalEntityConfigCMDT[0].XC_PaperInvoicePrice__c != 0){
                  valueToAdd = legalEntityConfigCMDT[0].XC_PaperInvoicePrice__c;
            }
            return valueToAdd;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021 
      * @param step 
      * @param invoiceDeliveryPreference 
      * @param assetList 
      * @return Boolean 
      **/
      private static Boolean updateAsset(XC_Provisioning_Step__c step, String invoiceDeliveryPreference, List<Asset> assetList, Decimal valueToAdd ){
            for(Asset ast : assetList){
                  if(ast.NE__BaseRecurringCharge__c != null && ast.NE__RecurringChargeOv__c != null){
                        ast.NE__BaseRecurringCharge__c = ast.NE__BaseRecurringCharge__c + valueToAdd;
                        ast.NE__RecurringChargeOv__c = ast.NE__RecurringChargeOv__c + valueToAdd;
                  }
            }
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(assetList);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            String errorMessage = '';
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : dMLResult){
                  if(!wrapperResult.success){
                        errorMessage = 'Error in asset update: ' + wrapperResult.errorMessage;
                        break;
                  }
            }
            if(!String.isEmpty(errorMessage)){
                  completeStep(step, Label.XC_CL_Step_CompletedKO, errorMessage);
                  return false;
            }
            return true;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 06-15-2021 
      * @param step 
      * @param orderItemsMap 
      * @param valueToAdd 
      **/
      private static void updateConfigurationAndConfigurationItem(XC_Provisioning_Step__c step, Map<Id, NE__OrderItem__c> orderItemsMap, Decimal valueToAdd){
            List<NE__OrderItem__c> oiListToUpdate = new List<NE__OrderItem__c>(); 
            List<NE__Order__c> orderList = new List<NE__Order__c>();
            NE__OrderItem__c orderItem = new NE__OrderItem__c();
            if(orderItemsMap.containsKey(step.XC_Configuration_Item__c)){
                  orderItem = orderItemsMap.get(step.XC_Configuration_Item__c);
                  orderItem.NE__BaseRecurringCharge__c += valueToAdd;
                  orderItem.NE__RecurringChargeOv__c += valueToAdd;
                  oiListToUpdate.add(orderItem);
                  if(!String.isEmpty(orderItem.NE__Bundle_Configuration__c) && orderItem.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c != null){
                        NE__OrderItem__c bundleOi = new NE__OrderItem__c(Id = orderItem.NE__Bundle_Configuration__c,
                              XC_BundleTotalOTAmount__c = orderItem.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c + valueToAdd);
                        oiListToUpdate.add(bundleOi);
                  }
                  if(!String.isEmpty(orderItem.NE__OrderId__c) && orderItem.NE__OrderId__r.NE__Recurring_Charge_Total__c != null){
                        orderList.add(new NE__Order__c(Id = orderItem.NE__OrderId__c, NE__Recurring_Charge_Total__c = orderItem.NE__OrderId__r.NE__Recurring_Charge_Total__c + valueToAdd));
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
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            dMLResult = XC_UTIL_SObject.updateListRecords(orderList);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : dMLResult){
                  if(!wrapperResult.success){
                        errorMessage = 'Error in configuration update: ' + wrapperResult.errorMessage;
                        break;
                  }
            }
            if(!String.isEmpty(errorMessage)){
                  completeStep(step, Label.XC_CL_Step_CompletedKO, errorMessage);
                  return;
            }
            completeStep(step, Label.XC_CL_Completed_Ok, '');
      }


            /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 15/06/2021 
      * @param step 
      * @param invoiceDeliveryPreference 
      * @param assetList 
      * @return Boolean 
      **/
      private static Boolean updateInvoiceDeliveryPreferenceOnAsset(XC_Provisioning_Step__c step, String invoiceDeliveryPreference, List<Asset> assetList ){
            for(Asset ast : assetList){
                  ast.XC_InvoiceDeliveryPreference__c = invoiceDeliveryPreference;
            }
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(assetList);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Asset_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            String errorMessage = '';
            for(XC_UTIL_Sobject.WrapperResult wrapperResult : dMLResult){
                  if(!wrapperResult.success){
                        errorMessage = 'Error in asset update: ' + wrapperResult.errorMessage;
                        break;
                  }
            }
            if(!String.isEmpty(errorMessage)){
                  completeStep(step, Label.XC_CL_Step_CompletedKO, errorMessage);
                  return false;
            }
            return true;
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