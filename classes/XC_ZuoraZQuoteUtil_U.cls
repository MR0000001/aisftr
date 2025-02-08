/**
* The Class XC_ZuoraZQuoteUtil_U
*@description The Class XC_ZuoraZQuoteUtil_U. 
*/
public with sharing class XC_ZuoraZQuoteUtil_U {

    /**
     * The Class UtilWrapper.
     *@description The Class UtilWrapper. 
     */
    public class UtilWrapper {
        public NE__MapObjectItem__c moi;
        public Set<String> orderFieldsToQuerySet;
        public Map<String, String> mappingZQuoteOrderFields;
        public Map<String, String> mappingZQuoteOrderValues;
        public NE__Order__c order;
    }

   /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
   /* public static Map<String, NE__Billing_Profile__c> getNEBillingProfilesRelatedToZAccountIds(List<Zuora__PaymentMethod__c> paymentMethods){
        Set<String> zAccountIds = new Set<String>();
        for(Zuora__PaymentMethod__c pm: paymentMethods){
            zAccountIds.add(pm.Zuora__BillingAccount__r.Zuora__External_Id__c);
        }
        System.debug('@@@@@@@@@@ zAccountIds = '+zAccountIds);
        Map<Id, NE__Billing_Profile__c> billProfToUpdMap = new Map<Id, NE__Billing_Profile__c>([ SELECT Id, Zuora_Account_Id__c FROM NE__Billing_Profile__c WHERE Zuora_Account_Id__c IN: zAccountIds]);
        List<NE__Billing_Profile__c> billProfToUpd = billProfToUpdMap.values();
        Map<String, NE__Billing_Profile__c> billProfMap = new Map<String, NE__Billing_Profile__c>();
        for(NE__Billing_Profile__c bp : billProfToUpd){
            billProfMap.put(bp.Zuora_Account_Id__c, bp);
        }
        System.debug('@@@@@@@@@ billProfMap = '+billProfMap);
        return billProfMap;
    }*/

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
    /*public static void populateZquoteFields(zqu__Quote__c q, UtilWrapper utilWr) {
        NE__Order__c order = utilWr.order;

        for(String zquField: utilWr.mappingZQuoteOrderFields.keySet()){
            String orderField = utilWr.mappingZQuoteOrderFields.get(zquField);
            q.put(zquField, order.get(orderField));  
        }
        for(String zquField: utilWr.mappingZQuoteOrderValues.keySet()){
            String orderField = utilWr.mappingZQuoteOrderValues.get(zquField);
            if(isNumeric(orderField)){
                q.put(zquField, Decimal.valueOf(orderField));
            }else{
                q.put(zquField, orderField);
            }
            
        }
        if(q.zqu__StartDate__c == null){
            q.put('zqu__StartDate__c', date.today());
            q.put('zqu__ValidUntil__c', date.today());
        }
    }*/

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static void populateMapZQuotesDiscountPercentage(Map<Id, String> mapZQuotesDiscountPercentage, NE__OrderItem__c configurationItem) {
        if(configurationItem.NE__Discount_Perc_OneTimeFee__c != 0){
            mapZQuotesDiscountPercentage.put(configurationItem.XC_ZQuoteId__c, String.valueOf(configurationItem.NE__Discount_Perc_OneTimeFee__c));
        }else if(configurationItem.NE__Discount_Perc_RecurringCharge__c != 0){
            mapZQuotesDiscountPercentage.put(configurationItem.XC_ZQuoteId__c, String.valueOf(configurationItem.NE__Discount_Perc_RecurringCharge__c));
        }
    }*/

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static void addChargeGroupsUtil(Map<Id, String> mapZQuotesDiscountPercentage, List<Id> productRatePlanIds) {

        Map<Id, zqu__QuoteRatePlanCharge__c> rpCharge
            = new Map<Id, zqu__QuoteRatePlanCharge__c>([SELECT Id, zqu__ChargeType__c, zqu__QuoteRatePlan__r.zqu__Quote__c
                                                    FROM zqu__QuoteRatePlanCharge__c 
                                                    WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :mapZQuotesDiscountPercentage.keySet()
                                                ]);
        //Map<Id, String> mapZQuoteIdToChargeType = populateMapZQuoteChargeType(rpCharge);
        List< zqu__QuoteRatePlanCharge__c> listRPC = rpCharge.values();
        List<zqu.zCharge> effCharge;
	
        for(Id quoteId: mapZQuotesDiscountPercentage.keySet()){

           String effectivePrice = mapZQuotesDiscountPercentage.get(quoteId);
            List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId, productRatePlanIds);
            
            //if(mapZQuoteIdToChargeType.get(quoteId) != 'Usage') {
            for(zqu__QuoteRatePlanCharge__c rpc : listRPC) {
                if(rpc.zqu__ChargeType__c != 'Usage') {
                	effCharge = XC_ZuoraZQuoteUtil_U.populateListEffCharge(chargeGroups, effectivePrice);
                    List<zqu.zCharge> chargeGroupsMod = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange( effCharge );
                     System.debug('chargeGroupsMod-->'+chargeGroupsMod);
                }
            }
            
            zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        }
    }*/

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static void populateOrderFieldsToQuerySet(UtilWrapper wr) {

        if(wr.moi.NE__SourceField__c != null ){
            if(wr.moi.NE__SourceField__c =='accountid__c'){
                wr.orderFieldsToQuerySet.add('ne__accountid__c'); 
            }else{
                wr.orderFieldsToQuerySet.add(wr.moi.NE__SourceField__c);
            }
        }   
        if(wr.moi.NE__Type__c == 'Field'){
            if(wr.moi.NE__SourceField__c =='accountid__c'){
                wr.mappingZQuoteOrderFields.put(wr.moi.NE__TargetField__c,'ne__accountid__c');
            }else{
                wr.mappingZQuoteOrderFields.put(wr.moi.NE__TargetField__c, wr.moi.NE__SourceField__c);
            }
            
        }else if(wr.moi.NE__Type__c == 'Value' ){
            wr.mappingZQuoteOrderValues.put(wr.moi.NE__TargetField__c, wr.moi.NE__Value__c);
        }

    }*/

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static String assignPayment(Zuora__PaymentMethod__c pm) {
        if(pm.Zuora__Type__c == 'BankTransfer'){
            return 'Direct Debt';
        }else{
            return 'Credit Card';
        }
    }*/

    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*public static List<zqu.zCharge> populateListEffCharge(List<zqu.zChargeGroup> chargeGroups, String effectivePrice) {
        
        List<zqu.zCharge> effCharge = new List<zqu.zCharge> ();
        for(zqu.zChargeGroup zchargeGroup: chargeGroups){
            System.debug('charge');
            for(zqu.zCharge zcharge: zchargeGroup.zCharges){
                System.debug('zcharge -->'+zcharge); 
                if ( zcharge.CHARGE_TYPE != 'Usage') {
                	zcharge.EFFECTIVE_PRICE = effectivePrice;         
                    effCharge.add(zcharge);
                } 
            }
        }
        return effCharge;
    }*/
    
    /**
    *@description populateListEffCharge 
    *@param chargeGroups
    *@param effectivePrice
    *@return List<zqu.zCharge>
    */
    public static List<zqu__QuoteRatePlanCharge__c> populateListEffCharge(List<zqu__QuoteRatePlanCharge__c> chargeGroups, String effectivePrice) {

        Map<String, Object> mapUtil = new Map<String,Object>{
                                                            'effectivePrice' => effectivePrice,
                                                            'date' => Date.today()
                                                            };
     
        return populateListEffCharge(chargeGroups, mapUtil, new List<NE__Order_Item_Discount__c>());
    }

    
    /**
    *@description populateListEffCharge 
    *@param chargeGroups
    *@param mapUtil
    *@param oiDiscount
    *@return List<zqu.zCharge>
    */
    public static List<zqu__QuoteRatePlanCharge__c> populateListEffCharge(List<zqu__QuoteRatePlanCharge__c> chargeGroups,  Map<String, Object> mapUtil, List<NE__Order_Item_Discount__c> oiDiscount) {
     
        String effectivePrice = (String) maputil.get('effectivePrice');
        
        System.debug(LoggingLevel.Finest, '@@##' + chargeGroups);
        for(zqu__QuoteRatePlanCharge__c zcharge: chargeGroups){
            System.debug('zcharge -->'+zcharge); 
            if (zcharge.zqu__ChargeType__c != 'Usage' && !zcharge.zqu__Model__c.equalsIgnoreCase('Discount-Percentage') && !zcharge.zqu__Model__c.equalsIgnoreCase('Discount-Fixed Amount')){
                zcharge.zqu__EffectivePrice__c = Decimal.valueOf(effectivePrice);   
                zcharge.zqu__ListPrice__c = Decimal.valueOf(effectivePrice);
                zcharge.zqu__ListTotal__c = Decimal.valueOf(effectivePrice);
                zcharge.zqu__Total__c = Decimal.valueOf(effectivePrice);
            } 
            
            XC_IN018_CreateZQuote_UU.manageOrderItemDiscountsCharges(zcharge, oiDiscount, mapUtil);
        }
        System.debug(LoggingLevel.Finest, '@@##' + chargeGroups);
        return chargeGroups;
    }



    /**
    *@description retrieve zuora entity id by legalEntity
    *@param legalEntity - String 
    *@param stepId - String
    *@return entityId - String
    */
    /*public static String getZuoraEntityId(String legalEntity, String stepId){

        String entityId;
        if(String.isBlank(legalEntity)) {
            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
            step.id = stepId;
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = Label.XC_CL_Opportunity_NoLegalEntity;
            XC_UTIL_Sobject.updateRecord(step);
            return null;
        }
     
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legEntityMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_ZuoraEntityId__c
                                                                                                                        FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                        WHERE XC_LegalEntity__c =: legalEntity AND XC_OrgId__c =: orgId]);
        List<XC_CM_LegalEntity_Configuration__mdt> legEntityList = legEntityMap.values();
        
        if(!legEntityList.isEmpty() && String.isNotBlank(legEntityList[0].XC_ZuoraEntityId__c)) {
            entityId = legEntityList[0].XC_ZuoraEntityId__c;
        } else {
            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
            step.id = stepId;
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = Label.XC_CL_LegalEntity_NoZuoraEntity;
            XC_UTIL_Sobject.updateRecord(step);
            return null;
        }

        return entityId;
    }*/
    
    
     /**
     * The Class EntityWrapper.
     * @description The Class EntityWrapper. 
     */
    public class EntityWrapper {
        public String entityId;
        public String timeZone;
    }

    /**
     * GetZuoraEntityWrapper.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description retrieve zuora entity id and timezone by legalEntity
     * @param legalEntity - String 
     * @param stepId - String
     * @return EntityWrapper
     */
    /*public static EntityWrapper getZuoraEntityWrapper(String legalEntity, String stepId) {

        EntityWrapper entityWr = new EntityWrapper();

        if(String.isBlank(legalEntity)) {
            if(String.isNotBlank(stepId)) {
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
                step.id = stepId;
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_Opportunity_NoLegalEntity;
                XC_UTIL_Sobject.updateRecord(step);
            }
            return null;
        }
     
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legEntityMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_ZuoraEntityId__c, XC_TimeZone__c
                                                                                                                        FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                        WHERE XC_LegalEntity__c =: legalEntity AND XC_OrgId__c =: orgId]);
        List<XC_CM_LegalEntity_Configuration__mdt> legEntityList = legEntityMap.values();
        
        if(!legEntityList.isEmpty()) {
            entityWr.entityId = legEntityList[0].XC_ZuoraEntityId__c;
            entityWr.timeZone = legEntityList[0].XC_TimeZone__c;
        } else {
            if(String.isNotBlank(stepId)) {
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
                step.id = stepId;
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_LegalEntity_NoZuoraEntity;
                XC_UTIL_Sobject.updateRecord(step);
            }
            return null;
        }

        return entityWr;
    }*/


    /**
     * GetZuoraEntityWrapper.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description retrieve zuora entity id and timezone by legalEntity
     * @param legalEntity - String 
     * @param stream - String 
     * @param stepId - String
     * @return EntityWrapper
     */
    public static EntityWrapper getZuoraEntityWrapper(String legalEntity, String stream, String stepId) {

        EntityWrapper entityWr = new EntityWrapper();

        if(String.isBlank(legalEntity) || String.isBlank(stream)) {
            if(String.isNotBlank(stepId)) {
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
                step.id = stepId;
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_Opportunity_NoLegalEntity;
                XC_UTIL_Sobject.updateRecord(step);
            }
            return null;
        }
     
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legEntityMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_ZuoraEntityId__c, XC_TimeZone__c
                                                                                                                        FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                        WHERE XC_OrgId__c =: orgId AND
                                                                                                                            XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream]);
        List<XC_CM_LegalEntity_Configuration__mdt> legEntityList = legEntityMap.values();
        
        if(!legEntityList.isEmpty()) {
            entityWr.entityId = legEntityList[0].XC_ZuoraEntityId__c;
            entityWr.timeZone = legEntityList[0].XC_TimeZone__c;
        } else {
            if(String.isNotBlank(stepId)) {
                XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
                step.id = stepId;
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = Label.XC_CL_LegalEntity_NoZuoraEntity;
                XC_UTIL_Sobject.updateRecord(step);
            }
            return null;
        }

        return entityWr;
    }


    /** @Federico Amici 06/21/2019 Method commented because not used. ApexDoc deleted to avoid PMD errors */
    /*private static Map<Id, String> populateMapZQuoteChargeType(Map<Id, zqu__QuoteRatePlanCharge__c> rpCharge) {
        Map<Id, String> mapZQuoteIdToChargeType = new Map<Id, String>();
        String zQuoteId;
        String chargeType;
        for(zqu__QuoteRatePlanCharge__c rpc : rpCharge.values()) {
            zQuoteId = rpCharge.get(rpc.Id).zqu__QuoteRatePlan__r.zqu__Quote__c;
            chargeType = rpCharge.get(rpc.Id).zqu__ChargeType__c;
            mapZQuoteIdToChargeType.put(zQuoteId, chargeType);
        }
        return mapZQuoteIdToChargeType;
    }*/
    
}