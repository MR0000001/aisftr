/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  12/11/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN064_ManageZPayment - This class is called from the flow 
*/

public without sharing class XC_IN064_ManageZPayment {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN064_ManageZPayment');

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
    * @description class to the the logic of create Zpayment process
    */
    @InvocableMethod 
    public static void manageZPayment(List<InputWrapper> inputWrapperList) { 

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN064_ManageZPayment');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            
            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN064_ManageZPayment_D.getMapSteps(listStepIds);
            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            String confItemId = step.XC_Configuration_Item__c;
            String legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
            String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;

            NE__OrderItem__c item = XC_IN064_ManageZPayment_D.getOrderItem(confItemId);
            String zAccountId = (!String.isBlank(item.XC_BillingProfileLineItem__c)) ?  item.XC_BillingProfileLineItem__r.XC_ZuoraId__c : '';
            
            if(String.isNotBlank(zAccountId)){

                XC_REST_CreatePayment_U.WrapperRequest wrPayment = new XC_REST_CreatePayment_U.WrapperRequest();
                wrPayment.amount = (item.NE__OrderId__r.NE__One_Time_Fee_Total__c != 0) ? item.NE__OrderId__r.NE__One_Time_Fee_Total__c : item.NE__OrderId__r.NE__Recurring_Charge_Total__c;
                wrPayment.type = (item.XC_PaymentMethod__c == Label.XC_CL_Credit_Card || item.XC_PaymentMethod__c == Label.XC_CL_DirectDebt) ? Label.XC_CL_PaymentType_Electronic : Label.XC_CL_PaymentType_External;
                wrPayment.GenericInfoReplace = item.NE__OrderId__r.XC_PaymentTransactionDetails__c;
                wrPayment.VALUE_DATEReplace = item.NE__OrderId__r.XC_PaymentTransactionDate__c;
                wrPayment.referenceId = item.NE__OrderId__r.XC_PaymentTransactionID__c;
                wrPayment.CRMContractNumberReplace = item.NE__OrderId__r.Name;
                wrPayment.currencyName = item.CurrencyIsoCode; 
                wrPayment.legalentity = legalEntity;
                wrPayment.accountId = zAccountId;
                wrPayment.stream = stream;

                XC_REST_CreatePayment_U.WrapperResponse wrResponse = XC_REST_CreatePayment.createPayment(wrPayment); 

                if(wrResponse.success){
                    updateStepsStatus(orderId, Label.XC_CL_Completed_Ok, (!wrResponse.status.equalsIgnoreCase('Processed')) ? wrResponse.status : ''); // sets the response status, only if it is not "processed", in the provisioning step XC_ErrorMessage__c field 
                }else{

                    String status = (!String.isBlank(wrResponse.status)) ? ' PaymentStatus: ' + wrResponse.status : '';
                    if(wrResponse.reasons != null && !(wrResponse.reasons).isEmpty()){
                        status = (!String.isBlank(status)) ? (wrResponse.reasons[0].message + status) : wrResponse.reasons[0].message;
                    }
                    updateStepsStatus(orderId, Label.XC_CL_Step_CompletedKO, status); 
                }
                
            }else {
                updateStepsStatus(orderId, Label.XC_CL_Step_CompletedKO, Label.XC_CL_MissingZAccountId);
            }
        }
    }


     /**
    * @description method to set provisioning step status   
    * @param orderid the order id
    * @param status the status to set on the step 
    * @param errorMessage the error message to set on the step
    */
    public static void updateStepsStatus(String orderId, String status, String errorMessage){
        
        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = XC_IN064_ManageZPayment_D.getStepsToComplete(orderId);

        for(XC_Provisioning_Step__c step : mapStepToUpdate.values()){
            
            step.XC_Status__c = status;
            step.XC_ErrorMessage__c = errorMessage;
        }

        if(!mapStepToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values()); 
        }
        
    }

}