/**
* @author Pasquale Pelliccia ppelliccia@deloitte.it
* @date Creation 29/11/2018
* @date Modification 30/11/2018
* @description Utility class 
*/
public without sharing class XC_ZuoraZQuoteUtil{
    
        
    /**
     * The Class QuoteRatePlanCharge.
     *@description The Class QuoteRatePlanCharge. 
     */
    //BEGIN - Nuovi metodi v2
    public class QuoteRatePlanCharge{
  
        /** 
        * @description zquoteId. 
        * @param zquoteId
        */
        public Id zquoteId;
        /** 
        * @description zuoraAccountId. 
        * @param zuoraAccountId
        */
        public String zuoraAccountId;

        /** 
        * @description zuoraAccountId. 
        * @param zuoraEntityId
        */
        public String zuoraEntityId;
        
        /** 
        * @description chargeType. 
        * @param chargeType
        */
        public String chargeType;    
        
        /** 
        * @description xc_wbs. 
        * @param xc_wbs
        */
        public String xcWbs;        

        /** 
        * @description startDate. 
        * @param startDate
        */
        public Date startDate;        
    }

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static void billingProfileFromPayment(List<String> zuoraPaymentMethodIds){
        List<NE__Billing_Profile__c> billingProfiles = new List<NE__Billing_Profile__c>();
        Map<Id, Zuora__PaymentMethod__c> paymentMethodsMap = 
                    new Map<Id, Zuora__PaymentMethod__c>([  SELECT id, Zuora__AchAccountNumberMask__c, Name, Zuora__External_Id__c, Zuora__Type__c,
                                                                 Zuora__BillingAccount__r.Zuora__Account__c, Zuora__BillingAccount__r.Zuora__External_Id__c, 
                                                                 Zuora__BillingAccount__r.Name,  Zuora__BillingAccount__r.Zuora__Account__r.NE__Name__c, 
                                                                 Zuora__BillingAccount__r.Zuora__Account__r.NE__Surname__c, Zuora__CreditCardMaskNumber__c, 
                                                                 Zuora__CreditCardType__c, Zuora__FirstName__c, Zuora__CreditCardExpirationYear__c, 
                                                                 Zuora__BankTransferAccountNumber__c, Zuora__CreditCardExpirationMonth__c 
                                                            FROM Zuora__PaymentMethod__c
                                                            WHERE id IN: zuoraPaymentMethodIds]);

        List<Zuora__PaymentMethod__c> paymentMethods = paymentMethodsMap.values();
        List<String> zuoraTypes = new List<String>();
        
        for(Zuora__PaymentMethod__c pm: paymentMethods){
            zuoraTypes.add(pm.Zuora__Type__c);
            System.debug('tipo '+pm.Zuora__Type__c);
        }
        
        Map<String, String> mapPaymentMeythodType = new Map<String, String>();
        
        for(B2WZC__PaymentMethodHPMapping__c pmhpm: [SELECT B2WZC__ZuoraPaymentMethodBack__c, B2WZC__B2WBillingProfile__c 
                                                    FROM B2WZC__PaymentMethodHPMapping__c 
                                                    WHERE B2WZC__ZuoraPaymentMethodBack__c IN:zuoraTypes]){
            mapPaymentMeythodType.put(pmhpm.B2WZC__ZuoraPaymentMethodBack__c, pmhpm.B2WZC__B2WBillingProfile__c);
        }
        
        //recupero gli NE__Billing_Profile__c gia creati
        Map<String, NE__Billing_Profile__c> billProfMap = XC_ZuoraZQuoteUtil_U.getNEBillingProfilesRelatedToZAccountIds(paymentMethods);
        NE__Billing_Profile__c  billingProfile;
        for(Zuora__PaymentMethod__c pm: paymentMethods){
             String payment = XC_ZuoraZQuoteUtil_U.assignPayment(pm);
                
            //se non esiste l'NE__Billing_Profile__c lo creo
            if(!billProfMap.containsKey(pm.Zuora__BillingAccount__r.Zuora__External_Id__c )){
                
                    billingProfile = new NE__Billing_Profile__c(
                    NE__Account__c = pm.Zuora__BillingAccount__r.Zuora__Account__c,
                    NE__Card_Number__c = pm.Zuora__CreditCardMaskNumber__c, 
                    NE__Card_Type__c = pm.Zuora__CreditCardType__c, 
                    NE__Expiration_Year__c = pm.Zuora__CreditCardExpirationYear__c == null? null: pm.Zuora__CreditCardExpirationYear__c.substring(2,4), 
                    NE__Expiration__c = pm.Zuora__CreditCardExpirationMonth__c,
                    NE__Payment__c = payment, //mapPaymentMeythodType.get(pm.Zuora__Type__c),  
                    B2WZC__Zuora_MethodPaymentId__c = pm.Zuora__External_Id__c,
                    Zuora_Account_Id__c = pm.Zuora__BillingAccount__r.Zuora__External_Id__c,
                    Name = pm.Zuora__Type__c == 'CreditCard' ? pm.Zuora__CreditCardMaskNumber__c : pm.Zuora__BankTransferAccountNumber__c,
                    NE__First_Name__c = pm.Zuora__BillingAccount__r.Name, 
                    NE__Last_Name__c = pm.Zuora__BillingAccount__r.Name
                );

            } else { //se esiste lo aggiorno
                billingProfile = billProfMap.get(pm.Zuora__BillingAccount__r.Zuora__External_Id__c );
                billingProfile.B2WZC__Zuora_MethodPaymentId__c = pm.Zuora__External_Id__c;
                billingProfile.NE__Card_Number__c = pm.Zuora__CreditCardMaskNumber__c;
                billingProfile.NE__Expiration_Year__c = pm.Zuora__CreditCardExpirationYear__c == null ? null : pm.Zuora__CreditCardExpirationYear__c.substring(2,4);
                billingProfile.NE__Expiration__c = pm.Zuora__CreditCardExpirationMonth__c;
                billingProfile.Name = pm.Zuora__Type__c == 'CreditCard' ? pm.Zuora__CreditCardMaskNumber__c : pm.Zuora__BankTransferAccountNumber__c;
                billingProfile.NE__First_Name__c = pm.Zuora__BillingAccount__r.Name;
                billingProfile.NE__Last_Name__c = pm.Zuora__BillingAccount__r.Name;
                billingProfile.NE__Payment__c = payment;
            }
            
            billingProfiles.add(billingProfile);
        }
        
        System.debug('billingProfiles -->'+billingProfiles);
        //upsert billingProfiles;
        XC_UTIL_Sobject.upsertListRecords(billingProfiles);
        
    }*/

    
    
    /**
    * Generate zuora accoutz quote rate plan charge map.
    *@description Generate zuora accoutz quote rate plan charge map.
    *@param zQuoteIds the z quote ids
    *@return the map
    */
    public static Map<String, List<QuoteRatePlanCharge>> generateZuoraAccoutzQuoteRatePlanChargeMap(List<Id> zQuoteIds){
        Map<String, List<QuoteRatePlanCharge>> mapZuoraAccountzQuotes = new Map<String, List<QuoteRatePlanCharge>>();
        Map<Id, zqu__QuoteRatePlanCharge__c> zQuoteRatePlanChargesMap =
            new Map<Id, zqu__QuoteRatePlanCharge__c>([SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__r.id, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraAccountID__c, XC_wbs__c,
                                                            zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraEntityId__c , zqu__ChargeType__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c
                                                      FROM zqu__QuoteRatePlanCharge__c 
                                                      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN: zQuoteIds ]);
        List<zqu__QuoteRatePlanCharge__c> zQuoteRatePlanCharges = zQuoteRatePlanChargesMap.values();
        for(zqu__QuoteRatePlanCharge__c zq: zQuoteRatePlanCharges){
            
            String zuoraAccountId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraAccountID__c;
            
            if(!mapZuoraAccountzQuotes.containsKey(zuoraAccountId)){
                List<QuoteRatePlanCharge> zqList = new List<QuoteRatePlanCharge>();
                QuoteRatePlanCharge qrpc = new QuoteRatePlanCharge();
                qrpc.zquoteId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.id;
                qrpc.zuoraAccountId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraAccountID__c;
                qrpc.zuoraEntityId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraEntityId__c;
                qrpc.chargeType = zq.zqu__ChargeType__c;
                qrpc.xcWbs = zq.xc_wbs__c;
                qrpc.startDate = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;
                zqList.add(qrpc);
                mapZuoraAccountzQuotes.put(zuoraAccountId, zqList);
            }else{
                List<QuoteRatePlanCharge> zqList =  mapZuoraAccountzQuotes.get(zuoraAccountId);
                QuoteRatePlanCharge qrpc = new QuoteRatePlanCharge();
                qrpc.zquoteId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.id;
                qrpc.zuoraAccountId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraAccountID__c;
                qrpc.zuoraEntityId = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__ZuoraEntityId__c;
                qrpc.chargeType = zq.zqu__ChargeType__c;
                qrpc.xcWbs = zq.xc_wbs__c;
                qrpc.startDate = zq.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;
                zqList.add(qrpc);
                mapZuoraAccountzQuotes.put(zuoraAccountId, zqList);
            }
        }
        return mapZuoraAccountzQuotes;
    }
    
    /**
    * Final send to Z billing.
    *@description Final send to Z billing.
    *@param zQuoteIds the z quote ids
    *@return the list
    */
    public static List<zqu.ZQuoteUtil.ZBillingResult> finalSendToZBilling(List<Id> zQuoteIds){
        
        Map<String, List<QuoteRatePlanCharge>> mapZuoraAccountzQuotes = generateZuoraAccoutzQuoteRatePlanChargeMap(zQuoteIds);
        
        List<zqu.zQuoteUtil.ZBillingQuoteCollection> zBillingQuoteCollections = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        
        if(!mapZuoraAccountzQuotes.isEmpty()) {
            for(String zuoraAccountId: mapZuoraAccountzQuotes.keySet()){
                zqu.zQuoteUtil.ZBillingQuoteCollection zbqc = new  zqu.zQuoteUtil.ZBillingQuoteCollection();
                
                System.debug('mapZuoraAccountzQuotes -->'+mapZuoraAccountzQuotes);
                //--ZBillingQuoteCollection
                String entityId = mapZuoraAccountzQuotes.get(zuoraAccountId)[0].zuoraEntityId; //The Zuora Entity ID for the entity that this request is being directed to.     
                System.debug('entityId -->'+entityId);
                Date startDate = mapZuoraAccountzQuotes.get(zuoraAccountId)[0].startDate; //The Zuora Entity ID for the entity that this request is being directed to.     
                String zAccountId = zuoraAccountId; //Indicates the Zuora Billing Account ID. For new accounts, set this field to new. A new billing account will be created, and all of the quotes in this ZBillingQuoteCollection object will be created under this new billing account.
                
                List<zqu.zQuoteUtil.ZBillingQuoteRequest> quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>(); //Contains a list of quote requests. Each quote request will be used to create a subscription request, which is then sent to Zuora for processing.   
                Set<String> finalzQuoteList = new Set<String>();
                Boolean isOneShotSubscription = false;
                    
                for(QuoteRatePlanCharge q: mapZuoraAccountzQuotes.get(zuoraAccountId)){
                    
                    //--ZBillingQuoteRequest--
                    if(q.chargeType == 'One-Shot'){
                        isOneShotSubscription =  true;
                    }
                    finalzQuoteList.add(q.zquoteId);
                }
                    Boolean applyCreditBalance = false;                                         //Determines whether any credit balance on a customer's account is automatically applied to invoices. If no value is specified, this field defaults to false.
                    //Date effectiveDate = Date.today();                                          //Specifies the start date of the quote
                    Date effectiveDate = startDate;         // to get the date in the Local Zone
                    //Boolean enableAccountAutoPay = true;                                      //Specifies whether to enable auto pay for this account
                    Boolean generateInvoice = isOneShotSubscription;                            //Specifies whether or not the invoice should be generated for this subscription. If not specified, the value of the Generate Invoice field in the Quote object will be used.
                    //String invoiceProcessingOption = 'Subscription';                          //Specifies at which level the invoice will be processed, Subscription or Account. When generateInvoice at the org or quote level is set to True, the invoiceProcessing option is set to Subscription, by default.
                    //Decimal paymentAmount = 30;                                               //The payment amount
                    //String paymentMethodId = '';                                              //The electronic payment method ID. If you do not specify a value, the default payment method will be used to process the payments.
                    Boolean processPayment = false; //true                                      //Specifies whether or not the payment for this subscription should be processed when sent to Z-Billing. See Process Payments in Z-Billing for information about how this setting takes effect.
                    //Boolean setNewPaymentAsDefault = true;                                        //Specifies whether to set the new payment method as the default. Setting this field to true takes effect only if you are specifying an electronic payment method, as defined in Zuora, in the paymentMethodId field. A payment gateway must be enabled and support the payment method specified in the paymentMethodId field.
                    //Id sfdcQuoteId = sfdcQuoteId;                                             //The Salesforce Quote ID. The data passed here must be valid Salesforce record IDs.   
                    //----
                for ( String tmpzqid : finalzQuoteList) {
                    zqu.zQuoteUtil.ZBillingQuoteRequest qr = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                    qr.applyCreditBalance = applyCreditBalance; 
                    qr.effectiveDate = effectiveDate; 

                    //qr.enableAccountAutoPay = enableAccountAutoPay; 
                    //qr.generateInvoice = generateInvoice; 
                    //qr.invoiceProcessingOption = invoiceProcessingOption; 
                    //qr.paymentAmount = paymentAmount;
                    //qr.paymentMethodId = paymentMethodId; 
                    qr.processPayment = processPayment; 
                    //qr.setNewPaymentAsDefault = setNewPaymentAsDefault;
                    // qr.sfdcQuoteId = q.zquoteId;
                    qr.sfdcQuoteId = tmpzqid;

                    quoteRequests.add(qr);
                }
                zbqc.entityId = entityId;
                zbqc.zAccountId = zAccountId;
                zbqc.quoteRequests = quoteRequests;
                zBillingQuoteCollections.add(zbqc);
            }

        } else {

            Map<Id, zqu__Quote__c> zquoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__Service_Activation_Date__c, zqu__ZuoraEntityId__c, zqu__ZuoraAccountID__c
                                                                            FROM zqu__Quote__c
                                                                            WHERE Id =: zQuoteIds[0] LIMIT 1]);
            zqu__Quote__c quote = zquoteMap.values()[0];

            List<zqu.zQuoteUtil.ZBillingQuoteRequest> quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
            zqu.zQuoteUtil.ZBillingQuoteRequest qr = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            qr.applyCreditBalance = false; 
            qr.effectiveDate = quote.zqu__Service_Activation_Date__c; 
            qr.processPayment = false; 
            qr.sfdcQuoteId = quote.Id;
            quoteRequests.add(qr);

            zqu.zQuoteUtil.ZBillingQuoteCollection zbqc = new  zqu.zQuoteUtil.ZBillingQuoteCollection();
            zbqc.entityId = quote.zqu__ZuoraEntityId__c;
            zbqc.zAccountId = quote.zqu__ZuoraAccountID__c;
            zbqc.quoteRequests = quoteRequests;
            zBillingQuoteCollections.add(zbqc);
        }
        
        System.debug(LoggingLevel.FINEST, '@@@#@#' + zBillingQuoteCollections);

        List<zqu.ZQuoteUtil.ZBillingResult> resultList = new List<zqu.ZQuoteUtil.ZBillingResult>();
        try {
            // Send to Zuora
            resultList = zqu.zQuoteUtil.sendToZBilling(zBillingQuoteCollections);

        } catch(Exception e) { // To set the Zuora error on Provisioning steps --> Added retry logic
                Map<Id, zqu__Quote__c> zQuoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, XC_ProvisioningStep__c FROM zqu__Quote__c WHERE Id IN :zquoteIds]);
                List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
                for(zqu__Quote__c zq : zQuoteMap.values()) {
                    stepsToUpdate.add(new XC_Provisioning_Step__c(Id = zq.XC_ProvisioningStep__c, XC_Status__c = Label.XC_CL_Step_CompletedKO,
                                                                    XC_ErrorMessage__c = e.getMessage()));
                }
                XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        }
        
        if(!resultList.isEmpty()){ 
            System.Debug('RESULT LIST::: ' + resultList[0]);

            Boolean hasConcurrentError = false;
            for(zqu.ZQuoteUtil.ZBillingResult zbr : resultList){
                if(!zbr.success && String.isNotBlank(zbr.message) && zbr.message.containsIgnoreCase('failed due to a lock competition')){
                    hasConcurrentError = true;
                    break;
                }
            }

            if(hasConcurrentError){
                Integer maxRetry = 3;
                System.Debug('ENTERED RETRY LOGIC');
                Boolean success = false;
                for(Integer i = 0; i<maxRetry; i++){
                    //insert a sleep here
                    System.Debug('CONCURRENT RETRY TENTATIVE N. ' + i + ' FINAL SEND TO ZBILLING');
                    XC_UTIL_RESTCallout.sleep(2000);
                    try{
                        resultList = zqu.zQuoteUtil.sendToZBilling(zBillingQuoteCollections);
                        success = true;
                        break;
                    }catch(Exception ex){
                        success = false;
                    }
                }
            }

        }

        return resultList;
    }


    //END - Nuovi metodi v2
     
    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static Boolean isNumeric(String s){
        Boolean returnValue;
        try{
            Decimal.valueOf(s);
            returnValue = TRUE; 
        } catch (Exception e) {
            returnValue = FALSE;
        }
        return returnValue;
    }*/
     
    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static List<Id> createZquoteFromDatamap (String mapName, Id orderId, Integer numberOfCopies){
        
        //Verifica che non ci siano attivi logger in caso positivo restituisci un messaggio di errore
        //List<B2WZC__LoggerEnabled__c> loggers = [SELECT B2WZC__IsEnabled__c FROM B2WZC__LoggerEnabled__c];
        
        //Verifica che il connettore sia atttivo, in caso negativo restituisci un messaggio di errore
        //List<B2WZC__Bit2WinConnector__c> connectors = [SELECT Id, name, B2WZC__isActiveConnector__c FROM B2WZC__Bit2WinConnector__c WHERE name = 'ZuoraConnector'  LIMIT 1];
         
        //List<NE__Order__c> orders = [SELECT id, name, NE__BillingProfId__c, B2WZC__ZPaymentMethodId__c, B2WZC__ZPaymentMethodIdFromula__c  FROM NE__Order__c WHERE id = :orderId LIMIT 1];
        
        //List<Map__c> map = [SELECT Id, Name, NE__Map_Name__c FROM NE__Map__c WHERE (NE__Map_Name__c =: mapName AND NE__Type__c = 'Object2Object')];
        
        
        Map<Id,NE__MapObject__c> mapObjectsMap = new Map<Id,NE__MapObject__c>([SELECT Id, NE__Activate_Sort__c, NE__Sort_Source__c, NE__Sort_Operation__c, Name, NE__Source__c, NE__Target__c, NE__Type__c, NE__Map__c, NE__Parent__c, NE__Filter__c, NE__Activate_Filter__c, NE__Filter_Operation__c, NE__Filter_Source__c, NE__Filter_Target__c, (SELECT Id, NE__Relationship__c, Name, NE__SourceField__c, NE__TargetField__c, NE__Type__c, NE__Value__c, NE__RecordTypeId__c FROM NE__Map_Object_Items__r) FROM NE__MapObject__c WHERE NE__Map__r.NE__Map_Name__c =: mapName ORDER BY NE__Sequence__c ASC NULLS FIRST]);       
        List<NE__MapObject__c> mapObjects = mapObjectsMap.values();
        String orderFieldsToQuery = '';
        Map<String, String> mappingZQuoteOrderFields = new Map<String, String>();
        Map<String, String> mappingZQuoteOrderValues = new Map<String, String>();
        
        Set<String> orderFieldsToQuerySet = new Set<String>();
        
        XC_ZuoraZQuoteUtil_U.UtilWrapper utilWr = new XC_ZuoraZQuoteUtil_U.UtilWrapper();
        utilWr.mappingZQuoteOrderFields = mappingZQuoteOrderFields;
        utilWr.mappingZQuoteOrderValues = mappingZQuoteOrderValues;
        utilWr.orderFieldsToQuerySet = orderFieldsToQuerySet;

        for( NE__MapObject__c mapObj:  [SELECT Id, NE__Activate_Sort__c, NE__Sort_Source__c, NE__Sort_Operation__c, Name, NE__Source__c, NE__Target__c, NE__Type__c, NE__Map__c, NE__Parent__c, NE__Filter__c, NE__Activate_Filter__c, NE__Filter_Operation__c, NE__Filter_Source__c, NE__Filter_Target__c, (SELECT Id, NE__Relationship__c, Name, NE__SourceField__c, NE__TargetField__c, NE__Type__c, NE__Value__c, NE__RecordTypeId__c FROM NE__Map_Object_Items__r) FROM NE__MapObject__c WHERE NE__Map__r.NE__Map_Name__c = 'Order2Zquote' ORDER BY NE__Sequence__c ASC NULLS FIRST]){
            
            for(NE__MapObjectItem__c moi: mapObj.NE__Map_Object_Items__r){
                utilWr.moi = moi;
                XC_ZuoraZQuoteUtil_U.populateOrderFieldsToQuerySet(utilWr);
            }
        }
        
        List<String> orderFieldsToQueryList = new List<String>();
        orderFieldsToQueryList.addAll(utilWr.orderFieldsToQuerySet);  
        orderFieldsToQuery = String.join(orderFieldsToQueryList, ',');
        System.debug('sss -->'+orderFieldsToQuery);
        List<zqu__Quote__c> zquotes = new List<zqu__Quote__c>();

        String queryString = 'SELECT '+orderFieldsToQuery+' FROM NE__Order__c WHERE Id =:orderId';
        queryString = String.escapeSingleQuotes(queryString);

        List<NE__Order__c> orders = Database.query(queryString);
        zqu__Quote__c q;

        for(Integer i=0; i<numberOfCopies; i++){
            for(NE__order__c order: orders){
                //generate zQuote
                utilWr.order = order;
                q = new zqu__Quote__c();
                XC_ZuoraZQuoteUtil_U.populateZquoteFields(q, utilWr);
                
                zquotes.add(q);
            }
        }
        
        //insert zQuote
        //insert zquotes;
        XC_UTIL_Sobject.insertListRecords(zquotes);
        List<Id> zQuotesIds = new List<Id>();
        for(zqu__Quote__c quote : zquotes){
            zQuotesIds.add(quote.Id);
        }
        return zQuotesIds;
    }*/

    /**
     * @description the map Z quote configuration item
     * @param mapZQuoteConfigurationItem 
     */
    public static void overridePrices(Map<Id, NE__OrderItem__c> mapZQuoteConfigurationItem){
        
        Map<Id, zqu__QuoteRatePlanCharge__c> rpChargeMap = 
            new Map<Id, zqu__QuoteRatePlanCharge__c>([SELECT Id, zqu__ChargeType__c, zqu__EffectivePrice__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__Model__c 
                                                      FROM zqu__QuoteRatePlanCharge__c 
                                                      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :mapZQuoteConfigurationItem.keyset()
                                                    ]);
        List<zqu__QuoteRatePlanCharge__c> rpChargeList = rpChargeMap.values();

        List<String> orderItemIds = XC_UTIL_Sobject.getListFieldValues(mapZQuoteConfigurationItem.values(), 'Id');
        Map<String,List<NE__Order_Item_Discount__c>> oiOiDiscount = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(orderItemIds);

        System.debug(LoggingLevel.FINEST, '### BEFORE populateListEffCharge ' + rpChargeList);
        Date startDate = rpChargeList[0].zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;

        for(Id quoteId: mapZQuoteConfigurationItem.keySet()){

            String effectivePrice = '';
            NE__OrderItem__c configurationItem = mapZQuoteConfigurationItem.get(quoteId);
            Boolean hasDiscountApplied = oiOiDiscount.containsKey(configurationItem.Id);

            if(hasDiscountApplied){
                if(configurationItem.NE__BaseOneTimeFee__c != 0){
                    effectivePrice = String.valueOf(configurationItem.NE__BaseOneTimeFee__c);
                }else if(configurationItem.NE__BaseRecurringCharge__c != 0){
                    effectivePrice = String.valueOf(configurationItem.NE__BaseRecurringCharge__c);
                }
            }else{
                if(configurationItem.NE__OneTimeFeeOv__c != 0){
                    effectivePrice = String.valueOf(configurationItem.NE__OneTimeFeeOv__c);
                } else if(configurationItem.NE__RecurringChargeOv__c != 0){
                    effectivePrice = String.valueOf(configurationItem.NE__RecurringChargeOv__c);
                }
            }
        
            if(effectivePrice == '') {
               return;
            }

            Map<String, Object> mapUtil = new Map<String,Object>{
                                                            'effectivePrice' => effectivePrice,
                                                            'date' => startDate
                                                            };

            List<zqu__QuoteRatePlanCharge__c> effCharge = XC_ZuoraZQuoteUtil_U.populateListEffCharge(rpChargeList, mapUtil, oiOiDiscount.get(configurationItem.Id));
            System.debug(LoggingLevel.FINEST, '### AFTER populateListEffCharge ' + rpChargeList);
   			System.debug(LoggingLevel.FINEST, '### AFTER effCharge ' + effCharge);

            XC_UTIL_SObject.updateListRecords(rpChargeList);
        }
    }
    

    /**
     * @description calculate the effective price for change order with subtype Substitution (Malfunction)
     * @param mapZQuoteConfigurationItem 
    **/
    /*public static void overridePricesMalfunction(Map<Id, NE__OrderItem__c> mapZQuoteConfigurationItem, NE__OrderItem__c oldItem){
        
        Map<Id, zqu__QuoteRatePlanCharge__c> rpChargeMap = 
            new Map<Id, zqu__QuoteRatePlanCharge__c>([SELECT Id, zqu__ChargeType__c, zqu__EffectivePrice__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__Model__c 
                                                      FROM zqu__QuoteRatePlanCharge__c 
                                                      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :mapZQuoteConfigurationItem.keyset()
                                                    ]);
        List<zqu__QuoteRatePlanCharge__c> rpChargeList = rpChargeMap.values();

        Map<String,List<NE__Order_Item_Discount__c>> oiOiDiscount = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(new List<String>{oldItem.Id});

        System.debug(LoggingLevel.FINEST, '### BEFORE populateListEffCharge ' + rpChargeList);
        Date startDate = rpChargeList[0].zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;


        String effectivePrice = '';
        Boolean hasDiscountApplied = oiOiDiscount.containsKey(oldItem.Id);

        if(hasDiscountApplied){
            if(oldItem.NE__BaseOneTimeFee__c != 0){
                effectivePrice = String.valueOf(oldItem.NE__BaseOneTimeFee__c);
            }else if(oldItem.NE__BaseRecurringCharge__c != 0){
                effectivePrice = String.valueOf(oldItem.NE__BaseRecurringCharge__c);
            }
        }else{
            if(oldItem.NE__OneTimeFeeOv__c != 0){
                effectivePrice = String.valueOf(oldItem.NE__OneTimeFeeOv__c);
            } else if(oldItem.NE__RecurringChargeOv__c != 0){
                effectivePrice = String.valueOf(oldItem.NE__RecurringChargeOv__c);
            }
        }
    
        if(effectivePrice == '') {
            return;
        }

        Map<String, Object> mapUtil = new Map<String,Object>{
                                                        'effectivePrice' => effectivePrice,
                                                        'date' => startDate
                                                        };

        List<zqu__QuoteRatePlanCharge__c> effCharge = XC_ZuoraZQuoteUtil_U.populateListEffCharge(rpChargeList, mapUtil, oiOiDiscount.get(oldItem.Id));
        System.debug(LoggingLevel.FINEST, '### AFTER populateListEffCharge ' + rpChargeList);
        System.debug(LoggingLevel.FINEST, '### AFTER effCharge ' + effCharge);

        XC_UTIL_SObject.updateListRecords(rpChargeList);
        
    }*/
    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static void tryToApplyDiscountPercentage(Map<Id, NE__OrderItem__c> mapZQuoteConfigurationItem, String couponName){
        
        System.debug('mapZQuoteConfigurationItem -->'+mapZQuoteConfigurationItem);
        Map<Id, String> mapZQuotesDiscountPercentage = new Map<Id, String>();
        
        for(Id quoteId: mapZQuoteConfigurationItem.keySet()){
            NE__OrderItem__c configurationItem = mapZQuoteConfigurationItem.get(quoteId);
            XC_ZuoraZQuoteUtil_U.populateMapZQuotesDiscountPercentage(mapZQuotesDiscountPercentage, configurationItem);    
        }
        
        Map<Id, zqu__ProductRatePlanCharge__c> productRatePlanChargesMap = new Map<Id, zqu__ProductRatePlanCharge__c>([select id from zqu__ProductRatePlanCharge__c where Name =: couponName]);
        List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = productRatePlanChargesMap.values();
        if(productRatePlanCharges.size() <= 0) {
            return;
        }
            
        String productRatePlanId = productRatePlanCharges[0].Id; //Coupon
        List<Id>  productRatePlanIds = new List<Id>{productRatePlanId};
            
        XC_ZuoraZQuoteUtil_U.addChargeGroupsUtil(mapZQuotesDiscountPercentage, productRatePlanIds);
    }*/
}