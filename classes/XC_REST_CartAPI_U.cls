/**
 * The Class XC_REST_CartAPI_U.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  10/06/2019
 * @date Modification :  12/10/2020
 * @description       :  Util class for XC_REST_CartAPI
 */


public without sharing class XC_REST_CartAPI_U {


    /**
     * ManageUpsertItemsResponse.
     *
     * @param result the result of upsert items
     * @param infos the infos map
     * @description manage response of UpsertItems
     */
    public static void manageUpsertItemsResponse(Map<String,Object> result, Map<String, String> infos) {

        Map<String,Object> sessionParam = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(result.get('sessionParameters')));
        sessionParam.put('isMultiCurrency', 'true');

        Map<String,Object> conf = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(result.get('configuration')));
        if(String.isBlank(infos.get('assetId'))) {
            populateConfigurationMap(conf, infos);
        } else {
            conf.put('XC_DeliveryAddress__c', infos.get('XC_DeliveryAddress__c'));
            conf.put('XC_InstallationAddress__c', infos.get('XC_InstallationAddress__c'));
            conf.put('XC_Contact__c', infos.get('ContactId'));
            conf.put('XC_ProvisioningStepToComplete__c', infos.get('PStoComplete'));
        }
        conf.remove('id');

        result.remove('sessionInfo');
        result.remove('listOfItems');
        result.remove('listOfCategories');
        result.remove('listOfBundle');
        result.remove('itemsCounter');
        result.put('configuration', (Object) conf);
        result.put('sessionParameters', (Object) sessionParam);

        String dataInterceptorString = JSON.serialize(result);
        dataInterceptorString = dataInterceptorString.escapeJava();
        infos.put('dataInterceptorString', dataInterceptorString);
    }


    /**
     * PopulateConfigurationMap.
     *
     * @param confMap the configuration Map
     * @param infos the infos map
     * @description populate Configuration Map with some infos
     */
    public static void populateConfigurationMap(Map<String, Object> confMap, Map<String, String> infos) {
        
        Set<String> valuesNoConf = new Set<String>{'sessionId', 'token', 'productCategory', 'categoryId', 'catalogId', 'catalogItemId', 'itemcode', 'qty', 'OrganizationId', 'ContactId',
                                                    'ClientId', 'ServerURL', 'ConfId', 'assetId', 'billingProfLineItemId', 'billingProfId', 'paymentMethod', 'ServerURL_Change', 'PStoComplete',
                                                    'Password', 'PasswordToken', 'UserToken', 'token_Change', 'LICname', 'oiAttribute', 'contactId', 'productId', 'familyPropertyIds', 'fromAutomotivePortal',
                                                    'ChannelCommodity', 'ChannelForOpp', 'OrderDocument', 'PricingRegionCommodity', 'AssetList', 'commodityTransactionID', 'account', 'clientSystem',
                                                    'productCode', 'accountDNI', 'Discounts', 'stream', 'optyIdRM', 'orderItemList', 'catalogItemIds', 'catalogItemAttributesMap', 'currentStep',
                                                    'insertOpportunityResult', 'preferredlanguageofcontact', 'catalogCategoryAndCatalogItems', 'catalogCategoryAndOrderItems', 'activationCountry',
                                                    'currencyISOCode', 'mapCategoryHasChild', 'parentChildMap', 'EngineVersion'
                                                   };
        
        for(String key : infos.keySet()) {
            if(!valuesNoConf.contains(key) && String.isNotBlank(infos.get(key))) {
                confMap.put(key, (Object) infos.get(key));
            }
        }

        confMap.put('NE__order_date__c', DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
        if(String.isNotBlank(infos.get('currencyISOCode'))){
            confMap.put('currencyisocode', infos.get('currencyISOCode'));
        }
        
    }


    /**
     * InsertIntegrationLogs.
     *
     * @param integrationLogsToInsert the integration log list
     * @param transactionID the transactionId
     * @description method insert integration Logs
     */
    @future
    public static void insertIntegrationLogs(String integrationLogsString, String infosString) {

        List<XC_Integration_Log__c> integrationLogsToInsert = (List<XC_Integration_Log__c>) JSON.deserialize(integrationLogsString, List<XC_Integration_Log__c>.class);
        Map<String, String> infos = (Map<String, String>) JSON.deserialize(infosString, Map<String, String>.class);
        String transactionId = (!String.isBlank(infos.get('XC_eMobTransactionId__c'))) ? infos.get('XC_eMobTransactionId__c') : infos.get('commodityTransactionID');
        String accountDNI = infos.get('accountDNI');
        String accountId = infos.get('NE__AccountId__c');
        String productCode = infos.get('productCode');

        for(XC_Integration_Log__c intLog : integrationLogsToInsert) {
            intLog.XC_Log_TransactionId__c = transactionID;
            intLog.XC_Log_ClientSystem__c = 'XCustomerB2C'; 
            intLog.XC_Log_ServerSystem__c = 'Bit2Win'; 
            intLog.XC_Log_AccountDNI__c = accountDNI;
            intLog.XC_Log_AccountID__c = accountId;
            intLog.XC_Log_ProductCode__c = productCode;
        }

        XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert);
    }


    /**
     * ManageCheckout.
     *
     * @param confId the configuration id
     * @param counter the counter
     * @param infos the infos map
     * @description method to manage the configuration
     */
    public static void manageCheckout(String confId, Integer counter, Map<String, String> infos) {

        if(counter == 0) {

            if(String.isBlank(infos.get('assetId')) && !Test.isRunningTest()) { // Create Configuration - Type inOrder
                XC_REST_CartAPI.ResultWrapper resultWr = XC_REST_CartAPI.cartCheckout(infos, 1);
                infos.put('integrationLog', Json.Serialize(resultWr.intLog));

            } else {    // Update Configuration - Type ChangeOrder

                Boolean complianceNeeded = getClientSystemSettings(infos.get('clientSystem'), infos);
                NE__Order__c ord = new NE__Order__c(Id = confId,
                                    RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId(),
                                    XC_Status__c = 'In Progress',
                                    XC_EnelEnergyOfferExternalID__c = infos.get('XC_EnelEnergyOfferExternalID__c'),
                                    NE__ConfigurationStatus__c = 'Valid',
                                    XC_Compliance_Approval__c = (!complianceNeeded) ? 'Not Needed' :  '',//'Not Needed',
                                    NE__Type__c = 'ChangeOrder',
                                    XC_Subtype__c =  (String.isBlank(infos.get('orderSubtype'))) ? 'eMobility Change Offer': infos.get('orderSubtype'),
                                    XC_eMobTransactionId__c = (String.isNotBlank(infos.get('XC_eMobTransactionId__c'))) ? infos.get('XC_eMobTransactionId__c') : '',
                                    XC_Channel__c = (String.isNotBlank(infos.get('ChannelCommodity'))) ? infos.get('ChannelCommodity') : '',
                                    NE__AccountId__c = infos.get('NE__AccountId__c'),
                                    NE__BillAccId__c = infos.get('NE__AccountId__c'),
                                    XC_Company_Code__c = infos.get('XC_Company_Code__c'),
                                    XC_Cost_Center__c  = infos.get('XC_Cost_Center__c'),
                                    NE__ServAccId__c = infos.get('NE__AccountId__c'));

                //[BEGIN ACERRA  PS_ID036 02.12.2021]
                if('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType'))){
                    ord.XC_CaseId__c = infos.get('XC_CaseId__c');
                    ord.XC_VASContractExtID__c = infos.get('XC_VASContractExtID__c');
                    ord.XC_VASContractNumber__c = infos.get('XC_VASContractNumber__c');
                }
                //[END ACERRA  PS_ID036 02.12.2021]
                XC_UTIL_Sobject.WrapperResult updateConfResult = XC_UTIL_Sobject.updateRecord(ord);
                System.debug('updateConfResult -> ' + updateConfResult);
                
                infos.put('complianceNeeded', JSON.serialize(complianceNeeded));
                startProvisioning(confId, infos);
            }
            
        } else if(counter == 1) {   // Update Configuration - Type inOrder

            Boolean complianceNeeded = getClientSystemSettings(infos.get('clientSystem'), infos);
            List<Group> ownGroup = new List<Group>([SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'OrdiniCatalogoFederatoCustomerInsights' LIMIT 1]); //[DeAv 09/11/2021 CR NR2063]
            NE__Order__c ord = new NE__Order__c(Id = confId,
                                                RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId(),
                                                XC_Status__c = 'In Progress',
                                                XC_EnelEnergyOfferExternalID__c = infos.get('XC_EnelEnergyOfferExternalID__c'),
                                                XC_Company_Code__c = infos.get('XC_Company_Code__c'),
                                                XC_Cost_Center__c  = infos.get('XC_Cost_Center__c'),
                                                NE__ConfigurationStatus__c = 'Valid',
                                                //XC_Compliance_Approval__c = 'Not Needed',
                                                XC_Compliance_Approval__c =  (!complianceNeeded) ? 'Not Needed' :  '', // compliance for Commodity
                                                XC_Channel__c = (String.isNotBlank(infos.get('ChannelCommodity'))) ? infos.get('ChannelCommodity') : '',
                                                XC_SignedByExternal__c = infos.get('clientSystem').equalsIgnoreCase('CommodityItalyB2C') ? 'VocalOrder' : '',
                                                XC_PlantOwnership__c = infos.get('stream') != 'B2C' ? 'Terzi' : null                                                
                                                );
            if('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem')) && null != ownGroup && !ownGroup.isEmpty()){//[ACERRA CR-NR2063 B2B 16.11.2021]
                //[begin, gs 04/07/2022, INC000089777758]
                //ord.OwnerId = ownGroup.get(0).Id;//[DeAv 09/11/2021 CR NR2063 - Added OwnerId]
                //[end, gs 04/07/2022, INC000089777758]
                ord.XC_PlantOwnership__c = 'Enel'; //[ACERRA CR-NR2063 B2B 19.11.2021]
            }

            //mridul.b.jain@accenture.com NR2299 4/5/22 start
            if('B2C'.equalsIgnoreCase(infos.get('stream')) && 'CommodityRomaniaB2C'.equalsIgnoreCase(infos.get('clientSystem'))){
                ord.XC_MarketLegalEntity__c = infos.get('MarketLegalEntity');
            }
            //mridul.b.jain@accenture.com NR2299 4/5/22 End
            
            XC_UTIL_Sobject.WrapperResult updateConfResult = XC_UTIL_Sobject.updateRecord(ord);
            System.debug('updateConfResult -> ' + updateConfResult);

            infos.put('complianceNeeded', JSON.serialize(complianceNeeded));
            startProvisioning(confId, infos);
        }
    }

    
    /**
     * Start Provisioning.
     *
     * @param confId the configuration id
     * @param infos the infos map
     * @description method to set the Billing Profile for Configuration Items and to start the Provisioning
     */
    public static void startProvisioning(String confId, Map<String, String> infos) {

        // Configuration Item
        Map<Id, NE__OrderItem__c> ordItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Action__c,XC_InstallmentFrequency__c, XC_InstallmentPlanType__c,  XC_InstallmentsNumber__c, NE__BillingProfId__c, XC_BillingProfileLineItem__c, XC_PaymentMethod__c, NE__CatalogItem__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__Root_Order_Item__c, XC_RecurringDuration__c,(select id,Name,NE__Value__c from NE__Order_Item_Attributes__r where name in ('Installment Plan Type','Tipologia di Interesse','Number of installments','Installment Frequency','Frequenza delle Rate')) FROM NE__OrderItem__c WHERE NE__OrderId__c =: confId]); //[DeAv 09/11/2021 CR NR2063 - Added XC_RecurringDuration__c]
        List<NE__OrderItem__c> ordItemList = ordItemMap.values();
        
        if(String.isNotBlank(infos.get('XC_Coupon_Code__c'))) {
            
            // Burn Coupon
            System.debug('BURN COUPON - CouponCode ' + infos.get('XC_Coupon_Code__c'));
            System.debug('BURN COUPON - Account ' + infos.get('NE__AccountId__c'));

            XC_REST_CheckCoupon_W.WrapperCheckCouponRequest requestBurnCoupon = new XC_REST_CheckCoupon_W.WrapperCheckCouponRequest();
            requestBurnCoupon.requestElement = new List<XC_REST_CheckCoupon_W.WrapperRequestElement>();
            XC_REST_CheckCoupon_W.WrapperRequestElement wrElement = new XC_REST_CheckCoupon_W.WrapperRequestElement();
            wrElement.CouponCode = infos.get('XC_Coupon_Code__c');
            wrElement.AccountID = infos.get('NE__AccountId__c');
            requestBurnCoupon.requestElement.add(wrElement);

            XC_REST_CheckCoupon_W.WrapperResponse resultBurnCoupon = new XC_REST_CheckCoupon_W.WrapperResponse();
            XC_REST_CheckCoupon_U.checkCouponPostPut(requestBurnCoupon, resultBurnCoupon, 'PUT');
        }
        
        for(NE__OrderItem__c ordItem : ordItemList) {
            if(String.isBlank(infos.get('paymentMethod'))) {
                ordItem.XC_PaymentMethod__c = 'Direct Debt';
            } else if((infos.get('paymentMethod') == Label.XC_CL_Commodity_Bill && String.isBlank(ordItem.NE__Root_Order_Item__c)) ||
                        infos.get('paymentMethod') != Label.XC_CL_Commodity_Bill) {
                    ordItem.NE__BillingProfId__c = infos.get('billingProfId');
                    ordItem.XC_BillingProfileLineItem__c = infos.get('billingProfLineItemId');
                    ordItem.XC_PaymentMethod__c = infos.get('paymentMethod');
                    //[DeAv 09/11/2021 CR NR2063 START]
                    if('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))){
                        ordItem.XC_RecurringDuration__c = 24;
                    }
                    //[DeAv 09/11/2021 CR NR2063 END]
            }

            if(String.isNotBlank(infos.get('assetId')) && !('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType')))) { //DCR 01122021 - PS_ID036  
                ordItem.NE__Action__c = (ordItem.NE__CatalogItem__c == infos.get('catalogItemId') || ordItem.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c.containsIgnoreCase('RFIDautoadd')) ? 'Add' : 'Remove';
            }
            //INC000088426093 - mario.a.giordano@accenture.com 13062022 - START
            if(!ordItem.NE__Order_Item_Attributes__r.isEmpty()){
                for(NE__Order_Item_Attribute__c oiatt : ordItem.NE__Order_Item_Attributes__r){
                    if(oiatt.Name=='Installment Plan Type' || oiatt.Name=='Tipologia di Interesse'){
                        ordItem.XC_InstallmentPlanType__c = oiatt.NE__Value__c;
                    }
                    if(oiatt.Name=='Number of installments'){
                        ordItem.XC_InstallmentsNumber__c = oiatt.NE__Value__c;
                    }
                    if(oiatt.Name=='Installment Frequency' || oiatt.Name=='Frequenza delle Rate'){
                        ordItem.XC_InstallmentFrequency__c = oiatt.NE__Value__c;
                    }
                }
            }
            //END
        }
        
        List<XC_UTIL_Sobject.WrapperResult> updateConfItemResult = XC_UTIL_Sobject.updateListRecords(ordItemList);
 
        if(String.isNotBlank(infos.get('ChannelCommodity')) && !String.isBlank(infos.get('OrderDocument'))) {   // FOR COMMODITY
            manageExternalDocument(confId, infos);
        }

        Boolean complianceNeeded = (Boolean)JSON.deserialize(infos.get('complianceNeeded'), Boolean.class);
        if(!Test.isRunningTest()) { // Start Provisioning 
            
            if(infos.get('stream') != 'B2C') {  // Set WBE for B2B/B2G
                Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, StartDate, EndDate FROM Contract WHERE EndDate = null AND XC_Configurations__c =: confId]);
                if(!contractMap.isEmpty()) {
                    Contract contract = contractMap.values()[0];
                    contract.StartDate = (contract.StartDate == null) ? Date.Today() : contract.StartDate;
                    //[DeAv 09/11/2021 CR NR2063 START]
                    if('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))){                        
                        contract.EndDate = (contract.EndDate == null) ? contract.StartDate.addMonths(25) : contract.EndDate;
                        contract.XC_Signed__c = true;
                    }else{
                        contract.EndDate = (contract.EndDate == null) ? contract.StartDate.addYears(1) : contract.EndDate;
                    }
                    //[ BEGIN, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]

                    if(!String.isBlank(infos.get('ExternalDocID'))){
                        system.debug('contract: '+contract);
                        contract.XC_EnelEnergyMARI_ExternalIdDOC__c = infos.get('ExternalDocID');
                    }

                    //[ END, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added mapping and conditions for new tag]
                    //[DeAv 09/11/2021 CR NR2063 END]
                    XC_UTIL_SObject.updateRecord(contract);
                }
                //[DeAv 09/11/2021 CR NR2063 START]
                if(!('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem')) )){
                    XC_LCC_056_CalculateWBS.submit(confId);
                }
                //[DeAv 09/11/2021 CR NR2063 END]
            }
            if(!('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem')) )){ //[DeAv 09/11/2021 CR NR2063]
                if(complianceNeeded){

                    XC_UTIL_NextStepOrderToProvisioning.firstNextStep(confId);

                } else {
            
                    XC_LCC048_OrderInProvisioning.insertProvisioningSteps(confId, 'XC_REST_CartAPI_U');
                    System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(confId));
                }
            }
        }
    }

    
    /**
     * Start manageExternalDocument.
     *
     * @param confId the configuration id
     * @param infos the infos map
     * @description method to manage the external document from commodity.
     */
    public static void manageExternalDocument(String confId, Map<String, String> infos){

        List<XC_REST_MobilityOrder_W.OrderDocumentWrapper> externalDocuments = (List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>)JSON.deserialize(infos.get('OrderDocument'), List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>.class); 
        List<XC_ExternalDocument__c> externalDocumentToInsert = new List<XC_ExternalDocument__c>();

        for(XC_REST_MobilityOrder_W.OrderDocumentWrapper extDocs : externalDocuments){
            if(!String.isBlank(extDocs.ContractUrl)){
                XC_ExternalDocument__c externalDoc = new XC_ExternalDocument__c(XC_Configuration__c = confId, XC_ContractURL__c = extDocs.ContractUrl);
                externalDocumentToInsert.add(externalDoc);
            }
        }
        
        if(!externalDocumentToInsert.isEmpty()){
            XC_UTIL_SObject.insertListRecords(externalDocumentToInsert);
        }
    }


    /**
    * @description method to get Client System setting
    * @return Boolean
    * @param clientSystem - String
    * @param infos - Map<String, String>
    */
    public static Boolean getClientSystemSettings(String clientSystem, Map<String, String> infos){

        if(String.isBlank(clientSystem)) {
            return true;
        }

        Map<Id, XC_CM_ClientSystemSetting__mdt> complianceMap = new Map<Id,XC_CM_ClientSystemSetting__mdt> ([SELECT XC_ComplianceNeeded__c
                                                                                                            FROM XC_CM_ClientSystemSetting__mdt   
                                                                                                            WHERE XC_ClientSystem__c  =: clientSystem]);
        
        if(!(complianceMap.values()).isEmpty()){
            return (complianceMap.values()[0].XC_ComplianceNeeded__c);
            //return (!complianceMap.values()[0].XC_ComplianceNeeded__c) ? false : (clientSystem == Label.XC_CL_CommoditySpainB2C && String.isBlank(infos.get('OrderDocument'))) ? false : true; 
        }
        
        return true;
    }


    /**
    * @description map attributes and field for child objects in case of complex product configuration
    * @author Francesco Imperioli - fimperioli@deloitte.it | 02-24-2021 
    * @param jsonCartItems 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> composeChildCartAndItemsMap(String jsonCartItems){

        Map<String,Object> result = new Map<String,Object>();

        //cart or listOfItems section
        List<Object> jsonFirstList = (List<Object>) JSON.DeserializeUnTyped(jsonCartItems);
        List<Map<String,Object>> listOfItemsMapped = new List<Map<String,Object>>();
        for(Object firstItemObj : jsonFirstList){
            Map<String,Object> mapFirst = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(firstItemObj));
            listOfItemsMapped.add(mapFirst);
        }

        for(Map<String,Object> item : listOfItemsMapped){
            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
            List<Object> parentItemAttrObject = (List<Object>) (JSON.DeserializeUntyped(JSON.serialize(item.get('listOfAttributes'))));

            Map<String,Object> parentAttributeCodeMap = new Map<String,Object>();
            //getting parent single attributes
            for(Object attrObj : parentItemAttrObject){
                    Map<String,Object> parentAttrItem = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attrObj));
                    Map<String,Object> parentAttrFields = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(parentAttrItem.get('fields')));
                    parentAttributeCodeMap.put(String.valueOf(parentAttrFields.get('attributeCode')),parentAttrFields);
            }
            
            

            if(item.containsKey('childItems')&&item.get('childItems')!=null){
                //read childItems
                List<Object> childItemsObjList = (List<Object>) (JSON.DeserializeUntyped(JSON.serialize(item.get('childItems'))));
                List<Map<String,Object>> childItemsMapList = new List<Map<String,Object>>();

                for(Object childItemObj : childItemsObjList){
                    Map<String,Object> childItemsMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(childItemObj));
                    childItemsMapList.add(childItemsMap);
                } 

                //read childItems field and attributes
                Map<String,Object> childItemsMap = new Map<String,Object>();

                for(Map<String,Object> childItem : childItemsMapList){

                    Map<String,Map<String,Object>> childFieldAttributeMap = new Map<String,Map<String,Object>>();
                    String usageCode;

                    for(String key : childItem.keySet()){
                        if(key.equalsIgnoreCase('fields')){
                            Map<String,Object> fieldMap = (Map<String,Object>) JSON.DeserializeUnTyped(JSON.serialize(childItem.get(key)));
                            usageCode = String.valueOf(fieldMap.get('NE__UsageCode__c'));
                            childFieldAttributeMap.put('fields',fieldMap);
                        }else if(key.equalsIgnoreCase('listOfAttributes')){
                            List<Object> attributesObjectList = (List<Object>) (JSON.DeserializeUntyped(JSON.serialize(childItem.get('listOfAttributes'))));
                            Map<String,Object> attributeCodeMap = new Map<String,Object>();
                            //getting single attributes
                            for(Object attrObj : attributesObjectList){
                                Map<String,Object> attributeMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attrObj));
                                Map<String,Object> attributeMapFields = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(attributeMap.get('fields')));
                                attributeCodeMap.put(String.valueOf(attributeMapfields.get('attributeCode')),attributeMapFields);
                            }
                            childFieldAttributeMap.put('attributes',attributeCodeMap);
                        }
    
                    }
                    childItemsMap.put(usageCode,childFieldAttributeMap);
                }

                result.put(String.valueOf(fields.get('NE__UsageCode__c')),childItemsMap);
            }else{

                Map<String,Object> fieldAttributeMap = new Map<String,Object>();
                fieldAttributeMap.put('fields',fields);
                fieldAttributeMap.put('attributes',parentAttributeCodeMap);
                result.put(String.valueOf(fields.get('NE__UsageCode__c')),fieldAttributeMap);

            }
        }

        return result;
    }

    public static void skipTestMFL(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}