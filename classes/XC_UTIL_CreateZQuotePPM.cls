/**
 * The Class XC_UTIL_CreateZQuotePPM.
 *
 * @author dpalamides - dpalamides@deloitte.it
 * @date Creation 22/05/2020
 * @description Handles the creation of the zQuote during the ppm billing task 
 */


public without sharing class XC_UTIL_CreateZQuotePPM {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_CreateZQuotePPM');


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @date 27/03/2019
     * @description Handles the creation of the zQuote
     */
    private class CreateWrapper {
        public String orderId;
        public Integer numberOfClones;
        public NE__OrderItem__c item;
        public List<String> listRatePlan;
        public Decimal initialTerm;
        public Boolean autoRenew;
        public Set<Id> itemIdList;
        public Boolean isPreview = false;
    }


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @date 27/03/2019
     * @description Handles the creation of the zQuote
     */
    public class ManageCreationWrapper {

        public Boolean                  generateInvoice;
        public Boolean                  separateInvoice;
        public Decimal                  initialTerm;
        public Boolean                  autoRenew;
        public String                   confItemId;
        public List<Id>                 confItemsIds      = new List<Id>();
        public List<NE__OrderItem__c>   confItems         = new List<NE__OrderItem__c>();

        public XC_Milestone__c milestone;
        public project_cloud__Project_Task__c task;
        public Boolean isPreview = false;


        /**
        * @description converto to IN018 wrapper.
        * @author dpalamides - dpalamides@deloitte.it
        * @return XC_IN018_CreateZQuote.ManageCreationWrapper the manage creation wrapper
        */
        public XC_IN018_CreateZQuote.ManageCreationWrapper convertWrapper(){
            XC_IN018_CreateZQuote.ManageCreationWrapper ret = new XC_IN018_CreateZQuote.ManageCreationWrapper();
            ret.generateInvoice = this.generateInvoice;
            ret.separateInvoice = this.separateInvoice;
            ret.initialTerm = this.initialTerm;
            ret.autoRenew = this.autoRenew;
            ret.confItemId = this.confItemId;
            ret.confItemsIds = this.confItemsIds;
            ret.confItems = this.confItems;

            return ret;
        }


        /**
        * @description applies IN018 wrapper flags.
        * @author dpalamides - dpalamides@deloitte.it
        * @param XC_IN018_CreateZQuote.ManageCreationWrapper wr
        */
        public void applyFlags(XC_IN018_CreateZQuote.ManageCreationWrapper wr){
            this.generateInvoice =   wr.generateInvoice;
            this.separateInvoice =   wr.separateInvoice;
            this.initialTerm =       wr.initialTerm;
            this.autoRenew =         wr.autoRenew;
            this.confItemId =        wr.confItemId;
            this.confItemsIds =      wr.confItemsIds;
            this.confItems =         wr.confItems;
        }

    }


    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @date 23/12/2019
     * @description Handles the creation of the zQuote
     */
    public class MilestoneWrapper{

        /** The Boolean. */
        public Boolean generateInvoice;

        /** The Boolean. */
        public Boolean separateInvoice;

        /** The Decimal. */
        public Decimal initialTerm;

        /** The Boolean. */
        public Boolean autoRenew;

        /** The String. */
        public String configurationItemId;

        /** The NE__OrderItem__c. */
        public NE__OrderItem__c item;

        /** The XC_Milestone__c. */
        public XC_Milestone__c milestone;

        /** The project_cloud__Project_Task__c. */
        public project_cloud__Project_Task__c task;

        /** The Boolean. */
        public Boolean isPreview = false;
    }


    /** 
     * @description Manage creation zquote.
     * @author dpalamides - dpalamides@deloitte.it
     * @param wr the manage creation wrapper
     */
    private static void manageCreationZquote(ManageCreationWrapper wr) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkBillingProfileConditions CALL');

        NE__OrderItem__c item = XC_IN018_CreateZQuote_D.retrieveConfigItemData(wr.confItemId);
        Id orderId = item.NE__OrderId__c;
        List<String>  ratePlanConfItem = new List<String>();
        Set<Id> confItemIdList = new Set<Id>();
        Boolean mixedVat = false;
        Map<Id, String> confItemDynamicPropDef = new Map<Id, String>();

        // Check WBE Tracking
        Map<String, Object> mapResultWbe = checkWBE(item);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ResultWbe: ' + mapResultWbe);

        //FM start SQUAD - Gestione errori task di billing
        if(item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'EnelSole'){
            mapResultWbe = checkValueForMilleston(item, wr.task, mapResultWbe);
        }
        //FM end SQUAD - Gestione errori task di billing
        
        if(mapResultWbe.containsKey('success') && Boolean.valueOf(mapResultWbe.get('success')) == false) {
            project_cloud__Project_Task__c task = wr.task;
            task.XC_TaskStatus__c = 'Suspended';
            task.XC_Message__c = mapResultWbe.containsKey('message') ? String.valueOf(mapResultWbe.get('message')) : '';
            XC_UTIL_Sobject.updateRecord(task);
            return;
        }

        // retrive the correct flags to set on the zquote
        XC_IN018_CreateZQuote.ManageCreationWrapper in018WR = wr.convertWrapper();
        XC_IN018_CreateZQuote_D.retrieveZuoraFlags(in018WR, item);
        wr.applyFlags(in018WR);

        if(wr.confItemsIds.isEmpty()){  // FOR No Penalty

            List<NE__OrderItem__c> relatedProductItems = XC_IN018_CreateZQuote_D.retrieveRelatedProductConfItems(item);

            if(!String.isBlank(item.NE__Bundle_Configuration__c)) {     // For Bundle
                List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveBundleConfItems(item.NE__Bundle_Configuration__c);
                for(NE__OrderItem__c ordItem : itemList){
                    if(item.XC_Product_Type__c != 'Bundle'){
                        ratePlanConfItem.add(ordItem.Id);
                    }
                    if(ordItem.NE__CatalogItem__r.XC_Mixed_VAT__c == true){
                        mixedVat = true;
                    }
                    confItemIdList.add(ordItem.Id);
                }
                confItemIdList.add(item.NE__Bundle_Configuration__c);

            } else if(item.XC_ProvisioningSpareParts__c) {      // For Tecnical Product
                List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveTecnicalProductConfItems(orderId);
                for(NE__OrderItem__c tecnicalProduct : itemList) {
                    ratePlanConfItem.add(tecnicalProduct.Id);
                    confItemIdList.add(tecnicalProduct.Id);
                }
            //17-02-2022 alag@deloitte.es Milestone Management now applies for all legal entities if Milestone Management is checked - START
            } else if(/*item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'Codensa' && */ item.NE__OrderId__r.NE__OptyId__r.XC_Milestone_Management__c){
            //17-02-2022 alag@deloitte.es Milestone Management now applies for all legal entities if Milestone Management is checked - END
                List<NE__OrderItem__c> childOrderItems = [SELECT id FROM NE__OrderItem__c WHERE NE__Parent_Order_Item__c =: item.Id];
                for (NE__OrderItem__c child: childOrderItems){
                    ratePlanConfItem.add(child.Id);
                    confItemIdList.add(child.Id);
                }
                ratePlanConfItem.add(item.Id);
                confItemIdList.add(item.Id);
            }else{

                if(item.NE__CatalogItem__r.XC_Mixed_VAT__c == true){
                    mixedVat = true;
                }

                if(item.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c == Label.XC_CL_SeguroProteccionDePagos){ // For Third Party Products
                    for(NE__Order_Item_Attribute__c oiAttr : item.NE__Order_Item_Attributes__r){
                        if(oiAttr.XC_DeveloperName__c == Label.XC_CL_Aliado){
                            confItemDynamicPropDef.put(item.Id, oiAttr.NE__Value__c);
                        }
                    }
                }

                ratePlanConfItem.add(item.Id);
                confItemIdList.add(item.Id);
            }

            if(!relatedProductItems.isEmpty()){    // For Subsidy and Shipping (Item with RelatedProduct field filled)
                ratePlanConfItem.add(relatedProductItems[0].Id);
                confItemIdList.add(relatedProductItems[0].Id);
            }

        }else if(item.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c == 'Codensa' &&  item.NE__OrderId__r.NE__OptyId__r.XC_Milestone_Management__c){
            List<NE__OrderItem__c> childOrderItems = [SELECT id FROM NE__OrderItem__c WHERE NE__Parent_Order_Item__c =: item.Id];
            System.debug('childOrderItems: ' + childOrderItems);
            for (NE__OrderItem__c child: childOrderItems){
                ratePlanConfItem.add(child.Id);
                confItemIdList.add(child.Id);
            }
            ratePlanConfItem.add(item.Id);
            confItemIdList.add(item.Id);
        } else { // FOR Penalty (called by XC_IN039)
            ratePlanConfItem.addAll(wr.confItemsIds);
            confItemIdList.addAll(new Set<Id>(wr.confItemsIds));
        }

        System.debug('ratePlanConfItem: ' + ratePlanConfItem);
        System.debug('confItemIdList: ' + confItemIdList);

        Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
        List<String> listRatePlan = XC_IN018_CreateZQuote_U.getAllRatePlanByItemId(ratePlanConfItem, prpcConfItemsMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listRatePlan: ' + listRatePlan);
        if(listRatePlan.isEmpty()) {
            generateErrorForNoRatePlan(wr.task);
            System.debug('nessun RP'+ratePlanConfItem);
            return;
        }

        /***************** Create RatePlan List *************************/
        Map<Id, List<String>> mapConfItemRatePlanList = new Map<Id, List<String>>();

        Integer numberOfzQuote = 1;
        CreateWrapper wrCreate = new CreateWrapper();
        wrCreate.orderId = orderId;
        wrCreate.numberOfClones = numberOfZquote;
        wrCreate.item = item;
        wrCreate.listRatePlan = listRatePlan;
        wrCreate.isPreview = wr.isPreview;
        wrCreate.itemIdList = confItemIdList;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrCreate: ' + wrCreate);
        System.debug('@@@createZQuotes-->' +wrCreate);
        Id zquoteId = createZQuotes(wrCreate);

        List<XC_UTIL_Sobject.WrapperResult> updResult = new List<XC_UTIL_Sobject.WrapperResult>();

        try {
            Contract cont = [select id, XC_InvoiceType__c from Contract where XC_Configurations__c = :orderId][0];
            if(cont.XC_InvoiceType__c.contains('Separate')){
               wr.separateInvoice = true;
            }
        } catch (Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Exception: ' + e.getStackTraceString());
        }

        XC_IN018_CreateZquote_U.UpdateWrapper wrUpdate = new XC_IN018_CreateZquote_U.UpdateWrapper();
        wrUpdate.orderId = orderId;
        wrUpdate.zQuoteId = String.valueOf(zQuoteId);
        wrUpdate.confItemId = wr.confItemId;
        wrUpdate.item = item;
        wrUpdate.separateInvoice = wr.separateInvoice;
        wrUpdate.generateInvoice = wr.generateInvoice;
        wrUpdate.generateEvergreen = false;
        wrUpdate.initialTerm = wr.initialTerm;
        wrUpdate.autoRenew = wr.autoRenew;

        /* Update qrpc*/
        wrUpdate.listRatePlans = listRatePlan;
        wrUpdate.prpcConfItemsMap = prpcConfItemsMap;
        wrUpdate.mixedVat = mixedVat;
        wrUpdate.confItemDynamicPropDef = confItemDynamicPropDef;

        wrUpdate.milestone = wr.milestone;
        wrUpdate.task = wr.task;

        wrUpdate.isPreview = wrCreate.isPreview;

        if(wrUpdate.milestone!=null){
            wrUpdate.task.XC_Milestone__c = wrUpdate.milestone.Id;
            wrUpdate.task.XC_Milestone__r = wrUpdate.milestone;
        }
        List<XC_UTIL_Sobject.WrapperResult> listWr;

        listWr = XC_IN018_CreateZquote_U.updateZQuotes(wrUpdate);
        if(listWr == null) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### Error ### No access to field');
            return;
        }
        updResult.addAll(listWr);
    }


    /**
     * @description Creates the Z quotes.
     * @author dpalamides - dpalamides@deloitte.it
     * @param wr the wrapper
     * @return the id
     */
    private static Id createZQuotes(CreateWrapper wr){

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ createZQuotes CALL idOrder='+wr.orderId+' - numberOfClone='+wr.numberOfClones);
        List<zqu__Quote__c> allZquotes = new List<zqu__Quote__c>();
        NE.DataMap.DataMapResponse dResp;

        try {
            dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote',wr.orderId);
        } catch(Exception e) {
            dResp = null;
        }

        if(dResp == null) {
            return null;
        }

        String idZuoraQuote = dResp.ParentId;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ zquote ' + idZuoraQuote);

        zqu__Quote__c quote = new zqu__Quote__c(Id = idZuoraQuote);
        List<zqu__Quote__c> zQuotes = new List<zqu__Quote__c>{quote};
        List<XC_UTIL_Sobject.WrapperResult> sobjectResults = XC_UTIL_Sobject.insertListRecords(zQuotes);

        quote.zqu__currency__c = wr.item.NE__CatalogItem__r.CurrencyIsoCode;
        quote.CurrencyIsoCode = wr.item.NE__CatalogItem__r.CurrencyIsoCode;
        quote.XC_Pod__c = wr.item.XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityCupsID__c;
        quote.XC_IsPreviewQuote__c = wr.isPreview;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'quote: ' + quote);
        XC_UTIL_Sobject.updateRecord(quote);

        wr.item.XC_ZQuoteId__c = idZuoraQuote;

        List<NE__OrderItem__c> children = new List<NE__OrderItem__c>();
        children.AddAll([select id from NE__OrderItem__c where NE__Root_Order_Item__c in :wr.itemIdList]);
        if(!children.isEmpty()){
            wr.itemIdList.addAll(XC_UTIL_Sobject.getIds(children));
        }
        List<NE__OrderItem__c> confItemList = new List<NE__OrderItem__c> ();
        for(String itemId : wr.itemIdList){
            NE__OrderItem__c confItem = new NE__OrderItem__c(Id = itemId , XC_ZQuoteId__c = idZuoraQuote);
            confItemList.add(confItem);
        }
        XC_UTIL_SObject.updateListRecords(confItemList);

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listRatePlanToAdd: ' + wr.listRatePlan);
        System.debug('@@@AddQuoteRatePlanFromRatePlan --> idZuoraQuote: ' +idZuoraQuote + ' - RatePlanList: ' +wr.listRatePlan);
        b2wzc.Bit2Win_OrderConnector.AddQuoteRatePlanFromRatePlan(idZuoraQuote, wr.listRatePlan);

        return idZuoraQuote;
    }


    /** 
     * @description generate Error For No Rate Plan.
     * @author dpalamides - dpalamides@deloitte.it
     * @param zQuoteId the id of zQuote
     */
    @TestVisible
    public static void generateErrorForNoRatePlan(project_cloud__Project_Task__c theTask){
        if(theTask!=null) {
            theTask.XC_TaskStatus__c = 'Suspended';
            //theTask.project_cloud__Health__c = 'Yellow';
            theTask.XC_Message__c = Label.XC_CL_ErrorMessage_NoRatePlanFound;
            XC_UTIL_Sobject.updateRecord(theTask);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'theTask: ' + theTask);
        }
    }


    /**
    *@author dpalamides - dpalamides@deloitte.it
    *@description create zquote from specific order item using a MilestoneWrapper
    */
    public static void createZquote(List<MilestoneWrapper> inputWrapperList) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN018_CreateZQuote');
        Boolean generateInvoice;
        Boolean separateInvoice;
        Decimal initialTerm;
        Boolean autoRenew;

        if(!inputWrapperList.isEmpty()){

            String orderId = '';

            for(MilestoneWrapper inputWr : inputWrapperList){
                generateInvoice = inputWr.generateInvoice;
                separateInvoice = inputWr.separateInvoice;
                initialTerm = inputWr.initialTerm;
                autoRenew = inputWr.autoRenew;
            }


            String confItemId;
            List<Id> confItemsIds = new List<Id>();
            List<NE__OrderItem__c> confItems = new List<NE__OrderItem__c>();

            project_cloud__Project_Task__c theTask;
            XC_Milestone__c theMilestone;

            Boolean isPreview = false;
            for(MilestoneWrapper inputWr : inputWrapperList) {
                orderId = inputWR.item.NE__OrderId__c; //TODO
                confItemId = inputWr.configurationItemId;
                confItemsIds.add(inputWr.configurationItemId);
                confItems.add(inputWr.item);

                //billing task & milestone (if present) are always the same for a zQuote
                theTask = inputWR.task;
                theMilestone = inputWR.milestone;

                isPreview = inputWR.isPreview;
            }

            /************* Get item actions and split in two lists *************/
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@manageCreationZquote--> ConfItem: ' +confItemId + ' - generateInvoice: ' +generateInvoice + ' - separateInvoice: ' +separateInvoice);
            ManageCreationWrapper wrCreation = new ManageCreationWrapper();
            wrCreation.generateInvoice = generateInvoice;
            wrCreation.separateInvoice = separateInvoice;
            wrCreation.confItemId = confItemId;
            wrCreation.initialTerm = initialTerm;
            wrCreation.autoRenew = autoRenew;
            wrCreation.confItemsIds = confItemsIds;
            wrCreation.confItems = confItems;

            wrCreation.milestone = theMilestone;
            wrCreation.task = theTask;

            wrCreation.isPreview = isPreview;

            manageCreationZquote(wrCreation);
        }
    }


    /** 
     * @description getRecurringPeriodTranscodingMapToZuora - get bit2win / zuora recurring periods mapping
     * @author dpalamides
     * @return Map<String,String> bit2win
     */
    public static Map<String,String> getRecurringPeriodTranscodingMapToZuora(){
        Map<String,String> ret = new Map<String,String>();
        Map<Id,XC_CM_RecurringPeriodTranscode__mdt> m = new Map<Id,XC_CM_RecurringPeriodTranscode__mdt>([
                select Id, XC_ZuoraRecurringPeriod__c, XC_Bit2winRecurringPeriod__c from XC_CM_RecurringPeriodTranscode__mdt limit 100
        ]);
        for(XC_CM_RecurringPeriodTranscode__mdt rec : m.values()){
            ret.put(rec.XC_Bit2winRecurringPeriod__c,rec.XC_ZuoraRecurringPeriod__c);
        }
        return ret;
    }


    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @date 11/11/2021
     * @description Method to check WBE
     * @param orderItem - NE__OrderItem__c
     * @return Map<String, Object>
     */
    private static Map<String, Object> checkWBE(NE__OrderItem__c orderItem) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN checkWBE');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderItem: ' + orderItem);

        Map<String, Object> mapResult = new Map<String, Object>();

        if(String.isBlank(orderItem.XC_ProductLine__c) || String.isBlank(orderItem.XC_ProductServiceType__c)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN checkWBE');
            orderItem.XC_ProductLine__c = orderItem.NE__CatalogItem__r.XC_ProductLine__c;
            orderItem.XC_ProductServiceType__c = orderItem.NE__CatalogItem__r.XC_ProductServiceType__c;
            XC_UTIL_SObject.updateRecord(orderItem);
        }
		
        // Check WBE fields
        String checkBlankValues = (XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE').Value__c : 'false';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkBlankValues: ' + checkBlankValues);
        if(checkBlankValues == 'true') {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN check WBE fields');
            Boolean missingFields = false;
            String fields = '';
            if(String.isBlank(orderItem.XC_CMCostCenter__c)) {
                fields += 'CostCenter';
                missingFields = true;
            }
            if(String.isBlank(orderItem.XC_CMProfitCenter__c)) {
                fields += (missingFields) ? ', ProfitCenter' : 'ProfitCenter';
                missingFields = true;
            }
            if(String.isBlank(orderItem.XC_ProductServiceType__c)) {
                fields += (missingFields) ? ', ProductServiceType' : 'ProductServiceType';
                missingFields = true;
            }
            if(String.isBlank(orderItem.XC_ProductLine__c)) {
                fields += (missingFields) ? ', ProductLine' : 'ProductLine';
                missingFields = true;
            }
            if(String.isBlank(orderItem.XC_Wbe__c)) {
                fields += (missingFields) ? ', Wbe' : 'Wbe';
                missingFields = true;
            }
            if(missingFields) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN missing WBE fields');
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Missing fields: ' + fields);
                mapResult.put('success', false);
                mapResult.put('message', Label.XC_CL_ProvisioningStep_MissingWBEFields);
                mapResult.put('messageDetails', 'Missing Fields: ' + fields);
                return mapResult;
            }
        }
        
        // Check WBE Tracking
        String checkWBETracking = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking').Value__c : 'false';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkWBETracking: ' + checkWBETracking);
        if(checkWBETracking == 'true') {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN check WBE Tracking');
            String checkWBETrackingBasedOnExcludedCatalog = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog').Value__c : null;
            List<String> catalogsNameForWBETrackingOnly = (checkWBETrackingBasedOnExcludedCatalog != null) ? checkWBETrackingBasedOnExcludedCatalog.split(';') : new List<String>();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'catalogsNameForWBETrackingOnly: ' + catalogsNameForWBETrackingOnly);

            String catalogName = orderItem.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c;
            if(String.isNotBlank(catalogName) && catalogsNameForWBETrackingOnly.contains(catalogName)) {
                mapResult.put('success', true);
                return mapResult;
            }

            List<XC_WbeTracking__c> listWBETracking = new List<XC_WbeTracking__c>([SELECT XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_ProductLine__c, XC_ProductService__c
                                                                                    FROM XC_WbeTracking__c 
                                                                                    WHERE XC_Status__c          = :Label.XC_CL_Configuration_Approved   AND
                                                                                        XC_Wbe__c               = :orderItem.XC_Wbe__c                  AND
                                                                                        XC_ProfitCenter__c      = :orderItem.XC_CMProfitCenter__c       AND
                                                                                        XC_CostCenter__c        = :orderItem.XC_CMCostCenter__c         AND
                                                                                        XC_ProductLine__c       = :orderItem.XC_ProductLine__c          AND
                                                                                        XC_ProductService__c    = :orderItem.XC_ProductServiceType__c]);

            if(listWBETracking.isEmpty()) {
                mapResult.put('success', false);
                mapResult.put('message', Label.XC_CL_ProvisioningStep_WBEFieldsNotValid);
                return mapResult;
            }
        }
        
        mapResult.put('success', true);
        return mapResult;
    }

    /**
     * @author Federico Manni - federico.manni@accenture.com - CR0709
     * @date 11/11/2021
     * @description Method to check WBE
     * @param orderItem - NE__OrderItem__c
     * @return Map<String, Object>
     */
    private static Map<String, Object> checkValueForMilleston(NE__OrderItem__c orderItem, project_cloud__Project_Task__c task, Map<String, Object> mapResult){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN checkValueForMilleston');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderItem: ' + orderItem);

        Boolean missingFields = false;
        String fields = '';

        if(String.isBlank(orderItem.XC_BillingModel__c)){
            fields += 'Billing model';
            missingFields = true;
        }
        if(!String.isBlank(orderItem.XC_BillingModel__c) && orderItem.XC_BillingModel__c == 'Milestone'){
            
            project_cloud__Project_Task__c taskc = [SELECT id, XC_MilestoneNumber__c, XC_TaskReason__c, XC_MilestonePercentage__c FROM project_cloud__Project_Task__c WHERE id = :task.id]; 
			
            if(taskc.XC_MilestoneNumber__c == null){
                fields += (missingFields) ? ', Milestone Number' : 'Milestone Number';
                missingFields = true;
            }
            if(String.isBlank(taskc.XC_TaskReason__c)){
                fields += (missingFields) ? ', Task Reason' : 'Task Reason';
                missingFields = true;
            }
            if(taskc.XC_MilestonePercentage__c == null){
                fields += (missingFields) ? ', Milestone Percentage' : 'Milestone Percentage';
                missingFields = true;
            }
            if(!String.isBlank(taskc.XC_TaskReason__c) && taskc.XC_TaskReason__c != 'Milestone'){
                fields += (missingFields) ? ', Task Reason is not Milestone' : 'Task Reason is not Milestone';
                missingFields = true;
            }
        }
        if(String.isBlank(orderItem.XC_BillingProfileLineItem__c)){
            fields += (missingFields) ? ', Billing Profile Line Item' : 'Billing Profile Line Item';
            missingFields = true;
        }
        if(!String.isBlank(orderItem.XC_BillingProfileLineItem__c) && (orderItem.XC_BillingProfileLineItem__r.XC_Status__c != 'Active')){
            fields += (missingFields) ? ', Billing Profile Line Item is not Active' : 'Billing Profile Line Item is not Active';
            missingFields = true;
        }
        if(String.isBlank(orderItem.XC_PaymentMethod__c)){
            fields += (missingFields) ? ', Payment Method' : 'Payment Method';
            missingFields = true;
        }
        //BEGIN federico.manni@accenture.com - INC000079947800
        /*
        if(String.isBlank(orderItem.NE__BillingProfId__r.NE__Payment__c)){
            fields += (missingFields) ? ', Billing Profile' : 'Billing Profile';
            missingFields = true;
        }
        if(!String.isBlank(orderItem.XC_PaymentMethod__c) && !String.isBlank(orderItem.NE__BillingProfId__r.NE__Payment__c)){
            if(orderItem.XC_PaymentMethod__c != orderItem.NE__BillingProfId__r.NE__Payment__c){
                fields += (missingFields) ? ', Payment Method in Billing Profile and Payment Method in item is not equals' : 'Payment Method in Billing Profile and Payment Method in item is not equals';
                missingFields = true;
            }
        }
        */
        //END federico.manni@accenture.com - INC000079947800
        if(!String.isBlank(orderItem.XC_BillingProfileLineItem__c) && String.isBlank(orderItem.XC_BillingProfileLineItem__r.XC_CustomerAccount__c) && (orderItem.XC_BillingProfileLineItem__r.XC_Status__c == 'Active')){
            fields += (missingFields) ? ', Billing Account Zuora for Billing Account Active' : 'Billing Account Zuora for Billing Account Active';
            missingFields = true;
        }

        if(missingFields) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN missing Milestone fields');
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Missing fields: ' + fields);
            mapResult.put('success', false);
            mapResult.put('message', 'Missing Fields: ' + fields);
            mapResult.put('messageDetails', 'Missing Fields: ' + fields);
            return mapResult;
        }

        mapResult.put('success', true);
        return mapResult;

    }

}