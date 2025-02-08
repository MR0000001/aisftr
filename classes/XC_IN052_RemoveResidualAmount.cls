/**
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  308/05/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN052_RemoveResidualAmount - This class is called from the flow 
 */


public without sharing class XC_IN052_RemoveResidualAmount {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN052_RemoveResidualAmount');


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
    public static void removeResidualAmount(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN052_RemoveResidualAmount');

        if(!inputWrapperList.isEmpty() && Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()) {

            List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN051_BillingDisconnectionProcess_D.getMapSteps(listStepIds);
            XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
            
            NE__OrderItem__c item = XC_IN051_BillingDisconnectionProcess_D.getOrderItem(step.XC_Configuration_Item__c);
            if(String.isNotBlank(item.NE__OrderId__r.XC_Subtype__c) && !item.NE__OrderId__r.XC_Subtype__c.containsIgnoreCase('Purchase Option')) {
                skipStep(step);
                return;
            }
            Asset a = item.Assets__r[0];

            Map<Id, Zuora__SubscriptionRatePlan__c > srpMap = new Map<Id, Zuora__SubscriptionRatePlan__c>([SELECT Id FROM Zuora__SubscriptionRatePlan__c WHERE Zuora__SubscriptionRatePlanName__c =: Label.XC_CL_RatePlan_ValorResidualOneTime AND Zuora__Subscription__r.Zuora__SubscriptionNumber__c =: a.XC_SubscriptionName__c]);
            if(srpMap.isEmpty()) {
                skipStep(step);
                return;
            }

            Map<Id, zqu__ProductRatePlan__c> prpMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id FROM zqu__ProductRatePlan__c WHERE zqu__ProductRatePlanFullName__c =: Label.XC_CL_RatePlan_ValorResidualOneTime LIMIT 1]);
            if(prpMap.isEmpty()) {
                skipStep(step);
                return;
            }

            String newZquoteId = '';
            
            XC_TR_Configuration_U_ChangeOrder.UtilWrapper wrapper = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
            wrapper.orderId = step.XC_Configuration_Item__r.NE__OrderId__c;
            wrapper.confItemId = step.XC_Configuration_Item__c;
            wrapper.stepId = step.Id;
            wrapper.prpcConfItemsMap = new Map<String, List<String>>();
            wrapper.ratePlanAddList = null;
            wrapper.ratePlanRemoveList = new List<String>{prpMap.values()[0].Id};

            if(String.isNotBlank(item.XC_ZQuoteId__c)) {

                wrapper.originalZQuoteId = item.XC_ZQuoteId__c;
                newZquoteId = XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wrapper);

            } else if(String.isNotBlank(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {

                wrapper.originalZQuoteId = a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c;
                newZquoteId = XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wrapper);

            } else if(String.isNotBlank(a.XC_SubscriptionName__c)) {

                wrapper.subNumber = a.XC_SubscriptionName__c;
                newZquoteId = XC_UTIL_ChangeOrderMigration.createAddRemoveProductsAmendmentQuote(wrapper);

            } else {
                skipStep(step);
                return;
            }

            item.XC_ZQuoteId__c = newZquoteId;
            XC_UTIL_Sobject.updateRecord(item);
        }
    }


    /**
     * @param stepId the step Id
     * @description method to skip the step
     */
    private static void skipStep(XC_Provisioning_Step__c step) {

        step.XC_Status__c = Label.XC_CL_Step_Skipped;
        XC_UTIL_Sobject.updateRecord(step);
        
    }

}