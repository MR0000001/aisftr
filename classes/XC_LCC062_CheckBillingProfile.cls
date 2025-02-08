/**
 * The Class XC_LCC062_CheckBillingProfile.
 *
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 28/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_LCC062_CheckBillingProfile – Controller for XC_LCP062_CheckBillingProfile Component
 */
public without sharing class XC_LCC062_CheckBillingProfile {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC062_CheckBillingProfile');
    /**
     * @description The Class resultWrapper.
     */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String  message; 
    }
    
    /**
     * @description Check billing profile.
     *
     * @param recordId the record id
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper checkBillingProfile (Id recordId){
        ResultWrapper rw = new ResultWrapper(); 
        Map<Id,XC_Provisioning_Step__c> listStepsMap = new Map<Id,XC_Provisioning_Step__c>([SELECT ID,XC_Flow_API_Name__c, XC_Configuration_Item__c 
                FROM XC_Provisioning_Step__c 
                WHERE Id =: recordId]);

        List<XC_Provisioning_Step__c> listSteps = listStepsMap.values();

        if(listSteps[0].XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCheckPaymentMethod_Flow){
            String confItemId = listSteps[0].XC_Configuration_Item__c;
            Map<Id, NE__OrderItem__c> configurationMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id,XC_BillingProfileLineItem__c
                FROM NE__OrderItem__c
                WHERE Id =: confItemId
            ]); 

            NE__OrderItem__c confItem = configurationMap.get(confItemId);  
            if(confItem.XC_BillingProfileLineItem__c == null){ 
                rw.success = false;
                rw.message = Label.XC_CL_CheckBillingProfileError; 
            }/* else {
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
            }*/
        } else { 
            rw.success = false;
            rw.message = Label.XC_CL_StepNotCorrect;                
        } 
        return rw;
    }
}