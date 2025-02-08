/**
 * The Class XC_IN031_DeactivateAutomaticRenewal.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/09/2019
 * @date Modification : 05/03/2021
 * @description       : Call Zuora to change AutoRenewal to false
 **/


public without sharing class XC_IN031_DeactivateAutomaticRenewal {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN031_DeactivateAutomaticRenewal');


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 04/09/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
    }    

    
    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 04/09/2019
     * @param inputWrapperList the list of input wrapper
     * @description method to change AutoRenewal to false
     */
    @InvocableMethod
    public static void changeAutoRenewal(List<InputWrapper> inputWrapperList) {
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN031_DeactivateAutomaticRenewal');

        if(inputWrapperList.isEmpty()) {
            return;
        }

        List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        XC_Provisioning_Step__c step = mapSteps.get(inputWrapperList[0].stepId);
        String orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
        String confItemId = step.XC_Configuration_Item__c;
        //String legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
        String legalEntity = (!String.isBlank(step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c)) ? step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c : step.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
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
        String subId = '';
        Integer initialTerm;
        String initialTermPeriodType = '';
        Boolean isEvergreenSubscription = false;

        zqu__Quote__c quote;

        // Search subscription infos
        // FROM Subscription Lookup on Asset
        if(String.isNotBlank(a.XC_Subscription__c)) {

            subId = a.XC_Subscription__r.Zuora__External_Id__c;
            initialTerm = String.isNotBlank(a.XC_Subscription__r.Zuora__InitialTerm__c) ? Integer.valueOf(a.XC_Subscription__r.Zuora__InitialTerm__c.split(' ')[0]) : 0;
            initialTermPeriodType = String.isNotBlank(a.XC_Subscription__r.Zuora__InitialTermPeriodType__c) ? a.XC_Subscription__r.Zuora__InitialTermPeriodType__c : '';
            isEvergreenSubscription = (String.isNotBlank(a.XC_Subscription__r.Zuora__TermSettingType__c) && a.XC_Subscription__r.Zuora__TermSettingType__c.equalsIgnoreCase(Label.XC_CL_EvergreenSubscription)) ? true : false;

            if(a.XC_Subscription__r.Zuora__Status__c == 'Cancelled') {
                step.XC_Status__c = Label.XC_CL_Step_Skipped;
                step.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

        // FROM Zquote
        } else if(String.isNotBlank(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {

            quote = XC_IN031_DeactivateAutomaticRenewal_D.getZquote(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c);
            subId = (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c;
            initialTerm = Integer.valueOf(quote.zqu__InitialTerm__c);
            initialTermPeriodType = quote.zqu__InitialTermPeriodType__c;
            isEvergreenSubscription = (String.isNotBlank(quote.zqu__Subscription_Term_Type__c) && quote.zqu__Subscription_Term_Type__c.equalsIgnoreCase(Label.XC_CL_EvergreenSubscription)) ? true : false;

            if(String.isBlank(subId)) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_NoSubscriptionOnZquote;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

            Map<Id, Zuora__Subscription__c> zuoraSubMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__Status__c
                                                                                                FROM Zuora__Subscription__c
                                                                                                WHERE Zuora__Account__c = :quote.zqu__Account__c
                                                                                                    AND (Zuora__OriginalId__c = :subId
                                                                                                    OR Zuora__PreviousSubscriptionId__c = :subId
                                                                                                    OR Zuora__External_Id__c = :subId)]);

            if(!zuoraSubMap.isEmpty() && zuoraSubMap.values()[0].Zuora__Status__c == 'Cancelled') {
                step.XC_Status__c = Label.XC_CL_Step_Skipped;
                step.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

        // FROM Zuora Subscription Record with Suscription Name
        } else if(String.isNotBlank(a.XC_SubscriptionName__c)) {

            Zuora__Subscription__c sub = XC_IN031_DeactivateAutomaticRenewal_D.getSubscription(a.XC_SubscriptionName__c);

            if(sub == null) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_NoZuoraSubscriptionRecord;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

            if(sub.Zuora__Status__c == 'Cancelled') {
                step.XC_Status__c = Label.XC_CL_Step_Skipped;
                step.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                XC_UTIL_Sobject.updateRecord(step);
                return;
            }

            subId = sub.Zuora__External_Id__c;
            initialTerm = String.isNotBlank(sub.Zuora__InitialTerm__c) ? Integer.valueOf(sub.Zuora__InitialTerm__c.split(' ')[0]) : 0;
            initialTermPeriodType = String.isNotBlank(sub.Zuora__InitialTermPeriodType__c) ? sub.Zuora__InitialTermPeriodType__c : '';
            isEvergreenSubscription = (String.isNotBlank(sub.Zuora__TermSettingType__c) && sub.Zuora__TermSettingType__c.equalsIgnoreCase(Label.XC_CL_EvergreenSubscription)) ? true : false;

        // No subscription found
        } else {

            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = Label.XC_CL_NoSubscription;
            XC_UTIL_Sobject.updateRecord(step);
            return;
        }

        // Call Zuora with Future
        callZuora(new Map<String, String>{'isEvergreenSubscription' => String.valueOf(isEvergreenSubscription),
                                            'subId' => subId,
                                            'initialTerm' => String.valueOf(initialTerm),
                                            'initialTermPeriodType' => initialTermPeriodType,
                                            'startDateLocal' => startDateLocal,
                                            'item' => JSON.serialize(item),
                                            'a' => JSON.serialize(a),
                                            'quote' => JSON.serialize(quote),
                                            'step' => JSON.serialize(step)});
    }


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @date 05/03/2021
     * @param utilMap the util Map
     * @description method to call zuora
     */
    @future(callout=true)
    public static void callZuora(Map<String, String> utilMap) {

        Boolean isEvergreenSubscription = Boolean.valueOf(utilMap.get('isEvergreenSubscription'));
        String subId = utilMap.get('subId');
        Integer initialTerm = Integer.valueOf(utilMap.get('initialTerm'));
        String initialTermPeriodType = utilMap.get('initialTermPeriodType');
        String startDateLocal = utilMap.get('startDateLocal');
        NE__OrderItem__c item = (NE__OrderItem__c) JSON.deserialize(utilMap.get('item'), NE__OrderItem__c.class);
        Asset a = (Asset) JSON.deserialize(utilMap.get('a'), Asset.class);
        zqu__Quote__c quote = (zqu__Quote__c) JSON.deserialize(utilMap.get('quote'), zqu__Quote__c.class);
        XC_Provisioning_Step__c step = (XC_Provisioning_Step__c) JSON.deserialize(utilMap.get('step'), XC_Provisioning_Step__c.class);


        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse wrResponseOwnerTransfer = null;
        XC_REST_Disconnection.WrapperResponse wrResponseDisconnection = null;

        if(!isEvergreenSubscription) {
            XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper amWr = new XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper();
            amWr.Type = 'TermsAndConditions';
            amWr.SubscriptionId = subId;
            amWr.Name = 'Change Renewal Amend';
            amWr.Description = 'Change Renewal to false';
            amWr.AutoRenew = 'false';
            amWr.RenewalTerm = initialTerm;
            amWr.RenewalTermPeriodType = initialTermPeriodType;
            amWr.ContractEffectiveDate = startDateLocal;
            amWr.ServiceActivationDate = startDateLocal;
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

            wrResponseOwnerTransfer = XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wrRequest);
            System.debug('@@@ WRAPPER RESPONSE Change Renewal to false --> ' + wrResponseOwnerTransfer);

        } else { // Evergreen Subpscription Call Disconnection WF
            
                XC_REST_Disconnection.QFWrapperRequest wr = new XC_REST_Disconnection.QFWrapperRequest();
                wr.legalEntity = item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
                wr.stream = item.NE__OrderId__r.XC_Segment__c;

                map<string,Object> r = new map<string,Object>();
                r.put('SubscriptionId__c',subId);
                r.put('CancellationDate__c',a.XC_ContractEndDate__c!=null ? String.valueof(a.XC_ContractEndDate__c) : startDateLocal );
                r.put('SubType__c',item.NE__OrderId__r.XC_Subtype__c); 
                r.put('Source__c','Salesforce');
                r.put('Reference__c',item.NE__OrderId__c); //order id o order name 
                r.put('Status__c','Pending'); 
                r.put('FlowName__c','Disconnection');
                wr.records = new List<Map<String,Object>>();
                wr.records.add(r);
                        
            wrResponseDisconnection = XC_IN008_DeprovisioningBillingProcess_U.callDisconnection(wr);
        }
        
        XC_IN031_DeactivateAutomaticRenewal_D.DeactivateAutoRenwalWrapperResponse wrResponse = XC_IN031_DeactivateAutomaticRenewal_D.manageResponsesDeactivateAutoRenewal(wrResponseOwnerTransfer,wrResponseDisconnection);

        if(wrResponse.success) {
            

            Date contractEndDate;
            if(!isEvergreenSubscription) {
                
                item.XC_LastSubscriptionId__c = wrResponse.subscriptionId;
                XC_UTIL_Sobject.updateRecord(item);

                if(quote != null) {
                    quote.XC_LastSubscriptionId__c = wrResponse.subscriptionId;
                    XC_UTIL_Sobject.updateRecord(quote);
                }
                //a.XC_ContractEndDate__c = setContractEndDate(a, initialTerm, initialTermPeriodType);
                contractEndDate = setContractEndDate(a, initialTerm, initialTermPeriodType);
            }

            //a.XC_Service_AutoRenew__c = false;
            //FIX to avoid the error ENTITY_IS_DELETED related to the zuora subscription record
            Asset assetToUpdate = New Asset(id = a.Id, XC_Service_AutoRenew__c = false );
            if(contractEndDate  != null){
                assetToUpdate.XC_ContractEndDate__c = contractEndDate;
            }
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.updateRecord(assetToUpdate);
            if(result.success){
                XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Completed_Ok);
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
            } else {
                XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Step_CompletedKO, XC_ErrorMessage__c = result.errorMessage);
                XC_UTIL_Sobject.updateRecord(stepToUpdate);
            }

        } else {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c(Id = step.Id, XC_Status__c = Label.XC_CL_Step_CompletedKO, XC_ErrorMessage__c = wrResponse.errorMessage);
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
        }

    }

    
    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 11/09/2019
     * @param a the asset
     * @param quote the zQUote
     * @description method to set the Contract End Date
     */
    public static Date setContractEndDate(Asset a, Integer initialTerm, String initialTermPeriodType) {
        
        if(initialTermPeriodType == 'Year') {
            return Date.valueOf((a.XC_Service_Last_Renewal_Date__c != null) ? a.XC_Service_Last_Renewal_Date__c.addYears(initialTerm) : a.NE__Activation_Date__c.addYears(initialTerm));
        } else if(initialTermPeriodType == 'Day') {
            return Date.valueOf((a.XC_Service_Last_Renewal_Date__c != null) ? a.XC_Service_Last_Renewal_Date__c.addDays(initialTerm) : a.NE__Activation_Date__c.addDays(initialTerm));
        } else if(initialTermPeriodType == 'Week') {
            return Date.valueOf((a.XC_Service_Last_Renewal_Date__c != null) ? a.XC_Service_Last_Renewal_Date__c.addDays(initialTerm*7) : a.NE__Activation_Date__c.addDays(initialTerm*7));
        } else {
            return Date.valueOf((a.XC_Service_Last_Renewal_Date__c != null) ? a.XC_Service_Last_Renewal_Date__c.addMonths(initialTerm) : a.NE__Activation_Date__c.addMonths(initialTerm));
        }

    }

}