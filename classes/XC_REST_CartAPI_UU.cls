/**
 * The Class XC_REST_CartAPI_UU.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  16/06/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  Util class for XC_REST_CartAPI
 */


public without sharing class XC_REST_CartAPI_UU {
	

    /**
     * CalcutaleCommodityBodyForRetrieveCatalogs.
     *
     * @param infos the infos map
     * @param conf the conf map
     * @description calculate body for Commodity Retrieve Catalogs
     */
    public static String calcutaleCommodityBodyForRetrieveCatalogs(Map<String, String> infos, Map<String, Object> confMap) {

        Map<String,String> assetMap = new Map<String,String>{'addressID' => 'XC_Address__c',
                                                            'assetProductCategory' => 'XC_Product_Catalog_Category__c',
                                                            'bundleid' => 'NE__Bundle__c', 
                                                            'catalogCategoryId' => 'NE__CatalogItem__r.NE__Catalog_Category_Name__c', 
                                                            'catalogId' => 'NE__Catalog__c', 
                                                            'catalogItemId' => 'NE__CatalogItem__c', 
                                                            'coverageassettype' => 'XC_Coverage_Asset_Type__c', 
                                                            'id' => 'id', 
                                                            'name' => 'Name', 
                                                            'NE_Description' => 'NE__Description__c', 
                                                            'ParentAssetId' => 'NE__Parent_Order_Item__c', 
                                                            'productid' => 'NE__ProdId__c', 
                                                            'productsubtype' => 'XC_Product_Subtype__c', 
                                                            'producttype' => 'XC_Product_Type__c', 
                                                            'Status' => 'NE__Status__c', 
                                                            'usagecode' => 'NE__UsageCode__c'
                                                            };

        List<Asset> assetList = (List<Asset>) Json.deserialize (infos.get('AssetList'), List<Asset>.class); 

        String node = '';
        for(Asset ass : assetList) {

            Map<String,String> fieldAsset = new Map<String,String>();
            for(String key : assetMap.keySet()){ 
                if(assetMap.get(key).contains('NE__CatalogItem__r')){
                    fieldAsset.put(key, ass.NE__CatalogItem__r.NE__Catalog_Category_Name__c);
                }else {
                    if(key == 'usagecode' && String.isBlank((String)ass.get(assetMap.get(key)))){
                        fieldAsset.put(key, ass.NE__CatalogItem__r.NE__UsageCode__c);
                    }else {
                        fieldAsset.put(key, (String)ass.get(assetMap.get(key)));
                    }
                }
            }
            node = node + JSON.serialize(fieldAsset) + ',';
        }
        
        node = node.removeEnd(',');

        Account acc = (Account)JSON.deserialize(infos.get('account'), Account.class); 
        confMap.put('NE__order_date__c', DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200');

        Map<Id, XC_CM_LanguageZuoraMapping__mdt> languageFromCM;
        if (!String.isBlank(infos.get('preferredlanguageofcontact'))){
            languageFromCM =  new Map<Id, XC_CM_LanguageZuoraMapping__mdt> ([SELECT XC_NELanguage__c FROM XC_CM_LanguageZuoraMapping__mdt WHERE XC_Invoice_Language__c =: infos.get('preferredlanguageofcontact') LIMIT 1]);
        }
        String language = (String.isBlank(infos.get('preferredlanguageofcontact'))) ? 'en_US' : ((languageFromCM != null && !languageFromCM.isEmpty())  ? languageFromCM.values()[0].XC_NELanguage__c : 'en_US');
        //DCR BEGIN 10112021 - NR2063
        String body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"' + language + '","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{'+(('B2B'.equalsIgnoreCase(infos.get('stream')) && 'CommodityItalyB2C'.equalsIgnoreCase(infos.get('clientSystem'))) ? '"country":"'+ acc.Country__c +'",' : '') +'"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_legalentity":"'+confMap.get('XC_LegalEntity__c')+'", "address" : "' + confMap.get('XC_DeliveryAddress__c') + '", "PricingRegion": "' + infos.get('PricingRegionCommodity') + '", "XC_IsEmployee": "' + acc.XC_IsEmployee__c + '"' + ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ',"currencyIsoCode": "' + infos.get('currencyISOCode') +'"' : '' ) + ((String.isNotBlank(infos.get('CalcPriceList'))) ?  ',"CalcPriceList": "' + infos.get('CalcPriceList') +'"' : '' ) + '}, "account":{"AccntId":"' + acc.Id + '","XC_AccountType":"' + acc.Account_Type__c + '","rtDeveloperName":"' + acc.XC_RecordTypeDeveloperName__c + '"}, "customasset":[' + node + '],"sessionparameter":[{"name":"UserChannel","value":"Commodity Partner"}, {"name":"sourcePlatform","value":"' + ((String.isNotBlank(infos.get('getFullStructure'))) ? 'Portal' : 'CRM') + '"}' +  ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ', {"name":"confcurrency","value":""}' : '' ) + ']}}}';
        //String body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"' + language + '","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"country":"Italy","createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_legalentity":"'+confMap.get('XC_LegalEntity__c')+'", "address" : "' + confMap.get('XC_DeliveryAddress__c') + '", "PricingRegion": "' + infos.get('PricingRegionCommodity') + '", "XC_IsEmployee": "' + acc.XC_IsEmployee__c + '"' + ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ',"currencyIsoCode": "' + infos.get('currencyISOCode') +'"' : '' ) + ((String.isNotBlank(infos.get('CalcPriceList'))) ?  ',"CalcPriceList": "' + infos.get('CalcPriceList') +'"' : '' ) + '}, "account":{"AccntId":"' + acc.Id + '","XC_AccountType":"' + acc.Account_Type__c + '","rtDeveloperName":"' + acc.XC_RecordTypeDeveloperName__c + '"}, "customasset":[' + node + '],"sessionparameter":[{"name":"UserChannel","value":"Commodity Partner"}, {"name":"sourcePlatform","value":"' + ((String.isNotBlank(infos.get('getFullStructure'))) ? 'Portal' : 'CRM') + '"}' +  ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ', {"name":"confcurrency","value":""}' : '' ) + ']}}}';
        //DCR END 10112021 - NR2063
        //String body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"' + language + '","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_legalentity":"'+confMap.get('XC_LegalEntity__c')+'", "address" : "' + confMap.get('XC_DeliveryAddress__c') + '", "PricingRegion": "' + infos.get('PricingRegionCommodity') + '", "XC_IsEmployee": "' + acc.XC_IsEmployee__c + '"' + ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ',"currencyIsoCode": "' + infos.get('currencyISOCode') +'"' : '' ) + ((String.isNotBlank(infos.get('CalcPriceList'))) ?  ',"CalcPriceList": "' + infos.get('CalcPriceList') +'"' : '' ) + '}, "account":{"AccntId":"' + acc.Id + '","XC_AccountType":"' + acc.Account_Type__c + '","rtDeveloperName":"' + acc.XC_RecordTypeDeveloperName__c + '"}, "customasset":[' + node + '],"sessionparameter":[{"name":"UserChannel","value":"Commodity Partner"}, {"name":"sourcePlatform","value":"CRM"}' +  ((String.isNotBlank(infos.get('currencyISOCode'))) ?  ', {"name":"confcurrency","value":""}' : '' ) + ']}}}';

        return body;
    }


    /**
     * PopulateItemsForUpsertItems.
     *
     * @param infos the infos map
     * @description populate node itemToAdd for UpsertItems
     */
    public static String populateItemsForUpsertItems(Map<String, String> infos) {

        String itemsToUpsert = '';

        if(String.isNotBlank(infos.get('familyPropertyIds'))) {     // FOR Commodity
            itemsToUpsert = populateItemsForCommodity(infos);
        //DCR BEGIN 25112021 - PS_ID036    
        }else if('Change Order'.equalsIgnoreCase(infos.get('OrderType')) && 'Promocode Application'.equalsIgnoreCase(infos.get('OrderSubType'))){
            itemsToUpsert = populateItemsForPriceQuotas(infos);
        //DCR END 25112021 - PS_ID036  
        }else if(String.isNotBlank(infos.get('orderItemList'))) {  // FOR eMobility inOrder
            itemsToUpsert = populateItemsForMobility(infos);
        }
        else {                                                    // FOR eMobility ChangeOrder
            itemsToUpsert = '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"}}]';
        }

        return itemsToUpsert;
    }


    /**
     * PopulateItemsForCommodity.
     *
     * @param infos the infos map
     * @param listOfAttributes the attribute list
     * @description populate items for Commodity
     */
    public static String populateItemsForCommodity(Map<String, String> infos) {

        Map<String, String> familyPropertyIds = (Map<String, String>) JSON.deserialize(infos.get('familyPropertyIds'), Map<String, String>.class);

        Map<String, Object> catalogItemAttributesMap = (Map<String, Object>) JSON.deserializeUntyped(infos.get('catalogItemAttributesMap'));
        List<Object> attributes = (List<Object>) catalogItemAttributesMap.get(infos.get('catalogItemId'));
        List<Map<String, Object>> listOfAttributes = new List<Map<String,Object>>();
        for(Object obj : attributes) {
            Map<String,Object> attribute = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            listOfAttributes.add(attribute);
        }
            
        String nodeAttr = '';
        List<Map<String, Object>> attributeList = new List<Map<String, Object>>();
        for(Map<String, Object> attr : listOfAttributes) {
            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attr.get('fields')));
            String id = (String) fields.get('id');
            
            if(String.isNotBlank(familyPropertyIds.get(id))) {
                fields.put('value', familyPropertyIds.get(id));
                attributeList.add(fields);
                nodeAttr = nodeAttr +  '{"fields":' + JSON.serialize(fields) + '},';
            }      
        }
        
        nodeAttr = nodeAttr.removeEnd(',');

        String nodeItems = '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"' + (String.isNotBlank(infos.get('itemCode')) ?  ',"itemCode": "' + infos.get('itemCode') +'"' : '' ) +'}' + (attributeList.isEmpty() ? '' : ',"listOfAttributes": [' + nodeAttr + ']') + '}]';
        //String nodeItems = (attributeList.isEmpty()) ? '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"}}]' : '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"},"listOfAttributes": [' + nodeAttr + '] }]';

        return nodeItems;
    }


    /**
     * PopulateItemsForMobility.
     *
     * @param infos the infos map
     * @param listOfAttributes the attribute list
     * @description populate items for Commodity
     */
    public static String populateItemsForMobility(Map<String, String> infos) {

        String nodeItems = '"itemsToAdd":[';

        List<XC_REST_MobilityOrder_W.OrderItemWrapper> orderItemList = (List<XC_REST_MobilityOrder_W.OrderItemWrapper>) JSON.deserialize(infos.get('orderItemList'), List<XC_REST_MobilityOrder_W.OrderItemWrapper>.class);
        for(XC_REST_MobilityOrder_W.OrderItemWrapper oiWr : orderItemList) {
            nodeItems += '{"fields":{"id":"' + oiWr.CatalogItemID + '","qty": "' + oiWr.Quantity +'","addAndConfigure": true}';

            String nodeAttr = '';
            if(oiWr.Attribute != null && !oiWr.Attribute.isEmpty()) {

                Map<String, Object> catalogItemAttributesMap = (Map<String, Object>) JSON.deserializeUntyped(infos.get('catalogItemAttributesMap'));
                List<Object> attributes = (List<Object>) catalogItemAttributesMap.get(oiWr.CatalogItemID);
                List<Map<String, Object>> listOfAttributes = new List<Map<String,Object>>();
                for(Object obj : attributes) {
                    Map<String,Object> attribute = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                    listOfAttributes.add(attribute);
                }

                for(XC_REST_MobilityOrder_W.WrapperAttribute attrWr : oiWr.Attribute) {
                    List<Map<String, Object>> attributeList = new List<Map<String, Object>>();
                    for(Map<String, Object> attr : listOfAttributes) {
                        Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attr.get('fields')));
                        String id = (String) fields.get('id');
                        
                        if(id == attrWr.ProductFamilyPropertyID) {
                            fields.put('value', attrWr.Value);
                            attributeList.add(fields);
                            nodeAttr = nodeAttr +  '{"fields":' + JSON.serialize(fields) + '},';
                        }      
                    }
                }
                nodeAttr = nodeAttr.removeEnd(',');
            }

            nodeItems += (String.isBlank(nodeAttr)) ? '},' : ',"listOfAttributes":[' + nodeAttr + ']},';
        }

        nodeItems = nodeItems.removeEnd(',');
        nodeItems += ']';

        return nodeItems;
    }


    /**
     * GetItemDiscount.
     *
     * @param result the result of retrieve items
     * @param infos the map infos
     * @description util method to get item discount information
     */
    public static void getItemDiscount(Map<String,Object> result, Map<String, String> infos) {

        List<Object> cart = (List<Object>) result.get('cart');
        List<Map<String,Object>> listOfCartItem = new List<Map<String,Object>>();
        for(Object obj : cart) {
            Map<String,Object> cartItem = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            listOfCartItem.add(cartItem);               
        }

        for(Map<String,Object> item : listOfCartItem) {
            
            List<Object> listOfChildItems = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('childItems')));
            List<Map<String,Object>> listOfChildItem = new List<Map<String,Object>>();
            for(Object obj : listOfChildItems) {
                Map<String,Object> childItem = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                listOfChildItem.add(childItem);               
            }

            for(Map<String,Object> childItem : listOfChildItem){
                List<Object> listOfAttributes = (List<Object>) JSON.deserializeUntyped(Json.serialize(childItem.get('listOfAttributes')));
                Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(childItem.get('fields')));
                if(fields.get('LicProductName') == 'Promocion' && fields.get('XC_Product_Type__c') == 'Billing' && fields.get('XC_Product_Subtype__c') == 'Promotion') {
                    infos.put('fieldsDiscount', '"fields":' + JSON.serialize(fields));
                    infos.put('listOfAttributesDiscount', JSON.serialize(listOfAttributes));
                    break;
                } 
            }
        }    
    }
    

    /**
     * CalcutaleCommodityBodyForRetrieveCatalogs.
     *
     * @param infos the infos map
     * @param conf the conf map
     * @description calculate body for Commodity Retrieve Catalogs
     */
    public static String calcutaleBodyForUpsertItemsDiscount(Map<String, String> infos) {

        String node1 = '"sessionInfo":{"Id":"' +infos.get('sessionId') + '"}';
        String node2 = '"sessionParameters":{}';
        String node3 = '"page":""';
        String node4 = '"language":"en_US"';
        String node5 = '"complexProductId":""';
        String node6 = '"categoryId":""';
        String node7 = '"catalogId":"' + infos.get('catalogId') + '"';
        String node8 = '"additionalData":{}';
        String node9 = '';
        String node10 = '';

        List<XC_REST_MobilityOrder_W.WrapperDiscount> discounts = (List<XC_REST_MobilityOrder_W.WrapperDiscount>)JSON.deserialize(infos.get('Discounts'), List<XC_REST_MobilityOrder_W.WrapperDiscount>.class); 
        /*List<String> discountValues = new List<String>{};
        for(XC_REST_MobilityOrder_W.WrapperDiscount discount : discounts){
            discountValues.add(discount.Code); 
        }*/

        // create a string to search the discount code through the cartAPI
        String discountCode = discounts[0].Code + ' ' + Integer.ValueOf(discounts[0].RecurringValue) + discounts[0].Type;
        infos.put('discountCode', discountCode);

        node9 = infos.get('fieldsDiscount');
        List<Object> attributes = (List<Object>) JSON.deserializeUntyped(infos.get('listOfAttributesDiscount'));
        List<Map<String, Object>> listOfAttributes = new List<Map<String,Object>>();
        for(Object obj : attributes) {
            Map<String,Object> attribute = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            listOfAttributes.add(attribute);
        }

        List<String> nodesList = new List<String>();     
        List<Map<String, Object>> attributeList = new List<Map<String, Object>>();
        Boolean discountFound = false;

        for(Map<String, Object> attr : listOfAttributes) {
            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attr.get('fields')));
            String licName = (String) fields.get('LicName');
            List<Object> domains = (List<Object>) attr.get('listOfDomains');
            List<Map<String,Object>> listOfDomains = new List<Map<String,Object>>();
            for(Object obj : domains) {
                Map<String,Object> domain = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                listOfDomains.add(domain);               
            }

            //for(Integer i=0; i<discountValues.size(); i++) { 
            if(licName == 'Tipo promocion'){
                for(Map<String,Object> domain : listOfDomains) {
                    Map<String, Object> domainFields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(domain.get('fields')));
                    if((String)domainFields.get('LicName') == discountCode && (String)domainFields.get('eligible') == 'Y'){
                        fields.put('value', discountCode);
                        attributeList.add(fields);
                        nodesList.add ('{"fields":' + JSON.serialize(fields) + '}');
                        break;
                    }
                }
            }
            //}    
            if(discountFound){
                break;
            }
        }

        String body;
        if(nodesList.isEmpty()){
            body = '';

        } else {
            for(Integer i=0; i<nodesList.size(); i++) {
                node10 = node10 + '{' + node9 + ', "listOfAttributes": [' + nodesList[i] + ']},';
            }
            node10 = node10.removeEnd(',');
            body = '{"upsertItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + '"itemsToAdd": [' + node10 + ']},"options":{' + ((String.isNotBlank(infos.get('EngineVersion'))) ? '"engineVersion":"' + infos.get('EngineVersion') + '",' : '') + '"GetStructure":false,"GetAllData":false,"userLanguage":"en_US"}}';
        }

        return body;
    }


    /**
     * createIntegrationLogForDiscountError.
     *
     * @param infos the map infos
     * @return integration log
     * @description method to create an integration log for discount error. We don't call B2W Upsert Item API.
     */
    public static XC_Integration_Log__c createIntegrationLogForDiscountError(Map<String, String> infos){
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logTransactionID = infos.get('commodityTransactionID');
        logWrapper.logIntegrationName = 'B2W_UpsertItemsDiscount';
        logWrapper.logEndpoint = ''; 
        logWrapper.httpMethod = '';
        logWrapper.logMessage = '';
        logWrapper.clientSystem = 'XCustomerB2C'; 
        logWrapper.serverSystem = 'Bit2Win'; 
        logWrapper.accountId = infos.get('NE__AccountId__c');
        logWrapper.productCode = infos.get('productCode');
        logWrapper.accountDNI = infos.get('accountDNI');                
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
        intLog.insertIntegReqOutboundLog(logWrapper);
        List<XC_REST_MobilityOrder_W.WrapperDiscount> discounts = (List<XC_REST_MobilityOrder_W.WrapperDiscount>)JSON.deserialize(infos.get('Discounts'), List<XC_REST_MobilityOrder_W.WrapperDiscount>.class); 
        return XC_UTIL_RESTCallout.getResponseLoggingError(intLog, 'DiscountCode ' + infos.get('discountCode') + ' not found or not elegible for the product ' + infos.get('productCode'))[0];
       
    }


    /**
     * updateQueuedRequestStep.
     *
     * @param infos the map infos
     * @param status the status
     * @param cartApiName the cartApiName
     * @description method to update the queued request step - FOR MARKET
     */
    public static void updateQueuedRequestStep(Map<String, String> infos, String status, String cartApiName){

        XC_UTIL_Sobject.WrapperResult wrResult = (!String.isBlank(infos.get('wrResult'))) ? (XC_UTIL_Sobject.WrapperResult)JSON.deserialize(infos.get('wrResult'), XC_UTIL_Sobject.WrapperResult.class): new XC_UTIL_Sobject.WrapperResult();
        XC_QueuedRequestStep__c currentStep = (XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class); 
        currentStep.XC_Status__c = status;
        currentStep.XC_ExecutionResponse__c = (status == Label.XC_CL_Step_CompletedKO) ?  '{"Result": {"Message": "Error on CartAPI ' + cartApiName + '","ErrorCode": "500"}}' : '{"Result": {"Message": "Operation completed successfully","ErrorCode": "0"}}';
        currentStep.XC_ErrorMessage__c = (status == Label.XC_CL_Completed_OK) ? '' : ((!wrResult.success) ? 'INTERNAL ERROR. TransactionID: ' + infos.get('commodityTransactionID') + '. ' + wrResult.errorMessage : 'Error on CartAPI with transactionID: ' + infos.get('commodityTransactionID')) + ((!String.isBlank(infos.get('LogError'))) ? '\n Error: ' + infos.get('LogError') : '');
        currentStep.XC_RelatedRecordsIds__c = !String.isBlank(infos.get('confId')) ? infos.get('confId') : null;
        XC_UTIL_Sobject.updateRecord(currentStep);
    }


    /**
     * deleteOpportunity.
     *
     * @param opportunityId the opportunity id
     * @description method to delete the opportunity - FOR MARKET
     */
    public static XC_UTIL_Sobject.WrapperResult deleteOpportunity(String opportunityID){
        
        return XC_UTIL_Sobject.deleteRecord(new Opportunity(Id = opportunityID));

    }


    /**
     * deleteSObject.
     *
     * @param sobjectID the sobject id
     * @param infos the infos map
     * @description method to delete the sobject - FOR MARKET
     */
    public static XC_UTIL_Sobject.WrapperResult deleteSObject(Id sObjectId, Map<String,String> infos){
        
        XC_UTIL_Sobject.WrapperResult wrResult = new  XC_UTIL_Sobject.WrapperResult();
        
        if(sObjectId != null){
            sObject sObj = sObjectId.getSobjectType().newSobject(sObjectId);
            wrResult = XC_UTIL_Sobject.deleteRecord(sObj);
            infos.put('wrResult', JSON.serialize(wrResult));
        }
        
        return wrResult;

    }


    /**
     * manageRollback.
     *
     * @param objectToDeleteName the object name to delete
     * @param infos the infos map
     * @param cartAPIName the name of the cartAPI
     * @description method to manage rollback for UniqueService
     */
    public static void manageRollback(Map<String,String> infos, String objectToDeleteName, String cartAPIName){
        if(!String.isBlank((Id) infos.get(objectToDeleteName))){
            XC_REST_CartAPI_UU.deleteSObject((Id) infos.get(objectToDeleteName), infos);
        }
        XC_REST_CartAPI_UU.updateQueuedRequestStep(infos, Label.XC_CL_Step_CompletedKO, cartAPIName);
        XC_UTIL_QueuedRequestStep.skipNotCallbackSteps((XC_QueuedRequestStep__c)JSON.deserialize(infos.get('currentStep'), XC_QueuedRequestStep__c.class));
    }


    /**
    * populateItemsToRemove.
    *
    * @param infos the infos map
    * @description populate items to remove
    */
    public static String populateItemsToRemove(Map<String, String> infos) {

        String nodeItems = '"itemsToRemove":[';

        Set<String> itemsToRemove = (infos.get('itemsToRemove') != null) ? (Set<String>) JSON.deserialize(infos.get('itemsToRemove'), Set<String>.class) : new Set<String>();

        for(String itemToRemoveCode : itemsToRemove) {
            nodeItems += '{"fields":{"itemCode":"' + itemToRemoveCode + '"}},';
        }

        nodeItems = nodeItems.removeEnd(',');
        nodeItems += ']';

        return nodeItems;
    }

    /**
    * PrepareInfosToRemove.
    *
    * @param infos the map infos
    * @return resultwrapper 
    * @description util method to prepare infos to remove product
    */
    public static XC_REST_CartAPI.ResultWrapper prepareInfosToRemove(Map<String, String> infos){
        
        XC_REST_CartAPI.ResultWrapper resultWr = new XC_REST_CartAPI.ResultWrapper();

        Map<String,XC_UTIL_Order.OrderItemWrapper> itemsToRemoveMap = (Map<String,XC_UTIL_Order.OrderItemWrapper>) JSON.deserialize(infos.get('itemsToRemoveMap'), Map<String,XC_UTIL_Order.OrderItemWrapper>.class);
        List<Object> itemsObjList = (List<Object>) JSON.deserializeUntyped(infos.get('retrieveItemFullResult'));
        Map<String,String> usageCodeItemCodeMap = new Map<String,String>();
        Set<String> itemsToRemove = new Set<String>();
        Set<String> itemsToRemoveNotFound = new Set<String>();
        List<Map<String,Object>> itemsMapList = new List<Map<String,Object>>();
        for(Object obj : itemsObjList) {
            Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            itemsMapList.add(item);
        }

        for(Map<String,Object> item : itemsMapList){

            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
            if(!String.isBlank(String.valueOf(fields.get('NE__UsageCode__c'))) && !String.isBlank(String.valueOf(fields.get('itemCode')))){
                usageCodeItemCodeMap.put(String.valueOf(fields.get('NE__UsageCode__c')), String.valueOf(fields.get('itemCode')));
            }
        }

        for(String itemUsageCode : itemsToRemoveMap.keySet()){
            if(usageCodeItemCodeMap.get(itemUsageCode) != null){
                itemsToRemove.add(usageCodeItemCodeMap.get(itemUsageCode));
            }else{
                itemsToRemoveNotFound.add(itemUsageCode);
            }
        }
        

        infos.put('itemsToRemove',JSON.serialize(itemsToRemove));
        infos.put('itemsToRemoveNotFound',JSON.serialize(itemsToRemoveNotFound));
        infos.put('removalAlreadyProcessed', 'Y');

        if(!itemsToRemoveNotFound.isEmpty()){
            
            String errorMessage = '[XCustomer] Product to be removed not found. Missing the following products: ' + itemsToRemoveNotFound;
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
            logWrapper.logTransactionID = infos.get('commodityTransactionID');
            logWrapper.logIntegrationName = 'B2W_RemoveItems';
            logWrapper.clientSystem = 'XCustomerB2C';
            logWrapper.serverSystem = 'Bit2Win';              
            XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
            intLog.insertIntegReqOutboundLog(logWrapper);
            resultWr.intLog = (XC_UTIL_RESTCallout.getResponseLoggingError(intLog, errorMessage))[0];
            resultWr.success = false;
            infos.put('LogError', errorMessage);
            return resultWr;
        }

        resultWr.success = true;
        return resultWr;
        
    }


    

    /**
    * Configure Upsert ChildBody.
    *
    * @param infos the infos map
    * @return the status of response
    * @description call to configure body for upsertitems Bit2Win API for child item
    */
    public static String configureUpsertChildBody(Map<String, String> infos){

        String jsonCartItems = infos.get('upsertItemFullResult');
        String listOfItems = infos.get('listOfItemsInfo');

        Map<String,Set<String>> parentChildProd = new Map<String,Set<String>>();
        Map<String,Set<String>> childProdAttr = new Map<String,Set<String>>();
        Map<String, List<XC_UTIL_Order.OrderItemWrapper>> parentChildMap = (Map<String, List<XC_UTIL_Order.OrderItemWrapper>>) Json.Deserialize(infos.get('parentChildMap'), Map<String, List<XC_UTIL_Order.OrderItemWrapper>>.class);
    
        String nodeItems = '"itemsToAdd":[';

        Map<String,Object> cartMap = XC_REST_CartAPI_U.composeChildCartAndItemsMap(jsonCartItems);
        Map<String,Object> itemsMap = XC_REST_CartAPI_U.composeChildCartAndItemsMap(listOfItems); 

        for(String parent: parentChildMap.keySet()){

            Set<String> childNotFound = new Set<String>();
            Set<String> attrNotFound = new Set<String>();

            for(XC_UTIL_Order.OrderItemWrapper oiWr: parentChildMap.get(parent)){
                
                if(oiWr.ProdID == 'PEN'){ // remove penalty item
                    continue;
                }
                if(String.isBlank(oiWr.ProdID)){
                    childNotFound.add(oiWr.ProdID);
                    break;
                }

                if(((Map<String,Object>)cartMap.get(parent)) != null && ((Map<String,Object>)cartMap.get(parent)).get(oiWr.ProdID) != null){      // autoadded product
                
                   if(oiWr.Attribute != null && !oiWr.Attribute.isEmpty()) {
                        Map<String,Object> fields = (Map<String,Object>)((Map<String,Object>)((Map<String,Object>)cartMap.get(parent)).get(oiWr.ProdID)).get('fields');
                        Map<String,Object> attrMap = (Map<String,Object>)((Map<String,Object>)((Map<String,Object>)cartMap.get(parent)).get(oiWr.ProdID)).get('attributes');
                        nodeItems += '{"fields":{"itemCode":"' + fields.get('itemCode') + '","vid":"' + fields.get('vid') + '","id":"' + fields.get('id') + '","qty": "' + oiWr.Quantity +'"}';
                        String nodeAttr = manageAttrToAdd(oiWr, attrMap, attrNotFound);
                        if(!attrNotFound.isEmpty()){
                            childProdAttr.put(oiWr.ProdID,attrNotFound);
                            infos.put('childProdAttr', JSON.Serialize(childProdAttr));
                            return '';
                        }
                        nodeItems += (String.isBlank(nodeAttr)) ? '},' : ',"listOfAttributes":[' + nodeAttr + ']},';
                    }

                } else if(itemsMap.get(oiWr.ProdID)!= null){ // not autoadded product
                    
                    Map<String,Object> fields = (Map<String,Object>)((Map<String,Object>)itemsMap.get(oiWr.ProdID)).get('fields');
                    Map<String,Object> attrMap = (Map<String,Object>)((Map<String,Object>)itemsMap.get(oiWr.ProdID)).get('attributes');
                    nodeItems += '{"fields":{"itemCode":"' + fields.get('itemCode') + '","vid":"' + fields.get('vid') + '","id":"' + fields.get('id') + '","parentvid":"' + fields.get('parentvid') + '","rootvid":"' + fields.get('rootvid') + '","qty": "' + oiWr.Quantity +'"}';
                    String nodeAttr = manageAttrToAdd(oiWr, attrMap, attrNotFound);
                    if(!attrNotFound.isEmpty()){
                        childProdAttr.put(oiWr.ProdID,attrNotFound);
                        infos.put('childProdAttr', JSON.Serialize(childProdAttr));
                        return '';
                    }
                    nodeItems += (String.isBlank(nodeAttr)) ? '},' : ',"listOfAttributes":[' + nodeAttr + ']},';
                    
                }else{
                    childNotFound.add(oiWr.ProdID); // check if missing some orderItem configuration
                }
            }
           
            if(!childNotFound.isEmpty()){
                parentChildProd.put(parent,childNotFound);
                infos.put('parentChildProd', JSON.Serialize(parentChildProd));
                return '';
            }
            
        }

        nodeItems = nodeItems.removeEnd(',');
        nodeItems += ']';

        return nodeItems;
        
    }
    

    /**
    * Manage Attribute To Add.
    *
    * @param oiWr the oiWr
    * @param attrMap the attrMap
    * @param attrNotFound the attribute not found
    * @return the string
    * @description call to configure attribute info 
    */
    public static String manageAttrToAdd(XC_UTIL_Order.OrderItemWrapper oiWr,Map<String,Object> attrMap, Set<String> attrNotFound){
        String nodeAttr = '';
        if(oiWr.Attribute != null && !oiWr.Attribute.isEmpty()) {
            for(XC_UTIL_Order.WrapperAttribute attrWr : oiWr.Attribute) {
                Map<String, Object> attrFields = (Map<String,Object>)attrMap.get(attrWr.Name);
                if(attrFields != null){
                    attrFields.put('value', attrWr.Value);
                    nodeAttr = nodeAttr +  '{"fields":' + JSON.serialize(attrFields) + '},';
                }else{
                    nodeAttr = '';
                    attrNotFound.add(attrWr.Name);
                }
            }
            nodeAttr = nodeAttr.removeEnd(',');
        }
        
        return nodeAttr;
    }

    /**
    * @author Dario Cerelli dario.cerelli@accenture.com  
    * @param utilMap
    * @description method to populate items for price and number of quotas attributes
    **/ 

    public static String populateItemsForPriceQuotas(Map<String, String> infos) {

        String nodeItems = '"itemsToAdd":[';

        // get cart node
        List<Object> itemsObjList = (List<Object>) JSON.deserializeUntyped(infos.get('retrieveItemFullResult'));

        List<Map<String,Object>> itemsMapList = new List<Map<String,Object>>();
        for(Object obj : itemsObjList) {
            Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            itemsMapList.add(item);
        }

        Map<String,Map<String,Object>> cartItemFields = new Map<String,Map<String,Object>>();
        Map<String,Map<String,Object>> prodCartItem = new Map<String,Map<String,Object>>();
        Map<String,List<Map<String,Object>>> prodListOfAttributes = new Map<String,List<Map<String,Object>>>();
        List<Map<String,Object>> listOfAttributes = new List<Map<String,Object>>();


        List<XC_UTIL_Order.OrderItemWrapper> orderItemList = (List<XC_UTIL_Order.OrderItemWrapper>) JSON.deserialize(infos.get('orderItemList'), List<XC_UTIL_Order.OrderItemWrapper>.class);

        for(XC_UTIL_Order.OrderItemWrapper oiWr : orderItemList) {
            for(Map<String,Object> item : itemsMapList){

                // get fields node

                Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
                if(fields.get('usagecodenew') == oiWr.ProdId){
                    cartItemFields.put(oiWr.ProdId,fields);
                    prodCartItem.put(oiWr.ProdId,item);

                    // get listOfAttributes node

                    List<Object> listOfAttributesObj = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('listOfAttributes')));

                    for(Object obj : listOfAttributesObj) {
                        Map<String,Object> itemObj = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
                        listOfAttributes.add(itemObj);
                    }
                    prodListOfAttributes.put(oiWr.ProdId,listOfAttributes);
                }               
            }
        }
        
        for(XC_UTIL_Order.OrderItemWrapper oiWr : orderItemList) {

            nodeItems += '{"fields":{"id":"' + cartItemFields.get(oiWr.ProdId).get('id') + '","qty": "' + cartItemFields.get(oiWr.ProdId).get('qty') +'","vid": "'+cartItemFields.get(oiWr.ProdId).get('vid') + '","itemCode": "' + cartItemFields.get(oiWr.ProdId).get('itemCode') +'"}';

            String nodeAttr = '';

            if(oiWr.Attribute != null && !oiWr.Attribute.isEmpty()) {

                // set new attributes values

                for(Map<String,Object> item : prodListOfAttributes.get(oiWr.ProdId)){
        
                    Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));

                    for(XC_UTIL_Order.WrapperAttribute oia : oiWr.Attribute){
        
                        if( oia.Name.equalsIgnoreCase(''+fields.get('attributeCode'))){
            
                            nodeAttr = nodeAttr +  '{"fields": {"pfpId":"' + fields.get('pfpId') + '", "value":"'+oia.Value+'"}},';    
                        }
                    }
                }

                nodeAttr = nodeAttr.removeEnd(',');
            }

            nodeItems += (String.isBlank(nodeAttr)) ? '},' : ',"listOfAttributes":[' + nodeAttr + ']},';
        }

        nodeItems = nodeItems.removeEnd(',');
        nodeItems += ']';

        return nodeItems;

    }

    

}