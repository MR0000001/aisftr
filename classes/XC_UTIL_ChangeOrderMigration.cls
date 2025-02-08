/**
 * The XC_UTIL_ChangeOrderMigration Class.
 *
 * @author: Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation: 25/03/2020
 * @date Modification: dd/mm/yyyy
 * @description: UTIL class for Migration ChangeOrder 
 */ 


public without sharing class XC_UTIL_ChangeOrderMigration {

    public final static Boolean DEBUGACTIVE = true;

    /**
     * @description RatePlanWrapper
     */ 
    public class RatePlanWrapper{
        public List<String> listRatePlanAdd = new List<String>();
        public List<String> listRatePlanRemove = new List<String>();
    }

    /**
     * @description QuoteWrapper
     */ 
    public class QuoteWrapper{
        public List<String> listRatePlanAdd = new List<String>();
        public List<String> listRatePlanRemove = new List<String>();
        public String orderId;
        public String stepId;
        public String confItemId;
        public NE__OrderItem__c item;
        public NE__OrderItem__c confItemMalfunction;
        public Map<String, List<String>> prpcConfItemsMap;
        public String subNumber;
        public Boolean mixedVat; 
    }


    /**
     * @description class to the the logic of Change Provisioning Billing Process for Migration
     * @param inputMap the map string - object
     */
    public static void migrationPayAndBill(Map<String, Object> inputMap) {

        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = (XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems) inputMap.get('wr');
        Map<String, List<String>> mapItemAddRP = (Map<String, List<String>>) inputMap.get('mapItemAddRP');
        Map<String, List<String>> mapItemRemoveRP = (Map<String, List<String>>) inputMap.get('mapItemRemoveRP');
        String subNumber = (String) inputMap.get('subNumber');
        String orderId = (String) inputMap.get('orderId');
        String confItemId = (String) inputMap.get('confItemId');
        String stepId = (String) inputMap.get('stepId');
        NE__OrderItem__c confItemMalfunction = (NE__OrderItem__c) inputMap.get('confItemMalfunction');
        Map<String, List<String>> prpcConfItemsMap = (Map<String, List<String>>) inputMap.get('prpcConfItemsMap');

        RatePlanWrapper rpWrapper = cycleOnAsset(wr, mapItemAddRP, mapItemRemoveRP);

        QuoteWrapper quoteWr = new QuoteWrapper();
        quoteWr.listRatePlanAdd = rpWrapper.listRatePlanAdd;
        quoteWr.listRatePlanRemove = rpWrapper.listRatePlanRemove;
        quoteWr.subNumber = subNumber;
        quoteWr.orderId = orderId;
        quoteWr.confItemId = confItemId;
        quoteWr.stepId = stepId;
        quoteWr.prpcConfItemsMap = prpcConfItemsMap;
        quoteWr.confItemMalfunction = confItemMalfunction;
        quoteWr.mixedVat = wr.mixedVat;
        String newZquoteID = addRemoveProductsAmendmentQuote(quoteWr);
        if(String.isBlank(newZquoteID)) {
            return;
        }

        // Update Order Items with zQuoteId
        Map<Id, NE__OrderItem__c> confItemToUpdateList = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : wr.mapNewItems.values()) {
            if(oi.NE__Action__c != 'Remove'){
                oi.XC_ZQuoteId__c = newZquoteID;
                confItemToUpdateList.put(oi.Id, oi);
            }
        }
        XC_UTIL_Sobject.updateListRecords(confItemToUpdateList.values());

        // Update the XC_Original_Configuration_Item__c field (LABEL Previous Order Item) with the actual Order Item that have the new zquote
        Map<Id, Asset> assetToUpdateList = new Map<Id, Asset>();
        for(Asset a : wr.listAsset) {
            if(confItemToUpdateList.keySet().contains(a.XC_Configuration_Item__c)) {
                Asset aTemp = a;
                aTemp.XC_Original_Configuration_Item__c = a.XC_Configuration_Item__c;
                assetToUpdateList.put(aTemp.Id, aTemp);
            }
        }
        XC_UTIL_Sobject.updateListRecords(assetToUpdateList.values());
    }


    /**
     * @description cycle on asset to populate Rate Plan List for Migration
     * @param wr the asset wrapper
     * @param mapItemAddRP the map Item Add RP
     * @param mapItemRemoveRP the map Item Remove RP 
     * @return RatePlanWrapper the wrapper of the Rate Plan
     */
    public static RatePlanWrapper cycleOnAsset(XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr, Map<String, List<String>> mapItemAddRP, Map<String, List<String>> mapItemRemoveRP){
        
        RatePlanWrapper rpWrapper= new RatePlanWrapper();
        String newItemId;
        NE__OrderItem__c newItem;
        List<String> listRatePlanAddTmp;
        List<String> listRatePlanRemoveTmp;
        List<String> listRatePlanAdd =  new List<String>();
        List<String> listRatePlanRemove =  new List<String>();

        for(Asset a : wr.listAsset) {
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### asset da wr.ListAsset ' + a);

            system.debug('NEWITEM' + wr.mapNewItems);
            newItemId = a.XC_Configuration_Item__c;
            newItem = XC_IN011_ChangeProvBillingProcess_U.newItem(newItemId, wr);
            if(newItem == null) {
                continue;
            }

            listRatePlanRemoveTmp = mapItemRemoveRP.get(newItemId);
            listRatePlanAddTmp = mapItemAddRP.get(newItemId);
        
            if(newItem.NE__Action__c == 'Add') {
               /*			   if(listRatePlanAdd == null) {
                    listRatePlanAdd = new List<String>();
                }
                if(listRatePlanAddTmp != null) {
                    listRatePlanAdd.addAll(listRatePlanAddTmp);
                }*/
                
				manageAddRatePlan(listRatePlanAdd, listRatePlanAddTmp);

            } else if(newItem.NE__Action__c == 'Remove') {
                /*if(listRatePlanRemove == null) {
                    listRatePlanRemove = new List<String>();
                }
                if(listRatePlanRemoveTmp != null) {
                    listRatePlanRemove.addAll(listRatePlanRemoveTmp);
                }*/
                manageRemoveRatePlan(listRatePlanRemove,listRatePlanRemoveTmp);

            } else if(newItem.NE__Action__c == 'Change'){
                /*  if(listRatePlanAdd == null) {
                    listRatePlanAdd = new List<String>();
                }
                if(listRatePlanAddTmp != null) {
                    listRatePlanAdd.addAll(listRatePlanAddTmp);
                }
                 if(listRatePlanRemove == null) {
                    listRatePlanRemove = new List<String>();
                }
                if(listRatePlanRemoveTmp != null) {
                    listRatePlanRemove.addAll(listRatePlanRemoveTmp);
                }*/
                manageAddRatePlan(listRatePlanAdd, listRatePlanAddTmp);
                manageRemoveRatePlan(listRatePlanRemove,listRatePlanRemoveTmp);
            }
        }    


        rpWrapper.listRatePlanAdd = listRatePlanAdd;
        rpWrapper.listRatePlanRemove = listRatePlanRemove;

        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@listRatePlanAdd@'+listRatePlanAdd);
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@listRatePlanRemove@'+listRatePlanRemove);

        return rpWrapper;
    }


    /**
     * @description method to populate rate plan  add list
     * @param listRatePlanAdd
     * @param listRatePlanAddTmp
    */ 
    private static void manageAddRatePlan(List<String> listRatePlanAdd, List<String> listRatePlanAddTmp){

        /*if(listRatePlanAdd == null) {
            listRatePlanAdd = new List<String>();
        }*/
        if(listRatePlanAddTmp != null) {
            listRatePlanAdd.addAll(listRatePlanAddTmp);
        }
    }


    /**
     * @description method to populate rate plan remove list
     * @param listRatePlanRemove
     * @param listRatePlanRemoveTmp
    */ 
    private static void manageRemoveRatePlan(List<String> listRatePlanRemove, List<String> listRatePlanRemoveTmp){

        /*if(listRatePlanRemove == null) {
            listRatePlanRemove = new List<String>();
        }*/
        if(listRatePlanRemoveTmp != null) {
            listRatePlanRemove.addAll(listRatePlanRemoveTmp);
        }
    }


    /**
     * @description method to populate wrapper for Add/Remove Product
     * @param quoteWr
     * @return the zquote id
     */ 
    public static String addRemoveProductsAmendmentQuote(QuoteWrapper quoteWr){

        List<String> listRatePlanAdd = quoteWr.listRatePlanAdd;
        List<String> listRatePlanRemove = quoteWr.listRatePlanRemove;
        String orderId = quoteWr.orderId;
        
        XC_TR_Configuration_U_ChangeOrder.UtilWrapper wrapper = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
        wrapper.orderId = orderId;
        wrapper.stepId = quoteWr.stepId;
        wrapper.confItemId = quoteWr.confItemId;
        wrapper.confItem = quoteWr.item;
        wrapper.prpcConfItemsMap = quoteWr.prpcConfItemsMap;
        wrapper.subNumber = quoteWr.subNumber;
        wrapper.confItemMalfunction = quoteWr.confItemMalfunction; 
        wrapper.mixedVat = quoteWr.mixedVat;

        if(!listRatePlanAdd.isEmpty() && !listRatePlanRemove.isEmpty()) {
            wrapper.ratePlanAddList = listRatePlanAdd;
            wrapper.ratePlanRemoveList = listRatePlanRemove;
        } else if(!listRatePlanAdd.isEmpty() && listRatePlanRemove.isEmpty()){
            wrapper.ratePlanAddList = listRatePlanAdd;
            wrapper.ratePlanRemoveList = null;
        } else if(listRatePlanAdd.isEmpty() && !listRatePlanRemove.isEmpty()){
            wrapper.ratePlanAddList =null;
            wrapper.ratePlanRemoveList = listRatePlanRemove;
        }

        String newZquoteId = createAddRemoveProductsAmendmentQuote(wrapper);

        return newZquoteId;
    }


    /**
	 * @description creates the add remove products amendment quote
	 * @param wrapper the Util Wrapper
     * @return the zquote id
	 */
	public static String createAddRemoveProductsAmendmentQuote(XC_TR_Configuration_U_ChangeOrder.UtilWrapper wrapper){

        String subNumber = wrapper.subNumber;
        String orderId = wrapper.orderId;
        List<String> ratePlanAddList = wrapper.ratePlanAddList;
        List<String> ratePlanRemoveList = wrapper.ratePlanRemoveList;
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr;

        Map<Id,Zuora__Subscription__c> subscriptionListMap = new Map<Id,Zuora__Subscription__c>([SELECT Id, Name, Zuora__External_Id__c, Zuora__OriginalId__c, Zuora__NextChargeDate__c, Zuora__NextRenewalDate__c, 
                                                                                                    Zuora__CustomerAccount__r.Zuora__External_Id__c, Zuora__Version__c, Zuora__ContractEffectiveDate__c,
                                                                                                    Zuora__TermEndDate__c, Zuora__Status__c, Zuora__RenewalTerm__c, Zuora__AutoRenew__c, Zuora__TermStartDate__c
                                                                                                FROM Zuora__Subscription__c  
                                                                                                WHERE Zuora__SubscriptionNumber__c =: subNumber LIMIT 1]);
        if(subscriptionListMap.isEmpty()) {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = wrapper.stepId;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            stepToUpdate.XC_ErrorMessage__c = 'Subscription ' + subNumber + ' not found';
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return '';
        }

        if(subscriptionListMap.values()[0].Zuora__Status__c == 'Cancelled') {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = wrapper.stepId;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_Skipped;
            stepToUpdate.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return'';
        }

        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, XC_Product_Subtype__c, NE__OrderId__c,
                                                                                NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_Duration__c, NE__CatalogItem__r.XC_AutoRenewal__c, NE__CatalogItem__r.CurrencyIsoCode, NE__Action__c,
                                                                                NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c, NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c,
                                                                                (SELECT Id, NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r)

                                                                                FROM NE__OrderItem__c
                                                                                //WHERE Id =: wrapper.confItemId]);
                                                                                WHERE NE__OrderId__c =: orderId]);
        NE__OrderItem__c item;
        if(!orderItemMap.isEmpty()) {
            item = orderItemMap.get(wrapper.confItemId);
            entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, item.NE__OrderId__r.XC_Segment__c, wrapper.stepId);
            if(entityWr == null){
                return '';
            }
            
            if(item.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c.containsIgnoreCase('mobility')) {
                wrapper.postponeTermDate = true;
                for(NE__OrderItem__c oi : orderItemMap.values()) {
                    if(oi.NE__Action__c == 'Remove') {
                        for(NE__Order_Item_Attribute__c attrib : oi.NE__Order_Item_Attributes__r) {
                            if(attrib.XC_DeveloperName__c == 'Remove Immediately' && String.isNotBlank(attrib.NE__Value__c) &&  attrib.NE__Value__c.equalsIgnoreCase('TRUE')) {
                                wrapper.postponeTermDate = false;
                                break;
                            }
                        }
                    }
                }
            }
        }
        wrapper.confItem = item;
        
		//Creo uno zQuote di tipo amendment sfruttando il datamap ChangeOrder2Zquote
		NE.DataMap.DataMapResponse dResp = XC_TR_Configuration_U_ChangeOrder.getZQuoteFromDataMap(orderId);
		
		//Sovrascrivo lo zquoteid dell'order con il nuovo zQuoteId
		Id newZQuoteId = dResp.Parentid;
        wrapper.newZQuoteId = newZQuoteId;
	    System.debug('newZQuoteId --> ' + newZQuoteId);
	    
        Zuora__Subscription__c subscription = subscriptionListMap.values()[0];
		String subscriptionZuoraId = subscription.Zuora__External_Id__c;
		String zuoraAccountId = subscription.Zuora__CustomerAccount__r.Zuora__External_Id__c;
        wrapper.nextChargeDate = subscription.Zuora__NextRenewalDate__c;
 
		/*Eseguo un update dello zQuote rendendolo di tipo Amendment memorizzando nel campo
		zqu__ExistSubscriptionID__c il SubscriptionZuoraId nel caso in cui non esiste alcun
		amendment precedentemente creato, CurrentSubscription in caso contrario, popolando
		tutti i campi required*/
		zqu__Quote__c newZquote = new zqu__Quote__c(Id = newZQuoteId);
        newZquote.zqu__ZuoraAccountID__c = zuoraAccountId;
        newZquote.zqu__ExistSubscriptionID__c = subscriptionZuoraId;
        newZQuote.XC_SubscriptionName__c = subNumber;

        if(!String.isBlank(entityWr.entityId)){
            Map<Id, zqu__BillingEntity__c> billingEntityMap = new Map<Id, zqu__BillingEntity__c>([SELECT Id FROM zqu__BillingEntity__c WHERE zqu__EntityID__c =: entityWr.entityId]);
            newZQuote.zqu__BillingEntity__c = billingEntityMap.values()[0].Id;
            newZQuote.zqu__ZuoraEntityId__c = entityWr.entityId;
        }

        String startDateLocal;
        if(String.isNotBlank(entityWr.timeZone)) {
            startDateLocal = DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
            System.debug('StartDate (local time): ' + startDateLocal);
        } else {
            startDateLocal = String.valueOf(Date.Today());
            System.debug('StartDate (user local time): ' + startDateLocal);
        }

        String currentDateLocal = String.isNotBlank(String.valueOf(wrapper.confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c)) ? String.valueOf(wrapper.confItem.NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c) : startDateLocal;
        System.debug('currentLocal (user local time): ' + currentDateLocal);
        System.debug('Zuora__TermEndDate__c: ' + subscription.Zuora__TermEndDate__c);
        System.debug('Zuora__ContractEffectiveDate__c: ' + subscription.Zuora__ContractEffectiveDate__c);
        if(subscription != null){
            if(String.valueOf(subscription.Zuora__TermEndDate__c)!=null && currentDateLocal > String.valueOf(subscription.Zuora__TermEndDate__c)){
                currentDateLocal = String.valueOf(subscription.Zuora__TermEndDate__c);
            }else if(String.valueOf(subscription.Zuora__ContractEffectiveDate__c)!=null && currentDateLocal < String.valueOf(subscription.Zuora__ContractEffectiveDate__c)){
                currentDateLocal = String.valueOf(subscription.Zuora__ContractEffectiveDate__c);
            }
            //20220204 HotTopic_PROV_30 - [DO] – start
            else if(String.valueOf(subscription.Zuora__TermStartDate__c)!= null && currentDateLocal < String.valueOf(subscription.Zuora__TermStartDate__c)){
                currentDateLocal = String.valueOf(subscription.Zuora__TermStartDate__c);
                List<XC_Provisioning_Step__c> stepListToUpdate = new List<XC_Provisioning_Step__c>();
                XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
                stepToUpdate.id = wrapper.stepId;
                stepToUpdate.XC_Action_Start_Date__c = subscription.Zuora__TermStartDate__c;
                stepToUpdate.XC_Action_Date_Reason__c = Label.XC_CL_AmendDateEarlierSuspendDate;
                stepListToUpdate.add(stepToUpdate);
                if(!stepListToUpdate.isEmpty()){
                    XC_UTIL_Sobject.updateListRecords(stepListToUpdate);
                }                
            }
            //20220204 HotTopic_PROV_30 - [DO] – end
        }
        System.debug('currentLocal (user local time): ' + currentDateLocal);

        wrapper.startDateLocal = Date.valueOf(currentDateLocal);
        wrapper.existingSubscriptionId = newZquote.zqu__ExistSubscriptionID__c;
        wrapper.subscriptionTermEndDate = subscription.Zuora__TermEndDate__c;
        wrapper.subscriptionAutoRenew = subscription.Zuora__AutoRenew__c;
        wrapper.subscriptionRenewalTerm = subscription.Zuora__RenewalTerm__c;
        
	    newZquote.zqu__Amendment_Name__c = 'Modifica ' + dResp.Parentid;
        newZquote.zqu__currency__c = wrapper.confItem.NE__CatalogItem__r.CurrencyIsoCode;
        newZquote.CurrencyIsoCode = wrapper.confItem.NE__CatalogItem__r.CurrencyIsoCode;

		newZquote.zqu__ValidUntil__c = Date.valueOf(currentDateLocal);
        newZquote.zqu__StartDate__c = Date.valueOf(currentDateLocal);
        //newZquote.zqu__Subscription_Term_Type__c = 'Termed';					### Taken from DataMap ###

		newZquote.zqu__SubscriptionVersion__c = Integer.valueOf(subscription.Zuora__Version__c) + 1;
		newZquote.zqu__InitialTerm__c = wrapper.confItem.XC_Duration__c != null ? wrapper.confItem.XC_Duration__c : 36;
        newZquote.zqu__AutoRenew__c = wrapper.confItem.NE__CatalogItem__r.XC_AutoRenewal__c != null ? wrapper.confItem.NE__CatalogItem__r.XC_AutoRenewal__c : false;
		//newZquote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';		### Taken from DataMap ###
		newZquote.zqu__RenewalTerm__c = newZquote.zqu__InitialTerm__c;

        newZquote.zqu__SubscriptionTermStartDate__c = Date.valueOf(currentDateLocal);
        newZquote.zqu__SubscriptionTermEndDate__c = Date.valueOf(currentDateLocal) + 360;
		newZquote.zqu__Service_Activation_Date__c = Date.valueOf(currentDateLocal);

		newZquote.XC_ProvisioningStep__c = wrapper.stepId;
        newZquote.zqu__InvoiceSeparately__c = false;
        newZquote.zqu__GenerateInvoice__c = false;
        newZquote.XC_ConfigurationItem__c = wrapper.confItemId;
		newZquote.RecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        if(wrapper.mixedVat != null){
            newZquote.XC_MixedVat__c = XC_UTIL_Integration.convertFromBooleanToString (wrapper.mixedVat);
        }

		XC_UTIL_Sobject.updateRecord(newZquote);

        if(!Test.isRunningTest()) {
            XC_TR_Configuration_U_ChangeOrder.enqueueJob(wrapper);
        }

		return newZquote.Id;
	}

}