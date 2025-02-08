/**
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  30/04/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN051_BillingDisconnectionProcess - This class is called from the flow XC_FL_Deprovisioning_WithdrawalBillingProcess
*/

public without sharing class XC_IN051_BillingDisconnectionProcess {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN051_BillingDisconnectionProcess');


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
    * @description class to the the logic of billing  disconnection process
    */
    @InvocableMethod 
    public static void billingDisconnectionProcess(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN051_BillingDisconnectionProcess');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            String subscriptionId = '';
            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN051_BillingDisconnectionProcess_D.getMapSteps(listStepIds);
            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            String confItemId = step.XC_Configuration_Item__c;
            String legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
            String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;

            NE__OrderItem__c item = XC_IN051_BillingDisconnectionProcess_D.getOrderItem(confItemId);
            Asset a = item.Assets__r[0];
            
            if(String.isNotBlank(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {
                zqu__Quote__c quote = XC_IN051_BillingDisconnectionProcess_D.getZquote(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c);
                subscriptionId = (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c;
            }else if(String.isNotBlank(a.XC_SubscriptionName__c)){
                Zuora__Subscription__c subscr = XC_IN051_BillingDisconnectionProcess_D.getSubscription(a.XC_SubscriptionName__c);
                subscriptionId = subscr.Zuora__External_Id__c; 
            }

            if(String.isNotBlank(subscriptionId)){

                XC_REST_Withdrawal.WrapperRequest wrReq = new XC_REST_Withdrawal.WrapperRequest();
                wrReq.SubscriptionId = subscriptionId;
                wrReq.legalEntity = legalEntity;
                wrReq.stream = stream;

                XC_REST_Withdrawal.WrapperResponse wrResponse = XC_REST_Withdrawal.requestWithdrawal(wrReq);

                if(wrResponse.errors != null && !(wrResponse.errors).isEmpty()){

                    updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, wrResponse.errors[0].title);

                }else{

                    updateStepsStatus(step.Id, Label.XC_CL_Completed_Ok, '');
                }
                
            }else {
                updateStepsStatus(step.Id, Label.XC_CL_Step_CompletedKO, Label.XC_CL_MissingSubscriptionId);
            }
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



 
}