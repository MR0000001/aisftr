/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  15/06/2021
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN077_ChangeInvoiceDeliveryPreference - This class is called from the flow XC_FL_ChangeProvisioning_ChangeInvoiceDeliveryPreference
*/

public without sharing class XC_IN077_ChangeInvoiceDeliveryPreference {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN077_ChangeInvoiceDeliveryPreference');

    /**     
    * The Class InputWrapper.
    * @description InputWrapper
    */
    public class InputWrapper{ 
        @Invocablevariable     
        public String stepId;       
    }

     /**
    * @param inputWrapperList the list coming from flow
    * @description class to the the logic change invoice delivery preference 
    */
    @InvocableMethod 
    public static void changeInvoiceDeliveryPreference(List<InputWrapper> inputWrapperList) { 

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN077_ChangeInvoiceDeliveryPreference');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN077_ChangeInvoiceDeliveryPref_D.getMapSteps(listStepIds);
            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            String confItemId = step.XC_Configuration_Item__c;
            String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            NE__OrderItem__c item = XC_IN077_ChangeInvoiceDeliveryPref_D.getOrderItem(confItemId);
            Asset ass = item.Assets__r[0];

            if(ass == null){
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, 'Missing asset');
                return;
            }

            if(String.isBlank(ass.XC_InvoiceDeliveryPreference__c)){ // Skip step if it is an old account
                updateStepsStatus(step.Id, Label.XC_CL_Step_Skipped, '');
            }else {
                if(!String.isBlank(item.XC_BillingProfileLineItem__c)){
                    if(step.XC_Configuration_Item__r.NE__OrderId__r.XC_InvoiceDeliveryPreference__c != item.XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c){
                        // call zuora
                        manageCallZuoraAndUpdateObjects(item,step);
                    }else{ // Skip step if invoice delivery preference are equals 
                        updateStepsStatus(step.Id, Label.XC_CL_Step_Skipped, 'Same invoice delivery preference on order and billing profile line item'); 
                    }
                }else {
                    updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, 'Missing billing profile line item on order item');
                }
            }
        }
    }


    /**
    * @description method to manage call zuora and update objects 
    * @param item the order item 
    * @param step the step 
    * @param errorMessage the error message to set on the step
    */
    private static void manageCallZuoraAndUpdateObjects(NE__OrderItem__c item, XC_Provisioning_Step__c step){

        String deliveryPreference = step.XC_Configuration_Item__r.NE__OrderId__r.XC_InvoiceDeliveryPreference__c;
        Map<String,Object> bodyMap = new Map<String,Object>();

        if(!String.isblank(deliveryPreference)){ // change invoice deliveryPreference
            if(deliveryPreference.equalsIgnoreCase('Email')){
                bodyMap.put('invoiceDeliveryPrefsEmail',true);
                bodyMap.put('invoiceDeliveryPrefsPrint',false);
            }else if(deliveryPreference.equalsIgnoreCase('Print')){
                bodyMap.put('invoiceDeliveryPrefsEmail',false);
                bodyMap.put('invoiceDeliveryPrefsPrint',true);
            }else if (deliveryPreference.equalsIgnoreCase('Smart')){ // if is smart -> email = true
                bodyMap.put('invoiceDeliveryPrefsEmail',true);
                bodyMap.put('invoiceDeliveryPrefsPrint',false);
            }
        }else{
            updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, 'Blank Invoice Delivery Preference on Order');
            return;
        }

        if(!bodyMap.isEmpty()){

            bodyMap.put('legalEntity', step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c);
            bodyMap.put('stream', step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c);
            bodyMap.put('zuoraAccountId', item.XC_BillingProfileLineItem__r.XC_ZuoraId__c);

            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            ZuoraWebService.CreateZuoraAccountResponse result = XC_REST_UpdateZuoraAccount.updateZuoraAccount(bodyMap);
            manageZuoraResponse(result, item, step);
        }
    }

    
    /**
    * @description method to set provisioning step status   
    * @param stepId the step id
    * @param status the status to set on the step 
    * @param errorMessage the error message to set on the step
    */
    public static void updateStepsStatus(String stepId, String status, String errorMessage){
        
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c (Id = stepId, XC_Status__c = status);
        if(!String.isBlank(errorMessage)){
            step.XC_ErrorMessage__c = errorMessage;
        }        
        
        XC_UTIL_Sobject.updateRecord(step);

    }


     /**
    * @description method to manage the update zuora account response  
    * @param result the create account zuora response 
    * @param item the configuration item
    * @param step the provisioning step
    */
    public static void manageZuoraResponse(ZuoraWebService.CreateZuoraAccountResponse result, NE__OrderItem__c item, XC_Provisioning_Step__c step){

        List<XC_Integration_Log__c> integrationLogs = new List<XC_Integration_Log__c>();

        if(result!=null){
            
            if(result.integrationLog!=null){
                result.integrationLog.XC_Log_IntegrationName__c = 'ChangeInvoiceDeliveryPreference';
                result.integrationLog.XC_BillingProfileLineItem__c = item.XC_BillingProfileLineItem__c;
                integrationLogs.add(result.integrationLog);
            }

            if(!result.success.equalsIgnoreCase('true')){
                String errorMsg ='Error on Zuora: ';
                if(result.reasons != null){
                    for(ZuoraWebService.Reason errorRes : result.reasons){
                        errorMsg += errorRes.message + ' ';
                    }
                }
               
                updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, errorMsg); 
                if(!integrationLogs.isEmpty()){
                    XC_UTIL_Sobject.insertListRecords(integrationLogs);
                }else{
                    XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
                    XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
                    logWr.httpMethod = 'PUT'; 
                    logWr.logIsSuccess = false;
                    logWr.logIntegrationName = 'ChangeInvoiceDeliveryPreference';
                    logWr.logMessage = 'ChangeInvoiceDeliveryPreference';
                    logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
                    intLog.insertIntegReqOutboundLog(logWr);
                    intLog.insertIntegRespOutboundLog(false,'ERROR. Calling Zuora', '500', errorMsg);
                }
                return;
            }

            
            if(!integrationLogs.isEmpty()){
                XC_UTIL_Sobject.insertListRecords(integrationLogs);
            }

            
            // Update BPLI
            XC_BillingProfileLineItem__c bpliToUpdate = new XC_BillingProfileLineItem__c(Id = item.XC_BillingProfileLineItem__c, XC_InvoiceDeliveryPreference__c = item.NE__OrderId__r.XC_InvoiceDeliveryPreference__c); 
            XC_UTIL_Sobject.WrapperResult resultBpli = XC_UTIL_SObject.updateRecord(bpliToUpdate);
            if(!resultBpli.success){
                updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, 'INTERNAL ERROR: Update of invoice delivery preference on Billing Profile Line Item: '+ resultBpli.errorMessage); 
               return;
            }

            //Upadate BP
            String deliveryPreferenceForBP = (item.NE__OrderId__r.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Smart')) ? 'SmartInvoice' : item.NE__OrderId__r.XC_InvoiceDeliveryPreference__c;
            NE__Billing_Profile__c bpToUpdate = new NE__Billing_Profile__c(Id = item.XC_BillingProfileLineItem__r.XC_BillingProfile__c, XC_InvoiceDeliveryPref__c = deliveryPreferenceForBP);
            XC_UTIL_Sobject.WrapperResult resultBP = XC_UTIL_SObject.updateRecord(bpToUpdate);
            if(!resultBP.success){
                updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, 'INTERNAL ERROR: Update of invoice delivery preference on Billing Profile: '+ resultBP.errorMessage); 
               return;
            }

            updateStepsStatus(step.id, Label.XC_CL_Completed_Ok, ''); 

        }else{
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
            XC_UTIL_IntegrationLog.LogWrapper  logWr = new XC_UTIL_IntegrationLog.LogWrapper();
            logWr.httpMethod = 'POST'; 
            logWr.logIsSuccess = false;
            logWr.logIntegrationName = 'ChangeInvoiceDeliveryPreference';
            logWr.logMessage = 'ChangeInvoiceDeliveryPreference';
            logWr.orderID = step.XC_Configuration_Item__r.NE__OrderId__c;
            intLog.insertIntegReqOutboundLog(logWr);
            intLog.insertIntegRespOutboundLog(false,'ERROR. Calling Zuora', '500', 'Response NULL of the UpdateZuoraAccount API - ChangeInvoiceDeliveryPreference');
            updateStepsStatus(step.id, Label.XC_CL_Step_CompletedKO, 'Response NULL of the UpdateZuoraAccount API - ChangeInvoiceDeliveryPreference'); 
        }
    }
}