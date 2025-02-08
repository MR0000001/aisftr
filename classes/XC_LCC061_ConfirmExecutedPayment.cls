/**
 * The Class XC_LCC061_ConfirmExecutedPayment.
 *
 * @author Fabrizio Antonioli - fabrizio.antonioli@nttdata.com & Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 21/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_LCC061_ConfirmExecutedPayment – Controller for XC_LCP061_ConfirmExecutedPayment Component
 */
public without sharing class XC_LCC061_ConfirmExecutedPayment {
    
    /**
     * @description The Class resultWrapper.
     */
    public class resultWrapper {
        
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String  message; 
    }
    
    /**
     * @description Confirm executed payment.
     *
     * @param recordId the record id
     * @return the result wrapper
     */
    @AuraEnabled
    public static resultWrapper confirmExecutedPayment (Id recordId){
        Boolean checkStep;
        resultWrapper rw = new resultWrapper(); 
        Map<Id,XC_Provisioning_Step__c> listStepsMap = new Map<Id,XC_Provisioning_Step__c>([SELECT ID,XC_Flow_API_Name__c, XC_Configuration_Item__c 
                FROM XC_Provisioning_Step__c 
                WHERE Id =: recordId]);

        List<XC_Provisioning_Step__c> listSteps = listStepsMap.values();


        if (listSteps[0].XC_Flow_API_Name__c == Label.XC_CL_ProvisioningExecutePayment_Flow){ 
            checkStep = true;
            String confItemId = listSteps[0].XC_Configuration_Item__c;
            Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>(
                [SELECT Id,NE__Account__c,XC_PaymentMethod__c,
                    (SELECT Id,Name, NE__Value__c, XC_DeveloperName__c FROM NE__Order_Item_Attributes__r) 
                FROM NE__OrderItem__c
                WHERE Id =: confItemId]); 

            NE__OrderItem__c confItem = configurationMap.get(confItemId);
            if(confItem.XC_PaymentMethod__c == Label.XC_CL_Credit_Card || confItem.XC_PaymentMethod__c  == Label.XC_CL_DirectDebt){
                checkStep = false;
                rw.success = false;
                rw.message = Label.XC_CL_ConfirmPaymentTypeError;
                return rw;                 
            }
            /*for(NE__Order_Item_Attribute__c orItemAttribute : confItem.NE__Order_Item_Attributes__r){
                if(orItemAttribute.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_PaymentType){
                    if(orItemAttribute.NE__Value__c == Label.XC_CL_Credit_Card || orItemAttribute.NE__Value__c == Label.XC_CL_DirectDebt){ 
                        checkStep = false;
                        rw.success = false;
                        rw.message = Label.XC_CL_ConfirmPaymentTypeError;
                        return rw;     
                    }
                } 
            } */           
        } else {
            checkStep = false; 
            rw.success = false;
            rw.message = Label.XC_CL_StepNotCorrect;                
        }      

        if(checkStep == true){        
            XC_Provisioning_Step__c step = listSteps[0];
            step.XC_Status__c = Label.XC_CL_Completed_OK;
            XC_UTIL_SObject.WrapperResult updateResult = XC_UTIL_SObject.updateRecord(step);
            
            if(!updateResult.success){
                rw.success = updateResult.success;
                rw.message = updateResult.errorMessage; 
            } else {
                rw.success = true;
                rw.message = Label.XC_CL_StepCompleted;
            }
            return rw;
        } else {
            return rw;
        }
    }
}