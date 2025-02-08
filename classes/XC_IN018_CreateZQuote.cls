/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 27/03/2019
 * @date Last Modification 08/07/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description Handles the creation of the zQuote during the provisioning step
 */


public without sharing class XC_IN018_CreateZQuote {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN018_CreateZQuote');


    /** 
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId; 
        @Invocablevariable
        public Boolean generateInvoice;
        @Invocablevariable
        public Boolean separateInvoice;
        @Invocablevariable
        public Decimal initialTerm;
        @Invocablevariable
        public Boolean autoRenew;
    } 


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 27/03/2019
     * @description Handles the creation of the zQuote during the provisioning step
     */
    private class CreateWrapper {
        public String orderId;
        public Integer numberOfClones;
        public NE__OrderItem__c item;
        public List<String> listRatePlan;
        public String stepId;
        public Decimal initialTerm;
        public Boolean autoRenew;
        public Set<Id> itemIdList;
        public String dttNumberAndDate; //NR2122 - Cumulative Invoice
    }
    

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 27/03/2019
     * @description Handles the creation of the zQuote during the provisioning step
     */
    public class ManageCreationWrapper {
        public String stepId;
        public Boolean generateInvoice;
        public Boolean separateInvoice;
        public Boolean generateEvergreen = false;
        public Decimal initialTerm;
        public Boolean autoRenew;
        public String confItemId;
        public List<Id> confItemsIds = new List<Id>();
        public List<NE__OrderItem__c> confItems = new List<NE__OrderItem__c>();
    }


    /**
     * @author francesco imperioli - fimperioli@deloitte.it
     * @date 23/12/2019
     * @description Handles the creation of the zQuote during another provisioning step for specific order item
     */
    public class ExternalWrapper{ 
        public String stepId; 
        public Boolean generateInvoice;
        public Boolean separateInvoice;
        public Decimal initialTerm;
        public Boolean autoRenew;
        public String configurationItemId;
        public NE__OrderItem__c item;
    } 


    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description createZquote manages the creation of the zquote
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void createZquote(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN018_CreateZQuote');
        Boolean generateInvoice;
        Boolean separateInvoice;
        Decimal initialTerm;
        Boolean autoRenew;
        String stepId;
        
        if(!inputWrapperList.isEmpty()){
            List<String> listStepIds = new List<String>();
            List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
            String orderId = ''; 
            XC_Provisioning_Step__c step;
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
                generateInvoice = inputWr.generateInvoice;
                separateInvoice = inputWr.separateInvoice;
                initialTerm = inputWr.initialTerm;
                autoRenew = inputWr.autoRenew;
            }

            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);
            String confItemId;
            for(InputWrapper inputWr : inputWrapperList) {
                step = mapSteps.get(inputWr.stepId);
                //NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c);
                orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
                confItemId = step.XC_Configuration_Item__c;
                stepId = step.Id;
                //COMPLETE STEP - Salvatore Scarpato 14/3/2019
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                provisioningStepsToComplete.add(step); 

            }


            Boolean resultGenerateWorkorders = XC_UTIL_Configuration.generateWorkorders(orderId, stepId, 'XC_IN018_CreateZQuote');
            if(!resultGenerateWorkorders && !Test.isRunningTest()) {
                return;
            }

            /*Map<String, Object> mapResultWbe = checkWBE(orderId);
            if(mapResultWbe.containsKey('success') && Boolean.valueOf(mapResultWbe.get('success')) == false) {
                XC_Provisioning_Step__c stepToUpdateFailure = new XC_Provisioning_Step__c(
                    Id = stepId,
                    XC_Status__c = Label.XC_CL_Step_CompletedKO,
                    XC_ErrorMessage__c = mapResultWbe.containsKey('message') ? String.valueOf(mapResultWbe.get('message')) : ''
                );
                XC_UTIL_Sobject.updateRecord(stepToUpdateFailure);
                return;
            }*/
           
            /************* Get item actions and split in two lists *************/
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@manageCreationZquote--> ConfItem: ' +confItemId + ' - generateInvoice: ' +generateInvoice + ' - separateInvoice: ' +separateInvoice);
            ManageCreationWrapper wrCreation = new ManageCreationWrapper();
            wrCreation.stepId = stepId;
            wrCreation.generateInvoice = generateInvoice;
            wrCreation.separateInvoice = separateInvoice;
            wrCreation.confItemId = confItemId;
            wrCreation.initialTerm = initialTerm;
            wrCreation.autoRenew = autoRenew;
            manageCreationZquote(wrCreation, mapSteps);
        } 
    } 


    /** 
     * @description Manage creation zquote
     * @author Federico Amici - federico.amici@nttdata.com
     * @param wr the manage creation wrapper
     * @param mapSteps
     */
    private static void manageCreationZquote(ManageCreationWrapper wr, Map<Id, XC_Provisioning_Step__c> mapSteps) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkBillingProfileConditions CALL');
        NE__OrderItem__c item = XC_IN018_CreateZQuote_D.retrieveConfigItemData(wr.confItemId);
        Id orderId = item.NE__OrderId__c;
        List<String>  ratePlanConfItem = new List<String>();
        Set<Id> confItemIdList = new Set<Id>();
        Boolean mixedVat = false;
        Boolean currencyCLF= false;
        Boolean isThirdParty = false;//[2021-10-14 :: TP :: Third Party Billing :: Identify TP]
        Map<Id, String> confItemDynamicPropDef = new Map<Id, String>();
        Date  balanceEffectiveStartDate; //  [NR1640 Fix - 20220517 - LR]
        
        if(item.Assets__r == null || item.Assets__r.isEmpty()) {
            XC_UTIL_SObject.updateRecord(new XC_Provisioning_Step__c(Id = wr.stepId,
                                                                        XC_Status__c = Label.XC_CL_Step_CompletedKO,
                                                                        XC_ErrorMessage__c = 'Missing Asset'));
            return;
        }

        // Retrieve the correct flags to set on the zquote
        XC_IN018_CreateZQuote_D.retrieveZuoraFlags(wr, item);
        if(wr.confItemsIds.isEmpty()){  // FOR No Penalty
            List<NE__OrderItem__c> relatedProductItems = XC_IN018_CreateZQuote_D.retrieveRelatedProductConfItems(item);
            if(!String.isBlank(item.NE__Bundle_Configuration__c)) {     // For Bundle
                List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveBundleConfItems(item.NE__Bundle_Configuration__c);   
                for(NE__OrderItem__c ordItem : itemList){
                    if(item.XC_Product_Type__c != 'Bundle'){
                        ratePlanConfItem.add(ordItem.Id);
                    }
                    if(ordItem.NE__CatalogItem__r.XC_Mixed_VAT__c == true && ordItem.NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')){
                        mixedVat = true; 
                    }
                    if(ordItem.CurrencyIsoCode == Label.XC_CL_UnidadFomento_ISO){
                        currencyCLF = true;
                    } 
                    confItemIdList.add(ordItem.Id);
                }
                confItemIdList.add(item.NE__Bundle_Configuration__c);
              
            } else if(item.XC_ProvisioningSpareParts__c) {      // For Tecnical Product and Coupons
                //List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveTecnicalProductConfItems(orderId);
                List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveConfItemsForSpareParts(orderId, item.XC_Product_Type__c, item.XC_Product_Subtype__c);
                for(NE__OrderItem__c tecnicalProduct : itemList) {
                    ratePlanConfItem.add(tecnicalProduct.Id);
                    confItemIdList.add(tecnicalProduct.Id);
                    if(tecnicalProduct.CurrencyIsoCode == Label.XC_CL_UnidadFomento_ISO){
                        currencyCLF = true;
                    } 
                }
            }
            
            //MP Start
            else if(item.NE__ProdId__r.Manage_Complex_Product_B2C__c){ //For Complex Product
                String itemIdString=String.valueOf(item.id);
                List<NE__OrderItem__c> items = 
                XC_IN018_CreateZQuote_D.retrieveTecnicalProductConfItemsChildren(itemIdString);
                ratePlanConfItem.add(item.id);
                confItemIdList.add(item.id);
                for(NE__OrderItem__c child: items){
                    ratePlanConfItem.add(child.id);
                    confItemIdList.add(child.id);   
                }
            }
            //MP finish
            
            else{
                if(item.NE__CatalogItem__r.XC_Mixed_VAT__c == true  && item.NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')){
                    mixedVat = true; 
                }
                // BEGIN - [2021-10-14 :: TP :: Third Party Billing :: Identify TP]
                // isThirdParty = (item.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c == Label.XC_CL_SeguroProteccionDePagos);
                String thirdPartyName = '';
                for(NE__Order_Item_Attribute__c oiAttr : item.NE__Order_Item_Attributes__r){
                    isThirdParty |= (oiAttr.NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c == Label.XC_CL_ThirdPartyFamilyLic);
                    if( oiAttr.XC_DeveloperName__c == Label.XC_CL_Aliado )
                    {
                        thirdPartyName = oiAttr.NE__Value__c;
                    }
                }
                if((isThirdParty || item.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c == Label.XC_CL_SeguroProteccionDePagos) && String.isNotBlank(thirdPartyName)){ //[TP - 2022.01.17 - Third Party Billing Usage]// For Third Party Products 
                    confItemDynamicPropDef.put(item.Id, thirdPartyName);
                }
                // END - [2021-10-14 :: TP :: Third Party Billing :: Identify TP]
                ratePlanConfItem.add(item.Id);
                confItemIdList.add(item.Id);
                if(item.CurrencyIsoCode == Label.XC_CL_UnidadFomento_ISO){
                    currencyCLF = true;
                } 
            }
            if(!relatedProductItems.isEmpty()){    // For Subsidy and Shipping (Item with RelatedProduct field filled)
                ratePlanConfItem.add(relatedProductItems[0].Id);
                confItemIdList.add(relatedProductItems[0].Id);
            }
            
            // [Begin - NR1640 Fix - 20220517 - LR]
            balanceEffectiveStartDate = getBalanceEffectiveDate(item);// For change order with balance product 
            // [End - NR1640 Fix - 20220517 - LR]

        } else { // FOR Penalty (called by XC_IN039)
            ratePlanConfItem.addAll(wr.confItemsIds);
            confItemIdList.addAll(new Set<Id>(wr.confItemsIds));
        }

        Map<String, Object> mapResultWbe = checkWBE(ratePlanConfItem);
        if(mapResultWbe.containsKey('success') && Boolean.valueOf(mapResultWbe.get('success')) == false) {
            XC_Provisioning_Step__c stepToUpdateFailure = new XC_Provisioning_Step__c(
                Id = wr.stepId,
                XC_Status__c = Label.XC_CL_Step_CompletedKO,
                XC_ErrorMessage__c = mapResultWbe.containsKey('message') ? String.valueOf(mapResultWbe.get('message')) : '',
                XC_ErrorMessageDetails__c = mapResultWbe.containsKey('messageDetails') ? String.valueOf(mapResultWbe.get('messageDetails')) : ''
            );
            XC_UTIL_Sobject.updateRecord(stepToUpdateFailure);
            return;
        }

        Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
        List<String> listRatePlan = XC_IN018_CreateZQuote_U.getAllRatePlanByItemId(ratePlanConfItem, prpcConfItemsMap);
        if(listRatePlan.isEmpty()) {
            generateErrorForNoRatePlan(ratePlanConfItem);
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
        wrCreate.stepId = wr.stepId;
        wrCreate.itemIdList = confItemIdList;
        //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 21/03/2022]
        List<WorkOrder> workOrders = XC_IN018_CreateZQuote_D.retrieveWOfields(orderId);
        wrCreate.dttNumberAndDate = (!workOrders.isEmpty() && String.IsNotBlank(workOrders[0].XC_DeliveryId__c) && workOrders[0].XC_EffectiveDeliveryDate__c != null) ? workOrders[0].XC_DeliveryId__c + ';' + workOrders[0].XC_EffectiveDeliveryDate__c : null; 
        //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 21/03/2022]
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@createZQuotes-->' +wrCreate);
        Id zquoteId = createZQuotes(wrCreate);
                                                
        List<XC_UTIL_Sobject.WrapperResult> updResult = new List<XC_UTIL_Sobject.WrapperResult>();

        XC_IN018_CreateZquote_U.UpdateWrapper wrUpdate = new XC_IN018_CreateZquote_U.UpdateWrapper();
        wrUpdate.orderId = orderId;
        wrUpdate.zQuoteId = String.valueOf(zQuoteId);
        wrUpdate.confItemId = wr.confItemId;
        wrUpdate.item = item;
        wrUpdate.separateInvoice = wr.separateInvoice;
        wrUpdate.generateInvoice = wr.generateInvoice;
        wrUpdate.initialTerm = wr.initialTerm;
        wrUpdate.autoRenew = wr.autoRenew;
        wrUpdate.stepId = wr.stepId;
        /*27052019 1353 Update qrpc*/
        wrUpdate.listRatePlans = listRatePlan;
        wrUpdate.prpcConfItemsMap = prpcConfItemsMap;
        wrUpdate.mixedVat = mixedVat; 
        wrUpdate.manageCurrencyCLF = currencyCLF;
        wrUpdate.confItemDynamicPropDef = confItemDynamicPropDef;
        wrUpdate.generateEvergreen = wr.generateEvergreen;
        wrUpdate.isThirdParty = isThirdParty;//[2021-10-14 :: TP :: Third Party Billing :: Identify TP]
        //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]
        wrUpdate.dttNumberAndDate = (!workOrders.isEmpty() && String.IsNotBlank(workOrders[0].XC_DeliveryId__c) && workOrders[0].XC_EffectiveDeliveryDate__c != null) ? workOrders[0].XC_DeliveryId__c + ';' + workOrders[0].XC_EffectiveDeliveryDate__c : null; 
        if(item!=null && item.NE__OrderId__c != null && item.NE__OrderId__r.NE__OptyId__c != null) {
            wrUpdate.cumulativeInvoiceType = (String.isNotBlank(item.NE__OrderId__r.NE__OptyId__r.XC_DataType__c) && String.isNotBlank(item.NE__OrderId__r.NE__OptyId__r.XC_TextReference__c)) ? item.NE__OrderId__r.NE__OptyId__r.XC_DataType__c + ';' + item.NE__OrderId__r.NE__OptyId__r.XC_TextReference__c : null;
        }
        //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 15/02/2022]
        wrUpdate.lastInvoiceDate = mapSteps.get(wr.stepId) != null ? mapSteps.get(wr.stepId).XC_LastInvoiceDate__c : null; //[NR1640 Fix - 20220503 - LR]
        wrUpdate.balanceEffectiveStartDate = balanceEffectiveStartDate; //[NR1640 Fix - 20220503 - LR]
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
     * @author Federico Amici - federico.amici@nttdata.com
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
        //[BEGIN - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 11/02/2022]
        quote.XC_DTTNumberAndDate__c = (String.IsNotBlank(wr.dttNumberAndDate)) ? wr.dttNumberAndDate : null;
        //[END - NR2122 - Cumulative Invoice - Eleni Tsiolaki - 11/02/2022]
        XC_UTIL_Sobject.updateRecord(quote);

        wr.item.XC_ZQuoteId__c = idZuoraQuote;

        if(wr.item.NE__OrderId__r.XC_Segment__c =='B2B' || wr.item.NE__OrderId__r.XC_Segment__c =='B2G' || wr.item.NE__ProdId__r.Manage_Complex_Product_B2C__c == true){
            List<NE__OrderItem__c> children = new List<NE__OrderItem__c>();
            children.AddAll([select id from NE__OrderItem__c where NE__Root_Order_Item__c in :wr.itemIdList]);
            if (!children.isEmpty()) {
                wr.itemIdList.addAll(XC_UTIL_Sobject.getIds(children));
            }
        }

        List<NE__OrderItem__c> confItemList = new List<NE__OrderItem__c> ();
        for(String itemId : wr.itemIdList){
            NE__OrderItem__c confItem = new NE__OrderItem__c(Id = itemId , XC_ZQuoteId__c = idZuoraQuote);
            confItemList.add(confItem);
        }
        XC_UTIL_SObject.updateListRecords(confItemList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@AddQuoteRatePlanFromRatePlan --> idZuoraQuote: ' +idZuoraQuote + ' - RatePlanList: ' +wr.listRatePlan);
        b2wzc.Bit2Win_OrderConnector.AddQuoteRatePlanFromRatePlan(idZuoraQuote, wr.listRatePlan);
        return idZuoraQuote;
    }


    /** 
     * @description generate Error For No Rate Plan.
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @param zQuoteId the id of zQuote
     */
    @TestVisible
    public static void generateErrorForNoRatePlan(List<String> ratePlanConfItem){
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id,
                                                                                (SELECT Id, XC_Status__c FROM Provisioning_Steps__r 
                                                                                WHERE XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningCreateSubscription_Flow 
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningTriggerInvoice_Flow
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningTriggerInvoiceBarcode_Flow
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_ChangeProvisioningSubstitutionBillingProcess_Flow
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_ChangeProvisioning_AddRemoveCoverage_BillingProcess_Flow
                                                                                OR XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningCreateSubscriptionTriggerInvoice_Flow
                                                                               	OR XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_CreateSubscriptionNoZeroPrice_Flow
                                                                                )
                                                                                FROM NE__OrderItem__c WHERE Id IN :ratePlanConfItem]);
        
        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = new Map<Id, XC_Provisioning_Step__c>();
        for(NE__OrderItem__c oi : orderItemMap.values()) {
            XC_TR_ZQuote_U_ManageErrors.manageStepsForErrorZquote(oi.Provisioning_Steps__r, Label.XC_CL_ErrorMessage_NoRatePlanFound, mapStepToUpdate);
        }
        XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values());
    }


    /**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@description create zquote from specific order item using an externalwrapper
    */ 
    public static void createZquote(List<ExternalWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN018_CreateZQuote');
        Boolean generateInvoice;
        Boolean separateInvoice;
        Decimal initialTerm;
        Boolean autoRenew;
        String stepId;
        if(!inputWrapperList.isEmpty()){
            List<String> listStepIds = new List<String>();
            List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
            String orderId = ''; 
            XC_Provisioning_Step__c step;
            for(ExternalWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
                generateInvoice = inputWr.generateInvoice;
                separateInvoice = inputWr.separateInvoice;
                initialTerm = inputWr.initialTerm;
                autoRenew = inputWr.autoRenew;
            }

            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);
            String confItemId;
            List<Id> confItemsIds = new List<Id>();
            List<NE__OrderItem__c> confItems = new List<NE__OrderItem__c>();
            for(ExternalWrapper inputWr : inputWrapperList) {
                step = mapSteps.get(inputWr.stepId);
                orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
                confItemId = inputWr.configurationItemId; //fimperioli 24-12-2019 to manage single configuration item
                stepId = step.Id;
                confItemsIds.add(inputWr.configurationItemId);
                confItems.add(inputWr.item);
                //COMPLETE STEP - Salvatore Scarpato 14/3/2019
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
                provisioningStepsToComplete.add(step); 
            } 
           
            /************* Get item actions and split in two lists *************/
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@manageCreationZquote--> ConfItem: ' +confItemId + ' - generateInvoice: ' +generateInvoice + ' - separateInvoice: ' +separateInvoice);
            ManageCreationWrapper wrCreation = new ManageCreationWrapper();
            wrCreation.stepId = stepId;
            wrCreation.generateInvoice = generateInvoice;
            wrCreation.separateInvoice = separateInvoice;
            wrCreation.confItemId = confItemId;
            wrCreation.initialTerm = initialTerm;
            wrCreation.autoRenew = autoRenew;
            wrCreation.confItemsIds = confItemsIds;
            wrCreation.confItems = confItems;
            manageCreationZquote(wrCreation, mapSteps);
        } 
    } 


    /**
    *@author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    *@date 08/07/2021
    *@description Method to check WBE
    *@param orderId - String
    *@return Map<String, Object>
    */ 
    /*private static Map<String, Object> checkWBE(String orderId) { 
        Map<String, Object> mapResult = new Map<String, Object>();
        // Query OrderItem of Order
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.XC_Segment__c, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
            ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, ' +
            ' NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, ' +
            ' (SELECT Id FROM Assets__r) ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE NE__OrderId__c = :orderId';
        query = query.replace('xc_installation_address__c,','');
        List<NE__OrderItem__c> listOrderItemFiltered = Database.query(String.escapeSingleQuotes(query));
        if(listOrderItemFiltered.isEmpty()) {
            mapResult.put('success', true);
            return mapResult;
        }
        
        // Check if these items must be recalculated:
        Boolean mustRecalculate = false;
        for(NE__OrderItem__c oi : listOrderItemFiltered) {
            Boolean blankFields = String.isBlank(oi.XC_CMCostCenter__c) || String.isBlank(oi.XC_CMProfitCenter__c) || String.isBlank(oi.XC_ProductServiceType__c) || String.isBlank(oi.XC_ProductLine__c) || String.isBlank(oi.XC_Wbe__c);
            Boolean differentValue = false;
            if(!blankFields) {
                if(String.isBlank(oi.NE__Bundle_Configuration__c)) {
                    if(String.isBlank(oi.NE__CatalogItem__c)) {
                        mapResult.put('success', false);
                        mapResult.put('message', 'Missing Catalog Item for Configuration Item ' + oi.Name);
                        return mapResult;
                    }
                    differentValue = oi.NE__CatalogItem__r.XC_CostCenter__c != oi.XC_CMCostCenter__c || oi.NE__CatalogItem__r.XC_ProfitCenter__c != oi.XC_CMProfitCenter__c || oi.NE__CatalogItem__r.XC_ProductServiceType__c != oi.XC_ProductServiceType__c || oi.NE__CatalogItem__r.XC_ProductLine__c != oi.XC_ProductLine__c;
                } else {
                    if(String.isBlank(oi.NE__Bundle_Configuration__r.NE__CatalogItem__c)) {
                        mapResult.put('success', false);
                        mapResult.put('message', 'Missing Catalog Item for Bundle of Configuration Item ' + oi.Name);
                        return mapResult;
                    }
                    differentValue = oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c != oi.XC_CMCostCenter__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c != oi.XC_CMProfitCenter__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c != oi.XC_ProductServiceType__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c != oi.XC_ProductLine__c;
                }
            }
            if(blankFields || differentValue) {
                mustRecalculate = true;
                break;
            }
        }

        // Recalculate WBE:
        List<NE__OrderItem__c> listItemRecalculated = new List<NE__OrderItem__c>();
        if(mustRecalculate && listOrderItemFiltered[0].NE__OrderId__r.XC_Segment__c == 'B2C') {
            listItemRecalculated = recalculateWBE(listOrderItemFiltered);
            if(listItemRecalculated.isEmpty()) {
                mapResult.put('success', false);
                mapResult.put('message', 'Error to recalculate WBE');
                return mapResult;
            }
        } else {
            listItemRecalculated = listOrderItemFiltered;
        }

        // Check missing fields and populate list for WBE Tracking:
        List<String> listWBEs = new List<String>();
        List<String> listCostCenter = new List<String>();
        List<String> listProfitCenter = new List<String>();
        List<String> listProductLine = new List<String>();
        List<String> listProductServiceType = new List<String>();
        String checkBlankValues = XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE').Value__c;
        for(NE__OrderItem__c oi : listItemRecalculated) {
            if(checkBlankValues=='true') {
                /*if(String.isBlank(oi.XC_CMCostCenter__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', 'Missing Cost Center for Configuration Item ' + oi.Id);
                    return mapResult;
                }
                if(String.isBlank(oi.XC_CMProfitCenter__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', 'Missing Profit Center for Configuration Item ' + oi.Id);
                    return mapResult;
                }
                if(String.isBlank(oi.XC_ProductServiceType__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', 'Missing Product Service Type for Configuration Item ' + oi.Id);
                    return mapResult;
                }
                if(String.isBlank(oi.XC_ProductLine__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', 'Missing Product Line for Configuration Item ' + oi.Id);
                    return mapResult;
                }
                if(String.isBlank(oi.XC_Wbe__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', 'Missing WBE for Configuration Item ' + oi.Id);
                    return mapResult;
                }*/
                /*if(String.isBlank(oi.XC_CMCostCenter__c) || String.isBlank(oi.XC_CMProfitCenter__c) || String.isBlank(oi.XC_ProductServiceType__c) || String.isBlank(oi.XC_ProductLine__c) || String.isBlank(oi.XC_Wbe__c)) {
                    mapResult.put('success', false);
                    mapResult.put('message', Label.XC_CL_ProvisioningStep_MissingWBEFields);
                    return mapResult;
                }
            }
            listWBEs.add(oi.XC_Wbe__c);
            listCostCenter.add(oi.XC_CMCostCenter__c);
            listProfitCenter.add(oi.XC_CMProfitCenter__c);
            listProductLine.add(oi.XC_ProductLine__c);
            listProductServiceType.add(oi.XC_ProductServiceType__c);
        }
        
        // Check WBE Tracking:
        String checkWBETracking = XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking').Value__c;
        if(checkWBETracking=='true') {
            List<XC_WbeTracking__c> listWBETracking = new List<XC_WbeTracking__c>([
                SELECT XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_ProductLine__c, XC_ProductService__c
                FROM XC_WbeTracking__c 
                WHERE XC_Status__c          =  :Label.XC_CL_Configuration_Approved  AND
                    XC_Wbe__c             IN :listWBEs                            AND
                    XC_ProfitCenter__c    IN :listProfitCenter                    AND
                    XC_CostCenter__c      IN :listCostCenter                      AND
                    XC_ProductLine__c     IN :listProductLine                     AND
                    XC_ProductService__c  IN :listProductServiceType
            ]);
            if(listWBETracking.isEmpty()) {
                mapResult.put('success', false);
                mapResult.put('message', 'WBE not accepted');
                return mapResult;
            }
            Boolean wbesAccepted = true;
            List<String> listNameItemsNotAccepted = new List<String>();
            for(NE__OrderItem__c oi : listItemRecalculated) {
                Boolean found = false;
                for(XC_WbeTracking__c track : listWBETracking) {
                    if(oi.XC_Wbe__c == track.XC_Wbe__c && oi.XC_CMCostCenter__c == track.XC_CostCenter__c && oi.XC_CMProfitCenter__c == track.XC_ProfitCenter__c && oi.XC_ProductLine__c == track.XC_ProductLine__c && oi.XC_ProductServiceType__c == track.XC_ProductService__c) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    wbesAccepted = false;
                    listNameItemsNotAccepted.add(oi.Id);
                }
            }
            if(!wbesAccepted) {
                mapResult.put('success', false);
                //mapResult.put('message', 'WBE, Profit Center, Cost Center not accepted for item ' + String.join(listNameItemsNotAccepted, ','));
                mapResult.put('message', Label.XC_CL_ProvisioningStep_WBEFieldsNotValid);
                return mapResult;
            }
        }
        mapResult.put('success', true);
        return mapResult;
    }*/


    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 08/07/2021
     * @description Method to check WBE
     * @param orderId - String
     * @return Map<String, Object>
     */ 
    private static Map<String, Object> checkWBE(List<String> ratePlanConfItem) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN checkWBE');
        
        Boolean mustRecalculate = false;
        Map<String, Object> mapResult = new Map<String, Object>();

        // Query OrderItem of Order
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, NE__OrderId__r.XC_Segment__c, ' +
            ' NE__OrderId__r.XC_LegalEntity__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, ' +
            ' NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c, NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.NE__OptyId__r.XC_Company__c, ' +
            ' NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_WbeMode__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_WbeMode__c, ' +
            ' (SELECT Id FROM Assets__r) ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE Id IN :ratePlanConfItem';
        query = query.replace('xc_installation_address__c,','');
        Map<Id, NE__OrderItem__c> listOrderItemFiltered = new Map<Id, NE__OrderItem__c>((List<NE__OrderItem__c>) Database.query(String.escapeSingleQuotes(query)));
        if(listOrderItemFiltered.isEmpty()) {
            mapResult.put('success', true);
            return mapResult;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listOrderItemFiltered: ' + listOrderItemFiltered);

        // Check Legal Entity
        if(String.isBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c) && String.isBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.XC_LegalEntity__c)) {
            System.debug('IN 1');
            mapResult.put('success', false);
            mapResult.put('message', 'Missing Legal Entity');
            return mapResult;
        } else if(String.isBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c) && String.isNotBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.XC_LegalEntity__c)) {
            System.debug('IN 2');
            Opportunity opp = new Opportunity();
            opp.Id = listOrderItemFiltered.values()[0].NE__OrderId__r.NE__OptyId__r.Id;
            opp.XC_LegalEntity__c = listOrderItemFiltered.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            XC_UTIL_SObject.updateRecord(opp);
            mustRecalculate = true;
        } else if (String.isNotBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c) && String.isBlank(listOrderItemFiltered.values()[0].NE__OrderId__r.XC_LegalEntity__c)) {
            System.debug('IN 3');
            NE__Order__c order = new NE__Order__c();
            order.Id = listOrderItemFiltered.values()[0].NE__OrderId__c;
            order.XC_LegalEntity__c = listOrderItemFiltered.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            XC_UTIL_SObject.updateRecord(order);
            mustRecalculate = true;
        }
        
        // Check if these items must be recalculated:
        for(NE__OrderItem__c oi : listOrderItemFiltered.values()) {
            Boolean blankFields = String.isBlank(oi.XC_CMCostCenter__c) || String.isBlank(oi.XC_CMProfitCenter__c) || String.isBlank(oi.XC_ProductServiceType__c) || String.isBlank(oi.XC_ProductLine__c) || String.isBlank(oi.XC_Wbe__c);
            Boolean differentValue = false;
            if(!blankFields) {
                if(String.isBlank(oi.NE__Bundle_Configuration__c)) {
                    if(String.isBlank(oi.NE__CatalogItem__c)) {
                        mapResult.put('success', false);
                        mapResult.put('message', 'Missing Catalog Item');
                        mapResult.put('messageDetails', 'Missing Catalog Item for Configuration Item ' + oi.Name);
                        return mapResult;
                    }
                    differentValue = (oi.NE__CatalogItem__r.XC_CostCenter__c != oi.XC_CMCostCenter__c || oi.NE__CatalogItem__r.XC_ProfitCenter__c != oi.XC_CMProfitCenter__c || oi.NE__CatalogItem__r.XC_ProductServiceType__c != oi.XC_ProductServiceType__c || oi.NE__CatalogItem__r.XC_ProductLine__c != oi.XC_ProductLine__c) &&  (oi.NE__CatalogItem__r.XC_WbeMode__c == null || (oi.NE__CatalogItem__r.XC_WbeMode__c != null && !oi.NE__CatalogItem__r.XC_WbeMode__c.contains('ECA')));
                } else {
                    if(String.isBlank(oi.NE__Bundle_Configuration__r.NE__CatalogItem__c)) {
                        mapResult.put('success', false);
                        mapResult.put('message', 'Missing Catalog Item');
                        mapResult.put('messageDetails', 'Missing Catalog Item for Bundle of Configuration Item ' + oi.Name);
                        return mapResult;
                    }
                    differentValue = (oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c != oi.XC_CMCostCenter__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c != oi.XC_CMProfitCenter__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c != oi.XC_ProductServiceType__c || oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c != oi.XC_ProductLine__c) && (oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_WbeMode__c == null || (oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_WbeMode__c != null && !oi.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_WbeMode__c.contains('ECA')));
                }
            }
            if(blankFields || differentValue) {
                mustRecalculate = true;
                break;
            }
        }

        // Recalculate WBE:
        List<NE__OrderItem__c> listItemRecalculated = new List<NE__OrderItem__c>();
        if(mustRecalculate && listOrderItemFiltered.values()[0].NE__OrderId__r.XC_Segment__c == 'B2C') {
            listItemRecalculated = recalculateWBE(listOrderItemFiltered.values());
            if(listItemRecalculated.isEmpty()) {
                mapResult.put('success', false);
                mapResult.put('message', 'Error to recalculate WBE');
                return mapResult;
            }
            
        } else if (mustRecalculate && listOrderItemFiltered.values()[0].NE__OrderId__r.XC_Segment__c != 'B2C') {
           // listItemRecalculated = recalculateWBEB2BG(listOrderItemFiltered);
           listItemRecalculated = setFieldsOnOIForB2BG(listOrderItemFiltered.values());
            
        } else {
            listItemRecalculated = listOrderItemFiltered.values();
        }

        // Check missing fields and populate list for WBE Tracking:
        List<String> listWBEs = new List<String>();
        List<String> listCostCenter = new List<String>();
        List<String> listProfitCenter = new List<String>();
        List<String> listProductLine = new List<String>();
        List<String> listProductServiceType = new List<String>();
        String checkBlankValues = XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE').Value__c;
        List<String> listItemsBlankValue = new List<String>();
        for(NE__OrderItem__c oi : listItemRecalculated) {
            if(checkBlankValues == 'true') {
                if(String.isBlank(oi.XC_CMCostCenter__c) || String.isBlank(oi.XC_CMProfitCenter__c) || String.isBlank(oi.XC_ProductServiceType__c) || String.isBlank(oi.XC_ProductLine__c) || String.isBlank(oi.XC_Wbe__c)) {
                    listItemsBlankValue.add(oi.Id);
                }
            }

            if(String.isNotBlank(oi.XC_Wbe__c))                 {listWBEs.add(oi.XC_Wbe__c);}
            if(String.isNotBlank(oi.XC_CMCostCenter__c))        {listCostCenter.add(oi.XC_CMCostCenter__c);}
            if(String.isNotBlank(oi.XC_CMProfitCenter__c))      {listProfitCenter.add(oi.XC_CMProfitCenter__c);}
            if(String.isNotBlank(oi.XC_ProductLine__c))         {listProductLine.add(oi.XC_ProductLine__c);}
            if(String.isNotBlank(oi.XC_ProductServiceType__c))  {listProductServiceType.add(oi.XC_ProductServiceType__c);}
        }
        if(!listItemsBlankValue.isEmpty()) {
            mapResult.put('success', false);
            mapResult.put('message', Label.XC_CL_ProvisioningStep_MissingWBEFields);
            mapResult.put('messageDetails', 'Configuration Items: ' + String.join(listItemsBlankValue, ','));
            return mapResult;
        }
        
        // Check WBE Tracking:
        String checkWBETracking = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking').Value__c : 'false';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkWBETracking: ' + checkWBETracking);
        if(checkWBETracking == 'true') {
            String checkWBETrackingBasedOnExcludedCatalog = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog').Value__c : null;
            List<String> catalogsNameForWBETrackingOnly = (checkWBETrackingBasedOnExcludedCatalog != null) ? checkWBETrackingBasedOnExcludedCatalog.split(';') : new List<String>();
            System.debug('listWBEs: ' + listWBEs);
            System.debug('listProfitCenter: ' + listProfitCenter);
            System.debug('listCostCenter: ' + listCostCenter);
            System.debug('listProductLine: ' + listProductLine);
            System.debug('listProductServiceType: ' + listProductServiceType);

            List<XC_WbeTracking__c> listWBETracking = new List<XC_WbeTracking__c>([SELECT XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_ProductLine__c, XC_ProductService__c
                                                                                    FROM XC_WbeTracking__c 
                                                                                    WHERE XC_Status__c          =  :Label.XC_CL_Configuration_Approved  AND
                                                                                        XC_Wbe__c               IN :listWBEs                            AND
                                                                                        XC_ProfitCenter__c      IN :listProfitCenter                    AND
                                                                                        XC_CostCenter__c        IN :listCostCenter                      AND
                                                                                        XC_ProductLine__c       IN :listProductLine                     AND
                                                                                        XC_ProductService__c    IN :listProductServiceType]);
            Boolean wbesAccepted = true;
            List<String> listNameItemsNotAccepted = new List<String>();
            for(NE__OrderItem__c oi : listItemRecalculated) {

                String catalogName = (listOrderItemFiltered.containsKey(oi.Id)) ? listOrderItemFiltered.get(oi.Id).NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c : oi.NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c;
                if(String.isNotBlank(catalogName) && catalogsNameForWBETrackingOnly.contains(catalogName)) {
                    continue;
                }

                Boolean found = false;
                for(XC_WbeTracking__c track : listWBETracking) {
                    if(oi.XC_Wbe__c == track.XC_Wbe__c && oi.XC_CMCostCenter__c == track.XC_CostCenter__c && oi.XC_CMProfitCenter__c == track.XC_ProfitCenter__c && oi.XC_ProductLine__c == track.XC_ProductLine__c && oi.XC_ProductServiceType__c == track.XC_ProductService__c) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    wbesAccepted = false;
                    listNameItemsNotAccepted.add(oi.Id);
                }
            }

            if(!wbesAccepted) {
                mapResult.put('success', false);
                mapResult.put('message', Label.XC_CL_ProvisioningStep_WBEFieldsNotValid);
                mapResult.put('messageDetails', 'Configuration Items: ' + String.join(listNameItemsNotAccepted, ','));
                return mapResult;
            }

        }
        
        mapResult.put('success', true);
        return mapResult;
    }


    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 20/10/2020
     * @description Method to recalculate WBE
     * @param listOrderItemFiltered - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
     */
    private static List<NE__OrderItem__c> recalculateWBE(List<NE__OrderItem__c> listOrderItemFiltered) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN recalculateWBE');

        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : listOrderItemFiltered) {
            mapOrderItem.put(oi.Id, oi);
        }
        List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listOrderItemFiltered);
        XC_TR_Configuration_U_ManageWBE.populateWBEFromBundle(listOrderItemToUpdate);
        Map<Id, NE__OrderItem__c> orderItemsToUpdate = new Map<Id, NE__OrderItem__c>();
        Map<String, NE__OrderItem__c> itemCodeItemMap = new Map<String, NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemsWithRelatedProducts = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oiProcessed : listOrderItemToUpdate) {
            if(String.isNotBlank(oiProcessed.XC_RelatedProduct__c) && String.isBlank(oiProcessed.NE__Bundle_Configuration__c) && String.isBlank(oiProcessed.NE__Root_Order_Item__c)) {
                orderItemsWithRelatedProducts.add(oiProcessed);
            } else {
                NE__OrderItem__c oiToUpdate = new NE__OrderItem__c(Id = oiProcessed.Id,
                                                                    XC_WBE__c = oiProcessed.XC_WBE__c,
                                                                    XC_CMProfitCenter__c = oiProcessed.XC_CMProfitCenter__c,
                                                                    XC_CMCostCenter__c = oiProcessed.XC_CMCostCenter__c,
                                                                    XC_ProductServiceType__c = oiProcessed.XC_ProductServiceType__c,
                                                                    XC_ProductLine__c = oiProcessed.XC_ProductLine__c);
                orderItemsToUpdate.put(oiToUpdate.Id, oiToUpdate);
                if(String.isNotBlank(oiProcessed.NE__Item_Code__c)) {
                    itemCodeItemMap.put(oiProcessed.NE__Item_Code__c, oiToUpdate);
                }
            }
        }
        for(NE__OrderItem__c oiProcessed : orderItemsWithRelatedProducts) {
            NE__OrderItem__c oiToUpdate = new NE__OrderItem__c();
            if(itemCodeItemMap.containsKey(oiProcessed.XC_RelatedProduct__c)) {
                oiToUpdate = new NE__OrderItem__c(Id = oiProcessed.Id,
                                                    XC_WBE__c = itemCodeItemMap.get(oiProcessed.XC_RelatedProduct__c).XC_WBE__c,
                                                    XC_CMProfitCenter__c = itemCodeItemMap.get(oiProcessed.XC_RelatedProduct__c).XC_CMProfitCenter__c,
                                                    XC_CMCostCenter__c = itemCodeItemMap.get(oiProcessed.XC_RelatedProduct__c).XC_CMCostCenter__c,
                                                    XC_ProductServiceType__c = itemCodeItemMap.get(oiProcessed.XC_RelatedProduct__c).XC_ProductServiceType__c,
                                                    XC_ProductLine__c = itemCodeItemMap.get(oiProcessed.XC_RelatedProduct__c).XC_ProductLine__c);
            } else {
                oiToUpdate = new NE__OrderItem__c(Id = oiProcessed.Id,
                                                    XC_WBE__c = oiProcessed.XC_WBE__c,
                                                    XC_CMProfitCenter__c = oiProcessed.XC_CMProfitCenter__c,
                                                    XC_CMCostCenter__c = oiProcessed.XC_CMCostCenter__c,
                                                    XC_ProductServiceType__c = oiProcessed.XC_ProductServiceType__c,
                                                    XC_ProductLine__c = oiProcessed.XC_ProductLine__c);
            }
            orderItemsToUpdate.put(oiToUpdate.Id, oiToUpdate);
        }
        List<XC_UTIL_Sobject.WrapperResult> listOiResults = XC_UTIL_Sobject.updateListRecords(orderItemsToUpdate.values());

        if(XC_UTIL_Sobject.checkDMLResults(listOiResults)) {
            List<Asset> listAssetsToUpdate = new List<Asset>();
            for(NE__OrderItem__c oi : orderItemsToUpdate.values()) {
                for(Asset ass : mapOrderItem.get(oi.Id).Assets__r) {
                    ass.XC_WBE__c = oi.XC_WBE__c;
                    ass.XC_CMProfitCenter__c = oi.XC_CMProfitCenter__c;
                    ass.XC_CMCostCenter__c = oi.XC_CMCostCenter__c;
                    listAssetsToUpdate.add(ass);
                }
            }
            XC_UTIL_Sobject.updateListRecords(listAssetsToUpdate);
        } else {
            return new List<NE__OrderItem__c>();
        }

        return orderItemsToUpdate.values();
    }


    /**
     * @author Nicola Arrigo - narirgo@deloitte.it
     * @date 04/11/2021
     * @description Method to recalculate WBE B2BG
     * @param listOrderItemFiltered - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
     */
    /*private static List<NE__OrderItem__c> recalculateWBEB2BG(List<NE__OrderItem__c> listOrderItemFiltered){
        List<id> odIdList=new List<id>();
        List<id> catalogItemListId=new List<id>();
        for(NE__OrderItem__c oi:listOrderItemFiltered){
            odIdList.add(oi.id);
        }
        List<NE__OrderItem__c> orderItemList=[select id,XC_ProductServiceType__c,NE__CatalogItem__c,XC_ProductLine__c from NE__OrderItem__c 
                                                where id IN:odIdList];
        for(NE__OrderItem__c oi:orderItemList){
            catalogItemListId.add(oi.NE__CatalogItem__c);
        }
        if(catalogItemListId.isEmpty()){
            return orderItemList;
        }                                        
        Map<id,NE__Catalog_Item__c> mapCatalogItems=new Map<id,NE__Catalog_Item__c> ([select id,XC_ProductServiceType__c,XC_ProductLine__c 
                                                                                          from NE__Catalog_Item__c
                                                                                          where id IN: catalogItemListId]); 
        for(NE__OrderItem__c oi:orderItemList){
            if(mapCatalogItems.get(oi.NE__CatalogItem__c)!=null){
                NE__Catalog_Item__c catItem=mapCatalogItems.get(oi.NE__CatalogItem__c);
                oi.XC_ProductServiceType__c=catItem.XC_ProductServiceType__c;
                oi.XC_ProductLine__c=catItem.XC_ProductLine__c;
            }
        }
        update orderItemList;
        return orderItemList;
    }*/


    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @date 04/11/2021
     * @description Method to recalculate WBE B2BG
     * @param listOrderItemFiltered - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
     */
    private static List<NE__OrderItem__c> setFieldsOnOIForB2BG(List<NE__OrderItem__c> listOrderItemFiltered){

        for(NE__OrderItem__c oi : listOrderItemFiltered){
            oi.XC_ProductServiceType__c = (String.isBlank(oi.XC_ProductServiceType__c)) ? oi.NE__CatalogItem__r.XC_ProductServiceType__c : oi.XC_ProductServiceType__c;
            oi.XC_ProductLine__c = (String.isBlank(oi.XC_ProductLine__c)) ? oi.NE__CatalogItem__r.XC_ProductLine__c : oi.XC_ProductLine__c;
        }
        XC_UTIL_SObject.updateListRecords(listOrderItemFiltered);

        return listOrderItemFiltered;
    }


    /**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @date 17/05/2022
     * @description Method to retrieve the effective start date of the balance product. This date, if present, is used to override the star date of the subscription to ensure correct billing of this product as well
     * @param item - NE__OrderItem__c
     * @return Date
     */
    private static Date getBalanceEffectiveDate(NE__OrderItem__c item){

        Date balanceEffectiveStartDate; 
        
        if(item.NE__OrderId__r.XC_LegalEntity__c ==Label.XC_CL_LegalEntity_EnelSole && item.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder
            &&  item.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade && item.XC_BillingModel__c == Label.XC_CL_BillingModel_Recurring){
                List<NE__OrderItem__c>  itemList = XC_IN018_CreateZQuote_D.retrieveConfItemsbyProd(item.id,item.NE__OrderId__c, Label.XC_CL_AdjustmentProdName);
                if(itemList != null && !itemList.isEmpty()){
                    for(NE__OrderItem__c oi : itemList){
                        if(oi.XC_Effective_Start_Date_Recurring__c != null){
                            if(!oi.Assets__r.isEmpty()){
                                balanceEffectiveStartDate = (oi.CreatedDate < oi.Assets__r[0].CreatedDate ) ? oi.XC_Effective_Start_Date_Recurring__c : null;
                            }
                            break;
                        }
                    }
                }
        }
        return balanceEffectiveStartDate; 
    }

}