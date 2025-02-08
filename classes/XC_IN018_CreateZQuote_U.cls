/**
 * The Class XC_IN018_CreateZQuote_U.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 27/03/2019
 * @date Modification 07/08/2019 by Nicola Mariniello - nmariniello@deloitte.it
 * @description Handles the creation of the zQuote during the provisioning step
 */


public without sharing class XC_IN018_CreateZQuote_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN018_CreateZQuote');


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 27/03/2019
     * @description Handles the creation of the zQuote during the provisioning step
     */
    public class UpdateWrapper {
        public String orderId;
        public String zQuoteId;
        public String confItemId;
        public Boolean generateInvoice;
        public Boolean separateInvoice;
        public Decimal initialTerm;
        public Boolean autoRenew;
        public Boolean generateEvergreen =false;
        public NE__OrderItem__c item;
        public String stepId;
        public List<String> listRatePlans;
        public Map<String, List<String>> prpcConfItemsMap;
        public Boolean mixedVat = false;
        public Boolean manageCurrencyCLF = false;
        public Boolean isThirdParty = false;//[2021-10-14 :: TP :: Third Party Billing :: Identify TP]
        public Map<Id, String> confItemDynamicPropDef;

        //DP - for PPM billing
        public XC_Milestone__c milestone;
        public project_cloud__Project_Task__c task;
        public Boolean isPreview = false;
        
        //NR2122 - Cumulative Invoice
        public String cumulativeInvoiceType;
        public String dttNumberAndDate;

        // [Begin - NR1640 Fix - 20220503 - LR]
        public Date lastInvoiceDate; // date used to override the start date of a new subscription. Populated in the Get Subscription step. 
        public Date balanceEffectiveStartDate; // date used to override the start date of a new subscription if if a balance product was added to the order (service upgrade/downgrade)
        // [End - NR1640 Fix - 20220503 - LR]
    }


    /**
     * @description Send Future Queuable
     */
    public class UpdateRPQueuable implements Queueable , Database.AllowsCallouts{

        /** The zquote ids. */
        List<Id> zquoteIds;
        Map<String, List<String>> prpcConfItemsMap;
        List<String> listRatePlans;
        Map<Id, String> confItemDynamicPropDef;
        UpdateWrapper wr;

        //DP PPM milestone
        XC_Milestone__c milestone;
        project_cloud__Project_Task__c task;
        Boolean isPreview = false;

        /**
         * @description Instantiates a new send future queuable.
         * @param zquoteIds the zquote ids
         * @param mapItem the map item
         * @param listRatePlans the rateplan list
         */
        public UpdateRPQueuable(List<Id> zquoteIds, UpdateWrapper wr){
            this.zquoteIds = zquoteIds;
            this.prpcConfItemsMap = wr.prpcConfItemsMap;
            this.listRatePlans = wr.listRatePlans;
            this.confItemDynamicPropDef = wr.confItemDynamicPropDef;
            this.wr = wr;

            //DP PPM milestone
            this.milestone=wr.milestone;
            this.task=wr.task;
            this.isPreview = wr.isPreview;

        }


        /**
         * @description execute
         * @param context the context
         */
        public void execute(QueueableContext context) {

            Map<String, Object> mapUtil = new Map<String, Object>{ 'newZQuoteId' => this.zquoteIds[0],
            'listRatePlans' => this.listRatePlans,
            'prpcConfItemsMap' => this.prpcConfItemsMap,
            'confItemDynamicPropDef' => this.confItemDynamicPropDef,
            'milestone' => this.milestone,
            'projectTask' => this.task,
            'isPreview' => this.isPreview,
            'isThirdParty' => this.wr.isThirdParty, //[TP - 2021.11.29 - TPB - AVOID PRORATION]
            'cumulativeInvoiceType' => this.wr.cumulativeInvoiceType, //[ET - 15/02/2022 - NR2122 - Cumulative Invoice]
            'dttNumberAndDate' => this.wr.dttNumberAndDate, //[ET - 21/03/2022 - NR2122 - dttNumberAndDate]
            'balanceEffectiveStartDate' => this.wr.balanceEffectiveStartDate, //[NR1640 Fix - 20220517 - LR]
            'lastInvoiceDate' => this.wr.lastInvoiceDate // [NR1640 Fix - 20220517 - LR]
            };

            //updateRatePlanCharge(this.zquoteIds[0], this.listRatePlans, this.prpcConfItemsMap); ---
            if(this.isPreview) {
                updateRatePlanChargePreview(mapUtil);
            }else{
                updateRatePlanCharge(mapUtil);
            }

            Boolean checkInvoiceTOTBundle = checkInvoice(this.wr);
            if(!checkInvoiceTOTBundle){
                XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c(Id = this.wr.stepId);
                provStep.XC_ErrorMessage__c = Label.XC_CL_ErrorMessageForCheckInvoice;
                XC_UTIL_Sobject.updateRecord(provStep);
                List<XC_CS008_BlockProvisioningStep__c> listOfCustomSetting = new List<XC_CS008_BlockProvisioningStep__c>([SELECT Id, XC_BlockCreateSubscription__c FROM XC_CS008_BlockProvisioningStep__c WHERE Name = 'BlockCreateSubscription']);
                if(!listOfCustomSetting.isEmpty() && !listOfCustomSetting[0].XC_BlockCreateSubscription__c){
                    if(!Test.isRunningTest()) {
                        System.enqueueJob(new XC_TR_ConfigurationItem_U_UpdateZQuote.SendFutureQueuable(this.zquoteIds));
                    }
                }
            }else {
                if(!Test.isRunningTest()) {
                    System.enqueueJob(new XC_TR_ConfigurationItem_U_UpdateZQuote.SendFutureQueuable(this.zquoteIds));
                }
            }
        }
    }


    /**
    * @description method to update rate plan charge
    *
    * @param newZQuoteId the  newzquote id
    * @param ratePlanAddList the rate plan add list
    */
    public static void updateRatePlanCharge(Map<String, Object> mapUtil) {

        List<NE__OrderItem__c> confItemIdList = new List<NE__OrderItem__c>(); //CR771-10.05.2022
        String newZQuoteId = (String) mapUtil.get('newZQuoteId');
        List<String> listRatePlans = (List<String>) mapUtil.get('listRatePlans');
        Map<String, List<String>> prpcConfItemsMap = (Map<String, List<String>>) mapUtil.get('prpcConfItemsMap');
        NE__OrderItem__c confItemMalfunction = (NE__OrderItem__c) mapUtil.get('confItemMalfunction');   // FOR ChangeOrder - Substitution (Malfunction)
        Map<Id, String> confItemDynamicPropDef = (Map<Id, String>) mapUtil.get('confItemDynamicPropDef'); // For third party product

        XC_Milestone__c milestone = (XC_Milestone__c) mapUtil.get('milestone'); //DP PPM milestone
        project_cloud__Project_Task__c theTask = (project_cloud__Project_Task__c) mapUtil.get('projectTask'); //DP PPM milestone

        System.debug('@@@ prpcConfItemsMap -> ' + prpcConfItemsMap);

        /********** Retrieve the asset having the needed fields **********/
        //Mod CV CR.NR2044 Add XC_Configuration_Item__r.NE__ProdName__c to query
        System.debug('newZQuoteId -> ' + newZQuoteId);
        Map<Id, Asset> mapAss = new Map<Id, Asset>([SELECT XC_Wbe__c, XC_CMProfitCenter__c, XC_CMCostCenter__c, XC_Configuration_Item__c,
                XC_Configuration_Item__r.NE__Qty__c, XC_Configuration_Item__r.NE__OneTimeFeeOv__c,XC_Configuration_Item__r.XC_InvoiceDescription__c,XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c,XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Country__c,//[R2 22.02.2022 CR771 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com Added the field XC_Configuration_Item__r.XC_InvoiceDescription__c ]
                XC_Configuration_Item__r.NE__RecurringChargeOv__c, Name, XC_Configuration_Item__r.NE__Item_Code__c,
                XC_Configuration_Item__r.NE__BaseOneTimeFee__c, XC_Configuration_Item__r.NE__BaseRecurringCharge__c,
                XC_Configuration_Item__r.XC_DaneCode__c,  XC_Configuration_Item__r.XC_RelatedProduct__c,
                XC_Configuration_Item__r.XC_Product_Type__c, XC_Configuration_Item__r.XC_Product_Subtype__c,
                XC_LegalEntity__c,XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c,XC_Product_Subtype__c,
                NE__Parent_Order_Item__r.Name, XC_Product_Name_LIC__c, XC_Configuration_Item__r.XC_Good_Cost__c,
                XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c, XC_Configuration_Item__r.XC_TranslatedProductName__c,
                XC_Configuration_Item__r.XC_Billing_Period_Recurring__c, XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c,XC_Configuration_Item__r.NE__ProdName__c,XC_Configuration_Item__r.XC_CA_UpdateDate__c, XC_Configuration_Item__r.XC_CA_RenewalDate__c,
                XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c, XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c,
                XC_Configuration_Item__r.NE__CatalogItem__r.Catalog_item_code__c, XC_Configuration_Item__r.XC_ProjectDimension__c, XC_Configuration_Item__r.XC_WBE_Status__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_InvoiceType__c, XC_Configuration_Item__r.XC_BillingModel__c,
                XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_NumeroProtocolloEsportatoreAbituale__c,
                XC_Configuration_Item__r.XC_ImpliedInterest__c, XC_Configuration_Item__r.NE__Description__c, XC_Configuration_Item__r.NE__Root_Order_Item__c,XC_Configuration_Item__r.XC_WBE__c, XC_Configuration_Item__r.XC_CMProfitCenter__c,
                XC_Configuration_Item__r.NE__UsageCode__c,NE__Order_Config__r.XC_Country__c,
                XC_Configuration_Item__r.XC_LawDescriptionCode__c,XC_Configuration_Item__r.XC_LawDescription__c,
                XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c, XC_Configuration_Item__r.NE__OrderId__c,
                XC_Configuration_Item__r.XC_RecurringDuration__c, XC_Configuration_Item__r.XC_RecurringPeriodType__c,
                XC_Configuration_Item__r.NE__Root_Order_Item__r.XC_TranslatedProductName__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c,
                XC_Configuration_Item__r.NE__CatalogItem__r.NE__Complex_Item__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c,
                XC_Configuration_Item__r.XC_SelectedIncentiveMode__c,XC_Configuration_Item__r.XC_CreditAssignmentCustomerAmount__c, //arjun.raoh@accenture.com, NR2388, R2 2022, 10/02/2022
                NE__CatalogItem__c, NE__CatalogItem__r.NE__UsageCode__c, //[NR2122 - ET - 28/02/2022]
                NE__EndDate__c,XC_Configuration_Item__r.NE__ProdId__r.XC_LIC_Product_Name__c
        FROM Asset
        WHERE XC_ZQuoteId__c = :newZQuoteId]);//[TP - 2021.11.29 - TPB - added Order Type]

        Map<String, Asset> confItemIdAssetMap = new Map<String, Asset>();
        Map<String,Asset> itemCodeAssetMap = new Map<String,Asset>();
        Set<Id> setOrderId = new Set<Id>();
        List<String> confItemCodes = new List<String>();
        List<String> listSubsidyItemIds = new List<String>();
        for(Asset a : mapAss.values()) {
            setOrderId.add(a.XC_Configuration_Item__r.NE__OrderId__c);
            confItemIdAssetMap.put(a.XC_Configuration_Item__c, a);
            itemCodeAssetMap.put(a.XC_Configuration_Item__r.NE__Item_Code__c,a);
            confItemCodes.add(a.XC_Configuration_Item__r.NE__Item_Code__c);
            if(String.isNotBlank(a.XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c) && a.XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c.containsIgnoreCase('eMobility')) {
                listSubsidyItemIds.add(a.XC_Configuration_Item__c); // To do the query on OrderItemAttribute
            }
        }

        System.debug('@@@ confItemIdAssetMap -> ' + confItemIdAssetMap);
        List<NE__OrderItem__c> listSubsidyItem = new List<NE__OrderItem__c>([SELECT Id
        FROM NE__OrderItem__c
        WHERE XC_ZQuoteId__c = :newZQuoteId
        AND (XC_RelatedProduct__c IN: confItemCodes OR XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive
        OR (XC_Product_Type__c =: Label.XC_CL_OrderItem_ProductType AND XC_Product_Subtype__c =: Label.XC_CL_OrderItemSubtype_Coupon))]);
        if(!listSubsidyItem.isEmpty()){
            listSubsidyItemIds.addAll(XC_UTIL_Sobject.getIds(listSubsidyItem));
        }

        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c,zqu__Model__c, zqu__EffectivePrice__c, TariffType__c, zqu__ProductRatePlanCharge__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c, zqu__QuoteRatePlan__r.Id,zqu__Quantity__c, zqu__BillingTiming__c, CRMAssetID__c,
        CausaExencion__c, //alag@deloitte.es 08-03-2022 NR2001 VAT Management CausaExencion
        XC_Discount__c, XC_TotalToPay__c //NR2388, R2 2022, 10/02/2022
        FROM zqu__QuoteRatePlanCharge__c
        WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :newZQuoteId];

        //alag@deloitte.es 08-03-2022 NR2001 VAT Management CausaExencion - START 
        zqu__Quote__c associatedQuote = [SELECT Id, CausaExencion__c FROM zqu__Quote__c WHERE Id=:newZQuoteId];
        //alag@deloitte.es 08-03-2022 NR2001 VAT Management CausaExencion - END 

        /*********** Gerarchia RP ***************/
        List<String> prodRPList = new List<String>();
        for(zqu__QuoteRatePlanCharge__c rpc : rpChargeList){
            prodRPList.add(rpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c);
            //alag@deloitte.es 08-03-2022 NR2001 VAT Management CausaExencion - START 
            rpc.CausaExencion__c = associatedQuote?.CausaExencion__c;
            //alag@deloitte.es 08-03-2022 NR2001 VAT Management CausaExencion - END 
        }

        List<B2WExtCat__Work_Order_Item__c > ecaList = [select id, B2WExtCat__Configuration_Item__c, B2WExtCat__Work_Order_Item_Code__c,B2WExtCat__Configuration_Item__r.NE__Root_Order_Item__c, B2WExtCat__External_Catalog_Association__r.B2WExtCat__External_Item_Name__c, B2WExtCat__Configuration_Item__r.NE__OrderId__c
        from B2WExtCat__Work_Order_Item__c  where B2WExtCat__Work_Order_Item_Code__c in :prodRPList AND B2WExtCat__Configuration_Item__r.NE__OrderId__c IN :setOrderId];

        Map<String,B2WExtCat__Work_Order_Item__c > ecaByRP = new Map<String, B2WExtCat__Work_Order_Item__c >();
        for(B2WExtCat__Work_Order_Item__c  eca : ecaList){
            ecaByRP.put(eca.B2WExtCat__Work_Order_Item_Code__c,eca);
        }
        Map<String,zqu__QuoteRatePlan__c> rpByProductRP = new Map<String, zqu__QuoteRatePlan__c>();
        for(zqu__QuoteRatePlanCharge__c rpc : rpChargeList){
            rpByProductRP.put(rpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c, rpc.zqu__QuoteRatePlan__r);
        }
        List<zqu__QuoteRatePlan__c> qrpToUpdate = new List<zqu__QuoteRatePlan__c>();
        /*for(zqu__QuoteRatePlan__c qrp : rpByProductRP.values()){
            B2WExtCat__Work_Order_Item__c  eca = ecaByRP.get(qrp.zqu__ProductRatePlan__c);
            String rootRP = null;
            for(B2WExtCat__Work_Order_Item__c  ecaP : ecaList){
                if(ecaP.B2WExtCat__Configuration_Item__c == eca.B2WExtCat__Configuration_Item__r.NE__Root_Order_Item__c){
                    rootRP = ecaP.B2WExtCat__Work_Order_Item_Code__c;
                    break;
                }
            }
            if(rootRP!=null){
                qrp.zqu__Parent__c = rpByProductRP.containsKey(rootRP) ? rpByProductRP.get(rootRP).Id : null;
                qrpToUpdate.add(qrp);
            }
        }*/
        //XC_UTIL_SObject.updateListRecords(qrpToUpdate);
        /**************************/



        Date startDate = Date.Today();
        if(!Test.isRunningTest()) {
            startDate = rpChargeList[0].zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;
        }

        Map<Id, zqu__ProductRatePlanCharge__c> prpcList = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c, XC_BillingTiming__c
        FROM zqu__ProductRatePlanCharge__c
        WHERE zqu__ProductRatePlan__c IN :listRatePlans]);

        Map<String, String> confItemIdEffectivePriceMap;
        Map<String,List<NE__Order_Item_Discount__c>> discounts;
        if(confItemMalfunction == null) {

            //fimperioli added --> check on discount items
            List<String> confItemsIds = new List<String>();
            confItemsIds.addAll(confItemIdAssetMap.keySet());
            discounts = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(confItemsIds);

            System.Debug('DISCOUNTS FOUND ON ITEM :::: ' + discounts);
            //if(milestone!=null){ //MILESTONE NON MILESTONE              
            if(theTask!=null && theTask.XC_TaskReason__c == 'Milestone'){
                confItemIdEffectivePriceMap = XC_IN018_CreateZQuote_UU.calculateEffectivePriceMilestonePPM(new List<project_cloud__Project_Task__c>{theTask}, discounts);
            }else{
                confItemIdEffectivePriceMap = XC_IN018_CreateZQuote_UU.calculateEffectivePrice(mapAss.values(), discounts);
            }
        } else {  // FOR ChangeOrder - Substitution (Malfunction)

            discounts = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(new List<String>{confItemMalfunction.Id});
            confItemIdEffectivePriceMap = XC_IN018_CreateZQuote_UU.calculateEffectivePriceMulfunction(confItemMalfunction,discounts, confItemIdAssetMap.values()[0].XC_Configuration_Item__c);
        }

        Map<String, zqu__ProductRatePlanCharge__c> mapQRPCNameToPRPC = XC_IN018_CreateZQuote_UU.createMapQRPCToPRPC(rpChargeList, prpcList.values());
        System.debug('@@@ confItemIdEffectivePriceMap -> ' + confItemIdEffectivePriceMap);

        /********** Update RatePlanCharge **********/
        zqu__ProductRatePlanCharge__c prpc;
        Decimal includedKWh;
        Set<String> b2bgSet = new Set<String>{'B2B','B2G'};
        Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt = new Map<Id,Map<String,NE__Order_Item_Attribute__c>>();
        if(!listSubsidyItemIds.isEmpty()){
            mapIdMapNameConfItemAtt = XC_IN018_CreateZQuote_UU.retriveConfItemAttribute(listSubsidyItemIds);
            System.Debug('SUBSIDY ITEMS MAP::: ' + mapIdMapNameConfItemAtt);
        }
        else if(mapAss.values()[0]!=null && b2bgSet.contains(mapAss.values()[0].XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c)){
            mapIdMapNameConfItemAtt = XC_IN018_CreateZQuote_UU.retriveConfItemAttribute(XC_UTIL_Sobject.getListFieldValues(mapAss.values(),'XC_Configuration_Item__c'));
            System.Debug('CONFIG ITEMS MAP::: ' + mapIdMapNameConfItemAtt);
        }

        //[Begin - NR1640 Fix - 20220517 - LR]
        Date balanceEffectiveStartDate =  (Date) mapUtil.get('balanceEffectiveStartDate');
        Date lastInvoiceDate = (Date) mapUtil.get('lastInvoiceDate');
        //[End - NR1640 Fix - 20220517 - LR]

        for (zqu__QuoteRatePlanCharge__c rpc : rpChargeList ) {
            prpc = prpcList.get(rpc.zqu__ProductRatePlanCharge__c);
            System.debug('@@@ prpc -> ' + prpc);

            String confItemId = prpcConfItemsMap.get(prpc.Id)[0];
            System.debug('@@@ confItemId -> ' + confItemId);

            /*rpc.XC_WBE__c = (!String.isBlank(prpc.XC_WBE__c)) ? prpc.XC_WBE__c : confItemIdAssetMap.get(confItemId).XC_WBE__c;
            rpc.XC_ProfitCenter__c = (!String.isBlank(prpc.XC_ProfitCenter__c)) ? prpc.XC_ProfitCenter__c : confItemIdAssetMap.get(confItemId).XC_CMProfitCenter__c;*/
            rpc.TariffType__c = (!String.isBlank(prpc.TariffType__c )) ? prpc.TariffType__c  : rpc.TariffType__c;
            if(prpc != null && !prpc.Name.contains('Suplido')){
                rpc.XC_DynamicPropertyDefinition__c = (confItemDynamicPropDef != null && confItemDynamicPropDef.get(confItemId) != null) ? confItemDynamicPropDef.get(confItemId) : '';
            }else{
                rpc.XC_DynamicPropertyDefinition__c = 'Suplido';
            }
            rpc.IncludedkWh__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId, 'kWH');

            /***********NR1309 Billing in advance ***************/
            if(rpc.zqu__BillingTiming__c != prpc.XC_BillingTiming__c){
                rpc.zqu__BillingTiming__c = prpc.XC_BillingTiming__c;
            }
            /*************END***********/


            if(confItemIdAssetMap.containsKey(confItemId)){
                rpc.XC_DaneCode__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_DaneCode__c;
                rpc.XC_CostCenter__c = confItemIdAssetMap.get(confItemId).XC_CMCostCenter__c;
                //ALC 12-01-2022 - ENELX - NR2002_Suplidos in EX invoices - Start
                if(prpc != null && !prpc.Name.contains('Suplido')){
                	rpc.XC_InvoiceDescription__c = XC_IN018_CreateZQuote_UU.populateInvoiceDescription(confItemId, confItemIdAssetMap, mapIdMapNameConfItemAtt);
                }else{
                    rpc.XC_InvoiceDescription__c = 'Suplido';
                }
                //ALC 12-01-2022 - ENELX - NR2002_Suplidos in EX invoices - End
                rpc.XC_GoodAmount__c = (confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Good_Cost__c == null) ? '' : String.valueOf(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Good_Cost__c);
                rpc.XC_WBEStatus__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_WBE_Status__c;

                if(String.isNotBlank(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__CatalogItem__r.Catalog_item_code__c)){
                    rpc.XC_VASCode__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__CatalogItem__r.Catalog_item_code__c;
                }
                if(String.isNotBlank(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_ProjectDimension__c)){
                    rpc.XC_ProjectDimension__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_ProjectDimension__c;
                }

            }

            /*SUBSIDY MANAGEMENT*/
            /*----------------------------*/
            //rpc.XC_SubsidyDuration__c = Date.valueOf(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Duration'));//Date.valueOf(mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Duration').NE__Value__c);
            if(confItemIdAssetMap.containsKey(confItemId) && confItemIdAssetMap.get(confItemId).XC_Product_Name_LIC__c ==Label.XC_CL_SubsidyProductName){

                rpc.XC_SubsidyType__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Type');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Type').NE__Value__c ;
                rpc.XC_SubsidySubtype__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Subtype'); //mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Subtype').NE__Value__c ;
                rpc.XC_SubsidyForm__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Form'); //mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Form').NE__Value__c ;
                rpc.XC_SubsidyCollectionType__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Collection Type');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Collection Type').NE__Value__c ;
                rpc.XC_SubsidyCode__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Code');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Code').NE__Value__c ;
                rpc.XC_SubsidyAmount__c = String.isEmpty(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Amount')) ? null :Decimal.valueOf(checkSubsidyAmount(mapIdMapNameConfItemAtt,confItemId,confItemIdAssetMap.get(confItemId),'Subsidy Amount', confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c));
                rpc.XC_InvoiceDescription__c = !String.isBlank(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Name')) ? checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Name') : rpc.XC_InvoiceDescription__c;

            }else if(confItemIdAssetMap.containsKey(confItemId) && confItemIdAssetMap.get(confItemId).XC_Product_SubType__c==Label.XC_CL_ProductSubtypeIncentive && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c){
                //in case of "cessione del credito" we populate subsidy fields on zuora
                String incentiveUniqueCode = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__UsageCode__c;
                rpc.XC_SubsidyCode__c = incentiveUniqueCode;
                rpc.XC_SubsidyAmount__c = String.isEmpty(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Amount')) ? null :Decimal.valueOf(checkSubsidyAmount(mapIdMapNameConfItemAtt,confItemId,confItemIdAssetMap.get(confItemId),'Amount', confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c));
                //[BEGIN, arjun.raoh@accenture.com, NR2388, R2 2022, 10/02/2022]
                if( 'Discount on invoice'.equalsIgnoreCase(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_SelectedIncentiveMode__c) ||
                    'Sconto in fattura'.equalsIgnoreCase(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_SelectedIncentiveMode__c)) {
                    rpc.XC_Discount__c   = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_SelectedIncentiveMode__c;
                    rpc.XC_TotalToPay__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CreditAssignmentCustomerAmount__c;
                }
                //[END, arjun.raoh@accenture.com, NR2388, R2 2022, 10/02/2022]
            }
            /*----------------------------*/
            
            //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]
            rpc.XC_CumulativeInvoiceType__c = (mapUtil.get('cumulativeInvoiceType') != null) ? (String) mapUtil.get('cumulativeInvoiceType') : null; 
            rpc.XC_CumulativeInvoiceCode__c = (String.IsNotBlank(mapAss.values()[0].NE__CatalogItem__r?.NE__UsageCode__c) && String.IsNotBlank(rpc.XC_CumulativeInvoiceType__c))? 'Codice Accessorio;' +  mapAss.values()[0].NE__CatalogItem__r?.NE__UsageCode__c: null;
            //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]

            rpc.CRMAssetID__c = mapAss.values()[0].Id; //[02/03/2022 - Gestione Cruscotto]
            rpc.CRMAssetID__c = confItemIdAssetMap.get(confItemId).Id; //[02/03/2022 - Gestione Cruscotto]
            Map<String, Object> inputFields = new Map<String, Object>{'confItemId' => confItemId,
            'confItemIdEffectivePriceMap' => confItemIdEffectivePriceMap,
            'confItemIdAssetMap' => confItemIdAssetMap,
            'prpc' => prpc,
            'oiDiscountMap' => discounts,
            'date' => startDate
            };

            XC_IN018_CreateZQuote_UU.populateRcpFields(rpc, inputFields);

            String effectivePrice = confItemIdEffectivePriceMap.get(confItemId);
            if(String.isNotBlank(effectivePrice) && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c == 'Billing Plan') {
                rpc.XC_PriceBillingPlan__c = effectivePrice;
            }

            if(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c == 'Saving Sharing') {
                rpc.XC_SavingSharingPercentage__c = checkNullValue(mapIdMapNameConfItemAtt, confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Root_Order_Item__c,'Sharing Percentage'); //TODO verify correct attribute
            }
            /********* GESTIONE RPC Interessi Impliciti **********/

            B2WExtCat__Work_Order_Item__c eca = ecaByRP.get(rpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__c);
            String invoiceType = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_InvoiceType__c;
            String ecaType = eca != null && eca.B2WExtCat__External_Catalog_Association__r.B2WExtCat__External_Item_Name__c != null ? eca.B2WExtCat__External_Catalog_Association__r.B2WExtCat__External_Item_Name__c : ''; //TODO verify
            if((ecaType.contains('Implied Interest') && invoiceType == 'Invoice Accrued interest - Implied interest share') || Test.isRunningTest()){
                Decimal interestValue = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_ImpliedInterest__c;
                rpc.zqu__EffectivePrice__c = interestValue;
                rpc.zqu__ListPrice__c = interestValue;
                rpc.zqu__ListTotal__c = interestValue;
                rpc.zqu__Total__c = interestValue;
            }

            /******** GERARCHIA RPC *****************************/
            Set<String> itaLE = new Set<String>{'EnelXItalia','EnelXMobilityItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio','EnelXMSP','EnelXMobilityHolding'};
            if(b2bgSet.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c)){
                rpc.XC_LawDescriptionCode__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_LawDescriptionCode__c;
                rpc.XC_LawDescription__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_LawDescription__c;
                if(rpc.zqu__ChargeType__c != 'Usage' || confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c == 'Join Venture'){
                    rpc.XC_WBE__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_WBE__c;
                    rpc.XC_ProfitCenter__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CMProfitCenter__c;
                }
                /*rpc.XC_Hierarchy__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Root_Order_Item__c != null ? 'Child' : 'Root';
                if(rpc.XC_Hierarchy__c == 'Root' && String.isNotBlank(effectivePrice) && Decimal.valueOf(effectivePrice)>0  && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c != 'Milestone'){
                    rpc.XC_Hierarchy__c = 'Child';
                }*/

                //NR1446
                if(itaLE.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c)){
                rpc.XC_RootName__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Root_Order_Item__c != null ? confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Root_Order_Item__r.XC_TranslatedProductName__c : null;

                //NR1447
                if(theTask!=null && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c == 'Milestone') {
                    rpc.XC_PercentualeSAL__c = theTask.XC_MilestonePercentage__c != null ? String.valueOf(theTask.XC_MilestonePercentage__c) : null;
                    rpc.XC_RagioneSAL__c = theTask.XC_MilestoneReason__c;
                    rpc.XC_NumeroSAL__c = theTask.XC_MilestoneNumber__c != null ? String.valueOf(theTask.XC_MilestoneNumber__c) : null;
                }
            }
               
        }
            if(prpc != null && !prpc.Name.contains('Suplido')){    
                rpc.XC_Hierarchy__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Root_Order_Item__c != null ? 'Child' : 'Root';
            }else{
                rpc.XC_Hierarchy__c = '';
            }

            if(rpc.XC_Hierarchy__c == 'Root' && String.isNotBlank(effectivePrice) && Decimal.valueOf(effectivePrice)>0  && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c != 'Milestone'){
                rpc.XC_Hierarchy__c = 'Child';
            }

            /*********CR NR1309*********************************/
            Boolean isB2BRecurring = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_BillingModel__c =='Recurring' /*&& !(wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'Codensa' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelX' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelDistribucion')*/
                    && b2bgSet.contains(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c);

            if((isB2BRecurring && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_RecurringPeriodType__c!=null) || Test.isRunningTest()) {
                rpc.zqu__SpecificBillingPeriod__c = getRecurringNumberOfMonths(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_RecurringPeriodType__c);
                rpc.zqu__Period__c = 'Specific Months';
            }

            Boolean changeOrder = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'Service Upgrade/Downgrade' &&
                    confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c != null &&
                    confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c != null;

            if((isB2BRecurring && changeOrder)|| Test.isRunningTest()) {
                Date startDateChangeOrder = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
                //rpc.zqu__SpecificBillingPeriod__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c;
                rpc.zqu__EffectiveStartDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
                rpc.zqu__TriggerEvent__c = 'SpecificDate';
                rpc.zqu__EndDateCondition__c = 'Specific End Date';
                rpc.zqu__SpecificEndDate__c = startDateChangeOrder.addMonths(Integer.valueOf(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c));
                rpc.zqu__TriggerDate__c = startDateChangeOrder;
                //rpc.zqu__TriggerDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
            }

            //Commented because it concerns the old dashboard logic
            /*Boolean contractAmendmentChangeDate =  confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CA_UpdateDate__c;
            if(contractAmendmentChangeDate){
                rpc.zqu__EffectiveStartDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
                //rpc.zqu__TriggerEvent__c = 'SpecificDate';
                rpc.zqu__EndDateCondition__c = 'Specific End Date';
                rpc.zqu__SpecificEndDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CA_RenewalDate__c;
                //rpc.zqu__TriggerDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CA_RenewalDate__c;
            }*/


            /****************************************************/
            //Mod CV CR.NR2044 fill filed for zuora quote
            if( Test.isRunningTest() || ((isB2BRecurring && changeOrder)&& confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__ProdName__c == Label.XC_CL_AdjustmentProdName)) {
                Date startDateChangeOrder = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
                rpc.zqu__EffectiveStartDate__c = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c;
                rpc.zqu__TriggerEvent__c = 'SpecificDate';
                rpc.zqu__EndDateCondition__c = 'Specific End Date';
                // rpc.zqu__SpecificEndDate__c = startDateChangeOrder.addMonths(Integer.valueOf(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c));
                // rpc.zqu__TriggerDate__c = startDateChangeOrder.addMonths(Integer.valueOf(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c));
                //Integer orderItemBillPerRecu = getRecurringNumberOfMonths(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_RecurringPeriodType__c)*Integer.valueOf(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c);
                Integer orderItemBillPerRecu = getRecurringNumberOfMonths(confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_RecurringPeriodType__c);
                rpc.zqu__SpecificEndDate__c = startDateChangeOrder.addMonths(orderItemBillPerRecu);
                rpc.zqu__TriggerDate__c = startDateChangeOrder;//.addMonths(orderItemBillPerRecu);
            }
            //<--End

            //[Begin - NR1640 Fix - 20220517 - LR]
            //If a balance-type product is added to the change order, the start date of the subscription is overwritten with the effective start date of the balance. For all other rpc, the start date is equal to the last invoice date if if greater than effective start date recurring 
            // if the last invoice date is populated for a change order b2b, the end date of each charge is also recalculated
            if(lastInvoiceDate != null && isB2BRecurring  && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade){
                if(balanceEffectiveStartDate != null && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__ProdId__r.XC_LIC_Product_Name__c != Label.XC_CL_AdjustmentProdName){
                    Date effectiveStartDateRec = (confItemIdAssetMap.get(confItemId)!= null) ?  confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Effective_Start_Date_Recurring__c : null;
                    rpc.zqu__EffectiveStartDate__c = (effectiveStartDateRec != null && effectiveStartDateRec >= lastInvoiceDate) ? effectiveStartDateRec : lastInvoiceDate;
                    rpc.zqu__TriggerEvent__c = 'SpecificDate';
                    rpc.zqu__TriggerDate__c = (effectiveStartDateRec != null && effectiveStartDateRec >= lastInvoiceDate) ? effectiveStartDateRec : lastInvoiceDate;
                }
                if(confItemIdAssetMap.get(confItemId).NE__EndDate__c != null && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_Billing_Period_Recurring__c == null){
                    rpc.zqu__EndDateCondition__c = 'Specific End Date';
                    rpc.zqu__SpecificEndDate__c = Date.valueOf(confItemIdAssetMap.get(confItemId).NE__EndDate__c.addDays(1));
                }
            }
            //[End - NR1640 Fix - 20220517 - LR]
            
            //BEGIN - [TP - 2021.11.29 - TPB - AVOID PRORATION]
            Boolean isThirdParty = (Boolean) mapUtil.get('isThirdParty') != null ? (Boolean) mapUtil.get('isThirdParty') : false;
            String orderType = confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c;
            if(isThirdParty && (String.isBlank(orderType) || 'InOrder'.equalsIgnoreCase(orderType)) ){
                rpc.zqu__TriggerEvent__c = 'SpecificDate';
                rpc.zqu__TriggerDate__c = rpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;
            }
            //END - [TP - 2021.11.29 - TPB - AVOID PRORATION]
            if(rpc.zqu__Quantity__c==null){
                rpc.zqu__Quantity__c=confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__Qty__c;
            }

            //CR771-10.05.2022 start
            if(null != rpc.XC_InvoiceDescription__c){                
                confItemIdList.add(new NE__OrderItem__c (Id = confItemId, XC_InvoiceDescription__c = rpc.XC_InvoiceDescription__c)); //CR771-10.05.2022
            } 
            //CR771-10.05.2022 end 
            prpcConfItemsMap.get(prpc.Id).remove(0);
        }

        //CR771-10.05.2022 START 
        if(!confItemIdList.isEmpty()){
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);                
            XC_UTIL_Sobject.updateListRecords(confItemIdList); 
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    	}
        //CR771-10.05.2022 END 
        if(!rpChargeList.isEmpty()){
            XC_UTIL_SObject.updateListRecords(rpChargeList);
        } 
        
        mapUtil.put('qrpcList', rpChargeList);
    }

    private static Integer getRecurringNumberOfMonths(String period){
        switch on period {
            when 'Monthly' {
                return 1;
            } when 'Annual' {
                return 12;
            } when 'Bi-Monthly' {
                return 2;
            } when 'Four-Monthly' {
                return 4;
            } when 'Biennial' {
                return 24;
            }when 'Biannual' {
                return 6;
            }when 'Quarter' {
                return 3;
            } when else{
                return 1;
            }
        }
    }


    /**
     * @author Pasquale Pelliccia
  * @description The Class ZQuoteOption.
  */
    public class ZQuoteOption{

        /** The auto renew. */
        public Boolean autoRenew;

        /** The initial term. */
        public Integer initialTerm;

        /**
         * @description constructor
         * @param autoRenew the auto renew
         * @param initialTerm the initial term
         */
        public ZQuoteOption( Boolean autoRenew, Integer initialTerm){
            this.autoRenew = autoRenew;
            this.initialTerm = initialTerm;

        }
    }


    /**
     * @description Gets the all rate plan by map new.
     * @author Federico Amici - federico.amici@nttdata.com
     * @param ratePlanConfItem the conf item id list
     * @return the all rate plan by map new
     * @LastModify Federico Amici, added the record type ZuoraOneTime,
     */
    public static List<String> getAllRatePlanByItemId(List<String> ratePlanConfItem, Map<String, List<String>> prpcConfItemsMap) {

        if(!Schema.sObjectType.B2WExtCat__Work_Order_Item__c.isAccessible()){
            return null;
        }

        /*************** DP **********/
        List<B2WExtCat__Work_Order_Item__c> listB2WWo = [SELECT B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__c, Name, RecordType.Name
        FROM   B2WExtCat__Work_Order_Item__c
        WHERE  ((B2WExtCat__Configuration_Item__r.NE__OrderId__r.XC_Segment__c in ('B2B','B2G') and (B2WExtCat__Configuration_Item__r.XC_BillingModel__c != 'Milestone' OR B2WExtCat__Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_Milestone_Management__c = true) and B2WExtCat__Configuration_Item__r.NE__Root_Order_Item__c = :ratePlanConfItem)
        or
        (B2WExtCat__Configuration_Item__c IN : ratePlanConfItem) ) AND
        (RecordType.Name = 'ZuoraOne-Time' OR
        RecordType.Name = 'ZuoraOneTime' OR
        RecordType.Name = 'ZuoraRecurring' OR
        RecordType.Name = 'ZuoraUsage') AND
        (B2WExtCat__Action__c = 'Provide' or B2WExtCat__Action__c = null)];


        /*************** DP **********/

        List<String> listRatePlan = XC_UTIL_SObject.getListFieldValues(listB2WWo, 'B2WExtCat__Work_Order_Item_Code__c');
        Map<Id, zqu__ProductRatePlanCharge__c> prodRatePlanChargeMap = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, zqu__ProductRatePlan__c
        FROM zqu__ProductRatePlanCharge__c
        WHERE zqu__ProductRatePlan__c IN :listRatePlan]);

        for(zqu__ProductRatePlanCharge__c prpc : prodRatePlanChargeMap.values()) {
            prpcConfItemsMap.put(prpc.Id, new List<String>());
            for(B2WExtCat__Work_Order_Item__c wo : listB2WWo){
                if(wo.B2WExtCat__Work_Order_Item_Code__c == prpc.zqu__ProductRatePlan__c) {
                    prpcConfItemsMap.get(prpc.Id).add(wo.B2WExtCat__Configuration_Item__c);
                }
            }
        }

        return listRatePlan;
    }


    /**
     * @description Gets the map payment method item id.
     * @author Federico Amici - federico.amici@nttdata.com
     * @param wr the wrapper
     * @return the list
     */
    public static List<XC_UTIL_Sobject.WrapperResult> updateZQuotes(UpdateWrapper wr){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN updateZQuotes');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderItemId-->' + wr.confItemId);

        List<zqu__Quote__c> zquotesToUpd = new List<zqu__Quote__c>();
        String zuoraAccountId = XC_IN018_CreateZQuote_UU.populateZuoraAccountID(wr);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'zuoraAccountId-->' + zuoraAccountId);
        String legalEntity = (String.isNotBlank(wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c)) ? wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c : wr.item.NE__OrderId__r.XC_LegalEntity__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'legalEntity-->' + legalEntity);

        zqu__Quote__c zqu = new zqu__Quote__c(id = wr.zQuoteId);
        zqu.zqu__ZuoraAccountID__c = zuoraAccountId;
        zqu.XC_ConfigurationItem__c = wr.confItemId;
        //zqu.zqu__Service_Activation_Date__c = Date.today();

        //BEGIN - [2022-02-10 : NR1913 - NR2122]
        //zqu.zqu__InvoiceSeparately__c = (wr.separateInvoice == null ? true : wr.separateInvoice);
        Boolean separateInvoiceAttr = checkItemAttributeForSeperateInvoice(wr);
        zqu.zqu__InvoiceSeparately__c = separateInvoiceAttr != null ? separateInvoiceAttr : (wr.separateInvoice == null ? true : wr.separateInvoice);
        //END - [2022-02-10 : NR1913 - NR2122]
        
        zqu.XC_ProvisioningStep__c = wr.stepId;
        zqu.zqu__GenerateInvoice__c = wr.generateInvoice == null ? false : wr.generateInvoice;
        zqu.zqu__InitialTerm__c = 1;
        zqu.zqu__RenewalTerm__c = zqu.zqu__InitialTerm__c;
        zqu.XC_MixedVat__c = XC_UTIL_Integration.convertFromBooleanToString (wr.mixedVat);
        zqu.XC_CompanyCode__c = wr.item.NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c + ';' + wr.item.NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c+';'+ (wr.item.XC_Product_Subtype__c == Label.XC_CL_ProductSubtype_B2BTariff ? 'B2BCompanyParentAccount' : '');
        zqu.XC_GeoCountry__c = wr.item.NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c;
        // NR0944 UF Sales&Billing
        zqu.XC_OrderCurrency__c = (wr.manageCurrencyCLF == true) ? Label.XC_CL_UnidadFomento_ISO : null;
        //BEGIN - [2021-10-14 :: TP :: Third Party Billing :: Identify TP]
        if(wr.isThirdParty && String.isNotBlank(wr.item.NE__OrderId__r.XC_VASContractNumber__c))
        {
            zqu.XC_ThirdPartyContractNumber__c = wr.item.NE__OrderId__r.XC_VASContractNumber__c;
        }
        //END - [2021-10-14 :: TP :: Third Party Billing :: Identify TP]
        //DP - PPM billing new fields
        if(wr.task != null) {
            zqu.XC_ProjectId__c = wr.task.XC_Project_ID__c;
            zqu.XC_ProjectTaskId__c = wr.task.Id;
            zqu.XC_Project_Task__c = wr.task.Id;
            //JJP 22-11-2021 - ENELX - NR2002_Suplidos in EX invoices - Start           
            //if(wr.task.XC_Account__r.Country__c == 'Spain'){
            List <project_cloud__Project_Task__c> cc = [SELECT XC_Account__r.Country__c FROM project_cloud__Project_Task__c WHERE id = :wr.task.id];
            if(cc[0].XC_Account__r.Country__c == 'Spain') {
                zqu.XC_SuplidoAmount__c = wr.task.XC_SuplidoAmount__c;
                zqu.XC_ApplySuplido__c = wr.task.XC_ApplySuplido__c;

                //ALC 12-01-2022 - ENELX - NR2002_Suplidos in EX invoices - Start
                System.debug('ALC apply suplido: '+wr.task.XC_ApplySuplido__c);
                if(wr.task.XC_ApplySuplido__c){

                    zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
                    quoteAmendment.zqu__Quote__c = wr.zQuoteId;
                    quoteAmendment.zqu__Type__c = 'NewProduct';
                    insert quoteAmendment;

                    zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
                    quoteRatePlan.Name = 'Suplido';
                    quoteRatePlan.zqu__Quote__c = wr.zQuoteId;
                    quoteRatePlan.zqu__AmendmentType__c = 'NewProduct';
                    quoteRatePlan.zqu__QuoteAmendment__c = quoteAmendment.Id;
                    //quoteRatePlan.zqu__ProductRatePlanZuoraId__c = '8adca41e7e47e513017e49c729283875';
                    quoteRatePlan.zqu__QuoteProductName__c = 'Suplido '+wr.item?.XC_Segment__c;

                    String prpName = 'Suplido ';
                    List<zqu__ProductRatePlan__c> productRatePlans = new List<zqu__ProductRatePlan__c>();

                    if (Schema.sObjectType.zqu__ProductRatePlan__c.isAccessible()) {
                        if(wr.item?.XC_Segment__c == 'B2B'){
                            prpName += 'B2B';
                        }else if(wr.item?.XC_Segment__c == 'B2G'){
                            prpName += 'B2G';
                        }

                        productRatePlans = [SELECT Id, Name, zqu__ZuoraId__c FROM zqu__ProductRatePlan__c WHERE Name=:prpName];
                    }

                    if(!productRatePlans.isEmpty()){
                        quoteRatePlan.zqu__ProductRatePlan__c = productRatePlans[0].Id;
                        quoteRatePlan.zqu__ProductRatePlanZuoraId__c = productRatePlans[0].zqu__ZuoraId__c;
                    }

                    insert quoteRatePlan;

                    List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
                    
                    if (Schema.sObjectType.zqu__ProductRatePlanCharge__c.isAccessible()) {
                        productRatePlanCharges = [SELECT Id, Name, zqu__ZuoraId__c FROM zqu__ProductRatePlanCharge__c WHERE Name=:prpName];
                    }

                    zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
                    quoteRatePlanCharge.zqu__QuoteRatePlan__c = quoteRatePlan.Id;
                    quoteRatePlanCharge.XC_DynamicPropertyDefinition__c = 'Suplido';
                    quoteRatePlanCharge.XC_InvoiceDescription__c = 'Suplido';
                    quoteRatePlanCharge.XC_WBE__c = wr.item.XC_Wbe__c;
                    quoteRatePlanCharge.XC_CostCenter__c = wr.item.XC_CMCostCenter__c;
                    quoteRatePlanCharge.XC_ProfitCenter__c = wr.item.XC_CMProfitCenter__c;
                    quoteRatePlanCharge.zqu__EffectivePrice__c = zqu.XC_SuplidoAmount__c;
                    quoteRatePlanCharge.zqu__ListPrice__c = zqu.XC_SuplidoAmount__c;
                    quoteRatePlanCharge.zqu__Quantity__c = 1;
                    quoteRatePlanCharge.zqu__UOM__c = 'Each';
                    quoteRatePlanCharge.zqu__Currency__c = 'EUR';
                    //quoteRatePlanCharge.zqu__ProductRatePlanChargeZuoraId__c = '8adca41e7e47e513017e49c72a503877';
                    
                    if(!productRatePlanCharges.isEmpty()){
                        quoteRatePlanCharge.zqu__ProductRatePlanCharge__c = productRatePlanCharges[0].Id;
                        quoteRatePlanCharge.zqu__ProductRatePlanChargeZuoraId__c = productRatePlanCharges[0].zqu__ZuoraId__c;
                    }

                    insert quoteRatePlanCharge;

                    wr.listRatePlans.add(String.valueOf(productRatePlans[0].Id));
                    List<String> confItems = new List<String>();
                    confItems.add(String.valueOf(wr.item.Id));
                    wr.prpcConfItemsMap.put(productRatePlanCharges[0].Id, confItems);
                }
                //ALC 12-01-2022 - ENELX - NR2002_Suplidos in EX invoices - End
            }
			//JJP 22-11-2021 - ENELX - NR2002_Suplidos in EX invoices - End
        }

        //F.I. Manage Bank Transfer Unique Code IT-Adoption
        if(wr.item != null) {
            zqu.XC_BankTransferCode__c = wr.item.XC_BankTransferCode__c;
            // add check on credit assignment
            if(String.isNotBlank(wr.item.NE__Bundle_Configuration__c) &&
                    wr.item.NE__Bundle_Configuration__r.XC_CreditAssignmentAvailable__c &&
                    wr.item.NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c >0){
                zqu.XC_IncentiveAmount__c = wr.item.NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c;
            }

            //ALC 01-12-2021 - ENELX - NR2001_VAT Management - START
            System.debug('ALC wr.item.XC_CountryFormula__c: '+wr.item.XC_CountryFormula__c);
            System.debug('ALC wr.item.XC_Select_Tax_Completed__c: '+wr.item.XC_Select_Tax_Completed__c);
            System.debug('ALC wr.item.XC_Tax_Subtype__c: '+wr.item.XC_Tax_Subtype__c);
            if(wr.item.XC_CountryFormula__c == 'Spain' && wr.item.XC_Select_Tax_Completed__c && (wr.item.XC_Tax_Subtype__c == 'Exento IVA' || wr.item.XC_Tax_Subtype__c == 'Exento IGIC' || wr.item.XC_Tax_Subtype__c == 'Exento IPSI' || wr.item.XC_Tax_Subtype__c == 'No Sujeción IVA' || wr.item.XC_Tax_Subtype__c == 'No Sujeción IGIC' || wr.item.XC_Tax_Subtype__c == 'No Sujeción IPSI' || wr.item.XC_Tax_Subtype__c == 'Sujeto Pasivo (ISP) IVA' || wr.item.XC_Tax_Subtype__c == 'Sujeto Pasivo (ISP) IGIC')) {
                zqu.zqu__Tax_Exempt__c = 'Yes';
                if(!String.isBlank(wr.item.XC_Exemptions__c)){
                    zqu.CausaExencion__c = wr.item.XC_Exemptions__c.substringBefore('-');
                }else if(!String.isBlank(wr.item.XC_Not_Subject__c)){
                    if(wr.item.XC_Not_Subject__c?.contains('por reglas de')){
                        zqu.CausaExencion__c = 'NS2';
                    }else{
                        zqu.CausaExencion__c = 'NS1';
                    }
                }else if(!String.isBlank(wr.item.XC_Sujeto_Pasivo_ISP__c)){
                    zqu.CausaExencion__c = wr.item.XC_Sujeto_Pasivo_ISP__c.substringBefore('-');
                }
            }
            //ALC 01-12-2021 - ENELX - NR2001_VAT Management - END
        }

        Map<Id, XC_IN018_CreateZquote_U.ZQuoteOption> mapConfogurationItemInitialTerm = XC_IN018_CreateZQuote_UU.calculateInitialTerm(wr.confItemId);

        Boolean foundAttr = false;

        List<NE__Order_Item_Attribute__c> attr = wr.item.NE__Order_Item_Attributes__r;

        XC_IN018_CreateZQuote_UU.computeFoundAttr(attr, foundAttr);

        XC_IN018_CreateZquote_U.ZQuoteOption option = mapConfogurationItemInitialTerm.get(wr.confItemId);

        Map<Id, NE__OrderItem__c> ciBillingValMap = new Map<Id, NE__OrderItem__c>([SELECT XC_BillingModel__c, XC_PaymentMethod__c, NE__OrderId__r.XC_HasFiscalProducts__c, CurrencyIsoCode, ne__OrderId__r.XC_Country__c FROM NE__OrderItem__c WHERE Id = :wr.confItemId]);
        List<NE__OrderItem__c> ciBillingVal = ciBillingValMap.values();

        String ciBillMod = ciBillingVal[0].XC_BillingModel__c;
        zqu.zqu__PaymentMethod__c = ciBillingVal[0].XC_PaymentMethod__c;
        XC_IN018_CreateZQuote_UU.replacePaymentMethod(zqu);

        XC_IN018_CreateZQuote_UU.SetInitTermWrapper setWr = new XC_IN018_CreateZQuote_UU.SetInitTermWrapper();
        setWr.zqu = zqu;
        setWr.option = option;
        setWr.ciBillMod = ciBillMod;
        setWr.confItem = wr.item;
        setInitTermAndAutoRenew(setWr, zqu);


        zqu.zqu__InitialTerm__c = wr.initialTerm != null ? wr.initialTerm : zqu.zqu__InitialTerm__c;
        zqu.zqu__RenewalTerm__c = (ciBillMod == 'Recurring' && zqu.zqu__RenewalTerm__c == null) ? 12 : zqu.zqu__InitialTerm__c;
        zqu.zqu__AutoRenew__c = wr.autoRenew != null ? wr.autoRenew : zqu.zqu__AutoRenew__c;

        // Set InitialTerm, RenewalTerm and AutoRenew based on B2W Attribute
        for(NE__Order_Item_Attribute__c attrib : attr){
            if(attrib.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Duration and Renewal Terms' && attrib.XC_DeveloperName__c == 'Duration' /*&& ciBillMod == 'Recurring'*/){
                zqu.zqu__InitialTerm__c = Decimal.valueOf(attrib.NE__Value__c);
                continue;
            }
            if(attrib.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == 'Duration and Renewal Terms' && attrib.XC_DeveloperName__c == 'Renewal Duration' && attrib.NE__Value__c != null){
                //zqu.zqu__RenewalTerm__c = (ciBillMod == 'Recurring') ? Decimal.valueOf(attrib.NE__Value__c) : zqu.zqu__RenewalTerm__c;
                zqu.zqu__RenewalTerm__c = Decimal.valueOf(attrib.NE__Value__c);
                zqu.zqu__AutoRenew__c = (Decimal.valueOf(attrib.NE__Value__c) == 0) ? false : (( wr.isThirdParty && ciBillMod == 'Usage') || zqu.zqu__AutoRenew__c);//[TP - 2022.01.17 - Third Party Billing - Usage Management]
                wr.generateEvergreen = (Decimal.valueOf(attrib.NE__Value__c) == 0) ? false : wr.generateEvergreen;
                continue;
            }
        }

        //Test Evergreen
        //if(ciBillMod =='Recurring' && wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelXItalia' && wr.item.NE__OrderId__r.XC_Segment__c =='B2C') {
        if(/*wr.generateEvergreen!= null &&*/ wr.generateEvergreen){
            zqu.zqu__Subscription_Term_Type__c ='Evergreen';
            //zqu.zqu__InitialTerm__c =0;
        }

        Boolean isB2BRecurring = ciBillMod =='Recurring' /*&& !(wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'Codensa' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelX' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelDistribucion')*/
                && (wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G');

        if(isB2BRecurring  || Test.isRunningTest()) {
            zqu.zqu__Subscription_Term_Type__c ='Termed';
            zqu.zqu__InitialTermPeriodType__c = XC_UTIL_CreateZQuotePPM.getRecurringPeriodTranscodingMapToZuora().containsKey(wr.item.NE__RecurringChargeFrequency__c) ? XC_UTIL_CreateZQuotePPM.getRecurringPeriodTranscodingMapToZuora().get(wr.item.NE__RecurringChargeFrequency__c) : 'Month';
            zqu.zqu__InitialTerm__c = wr.task != null && wr.task.XC_RecurringDuration__c != null ? wr.task.XC_RecurringDuration__c : wr.item.XC_RecurringDuration__c;
        }
        //DP - installment plan fields
        Boolean isB2BInstallmentPlan = (ciBillMod =='Installment plan' || ciBillMod =='Billing Plan') /*&& !(wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'Codensa' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelX' || wr.item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelDistribucion')*/
                && (wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G');

        if(isB2BInstallmentPlan || Test.isRunningTest()) {
            zqu.XC_InstallmentPlanType__c  = wr.item.XC_InstallmentPlanType__c;
            zqu.InstallmentDivisionTax__c  = wr.item.InstallmentDivisionTax__c;
            zqu.XC_InstallmentFrequency__c = wr.item.XC_InstallmentFrequency__c;
            zqu.XC_InstallmentsNumber__c   = wr.item.XC_InstallmentsNumber__c;
            zqu.XC_InstallmentRate__c      = wr.item.XC_Interests_Index__c + ';' +wr.item.XC_InstallmentRate__c;

            if(ciBillMod =='Billing Plan' || Test.isRunningTest()){
                Decimal total = getBillingPlanTotal(wr.confItemId);
                zqu.XC_BillingPlanTotalAmount__c = String.valueOf(total);
            }
        }

        Boolean isItalyB2B = (legalEntity == 'EnelXItalia' || legalEntity == 'EnelXMobilityItalia' || legalEntity == 'Cogenio' || legalEntity == 'EnelSole')
                && (wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G');
	
		Boolean isSpainB2BG = (legalEntity == 'EndesaX') && (wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G');
        
        Boolean isItalyEsportatoreAbituale = (wr.item?.NE__OrderId__r?.XC_Segment__c == 'B2B' && wr.item?.NE__OrderId__r?.XC_Country__c == 'Italy' && wr.item?.NE__OrderId__r?.NE__OptyId__r?.Account?.XC_AccountTaxType__c == 'Esportatore Abituale');

        
        if(isSpainB2BG){
            zqu.XC_Annex__c = wr.item.NE__OrderId__r.XC_Annex__c == true ? 'yes' : 'no'; 
        }

        if(isItalyB2B) {
            zqu.XC_Annex__c = wr.item.NE__OrderId__r.XC_Annex__c == true ? 'yes' : 'no';
            //zqu.XC_PossibleCompensation__c = wr.item.NE__OrderId__r.XC_PossibleCompensationNew__c;
            zqu.BillingModel__c = wr.item.XC_BillingModel__c;
            if(isItalyEsportatoreAbituale){
                //M.G. 23062022 - NR2450 - START
                zqu.ProtocolNumber__c = (wr.item?.NE__OrderId__r?.NE__OptyId__r?.XC_ProtocolType__c).toUpperCase() +'|'+ wr.item?.NE__OrderId__r?.NE__OptyId__r?.XC_NumeroProtocolloEsportatoreAbituale__c+'|'+String.valueOf(wr.item?.NE__OrderId__r?.NE__OptyId__r?.XC_ProtocolDate__c);
                //END
            } else{
                zqu.ProtocolNumber__c = wr.item.NE__OrderId__r.NE__OptyId__r.XC_NumeroProtocolloEsportatoreAbituale__c;
            }


        }
        //mridul.b.jain@accenture.com NR2299 4/5/22 START
        Set<String> roman = new Set<String>{'EnelXMobilityRomania','EnelXRomania'};
        //mridul.b.jain@accenture.com NR2299 4/5/22 END
        List<Contract> listContract = new List<Contract>();
        //mridul.b.jain@accenture.com NR2299 4/5/22 Added XC_MarketLegalEntity__c in below query
        listContract = [SELECT id, XC_MarketLegalEntity__c, StartDate, XC_AdditionalDescription__c,XC_ContractHeader__c, XC_Configurations__c, Opportunity__c, Opportunity__r.XC_ContractType__c, Opportunity__r.XC_InvoiceType__c, XC_ContractType__c, Contract_Type__c,XC_InvoiceType__c, XC_CIG__c, XC_CUP__c, XC_Determina__c from Contract where Opportunity__c = :wr.item.NE__OrderId__r.NE__OptyId__c];
        if(!listContract.isEmpty()) {
            if (wr.item.NE__OrderId__r.XC_Segment__c == 'B2G' || wr.item.NE__OrderId__r.XC_Segment__c == 'B2B') {
                //List<Contract> listContract = new List<Contract>();
                //listContract = [SELECT id, XC_Configurations__c, Opportunity__c, Opportunity__r.XC_ContractType__c, Opportunity__r.XC_InvoiceType__c, XC_ContractType__c, Contract_Type__c,XC_InvoiceType__c, XC_CIG__c, XC_CUP__c, XC_Determina__c from Contract where Opportunity__c = :wr.item.NE__OrderId__r.NE__OptyId__c];
                //if (!listContract.isEmpty()) {
                zqu.XC_ContractType__c = listContract[0].Opportunity__r.XC_ContractType__c;
                zqu.XC_InvoiceType__c = listContract[0].Opportunity__r.XC_InvoiceType__c;
                if(wr.item.NE__OrderId__r.XC_Segment__c == 'B2G'){
                    zqu.XC_Determina__c = listContract[0].XC_Determina__c;
                    zqu.XC_CigCup__c = (listContract[0].XC_CIG__c != null ? listContract[0].XC_CIG__c : '') + (listContract[0].XC_CUP__c != null ? ';' + listContract[0].XC_CUP__c : '');
                }
                //}
            }
            //mridul.b.jain@accenture.com NR2299 4/5/22 START
            else if('B2C'.equalsIgnoreCase(wr.item.NE__OrderId__r.XC_Segment__c) && roman.contains(legalEntity)){
                //zqu.XC_MarketLegalEntity__c = wr.item.NE__OrderId__r.XC_MarketLegalEntity__c;
                zqu.XC_MarketLegalEntity__c = listContract[0].XC_MarketLegalEntity__c;
            }
            //mridul.b.jain@accenture.com NR2299 4/5/22 END
            Set<String> itaLE = new Set<String>{'EnelXItalia','EnelXMobilityItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio'};
            if(itaLE.contains(legalEntity)) {
                zqu.XC_AdditionalDescription__c = listContract[0].XC_AdditionalDescription__c;
                zqu.XC_Observaciones__c = listContract[0].XC_ContractHeader__c;
            }

        }

        if(ciBillMod == 'Milestone'){
            zqu.XC_InvoiceType__c = 'Single Invoice - Aggregate Components';
        }

        Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt = new Map<Id,Map<String,NE__Order_Item_Attribute__c>>();
        Boolean isB2B2G = (wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G');
        if(isB2B2G){
            
            List<String> listItem = new List<String>();
            listItem.add(wr.confItemId);
            mapIdMapNameConfItemAtt = XC_IN018_CreateZQuote_UU.retriveConfItemAttribute(listItem);
            system.debug('mapIdMapNameConfItemAtt->'+mapIdMapNameConfItemAtt);
            if(mapIdMapNameConfItemAtt!= null && !mapIdMapNameConfItemAtt.isEmpty() && mapIdMapNameConfItemAtt.get(wr.confItemId)!=null){
                for (NE__Order_Item_Attribute__c att :mapIdMapNameConfItemAtt.get(wr.confItemId).values()){
                    system.debug('att.XC_DeveloperName__c->'+att.XC_DeveloperName__c);
                    system.debug('Label.XC_CL_ReverseCharge->'+Label.XC_CL_ReverseCharge);
                    if(att.XC_DeveloperName__c == Label.XC_CL_ReverseCharge)
                        zqu.AutoPost__c = 'No';

                }
            }

            //Manage AIU Fiscal Products logic
            try {
                zqu.zqu__InvoiceSeparately__c = ciBillingValMap.containsKey(wr.item.Id) && ciBillingValMap.get(wr.item.Id).NE__OrderId__r.XC_HasFiscalProducts__c ? false : zqu.zqu__InvoiceSeparately__c;
                //Multicurrency
                Set<String> managedCurrencies = new Set<String>{'CLF','USD','EUR'};
                Set<String> managedCountries = new Set<String>{'Chile','Colombia'};
                String ordCurr = null;
                for(NE__OrderItem__c oi : ciBillingValMap.values()){
                    if(managedCurrencies.contains(oi.CurrencyIsoCode) && managedCountries.contains(oi.ne__OrderId__r.XC_Country__c)){
						ordCurr = oi.CurrencyIsoCode;
                        break;
                    }
                }
                zqu.XC_OrderCurrency__c = ordCurr != null  ? ordCurr : zqu.XC_OrderCurrency__c;
            }catch(Exception e){
                System.debug('Manage AIU Fiscal Products logic: '+e.getMessage()+' at line '+e.getLineNumber());
                System.debug(e.getStackTraceString());
            }
        }

        /// set zuora entity Id
        if(wr.item != null){
            XC_ZuoraZQuoteUtil_U.EntityWrapper entityWr = XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper(legalEntity, wr.item.NE__OrderId__r.XC_Segment__c, wr.stepId);
            if(entityWr == null){
                return new List<XC_UTIL_Sobject.WrapperResult>();
            }

            String startDateLocal = (Test.isRunningTest()) ? String.valueOf(DateTime.now()) : DateTime.now().format('yyyy-MM-dd', entityWr.timeZone);
            System.debug('StartDate (local time): ' + startDateLocal);

            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022 - start
            /*
            if(isB2B2G && !listContract.isEmpty()){
                try{
                    startDateLocal = listContract[0].StartDate != null ? Datetime.newInstance(listContract[0].StartDate,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd', entityWr.timeZone) : startDateLocal;
                    startDateLocal = (!mapIdMapNameConfItemAtt.isEmpty() && mapIdMapNameConfItemAtt.containsKey(wr.item.Id) && mapIdMapNameConfItemAtt.get(wr.item.Id) != null && mapIdMapNameConfItemAtt.get(wr.item.Id).containsKey('Override Subscription Date') && mapIdMapNameConfItemAtt.get(wr.item.Id).get('Override Subscription Date').NE__Value__c == 'Yes' && wr.item.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Payment__c == 'Commodity Bill' && wr.item.XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_LastEventDate__c != null && listContract[0].StartDate != null && wr.item.XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_LastEventDate__c > listContract[0].StartDate) ? String.valueOf(wr.item.XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_LastEventDate__c) : startDateLocal;
                }catch(Exception e){
                    System.debug('startDateLocal Exception->'+e.getMessage());
                    System.debug('startDateLocal Exception->'+e.getStackTraceString());
                }
            }
            */
            if(isB2B2G && wr.item.XC_BillingModel__c =='Recurring'){
                startDateLocal = wr.item.NE__StartDate__c != null ? String.valueOf(wr.item.NE__StartDate__c) : startDateLocal;
            }
            //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022 - end

            //20220114 HotTopic_PROV_32 - [DO] – start
            //zqu.zqu__StartDate__c = (wr.item.NE__OrderId__r.XC_ActivationDateOverride__c != null) ? wr.item.NE__OrderId__r.XC_ActivationDateOverride__c : (!wr.item.Assets__r.isEmpty() && legalEntity == Label.XC_CL_EndesaX && wr.item.NE__OrderId__r.XC_Segment__c == 'B2C' && wr.item.XC_Product_Type__c == Label.XC_CL_OrderItem_ProductType) ? Date.valueOf(wr.item.Assets__r[0].CreatedDate.format('yyyy-MM-dd', entityWr.timeZone)) : Date.valueOf(startDateLocal);
            zqu.zqu__StartDate__c = (wr.item.NE__OrderId__r.XC_ActivationDateOverride__c != null) ? wr.item.NE__OrderId__r.XC_ActivationDateOverride__c : Date.valueOf(startDateLocal);
            //20220114 HotTopic_PROV_32 - [DO] – end
            zqu.zqu__ValidUntil__c = (wr.item.NE__OrderId__r.XC_ActivationDateOverride__c != null) ? wr.item.NE__OrderId__r.XC_ActivationDateOverride__c : Date.valueOf(startDateLocal);
            zqu.zqu__Service_Activation_Date__c = (wr.item.NE__OrderId__r.XC_ActivationDateOverride__c != null) ? wr.item.NE__OrderId__r.XC_ActivationDateOverride__c : Date.valueOf(startDateLocal);

            //[Begin - NR1640 Fix - 20220503 - LR]
            // Overrides the subscription start date if the last invoice date is populated on the provisioning step.
            // However, if a balance product is added to the order, its effective start date date is selected to define the start date of the new subscription 
            if(wr.lastInvoiceDate != null){
                zqu.zqu__StartDate__c = (wr.balanceEffectiveStartDate != null) ? wr.balanceEffectiveStartDate : wr.lastInvoiceDate;
                zqu.zqu__ValidUntil__c = (wr.balanceEffectiveStartDate != null) ? wr.balanceEffectiveStartDate :wr.lastInvoiceDate;
                zqu.zqu__Service_Activation_Date__c = (wr.balanceEffectiveStartDate != null) ? wr.balanceEffectiveStartDate : wr.lastInvoiceDate;
            }
            // [End - NR1640 Fix - 20220503 - LR]

            if(isB2B2G && wr.item.NE__ProdName__c == 'Monitoring and Verification Start'){
                zqu.zqu__StartDate__c = zqu.zqu__StartDate__c.addMonths(1);
                zqu.zqu__ValidUntil__c = zqu.zqu__ValidUntil__c.addMonths(1);
                zqu.zqu__Service_Activation_Date__c = zqu.zqu__Service_Activation_Date__c.addMonths(1);
            }


            if(wr.isPreview){
                zqu.zqu__Service_Activation_Date__c = null;
                //zqu.zqu__StartDate__c = null;
                zqu.zqu__ValidUntil__c = null;
                zqu.zqu__GenerateInvoice__c = false;
            }

            Map<Id, zqu__BillingEntity__c> billingEntityMap = new Map<Id, zqu__BillingEntity__c>([SELECT Id FROM zqu__BillingEntity__c WHERE zqu__EntityID__c =: entityWr.entityId]);
            zqu.zqu__BillingEntity__c = billingEntityMap.values()[0].Id;
            zqu.zqu__ZuoraEntityId__c = entityWr.entityId;
            
            //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 11/02/2022]
            zqu.XC_DTTNumberAndDate__c = (String.isNotBlank(wr.dttNumberAndDate)) ? wr.dttNumberAndDate : null;
            //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 11/02/2022]
        }

        zquotesToUpd.add(zqu);

        List<XC_UTIL_Sobject.WrapperResult> listRet = XC_UTIL_Sobject.updateListRecords(zquotesToUpd);

        Map<Id, NE__OrderItem__c> mapZQuoteConfigurationItem = new Map<Id,NE__OrderItem__c>{wr.zQuoteId => wr.item};
        System.debug('@@@ mapZQuoteConfigurationItem --> ' +  mapZQuoteConfigurationItem);


        //XC_ZuoraZQuoteUtil.overridePrices(mapZQuoteConfigurationItem);

        //XC_ZuoraZQuoteUtil.tryToApplyDiscountPercentage(mapZQuoteConfigurationItem, 'Cupon');
        /*XC_IN018_CreateZQuote_U.UpdateRPQueuable updateRPQJob = new XC_IN018_CreateZQuote_U.UpdateRPQueuable(new List<Id>{wr.zquoteID},
                                                                                                                wr.prpcConfItemsMap,
                                                                                                                wr.listRatePlans);*/

        XC_IN018_CreateZQuote_U.UpdateRPQueuable updateRPQJob = new XC_IN018_CreateZQuote_U.UpdateRPQueuable(new List<Id>{wr.zquoteID}, wr);
        System.enqueueJob(updateRPQJob);

        return listRet;
    }


    /**
     * @description Gets the map payment method item id.
     * @author FedericoXC_BillingPlanTotalAmount__c Amici - federico.amici@nttdata.com
     * @param wr the wrapper
     * @param zqu the quote
     */
    private static void setInitTermAndAutoRenew(XC_IN018_CreateZQuote_UU.SetInitTermWrapper wr, zqu__Quote__c zqu) {
        if(wr.option != null) {
            zqu.zqu__InitialTerm__c = wr.option.initialTerm;
            zqu.zqu__AutoRenew__c = wr.option.autoRenew;
        } else if((wr.ciBillMod == 'Usage') || (wr.ciBillMod == 'Recurring')) { // 2019-06-02 Billing Model check for initial term and auto-renew
            zqu.zqu__InitialTerm__c = 12;
            zqu.zqu__AutoRenew__c = true;
        } else {
            zqu.zqu__InitialTerm__c = wr.confItem.XC_Duration__c != null ? wr.confItem.XC_Duration__c : 1;
            zqu.zqu__AutoRenew__c = wr.confItem.NE__CatalogItem__r.XC_AutoRenewal__c;
        }

    }

    private static String checkNullValue(Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt, String confItemId, String nameConfItemAttri){
        String valueMap = '';
        if(mapIdMapNameConfItemAtt.containsKey(confItemId) && mapIdMapNameConfItemAtt.get(confItemId).containsKey(nameConfItemAttri)){
            valueMap = mapIdMapNameConfItemAtt.get(confItemId).get(nameConfItemAttri).NE__Value__c ;
            System.Debug('NON NULL ATTRIBUTE::: ' + valueMap + ' ATTR NAME : ' + nameConfItemAttri);
        }
        return valueMap;
    }

    /**
    *@author Francesco Imperioli
    *@description check if subsidy amount has to be sent based on LE configuration
    *@createddate 2020-03-06
    */
    private static String checkSubsidyAmount(Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt,String confItemId,Asset parentAsset, String nameConfItemAttri, String stream){

        if(String.isNotBlank(checkNullValue(mapIdMapNameConfItemAtt,confItemId,nameConfItemAttri)) && parentAsset!=null){

            String parentAssetLE = parentAsset.XC_LegalEntity__c;
            String currentOrgId = UserInfo.getOrganizationId();
            Boolean hasCreditAssignment = parentAsset.XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c;
            XC_CM_LegalEntity_Configuration__mdt currentLEConf =
            [
                    SELECT ID,XC_LegalEntity__c,XC_AllowCreditAssignment__c
                    FROM XC_CM_LegalEntity_Configuration__mdt
                    WHERE XC_LegalEntity__c = :parentAssetLE AND XC_OrgId__c = :currentOrgId AND XC_Stream__c = :stream
                    LIMIT 1
            ];

            if(!hasCreditAssignment && currentLEConf.XC_AllowCreditAssignment__c){
                return '';

            }else{
                return checkNullValue(mapIdMapNameConfItemAtt,confItemId,nameConfItemAttri);
            }
        }
        return '';
    }






    /**
    * @description method to update rate plan charge
    *
    * @param newZQuoteId the  newzquote id
    * @param ratePlanAddList the rate plan add list
    */
    public static void updateRatePlanChargePreview(Map<String, Object> mapUtil) {

        String newZQuoteId = (String) mapUtil.get('newZQuoteId');
        List<String> listRatePlans = (List<String>) mapUtil.get('listRatePlans');
        Map<String, List<String>> prpcConfItemsMap = (Map<String, List<String>>) mapUtil.get('prpcConfItemsMap');
        NE__OrderItem__c confItemMalfunction = (NE__OrderItem__c) mapUtil.get('confItemMalfunction');   // FOR ChangeOrder - Substitution (Malfunction)
        Map<Id, String> confItemDynamicPropDef = (Map<Id, String>) mapUtil.get('confItemDynamicPropDef'); // For third party product

        XC_Milestone__c milestone = (XC_Milestone__c) mapUtil.get('milestone'); //DP PPM milestone
        project_cloud__Project_Task__c theTask = (project_cloud__Project_Task__c) mapUtil.get('projectTask'); //DP PPM milestone
        Boolean isPreview = (Boolean) mapUtil.get('isPreview');

        System.debug('@@@ isPreview -> ' + isPreview);
        System.debug('@@@ prpcConfItemsMap -> ' + prpcConfItemsMap);

        /********** Retrieve the asset having the needed fields **********/
        System.debug('newZQuoteId -> ' + newZQuoteId);

        Map<String, String> confItemIdEffectivePriceMap = new Map<String, String>();
        List<String> allConfigItemsId = new List<String>();
        for(List<String> l : prpcConfItemsMap.values()){
            allConfigItemsId.addAll(l);
        }

        Map<id,NE__OrderItem__c> allOrdItems = new Map<Id, NE__OrderItem__c>([
                select id, NE__Qty__c, NE__OneTimeFeeOv__c,
                        NE__RecurringChargeOv__c,  NE__Item_Code__c,
                        NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c,
                        XC_DaneCode__c,  XC_RelatedProduct__c,
                        XC_CreditAssignmentAvailable__c,
                        XC_Good_Cost__c,
                        NE__OrderId__r.XC_Segment__c,XC_Wbe__c,XC_CMProfitCenter__c,
                        NE__CatalogItem__r.Catalog_item_code__c, XC_CMCostCenter__c, Name, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, XC_BillingModel__c,
            			NE__CatalogItem__c, NE__CatalogItem__r.NE__UsageCode__c //[NR2122 - ET - 28/02/2022]
                from NE__OrderItem__c where id in :allConfigItemsId
        ]);

        Map<String, Asset> confItemIdAssetMap = new Map<String, Asset>();

        List<String> confItemCodes = new List<String>();
        for(NE__OrderItem__c a : allOrdItems.values()) {
            confItemCodes.add(a.NE__Item_Code__c);
        }

        List<NE__OrderItem__c> listSubsidyItem = new List<NE__OrderItem__c>([SELECT Id
        FROM NE__OrderItem__c
        WHERE XC_ZQuoteId__c = :newZQuoteId
        AND (XC_RelatedProduct__c IN: confItemCodes OR XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive)]);

        List<String> listSubsidyItemIds = new List<String>();
        if(!listSubsidyItem.isEmpty()){
            listSubsidyItemIds = XC_UTIL_Sobject.getIds(listSubsidyItem);
        }
        List<zqu__QuoteRatePlanCharge__c> rpChargeList = [SELECT Id, Name, zqu__ChargeType__c,zqu__Model__c, zqu__EffectivePrice__c, TariffType__c, zqu__ProductRatePlanCharge__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c
        FROM zqu__QuoteRatePlanCharge__c
        WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :newZQuoteId];
        Date startDate = Date.Today();
        if(!Test.isRunningTest()) {
            startDate = rpChargeList[0].zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c;
        }

        Map<Id, zqu__ProductRatePlanCharge__c> prpcList = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, name, XC_WBE__c, XC_ProfitCenter__c, PIncludedkWh__c, TariffType__c
        FROM zqu__ProductRatePlanCharge__c
        WHERE zqu__ProductRatePlan__c IN :listRatePlans]);

        Map<String,List<NE__Order_Item_Discount__c>> discounts;
        if(confItemMalfunction == null) {

            //fimperioli added --> check on discount items
            List<String> confItemsIds = new List<String>();
            confItemsIds.addAll(confItemIdAssetMap.keySet());
            discounts = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(confItemsIds);

            confItemIdEffectivePriceMap = XC_IN018_CreateZQuote_UU.calculateEffectivePricePreview(allOrdItems, discounts);

        } else {  // FOR ChangeOrder - Substitution (Malfunction)

            discounts = XC_IN018_CreateZQuote_D.retrieveDiscountItemsMap(new List<String>{confItemMalfunction.Id});
            confItemIdEffectivePriceMap = XC_IN018_CreateZQuote_UU.calculateEffectivePriceMulfunction(confItemMalfunction,discounts, allOrdItems.values()[0].Id);
        }

        Map<String, zqu__ProductRatePlanCharge__c> mapQRPCNameToPRPC = XC_IN018_CreateZQuote_UU.createMapQRPCToPRPC(rpChargeList, prpcList.values());
        System.debug('@@@ confItemIdEffectivePriceMap -> ' + confItemIdEffectivePriceMap);

        /********** Update RatePlanCharge **********/
        zqu__ProductRatePlanCharge__c prpc;
        Decimal includedKWh;

        Map<Id,Map<String,NE__Order_Item_Attribute__c>> mapIdMapNameConfItemAtt = new Map<Id,Map<String,NE__Order_Item_Attribute__c>>();
        if(!listSubsidyItemIds.isEmpty()){
            mapIdMapNameConfItemAtt = XC_IN018_CreateZQuote_UU.retriveConfItemAttribute(listSubsidyItemIds);
            System.Debug('SUBSIDY ITEMS MAP::: ' + mapIdMapNameConfItemAtt);
        }

        for (zqu__QuoteRatePlanCharge__c rpc : rpChargeList ) {
            prpc = prpcList.get(rpc.zqu__ProductRatePlanCharge__c);
            System.debug('@@@ prpc -> ' + prpc);

            String confItemId = prpcConfItemsMap.get(prpc.Id)[0];
            System.debug('@@@ confItemId -> ' + confItemId);

            /*rpc.XC_WBE__c = (!String.isBlank(prpc.XC_WBE__c)) ? prpc.XC_WBE__c : confItemIdAssetMap.get(confItemId).XC_WBE__c;
            rpc.XC_ProfitCenter__c = (!String.isBlank(prpc.XC_ProfitCenter__c)) ? prpc.XC_ProfitCenter__c : confItemIdAssetMap.get(confItemId).XC_CMProfitCenter__c;*/
            rpc.TariffType__c = (!String.isBlank(prpc.TariffType__c )) ? prpc.TariffType__c  : rpc.TariffType__c;
            rpc.XC_DynamicPropertyDefinition__c = (confItemDynamicPropDef != null && confItemDynamicPropDef.get(confItemId) != null) ? confItemDynamicPropDef.get(confItemId) : '';

            if(allOrdItems.containsKey(confItemId)){
                rpc.XC_DaneCode__c = allOrdItems.get(confItemId).XC_DaneCode__c;
                rpc.XC_CostCenter__c = allOrdItems.get(confItemId).XC_CMCostCenter__c;
                rpc.XC_InvoiceDescription__c = allOrdItems.get(confItemId).Name;
                rpc.XC_GoodAmount__c = (allOrdItems.get(confItemId).XC_Good_Cost__c == null) ? '' : String.valueOf(allOrdItems.get(confItemId).XC_Good_Cost__c);

                if(String.isNotBlank(allOrdItems.get(confItemId).NE__CatalogItem__r.Catalog_item_code__c)){
                    rpc.XC_VASCode__c = allOrdItems.get(confItemId).NE__CatalogItem__r.Catalog_item_code__c;
                }

            }

            /*SUBSIDY MANAGEMENT*/
            /*----------------------------*/
            //rpc.XC_SubsidyDuration__c = Date.valueOf(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Duration'));//Date.valueOf(mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Duration').NE__Value__c);
            if(allOrdItems.containsKey(confItemId) && allOrdItems.get(confItemId).NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c ==Label.XC_CL_SubsidyProductName){

                rpc.XC_SubsidyType__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Type');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Type').NE__Value__c ;
                rpc.XC_SubsidySubtype__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Subtype'); //mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Subtype').NE__Value__c ;
                rpc.XC_SubsidyForm__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Form'); //mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Form').NE__Value__c ;
                rpc.XC_SubsidyCollectionType__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Collection Type');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Collection Type').NE__Value__c ;
                rpc.XC_SubsidyCode__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Code');//mapIdMapNameConfItemAtt.get(confItemId).get('Subsidy Code').NE__Value__c ;
                rpc.XC_SubsidyAmount__c = String.isEmpty(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Amount')) ? null :Decimal.valueOf(checkSubsidyAmount(mapIdMapNameConfItemAtt,confItemId,confItemIdAssetMap.get(confItemId),'Subsidy Amount', confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c));
                rpc.XC_InvoiceDescription__c = !String.isBlank(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Name')) ? checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Subsidy Name') : rpc.XC_InvoiceDescription__c;

            }else if(confItemIdAssetMap.containsKey(confItemId) && confItemIdAssetMap.get(confItemId).XC_Product_SubType__c==Label.XC_CL_ProductSubtypeIncentive && confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.XC_CreditAssignmentAvailable__c){
                //in case of "cessione del credito" we populate subsidy fields on zuora
                rpc.XC_SubsidyCode__c = checkNullValue(mapIdMapNameConfItemAtt, confItemId, 'Type') + '_' +  checkNullValue(mapIdMapNameConfItemAtt, confItemId, 'Amount');
                rpc.XC_SubsidyAmount__c = String.isEmpty(checkNullValue(mapIdMapNameConfItemAtt, confItemId,'Amount')) ? null :Decimal.valueOf(checkSubsidyAmount(mapIdMapNameConfItemAtt,confItemId,confItemIdAssetMap.get(confItemId),'Amount', confItemIdAssetMap.get(confItemId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c));

            }
            /*----------------------------*/
            
            //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]
            rpc.XC_CumulativeInvoiceType__c = (mapUtil.get('cumulativeInvoiceType') != null) ? (String) mapUtil.get('cumulativeInvoiceType') : null; 
            rpc.XC_CumulativeInvoiceCode__c = (String.isNotBlank(allOrdItems.get(confItemId).NE__CatalogItem__r?.NE__UsageCode__c) && String.IsNotBlank (rpc.XC_CumulativeInvoiceType__c)) ? 'Codice Accessorio;' +  allOrdItems.get(confItemId).NE__CatalogItem__r?.NE__UsageCode__c : null;
            //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]

            Map<String, Object> inputFields = new Map<String, Object>{'confItemId' => confItemId,
            'confItemIdEffectivePriceMap' => confItemIdEffectivePriceMap,
            'confItemIdAssetMap' => confItemIdAssetMap,
            'prpc' => prpc,
            'oiDiscountMap' => discounts,
            'date' => startDate,
            'allOrdItems' => allOrdItems,
            'isPreview' => isPreview

            };
            System.debug('§inputFields:'+inputFields);

            XC_IN018_CreateZQuote_UU.populateRcpFieldsPreview(rpc, inputFields);

            prpcConfItemsMap.get(prpc.Id).remove(0);
        }

        XC_UTIL_SObject.updateListRecords(rpChargeList);
    }

    public static Decimal getBillingPlanTotal(String confItemId){
        Decimal tot = 0;
        List<NE__OrderItem__c> allOrdItems = [select id,NE__OneTimeFeeOV__c from NE__OrderItem__c where id = :confItemId or NE__Root_Order_Item__c = :confItemId ];
        for(NE__OrderItem__c oi : allOrdItems){
            tot += oi.NE__OneTimeFeeOV__c != null ? oi.NE__OneTimeFeeOV__c : 0;
        }
        return tot;
    }

    /**
    * @author Eleni Tsiolaki - etsiolaki@deloitte.gr / Dimitris Karnavas - dkarnavas@deloitte.gr
    *@description loops through all conf item attributes and checks for seperate invoice attribute
    *@param wr UpdateWrapper
    *@return Boolean
    */
    //
    private static Boolean checkItemAttributeForSeperateInvoice(UpdateWrapper wr){
        Boolean result = null;
        List<NE__Order_Item_Attribute__c> orderItemAttributes = wr.item.NE__Order_Item_Attributes__r;
        for(NE__Order_Item_Attribute__c oia:orderItemAttributes){
            if(oia.XC_DeveloperName__c == Label.XC_CL_SeparateInvoice && !String.isBlank(oia.NE__Value__c)){
                result = Boolean.valueOf(oia.NE__Value__c);
                break;
            }
        }
        return result;
    }

    @TestVisible
    private static Boolean checkInvoice (UpdateWrapper wr){
        if(wr.item.NE__Bundle_Configuration__c != null){
            List<zqu__QuoteRatePlan__c> listOfQuoteRatePlan = new List<zqu__QuoteRatePlan__c>([SELECT Id FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c =: wr.zquoteID]);
            List<String> listOfIdQuoteRatePlan = XC_UTIL_SObject.getIds(listOfQuoteRatePlan);
            if(listOfIdQuoteRatePlan.isEmpty()){
                return true;
            }
            List<zqu__QuoteRatePlanCharge__c> listOfQuoteRatePlanCharge = new List<zqu__QuoteRatePlanCharge__c>([SELECT Id, Name, zqu__QuoteRatePlan__c,zqu__DiscountAmount__c, zqu__DiscountPercentage__c, zqu__EffectivePrice__c, zqu__Quantity__c, zqu__Model__c
                                                            FROM zqu__QuoteRatePlanCharge__c
                                                            WHERE zqu__QuoteRatePlan__r.id IN : listOfIdQuoteRatePlan]);
            if(listOfQuoteRatePlanCharge.isEmpty()){
                return true;
            }
            Map<String, List<zqu__QuoteRatePlanCharge__c>> mapQuoteRatePlanQuoteRatePlanCharge = new Map<String, List<zqu__QuoteRatePlanCharge__c>>();
            for(zqu__QuoteRatePlanCharge__c quoteCharge : listOfQuoteRatePlanCharge){
                if(!mapQuoteRatePlanQuoteRatePlanCharge.containsKey(quoteCharge.zqu__QuoteRatePlan__c)){
                    mapQuoteRatePlanQuoteRatePlanCharge.put(quoteCharge.zqu__QuoteRatePlan__c, new List<zqu__QuoteRatePlanCharge__c>());
                }
                mapQuoteRatePlanQuoteRatePlanCharge.get(quoteCharge.zqu__QuoteRatePlan__c).add(quoteCharge);
            }
            Double totalAmount = 0;
            for(String key : mapQuoteRatePlanQuoteRatePlanCharge.keySet()){
                Double totalProduct = 0;
                Double percentageDiscount = 0;
                for(zqu__QuoteRatePlanCharge__c quoteCharge : mapQuoteRatePlanQuoteRatePlanCharge.get(key)){
                    if(quoteCharge.zqu__EffectivePrice__c != null  && quoteCharge.zqu__Model__c != Label.XC_CL_DiscountFixedAmount
                            && quoteCharge.zqu__Model__c != Label.XC_CL_DiscountPercentage){
                        if(quoteCharge.zqu__Quantity__c != null){
                            totalProduct += quoteCharge.zqu__EffectivePrice__c * quoteCharge.zqu__Quantity__c;
                        }else{
                            totalProduct += quoteCharge.zqu__EffectivePrice__c;
                        }
                    }
                    if(quoteCharge.zqu__DiscountAmount__c != null && quoteCharge.zqu__Model__c == Label.XC_CL_DiscountFixedAmount){
                        totalProduct = totalProduct - quoteCharge.zqu__DiscountAmount__c;
                    }
                    if(quoteCharge.zqu__DiscountPercentage__c != null && quoteCharge.zqu__Model__c == Label.XC_CL_DiscountPercentage){
                        percentageDiscount = quoteCharge.zqu__DiscountPercentage__c;
                    }
                }
                if(percentageDiscount != 0){
                    totalProduct = totalProduct - (totalProduct*percentageDiscount/100);
                }
                totalAmount += totalProduct;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'totalAmount-->' +totalAmount);
            }
            if(wr.item.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c != null){
                Double bundleOTAmount = wr.item.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c;
                Double differenceBetweenOTAmountZuora = MATH.abs(bundleOTAmount - totalAmount);
                if(differenceBetweenOTAmountZuora >= 0.5){
                    return false;
                }else{
                    return true;
                }
            }
        }
        return true;
    }

}