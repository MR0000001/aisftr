/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Updates the zuora account with the customer account on the billing profile line item
* @LastModify Nicola Mariniello nmariniello@deloitte.it
*/


public with sharing class XC_IN024_ChangeBillingProfile {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN024_ChangeBillingProfile');

    /** 
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
    }    

    
    /** 
     * @param inputWrapperList the list of input wrapper
     * @description Wrapper used by flow
     */
    @InvocableMethod
    public static void changeBillingProfile(List<InputWrapper> inputWrapperList) {
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN024_ChangeBillingProfile');

        if(inputWrapperList.isEmpty()) {
            return;
        }

        List<String> listStepIds = new List<String>{inputWrapperList[0].stepId};
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        XC_Provisioning_Step__c step;
        String confItemId = '';
        String orderId = ''; 
        String legalEntity = '';
        String stream = '';
        String bundleConfItem = '';
        String subscriptionId = '';
        zqu__Quote__c quote;
        Map<Id, XC_Provisioning_Step__c> mapStepUpdate = new  Map<Id, XC_Provisioning_Step__c>();

        for(InputWrapper inputWr : inputWrapperList) {
            step = mapSteps.get(inputWr.stepId);
            confItemId = step.XC_Configuration_Item__c;
            orderId = step.XC_Configuration_Item__r.NE__OrderId__c;
            legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
            stream = step.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            bundleConfItem = step.XC_Configuration_Item__r.NE__Bundle_Configuration__c; 
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

        // Get items
        Map<Id, NE__OrderItem__c> itemMap;
        if(String.isBlank(bundleConfItem)) {
            itemMap = new Map<Id, NE__OrderItem__c>([SELECT ID, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_PreviousBillingProfileLineItem__c,
                                                        XC_PreviousBillingProfileLineItem__r.XC_ZuoraId__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,
                                                        NE__BillingProfId__r.Zuora_Account_Id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_eMobTransactionId__c,
                                                        NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.XC_Type__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__AccountId__c, NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c,
                                                        (SELECT Id, XC_Status__c, XC_Flow_API_Name__c FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c = 'XC_FL_ChangeProvisioning_ChangeBillingProfile' OR 
                                                                                                            XC_Flow_API_Name__c =: Label.XC_CL_ChangeProvisioning_ChangeOwnership_BillingProcess_Flow)
                                                        FROM NE__OrderItem__c 
                                                        WHERE Id = :confItemId
                                                        LIMIT 1]);
        } else {
            itemMap = new Map<Id, NE__OrderItem__c>([SELECT ID, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_PreviousBillingProfileLineItem__c,
                                                        XC_PreviousBillingProfileLineItem__r.XC_ZuoraId__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,
                                                        NE__BillingProfId__r.Zuora_Account_Id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_eMobTransactionId__c,
                                                        NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.XC_Type__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__AccountId__c, NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c,
                                                        (SELECT Id, XC_Status__c, XC_Flow_API_Name__c FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c = 'XC_FL_ChangeProvisioning_ChangeBillingProfile' OR 
                                                                                                            XC_Flow_API_Name__c =: Label.XC_CL_ChangeProvisioning_ChangeOwnership_BillingProcess_Flow)
                                                        FROM NE__OrderItem__c 
                                                        WHERE NE__Bundle_Configuration__c = :bundleConfItem]);
        }
        NE__OrderItem__c item = itemMap.get(confItemId);

        // Check if the current and previous bpli are the same
        if(item.XC_BillingProfileLineItem__c == item.XC_PreviousBillingProfileLineItem__c || item.XC_BillingProfileLineItem__r.XC_ZuoraId__c == item.XC_PreviousBillingProfileLineItem__r.XC_ZuoraId__c){
            setProvisioningStepStatus(itemMap.values(), true, 'SameBpliError:' + Label.XC_CL_SameBpli_ErrorMessage);
            return;
        }

        // Get Asset
        Map<Id, Asset> mapAss = new Map<Id, Asset>([SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_SubscriptionName__c, XC_Original_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__External_Id__c,
                                                    XC_Subscription__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__Status__c
                                                    FROM Asset
                                                    WHERE XC_Configuration_Item__c = :confItemId]);
        if(mapAss.isEmpty()) {
            setProvisioningStepStatus(itemMap.values(), true, Label.XC_CL_MissingAsset);
            return;
        }
        Asset a = mapAss.values()[0];


        // Search Subscription ID
        // FROM Subscription Lookup on Asset
        if(String.isNotBlank(a.XC_Subscription__c)) {

            if(a.XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c == item.XC_BillingProfileLineItem__r.XC_ZuoraId__c) {
                setProvisioningStepStatus(itemMap.values(), true, 'SameBpliError:' + Label.XC_CL_SameBpli_ErrorMessage);
                return;
            }
            if(a.XC_Subscription__r.Zuora__Status__c == 'Cancelled') {
                for( XC_Provisioning_Step__c stepTU : mapSteps.values()){
                    XC_Provisioning_Step__c updateStep = new XC_Provisioning_Step__c();
                    updateStep.Id = step.Id;
                    updateStep.XC_Status__c = Label.XC_CL_Step_Skipped;
                    updateStep.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                    mapStepUpdate.put(updateStep.Id, updateStep);
                }
                XC_UTIL_Sobject.updateListRecords(mapStepUpdate.values());
                return;
            }
            subscriptionId = a.XC_Subscription__r.Zuora__External_Id__c; 

        // FROM Zquote
        } else if(String.isNotBlank(a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)) {

            Map<Id, zqu__Quote__c> mapZquote = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionNumber__c, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c, zqu__ZuoraAccountID__c, zqu__Account__c
                                                                            FROM zqu__Quote__c 
                                                                            WHERE Id = :a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c]);
            quote = mapZquote.values()[0];
            subscriptionId = (String.isNotBlank(quote.XC_LastSubscriptionId__c)) ? quote.XC_LastSubscriptionId__c : quote.zqu__ZuoraSubscriptionID__c;

            if(String.isBlank(subscriptionId)) {
                setProvisioningStepStatus(itemMap.values(), true, Label.XC_CL_NoSubscriptionOnZquote);
                return;
            }

            Map<Id, Zuora__Subscription__c> zuoraSubMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Name, Zuora__OriginalId__c, Zuora__PreviousSubscriptionId__c, Zuora__External_Id__c, Zuora__SubscriptionNumber__c, Zuora__CustomerAccount__r.Zuora__External_Id__c, Zuora__Status__c
                                                                                                FROM Zuora__Subscription__c
                                                                                                WHERE Zuora__Account__c = :quote.zqu__Account__c
                                                                                                    AND (Zuora__OriginalId__c = :subscriptionId
                                                                                                    OR Zuora__PreviousSubscriptionId__c = :subscriptionId
                                                                                                    OR Zuora__External_Id__c = :subscriptionId)]);
            if(!zuoraSubMap.isEmpty() && zuoraSubMap.values()[0].Zuora__CustomerAccount__r.Zuora__External_Id__c == item.XC_BillingProfileLineItem__r.XC_ZuoraId__c) {
                setProvisioningStepStatus(itemMap.values(), true, 'SameBpliError:' + Label.XC_CL_SameBpli_ErrorMessage);
                return;
            }
            if(!zuoraSubMap.isEmpty() && zuoraSubMap.values()[0].Zuora__Status__c == 'Cancelled') {
                for( XC_Provisioning_Step__c stepTU : mapSteps.values()){
                    XC_Provisioning_Step__c updateStep = new XC_Provisioning_Step__c();
                    updateStep.Id = step.Id;                    
                    updateStep.XC_Status__c = Label.XC_CL_Step_Skipped;
                    updateStep.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                    mapStepUpdate.put(updateStep.Id, updateStep);
                }
                XC_UTIL_Sobject.updateListRecords(mapStepUpdate.values());
                return;
            }

        // FROM Zuora Subscription Record with Suscription Name
        } else if(String.isNotBlank(a.XC_SubscriptionName__c)) {

            Map<Id, Zuora__Subscription__c> zuoraSubMap = new  Map<Id, Zuora__Subscription__c>([SELECT Zuora__Status__c, Zuora__External_Id__c, Zuora__CustomerAccount__r.Zuora__External_Id__c
                                                                                                FROM Zuora__Subscription__c
                                                                                                WHERE Zuora__SubscriptionNumber__c =: a.XC_SubscriptionName__c order by Zuora__Version__c desc]);
            if(zuoraSubMap.isEmpty()) {
                setProvisioningStepStatus(itemMap.values(), true, Label.XC_CL_NoZuoraSubscriptionRecord);
                return;
            }
            if(zuoraSubMap.values()[0].Zuora__CustomerAccount__r.Zuora__External_Id__c == item.XC_BillingProfileLineItem__r.XC_ZuoraId__c) {
                setProvisioningStepStatus(itemMap.values(), true, 'SameBpliError:' + Label.XC_CL_SameBpli_ErrorMessage);
                return;
            }
            if(!zuoraSubMap.isEmpty() && zuoraSubMap.values()[0].Zuora__Status__c == 'Cancelled') {
                for( XC_Provisioning_Step__c stepTU : mapSteps.values()){
                    XC_Provisioning_Step__c updateStep = new XC_Provisioning_Step__c();
                    updateStep.Id = step.Id;
                    updateStep.XC_Status__c = Label.XC_CL_Step_Skipped;
                    updateStep.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
                    mapStepUpdate.put(updateStep.Id, updateStep);
                }
                XC_UTIL_Sobject.updateListRecords(mapStepUpdate.values());
                return;
            }
            subscriptionId = zuoraSubMap.values()[0].Zuora__External_Id__c; 

        // No subscription found
        } else {
            setProvisioningStepStatus(itemMap.values(), true, Label.XC_CL_NoSubscription);
            return;
        }

        // Calculate start date
        String startDateLocal;
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, stream, '');
        if(entityWr != null && String.isNotBlank(entityWr.timeZone)){
            startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
            System.debug('StartDate (local time): ' + startDateLocal);
        } else {
            startDateLocal = String.valueOf(Date.Today());
            System.debug('StartDate (user local time): ' + startDateLocal);
        }

        // Prepare wrapper for call zuora
        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wrRequest = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequest();
        wrRequest.requests = new List<XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora>();

        XC_REST_ZuoraOwnerTransfer_U.AmendOptionsWrapper amOpWr = new XC_REST_ZuoraOwnerTransfer_U.AmendOptionsWrapper();
        amOpWr.GenerateInvoice = 'false';

        XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora wrZuoraReq = new XC_REST_ZuoraOwnerTransfer_U.WrapperRequestZuora();
        wrZuoraReq.AmendOptions = amOpWr; 
        
        XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper amWr = new XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper();
        amWr.ContractEffectiveDate = String.isNotBlank(String.valueOf(item.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c)) ? String.valueOf(item.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c) : startDateLocal;
        amWr.Description = (item.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_ChangeOfOwnership) ? item.NE__OrderId__r.XC_Type__c : 'STANDARD Owner transfer';
        amWr.Name = (item.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_ChangeOfOwnership) ? item.NE__OrderId__r.XC_Type__c : 'Owner transfer';
        amwr.SubscriptionId = subscriptionId;
        amWr.DestinationAccountId = item.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
        amWr.DestinationInvoiceOwnerId = item.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c;
        amWr.Type = 'OwnerTransfer';
        List<XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper> listAm = new List<XC_REST_ZuoraOwnerTransfer_U.AmendmentWrapper>();
        listAm.add(amWr);
        wrZuoraReq.Amendments = listAm;

        wrRequest.requests.add(wrZuoraReq);
        wrRequest.legalEntity = item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
        wrRequest.stream = item.NE__OrderId__r.XC_Segment__c;
        wrRequest.transactionID = item.NE__OrderId__r.XC_eMobTransactionId__c;

        // Call Zuora
        Map<String, String> utilMap = new Map<String, String>{'wrRequest' => JSON.serialize(wrRequest),
                                                                'confItemList' => JSON.serialize(itemMap.values()),
                                                                'item' => JSON.serialize(item),
                                                                'quote' => JSON.serialize(quote)};
        callZuoraForOwnerTransfer(utilMap);
    }


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 20/11/2020
     * @param utilMap the utilMap
     * @description call zuora and set the status on the step
     */
    @future(callout=true)
    public static void callZuoraForOwnerTransfer(Map<String, String> utilMap) {

        XC_REST_ZuoraOwnerTransfer_U.WrapperRequest wrRequest = (XC_REST_ZuoraOwnerTransfer_U.WrapperRequest) JSON.deserialize(utilMap.get('wrRequest'), XC_REST_ZuoraOwnerTransfer_U.WrapperRequest.class);
        List<NE__OrderItem__c> confItemList = (List<NE__OrderItem__c>) JSON.deserialize(utilMap.get('confItemList'), List<NE__OrderItem__c>.class);
        NE__OrderItem__c item = (NE__OrderItem__c) JSON.deserialize(utilMap.get('item'), NE__OrderItem__c.class);
        zqu__Quote__c quote = (zqu__Quote__c) JSON.deserialize(utilMap.get('quote'), zqu__Quote__c.class);


        XC_REST_ZuoraOwnerTransfer_U.WrapperResponse wrResponse = XC_REST_ZuoraOwnerTransfer.zuoraChangeOwnership(wrRequest);
        System.debug('@@@0207 WRAPPER RESPONSE CHANGE BILLING PROFILE-->' + wrResponse);
        
        if((wrResponse!= null && wrResponse.results!=null && !wrResponse.results.isEmpty())){
            if(wrResponse.results[0].success) {

                setProvisioningStepStatus(confItemList, false, '');
                
                String newSubscriptionId = wrResponse.results[0].subscriptionId;
                item.XC_LastSubscriptionId__c = newSubscriptionId;
                XC_UTIL_Sobject.updateRecord(item);
                if(quote != null){
                    quote.XC_LastSubscriptionId__c = newSubscriptionId;
                    XC_UTIL_Sobject.updateRecord(quote);
                }
                
            } else {
                setProvisioningStepStatus(confItemList, true, wrResponse.results[0].errors[0].message);
            }
        }

    }
    

    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 28/10/2019
     * @param confItemList the conf item list
     * @param zuoraError the boolean
     * @param errorMessage the error Message
     * @description set the status on the step
     */
    public static void setProvisioningStepStatus(List<NE__OrderItem__c> confItemList, Boolean zuoraError, String errorMessage) {

        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = new  Map<Id, XC_Provisioning_Step__c>();
        for(NE__OrderItem__c confItem : confItemList) {
            if(!zuoraError) {
                XC_TR_ZQuote_U_ManageSent.manageStepsForSentZquote(confItem.Provisioning_Steps__r, mapStepToUpdate, '');
            } else if(!String.isBlank(errorMessage) && errorMessage.startsWith('SameBpliError:')){
                manageSkipSteps(confItem.Provisioning_Steps__r, errorMessage.replace('SameBpliError:', ''), mapStepToUpdate);
            }else {
                XC_TR_ZQuote_U_ManageErrors.manageStepsForErrorZquote(confItem.Provisioning_Steps__r, errorMessage, mapStepToUpdate);
            }
        }
        system.debug('STEPTOUPDATE'+  mapStepToUpdate.values());
        XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values());
    }


    /** 
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @date 08/01/2021
     * @param stepList the step list
     * @param errorMessage the error message
     * @param mapStepToUpdate the map step to update
     * @description set the skipped status on the step
     */
    public static void manageSkipSteps(List<XC_Provisioning_Step__c> stepList, String errorMessage, Map<Id, XC_Provisioning_Step__c> mapStepToUpdate) {

        for(XC_Provisioning_Step__c step : stepList) {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = step.Id;
            stepToUpdate.XC_ErrorMessage__c = errorMessage;
            if(step.XC_Status__c == 'In Progress') {
                stepToUpdate.XC_Status__c = Label.XC_CL_Step_Skipped;
            } else {
                stepToUpdate.XC_ToBeAutocompleted__c = true;
            }
            mapStepToUpdate.put(stepToUpdate.Id, stepToUpdate);
        }
    }

}