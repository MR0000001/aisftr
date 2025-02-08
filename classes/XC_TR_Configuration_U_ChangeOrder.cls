/**
 * The Class XC_TR_Configuration_U_ChangeOrder.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 28/02/2019
 * @date Modification : 13/08/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : XC_TR_Configuration_U_ChangeOrder
 */
 

public without sharing class XC_TR_Configuration_U_ChangeOrder {


    /**
     * @description Utility wrapper
     */
    public class UtilWrapper{
        public String orderId;
        public String originalZQuoteId;
        public List<String> ratePlanAddList = new List<String>();
        public List<String> ratePlanRemoveList = new List<String>();
        public String stepId;
        public String confItemId;
        public NE__OrderItem__c confItem;
        public Boolean postponeTermDate = false;
        public Date nextChargeDate;
        public String newZQuoteId;
        public NE__OrderItem__c confItemMalfunction;
        public Map<String, List<String>> prpcConfItemsMap;
        public String subNumber;
        public Boolean mixedVat;
        public Date startDateLocal; 
        public String existingSubscriptionId;
        public Date subscriptionTermEndDate;
        public Boolean subscriptionAutoRenew;
        public String subscriptionRenewalTerm;
        public Date subscriptionServiceActionDate;//[TP - 2021.11.27 - TPB change plan]
        public List<zqu__QuoteRatePlanCharge__c> qrpcList = new List<zqu__QuoteRatePlanCharge__c>();
        public Boolean isContractAmendmentChangeDate = false;
    }
    

    /**
     * @description The Class ManageDMLQueuable.
     */
    public class ManageDMLQueuable implements Queueable , Database.AllowsCallouts{
        
        Id zquoteId;
        List<String> ratePlanAddList; 
        List<String> ratePlanRemoveList;
        UtilWrapper wrapper;
        
        /**
         * @description Instantiates a new manage DML queuable.
         *
         * @param zquoteId the zquote id
         * @param ratePlanAddList the rate plan add list
         * @param ratePlanRemoveList the rate plan remove list
         */
        public ManageDMLQueuable(UtilWrapper wrapper){
            this.wrapper = wrapper;
        }
        
        /**
         * @description Execute.
         *
         * @param context the context
         */
        public void execute(QueueableContext context) {
        	if(this.wrapper.ratePlanAddList != null && !this.wrapper.ratePlanAddList.isEmpty()) {
                System.debug('@@@ ratePlanAddList --> ' +  this.wrapper.ratePlanAddList);
        		b2wzc.Bit2Win_OrderConnector.AddQuoteRatePlanFromRatePlan(this.wrapper.newZQuoteId, this.wrapper.ratePlanAddList);

                if(!Test.isRunningTest()) { // update rate plan charge in add
                    Map<String, Object> mapUtil = new Map<String, Object>{ 'newZQuoteId' => this.wrapper.newZQuoteId,
                                                                            'listRatePlans' => this.wrapper.ratePlanAddList,
                                                                            'prpcConfItemsMap' => this.wrapper.prpcConfItemsMap,
                                                                            'confItemMalfunction' => this.wrapper.confItemMalfunction
                                                                            };
                    XC_IN018_CreateZQuote_U.updateRatePlanCharge(mapUtil);
                    this.wrapper.qrpcList = (List<zqu__QuoteRatePlanCharge__c>) mapUtil.get('qrpcList');
                }
			}
            if(!Test.isRunningTest()) {
            	System.enqueueJob(new DeleteFutureQueuable(this.wrapper));    
            }
        }
	}

    
    /**
     * @description The Class DeleteFutureQueuable.
     */
    public class DeleteFutureQueuable implements Queueable , Database.AllowsCallouts{
        
        UtilWrapper wrapper;
        
        /**
         * @description Instantiates a new delete future queuable.
         *
         * @param zquoteId the zquote id
         * @param ratePlanAddList the rate plan add list
         * @param ratePlanRemoveList the rate plan remove list
         */
        public DeleteFutureQueuable(UtilWrapper wrapper){
            this.wrapper = wrapper;
        }
        
        /**
         * @description Execute.
         *
         * @param context the context
         */
        public void execute(QueueableContext context) {
        	if(this.wrapper.ratePlanRemoveList != null && !this.wrapper.ratePlanRemoveList.isEmpty()) {
                System.debug('@@@ ratePlanRemoveList --> ' +  this.wrapper.ratePlanRemoveList);
        		b2wzc.Bit2Win_OrderConnector.RemoveQuoteRatePlanFromRatePlan(this.wrapper.newZQuoteId, this.wrapper.ratePlanRemoveList);
                updateRemoveAmendment(this.wrapper.newZQuoteId, this.wrapper.postponeTermDate, this.wrapper.nextChargeDate);
        	}
        	/*if(!Test.isRunningTest() && ((this.wrapper.ratePlanAddList != null && !this.wrapper.ratePlanAddList.isEmpty()) || (this.wrapper.ratePlanRemoveList != null && !this.wrapper.ratePlanRemoveList.isEmpty()))){
				System.enqueueJob(new SendFutureQueuable(wrapper));
			}*/
            if(!Test.isRunningTest() && this.wrapper.subscriptionTermEndDate != null && !this.wrapper.qrpcList.isEmpty() && (this.wrapper.isContractAmendmentChangeDate || (String.isNotBlank(this.wrapper.confItem.NE__OrderId__r.XC_Subtype__c) && this.wrapper.confItem.NE__OrderId__r.XC_Subtype__c.equalsIgnoreCase('Promocode application')))) {
                System.enqueueJob(new TermsAndContitionsAmendmentQueuable(wrapper));
            } else if(!Test.isRunningTest() && ((this.wrapper.ratePlanAddList != null && !this.wrapper.ratePlanAddList.isEmpty()) || (this.wrapper.ratePlanRemoveList != null && !this.wrapper.ratePlanRemoveList.isEmpty()))) {
                System.enqueueJob(new SendFutureQueuable(wrapper));
            }
        }
	}


    /**
     * @description The Class TermsAndContitionsAmendmentQueuable.
     */
    public class TermsAndContitionsAmendmentQueuable implements Queueable , Database.AllowsCallouts{
        
        UtilWrapper wrapper;

        /**
         * @description Instantiates a new send future queuable.
         *
         * @param zquoteIds the zquote ids
         */
        public TermsAndContitionsAmendmentQueuable(UtilWrapper wrapper){
            this.wrapper = wrapper;
        }
        
        /**
         * @description Execute.
         *
         * @param context the context
         */
        public void execute(QueueableContext context) {
            
            List<zqu__QuoteRatePlanCharge__c> qrpcList = this.wrapper.qrpcList;
            Date termEndDateOnCharge;
            for(zqu__QuoteRatePlanCharge__c qrpc : qrpcList) {
                if(qrpc.zqu__SpecificEndDate__c != null && (termEndDateOnCharge == null || qrpc.zqu__SpecificEndDate__c > termEndDateOnCharge)) {
                    termEndDateOnCharge = qrpc.zqu__SpecificEndDate__c;
                }
            }

            //BEGIN - [TP - 2021.11.27 - TPB change plan]
            Boolean changePlanTPB = false;
            Integer duration = 0;
            if(wrapper.confItem != null && wrapper.confItem.NE__Order_Item_Attributes__r != null )
            {
                for(NE__Order_Item_Attribute__c attr : wrapper.confItem.NE__Order_Item_Attributes__r )
                {
                    changePlanTPB |= (attr.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Third Party' && this.wrapper.confItem.NE__OrderId__r.XC_Subtype__c == 'Promocode application');
                    duration = (attr.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Duration and Renewal Terms' && attr.XC_DeveloperName__c == 'Duration' && String.isNotBlank(attr.NE__Value__c) && attr.NE__Value__c != attr.NE__Old_Value__c && attr.NE__Value__c.isNumeric()) ? Integer.valueOf(attr.NE__Value__c) : duration;
                }
            }
            
            if(changePlanTPB && duration > 0)
            {
                Date tempEnd = this.wrapper.subscriptionServiceActionDate.addMonths(duration);
                termEndDateOnCharge = (termEndDateOnCharge != null && termEndDateOnCharge > tempEnd) ? termEndDateOnCharge : ( tempEnd > Date.today() ? tempEnd : null);
            }

            if(termEndDateOnCharge != null && (termEndDateOnCharge > this.wrapper.subscriptionTermEndDate || changePlanTPB)) {

                Integer initialTerm;
                if(!changePlanTPB) 
                {
                    initialTerm = (termEndDateOnCharge > this.wrapper.startDateLocal) ? this.wrapper.startDateLocal.monthsBetween(termEndDateOnCharge) : termEndDateOnCharge.monthsBetween(this.wrapper.startDateLocal);
                    if ((this.wrapper.startDateLocal > termEndDateOnCharge && this.wrapper.startDateLocal.day() > termEndDateOnCharge.day()) || (termEndDateOnCharge > this.wrapper.startDateLocal && termEndDateOnCharge.day() > this.wrapper.startDateLocal.day())) initialTerm++;
                }
                else 
                {
                    initialTerm = this.wrapper.subscriptionServiceActionDate.monthsBetween(termEndDateOnCharge);
                    if (termEndDateOnCharge.day() > this.wrapper.subscriptionServiceActionDate.day()) initialTerm++;
                }
                //END - [TP - 2021.11.27 - TPB change plan]
                zqu__Quote__c quote = new zqu__Quote__c();
                quote.Id = this.wrapper.newZQuoteId;
                quote.zqu__ExistSubscriptionID__c = this.wrapper.existingSubscriptionId;
                quote.zqu__AutoRenew__c = this.wrapper.subscriptionAutoRenew;
                quote.zqu__InitialTerm__c = initialTerm;
                quote.zqu__RenewalTerm__c = Decimal.valueOf(this.wrapper.subscriptionRenewalTerm.split(' ')[0]);
                quote.zqu__TermStartDate__c = !changePlanTPB ? this.wrapper.startDateLocal : this.wrapper.subscriptionServiceActionDate;//[TP - 2021.11.27 - TPB change plan]

                Map<String, Object> termsAndConditionChanges = new Map<String, Object>();
                termsAndConditionChanges.put('zqu__AutoRenew__c', (quote.zqu__AutoRenew__c) ? 'true' : 'false');
                termsAndConditionChanges.put('zqu__RenewalTerm__c', quote.zqu__RenewalTerm__c);
                termsAndConditionChanges.put('zqu__InitialTerm__c', quote.zqu__InitialTerm__c);
                termsAndConditionChanges.put('zqu__TermStartDate__c', quote.zqu__TermStartDate__c);
                termsAndConditionChanges.put('zqu__ServiceActivationDate__c', (!changePlanTPB ? quote.zqu__TermStartDate__c.addDays(1) : quote.zqu__TermStartDate__c));//[TP - 2021.11.27 - TPB change plan]
                termsAndConditionChanges.put('zqu__ContractEffectiveDate__c', (!changePlanTPB ? quote.zqu__TermStartDate__c.addDays(1) : quote.zqu__TermStartDate__c));//[TP - 2021.11.27 - TPB change plan]
                System.debug('Changes Map: ' + termsAndConditionChanges);
                
                Map<String,Map<String,Object>> completeMap = new Map<String,Map<String,Object>>{quote.zqu__ExistSubscriptionID__c => termsAndConditionChanges};
                System.debug('Final Map for call: ' + completeMap);

                zqu.zQuoteUtil.setSubscriptionTermChanges(completeMap);
                XC_UTIL_SObject.updateRecord(quote);
            }
            
            if(!Test.isRunningTest() && ((this.wrapper.ratePlanAddList != null && !this.wrapper.ratePlanAddList.isEmpty()) || (this.wrapper.ratePlanRemoveList != null && !this.wrapper.ratePlanRemoveList.isEmpty()))){
				System.enqueueJob(new SendFutureQueuable(wrapper));
			}
        } 
	}


    /**
     * @description The Class SendFutureQueuable.
     */
    public class SendFutureQueuable implements Queueable , Database.AllowsCallouts{
        
        UtilWrapper wrapper;

        /**
         * @description Instantiates a new send future queuable.
         *
         * @param zquoteIds the zquote ids
         */
        public SendFutureQueuable(UtilWrapper wrapper){
            this.wrapper = wrapper;
        }
        
        /**
         * @description Execute.
         *
         * @param context the context
         */
        public void execute(QueueableContext context) {
            if(!Test.isRunningTest()) {
            	List<zqu.ZQuoteUtil.ZBillingResult> resultList = XC_ZuoraZQuoteUtil.finalSendToZBilling(new List<Id>{this.wrapper.newZQuoteId});
                
                // update Step with error info
                updateStepErrorInfo(resultList, this.wrapper.stepId);
            }
        } 
	}


    /**
	 * @description update Step with error info.
	 * @param resultList the ZBillingResult list
	 * @param stepId the Step Id
	 */
    public static void updateStepErrorInfo(List<zqu.ZQuoteUtil.ZBillingResult> resultList, String stepId){
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();
        for(zqu.ZQuoteUtil.ZBillingResult result : resultList){
            system.debug('##0610## result success --> '+ result.success);
            system.debug('##0610## result message --> '+ result.message);
            if(!result.success) {
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
                step.id = stepId;
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = result.message;
                stepList.add(step);
            }
        }
        if(!stepList.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(stepList);
        }
    }


	/**
	 * @description Creates the add remove products amendment quote.
	 * @param wrapper
     * @return the zquote id
	 */
	public static String createAddRemoveProductsAmendmentQuote(UtilWrapper wrapper){

        String orderId = wrapper.orderId;
        String originalZQuoteId = wrapper.originalZQuoteId;
        List<String> ratePlanAddList = wrapper.ratePlanAddList;
        List<String> ratePlanRemoveList = wrapper.ratePlanRemoveList;
        //String entityId;
        XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr;

        //Verifichiamo se il prodotto è di eMobility
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,
                                                                                NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_Duration__c, NE__CatalogItem__r.XC_AutoRenewal__c, NE__CatalogItem__r.CurrencyIsoCode,
                                                                                NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_CaseId__r.XC_Communication_Date__c,
                                                                                XC_Product_Subtype__c, NE__OrderId__c, NE__Action__c, NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c, XC_CA_UpdateDate__c, XC_CA_RenewalDate__c,
                                                                                (SELECT Id, NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c, XC_DeveloperName__c, NE__Value__c, NE__Old_Value__c FROM NE__Order_Item_Attributes__r)
                                                                                FROM NE__OrderItem__c
                                                                                //WHERE Id =: wrapper.confItemId]);
                                                                                WHERE NE__OrderId__c =: orderId]);//[TP - 2021.11.27 - TPB change plan]
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
        
		//Recupero lo zQuote associato all'NE__Order__c in stato di change order	
		Map<Id,zqu__Quote__c> subscriptionZuoraListMap = new Map<Id,zqu__Quote__c>([SELECT Id, name, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, zqu__SubscriptionVersion__c,
                                                                                    zqu__InvoiceSeparately__c, zqu__GenerateInvoice__c, zqu__Account__c, XC_LastSubscriptionId__c,
                                                                                    XC_MixedVat__c, XC_SubscriptionName__c
                                                                                    FROM zqu__Quote__c
                                                                                    WHERE id = :originalZQuoteId ]);

        List<zqu__Quote__c> subscriptionZuoraList = SubscriptionZuoraListMap.values();

		//Memorizzo temporaneamente il subscriptionId di zuora
		String subscriptionZuoraId = '';
	    
        zqu__Quote__c originalQuote;
        
        if(!subscriptionZuoraList.isEmpty()) {
            originalQuote = subscriptionZuoraList[0];
        }
        
		//Creo uno zQuote di tipo amendment sfruttando il datamap ChangeOrder2Zquote
		NE.DataMap.DataMapResponse dResp = getZQuoteFromDataMap(orderId);
		
		//Sovrascrivo lo zquoteid dell'order con il nuovo zQuoteId
		Id newZQuoteId = dResp.Parentid;
        wrapper.newZQuoteId = newZQuoteId;
	    System.debug('ooo -->'+newZQuoteId);
		//Obj.b2wzc__ZQuoteId__c = dResp.Parentid;

	    for(zqu__Quote__c zq: SubscriptionZuoraList){
	       subscriptionZuoraId = (String.isNotBlank(zq.XC_LastSubscriptionId__c)) ? zq.XC_LastSubscriptionId__c : zq.zqu__ZuoraSubscriptionID__c;
	    }
		
		//Verifico l'esistenza di precedenti amendments sullo stesso zquote in caso positivo prendo l'ultimo amendment e lo memorizzo nella variabile String CurrentSubscription
		Map<Id,Zuora__Subscription__c> subscriptionListMap = new Map<Id,Zuora__Subscription__c>([SELECT id, name, Zuora__Zuora_Id__c, Zuora__External_Id__c, Zuora__OriginalId__c, Zuora__Version__c,
                                                                                                    Zuora__NextChargeDate__c, Zuora__NextRenewalDate__c, Zuora__CustomerAccount__r.Zuora__External_Id__c,
                                                                                                    Zuora__ContractEffectiveDate__c, Zuora__TermEndDate__c, Zuora__Status__c, Zuora__TermStartDate__c,
                                                                                                    Zuora__RenewalTerm__c, Zuora__AutoRenew__c, Zuora__ServiceActivationDate__c 
                                                                                                FROM Zuora__Subscription__c  
                                                                                                WHERE Zuora__External_Id__c =: SubscriptionZuoraId 
                                                                                                ORDER BY Zuora__Version__c DESC
                                                                                                LIMIT 1]);//[TP - 2021.11.27 - TPB change plan - added Zuora__ServiceActivationDate__c]
        List<Zuora__Subscription__c> subscriptionList = subscriptionListMap.values();
        String currentSubscription = subscriptionZuoraId;
		//PROV40_4 Deloitte - 2022-01-20 - start
        if(!subscriptionListMap.isEmpty() && subscriptionListMap.values()[0].Zuora__Status__c == 'Cancelled') {
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = wrapper.stepId;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_Skipped;
            stepToUpdate.XC_SkipMessage__c = Label.XC_CL_SkipCancelledSubscription;
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return'';
        }else if(subscriptionListMap.isEmpty()){
            XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
            stepToUpdate.Id = wrapper.stepId;
            stepToUpdate.XC_ErrorMessage__c = 'Subscription ' + subscriptionZuoraList[0].XC_SubscriptionName__c + ' not found. Subscription ID: ' + subscriptionZuoraList[0].Id;
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            XC_UTIL_Sobject.updateRecord(stepToUpdate);
            return'';
        }
		//PROV40_4 Deloitte - 2022-01-20 - end
        getCurrentSubscription(subscriptionList, currentSubscription, wrapper);
	    
		/*Eseguo un update dello zQuote rendendolo di tipo Amendment memorizzando nel campo
		zqu__ExistSubscriptionID__c il SubscriptionZuoraId nel caso in cui non esiste alcun
		amendment precedentemente creato, CurrentSubscription in caso contrario, popolando
		tutti i campi required*/
		zqu__Quote__c newZquote = new zqu__Quote__c(Id = newZQuoteId);
        //setZuoraAccountID(subscriptionZuoraList, newZQuote);
        newZquote.zqu__ZuoraAccountID__c = (!subscriptionList.isEmpty()) ? subscriptionList[0].Zuora__CustomerAccount__r.Zuora__External_Id__c : subscriptionZuoraList[0].zqu__ZuoraAccountID__c;
	     
        setSubscriptionID(newZquote, currentSubscription, subscriptionZuoraId);
        wrapper.existingSubscriptionId = newZquote.zqu__ExistSubscriptionID__c;
        wrapper.subscriptionTermEndDate = subscriptionListMap.values()[0].Zuora__TermEndDate__c;
        wrapper.subscriptionAutoRenew = subscriptionListMap.values()[0].Zuora__AutoRenew__c;
        wrapper.subscriptionRenewalTerm = subscriptionListMap.values()[0].Zuora__RenewalTerm__c;
        wrapper.subscriptionServiceActionDate = subscriptionListMap.values()[0].Zuora__ServiceActivationDate__c;//[TP - 2021.11.27 - TPB change plan]
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
        if(!subscriptionList.isEmpty()){
            if(String.valueOf(subscriptionList[0].Zuora__TermEndDate__c)!= null && currentDateLocal > String.valueOf(subscriptionList[0].Zuora__TermEndDate__c)){
                currentDateLocal = String.valueOf(subscriptionList[0].Zuora__TermEndDate__c);
            }else if(String.valueOf(subscriptionList[0].Zuora__ContractEffectiveDate__c)!=null && currentDateLocal < String.valueOf(subscriptionList[0].Zuora__ContractEffectiveDate__c)){
                currentDateLocal = String.valueOf(subscriptionList[0].Zuora__ContractEffectiveDate__c);
            }
            //20220114 HotTopic_PROV_32 - [DO] – start
            else if(String.valueOf(subscriptionList[0].Zuora__TermStartDate__c)!= null && currentDateLocal < String.valueOf(subscriptionList[0].Zuora__TermStartDate__c)){
                currentDateLocal = String.valueOf(subscriptionList[0].Zuora__TermStartDate__c);
                List<XC_Provisioning_Step__c> stepListToUpdate = new List<XC_Provisioning_Step__c>();
                XC_Provisioning_Step__c stepToUpdate = new XC_Provisioning_Step__c();
                stepToUpdate.id = wrapper.stepId;
                stepToUpdate.XC_Action_Start_Date__c = subscriptionList[0].Zuora__TermStartDate__c;
                stepToUpdate.XC_Action_Date_Reason__c = Label.XC_CL_AmendDateEarlierSuspendDate;
                stepListToUpdate.add(stepToUpdate);
                if(!stepListToUpdate.isEmpty()){
                    XC_UTIL_Sobject.updateListRecords(stepListToUpdate);
                }                
            }
            //20220114 HotTopic_PROV_32 - [DO] – end
        }

        wrapper.startDateLocal = Date.valueOf(currentDateLocal);
        
	    newZquote.zqu__Amendment_Name__c ='Modifica ' + dResp.Parentid;
        newZquote.zqu__currency__c = wrapper.confItem.NE__CatalogItem__r.CurrencyIsoCode;
        newZquote.CurrencyIsoCode = wrapper.confItem.NE__CatalogItem__r.CurrencyIsoCode;
        newZquote.zqu__ValidUntil__c = Date.valueOf(currentDateLocal);
        newZquote.zqu__StartDate__c = Date.valueOf(currentDateLocal);
        //newZquote.zqu__Subscription_Term_Type__c = 'Termed';					### Taken from DataMap ###
		newZquote.zqu__SubscriptionVersion__c = subscriptionList.isEmpty() ? 1 : Integer.valueOf(subscriptionList[0].Zuora__Version__c) + 1;
		newZquote.zqu__InitialTerm__c = wrapper.confItem.XC_Duration__c != null ? wrapper.confItem.XC_Duration__c : 36;
        newZquote.zqu__AutoRenew__c = wrapper.confItem.NE__CatalogItem__r.XC_AutoRenewal__c != null ? wrapper.confItem.NE__CatalogItem__r.XC_AutoRenewal__c : false;
		//newZquote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';		### Taken from DataMap ### 
		newZquote.zqu__RenewalTerm__c = newZquote.zqu__InitialTerm__c;  
        newZquote.zqu__SubscriptionTermStartDate__c = Date.valueOf(currentDateLocal);
        newZquote.zqu__SubscriptionTermEndDate__c = Date.valueOf(currentDateLocal) + 360;
        newZquote.zqu__Service_Activation_Date__c = Date.valueOf(currentDateLocal);
        newZquote.XC_ProvisioningStep__c = wrapper.stepId;
        newZquote.zqu__InvoiceSeparately__c = originalQuote != null ? originalQuote.zqu__InvoiceSeparately__c : false;
        //newZquote.zqu__GenerateInvoice__c = originalQuote != null ? originalQuote.zqu__GenerateInvoice__c : true;
        //newZquote.zqu__GenerateInvoice__c = (wrapper.confItem.NE__OrderId__r.XC_Subtype__c == 'eMobility Change Offer' && originalQuote != null) ? originalQuote.zqu__GenerateInvoice__c : false;
        newZquote.zqu__GenerateInvoice__c = false;  // For eMobility Change Offer there is the 'Execute Payment' step
        newZquote.XC_ConfigurationItem__c = wrapper.confItemId;
        newZquote.XC_MixedVat__c = (wrapper.mixedVat == null) ? originalQuote.XC_MixedVat__c : XC_UTIL_Integration.convertFromBooleanToString (wrapper.mixedVat);
        newZquote.XC_SubscriptionName__c = originalQuote.XC_SubscriptionName__c;
        /*
        Boolean changeOrderB2b = wrapper.confItem.NE__OrderId__r.XC_Subtype__c == 'Service Upgrade/Downgrade';
                if(changeOrderB2b){
            newZquote.zqu__SubscriptionTermEndDate__c = Date.parse('27/07/2022');

        }*/
         Boolean changeOrderB2b = wrapper.confItem.NE__OrderId__r.XC_Subtype__c == 'Service Upgrade/Downgrade';

        if(changeOrderB2b){
            List<NE__OrderItem__c> listNE = [select id, NE__Action__c, XC_Effective_Start_Date_Recurring__c, XC_Billing_Period_Recurring__c from NE__OrderItem__c where NE__OrderId__c =:wrapper.confItem.NE__OrderId__c  and XC_Effective_Start_Date_Recurring__c != null and XC_Billing_Period_Recurring__c != null order by XC_Billing_Period_Recurring__c, XC_Effective_Start_Date_Recurring__c];

            if(!listNE.isEmpty()) {
                Date maxDate = listNE[0].XC_Effective_Start_Date_Recurring__c.addMonths(Integer.valueOf(listNE[0].XC_Billing_Period_Recurring__c));
                newZquote.zqu__SubscriptionTermEndDate__c = maxDate;
            }

        }
        
        Boolean isContractAmendmentChangeDate = wrapper.confItem.XC_CA_UpdateDate__c && wrapper.confItem.XC_CA_RenewalDate__c != null;
        if(isContractAmendmentChangeDate) {
            Map<Id, Asset> mapCA = new Map<Id, Asset>();
            mapCA = XC_IN081_ContractAmenment_D.getMapContrAmendByOrderItem(wrapper.confItemId);
            if(!mapCA.isEmpty()){
                newZquote.zqu__SubscriptionTermEndDate__c = mapCA.values()[0].XC_Contract_Amendment__r.XC_Contract__r.EndDate;
            }
            wrapper.isContractAmendmentChangeDate = true;
        }

		Id quoteAmendRT = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
		newZquote.RecordTypeId = quoteAmendRT;

		XC_UTIL_Sobject.updateRecord(newZquote);

        if(!Test.isRunningTest()) {
            enqueueJob(wrapper);
        }

		return newZquote.Id;
	}
    

    /**
	 * @description enqueueJob
	 * @param wrapper the wrapper
	 */
    public static void enqueueJob(UtilWrapper wrapper){
		if((wrapper.ratePlanAddList != null && !wrapper.ratePlanAddList.isEmpty()) || (wrapper.ratePlanRemoveList != null && !wrapper.ratePlanRemoveList.isEmpty())){
			System.enqueueJob(new ManageDMLQueuable(wrapper));
		}
    }


    /**
	 * @description setSubscriptionID
	 * @param newZquote the new Zquote
     * @param currentSubscription the current Subscription
     * @param subscriptionZuoraId the zuora subscription Id
	 */
    private static void setSubscriptionID(zqu__Quote__c newZquote, String currentSubscription, String subscriptionZuoraId) {
		if(currentSubscription == null || currentSubscription==''){
			newZquote.zqu__ExistSubscriptionID__c = subscriptionZuoraId; 
	    } else {
			newZquote.zqu__ExistSubscriptionID__c = currentSubscription;
	    }
    }


    /**
	 * @description getCurrentSubscription
	 * @param subscriptionList the subscription List
     * @param currentSubscription the current Subscription
     * @param wrapper the wrapper
	 */
    private static void getCurrentSubscription(List<Zuora__Subscription__c> subscriptionList, String currentSubscription, UtilWrapper wrapper) {
		for(Zuora__Subscription__c elem2 : subscriptionList) {
			currentSubscription = elem2.Zuora__External_Id__c;
            //wrapper.nextChargeDate = elem2.Zuora__NextChargeDate__c;
            wrapper.nextChargeDate = elem2.Zuora__NextRenewalDate__c;
		}
    }


    /**
	 * @description getZQuoteFromDataMap
	 * @param orderId the order Id
     * @return the NE.DataMap.DataMapResponse
	 */
    public static NE.DataMap.DataMapResponse getZQuoteFromDataMap(String orderId) {
        NE.DataMap.DataMapResponse dResp;
        if(!Test.isRunningTest()) {
            dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('ChangeOrder2Zquote',orderId);
        } else {
            dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote',orderId);
        }
        return dResp;
    }
    

    /**
	 * @description setZuoraAccountID
	 * @param subscriptionZuoraList the Zuora subscription List
     * @param newZquote the new zquote
	 */
    private static void setZuoraAccountID(List<zqu__Quote__c> subscriptionZuoraList, zqu__Quote__c newZquote) {
	    for(zqu__Quote__c zq: subscriptionZuoraList){
	       newZquote.zqu__ZuoraAccountID__c = zq.zqu__ZuoraAccountID__c;
	    }
    }


    /**
	 * @description updateRemoveAmendment
	 * @param zQuoteId the zquote Id
     * @param postponeTermDate the boolean
     * @param nextChargeDate the date
	 */
    private static void updateRemoveAmendment(String zQuoteId, Boolean postponeTermDate, Date nextChargeDate) {
	    if(postponeTermDate) {
            Map<Id, zqu__QuoteAmendment__c> amendmentMap = new Map<Id, zqu__QuoteAmendment__c>([SELECT Id, zqu__Quote__c, zqu__Type__c, zqu__ServiceActivationDate__c, zqu__ContractEffectiveDate__c
                                                                                                FROM zqu__QuoteAmendment__c
                                                                                                WHERE zqu__Type__c = 'RemoveProduct'
                                                                                                AND zqu__Quote__c = :zQuoteId]);
            List<zqu__QuoteAmendment__c> amendmentList = amendmentMap.values();
            for(zqu__QuoteAmendment__c amendment : amendmentList) {
                amendment.zqu__ServiceActivationDate__c = nextChargeDate;
                amendment.zqu__ContractEffectiveDate__c = nextChargeDate;
            }
            XC_UTIL_Sobject.updateListRecords(amendmentList);
        }
    }
    
}