/**
 * The Class XC_REST_CartAPI_UU_clone.
 *
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  16/06/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  Util class for XC_REST_CartAPI
 */


public without sharing class XC_REST_CartAPI_UU_clone {
	

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
                    fieldAsset.put(key, (String)ass.get(assetMap.get(key)));
                }
            }
            node = node + JSON.serialize(fieldAsset) + ',';
        }
        
        node = node.removeEnd(',');

        Account acc = (Account)JSON.deserialize(infos.get('account'), Account.class); 
        confMap.put('NE__order_date__c', DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200');
        String language = (String.isBlank(infos.get('preferredlanguageofcontact'))) ? 'en_US' : ([SELECT XC_NELanguage__c FROM XC_CM_LanguageZuoraMapping__mdt WHERE XC_Invoice_Language__c =: infos.get('preferredlanguageofcontact')][0].XC_NELanguage__c);
        language = (String.isBlank(language)) ? 'en_US' : language;
        String body = '{"retrieveCatalogs":{"sessionInfo":{"Id":""},"configuration":{}},"options":{"ItemsForPage":"100","GetStructure":false,"GetAllData":false,"userLanguage":"' + language + '","facts":{"configuration":' + JSON.serialize(confMap) + ',"opportunity":{"createddate":"' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + '+0200","XC_legalentity":"'+confMap.get('XC_LegalEntity__c')+'", "address" : "' + confMap.get('XC_DeliveryAddress__c') + '", "PricingRegion": "' + infos.get('PricingRegionCommodity') + '", "XC_IsEmployee": "' + acc.XC_IsEmployee__c + '"}, "account":{"AccntId":"' + acc.Id + '","XC_AccountType":"' + acc.Account_Type__c + '","rtDeveloperName":"' + acc.XC_RecordTypeDeveloperName__c + '"}, "customasset":[' + node + '],"sessionparameter":[{"name":"UserChannel","value":"Commodity Partner"}, {"name":"sourcePlatform","value":"CRM"}]}}}'; 
       
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
            
        } else if(String.isNotBlank(infos.get('orderItemList'))) {  // FOR eMobility inOrder
            itemsToUpsert = populateItemsForMobility(infos);

        } else {                                                    // FOR eMobility ChangeOrder
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
        String nodeItems = (attributeList.isEmpty()) ? '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"}}]' : '"itemsToAdd":[{"fields":{"id":"' + infos.get('catalogItemId') +'","qty": "' + infos.get('qty') +'"},"listOfAttributes": [' + nodeAttr + '] }]';

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
            nodeItems += '{"fields":{"id":"' + oiWr.CatalogItemID + '","qty": "' + oiWr.Quantity +'"}';

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
            body = '{"upsertItems":{' + node1 + ',' + node2 + ',' + node3 + ',' + node4 + ',' + node5 + ',' + node6 + ',' + node7 + ',' + node8 + ',' + '"itemsToAdd": [' + node10 + ']},"options":{"GetStructure":false,"GetAllData":false,"userLanguage":"en_US"}}';
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
        return XC_UTIL_RESTCallout.getResponseLoggingError(intLog, 'DiscountCode ' + infos.get('discountCode')+ ' not found or not elegible for the product ' + infos.get('productCode'))[0];
       
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
        currentStep.XC_ErrorMessage__c = (status == Label.XC_CL_Completed_OK) ? '' : (!wrResult.success) ? 'INTERNAL ERROR. TransactionID: ' + infos.get('commodityTransactionID') + '. ' + wrResult.errorMessage : 'Error on CartAPI with transactionID: ' + infos.get('commodityTransactionID');
        currentStep.XC_RelatedRecordsIds__c = !String.isBlank(infos.get('confId')) ? infos.get('confId') : null;
        XC_UTIL_Sobject.updateRecord(currentStep);
    }


    /**
     * updateQueuedRequestStep.
     *
     * @param opportunityId the opportunity id
     * @description method to delete the opportunity - FOR MARKET
     */
    public static XC_UTIL_Sobject.WrapperResult deleteOpportunity(String opportunityID){
        
        return XC_UTIL_Sobject.deleteRecord(new Opportunity(Id = opportunityID));

    }

}