/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @description The Class XC_TR_ConfigurationItem_U_UpdateZQuote - WARNING, this class is not a trigger handler - called by XC_IN015
 */
public without sharing class XC_TR_ConfigurationItem_U_UpdateZQuote {

    /**
     * The Class Params. 
     * @description paramenters
     */
    public class Params{
        public String price;
        public String quantity;
    }

    /**
    * @description Delta Wrapper
    */
    public class DeltaWrapper {
        public Decimal price;
        public Decimal maxMonth;
        public Integer monthsPast;
        public Boolean posMonthsPast;
    }

    /**
    * @description UtilWrapper
    */
    public class UtilWrapper{
        public Boolean posMonthsPast;
        public Integer monthsPast;
    }

    /**
     * @description The Class ManageDMLQueuable.
     */
    public class ManageDMLQueuable implements Queueable , Database.AllowsCallouts{
        
        Id zquoteId;
        Map<String, Params> mapZQuotePrice;
        List<String> ratePlanAddList;
        List<String> ratePlanRemoveList;
        
        /**
         * @description Instantiates a new manage DML queuable.
         * @param zquoteId the zquote id
         * @param mapZQuotePrice the map Z quote price
         */
        public ManageDMLQueuable(Id zquoteId, Map<String, Params> mapZQuotePrice){
            this.zquoteId = zquoteId;
            this.mapZquotePrice = mapZquotePrice;
        }
        
        /**
         * @description Execute.
         * @param context the context
         */
        public void execute(QueueableContext context) {
            overridePrices(this.mapZQuotePrice);
            if(!Test.isRunningTest()) {
            	System.enqueueJob(new SendFutureQueuable(new List<Id>{this.zquoteId}));                
            }
        }
    }

    /**
     * @description Send Future Queuable
     */
    public class SendFutureQueuable implements Queueable , Database.AllowsCallouts{
        
        List<Id> zquoteIds;
        /**
         * @description Instantiates a new send future queuable.
         * @param zquoteIds the zquote ids
         */
        public SendFutureQueuable(List<Id> zquoteIds){
            this.zquoteIds = zquoteIds;
        } 
        
        /**
         * @description execute
         * @param context the context
         */
        public void execute(QueueableContext context) {
            List<zqu.ZQuoteUtil.ZBillingResult> resultList = XC_ZuoraZQuoteUtil.finalSendToZBilling(this.zquoteIds);
            List<zqu__Quote__c> zQuoteList = new List<zqu__Quote__c>();
            for(zqu.ZQuoteUtil.ZBillingResult result : resultList) {
                zqu__Quote__c quote = new zqu__Quote__c(Id=result.sfdcQuoteId);
                quote.XC_Message__c = result.message;
                quote.XC_isSuccess__c = result.success;
                zQuoteList.add(quote);
            }
            XC_UTIL_Sobject.updateListRecords(zQuoteList);
        }
    }
    
    /**
    * @description getZuoraSubscription gets the zuora subscription
    * @param subscriptionZuoraId the id of the subscription
    * @return the list of subscriptions
    */
    public static List<Zuora__Subscription__c> getZuoraSubscription(String subscriptionZuoraId){
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        if(Schema.sObjectType.Zuora__Subscription__c.isAccessible()){
            subscriptionList =[SELECT id, name, Zuora__Zuora_Id__c, Zuora__OriginalId__c, Zuora__Version__c
                                                            FROM Zuora__Subscription__c  
                                                            WHERE Zuora__OriginalId__c  =:subscriptionZuoraId 
                                                            ORDER BY Zuora__Version__c DESC
                                                            LIMIT 1];
        }
        return subscriptionList;
    }

    /**
     *@author Federico Amici - federico.amici@nttdata.com
     *@description createAddRemoveProductsAmendmentQuote Creates the add remove products amendment quote
     *@param wrapperUpdate the update wrapper
     */
    public static void createAddRemoveProductsAmendmentQuote(XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wrapperUpdate){
        /*  The item not penalty */ 
        NE__OrderItem__c item = wrapperUpdate.mapNewItems.get(wrapperUpdate.confItemId);

        Date activationDate = (item.NE__Activation_Date__c).date();
        Date todayDate = Date.today();
        Integer monthsPast = activationDate.monthsBetween(todayDate);
        Boolean posMonthsPast =true;

        UtilWrapper wrapper = checkMonthsPast(monthsPast, posMonthsPast, activationDate);

        /*List<XC_UTIL_ResultWrapper> listPenalty = new List<XC_UTIL_ResultWrapper>();
        XC_UTIL_ResultWrapper wr;

        for(Asset a : wrapperUpdate.listAsset) {
            wr = XC_LCC095_ShowPenalty.showPenalty(a.Id);
            listPenalty.add(wr);
        }*/

        //Recupero lo zQuote associato all'NE__Order__c in stato di change order
        Map<Id, zqu__Quote__c> mapSubscription = new Map<Id, zqu__Quote__c>([
            SELECT Id, name, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, zqu__SubscriptionVersion__c, zqu__Account__c, zqu__InvoiceSeparately__c, zqu__GenerateInvoice__c
            FROM zqu__Quote__c 
            WHERE id = :wrapperUpdate.zQuoteId ]); 
        /*Map<Id, zqu__Quote__c> mapSubscription = new Map<Id, zqu__Quote__c>([
            SELECT Id, name, zqu__ZuoraAccountID__c, zqu__ZuoraSubscriptionID__c, zqu__SubscriptionVersion__c, zqu__Account__c
            FROM zqu__Quote__c 
            WHERE id = 'a1D9E0000023aqtUAA' ]);  */
        List<zqu__Quote__c> subscriptionZuoraList = mapSubscription.values();
        zqu__Quote__c originalQuote;
        
        if(!subscriptionZuoraList.isEmpty()) {
            originalQuote = subscriptionZuoraList[0];
        }

        //Memorizzo temporaneamente l'accountId e il subscriptionId di zuora
        String subscriptionZuoraId = '';
        String zquAccount = '';
        
        //Creo uno zQuote di tipo amendment sfruttando il datamap ChangeOrder2Zquote
        NE.DataMap.DataMapResponse dResp = getZQuoteByDataMap(wrapperUpdate.orderId);
        
        //NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('ChangeOrder2Zquote', 'a2X9E000001HmXQUA0');
        
        //Sovrascrivo lo zquoteid dell'order con il nuovo zQuoteId
        Id newZQuoteId = dResp.Parentid;
        System.debug('ooo -->'+newZQuoteId);
        //Obj.b2wzc__ZQuoteId__c = dResp.Parentid;

        for(zqu__Quote__c zq: SubscriptionZuoraList){
           subscriptionZuoraId = zq.zqu__ZuoraSubscriptionID__c;
        }
        
        //Verifico l'esistenza di precedenti amendments sullo stesso zquote in caso positivo prendo l'ultimo amendment e lo memorizzo nella variabile String CurrentSubscription
        List<Zuora__Subscription__c> subscriptionList = XC_TR_ConfigurationItem_U_UpdateZquote.getZuoraSubscription(subscriptionZuoraId);

        String currentSubscription = getCurrentSubscription(subscriptionList);
        
        /*Eseguo un update dello zQuote rendendolo di tipo Amendment memorizzando nel campo
        zqu__ExistSubscriptionID__c il SubscriptionZuoraId nel caso in cui non esiste alcun
        amendment precedentemente creato, CurrentSubscription in caso contrario, popolando
        tutti i campi required*/
        zqu__Quote__c newZquote = new zqu__Quote__c();

        setSubscriptionIDAndZuoraAccountID(newZquote, currentSubscription, subscriptionZuoraId);

        for(zqu__Quote__c zq: SubscriptionZuoraList){
           newZquote.zqu__ZuoraAccountID__c = zq.zqu__ZuoraAccountID__c;
        }

        newZquote.id = newZQuoteId;
        newZquote.zqu__Amendment_Name__c = 'Modifica ' + dResp.Parentid;
        newZquote.zqu__ValidUntil__c = Date.today();
        newZquote.zqu__StartDate__c = Date.today();
        //newZquote.zqu__Subscription_Term_Type__c = 'Termed';                  ### Taken from DataMap ###
        newZquote.zqu__SubscriptionVersion__c = subscriptionList.isEmpty() ? 1 : Integer.valueOf(subscriptionList[0].Zuora__Version__c) + 1;
        newZquote.zqu__InitialTerm__c = item.XC_Max_Months_Renting__c - wrapper.monthsPast;
        //newZquote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';        ### Taken from DataMap ###
        newZquote.zqu__RenewalTerm__c = newZquote.zqu__InitialTerm__c;
        newZquote.zqu__SubscriptionTermStartDate__c = Date.today();
        newZquote.zqu__SubscriptionTermEndDate__c = (Date.today()).addMonths(wrapper.monthsPast);
        newZquote.zqu__Service_Activation_Date__c = Date.today();       
        //newZquote.zqu__ZuoraAccountID__c = '8adc9a416a6dff4d016a7942e950571c'; // CAMPO AGGIUNTO PER TEST, TBD
        newZquote.XC_ConfigurationItem__c = wrapperUpdate.confItemId;
        newZquote.zqu__InvoiceSeparately__c = originalQuote != null ? originalQuote.zqu__InvoiceSeparately__c : false;
        //newZquote.zqu__GenerateInvoice__c = originalQuote != null ? originalQuote.zqu__GenerateInvoice__c : true;
        newZquote.zqu__GenerateInvoice__c = (item.NE__OrderId__r.XC_Subtype__c == 'eMobility Change Offer' && originalQuote != null) ? originalQuote.zqu__GenerateInvoice__c : false;

        Id quoteAmendRT = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        newZquote.RecordTypeId = quoteAmendRT;
        XC_UTIL_Sobject.updateRecord(newZquote);
      
        
        Params par = new Params();
        DeltaWrapper deltaWr = new DeltaWrapper();
        deltaWr.price = item.NE__RecurringChargeOv__c;
        deltaWr.maxMonth = item.XC_Max_Months_Renting__c;
        deltaWr.monthsPast = wrapper.monthsPast;
        deltaWr.posMonthsPast = wrapper.posMonthsPast;
        par.price = String.valueOf(item.NE__RecurringChargeOv__c - computeDelta(deltaWr));
        par.quantity = String.valueOf(item.NE__Qty__c);
        
        Map<String, Params> mapZQuotePrice = new Map<String, Params>();
        mapZQuotePrice.put(newZquote.Id, par);
        System.debug('mapZQuotePrice-->'+mapZQuotePrice);
 
        System.debug('newZquote Id-->'+newZquote.Id);
        //XC_UTIL_Sobject.updateRecord(newZquote);      

        if(!Test.isRunningTest()) {
            System.enqueueJob(new ManageDMLQueuable(newZquote.Id, mapZQuotePrice));
        }
        
    }
    
    private static UtilWrapper checkMonthsPast(Integer monthsPast, Boolean posMonthsPast, Date activationDate){
        UtilWrapper utilWr = new UtilWrapper();
        Date todayDate = Date.today();
        if(monthsPast < 0) {
            monthsPast = todayDate.monthsBetween(activationDate);
            posMonthsPast = false;
        }
        utilWr.posMonthsPast = posMonthsPast;
        utilWr.monthsPast = monthsPast;
        return utilWr;  
    } 

    /**
     * @description  Override prices.
     * @param mapZQuotePrice the map Z quote price
     */
    public static void overridePrices(Map<String, Params> mapZQuotePrice){
        
        List<zqu.zChargeGroup> chargeGroupsExt = new List<zqu.zChargeGroup>();
        String effectivePrice;
        String quantity;
            
        for(Id quoteId: mapZQuotePrice.keySet()){
            
            Params params = mapZQuotePrice.get(quoteId);
            effectivePrice = params.price;
            quantity = params.quantity;
            
            List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
            if(!Test.isRunningTest()) {
            	chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
            }
            
            if(effectivePrice != null){
               
                List<zqu.zCharge> effCharge = new List<zqu.zCharge> ();

                for(zqu.zChargeGroup zchargeGroup: chargeGroups){
                    System.debug('charge');
                    for(zqu.zCharge zcharge: zchargeGroup.zCharges){
                        System.debug('zcharge -->'+zcharge); 
                            
                        System.debug('zcharge.isEffectivePriceEditable -->'+zcharge.isEffectivePriceEditable);
                        if(zcharge.isEffectivePriceEditable){
                            zcharge.EFFECTIVE_PRICE = effectivePrice;
                            effCharge.add(zcharge);
                        }       
                        
                    }
                }
                
                List<zqu.zCharge>  chargeGroupsMod = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange( effCharge ); 
            }
            manageNotNullQuantity(quantity, chargeGroups);
            /*if(quantity != null){
                List<zqu.zCharge> effCharge = new List<zqu.zCharge> ();
                //chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
                effCharge = new List<zqu.zCharge> ();
                for(zqu.zChargeGroup zchargeGroup: chargeGroups){
                    System.debug('charge');
                    for(zqu.zCharge zcharge: zchargeGroup.zCharges){
                        System.debug('zcharge -->'+zcharge); 
                       
                        System.debug('zcharge.isQuantityEditable -->'+zcharge.isQuantityEditable);
                        if(zcharge.isQuantityEditable){
                            zCharge.QUANTITY = quantity;
                            effCharge.add(zcharge);
                        }
                         
                    }
                }
                
                List<zqu.zCharge>  chargeGroupsMod = zqu.zQuoteUtil.calculateChargesOnQuantityChange( effCharge );   
            }*/
            chargeGroupsExt.addAll(chargeGroups);
        }   
        updateChargeGroups(chargeGroupsExt);
    }

    private static void manageNotNullQuantity(String quantity, List<zqu.zChargeGroup> chargeGroups){
        if(quantity != null){
            List<zqu.zCharge> effCharge = new List<zqu.zCharge> ();
            //chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
            effCharge = new List<zqu.zCharge> ();
            for(zqu.zChargeGroup zchargeGroup: chargeGroups){
                System.debug('charge');
                for(zqu.zCharge zcharge: zchargeGroup.zCharges){
                    System.debug('zcharge -->'+zcharge); 
                    
                    System.debug('zcharge.isQuantityEditable -->'+zcharge.isQuantityEditable);
                    if(zcharge.isQuantityEditable){
                        zCharge.QUANTITY = quantity;
                        effCharge.add(zcharge);
                    }
                        
                }
            }
            
            List<zqu.zCharge>  chargeGroupsMod = zqu.zQuoteUtil.calculateChargesOnQuantityChange( effCharge );   
        }
    }

    private static void updateChargeGroups(List<zqu.zChargeGroup> chargeGroupsExt){
        if(!chargeGroupsExt.isEmpty()){
            zqu.zQuoteUtil.updateChargeGroups(chargeGroupsExt); 
        }     
    }

    /**
     * @description Compute delta.
     * @param deltaWr DeltaWrapper
     * @return the double
     */
    private static Double computeDelta(DeltaWrapper deltaWr) {
        Integer offsetMonths = Integer.valueOf(deltaWr.maxMonth) - deltaWr.monthsPast;
        Double res;
        if(deltaWr.posMonthsPast) {
            res = deltaWr.price - (deltaWr.price * offsetMonths) / deltaWr.maxMonth;
        } else {
            res = deltaWr.price + (deltaWr.price * offsetMonths) / deltaWr.maxMonth;
        }
        return res;
    }

    private static String getCurrentSubscription(List<Zuora__Subscription__c> subscriptionList) {
        String currentSubscription = '';
        for(Zuora__Subscription__c elem2 : subscriptionList) {
            currentSubscription = elem2.Zuora__Zuora_Id__c;
        }
        return currentSubscription;
    }

    private static void setSubscriptionIDAndZuoraAccountID(zqu__Quote__c newZQuote, String currentSubscription, String subscriptionZuoraId) {
        if(currentSubscription == null || currentSubscription==''){
            newZquote.zqu__ExistSubscriptionID__c = subscriptionZuoraId; 
        } else {
            newZquote.zqu__ExistSubscriptionID__c = currentSubscription;
        }
    }

    private static NE.DataMap.DataMapResponse getZQuoteByDataMap(String orderId) {
        NE.DataMap.DataMapResponse dResp;
        if(!Test.isRunningTest()) {
            dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('ChangeOrder2Zquote', orderId);
        } else {
            dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', orderId);
        }
        return dResp;
    }

}