/**
* @author Giovanni Schioppa giovanni.schioppa@nttdata.com
* @date Creation 07/01/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to check the Credit Card Pre Authorization
*/ 
public without sharing class XC_IN003_CreditCardPreAuthorization {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN003_CreditCardPreAuthorization');
    public static Boolean getKOInTest = false;
    /**
     * @description InputWrapper the input wrapper list
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;      
    }
    /**
     * @description Credit card pre authorization.
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod
    public static void creditCardPreAuthorization(List<InputWrapper> inputWrapperList) {
        List<Id> stepIdToComplete = new List<Id>();
        List<Id> stepIdToSetKO = new List<Id>();
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
                SELECT Id, NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c
                FROM NE__OrderItem__c
                WHERE Id IN: confItemListId]);  
            
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);
                XC_REST_VerifyPaymentMethods.WrapperRequest wrReq = new XC_REST_VerifyPaymentMethods.WrapperRequest(); 
                XC_REST_VerifyPaymentMethods.GatewayOptions wrOpt = new XC_REST_VerifyPaymentMethods.GatewayOptions();
                
                NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c); 
                //wrOpt.gatewayId= '8adce4216653523401665d4dde742ec9';   
                wrReq.securityCode = confItem.NE__BillingProfId__r.NE__Security_Code__c;
                wrReq.gatewayOptions = wrOpt;
                String paymentMethodId = confItem.NE__BillingProfId__r.B2WZC__Zuora_MethodPaymentId__c;
 
                XC_REST_VerifyPaymentMethods.WrapperResponse wrapperResult = XC_REST_VerifyPaymentMethods.verifyPaymentMethod(paymentMethodId,wrReq);
                if(!wrapperResult.success || (getKOInTest && Test.isRunningTest())){
                    stepIdToSetKO.add(inputWr.stepId);  
                } else if(wrapperResult.success){ 
                    stepIdToComplete.add(inputWr.stepId);  
                }               
            }
            // Set the step in OK or KO
            stepToKOorOK(stepIdToComplete,stepIdToSetKO); 
        }
    }
    /**
     * @description Method to complete provisioning steps
     * @param stepIdToComplete
     * @param stepIdToSetKO
     */
    private static void stepToKOorOK(List<Id> stepIdToComplete, List<Id> stepIdToSetKO) {
        if(!stepIdToComplete.isEmpty()){
            List<XC_Provisioning_Step__c> stepToCompleteList = new List<XC_Provisioning_Step__c>();
            for(String stepId : stepIdToComplete){
                XC_Provisioning_Step__c stepToComplete = new XC_Provisioning_Step__c(Id =stepId);
                stepToComplete.XC_status__c = Label.XC_CL_Completed_OK;
                stepToCompleteList.add(stepToComplete);
            }
            XC_UTIL_Sobject.updateListRecords(stepToCompleteList);
        } 
        if(!stepIdToSetKO.isEmpty()){
            List<XC_Provisioning_Step__c> stepToCompleteKOList = new List<XC_Provisioning_Step__c>();
            for(String stepId : stepIdToSetKO){
                XC_Provisioning_Step__c stepToComplete = new XC_Provisioning_Step__c(Id =stepId);
                stepToComplete.XC_status__c = Label.XC_CL_Step_CompletedKO;
                stepToCompleteKOList.add(stepToComplete);
            }
            XC_UTIL_Sobject.updateListRecords(stepToCompleteKOList);         
        }
    }
}