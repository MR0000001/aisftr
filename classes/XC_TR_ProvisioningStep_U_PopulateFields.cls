/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 07/12/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ProvisioningStep_U_PopulateFields – Class to populate fields on insert
 */

public without sharing class XC_TR_ProvisioningStep_U_PopulateFields {

     /**
     * @description populate Master Of Create Subscription
     * @param mapOli map of steps
     */
     public static void populateMasterOfSubscription(Map<Id, XC_Provisioning_Step__c> mapOld, Map<Id, XC_Provisioning_Step__c> mapNew){
          List<String> fieldList = new List<String>{'XC_MasterOfSubscription__c'};
          List<XC_Provisioning_Step__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
          List<String> orderItemList = new List<String>();
          for(XC_Provisioning_Step__c step : listChanged){
               if(!step.XC_MasterOfSubscription__c && (step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningCreateSubscription_Flow || step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningTriggerInvoice_Flow || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningChangeBilling_Flow || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningTriggerInvoiceBarcode_Flow)){
                    orderItemList.add(step.XC_Configuration_Item__c);
               }
          }
          if(!orderItemList.isEmpty()){
               List<XC_Provisioning_Step__c> allStepsList = new List<XC_Provisioning_Step__c>([SELECT Id, XC_MasterOfSubscription__c
                                                                                               FROM XC_Provisioning_Step__c 
                                                                                               WHERE XC_Configuration_Item__c IN: orderItemList
                                                                                               AND XC_MasterOfSubscription__c = true ]);
               for(XC_Provisioning_Step__c step : allStepsList){
                    step.XC_MasterOfSubscription__c = false;
               }
               XC_UTIL_Sobject.updateListRecords(allStepsList);
          }
     }
}