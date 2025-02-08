/**
 * The Class XC_IN076_TermsAndContitionsAmendment.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 27/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Call Zuora to do a Terms And Contitions Amendment
 **/


public without sharing class XC_IN076_TermsAndContitionsAmendment {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN076_TermsAndContitionsAmendment');


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
    }    

    
    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param inputWrapperList the list of input wrapper
     * @description method to change AutoRenewal to false
     */
    @InvocableMethod
    public static void changeTermsOnZuora(List<InputWrapper> inputWrapperList) {
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering in XC_IN076_TermsAndContitionsAmendment');

        if(inputWrapperList.isEmpty()) {
            return;
        }

        List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
        String confItemId = step.XC_Configuration_Item__c;
        String legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        String stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
        
        String startDateLocal;
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
        if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
            startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
            System.debug('StartDate (local time): ' + startDateLocal);
        } else {
            startDateLocal = String.valueOf(Date.Today());
            System.debug('StartDate (user local time): ' + startDateLocal);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

        NE__OrderItem__c item = XC_IN031_DeactivateAutomaticRenewal_D.getOrderItem(confItemId);
        Asset a = item.Assets__r[0];

        // Calculate NEW terms
        Integer initialTerm = 1;
        Integer renewalTerm = 1;
        Boolean autoRenew = true;

        for(NE__Order_Item_Attribute__c attrib : item.NE__Order_Item_Attributes__r){
            if(attrib.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Duration and Renewal Terms' && attrib.XC_DeveloperName__c == 'Duration' && attrib.NE__Value__c != null){
                initialTerm = Integer.valueOf(attrib.NE__Value__c);
                continue;
            }
            if(attrib.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Duration and Renewal Terms' && attrib.XC_DeveloperName__c == 'Renewal Duration' && attrib.NE__Value__c != null){
                renewalTerm = Integer.valueOf(attrib.NE__Value__c);
                autoRenew = (Integer.valueOf(attrib.NE__Value__c) == 0) ? false : true;
                continue;
            }
        }

        // Get subscription id
        String subId = '';
        Boolean isEvergreen = false;
        Boolean isCancelledSub = false; //20211130_DD_ERR_03 

        // FROM Subscription Lookup on Asset
        if(String.isNotBlank(a.XC_Subscription__c)) {
            subId = a.XC_Subscription__r.Zuora__External_Id__c;
            isEvergreen = (String.isNotBlank(a.XC_Subscription__r.Zuora__TermSettingType__c) && a.XC_Subscription__r.Zuora__TermSettingType__c.equalsIgnoreCase('EVERGREEN')) ? true : false;
			//20211130_DD_ERR_03 - start
			isCancelledSub = a.XC_Subscription__r.Zuora__Status__c == 'Cancelled' ? true : false; 
            //20211130_DD_ERR_03 - end
        // FROM Zquote
        } else if(String.isNotBlank(a.XC_ZQuoteId__c)) {
            //query in più sulla subscription per zuora__subscription status
            zqu__Quote__c quote = XC_IN031_DeactivateAutomaticRenewal_D.getZquote(a.XC_ZQuoteId__c);
            subId = (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c;
            if(String.isBlank(subId)) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_NoSubscriptionOnZquote;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }
			//20211130_DD_ERR_03 - start
            Map<Id, Zuora__Subscription__c> zuoraSubMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Name, Zuora__OriginalId__c, Zuora__PreviousSubscriptionId__c, Zuora__External_Id__c, Zuora__SubscriptionNumber__c, 
                                                                                               Zuora__CustomerAccount__r.Zuora__External_Id__c, Zuora__Status__c
                                                                                                FROM Zuora__Subscription__c
                                                                                                WHERE Zuora__Account__c = :quote.zqu__Account__c
                                                                                                    AND (Zuora__OriginalId__c = :subId
                                                                                                    OR Zuora__PreviousSubscriptionId__c = :subId
                                                                                                    OR Zuora__External_Id__c = :subId)]);
            if(!zuoraSubMap.isEmpty() && zuoraSubMap.values()[0].Zuora__Status__c == 'Cancelled') {
                isCancelledSub = true;
            }
            //20211130_DD_ERR_03 - end
        // FROM Zuora Subscription Record with Suscription Name
        } else if(String.isNotBlank(a.XC_SubscriptionName__c)) {

            Zuora__Subscription__c sub = XC_IN031_DeactivateAutomaticRenewal_D.getSubscription(a.XC_SubscriptionName__c);
            if(sub == null) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_NoZuoraSubscriptionRecord;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }
            subId = sub.Zuora__External_Id__c;
            isEvergreen = (String.isNotBlank(sub.Zuora__TermSettingType__c) && sub.Zuora__TermSettingType__c.equalsIgnoreCase('EVERGREEN')) ? true : false;
			//20211130_DD_ERR_03 - start
			isCancelledSub = sub.Zuora__Status__c == 'Cancelled' ? true : false; 
			//20211130_DD_ERR_03 - end
        // No subscription found
        } else {

            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = Label.XC_CL_NoSubscription;
            XC_UTIL_Sobject.updateRecord(step);
            return;
        }

        // If Subscription is evergreen, skip the step
        //20211130_DD_ERR_03 - start
        //if(isEvergreen) {
        if(isEvergreen || isCancelledSub) {
            if(isCancelledSub) step.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
            //20211130_DD_ERR_03 - end
            step.XC_Status__c = Label.XC_CL_Step_Skipped;
            XC_UTIL_Sobject.updateRecord(step);
            return;
        }

        // Call Zuora with Future
        callZuora(new Map<String, String>{'subId' => subId,
                                            'initialTerm' => String.valueOf(initialTerm),
                                            'renewalTerm' => String.valueOf(renewalTerm),
                                            'autoRenew' => (autoRenew) ? 'true' : 'false',
                                            'startDateLocal' => startDateLocal,
                                            'item' => JSON.serialize(item),
                                            'a' => JSON.serialize(a),
                                            'step' => JSON.serialize(step)});
    }


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param utilMap the util Map
     * @description method to call zuora
     */
    @future(callout=true)
    public static void callZuora(Map<String, String> utilMap) {

        String subId = utilMap.get('subId');
        Integer initialTerm = Integer.valueOf(utilMap.get('initialTerm'));
        Integer renewalTerm = Integer.valueOf(utilMap.get('renewalTerm'));
        String autoRenew = utilMap.get('autoRenew');
        String startDateLocal = utilMap.get('startDateLocal');
        NE__OrderItem__c item = (NE__OrderItem__c) JSON.deserialize(utilMap.get('item'), NE__OrderItem__c.class);
        Asset a = (Asset) JSON.deserialize(utilMap.get('a'), Asset.class);
        XC_Provisioning_Step__c step = (XC_Provisioning_Step__c) JSON.deserialize(utilMap.get('step'), XC_Provisioning_Step__c.class);


        XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper amWr = new XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper();
        amWr.Type = 'TermsAndConditions';
        amWr.SubscriptionId = subId;
        amWr.Name = 'Change Terms And Conditions';
        amWr.Description = 'Change Terms And Conditions';
        amWr.AutoRenew = autoRenew;
        amWr.CurrentTerm = initialTerm;
        amWr.CurrentTermPeriodType = 'Month';
        amWr.RenewalTerm = renewalTerm;
        amWr.RenewalTermPeriodType = 'Month';
        amWr.TermStartDate = startDateLocal;
        amWr.TermType = 'TERMED';
        amWr.ContractEffectiveDate = String.valueOf(Date.valueOf(startDateLocal).addDays(1));
        amWr.ServiceActivationDate = String.valueOf(Date.valueOf(startDateLocal).addDays(1));
        amWr.Status = 'Completed';

        XC_REST_ZuoraOwnerTransfer_U.AmendOptionsWrapper amOpWr = new XC_REST_ZuoraOwnerTransfer_U.AmendOptionsWrapper();
        amOpWr.GenerateInvoice = 'false';  

        XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora wrZuoraReq = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora();
        wrZuoraReq.Amendments = new List<XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper>();
        wrZuoraReq.Amendments.add(amWr);
        wrZuoraReq.AmendOptions = amOpWr; 
        
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wrRequest = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        wrRequest.requests = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora>();
        wrRequest.requests.add(wrZuoraReq);
        wrRequest.legalEntity = item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
        wrRequest.stream = item.NE__OrderId__r.XC_Segment__c;
        wrRequest.transactionID = item.NE__OrderId__r.XC_eMobTransactionId__c;

        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse wrResponseOwnerTransfer = XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wrRequest);
        XC_IN031_DeactivateAutomaticRenewal_D.DeactivateAutoRenwalWrapperResponse wrResponse = XC_IN031_DeactivateAutomaticRenewal_D.manageResponsesDeactivateAutoRenewal(wrResponseOwnerTransfer, null);
        
        if(wrResponse.success) {
            item.XC_LastSubscriptionId__c = wrResponse.subscriptionId;
            XC_UTIL_Sobject.updateRecord(item);

            if(String.isNotBlank(a.XC_ZQuoteId__c)) {
                zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = a.XC_ZQuoteId__c;
                quoteToUpdate.zqu__AutoRenew__c = (autoRenew == 'true') ? true : false;
                quoteToUpdate.zqu__InitialTerm__c = initialTerm;
                quoteToUpdate.zqu__InitialTermPeriodType__c = 'Month';
                quoteToUpdate.zqu__RenewalTerm__c = renewalTerm;
                quoteToUpdate.zqu__RenewalTermPeriodType__c = 'Month';
                quoteToUpdate.zqu__TermStartDate__c = Date.valueOf(startDateLocal);
                quoteToUpdate.XC_LastSubscriptionId__c = wrResponse.subscriptionId;
                XC_UTIL_SObject.updateRecord(quoteToUpdate);
            }

            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Completed_Ok);
            XC_UTIL_Sobject.updateRecord(stepToUpdate);

        } else if(String.isNotBlank(wrResponse.errorMessage) && wrResponse.errorMessage.containsIgnoreCase('change of ever-green to termed')) { // The error message of the Evergreen Subscription is 'The term and condition change of ever-green to termed can only be effective on a date later than 01/01/3000(most recent amendment on the subscription).'
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Step_Skipped);
            XC_UTIL_Sobject.updateRecord(stepToUpdate);

        } else {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Step_CompletedKO, XC_ErrorMessage__c = wrResponse.errorMessage);
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
        }

    }

}