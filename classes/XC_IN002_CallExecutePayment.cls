/**
*@author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
*@date Creation 20/12/2018
*@date Modification dd/mm/yyyy
*@description XC_IN002_CallExecutePayment – public class with invocable method. It is invoked by a Flow to call Execute Payment
*/
public without sharing class XC_IN002_CallExecutePayment {

    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN002_CallExecutePayment');
    /**
    *Update provisioning steps.
    *@description InputWrapper
    **/  
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;
    }

    /**
     *@description Call execute payment.
     *@param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void callExecutePayment(List<InputWrapper> inputWrapperList) { 
        List<XC_REST_CreatePayment_U.WrapperResponse> wrList = new List<XC_REST_CreatePayment_U.WrapperResponse>();
        List<XC_Provisioning_Step__c> provisioningStepsToComplete =  new List<XC_Provisioning_Step__c>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN002_CallExecutePayment.callExecutePayment');
        if(!inputWrapperList.isEmpty()){
            List<String> confItemListId = new List<String>();
            List<String> listStepIds = new List<String>();
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Configuration_Item__c 
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]); 
            for(Id stepId : mapSteps.keySet()){
                confItemListId.add(mapSteps.get(stepId).XC_Configuration_Item__c);
            } 

            Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id, XC_ZQuoteId__c, XC_PaymentType__c, NE__OrderItem__c.CurrencyIsoCode, NE__OneTimeFeeOv__c, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c,NE__RecurringChargeOv__c,
                    (SELECT Id,Name, NE__Value__c, XC_DeveloperName__c 
                    FROM NE__Order_Item_Attributes__r) 
                    FROM NE__OrderItem__c
                WHERE Id IN: confItemListId]);   
            
            Set<String> setPaymentMethodExtId = new Set<String>();
            for(NE__OrderItem__c confItem : configurationMap.values()){
                setPaymentMethodExtId.add(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c);
                //mapConfItemQuoteId.put(confItem.XC_ZQuoteId__c, confItem.Id);
            }

            Map<Id,Zuora__PaymentMethod__c> mapZuoraPaymentMethod = new Map<Id,Zuora__PaymentMethod__c>(
                [SELECT Id, Zuora__BillingAccount__r.Zuora__External_Id__c, Zuora__External_Id__c 
                FROM Zuora__PaymentMethod__c 
                WHERE Zuora__External_Id__c IN:setPaymentMethodExtId]); 
            Map<String,String> mapPaymentMethodExtIdAccountExtId = new Map<String,String>();
            for(Zuora__PaymentMethod__c zpm : mapZuoraPaymentMethod.values()){
                mapPaymentMethodExtIdAccountExtId.put(zpm.Zuora__External_Id__c, zpm.Zuora__BillingAccount__r.Zuora__External_Id__c);
            }

            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);
                XC_REST_CreatePayment_U.WrapperRequest wr = new XC_REST_CreatePayment_U.WrapperRequest();
                
                NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c);
                
                // electronic payment
                wr.gatewayId= '8adce4216653523401665d4dde742ec9';

                //************* cash payment ********* 
                callExecutePaymentHelper(confItem, wr);
                
                //************************************
                wr.currencyName = confItem.CurrencyIsoCode;
                wr.amount = confItem.NE__RecurringChargeOv__c;
                wr.paymentMethodId = confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c;
                if(mapPaymentMethodExtIdAccountExtId.containsKey(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c)){
                    wr.accountId = mapPaymentMethodExtIdAccountExtId.get(confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c);
                } 

                // COMPLETE STEP
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                provisioningStepsToComplete.add(step); 

                XC_REST_CreatePayment_U.WrapperResponse wrResponse = XC_REST_CreatePayment.createPayment(wr);
                wrList.add(wrResponse);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrResponse->' + wrResponse); 
            }
            if(!wrList.isEmpty()){
                updateProvisioningSteps(provisioningStepsToComplete);
                //System.enqueueJob(new ManageDMLQueuable(provisioningStepsToComplete)); 
            }
        } 
    }

    /**
    *@description Helper of callExecutePayment method
    *@param confItem
    *@param wr
    **/
    private static void callExecutePaymentHelper(NE__OrderItem__c confItem, XC_REST_CreatePayment_U.WrapperRequest wr){
        //************* cash payment *********************
        if(confItem.XC_PaymentType__c == Label.XC_CL_Credit_Card || confItem.XC_PaymentType__c== Label.XC_CL_DirectDebt ){
            wr.type = Label.XC_CL_PaymentType_Electronic;
        } else {
            wr.type = Label.XC_CL_PaymentType_External;    
        }

    }


    /**
    *Update provisioning steps.
    *@description Update provisioning steps
    *@param provisioningStepsToUpdate the provisioning steps to update
    **/
    public static void updateProvisioningSteps(List<XC_Provisioning_Step__c> provisioningStepsToUpdate){
        List<XC_UTIL_Sobject.WrapperResult> listDMLResult = XC_UTIL_Sobject.updateListRecords(provisioningStepsToUpdate);
    }
}