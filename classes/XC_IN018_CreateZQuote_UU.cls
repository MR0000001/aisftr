/**
 * The Class XC_IN018_CreateZQuote_UU.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 19/06/2019
 * @date Modification 07/08/2019 by Nicola Mariniello - nmariniello@deloitte.it
 * @description Util of the XC_IN018_CreateZQuote_U class
 */


public without sharing class XC_IN018_CreateZQuote_UU {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN018_CreateZQuote');


    /** @description wrapper */
    public class SetInitTermWrapper {
        public zqu__Quote__c zqu;
        public XC_IN018_CreateZquote_U.ZQuoteOption option;
        public String ciBillMod;
        public NE__OrderItem__c confItem;
    }


     /**
     * @description Populates zuora account id
     * @author Federico Amici - federico.amici@nttdata.com
     * @param wr the updatewrapper
     * @return the zuora account id string
     */
    public static String populateZuoraAccountID(XC_IN018_CreateZQuote_U.UpdateWrapper wr) {
        if(String.isNotBlank(wr.item.XC_BillingProfileLineItem__c)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ' + wr.item.XC_BillingProfileLineItem__c);
            return wr.item.XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_id__c;
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE,  wr.item.NE__BillingProfId__r.Zuora_Account_Id__c);
            return wr.item.NE__BillingProfId__r.Zuora_Account_Id__c;
        }
    }
    

    /**
     * @description creates the map that links qrpc to prpc
     * @author Federico Amici - federico.amici@nttdata.com
     * @param listQRPC
     * @param listPRPC
     * @return the map
     */
    public static Map<String, zqu__ProductRatePlanCharge__c> createMapQRPCToPRPC(List<zqu__QuoteRatePlanCharge__c> listQRPC, List<zqu__ProductRatePlanCharge__c> listPRPC) {		
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listQRPC -> ' + listQRPC);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPRPC -> ' + listPRPC);

        Map<String, zqu__ProductRatePlanCharge__c> mapRet = new Map<String, zqu__ProductRatePlanCharge__c>();		
        for(zqu__QuoteRatePlanCharge__c qrpc : listQRPC) {		
            zqu__ProductRatePlanCharge__c prpcFound = getPRPCByName(qrpc.zqu__ProductRatePlanCharge__c, listPRPC);		
            if(prpcFound == null) {		
                mapRet.put(qrpc.Name, new zqu__ProductRatePlanCharge__c(Id = listPRPC[0].Id,    // for Test Class
                                                                        XC_WBE__c = '',
                                                                        XC_ProfitCenter__c = '',
                                                                        TariffType__c = ''));
            } else {		
                mapRet.put(qrpc.Name, prpcFound);		
            }		
        }
        return mapRet;		
    }		


    /**
     * @description getPRPCByName
     * @author Federico Amici - federico.amici@nttdata.com
     * @param name
     * @param listPRPC
     * @return the prpc
     */
    public static zqu__ProductRatePlanCharge__c getPRPCByName(String prpcId, List<zqu__ProductRatePlanCharge__c> listPRPC) {		
        for(zqu__ProductRatePlanCharge__c prpc : listPRPC) {		
            if(prpcId == prpc.Id) {		
                return prpc;		
            }		
        }		
        return null;		
    }


    /**
     * @description Computes the foundAttr boolean
     * @author Federico Amici - federico.amici@nttdata.com
     * @param attr the orderItemAttribute list
     * @param foundAttr the foundAttr flag
     */
    public static void computeFoundAttr(List<NE__Order_Item_Attribute__c> attr, Boolean foundAttr) {
        for(NE__Order_Item_Attribute__c a : attr) {
            if(a.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel ||
              a.XC_DeveloperName__c == 'Modelo de Pago') {
                foundAttr = true;
            }
        }
    }


    /**
     * @description Calculate initial term.
     * @author Federico Amici - federico.amici@nttdata.com
     * @param confItemId the conf item id
     * @return the map
     */
    public static Map<Id, XC_IN018_CreateZQuote_U.ZQuoteOption> calculateInitialTerm(String confItemId){
        if(!Schema.sObjectType.NE__Order_Item_Attribute__c.isAccessible()){
            return null;
        }
        Map<Id, XC_IN018_CreateZQuote_U.ZQuoteOption> mapOrderItemInitialTerm = new Map<Id, XC_IN018_CreateZQuote_U.ZQuoteOption>();
        
        String paymentModel = Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel;
        String formaDePago = Label.XC_CL_ConfigurationItemAttribute_DevFormaDePago;

        Set<String> developerNames = new Set<String>{paymentModel, formaDePago};
        List<NE__Order_Item_Attribute__c> configurationItemAttributes = [SELECT NE__Order_Item__c ,Name, NE__Value__c, XC_DeveloperName__c 
                                                                        FROM NE__Order_Item_Attribute__c 
                                                                        WHERE XC_DeveloperName__c IN :developerNames 
                                                                            AND NE__Order_Item__c = :confItemId];
        
        for(NE__Order_Item_Attribute__c oia: configurationItemAttributes){
            Id oiId = oia.NE__Order_Item__c;
            Boolean autoRenew = false; 
            String value = oia.NE__Value__c;
            String developerName = oia.XC_DeveloperName__c;
            Integer initialTerm = 1;
            if(developerName == paymentModel){
                if(value.contains('3')){
                    initialTerm =  36;  
                }else if(value.contains('5')){
                    initialTerm = 60;
                }else if(value.contains('7')){
                    initialTerm = 84;
                }else if(value == Label.XC_CL_PaymentModel_Mensual || value == Label.XC_CL_PaymentModel_Annual || value == Label.XC_CL_PaymentModel_Monthly){
                    initialTerm = 12;
                    autoRenew = true;
                }
            }else if(developerName == formaDePago){
                initialTerm = 12;
                autoRenew = true;
            }
            mapOrderItemInitialTerm.put(oiId, new XC_IN018_CreateZQuote_U.ZQuoteOption(autoRenew,initialTerm));
        } 
        
        return mapOrderItemInitialTerm;
    }


    /**
     * @description Calculate effective price.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param assetList the asset list
     * @return the map
     */
    public static Map<String, String> calculateEffectivePrice(List<Asset> assetList,Map<String,List<NE__Order_Item_Discount__c>> discounts){

        Map<String, String> confItemIdEffectivePriceMap = new Map<String, String>();

        for(Asset a : assetList) {
            String effectivePrice = '0';
            Boolean hasDiscountApplied = discounts.containsKey(a.XC_Configuration_Item__c);

            if(hasDiscountApplied){
                if(a.XC_Configuration_Item__r.NE__BaseOneTimeFee__c != 0){
                    effectivePrice = String.valueOf(a.XC_Configuration_Item__r.NE__BaseOneTimeFee__c);
                }else if(a.XC_Configuration_Item__r.NE__BaseRecurringCharge__c != 0){
                    effectivePrice = String.valueOf(a.XC_Configuration_Item__r.NE__BaseRecurringCharge__c);
                }

            }else{
                if(a.XC_Configuration_Item__r.NE__OneTimeFeeOv__c != 0){
                    effectivePrice = String.valueOf(a.XC_Configuration_Item__r.NE__OneTimeFeeOv__c);
                } else if(a.XC_Configuration_Item__r.NE__RecurringChargeOv__c != 0){
                    effectivePrice = String.valueOf(a.XC_Configuration_Item__r.NE__RecurringChargeOv__c);
                }
            }
            //if(a.XC_Configuration_Item__r.XC_BillingModel__c == 'Billing Plan') {
            //    confItemIdEffectivePriceMap.put(a.XC_Configuration_Item__c, '0');
            //}else{
                confItemIdEffectivePriceMap.put(a.XC_Configuration_Item__c, effectivePrice);
            //}
        }

        return confItemIdEffectivePriceMap;
    }


    /**
     * @description Calculate effective price for change order with subtype Substitution (Malfunction).
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param oldItem the old item list
     * @param discounts the discounts
     * @param newItem the new item id
     * @return the map
     */
    public static Map<String, String> calculateEffectivePriceMulfunction(NE__OrderItem__c oldItem, Map<String,List<NE__Order_Item_Discount__c>> discounts, Id newItem){

        Map<String, String> confItemIdEffectivePriceMap = new Map<String, String>();

        String effectivePrice = '0';
        Boolean hasDiscountApplied = discounts.containsKey(oldItem.Id);

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

        confItemIdEffectivePriceMap.put(newItem, effectivePrice);
        
        return confItemIdEffectivePriceMap;
    }


    /**
     * @description populate Rcp Fields.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param rpc the quote rate plan charge
     * @param inputFields the map of input fields
     */
    public static void populateRcpFields(zqu__QuoteRatePlanCharge__c rpc, Map<String, Object> inputFields) {

        zqu__ProductRatePlanCharge__c prpc = (zqu__ProductRatePlanCharge__c) inputFields.get('prpc');
        String confItemId = (String) inputFields.get('confItemId');
        Map<String, String> confItemIdEffectivePriceMap = (Map<String, String>) inputFields.get('confItemIdEffectivePriceMap');
        Map<String, Asset> confItemIdAssetMap = (Map<String, Asset>) inputFields.get('confItemIdAssetMap');
        Map<String,List<NE__Order_Item_Discount__c>> oiDiscountMap = (Map<String,List<NE__Order_Item_Discount__c>>) inputFields.get('oiDiscountMap');
        Date startDate = (Date) inputFields.get('date');

        List<NE__Order_Item_Discount__c> discounts = oiDiscountMap.containsKey(confItemId) ? oiDiscountMap.get(confItemId) : null;

        System.Debug('DISCOUNT FOUND ON ITEM :::: ' + discounts);

        if(rpc.zqu__ChargeType__c != 'Usage' && confItemIdAssetMap.containsKey(confItemId)) {
            rpc.XC_WBE__c = (!String.isBlank(prpc.XC_WBE__c)) ? prpc.XC_WBE__c : confItemIdAssetMap.get(confItemId).XC_WBE__c;
            rpc.XC_ProfitCenter__c = (!String.isBlank(prpc.XC_ProfitCenter__c)) ? prpc.XC_ProfitCenter__c : confItemIdAssetMap.get(confItemId).XC_CMProfitCenter__c;

            // Effective Price

            if(rpc.zqu__Model__c != null && !rpc.zqu__Model__c.equalsIgnoreCase('Discount-Percentage') && !rpc.zqu__Model__c.equalsIgnoreCase('Discount-Fixed Amount')){
                
                String effectivePrice = confItemIdEffectivePriceMap.get(confItemId);
                System.debug('@@@ effective price: ' + effectivePrice + '   for confItem ' + confItemId);
                if(String.isNotBlank(effectivePrice)) {
                    rpc.zqu__EffectivePrice__c = Decimal.valueOf(effectivePrice);   
                    rpc.zqu__ListPrice__c = Decimal.valueOf(effectivePrice);
                    rpc.zqu__ListTotal__c = Decimal.valueOf(effectivePrice);
                    rpc.zqu__Total__c = Decimal.valueOf(effectivePrice);
                }   

                if(rpc.zqu__ChargeType__c != 'FlatFee') {
                    rpc.zqu__Quantity__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Qty__c;
                }

            }

            Map<String,Object> opts = new Map<String,Object>();
            opts.put('date', startDate);
            opts.put('qty', confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Qty__c);
            manageOrderItemDiscountsCharges(rpc, discounts,opts);

            
        } else {
            rpc.XC_WBE__c = prpc.XC_WBE__c;
            rpc.XC_ProfitCenter__c = prpc.XC_ProfitCenter__c;
        }
    }
    

    /**
     * @description replace Payment Method.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param zqu the zQuote
     */
    public static void replacePaymentMethod(zqu__Quote__c zqu) {

        if (zqu.zqu__PaymentMethod__c == 'Credit Card SIA' ) {
            zqu.zqu__PaymentMethod__c = 'Credit Card';
        } else if ((zqu.zqu__PaymentMethod__c == 'Commodity Bill') || (zqu.zqu__PaymentMethod__c == 'Barcode')) {
            zqu.zqu__PaymentMethod__c = 'Other';
        } else if (zqu.zqu__PaymentMethod__c == 'Direct Debt') {
            zqu.zqu__PaymentMethod__c = 'Bank Transfer';
        }
    }

    /**
     * @description Retrieve
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param subsidyItemIds
     * @return Map<Id,Map<String,NE__Order_Item_Attribute__c>>
     */

    public static Map<Id,Map<String,NE__Order_Item_Attribute__c>> retriveConfItemAttribute(List<String> subsidyItemIds){
        List<NE__Order_Item_Attribute__c> listConfAtt = new List<NE__Order_Item_Attribute__c>();
        Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt = new Map<Id,Map<String,NE__Order_Item_Attribute__c>>();
        if(Schema.sObjectType.NE__Order_Item_Attribute__c.isAccessible()){
            listConfAtt = [SELECT Id, NE__Order_Item__r.name, NE__Order_Item__r.NE__ProdName__c, Name, NE__Value__c, XC_DeveloperName__c, NE__FamPropId__r.XC_ShowInInvoice__c
                           FROM NE__Order_Item_Attribute__c
                           WHERE NE__Order_Item__c IN: subsidyItemIds
                            Order by Name asc];
        }
        for(Id i : subsidyItemIds){
            for(NE__Order_Item_Attribute__c o : listConfAtt){
                if(i==o.NE__Order_Item__c){
                    mapIdMapNameConfItemAtt.put(i, new Map<String,NE__Order_Item_Attribute__c>());
                }
            }
        }
        mapIdMapNameConfItemAtt = populateMapNameValue(mapIdMapNameConfItemAtt,listConfAtt);
        return mapIdMapNameConfItemAtt;

    }

    private static Map<Id,Map<String,NE__Order_Item_Attribute__c>> populateMapNameValue( Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt,List<NE__Order_Item_Attribute__c> listConfAtt){
        Map<String,NE__Order_Item_Attribute__c> mapNameConfItemAtt = new Map<String,NE__Order_Item_Attribute__c>();
        for(Id i :mapIdMapNameConfItemAtt.keySet()){
            for(NE__Order_Item_Attribute__c o :listConfAtt ){
                if(i==o.NE__Order_Item__c){
                    mapIdMapNameConfItemAtt.get(i).put(o.XC_DeveloperName__c,o);
                }
            }

        }
        return mapIdMapNameConfItemAtt;
    }

    /***
    *@author: francesco imperioli
    *@description: manage orderitem discounts mapping with zuora discount charges
    *@createddate : 2019-12-10
    */
    public static void manageOrderItemDiscountsCharges(zqu__QuoteRatePlanCharge__c rpc, List <NE__Order_Item_Discount__c> discounts, Map<String,Object> opts) {

     //fimp--> discount management custom 20/11/2019
        if (discounts != null && !discounts.isEmpty()) {
            
            System.Debug(':::DISCOUNTS FOUND::');
            Date startDate = opts.containsKey('date') ? (Date) opts.get('date') : Date.today();

            if (rpc.zqu__Model__c.equalsIgnoreCase('Discount-Percentage')) {

                //only one percentage discount must be setted up on order
                NE__Order_Item_Discount__c percDiscount = null;
                
                for(NE__Order_Item_Discount__c perDisc : discounts){
                    if(perDisc.NE__Type__c != 'Value'){
                        percDiscount = perDisc;
                    }
                }


                if (percDiscount != null && percDiscount.NE__Type__c != 'Value') {

                    Decimal discountValuePerc = percDiscount.NE__One_Time_Percentage__c != 0 ? percDiscount.NE__One_Time_Percentage__c : percDiscount.NE__Recurring_Percentage__c;

                    rpc.zqu__DiscountPercentage__c = discountValuePerc;

                    rpc.zqu__EffectivePrice__c = discountValuePerc;
                    rpc.zqu__ListPrice__c = discountValuePerc;
                    rpc.zqu__ListTotal__c = discountValuePerc;
                    rpc.zqu__Total__c = discountValuePerc;
                    rpc.zqu__Quantity__c = 1;

                    System.Debug('MONTHS OF APPLICATION' + rpc.zqu__Model__c + 'RPC MODEL');

                    calculateEndDate(rpc, startDate, percDiscount);

                } else {
                        rpc.zqu__DiscountPercentage__c = 0;
                        rpc.zqu__EffectivePrice__c = 0;
                        rpc.zqu__Discount__c = 0;
                        rpc.zqu__ListPrice__c = 0;
                        rpc.zqu__ListTotal__c = 0;
                        rpc.zqu__Total__c = 0;
                }

            } else if (rpc.zqu__Model__c.equalsIgnoreCase('Discount-Fixed Amount')) {

                System.Debug('FIXED AMOUNT DISCOUNT CASE');

                Decimal discountAmount = 0.0;

                NE__Order_Item_Discount__c absdiscount = null;
                NE__Order_Item_Discount__c perdiscount = null;
                Boolean firstDiscountValue = true;
                for (NE__Order_Item_Discount__c discount : discounts) {
                    if (discount.NE__Type__c == 'Value') {
                        discountAmount += discount.NE__One_Time_Value__c != 0 ? discount.NE__One_Time_Value__c : discount.NE__Recurring_Value__c;
                        if(firstDiscountValue) {
                            absdiscount = discount;
                            firstDiscountValue = false;
                        }

                    } else if(discount.NE__Type__c != 'Value' && discount.NE__Start_Date__c != null && discount.NE__End_Date__c != null) {
                        perdiscount = discount;
                    }
                }

                Decimal qty = (opts.containsKey('qty') && opts.containsKey('qty') != null) ? (Decimal) opts.get('qty') : null;
                discountAmount = (qty != null && qty != 0) ? discountAmount * qty : discountAmount;
                rpc.zqu__DiscountAmount__c = discountAmount;
                rpc.zqu__EffectivePrice__c = discountAmount;
                rpc.zqu__ListPrice__c = discountAmount;
                rpc.zqu__ListTotal__c = discountAmount;
                rpc.zqu__Total__c = discountAmount;
                rpc.zqu__Quantity__c = 1;

                if(absdiscount != null) {
                    if(perdiscount != null && absdiscount.NE__Start_Date__c > perdiscount.NE__End_Date__c) {
                        Integer delay = perdiscount.NE__Start_Date__c.daysBetween(Date.valueOf(absdiscount.NE__Order_Item__r.NE__OrderId__r.CreatedDate));
                        startDate = (delay > 0) ? startDate.addDays(delay) : startDate;
                    }
                    
                    calculateEndDate(rpc, startDate, absdiscount);
                }

                System.Debug('TOTAL DISCOUNT AMOUNT::: ' + discountAmount);
            }

        }
    }

        /**
     * @description Calculate effective price.
     * @author Dario Tramontin d.tramontin@deloitte.it
     * @param quoteRatePlanCharge Date NE__Order_Item_Discount__c
     * @return the map
     */
    public static void calculateEndDate(zqu__QuoteRatePlanCharge__c rpc, Date startDate, NE__Order_Item_Discount__c discount){

        //Integer monthsOfApplication = 0;
        Integer daysOfApplication = 0;
        if(discount.NE__Start_Date__c != null && discount.NE__End_Date__c != null){
           // monthsOfApplication = discount.NE__Start_Date__c.monthsBetween(discount.NE__End_Date__c);
           daysOfApplication = discount.NE__Start_Date__c.daysBetween(discount.NE__End_Date__c);

        }else{
            rpc.zqu__EndDateCondition__c = 'Subscription End Date';
        }

        System.debug('OrderItem: ' + discount.NE__Order_Item__c);
        System.debug('Code:' + discount.NE__Code__c); 
        System.debug('Order: ' + discount.NE__Order_Item__r.NE__OrderId__c);
        System.debug('Date: ' + discount.NE__Order_Item__r.NE__OrderId__r.CreatedDate);
        Integer span = (discount.NE__Start_Date__c != null) ? Date.valueOf(discount.NE__Order_Item__r.NE__OrderId__r.CreatedDate).daysBetween(discount.NE__Start_Date__c) : 0;
        Boolean isFutureDiscount = span > 0 ? true : false;
        
        if(isFutureDiscount){ // to be verified if (isFutureDiscount)
            rpc.zqu__TriggerEvent__c = 'SpecificDate';
            //rpc.zqu__TriggerDate__c = discount.NE__Start_Date__c.addMonths(discount.NE__Start_Date__c.monthsBetween(discount.NE__Order_Item__r.NE__OrderId__r.CreatedDate));
            rpc.zqu__TriggerDate__c = startDate.addDays(span);
        } 

        if (daysOfApplication > 0) {
            // rpc.zqu__EndDateCondition__c = 'Fixed Period';
            rpc.zqu__EndDateCondition__c = 'Specific End Date';
            //rpc.zqu__SpecificEndDate__c = Date.today().addMonths(monthsOfApplication);
            //rpc.zqu__SpecificEndDate__c = startDate.addMonths(monthsOfApplication);
            rpc.zqu__SpecificEndDate__c = (!isFutureDiscount) ? startDate.addDays(daysOfApplication) : rpc.zqu__TriggerDate__c.addDays(daysOfApplication);  
        }
    }


    /**
     * @description Calculate effective price.
     * @author dpalamides
     * @param assetList the asset list
     * @return the map
     */
    public static Map<String, String> calculateEffectivePriceMilestonePPM(List<project_cloud__Project_Task__c> taskList,Map<String,List<NE__Order_Item_Discount__c>> discounts){

        Map<String, String> confItemIdEffectivePriceMap = new Map<String, String>();
	
	List<Id> taskIds = new List<Id>();
        for (project_cloud__Project_Task__c pTask : taskList) taskIds.add(pTask.Id);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'taskIds: ' + taskIds);

        Map<Id,project_cloud__Project_Task__c> projectsInfo = new Map<Id, project_cloud__Project_Task__c>(
                            [SELECT id, XC_MilestonePercentage__c, XC_Milestone__r.XC_Rate__c, XC_Configuration__r.XC_LegalEntity__c,
                                    XC_Configuration__r.NE__OptyId__r.XC_Milestone_Management__c, XC_Milestone__r.XC_OrderItem__c,XC_OrderItem__c,
                                    XC_AmountToBill__c, XC_Milestone__r.XC_OrderItem__r.XC_TotalOneTimeFeeOv__c, XC_Milestone__r.XC_OrderItem__r.NE__Parent_Order_Item__c
                            FROM project_cloud__Project_Task__c
                            WHERE id IN: taskIds]);

        for (project_cloud__Project_Task__c t : projectsInfo.values()){
            //17-02-2022 alag@deloitte.es Milestone Management now applies for all legal entities if Milestone Management is checked - START
            if (/*t.XC_Configuration__r.XC_LegalEntity__c == 'Codensa' &&*/ t.XC_Configuration__r.NE__OptyId__r.XC_Milestone_Management__c) {
            //17-02-2022 alag@deloitte.es Milestone Management now applies for all legal entities if Milestone Management is checked - END
                List<NE__OrderItem__c> childOrderItems = [SELECT id, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE NE__Parent_Order_Item__c =: t.XC_Milestone__r.XC_OrderItem__c];
                for (NE__OrderItem__c configItem : childOrderItems){
                    Decimal effectivePrice = 0;
                    if (configItem.NE__BaseOneTimeFee__c != 0) {
                        effectivePrice = configItem.NE__BaseOneTimeFee__c * ( t.XC_Milestone__r.XC_Rate__c/100);
                    }
                    confItemIdEffectivePriceMap.put(configItem.Id, String.valueOf(effectivePrice));
                }
                Decimal effectivePrice = 0;
                if(t.XC_Milestone__r.XC_OrderItem__r.XC_TotalOneTimeFeeOv__c != 0 &&
                        t.XC_Milestone__r.XC_OrderItem__r.NE__Parent_Order_Item__c == null)
                        {
                            effectivePrice = t.XC_Milestone__r.XC_OrderItem__r.XC_TotalOneTimeFeeOv__c * ( t.XC_Milestone__r.XC_Rate__c/100);
                            confItemIdEffectivePriceMap.put(t.XC_Milestone__r.XC_OrderItem__c, String.valueOf(effectivePrice));
                }else{
                    confItemIdEffectivePriceMap.put(t.XC_Milestone__r.XC_OrderItem__c, '0');
                }
            }else{
                String effectivePrice = '0';
                Boolean hasDiscountApplied = discounts.containsKey(t.XC_Milestone__r.XC_OrderItem__c);

                if(t.XC_AmountToBill__c != 0){
                    effectivePrice = String.valueOf(t.XC_AmountToBill__c);
                }
                confItemIdEffectivePriceMap.put(t.XC_Milestone__r.XC_OrderItem__c, effectivePrice);
            }
        }

        return confItemIdEffectivePriceMap;
    }


    /**
     * @description Calculate effective price.
     * @author dpalamides
     * @param allOrdItems conf item map
     * @param discounts discunts map
     * @return the map
     */
    public static Map<String, String> calculateEffectivePricePreview(Map<id,NE__OrderItem__c> allOrdItems, Map<String,List<NE__Order_Item_Discount__c>> discounts){

        Map<String, String> confItemIdEffectivePriceMap = new Map<String, String>();

        for(NE__OrderItem__c a : allOrdItems.values()) {
            String effectivePrice = '0';
            Boolean hasDiscountApplied = discounts.containsKey(a.id);

            if(hasDiscountApplied){
                if(a.NE__BaseOneTimeFee__c != 0){
                    effectivePrice = String.valueOf(a.NE__BaseOneTimeFee__c);
                }else if(a.NE__BaseRecurringCharge__c != 0){
                    effectivePrice = String.valueOf(a.NE__BaseRecurringCharge__c);
                }

            }else{
                if(a.NE__OneTimeFeeOv__c != 0){
                    effectivePrice = String.valueOf(a.NE__OneTimeFeeOv__c);
                } else if(a.NE__RecurringChargeOv__c != 0){
                    effectivePrice = String.valueOf(a.NE__RecurringChargeOv__c);
                }
            }
            //if(a.XC_BillingModel__c == 'Billing Plan') {
            //    confItemIdEffectivePriceMap.put(a.Id, '0');
            //}else{
                confItemIdEffectivePriceMap.put(a.Id, effectivePrice);
            //}
        }

        return confItemIdEffectivePriceMap;
    }


    /**
     * @description populate Rcp Fields.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param rpc the quote rate plan charge
     * @param inputFields the map of input fields
     */
    public static void populateRcpFieldsPreview(zqu__QuoteRatePlanCharge__c rpc, Map<String, Object> inputFields) {

        zqu__ProductRatePlanCharge__c prpc = (zqu__ProductRatePlanCharge__c) inputFields.get('prpc');
        String confItemId = (String) inputFields.get('confItemId');
        Map<String, String> confItemIdEffectivePriceMap = (Map<String, String>) inputFields.get('confItemIdEffectivePriceMap');
        Map<String, Asset> confItemIdAssetMap = (Map<String, Asset>) inputFields.get('confItemIdAssetMap');
        Map<String,List<NE__Order_Item_Discount__c>> oiDiscountMap = (Map<String,List<NE__Order_Item_Discount__c>>) inputFields.get('oiDiscountMap');
        Date startDate = (Date) inputFields.get('date');
        Map<id,NE__OrderItem__c> allOrdItems = (Map<id,NE__OrderItem__c>) inputFields.get('allOrdItems');
        List<NE__Order_Item_Discount__c> discounts = oiDiscountMap.containsKey(confItemId) ? oiDiscountMap.get(confItemId) : null;

        System.Debug('DISCOUNT FOUND ON ITEM :::: ' + discounts);

        if(rpc.zqu__ChargeType__c != 'Usage' && allOrdItems.containsKey(confItemId)) {
            rpc.XC_WBE__c = (!String.isBlank(prpc.XC_WBE__c)) ? prpc.XC_WBE__c : allOrdItems.get(confItemId).XC_WBE__c;
            rpc.XC_ProfitCenter__c = (!String.isBlank(prpc.XC_ProfitCenter__c)) ? prpc.XC_ProfitCenter__c : allOrdItems.get(confItemId).XC_CMProfitCenter__c;

            // Effective Price

            if(rpc.zqu__Model__c != null && !rpc.zqu__Model__c.equalsIgnoreCase('Discount-Percentage') && !rpc.zqu__Model__c.equalsIgnoreCase('Discount-Fixed Amount')){

                String effectivePrice = confItemIdEffectivePriceMap.get(confItemId);
                System.debug('@@@ effective price: ' + effectivePrice + '   for confItem ' + confItemId);
                if(String.isNotBlank(effectivePrice)) {
                    rpc.zqu__EffectivePrice__c = Decimal.valueOf(effectivePrice);
                    rpc.zqu__ListPrice__c = Decimal.valueOf(effectivePrice);
                    rpc.zqu__ListTotal__c = Decimal.valueOf(effectivePrice);
                    rpc.zqu__Total__c = Decimal.valueOf(effectivePrice);
                }

                if(rpc.zqu__ChargeType__c != 'FlatFee') {
                    rpc.zqu__Quantity__c = allOrdItems.get(confItemId).NE__Qty__c;
                }

            }

            Map<String,Object> opts = new Map<String,Object>();
            opts.put('date',startDate);
            manageOrderItemDiscountsCharges(rpc, discounts,opts);


        } else {
            rpc.XC_WBE__c = prpc.XC_WBE__c;
            rpc.XC_ProfitCenter__c = prpc.XC_ProfitCenter__c;
        }
    }


    /**
     * @description populate Invoice Description Field.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param confItemId the confItemId
     * @param confItemIdAssetMap the confItemIdAssetMap
     * @param mapIdMapNameConfItemAtt the mapIdMapNameConfItemAtt
     * @return invoiceDescription the String
     */
    public static String populateInvoiceDescription(String confItemId, Map<String, Asset> confItemIdAssetMap, Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt) {

        String invoiceDescription;
        Set<String> b2bgSet = new Set<String>{'B2B','B2G'};
		//[START R2 16.03.2022 CR771 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
        if(confItemIdAssetMap.get(confItemId)!= null && b2bgSet.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c) && 'eCity'.equalsIgnoreCase(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c) && 'Italy'.equalsIgnoreCase(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Country__c)){
            if(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__c != null && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_InvoiceDescription__c != null){
               invoiceDescription = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_InvoiceDescription__c;
            }else if(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_InvoiceDescription__c == null){
               invoiceDescription = createInvoiceDescription2(mapIdMapNameConfItemAtt.get(confItemId), confItemIdAssetMap.get(confItemId));	
            }																				 
        //if(confItemIdAssetMap.get(confItemId)!= null && b2bgSet.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c)) {
		} else if(confItemIdAssetMap.get(confItemId)!= null && b2bgSet.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c)) {
        //[END R2 16.03.2022 CR771 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]  																																									
            invoiceDescription = createInvoiceDescription(mapIdMapNameConfItemAtt.get(confItemId), confItemIdAssetMap.get(confItemId));
        } else if(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Product_Type__c == Label.XC_CL_OrderItem_ProductType && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Product_Subtype__c == Label.XC_CL_OrderItemSubtype_Coupon) {
            invoiceDescription = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_TranslatedProductName__c + ' ' + mapIdMapNameConfItemAtt.get(confItemId).get(Label.XC_CL_OIA_DeveloperName_MaxKwh).NE__Value__c + ' Kwh';
        } else if(confItemIdAssetMap.get(confItemId).XC_Product_Name_LIC__c == Label.XC_CL_Asset_Penalty) {
            invoiceDescription = confItemIdAssetMap.get(confItemId).NE__Parent_Order_Item__r.Name;
        } else {
            invoiceDescription = (mapIdMapNameConfItemAtt.get(confItemId) != null && !mapIdMapNameConfItemAtt.get(confItemId).isEmpty()) ? createInvoiceDescription(mapIdMapNameConfItemAtt.get(confItemId), confItemIdAssetMap.get(confItemId)) : confItemIdAssetMap.get(confItemId).Name;
        }
		
        return invoiceDescription;
    }

	private static String createInvoiceDescription(Map<String,NE__Order_Item_Attribute__c> attributes, Asset assetObj){
        String retStr = assetObj != null ? assetObj.XC_Configuration_Item__r.XC_TranslatedProductName__c : null;
        if(attributes!=null){
            for(NE__Order_Item_Attribute__c attr : attributes.values()){
    
                if(assetObj!=null && attr.NE__FamPropId__r.XC_ShowInInvoice__c != null && attr.NE__FamPropId__r.XC_ShowInInvoice__c.contains(assetObj.NE__Order_Config__r.XC_Country__c)){
                    retStr = retStr == null ? attr.Name+':'+attr.NE__Value__c : attr.NE__Value__c != null ? retStr+' '+attr.Name+':'+attr.NE__Value__c : retStr;
                }
            }
        }
        return retStr;
    }

    //START[R2 18.02.2022 CR771 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
    private static String createInvoiceDescription2(Map<String,NE__Order_Item_Attribute__c> attributes, Asset assetObj){
        String retStr2 = assetObj != null ? assetObj.XC_Configuration_Item__r.XC_TranslatedProductName__c + '|' : null;
        String potenza, codice, tipologia, resto;
        if(attributes!=null){
            for(NE__Order_Item_Attribute__c attr : attributes.values()){
                if(assetObj!=null && attr.NE__FamPropId__r.XC_ShowInInvoice__c != null && attr.NE__FamPropId__r.XC_ShowInInvoice__c.contains(assetObj.NE__Order_Config__r.XC_Country__c)){
                    if('Code'.equalsIgnoreCase(attr.XC_DeveloperName__c)){ codice = attr.NE__Value__c;
                    }else if('Lighting Power'.equalsIgnoreCase(attr.XC_DeveloperName__c)){ potenza = attr.NE__Value__c;
                    }else if('Lighting Tipology'.equalsIgnoreCase(attr.XC_DeveloperName__c)){ tipologia = attr.NE__Value__c;
                    }else{ resto = resto == null ? (String.isNotBlank(attr.NE__Value__c) ? attr.NE__Value__c + ' - ' : '') : resto + (String.isNotBlank(attr.NE__Value__c) ? attr.NE__Value__c + ' - ' : '');
                    }
                //retStr2 = retStr2 == null ? '|'+attr.NE__Value__c +' - ' : attr.NE__Value__c != null ? retStr2 + attr.NE__Value__c + ' - ' : retStr2;
                }
            }
        }
        
        retStr2 = (String.isNotBlank(retStr2) ? retStr2 : '|') + (String.isNotBlank(codice) ? codice  + ' - ' : '') + (String.isNotBlank(tipologia) ? tipologia + ' - ' : '') + (String.isNotBlank(potenza) ? potenza + 'W - ' : '') + (String.isNotBlank(resto) ? resto : ''); 
        system.debug('retStr2 partial ' + retStr2);
        retStr2 = retStr2!= null && retStr2.endsWith('|') ? retStr2.substring(0, retStr2.length()-1) : retStr2!= null && retStr2.endsWith(' - ') ? retStr2.substring(0, retStr2.length()-3) : retStr2;
        system.debug('retStr2 final ' + retStr2);
        return retStr2;
    }
    //END[R2 18.02.2022 CR771 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
}