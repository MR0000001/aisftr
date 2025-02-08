/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 20/02/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to check the Pre Authorization
*/ 
public without sharing class XC_IN010_PreAuthorization {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN010_PreAuthorization');

    /**
    * @description InputWrapper the input wrapper 
    **/
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }

    /**
    * @description UtilWrapper a util wrapper
    **/
    private class UtilWrapper{
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>();
        Map<Id, Zuora__CustomerAccount__c> zuoraCustomerAccountMap = new Map<Id, Zuora__CustomerAccount__c>();
        Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>();
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @date Creation 20/02/2019
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of pre authotitation
     */
    @InvocableMethod 
    public static void payAndBill(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN010_PreAuthorization');
        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>();
            List<String> stepIdToComplete = new List<String>();
            List<String> stepIdToSetKO = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            UtilWrapper wrapper = payAndBillUtil(listStepIds);
            Map<Id, XC_Provisioning_Step__c> mapSteps = wrapper.mapSteps;
            Map<Id, Zuora__CustomerAccount__c> zuoraCustomerAccountMap = wrapper.zuoraCustomerAccountMap;
            Map<Id, NE__OrderItem__c> configurationMap = wrapper.configurationMap;
            Map<String,String> mapPaymentMethodExtIdAccountExtId = new Map<String,String>();
            Map<String,String> mapPaymentMethodExtIdAccountNumber = new Map<String,String>();
            for(Zuora__CustomerAccount__c zca : zuoraCustomerAccountMap.values()){
                mapPaymentMethodExtIdAccountExtId.put(zca.Zuora__Default_Payment_Method__r.Zuora__External_Id__c, zca.Zuora__Default_Payment_Method__r.Zuora__BillingAccount__r.Zuora__External_Id__c);
                mapPaymentMethodExtIdAccountNumber.put(zca.Zuora__Default_Payment_Method__r.Zuora__External_Id__c,zca.Zuora__AccountNumber__c );
            }
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);
                XC_REST_CreateAuthorization.WrapperRequest wr = new XC_REST_CreateAuthorization.WrapperRequest();
                if(mapPaymentMethodExtIdAccountExtId.containsKey(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c)){       
                    wr.accountId = mapPaymentMethodExtIdAccountExtId.get(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c);       
                } 
                if(mapPaymentMethodExtIdAccountNumber.containsKey(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c)){
                    wr.accountNumber = mapPaymentMethodExtIdAccountNumber.get(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c);
                }
                wr.amount = confItem.NE__OneTimeFeeOv__c;
                wr.gatewayOrderId = 'A001';
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### Wrapper of Pre-Authorizathion --->' + wr);
                String paymentMethodId = confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c;
                XC_REST_CreateAuthorization.WrapperResponse resp = XC_REST_CreateAuthorization.createAuthorization(paymentMethodId, wr);       
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrResponse 010->' + resp);

                if(resp.success){           
                    stepIdToComplete.add(inputWr.stepId);  
                } else { 
                    stepIdToSetKO.add(inputWr.stepId);     
                }  
            }
            stepToKOorOK(stepIdToComplete, stepIdToSetKO);
        } 
    }
    
    /**
     * @description Method to complete provisioning steps
     * @param stepIdToComplete
     * @param stepIdToSetKO
     */
    private static void stepToKOorOK(List<String> stepIdToComplete, List<String> stepIdToSetKO) {

        if(!stepIdToComplete.isEmpty() && stepIdToComplete != null){
            List<XC_Provisioning_Step__c> stepToComplete = new List<XC_Provisioning_Step__c>();
            for(String stepId : stepIdToComplete){
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id =stepId);
                step.XC_status__c = Label.XC_CL_Completed_OK;
                stepToComplete.add(step);
            }
            XC_UTIL_Sobject.updateListRecords(stepToComplete);
                
        }
        if(!stepIdToSetKO.isEmpty() && stepIdToSetKO != null){
            List<XC_Provisioning_Step__c> stepToCompleteKO = new List<XC_Provisioning_Step__c>();
            for(String stepId : stepIdToSetKO){
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id =stepId);
                step.XC_status__c = Label.XC_CL_Step_CompletedKO;
                stepToCompleteKO.add(step);
            }                                
            XC_UTIL_Sobject.updateListRecords(stepToCompleteKO);
        }
    }

    /**
    * @description an util mathod for payAndBillUtil
    * @param listStepIds
    * @return UtilWrapper
    **/
    private static UtilWrapper payAndBillUtil(List<String> listStepIds){
        List<String> confItemListId = new List<String>();
        UtilWrapper wrapper = new UtilWrapper();
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Configuration_Item__c 
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]); 
        for(Id stepId : mapSteps.keySet()){
            confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
        } 

        Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>([
            SELECT Id, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,
                XC_ZQuoteId__c,
                (SELECT Id,Name, NE__Value__c 
                FROM NE__Order_Item_Attributes__r) 
                FROM NE__OrderItem__c
            WHERE Id IN: confItemListId]);  

        Set<String> setPaymentMethodExtId = new Set<String>();

        for(NE__OrderItem__c confItem : configurationMap.values()){
            setPaymentMethodExtId.add(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c);
        }

        //OK
        Map<Id, Zuora__CustomerAccount__c> zuoraCustomerAccountMap = new Map<Id, Zuora__CustomerAccount__c>(
            [SELECT id, Zuora__AccountNumber__c, Zuora__Default_Payment_Method__r.Zuora__BillingAccount__r.Zuora__External_Id__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c
            FROM Zuora__CustomerAccount__c 
            WHERE Zuora__Default_Payment_Method__r.Zuora__External_Id__c IN: setPaymentMethodExtId]
        ); 
        wrapper.mapSteps = mapSteps;
        wrapper.zuoraCustomerAccountMap = zuoraCustomerAccountMap;
        wrapper.configurationMap = configurationMap;

        return wrapper;
    }
}