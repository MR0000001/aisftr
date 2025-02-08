/**
 * @description       : XC_REST_ContractAmendment
 * @author            : Donato Lombardi
 * @created date      : 04-02-2022
 * @last modified on  : dd-mm-yyyy
 * @last modified by  : 
 **/


public with sharing class XC_REST_ContractAmendment {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ContractAmendment');


    public class WrapperSubscription {
        public Map<String, Object> subscription;
    }

    public class InfoResponse {
        public Boolean success;
        public String errorMessage;
        public Map<String, Object> subscription;
    }

    public static Boolean updatePrice = false;


    public static void retrieveSubscription(List<XC_ContractAmendment__c> parent, List<XC_ContractAmendment__c> childs) {

        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();

        InfoResponse infoResponse = new infoResponse();
        infoResponse.success = true;
        XC_ContractAmendment__c contractAmendment = !parent.isEmpty() ? parent[0] : childs[0];
        XC_ContractAmendment__c contractAmendmentChild = childs[0];
        updatePrice = contractAmendment.XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Update price: ' + updatePrice);

        // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('contractAmendment', contractAmendment);
        utilMap.put('contractAmendmentChild', contractAmendmentChild);
        utilMap.put('parent', parent);
        utilMap.put('childs', childs);
        // [End - Gestione Cruscotto - Revalutation - 21/04/2022]

        Boolean isATermination= false;

        XC_REST_GetSubscription.WrapperRequest inputField = new XC_REST_GetSubscription.WrapperRequest();
        inputField.stream = parent[0].XC_Asset__r.XC_Segment__c;
        inputField.legalEntity = parent[0].XC_Asset__r.XC_LegalEntity__c;
        String subscriptionName = parent[0].XC_Asset__r.XC_SubscriptionName__c;

        XC_REST_GetSubscription.WrapperResponse response = XC_REST_GetSubscription.retrieveSubscriptionByName(subscriptionName, inputField);
        response.integrationLog.XC_Log_TransactionId__c = parent[0].Id;
        integrationLogsToInsert.add(response.integrationLog);

        XC_REST_CancelSubscription.WrapperResponse responseCancelSub = new XC_REST_CancelSubscription.WrapperResponse();
        if (response.response != null && response.success) {
            // [Begin - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]
            if(!updatePrice){ // cancellation scheduled in a specific date for date changes
                Date specificDate;
                if(contractAmendment.XC_EndDateAfterLastExtension__c > contractAmendment.XC_EndDateBeforeExtension__c){ // extension
                    specificDate = (contractAmendment.XC_EndDateBeforeExtension__c != null) ? contractAmendment.XC_EndDateBeforeExtension__c.addDays(1): contractAmendment.XC_EndDateBeforeExtension__c;
                }else{ // termination
                    isATermination = true;
                    specificDate = (contractAmendment.XC_EndDateAfterLastExtension__c != null) ? contractAmendment.XC_EndDateAfterLastExtension__c.addDays(1): contractAmendment.XC_EndDateAfterLastExtension__c;
                }
                inputField.cancellationEffectiveDate = specificDate;
            } else if(updatePrice){ // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
                Date revaluationEffectiveDate = getRevaluationEffectiveDate(response);
                inputField.cancellationEffectiveDate = revaluationEffectiveDate;
                utilMap.put('revaluationEffectiveDate', revaluationEffectiveDate);
            }// [End - Gestione Cruscotto - Revalutation - 21/04/2022]

            // [End - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]
            responseCancelSub = XC_REST_CancelSubscription.cancelSubscriptionByName(subscriptionName, inputField);
            responseCancelSub.integrationLog.XC_Log_TransactionId__c = parent[0].Id;
            integrationLogsToInsert.add(responseCancelSub.integrationLog);
        } else {
            manageError(utilMap, ((response.reasons != null && !response.reasons.isEmpty()) ? response.reasons[0].message : ''));
            XC_UTIL_SObject.insertListRecords(integrationLogsToInsert);
            return;
        }

        if (responseCancelSub.response != null && responseCancelSub.success) {
            // [Begin - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]
            if(!isATermination){ // skip the creation of a new subscription if it is a termination
                infoResponse = manageSubscription(response, utilMap);
            }
            // [End - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]
        } else {
            manageError(utilMap, ((responseCancelSub.reasons != null && !responseCancelSub.reasons.isEmpty()) ? responseCancelSub.reasons[0].message : ''));
            XC_UTIL_SObject.insertListRecords(integrationLogsToInsert);
            return;
        }
        
        // [Begin - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]
        if(!isATermination){
            XC_REST_CreateSubscription.WrapperResponse responseCreateSub = new XC_REST_CreateSubscription.WrapperResponse();
            if (infoResponse.success) {
                responseCreateSub = XC_REST_CreateSubscription.createSubscription(inputField, JSON.serialize(infoResponse.subscription));
                responseCreateSub.integrationLog.XC_Log_TransactionId__c = parent[0].Id;
                integrationLogsToInsert.add(responseCreateSub.integrationLog);
            } else {
                //manageError(parent, childs, 'Error on manageSubscription method');
                manageError(utilMap, 'Error on manageSubscription method');
                XC_UTIL_SObject.insertListRecords(integrationLogsToInsert);
                return;
            }
            //manageCreateSubscriptionResponse(parent, childs, responseCreateSub);
            manageCreateSubscriptionResponse(utilMap, responseCreateSub);
        }else{ //skip the creation of a new subscription if it is a termination
            manageContractAmendmentUpdate(parent, childs);
        }

        XC_UTIL_SObject.insertListRecords(integrationLogsToInsert);
        // [End - Gestione Cruscotto - Schedule a future deactivation - 22/03/2022]

        infoResponse.success = true;
        infoResponse.errorMessage = '';
    }

    
    private static XC_REST_ContractAmendment.infoResponse manageSubscription(XC_REST_GetSubscription.WrapperResponse response, Map<String,Object> utilMap) {
        // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
        XC_ContractAmendment__c contractAmendment = (XC_ContractAmendment__c) utilMap.get('contractAmendment');
        XC_ContractAmendment__c contractAmendmentChild = (XC_ContractAmendment__c) utilMap.get('contractAmendmentChild'); 
        // [End - Gestione Cruscotto - Revalutation - 21/04/2022]

        XC_REST_ContractAmendment.infoResponse infoResponse = new XC_REST_ContractAmendment.infoResponse();
        Set<String> assetIdForRevaluation = populateAssetId(contractAmendment);
        List<Object> ratePlan = new List<Object>();
        List<Map<String, Object>> ratePlanCharge = new List<Map<String, Object>>();
        ratePlan = ((List<Object>) response.subscription.get('ratePlans'));
        Map<String, Object> infoToSendSubscription = new Map<String, Object>();
        Map<String, Object> mapRatePlan = new Map<String, Object>();
        List<Object> listInfoRatePlan = new List<Object>();
        Set<String> checkValueRatePlan = new Set<String>();
        Map<String, Object> newMapProduct = new Map<String, Object>();
        Set<String> setUniqueRP = new Set<String>();
        Set<String> setUniqueRPC = new Set<String>();
        Date specificEndDate = (contractAmendment.XC_Contract__r.EndDate != null) ?  contractAmendment.XC_Contract__r.EndDate.addDays(1) : contractAmendment.XC_Contract__r.EndDate;

        for (Object o : ratePlan) {
            Map<String, Object> infoToSendRatePlan = new Map<String, Object>();
            List<Object> linstIfoToSendRatePlanCharge = new List<Object>();
            Map<String, Object> p = (Map<String, Object>) o;
            System.debug('RatePlan' + o);
            if (p.get('lastChangeType') != 'Remove') {
                System.debug('Dentro if uniche' + o);
                Map<String, Object> ratePlanCharges = New Map<String, Object>();
                List<Object> tt = new List<Object>();
                tt = (List<Object>) p.get('ratePlanCharges');
                for (Object rpc : tt) {
                    Map<String, Object> infoToSendRatePlanCharge = new Map<String, Object>();
                    System.debug('RPC -->' + rpc);
                    Map<String, Object> rpcMap = (Map<String, Object>) rpc;
                    if (String.valueOf(rpcMap.get('type')) == 'Recurring' /*&& Date.valueOf(String.valueOf(rpcMap.get('effectiveEndDate'))) >= Date.today()*/) { //cr 772 vdb 18-07-22
                        
                        infoToSendRatePlanCharge.put('listPriceBase', rpcMap.get('listPriceBase'));
                        infoToSendRatePlanCharge.put('billCycleType', 'SpecificDayofMonth'); //rpcMap.get('billingDay'));
                        infoToSendRatePlanCharge.put('billCycleDay', '1');
                        infoToSendRatePlanCharge.put('billingPeriod', rpcMap.get('billingPeriod'));
                        infoToSendRatePlanCharge.put('specificBillingPeriod', rpcMap.get('specificBillingPeriod'));
                        infoToSendRatePlanCharge.put('billingTiming', rpcMap.get('billingTiming'));
                        infoToSendRatePlanCharge.put('billingPeriodAlignment', rpcMap.get('billingPeriodAlignment'));
                        infoToSendRatePlanCharge.put('quantity', rpcMap.get('quantity'));
                        /*infoToSendRatePlanCharge.put('triggerDate', rpcMap.get('triggerDate'));
                        infoToSendRatePlanCharge.put('triggerEvent', rpcMap.get('triggerEvent'));*/
                        infoToSendRatePlanCharge.put('CRMAssetID__c', rpcMap.get('CRMAssetID__c'));

                        if(updatePrice && rpcMap.get('CRMAssetID__c') != null && assetIdForRevaluation.contains(String.valueOf(rpcMap.get('CRMAssetID__c')))) { 
                            //infoToSendRatePlanCharge.put('endDateCondition', 'Specific_End_Date'); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            //infoToSendRatePlanCharge.put('specificEndDate', response.subscription.get('subscriptionEndDate'));
                            //infoToSendRatePlanCharge.put('specificEndDate', specificEndDate); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            infoToSendRatePlanCharge.put('price', calculateRevaluation(contractAmendmentChild, (Decimal) rpcMap.get('price')));
                            /*infoToSendRatePlanCharge.put('triggerDate', Date.today()); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            infoToSendRatePlanCharge.put('triggerEvent', 'USD');*/
                        } else {
                            //infoToSendRatePlanCharge.put('endDateCondition', 'Specific_End_Date'); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            //infoToSendRatePlanCharge.put('specificEndDate', (contractAmendment.XC_EndDateAfterLastExtension__c != null) ? contractAmendment.XC_EndDateAfterLastExtension__c : response.subscription.get('subscriptionEndDate'));*/
                            //infoToSendRatePlanCharge.put('specificEndDate', specificEndDate); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            //infoToSendRatePlanCharge.put('triggerEvent','UCA'); // [Gestione Cruscotto - Revalutation - 21/04/2022]
                            infoToSendRatePlanCharge.put('price', (Decimal) rpcMap.get('price'));
                        }
                        
                        //infoToSendRatePlanCharge.put('specificEndDate',rpcMap.get('specificEndDate'));
                        /*infoToSendRatePlanCharge.put('triggerDate', Date.today());
                        infoToSendRatePlanCharge.put('triggerEvent', 'USD');*/

                        // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
                        infoToSendRatePlanCharge.put('endDateCondition', 'Specific_End_Date'); 
                        infoToSendRatePlanCharge.put('specificEndDate', specificEndDate);
                        infoToSendRatePlanCharge.put('triggerEvent','UCA');
                        // [End - Gestione Cruscotto - Revalutation - 21/04/2022]

                        infoToSendRatePlanCharge.put('description', rpcMap.get('description'));
                        infoToSendRatePlanCharge.put('TariffType__c', rpcMap.get('TariffType__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidySubtype__c', rpcMap.get('XC_SubsidySubtype__c'));
                        infoToSendRatePlanCharge.put('XC_OvverideAccountingCode__c', rpcMap.get('XC_OvverideAccountingCode__c'));
                        infoToSendRatePlanCharge.put('XC_DaneCode__c', rpcMap.get('XC_DaneCode__c'));
                        infoToSendRatePlanCharge.put('XC_InvoiceDescription__c', rpcMap.get('XC_InvoiceDescription__c'));
                        infoToSendRatePlanCharge.put('XC_ProjectDimension__c', rpcMap.get('XC_ProjectDimension__c'));
                        infoToSendRatePlanCharge.put('XC_LawDescriptionCode__c', rpcMap.get('XC_LawDescriptionCode__c'));
                        infoToSendRatePlanCharge.put('XC_ExchangeRate__c', rpcMap.get('XC_ExchangeRate__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyCode__c', rpcMap.get('XC_SubsidyCode__c'));
                        infoToSendRatePlanCharge.put('XC_PercentualeSAL__c', rpcMap.get('XC_PercentualeSAL__c'));
                        infoToSendRatePlanCharge.put('XC_ProfitCenter__c', rpcMap.get('XC_ProfitCenter__c'));
                        infoToSendRatePlanCharge.put('XC_CostCenter__c', rpcMap.get('XC_CostCenter__c'));
                        infoToSendRatePlanCharge.put('IncludedkWh__c', rpcMap.get('IncludedkWh__c'));
                        infoToSendRatePlanCharge.put('XC_PriceBillingPlan__c', rpcMap.get('XC_PriceBillingPlan__c'));
                        infoToSendRatePlanCharge.put('XC_WBE__c', rpcMap.get('XC_WBE__c'));
                        infoToSendRatePlanCharge.put('XC_RagioneSAL__c', rpcMap.get('XC_RagioneSAL__c'));
                        infoToSendRatePlanCharge.put('XC_NumeroSAL__c', rpcMap.get('XC_NumeroSAL__c'));
                        infoToSendRatePlanCharge.put('XC_DynamicPropertyDefinition__c', rpcMap.get('XC_DynamicPropertyDefinition__c'));
                        infoToSendRatePlanCharge.put('XC_Hierarchy__c', rpcMap.get('XC_Hierarchy__c'));
                        infoToSendRatePlanCharge.put('XC_LawDescription__c', rpcMap.get('XC_LawDescription__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyForm__c', rpcMap.get('XC_SubsidyForm__c'));
                        infoToSendRatePlanCharge.put('XC_WBEStatus__c', rpcMap.get('XC_WBEStatus__c'));
                        infoToSendRatePlanCharge.put('XC_GoodAmount__c', rpcMap.get('XC_GoodAmount__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyDuration__c', rpcMap.get('XC_SubsidyDuration__c'));
                        infoToSendRatePlanCharge.put('LastModifiedBy__c', rpcMap.get('LastModifiedBy__c'));
                        infoToSendRatePlanCharge.put('XC_VASCode__c', rpcMap.get('XC_VASCode__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyAmount__c', rpcMap.get('XC_SubsidyAmount__c'));
                        infoToSendRatePlanCharge.put('XC_OriginalCurrencyPrice__c', rpcMap.get('XC_OriginalCurrencyPrice__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyType__c', rpcMap.get('XC_SubsidyType__c'));
                        infoToSendRatePlanCharge.put('XC_SubsidyCollectionType__c', rpcMap.get('XC_SubsidyCollectionType__c'));
                        infoToSendRatePlanCharge.put('XC_RootName__c', rpcMap.get('XC_RootName__c'));
                        infoToSendRatePlanCharge.put('productRatePlanChargeId', rpcMap.get('productRatePlanChargeId'));
                        linstIfoToSendRatePlanCharge.add(infoToSendRatePlanCharge);
                    }

                }


                if (!linstIfoToSendRatePlanCharge.isEmpty()) {
                    infoToSendRatePlan.put('XC_CentrodeCosto__c', p.get('XC_CentrodeCosto__c'));
                    infoToSendRatePlan.put('productRatePlanId', p.get('productRatePlanId'));
                    infoToSendRatePlan.put('RatePlanOptionId__QT', p.get('RatePlanOptionId__QT'));
                    infoToSendRatePlan.put('XC_bollo__c', p.get('XC_bollo__c'));
                    infoToSendRatePlan.put('RatePlanOptionOverrideId__QT', p.get('RatePlanOptionOverrideId__QT'));
                    infoToSendRatePlan.put('RatePlanOptionExtendId__QT', p.get('RatePlanOptionExtendId__QT'));
                    infoToSendRatePlan.put('RatePlanOptionGroupId__QT', p.get('RatePlanOptionGroupId__QT'));
                    infoToSendRatePlan.put('RatePlanOptionType__QT', p.get('RatePlanOptionType__QT'));
                    infoToSendRatePlan.put('XC_GoodAmount__c', p.get('XC_GoodAmount__c'));
                    infoToSendRatePlan.put('chargeOverrides', (List<Object>) linstIfoToSendRatePlanCharge);
                    listInfoRatePlan.add(infoToSendRatePlan);
                }

            }
        }

        infoToSendSubscription = response.subscription;
        // [Begin - Gestione Cruscotto - Calculate recurring duration and subscription start date - 22/03/2022]
        Integer recurringDuration;
        if(updateprice){
            Date revaluationEffectiveDate = (Date)utilMap.get('revaluationEffectiveDate');  // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
            recurringDuration = calculateRecurringDuration (revaluationEffectiveDate, contractAmendment.XC_Contract__r.EndDate, contractAmendment.XC_Asset__r.NE__RecurringChargeFrequency__c);
            infoToSendSubscription.put('contractEffectiveDate', revaluationEffectiveDate);
            infoToSendSubscription.put('serviceActivationDate', revaluationEffectiveDate);
            infoToSendSubscription.put('customerAcceptanceDate', revaluationEffectiveDate);
            infoToSendSubscription.put('termStartDate', revaluationEffectiveDate); // [End - Gestione Cruscotto - Revalutation - 21/04/2022]
            infoToSendSubscription.put('initialTerm', (recurringDuration == null || recurringDuration == 0) ? response.subscription.get('initialTerm'):  recurringDuration);
        }else{
            Date specificDate = (contractAmendment.XC_EndDateBeforeExtension__c != null) ? contractAmendment.XC_EndDateBeforeExtension__c.addDays(1): contractAmendment.XC_EndDateBeforeExtension__c;
            recurringDuration = calculateRecurringDuration (contractAmendment.XC_EndDateBeforeExtension__c , contractAmendment.XC_EndDateAfterLastExtension__c, contractAmendment.XC_Asset__r.NE__RecurringChargeFrequency__c);
            infoToSendSubscription.put('contractEffectiveDate', specificDate);
            infoToSendSubscription.put('serviceActivationDate', specificDate);
            infoToSendSubscription.put('customerAcceptanceDate', specificDate);
            infoToSendSubscription.put('termStartDate', specificDate);
            infoToSendSubscription.put('initialTerm', (recurringDuration == null || recurringDuration == 0) ? response.subscription.get('initialTerm'):  recurringDuration);
        }
        // [End - Gestione Cruscotto - Calculate recurring duration and subscription start date - 22/03/2022]
        infoToSendSubscription.put('accountKey',response.subscription.get('accountId'));
        infoToSendSubscription.put('runBilling',false); //vdb cr 772 18-07-22
        /*infoToSendSubscription.put('contractEffectiveDate',(Object) Date.today());
        infoToSendSubscription.put('serviceActivationDate',(Object) Date.today());
        infoToSendSubscription.put('customerAcceptanceDate',(Object) Date.today());*/
        infoToSendSubscription.remove('success');
        infoToSendSubscription.remove('id');
        infoToSendSubscription.remove('accountId');
        infoToSendSubscription.remove('accountNumber');
        infoToSendSubscription.remove('invoiceOwnerAccountId');
        infoToSendSubscription.remove('invoiceOwnerAccountNumber');
        infoToSendSubscription.remove('invoiceOwnerAccountName');
        infoToSendSubscription.remove('version');
        infoToSendSubscription.remove('subscriptionNumber');
        infoToSendSubscription.remove('ratePlans');
        infoToSendSubscription.put('subscribeToRatePlans', (Object) listInfoRatePlan);
        infoToSendSubscription.remove('paymentTerm');
        infoToSendSubscription.remove('billToContact');
        infoToSendSubscription.remove('status');
        infoToSendSubscription.remove('totalContractedValue');
        infoToSendSubscription.remove('contractedMrr');
        infoToSendSubscription.remove('currentTermPeriodType');
        infoToSendSubscription.remove('currentTerm');
        infoToSendSubscription.remove('termEndDate');
        infoToSendSubscription.remove('subscriptionEndDate');
        infoToSendSubscription.remove('revision');
        infoToSendSubscription.remove('accountName');
        infoToSendSubscription.remove('subscriptionStartDate');
        infoToSendSubscription.remove('cancelReason');
        infoToSendSubscription.remove('LastBookingDate'); // 05.07.2022 PRB000000141923 sooraji.sajan@accenture.com cr 772
		infoToSendSubscription.remove('isLatestVersion'); // 18-07-2022 vdb cr 772
        infoResponse.subscription = infoToSendSubscription;
        infoResponse.success = true;
        return infoResponse;
    }


    private static void manageError( Map<String,Object> utilMap, String messageError) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'messageError: ' + messageError);
        // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
        List<XC_ContractAmendment__c> parent = (List<XC_ContractAmendment__c>) utilMap.get('parent');
        List<XC_ContractAmendment__c> child = (List<XC_ContractAmendment__c>) utilMap.get('childs');
        Date revaluationEffectiveDate = (Date)utilMap.get('revaluationEffectiveDate');
        // [End - Gestione Cruscotto - Revalutation - 21/04/2022]

        for(XC_ContractAmendment__c c : child) {
            c.XC_Status__c = 'Error';
            c.XC_Error__c = 'ERROR on Zuora API flow';
            c.XC_ErrorDetail__c = messageError;
            c.XC_RevaluationEffectiveDate__c = revaluationEffectiveDate; // [Gestione Cruscotto - Revalutation - 21/04/2022]
        }

        parent[0].XC_Status__c = 'Error';
        parent[0].XC_Error__c = 'ERROR on Zuora API flow';
        parent[0].XC_ErrorDetail__c = messageError;
        parent[0].XC_RevaluationEffectiveDate__c = revaluationEffectiveDate; // [Gestione Cruscotto - Revalutation - 21/04/2022]
        child.add(parent[0]);
        XC_UTIL_SObject.updateListRecords(child);
    }


    private static void manageCreateSubscriptionResponse(Map<String,Object> utilMap, XC_REST_CreateSubscription.WrapperResponse responseCreateSub) {
        
        // [Begin - Gestione Cruscotto - Revalutation - 21/04/2022]
        List<XC_ContractAmendment__c> parent = (List<XC_ContractAmendment__c>) utilMap.get('parent');
        List<XC_ContractAmendment__c> child = (List<XC_ContractAmendment__c>) utilMap.get('childs');
        Date revaluationEffectiveDate = (Date)utilMap.get('revaluationEffectiveDate');
        // [End - Gestione Cruscotto - Revalutation - 21/04/2022]

        if(responseCreateSub.success) {

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'New Subscription: ' + responseCreateSub.subscriptionNumber);

            Map<Id, Asset> assetsToUpdate = new Map<Id, Asset>();
            Map<Id, NE__OrderItem__c> oiToUpdateMap = new Map<Id, NE__OrderItem__c>();
           
            for(XC_ContractAmendment__c c : child){
                c.XC_Status__c = 'Completed';
                c.XC_RevaluationEffectiveDate__c = revaluationEffectiveDate; // [Gestione Cruscotto - Revalutation - 21/04/2022]

                assetsToUpdate.put(c.XC_Asset__c, new Asset(Id = c.XC_Asset__c, XC_PreviousSubscriptionName__c = c.XC_Asset__r.XC_SubscriptionName__c, XC_SubscriptionName__c = responseCreateSub.subscriptionNumber , XC_Subscription__c = null));
                if(!String.isBlank(c.XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c)){ // remove the link to the quote to avoid overwriting the subscription name
                    oiToUpdateMap.put(c.XC_Asset__r.XC_Configuration_Item__c, new NE__OrderItem__c (Id = c.XC_Asset__r.XC_Configuration_Item__c, XC_ZQuoteId__c = null));
                }
                if(!String.isBlank(c.XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)){
                    oiToUpdateMap.put(c.XC_Asset__r.XC_Original_Configuration_Item__c, new NE__OrderItem__c (Id = c.XC_Asset__r.XC_Original_Configuration_Item__c, XC_ZQuoteId__c = null));
                }
            }

            parent[0].XC_Status__c = 'Completed';
            parent[0].XC_RevaluationEffectiveDate__c = revaluationEffectiveDate; // [Gestione Cruscotto - Revalutation - 21/04/2022]
            child.add(parent[0]);
            assetsToUpdate.put(parent[0].XC_Asset__c, new Asset(Id = parent[0].XC_Asset__c, XC_PreviousSubscriptionName__c = parent[0].XC_Asset__r.XC_SubscriptionName__c, XC_SubscriptionName__c = responseCreateSub.subscriptionNumber, XC_Subscription__c = null));
            if(!parent.isEmpty()){ // remove the link to the quote to avoid overwriting the subscription name
                if(!String.isBlank(parent[0].XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c)){
                    oiToUpdateMap.put(parent[0].XC_Asset__r.XC_Configuration_Item__c, new NE__OrderItem__c (Id = parent[0].XC_Asset__r.XC_Configuration_Item__c, XC_ZQuoteId__c = null));
                }
                if(!String.isBlank(parent[0].XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)){
                    oiToUpdateMap.put(parent[0].XC_Asset__r.XC_Original_Configuration_Item__c, new NE__OrderItem__c (Id = parent[0].XC_Asset__r.XC_Original_Configuration_Item__c, XC_ZQuoteId__c = null));
                }
            }
            
            if(updatePrice){
                String contractID = !parent.isEmpty() && !String.isBlank(parent[0].XC_Contract__c) ? parent[0].XC_Contract__c : child[0].XC_Contract__c;
                if(!String.isBlank(contractID)) {
                    Map<Id,Asset> mapAsset = new Map<Id,Asset>([SELECT XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Configuration_Item__r.XC_ZQuoteId__c 
                                                                FROM Asset 
                                                                WHERE XC_BillingModel__c =: Label.XC_CL_BillingModel_Recurring AND NE__EndDate__c >= TODAY AND  
                                                                Status =: Label.XC_CL_Asset_StatusActive AND XC_Contract__c =:contractID AND XC_Particle__c = 'TRUE'
                                                                AND XC_LegalEntity__c =: Label.XC_CL_LegalEntity_EnelSole]);
                    if(!mapAsset.isEmpty()){
                        for(Asset ass : mapAsset.values()){
                            if(!String.isBlank(ass.XC_Configuration_Item__r.XC_ZQuoteId__c)){
                                oiToUpdateMap.put(ass.XC_Configuration_Item__c, new NE__OrderItem__c (Id = ass.XC_Configuration_Item__c, XC_ZQuoteId__c = null));
                            }
                            if(!String.isBlank(ass.XC_Original_Configuration_Item__r.XC_ZQuoteId__c)){
                                oiToUpdateMap.put(ass.XC_Original_Configuration_Item__c, new NE__OrderItem__c (Id =ass.XC_Original_Configuration_Item__c, XC_ZQuoteId__c = null));
                            }
                        }
                    }
                }
            }


            XC_UTIL_SObject.updateListRecords(child);
            XC_UTIL_SObject.updateListRecords(assetsToUpdate.values());
            if(!oiToUpdateMap.isEmpty()){
                XC_UTIL_SObject.updateListRecords(oiToUpdateMap.values());
            }
        } else {
            manageError(utilMap, ((responseCreateSub.reasons != null && !responseCreateSub.reasons.isEmpty()) ? responseCreateSub.reasons[0].message : ''));
        }
        
    }

    /**
	* @description manage the contract amendment update
    * @param parent - List<XC_ContractAmendment__c>
    * @param child - List<XC_ContractAmendment__c>
	**/
    private static void manageContractAmendmentUpdate(List<XC_ContractAmendment__c> parent, List<XC_ContractAmendment__c> child) {

        for(XC_ContractAmendment__c c : child){
            c.XC_Status__c = 'Completed';
        }

        if(!parent.isEmpty()){
            parent[0].XC_Status__c = 'Completed';
            child.add(parent[0]);
        }
        
        if(!child.isEmpty()){
            XC_UTIL_SObject.updateListRecords(child);
        }
        
    }


    private static String calculateRevaluation(XC_ContractAmendment__c c, Decimal price){
        Decimal difference = 0;
        Decimal renewal = 0;
        if(price != null && c.XC_Percentage__c != null){
           renewal =  price * c.XC_Percentage__c / 100;
           renewal = renewal + price;
        }
        return String.valueOf(renewal);


    }

    private static Set<String> populateAssetId(XC_ContractAmendment__c contractAmendment){
        Set<String> assetIdForRevaluation = new Set<String>();
        if(String.isNotBlank(contractAmendment.XC_Asset__r.XC_Particle__c) && contractAmendment.XC_Asset__r.XC_Particle__c.equalsIgnoreCase('false')) {
            assetIdForRevaluation.add(contractAmendment.XC_Asset__r.id);
        }

        for(XC_ContractAmendment__c ca : contractAmendment.XC_ContractAmendmentsChilds__r){
            if(String.isNotBlank(ca.XC_Asset__r.XC_Particle__c) && ca.XC_Asset__r.XC_Particle__c.equalsIgnoreCase('false')) {
                assetIdForRevaluation.add(ca.XC_Asset__r.id);
            }
        }

        return assetIdForRevaluation;
    }


    /**
	* @description calculates the recurring duration
    * @param startdate - date
    * @param endDate - date
    * @param billingFrequency - string
    * @return Integer
	**/
    private static Integer calculateRecurringDuration(Date startdate, Date endDate, String billingFrequency){

        Integer recurringDuration = 0; 

        if(!String.isBlank(billingFrequency) && startDate != null && endDate != null){
            startDate = Date.newInstance(startDate.year(),startDate.month(),startDate.day());
            endDate = Date.newInstance(endDate.year(),endDate.month(),endDate.day());
            if (billingFrequency.equalsIgnoreCase('Biennial') || billingFrequency.equalsIgnoreCase('Annual')){
                recurringDuration = ((startDate.monthsBetween(endDate)) / 12) + 1 ;
            } else{
                recurringDuration = (startDate.monthsBetween(endDate)) + 1 ;
            }
        }

        return recurringDuration;
    }

    
    /**
	* @description method to retrieve the last invoice date to be used in case of contract revaluation 
    * @param response - XC_REST_GetSubscription.WrapperResponse
    * @return Date
	**/
    private static Date getRevaluationEffectiveDate(XC_REST_GetSubscription.WrapperResponse response){
        
        //assumption: the root is not removed, if there are several roots the date is the same 
        List<Object> ratePlan = ((List<Object>) response.subscription.get('ratePlans'));
        Date revaluationEffectiveDate = Date.today();
        Boolean foundDate = false;
        for (Object obj : ratePlan) {
            Map<String, Object> rp = (Map<String, Object>) obj;
            List<Object> tt = (List<Object>) rp.get('ratePlanCharges');
            for (Object rpc : tt) {
                Map<String, Object> rpcMap = (Map<String, Object>) rpc;
                if (!String.isBlank(String.valueOf(rpcMap.get('XC_Hierarchy__c'))) && String.valueOf(rpcMap.get('XC_Hierarchy__c')).equalsIgnoreCase('Root')){
                    revaluationEffectiveDate =  !String.isBlank(String.valueOf(rpcMap.get('chargedThroughDate'))) ? Date.valueOf(String.valueOf(rpcMap.get('chargedThroughDate'))) : (!String.isBlank(String.valueOf(rpcMap.get('effectiveStartDate')))) ? Date.valueOf(String.valueOf(rpcMap.get('effectiveStartDate'))): Date.today();
                    foundDate = true;
                    break;
                }
            }
            if(foundDate){
                break;
            }
        }

        return revaluationEffectiveDate;      
    }
}