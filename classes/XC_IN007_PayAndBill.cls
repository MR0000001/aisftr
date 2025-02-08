/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com / Giovanni Schioppa giovanni.schioppa@nttdata.com
* @date Creation 05/02/2019
* @date Modification 20/03/2020 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Modification 23/03/2020 by Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @description  – .
*/ 
public without sharing class XC_IN007_PayAndBill {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN007_PayAndBill');


    /**
     * @description InputWrapper
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;  
        @Invocablevariable
        public String confItemIdInInputId;
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param inputWrapperList the list coming from flow
     * @description Method to do the logic required for Pay And Bill.
     */   
    @InvocableMethod 
    public static void payAndBill(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN007_PayAndBill');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible() && Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            List<String> confItemListId = new List<String>();
            List<String> listStepIds = new List<String>();
            List<String> confItemIdInInputIdList = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
                if(!String.isEmpty(inputWr.confItemIdInInputId)){
                    confItemIdInInputIdList.add(inputWr.confItemIdInInputId);
                }
            }
  
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c 
                                                                                                FROM XC_Provisioning_Step__c 
                                                                                                WHERE Id IN: listStepIds]); 
            
            if(checkIfItalyAndMixedVAT(mapSteps)){
                return;
            }
            
            if(confItemIdInInputIdList.isEmpty()){
                confItemListId = populateConfItemList(mapSteps);
            } else {
                confItemListId.addAll(confItemIdInInputIdList);
            }

			// Modified by Danilo Ortolani 20/02/2019
			// Added field: NE__BillingProfId__r.Zuora_Account_Id__c
            Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,
                                                                                            NE__BillingProfId__r.Zuora_Account_Id__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,
                                                                                            XC_ZQuoteId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_eMobTransactionId__c
                                                                                        FROM NE__OrderItem__c
                                                                                        WHERE Id IN: confItemListId]); 

            //Set<String> setPaymentMethodExtId = new Set<String>();
            Map<Id,String> mapConfItemZQuoteId = new Map<Id,String>();
            Map<String,String> mapConfItemIdZuoraSubscription = new Map<String,String>();

            mapConfItemZQuoteId = populateMapConfItemZQuoteMap(configurationMap);
            
            Map<Id,zqu__Quote__c> mapZuoraQuote = new Map<Id,zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c
                                                                                FROM zqu__Quote__c
                                                                                WHERE Id IN: mapConfItemZQuoteId.keyset()]);

            for(zqu__Quote__c quote : mapZuoraQuote.values()){
                mapConfItemIdZuoraSubscription.put(mapConfItemZQuoteId.get(quote.Id), (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c);
            }

            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step -> ' + step);
                NE__OrderItem__c confItem = new NE__OrderItem__c();
                if(configurationMap.containsKey(step.XC_Configuration_Item__c)){
                    confItem = configurationMap.get(step.XC_Configuration_Item__c);
                } else {
                    confItem = configurationMap.values()[0];
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'confItem -> ' + confItem);

                XC_REST_PayAndBill.WrapperRequest wrapperPayAndBill = new XC_REST_PayAndBill.WrapperRequest();
                wrapperPayAndBill.SubscriptionId = mapConfItemIdZuoraSubscription.get(confItem.Id);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'SubscriptionId -> ' + wrapperPayAndBill.SubscriptionId);
                wrapperPayAndBill.PrepaidAmount = confItem.NE__OneTimeFeeOv__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'PrepaidAmount -> ' + wrapperPayAndBill.PrepaidAmount);

                // Insert by Danilo Ortolani 20/02/2019
                if(confItem.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c != null){
                    wrapperPayAndBill.accountId = confItem.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
                } else if(confItem.NE__BillingProfId__r.Zuora_Account_Id__c != null){
                    wrapperPayAndBill.accountId = confItem.NE__BillingProfId__r.Zuora_Account_Id__c;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'accountId->' + wrapperPayAndBill.accountId);

                wrapperPayAndBill.legalEntity = confItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
                wrapperPayAndBill.stream = confItem.NE__OrderId__r.XC_Segment__c;
                wrapperPayAndBill.transactionID = confItem.NE__OrderId__r.XC_eMobTransactionId__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'legalEntity-->' + wrapperPayAndBill.legalEntity);

                callZuoraAndSetStepStatus(JSON.serialize(wrapperPayAndBill), JSON.serialize(step));           
            }
        } 
    }


    /**
    * @description check If Italy legal entity and Mixed VAT
    * @author salvatore.scarpato@nttdata.com | 30/3/2020 
    * @return Boolean 
    **/
    private static Boolean checkIfItalyAndMixedVAT(Map<Id, XC_Provisioning_Step__c> mapSteps){
        Set<String> stepIdsItalySet = new Set<String>();
        Boolean toBeSkipped = false;
        for(Id stepId : mapSteps.keySet()){
            if(mapSteps.get(stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || mapSteps.get(stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia){
                stepIdsItalySet.add(stepId);
            }    
        }
        if(!stepIdsItalySet.isEmpty()){
            List<XC_Provisioning_Step__c> provisioningStepToBeSkippedList = new List<XC_Provisioning_Step__c>();
            Map<Id,Boolean> stepIdCheckMap = XC_IN050_ManageMixedVATWF.checkMixedVAT(stepIdsItalySet);
            for(Id stepId : mapSteps.keySet()){
                if(stepIdCheckMap.containsKey(stepId) && stepIdCheckMap.get(stepId)){
                    skipStep(mapSteps.get(stepId), provisioningStepToBeSkippedList) ;
                }
            }
            if(!provisioningStepToBeSkippedList.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(provisioningStepToBeSkippedList);
                toBeSkipped = true;                    
            } 
        }
        return toBeSkipped;
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param wrapperPayAndBillSerialize the wrapperPayAndBill serialized
     * @param stepSerialize the step serialized
     * @description Method to do the logic required for Pay And Bill.
     */   
    @future (callout=true)
    public static void callZuoraAndSetStepStatus(String wrapperPayAndBillSerialize, String stepSerialize) { 

        XC_REST_PayAndBill.WrapperRequest wrapperPayAndBill = (XC_REST_PayAndBill.WrapperRequest) JSON.deserialize(wrapperPayAndBillSerialize, XC_REST_PayAndBill.WrapperRequest.class);
        XC_Provisioning_Step__c step = (XC_Provisioning_Step__c) JSON.deserialize(stepSerialize, XC_Provisioning_Step__c.class);

        XC_REST_PayAndBill.WrapperResponse wrResponse = XC_REST_PayAndBill.createPayAndBill(wrapperPayAndBill);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '[PayAndBill] wrResponse -> ' + wrResponse); 

        setStepStatus(wrResponse, step);
        XC_UTIL_Sobject.updateRecord(step);
    }

     
    /**
    * Set step status.
    * @param wrResponse the PayAndBill wrapper response
    * @param step the provisioning step to update
    * @description Method to set step status
    */
    private static void setStepStatus(XC_REST_PayAndBill.WrapperResponse wrResponse, XC_Provisioning_Step__c step){
        if(wrResponse.errors != null && !(wrResponse.errors).isEmpty()){
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = wrResponse.errors[0].title;
        }else {
            // COMPLETE STEP
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        }
    }


    /**
    * @param step the provisioning step to update
    * @description Set the step in skipped
    */
    private static void skipStep(XC_Provisioning_Step__c step, List<XC_Provisioning_Step__c> provisioningStepToBeSkippedList){
        step.XC_Status__c = Label.XC_CL_Step_Skipped;
        provisioningStepToBeSkippedList.add(step);
    }


    private static List<String> populateConfItemList(Map<Id, XC_Provisioning_Step__c> mapSteps){
        List<String> confItemListId = new List<String>();
        for(Id stepId : mapSteps.keySet()){
            confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
        }
        return confItemListId;
    }


    private static Map<Id,String> populateMapConfItemZQuoteMap(Map<Id, NE__OrderItem__c> configurationMap){
        Map<Id,String> mapConfItemZQuoteId = new Map<Id,String>();
        for(NE__OrderItem__c confItem : configurationMap.values()){
            mapConfItemZQuoteId.put(confItem.XC_ZQuoteId__c, confItem.Id);
        }
        return mapConfItemZQuoteId;
    }
}