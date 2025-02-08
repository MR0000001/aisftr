/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 02-08-2021
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-14-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_AMP_LCC010_U_CartAPI {

    /**
    * @description return b2w token to use between cartAPI calls
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> retrieveCartAPIToken(){

        Map<String,Object> result = new Map<String,Object>();
        Map<String,String> tokenParams = new Map<String,String>();

        Map<Id, XC_CS004_Bit2WinCredentials__c> b2wMap = new Map<Id, XC_CS004_Bit2WinCredentials__c>([SELECT XC_ServerURL__c, XC_ClientId__c, XC_OrganizationId__c, XC_EngineVersion__c FROM XC_CS004_Bit2WinCredentials__c WHERE XC_Country__c = 'SPAIN']);
        List<XC_CS004_Bit2WinCredentials__c> b2wCred = b2wMap.values();

        if(b2wCred.isEmpty()){
            result.put('success',false);
            return result;
        }

        tokenParams.put('ServerURL', b2wCred[0].XC_ServerURL__c);
        tokenParams.put('ClientId', b2wCred[0].XC_ClientId__c);
        tokenParams.put('OrganizationId', b2wCred[0].XC_OrganizationId__c);
        tokenParams.put('EngineVersion', b2wCred[0].XC_EngineVersion__c);


        XC_REST_CartAPI.ResultWrapper tokenRw = XC_REST_CartAPI.generateTokenB2W(tokenParams);

        result.put('success',tokenRw.success);
        if(tokenRw.success){
            result.putAll(tokenParams);
        }
        return result;
    }


    /**
    * @description retrieve B2W catalog withItems
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> retrieveCartAPICatalogAndItems(Map<String,Object> paramsMap){

        Map<String,String> b2wInfos = new Map<String,String>();
        b2wInfos.put('getFullStructure','true');
        b2wInfos.put('NE__OptyId__c',String.valueOf(paramsMap.get('opportunityId')));
        retrieveObjectInfos(paramsMap, b2wInfos);


        Map<String,Object> result = new Map<String,Object>();
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();

        //call to get catalog
        XC_REST_CartAPI.ResultWrapper catalogRw = XC_REST_CartAPI.retriveCatalogs(b2wInfos);
        integrationLogsToInsert.add(catalogRw.intLog);

        result.put('success',catalogRw.success);
        if(catalogRw.success){
            XC_REST_CartAPI.ResultWrapper itemsRW = XC_REST_CartAPI.retriveItems(b2wInfos);
            integrationLogsToInsert.add(itemsRw.intLog);
            result.put('success',itemsRW.success);
            if(itemsRw.success){
                result.put('b2wInfos',b2wInfos);
                result.put('resultItems',getItemsFields(b2wInfos.get('itemsFullMap')));
                String catName = retrieveCategoryName(String.valueOf(paramsMap.get('categoryId')));
                result.put('checkForFileCategory', checkForCategory(catName,String.valueOf(paramsMap.get('categoryForFile'))));
                result.put('checkForExtraSectionsCategory', checkForCategory(catName,String.valueOf(paramsMap.get('categoryForExtraSections'))));
                // b2wInfos.remove('itemsFullMap');
            }
        }

        XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(b2wInfos));
        return result;
    }

    /**
    * @description retrieve the Category Name from Id
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @param categoryId 
    * @return the Category Name
    **/
    private static String retrieveCategoryName(String categoryId){
        Map<Id,NE__Catalog_Category__c> catData = new Map<Id,NE__Catalog_Category__c>([
            SELECT Id, XC_LIC_Category_Name__c FROM NE__Catalog_Category__c WHERE Id =: categoryId
        ]);

        return !catData.isEmpty() ? catData.values()[0].XC_LIC_Category_Name__c : '';
    }

    /**
    * @description Check For Category, to know if show the File Upload Section
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @param categoryName 
    * @param categories 
    * @return check result 
    **/
    private static Boolean checkForCategory(String categoryName, String categories){
        if(String.isNotBlank(categories) && String.isNotBlank(categoryName)){
            return categories.contains(categoryName);
        }
        return true;
    }

    /**
    * @description upsert item for attribute evluation mapping
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-15-2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> firstUpsertCartAPICatalogItems(Map<String,Object> paramsMap){
        Map<String,Object> result = new Map<String,Object>();
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();


        Map<String,Object> b2wInfosObj = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(paramsMap.get('b2wInfos')));
        Map<String,String> b2wInfos = new Map<String,String>();
        
        for(String key : b2wInfosObj.keySet()){
            b2wInfos.put(key,String.valueOf(b2wInfosObj.get(key)));
        }

        b2wInfos.put('catalogItemId',String.valueOf(paramsMap.get('itemId')));
        b2wInfos.put('qty','1'); //TODO: Default value

        List<Object> itemsObjList = (List<Object>) JSON.deserializeUntyped(b2wInfos.get('itemsFullMap'));
        List<Map<String,Object>> listOfItems = new List<Map<String,Object>>();
        for(Object obj : itemsObjList) {
            Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            listOfItems.add(item);
        }

        //manage attributes in full form before calling cart API
        Map<String,List<Object>> catalogItemAttributesMap = new Map<String,List<Object>>();
        for(Map<String,Object> item : listOfItems) {
            List<Object> listOfAttributes = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('listOfAttributes')));
            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
            String id = (String) fields.get('id');
            String eligible = (String) fields.get('eligible');
            if(b2wInfos.get('catalogItemId') == id){
                catalogItemAttributesMap.put(id, listOfAttributes);
            }                
        }
        b2wInfos.put('catalogItemAttributesMap', JSON.serialize(catalogItemAttributesMap));

        //attribute are passed togheter with the item code of the item that is going to be edited.
        if(paramsMap.containsKey('itemCode') && paramsMap.containsKey('changedAttributesMap')){
            b2wInfos.put('itemCode',String.valueof(paramsMap.get('itemCode')));
            Map<String,Object> changedAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(paramsMap.get('changedAttributesMap')));
            String key = String.valueOf(changedAttributesMap.get('pfpId'));
            String value = String.valueOf(changedAttributesMap.get('value'));

            b2wInfos.put('familyPropertyIds',JSON.Serialize(new Map<String,String> {
                key => value
            }));

            System.Debug('PASSED ATTRIBUTES PROPERTIES ' + JSON.serialize(b2wInfos.get('familyPropertyIds')));
            
        }else{
            b2wInfos.put('familyPropertyIds',JSON.Serialize(new Map<String,String>()));
        }


        //call to cart API
        XC_REST_CartAPI.ResultWrapper upsertRw = XC_REST_CartAPI.upsertItems(b2wInfos);
        result.put('success',upsertRw.success);
        integrationLogsToInsert.add(upsertRw.intLog);

        if(upsertRw.success){
            result.put('b2wInfos',b2wInfos);
            result.put('resultItems',getItemsFields(b2wInfos.get('upsertItemFullResult')));
            for(Map<String,Object> reducedItem : (List<Map<String,Object>>)result.get('resultItems')){
                if(reducedItem.get('id') == b2wInfos.get('catalogItemId')){
                    result.put('productDescription', reducedItem.get('productdescription'));
                    if( (Double)reducedItem.get('baserecurringcharge') > 0 ){ //
                        result.put('productPrice', String.valueOf(reducedItem.get('baserecurringcharge')) + ' ' + String.valueOf(reducedItem.get('currencyisocode')) + ' / ' + Label.XC_CL_MonthLabel);
                        if( (Double)reducedItem.get('baserecurringcharge') != (Double)reducedItem.get('recurringchargeov') ){
                            result.put('productDiscountedPrice', String.valueOf(reducedItem.get('recurringchargeov')) + ' ' + String.valueOf(reducedItem.get('currencyisocode')) + ' / ' + Label.XC_CL_MonthLabel);
                        }
                    }else{
                        result.put('productPrice', String.valueOf(reducedItem.get('baseonetimefee')) + ' ' + String.valueOf(reducedItem.get('currencyisocode')));
                        if( (Double)reducedItem.get('baseonetimefee') != (Double)reducedItem.get('onetimefeeov') ){
                            result.put('productDiscountedPrice', String.valueOf(reducedItem.get('onetimefeeov')) + ' ' + String.valueOf(reducedItem.get('currencyisocode')));
                        }
                    }
                    break;
                }
            }
        }

        XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), JSON.serialize(b2wInfos));

        return result;
    }

    /**
    * @description remove the item from the cart
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-17-2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> removeItem(Map<String,Object> paramsMap){
        Map<String,Object> result = new Map<String,Object>();
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();

        String itemToBeRemoved = String.valueOf(paramsMap.get('removeItemCode'));
        Map<String,Object> b2wInfosObj = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(paramsMap.get('b2wInfos')));
        Map<String,String> b2wInfos = new Map<String,String>();
        for(String key : b2wInfosObj.keySet()){
            b2wInfos.put(key,String.valueOf(b2wInfosObj.get(key)));
        }
        b2wInfos.put('itemsToRemove',JSON.serialize(new Set<String>{itemToBeRemoved}));

        //CALL CART API
        XC_REST_CartAPI.ResultWrapper deleteRw = XC_REST_CartAPI.removeItems(b2wInfos);
        result.put('success',deleteRw.success);
        integrationLogsToInsert.add(deleteRw.intLog);

        if(deleteRw.success){
            result.put('b2wInfos',b2wInfos);
            result.put('resultItems',getItemsFields(b2wInfos.get('upsertItemFullResult')));
        }

        return result;

    }


    /**
    * @description save configuration and creates NE__Order__c record
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-15-2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> finalSaveConfiguration(Map<String,Object> paramsMap){

        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> b2wInfosObj = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(paramsMap.get('b2wInfos')));
        Map<String,String> b2wInfos = new Map<String,String>();
        
        for(String key : b2wInfosObj.keySet()){
            b2wInfos.put(key,String.valueOf(b2wInfosObj.get(key)));
        }

        String catalogItemId = String.valueOf(b2wInfos.get('catalogItemId'));
        Map<Id,NE__Catalog_Item__c> catData = new Map<Id,NE__Catalog_Item__c>([
            SELECT Id, NE__Product_Name__c
            FROM NE__Catalog_Item__c
            WHERE Id =: catalogItemId
        ]);

        XC_REST_CartAPI.ResultWrapper scRw = XC_REST_CartAPI.saveConfiguration(b2wInfos);
        result.put('success',scRw.success);
        if(scRw.success){
            Map<String,Map<Object,Object>> dataUpdateObj = mapSectionObjectData((List<Object>)paramsMap.get('validSections'));
            
            String opportunityId = b2wInfos.get('NE__OptyId__c');
            Opportunity oppObjData = retrieveOpportunityData(opportunityId);

            Integer counter = 1 /*Boolean.valueOf(b2wInfos.get('directOrder')) ? 1 : 0*/;
            b2wInfos.put('fromAutomotivePortal', 'true');
            XC_REST_CartAPI.ResultWrapper checkoutRw = XC_REST_CartAPI.cartCheckout(b2wInfos, counter);
            result.put('success',checkoutRw.success);
            result.put('b2wInfos',b2wInfos);
            result.put('orderId',b2wInfos.get('confId'));

            if(b2wInfos.containsKey('confId')){
                Opportunity currentOpportunity = new Opportunity(Id = opportunityId, XC_AMP_Order__c = b2wInfos.get('confId'), XC_AMP_ProductDescription__c = (String)paramsMap.get('productDescription'));
                if(!catData.isEmpty()){
                    currentOpportunity.XC_AMP_ProductName__c = catData.values()[0].NE__Product_Name__c;
                }
                if(dataUpdateObj.get('Opportunity') != null){
                    Map<Object,Object> oppData = dataUpdateObj.get('Opportunity');
                    for(Object fieldName : oppData.keySet()){
                        currentOpportunity.put((String.valueOf(fieldName)),oppData.get(fieldName));
                    }
                }
                if(dataUpdateObj.get('XC_AMP_Vehicle__c') != null){
                    if(oppObjData!=null && String.isNotBlank(oppObjData.XC_AMP_Vehicle__c)){
                        XC_AMP_Vehicle__c vehicle = new XC_AMP_Vehicle__c(Id = oppObjData.XC_AMP_Vehicle__c);
                        Map<Object,Object> vehicleData = dataUpdateObj.get('XC_AMP_Vehicle__c');
                        SObjectType objType = ((SObject)(Type.forName('Schema.'+'XC_AMP_Vehicle__c').newInstance())).getSObjectType();
                        DescribeSObjectResult descr = objType.getDescribe();
                        for(Object fieldName : vehicleData.keySet()){
                            Schema.DisplayType fieldType = descr.fields.getMap().get(String.valueOf(fieldName)).getDescribe().getType();
                            if(fieldType == Schema.DisplayType.Date){
                                String dateStrValue = String.valueOf(vehicleData.get(fieldName));
                                vehicle.put((String.valueOf(fieldName)),Date.valueOf(dateStrValue));
                            }else{
                                vehicle.put((String.valueOf(fieldName)),String.valueOf(vehicleData.get(fieldName)));
                            }
                        }
                        List<XC_UTIL_Sobject.WrapperResult> vehicleDMLRes = XC_UTIL_DML.updateRecords(new List<XC_AMP_Vehicle__c>{vehicle} );
                    }
                }
                XC_UTIL_Sobject.WrapperResult optyupdateWr = XC_UTIL_Sobject.updateRecord(currentOpportunity);
                
                //Configuration Update
                NE__Order__c order = new NE__Order__c( Id = b2wInfos.get('confId') );
                List<NE__OrderItem__c> orderitems = retrieveOrderItemsFromOrder(b2wInfos.get('confId'));
                Boolean updOrder = false;
                Boolean updOrderItems = false;
                //set Account B2B
                if(oppObjData!=null){
                    order.NE__BillAccId__c = oppObjData.Owner.Account.ParentId;
                    updOrder = true;
                    if(!orderitems.isEmpty()){
                        for(NE__OrderItem__c oi : orderitems){
                            oi.NE__Billing_Account__c = oppObjData.Owner.Account.ParentId;
                        }
                        updOrderItems = true;
                    }
                }

                if(paramsMap.get('callType') != null){
                    order.XC_CallType__c = (String)paramsMap.get('callType');
                    updOrder = true;
                }
                if(updOrder){
                    //XC_UTIL_Sobject.WrapperResult orderRW = XC_UTIL_Sobject.updateRecord(order);
                    List<XC_UTIL_Sobject.WrapperResult> orderRW = XC_UTIL_DML.updateRecords(new List<NE__Order__c>{order});
                }
                if(updOrderItems){
                    List<XC_UTIL_Sobject.WrapperResult> orderitemsRW = XC_UTIL_DML.updateRecords(orderitems);
                }

                result.put('success', optyupdateWr.success);
            }
        }

        return result;

    }

    /**
    * @description retrieveOpportunityData from Id
    * @param opportunityId 
	* @return the Opportunity obj
    **/
    private static Opportunity retrieveOpportunityData(String opportunityId){
        Map<Id,Opportunity> oppData = new Map<Id,Opportunity>([
            SELECT Id, XC_AMP_Vehicle__c, Owner.Account.ParentId FROM Opportunity WHERE Id =: opportunityId
        ]);
        
        return (!oppData.isEmpty()) ? oppData.values()[0] : null;
    }

    /**
    * @description retrieveOrderItemsFromOrder from Id
    * @param orderId 
	* @return the NE__OrderItem__c related
    **/
    private static List<NE__OrderItem__c> retrieveOrderItemsFromOrder(String orderId){
        if(String.isBlank(orderId)){
            return new List<NE__OrderItem__c>();
        }

        Map<Id,NE__OrderItem__c> orderitems = new Map<Id,NE__OrderItem__c>([
            SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderId
        ]);
        
        return orderitems.values();
    }

    /**
    * @description mapSectionObjectData
    * @param validSections 
	* @return Map<String,Map<Object,Object>> {key=objectType -> value={objectData: key=nomeCampo -> value=valoreCampo}}
    **/
    private static Map<String,Map<Object,Object>> mapSectionObjectData(List<Object> validSections){
        //Example of Input
        /*"validSections":[
            {"sObjectName":"Opportunity",
             "sectionName":"ElementiOrdineCSPS_E (14 more) ...",
             "isSectionValid":true,
             "fields":{"XC_AMP_OrderCSPSNumber__c":"1234567","XC_AMP_OrderCSPSLineNumber__c":"12345"}}]
        */
        Map<String,Map<Object,Object>> sectionObjectFieldsMap = new Map<String,Map<Object,Object>>();
        for(Object sectionObj : validSections){
            Map<Object,Object> section = (Map<Object,Object>)sectionObj;
            if(sectionObjectFieldsMap.get(String.valueOf(section.get('sObjectName'))) == null){
                sectionObjectFieldsMap.put(String.valueOf(section.get('sObjectName')), new Map<Object,Object>());
            }
            Map<Object,Object> fields = (Map<Object,Object>)section.get('fields');
			if(fields != null && !fields.isEmpty()){
                (sectionObjectFieldsMap.get(String.valueOf(section.get('sObjectName')))).putAll(fields);
            }
        }
        return sectionObjectFieldsMap;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @param paramsMap 
    * @param infos 
    **/
    private static void retrieveObjectInfos(Map<String,Object> paramsMap,Map<String,String> infos){

        String accountId = String.valueOf(paramsMap.get('accountId'));
        String opportunityId = String.valueOf(paramsMap.get('opportunityId'));
        String defaultBPLIId = String.valueOf(paramsMap.get('defaultBpliId'));
        String catalogId = String.valueOf(paramsMap.get('catalogId'));
        String categoryId = String.valueOf(paramsMap.get('categoryId'));
        Boolean directOrder = Boolean.valueOf(paramsMap.get('directOrder'));


        Id configurationRecordTypeId = directOrder ? 
        Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId() 
        : Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();


        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c, (SELECT Id, XC_Preferredlanguageofcontact__c FROM Contacts WHERE XC_PrimaryContact__c = true),
        // (SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c, XC_SoldToAddress__c  FROM XC_BillingProfileLineItems__r WHERE Id =:defaultBPLIId),
        (SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, Id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Assets WHERE NE__Status__c =: Label.XC_CL_Asset_StatusActive)
        FROM Account WHERE Id =:accountId LIMIT 1]);

        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id,XC_Address__c,XC_Address__r.XC_PricinRegion__c,XC_Address__r.XC_AddressProvince__c,XC_LegalEntity__c,XC_ReceivingChannel__c,XC_Calculated_Pricelist__c FROM Opportunity WHERE Id =:opportunityId]);

        infos.put('account', JSON.Serialize(accountMap.values()[0]));

        infos.put('XC_LegalEntity__c', opportunityMap.values()[0].XC_LegalEntity__c);
        infos.put('categoryId',categoryId);
        infos.put('stream', accountMap.values()[0].XC_Segment__c);
        infos.put('catalogId', catalogId);
        infos.put('contactId', accountMap.values()[0].Contacts[0].Id);
        infos.put('xcProvince', opportunityMap.values()[0].XC_Address__r.XC_AddressProvince__c);
        infos.put('PricingRegionCommodity',opportunityMap.values()[0].XC_Address__r.XC_PricinRegion__c);
        infos.put('AssetList', (!accountMap.values()[0].Assets.isEmpty() ? JSON.Serialize(accountMap.values()[0].Assets) : JSON.Serialize(new List<Asset>())));
        infos.put('XC_OrderBillingAddress__c',opportunityMap.values()[0].XC_Address__c);
        infos.put('XC_DeliveryAddress__c',opportunityMap.values()[0].XC_Address__c);
        infos.put('XC_InstallationAddress__c', opportunityMap.values()[0].XC_Address__c);
        infos.put('preferredlanguageofcontact', String.valueOf(paramsMap.get('preferredlanguageofcontact'))); // accountMap.values()[0].Contacts[0].XC_Preferredlanguageofcontact__c
        infos.put('currencyISOCode', 'EUR'); //TODO: CHeck this
        infos.put('NE__AccountId__c' , accountMap.values()[0].Id);
        infos.put('NE__BillAccId__c' , accountMap.values()[0].Id);
        infos.put('NE__ServAccId__c' , accountMap.values()[0].Id);
        infos.put('NE__OrderStatus__c' , 'In Progress');
        infos.put('NE__ConfigurationStatus__c' , 'Valid');
        infos.put('NE__type__c' , 'InOrder');
        infos.put('RecordTypeId' , configurationRecordTypeId);
        infos.put('NE__Channel__c',opportunityMap.values()[0].XC_ReceivingChannel__c);
        infos.put('clientSystem',opportunityMap.values()[0].XC_ReceivingChannel__c);
        infos.put('CalcPriceList',opportunityMap.values()[0].XC_Calculated_Pricelist__c);

        //Mapping default BPLI from partner account
        if(String.isNotBlank(defaultBPLIId)){
            Map<Id,XC_BillingProfileLineItem__c> bpliMap = new Map<Id,XC_BillingProfileLineItem__c>([SELECT Id,XC_BillingProfile__r.NE__Payment__c,XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE Id =:defaultBPLIId LIMIT 1]);

            infos.put('billingProfLineItemId',defaultBPLIId);
            infos.put('billingProfId',bpliMap.get(defaultBPLIId).XC_BillingProfile__c);
            infos.put('paymentMethod',bpliMap.get(defaultBPLIId).XC_BillingProfile__r.NE__Payment__c);
        }



        
        //auth infos
        infos.put('OrganizationId',String.valueOf(paramsMap.get('OrganizationId')));
        infos.put('ClientId',String.valueOf(paramsMap.get('ClientId')));
        infos.put('token',String.valueOf(paramsMap.get('token')));
        infos.put('ServerURL',String.valueOf(paramsMap.get('ServerURL')));
        infos.put('EngineVersion',String.valueOf(paramsMap.get('EngineVersion')));




    }


    /**
    * @description clean items for front end ease of usage in simplified b2w cart management
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @param listOfItemsJSON 
    **/
    private static List<Map<String,Object>> getItemsFields(String listOfItemsJSON){

        List<Map<String,Object>> result = new List<Map<String,Object>>();
        List<Object> itemsObjList = (List<Object>) JSON.deserializeUntyped(listOfItemsJSON);
        List<Map<String,Object>> itemsMapList = new List<Map<String,Object>>();
        for(Object obj : itemsObjList) {
            Map<String,Object> item = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(obj));
            itemsMapList.add(item);
        }

        for(Map<String,Object> item : itemsMapList){

            Map<String, Object> fields = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(item.get('fields')));
            List<Object> listOfAttributes = (List<Object>) JSON.deserializeUntyped(Json.serialize(item.get('listOfAttributes')));


            String id = (String) fields.get('id');
            String eligible = (String) fields.get('eligible');
            String visible = (String) fields.get('visible');

            if(eligible.equalsIgnoreCase('Y') && visible == 'true'){

                Map<String,Object> reducedItem = new Map<String,Object>();
                reducedItem.put('id',String.valueOf(fields.get('id')));
                reducedItem.put('productname',String.valueOf(fields.get('productname')));
                reducedItem.put('enginecode',String.valueOf(fields.get('enginecode')));
                reducedItem.put('NE__UsageCode__c',String.valueOf(fields.get('NE__UsageCode__c')));
                reducedItem.put('XC_Product_Subtype__c',String.valueOf(fields.get('XC_Product_Subtype__c')));
                reducedItem.put('productdescription', String.valueOf(fields.get('productdescription')));
                reducedItem.put('baserecurringcharge', Double.valueOf(fields.get('baserecurringcharge')));
                reducedItem.put('recurringchargeov', Double.valueOf(fields.get('recurringchargeov')));
                reducedItem.put('baseonetimefee', Double.valueOf(fields.get('baseonetimefee')));
                reducedItem.put('onetimefeeov', Double.valueOf(fields.get('onetimefeeov')));
                reducedItem.put('currencyisocode', String.valueOf(fields.get('currencyisocode')));

                if(fields.containsKey('itemCode')){
                    reducedItem.put('itemCode',String.valueOf(fields.get('itemCode')));
                }

                //attributes
                List<Map<String,Object>> reducedAttributeMapList = new List<Map<String,Object>>();

                for(Object attr : listOfAttributes){

                    Map<String,Object> attrMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attr));
                    Map<String,Object> attFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(attrMap.get('fields'))); 

                    System.Debug('ATTRIBUTE MAP ' + attFieldsMap);


                    Boolean hidden =  Boolean.valueOf(attFieldsMap.get('readonly')) || Boolean.valueOf(attFieldsMap.get('hiddenInCart'));

                    if(!hidden){
                        Map<String,Object> reducedAttr = new Map<String,Object>();
                        reducedAttr.put('name',String.valueOf(attFieldsMap.get('name')));
                        reducedAttr.put('attributeCode',String.valueOf(attFieldsMap.get('attributeCode')));
                        reducedAttr.put('pfpId',String.valueOf(attFieldsMap.get('pfpId')));
                        reducedAttr.put('value',String.valueOf(attFieldsMap.get('value')));
                        reducedAttr.put('type',String.valueOf(attFieldsMap.get('type')));

                        if(String.valueOf(attFieldsMap.get('type')).equalsIgnoreCase('Enumerated')){
                            //getting list of domains
                            List<Object> listOfDomainsObj = (List<Object>) JSON.deserializeUntyped(Json.serialize(attrMap.get('listOfDomains')));
                            List<Map<String,Object>> reducedDomainList = new List<Map<String,Object>>();

                            for(Object domainObj : listOfDomainsObj){

                                Map<String,Object> domainMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(domainObj));
                                Map<String,Object> domainFieldsMap = (Map<String,Object>) JSON.deserializeUntyped(Json.serialize(domainMap.get('fields'))); 

                                if(String.valueOf(domainFieldsMap.get('eligible')).equalsIgnoreCase('Y')){
                                    Map<String,Object> reducedDomain = new Map<String,Object>();
                                    reducedDomain.put('label',String.valueOf(domainFieldsMap.get('label')));
                                    reducedDomain.put('value',String.valueOf(domainFieldsMap.get('LicName')));
                                    reducedDomainList.add(reducedDomain);
                                }
                                reducedAttr.put('attributeLOV',reducedDomainList);
                            }

                        }
                        reducedAttributeMapList.add(reducedAttr);
                    }

                }

                reducedItem.put('attributes',reducedAttributeMapList);
                result.add(reducedItem);
            }

        }

        return result;

    }

}