/**
 * The Class XC_REST_CartAPI_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 12/06/2019
 * @date Modification : 12/10/2020
 * @description       : Test Class for XC_REST_CartAPI
 **/
 

@isTest
public without sharing class XC_REST_CartAPI_TEST {
	
    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        List<XC_CS_UtilityGlobalValues__c> csList = new List<XC_CS_UtilityGlobalValues__c>();
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_ActiveRetry', Value__c = 'True'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_Nattempts', Value__c = '1'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_errorStatusSet', Value__c = '503;'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_Sleep', Value__c = '2000'));
        insert csList;
      
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__AccountId__c =  accountList[0].Id;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        insert catItem;


        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        insert assetList;

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"Channel":"EnelEnergiaItalia","Document":[{"ContractUrl":"http:z"}],"IntegrationID":"1231213123","LegalEntity":"EnelXItalia","OrderItem":[{"Attribute":[{"Name":"Test:Pfp","ProductFamilyPropertyID":"a1V1l000000PNaMEAW","Value":"Monthly"}],"BaseOneTimeFee":0.00,"BaseRecurringCharge":7.50,"BundleConfiguration":null,"ContractType":"Light","ProdID":"TestCatItem","Quantity":1}],"OrderStatus":"In progress"}}';
        qr.XC_ClientSystem__c = 'CommodityItalyB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;
    }


    //call B2W for eMobility
    @isTest
    static void cartApiEMobilityTest(){

    
        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('AssetList', json.serialize([SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Asset]));
        infos.put('XC_eMobTransactionId__c', 'test');
        infos.put('NE__Account__c', '12345');
        infos.put('ConfId', '12345');
        infos.put('listOfAttributes', '[{"fields":{"id":"12345"}}]');
        infos.put('dataInterceptorString', 'testest');
        Map<String, List<Object>> catalogItemAttributesMap = new Map<String, List<Object>>();
        Map<String, Object> fields = new Map<String, Object>();
        fields.put('id', '555');
        Map<String, Object> attribute = new Map<String, Object>();
        attribute.put('fields', fields);
        catalogItemAttributesMap.put('12345', new List<Object>{attribute});
        infos.put('catalogItemAttributesMap', JSON.serialize(catalogItemAttributesMap));
        List<XC_REST_MobilityOrder_W.OrderItemWrapper> orderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        XC_REST_MobilityOrder_W.OrderItemWrapper oiWr = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        oiWr.CatalogItemID = '12345';
        oiWr.Quantity = 1;
        oiWr.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        XC_REST_MobilityOrder_W.WrapperAttribute attrWr = new XC_REST_MobilityOrder_W.WrapperAttribute();
        attrWr.ProductFamilyPropertyID = '555';
        attrWr.Value = '000';
        oiWr.Attribute.add(attrWr);
        orderItemList.add(oiWr);
        infos.put('orderItemList', JSON.serialize(orderItemList));

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new generateRequestTrue_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }


    //call B2W for Commodity
    @isTest
    static void cartApiCommodityTest(){

        Map<Id, List<String>> mapCategoryIdCatalogItemList = new  Map<Id, List<String>>();
        NE__Catalog_Item__c catItem = [Select NE__Catalog_Category_Name__c FROM NE__Catalog_Item__c LIMIT 1][0];
        mapCategoryIdCatalogItemList.put(catItem.NE__Catalog_Category_Name__c, new List<String>{'31451345'});
     
        Map<Id, List<XC_UTIL_Order.OrderItemWrapper>> mapCategoryIdOrderItemList = new Map<Id, List<XC_UTIL_Order.OrderItemWrapper>>();
        List<XC_UTIL_Order.OrderItemWrapper> orderItemList = new List<XC_UTIL_Order.OrderItemWrapper>();
        XC_UTIL_Order.OrderItemWrapper oiWr = new XC_UTIL_Order.OrderItemWrapper();
        oiWr.CatalogItemID = '12345';
        oiWr.Quantity = 1;
        oiWr.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
        XC_UTIL_Order.WrapperAttribute attrWr = new XC_UTIL_Order.WrapperAttribute();
        attrWr.ProductFamilyPropertyID = '555';
        attrWr.Value = '000';
        oiWr.Attribute.add(attrWr);
        orderItemList.add(oiWr);
        mapCategoryIdOrderItemList.put(catItem.NE__Catalog_Category_Name__c, orderItemList);
        
        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('AssetList', json.serialize([SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Asset]));
		infos.put('account', json.serialize([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c FROM Account LIMIT 1][0]));
        infos.put('NE__Account__c', '12345');
        infos.put('ConfId', '12345');
        infos.put('listOfAttributes', '[{"fields":{"id":"12345"}}]');
        infos.put('dataInterceptorString', 'testest');
        infos.put('ChannelCommodity', 'Test'); 
        infos.put('listOfAttributesDiscount', '[{"fields": { "LicName": "Tipo promocion"}, "listOfDomains":[ {"fields" : {"LicName" : "12 Meses 20%", "eligible" : "Y"}}]}]');
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));
        infos.put('Discounts', '[ {"Code": "EXU","OneTimePrice": 20.0,"OneTimeValue": 20.0, "RecurringPrice": 20.0, "RecurringValue": 20.0,"Sequence": 49,"Status": "Active","Type": "%"}]');
        infos.put('clientSystem', 'Test');
        infos.put('catalogCategoryAndCatalogItems', JSON.serialize(mapCategoryIdCatalogItemList));
        infos.put('catalogCategoryAndOrderItems', JSON.serialize(mapCategoryIdOrderItemList));

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new generateRequestTrue_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }

      //call B2W for Commodity
    @isTest
    static void cartApiUniqueServiceTest(){

        Map<Id, List<String>> mapCategoryIdCatalogItemList = new  Map<Id, List<String>>();
        NE__Catalog_Item__c catItem = [Select NE__Catalog_Category_Name__c FROM NE__Catalog_Item__c LIMIT 1][0];
        mapCategoryIdCatalogItemList.put(catItem.NE__Catalog_Category_Name__c, new List<String>{'31451345'});
     
        Map<Id, List<XC_UTIL_Order.OrderItemWrapper>> mapCategoryIdOrderItemList = new Map<Id, List<XC_UTIL_Order.OrderItemWrapper>>();
        List<XC_UTIL_Order.OrderItemWrapper> orderItemList = new List<XC_UTIL_Order.OrderItemWrapper>();
        XC_UTIL_Order.OrderItemWrapper oiWr = new XC_UTIL_Order.OrderItemWrapper();
        oiWr.CatalogItemID = '12345';
        oiWr.Quantity = 1;
        oiWr.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
        XC_UTIL_Order.WrapperAttribute attrWr = new XC_UTIL_Order.WrapperAttribute();
        attrWr.ProductFamilyPropertyID = '555';
        attrWr.Value = '000';
        oiWr.Attribute.add(attrWr);
        orderItemList.add(oiWr);
        mapCategoryIdOrderItemList.put(catItem.NE__Catalog_Category_Name__c, orderItemList);

        Map<String, Boolean> mapCategoryHasChild = new Map<String, Boolean>();
        mapCategoryHasChild.put(catItem.NE__Catalog_Category_Name__c, true);
        Map<String, List<XC_UTIL_Order.OrderItemWrapper>> parentChildMap = new Map<String, List<XC_UTIL_Order.OrderItemWrapper>>();
        List<XC_UTIL_Order.OrderItemWrapper> orderItemListChild = new List<XC_UTIL_Order.OrderItemWrapper>();
        XC_UTIL_Order.OrderItemWrapper oiWrChild = new XC_UTIL_Order.OrderItemWrapper();
        oiWrChild.CatalogItemID = '56789';
        oiWrChild.ProdID = '56789'; 
        oiWrChild.Quantity = 1;
        oiWrChild.Attribute = new List<XC_UTIL_Order.WrapperAttribute>();
        XC_UTIL_Order.WrapperAttribute attrWrChild = new XC_UTIL_Order.WrapperAttribute();
        attrWrChild.ProductFamilyPropertyID = '555';
        attrWrChild.Value = '000';
        oiWrChild.Attribute.add(attrWrChild);
        orderItemListChild.add(oiWrChild);
        parentChildMap.put('12345', orderItemListChild);
        
        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('AssetList', json.serialize([SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Asset]));
		infos.put('account', json.serialize([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c FROM Account LIMIT 1][0]));
        infos.put('NE__Account__c', '12345');
        infos.put('ConfId', '12345');
        infos.put('listOfAttributes', '[{"fields":{"id":"12345"}}]');
        infos.put('dataInterceptorString', 'testest');
        infos.put('ChannelCommodity', 'Test'); 
        infos.put('listOfAttributesDiscount', '[{"fields": { "LicName": "Tipo promocion"}, "listOfDomains":[ {"fields" : {"LicName" : "12 Meses 20%", "eligible" : "Y"}}]}]');
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));
        infos.put('Discounts', '[ {"Code": "EXU","OneTimePrice": 20.0,"OneTimeValue": 20.0, "RecurringPrice": 20.0, "RecurringValue": 20.0,"Sequence": 49,"Status": "Active","Type": "%"}]');
        infos.put('clientSystem', 'Test');
        infos.put('catalogCategoryAndCatalogItems', JSON.serialize(mapCategoryIdCatalogItemList));
        infos.put('catalogCategoryAndOrderItems', JSON.serialize(mapCategoryIdOrderItemList));
        infos.put('mapCategoryHasChild', JSON.serialize(mapCategoryHasChild));
        infos.put('parentChildMap', JSON.serialize(parentChildMap));


        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new generateRequestTrue_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }

    @isTest
    static void cartApiCommoditySpainTest(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('AssetList', json.serialize([SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Asset]));
		infos.put('account', json.serialize([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c FROM Account LIMIT 1][0]));
        infos.put('NE__Account__c', '12345');
        infos.put('ConfId', '12345');
        infos.put('listOfAttributes', '[{"fields":{"id":"12345"}}]');
        infos.put('dataInterceptorString', 'testest');
        infos.put('ChannelCommodity', 'Test'); 
        infos.put('listOfAttributesDiscount', '[{"fields": { "LicName": "Tipo promocion"}, "listOfDomains":[ {"fields" : {"LicName" : "12 Meses 20%", "eligible" : "Y"}}]}]');
        infos.put('Discounts', '[ {"Code": "EXU","OneTimePrice": 20.0,"OneTimeValue": 20.0, "RecurringPrice": 20.0, "RecurringValue": 20.0,"Sequence": 49,"Status": "Active","Type": "%"}]');
        infos.put('clientSystem', 'Test');
        infos.put('familyPropertyIds', '{"555":"test"}');

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new generateRequestTrue_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }


    // Cart Checkout 1
    @isTest
    static void testCartCheckout1(){
		User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        List<XC_Voucher__c> voucherList = XC_DF_Voucher.generateSingleVoucher(1);
        voucherList[0].XC_CompanyCode__c = 'CompanyCode';
        voucherList[0].XC_CostCenter__c = 'CostCenter';
        insert voucherList;

        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('NE__Account__c', '12345');
        infos.put('XC_Coupon_Code__c', [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c);
        infos.put('ConfId', '12345');
        infos.put('dataInterceptorString', 'testest');
		infos.put('clientSystem', 'CommodityItalyB2C');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CartCheckout_Mock());
		XC_REST_CartAPI.cartCheckout(infos, 1);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
        }
    }


     // Cart Checkout 1
    @isTest
    static void testRemoveItems(){
		User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){

        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('NE__Account__c', '12345');
        infos.put('itemsToRemove', JSON.serialize(new List<String>{'22892'}));
        infos.put('ConfId', '12345');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RemoveItems_Mock());
		XC_REST_CartAPI.removeItems(infos);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
        }
    }

    // Manage external document
    @isTest
    static void testExternalDocument(){
        
    
        NE__Order__c order = [SELECT id FROM NE__order__c LIMIT 1][0];
        Map<String, String> infos = new Map<String, String>();

        XC_REST_MobilityOrder_W.OrderDocumentWrapper docWR = new XC_REST_MobilityOrder_W.OrderDocumentWrapper();
        docWR.ContractUrl = 'test.url.com';
        List<XC_REST_MobilityOrder_W.OrderDocumentWrapper> docList = new List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>();
        docList.add(docWR);
        infos.put('OrderDocument', JSON.serialize(docList));

        test.startTest();
		XC_REST_CartAPI_U.manageExternalDocument((String)order.Id, infos);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrderDocument'), 'Wrong assert result');
    }
    
    

    // Retrive Catalogs False
    @isTest
    static void testRetrieveCatalogsFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('XC_eMobTransactionId__c', 'test');
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateRequestRetrieveCatFalse_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }


    // Retrive Items False
    @isTest
    static void testRetriveItemsFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('XC_eMobTransactionId__c', 'test');
        //infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateRequestRetrieveItemFalse_Mock());
		System.enqueueJob(cartAPI);
        test.stopTest();

        System.assertNotEquals(null, infos.get('OrganizationId'), 'Wrong assert result');
    }
    
    
    @isTest
    static void DDcartApiTest0(){

        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 0, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();


    }
    
    @isTest
    static void DDcartApiTest1(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 1, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();


    }
    
    @isTest
    static void DDcartApiTest2(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 2, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();

    }
    
    @isTest
    static void DDcartApiTest3(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 3, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();


    }
    
    @isTest
    static void DDcartApiTest4(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 4, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();

    }
    
    @isTest
    static void DDcartApiTest5(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 5, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();

    }
    
    @isTest
    static void DDcartApiTest6(){
    
        Map<String, String> infos = setDDinfos();

        XC_REST_CartAPI cartAPI = new XC_REST_CartAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 6, 0));
            
            System.enqueueJob(cartAPI);

        test.stopTest();

    }
    
    public static Map<String, String> setDDinfos(){
        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('AssetList', json.serialize([SELECT XC_Address__c, XC_Product_Catalog_Category__c, NE__Bundle__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__Catalog__c, NE__CatalogItem__c, XC_Coverage_Asset_Type__c, id, Name, NE__Description__c, NE__Parent_Order_Item__c, NE__ProdId__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__Status__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c  FROM Asset]));
		infos.put('account', json.serialize([SELECT Id, XC_Segment__c, XC_IsEmployee__c, XC_AccountType__c, XC_RecordTypeDeveloperName__c FROM Account LIMIT 1][0]));
        infos.put('NE__Account__c', '12345');
        infos.put('ConfId', '12345');
        infos.put('listOfAttributes', '[{"fields":{"id":"12345"}}]');
        infos.put('dataInterceptorString', 'testest');
        infos.put('ChannelCommodity', 'Test'); 
        infos.put('fieldsDiscount', '{}'); 
        infos.put('listOfAttributesDiscount', '[{"fields": { "LicName": "Tipo promocion"}, "listOfDomains":[ {"fields" : {"LicName" : "EXU 20%", "eligible" : "Y"}}]}]');
        infos.put('Discounts', '[ {"Code": "EXU","OneTimePrice": 20.0,"OneTimeValue": 20.0, "RecurringPrice": 20.0, "RecurringValue": 20.0,"Sequence": 49,"Status": "Active","Type": "%"}]');
        infos.put('clientSystem', 'Test');
        infos.put('familyPropertyIds', '{"555":"test"}');
        Map<String, List<Object>> catalogItemAttributesMap = new Map<String, List<Object>>();
        Map<String, Object> fields = new Map<String, Object>();
        fields.put('id', '555');
        Map<String, Object> attribute = new Map<String, Object>();
        attribute.put('fields', fields);
        catalogItemAttributesMap.put('12345', new List<Object>{attribute});
        infos.put('catalogItemAttributesMap', JSON.serialize(catalogItemAttributesMap));
        List<XC_REST_MobilityOrder_W.OrderItemWrapper> orderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        XC_REST_MobilityOrder_W.OrderItemWrapper oiWr = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        oiWr.CatalogItemID = '12345';
        oiWr.Quantity = 1;
        oiWr.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        XC_REST_MobilityOrder_W.WrapperAttribute attrWr = new XC_REST_MobilityOrder_W.WrapperAttribute();
        attrWr.ProductFamilyPropertyID = '555';
        attrWr.Value = '000';
        oiWr.Attribute.add(attrWr);
        orderItemList.add(oiWr);
        infos.put('orderItemList', JSON.serialize(orderItemList));
        return infos;
    }
    
    public without sharing class DD_Callouts implements HttpCalloutMock {
        
        public Integer counter;
        public Integer maxCounter;
        public String errorCode;
        public Integer statusCode;
        
        public DD_Callouts(){
            this.counter = 0;
            this.maxCounter = 0;
            this.errorCode = '0';
            this.statusCode = 200;
        }
        public DD_Callouts(String errorCode, Integer statusCode, Integer maxCounter, Integer counter){
            this.counter = counter;
            this.maxCounter = maxCounter;
            this.errorCode = errorCode;
            this.statusCode = statusCode;
        }
        
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();
			System.debug('###@@@ : ' + String.valueOf(this.counter) + '/' + String.valueOf(this.maxCounter));
                if(this.counter >= this.maxCounter){
                    this.errorCode = '0';
                    this.statusCode = 503;
                }
                this.counter += 1;
            if(req.getEndpoint().endsWith('generateToken')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"errorCode":"' + this.errorCode + '","token":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                    response.setStatusCode(this.statusCode); 
                }else if(req.getEndpoint().endsWith('RetrieveCatalogs')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[],"listOfCategories":[{"id":"a1F6E0000011JTpUAM","categoryFields":{"countitem":0,"sequence":0,"name":"eHome-SPA","enginecode":"a0s1w0000004OeXAAU","visibleWeb":"true","hidden":"false","depth":0,"LicName":"eHome","CartMaxQTY":null,"commercial_visit_req":false,"skill":"","id":"a1F6E0000011JTpUAM","parentcategory":"","childCounter":0}}],"listOfBundle":[],"configuration":{},"cart":[],"additionalData":{},"action":null,"catalogs":[{"catalog":{"Name":"eHome","Id":"a1G6E000002ErMvUAK"}},{"catalog":{"Name":"E-mobility","Id":"a1G6E000002ErbcUAC"}}],"errorCode":"' + this.errorCode + '","errorMessage":""}');
                    response.setStatusCode(this.statusCode); 
                    
                } else if(req.getEndpoint().endsWith('RetrieveItems')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"sessionInfo":{"Id":"429e975b916b13c44fa1f7b3aed22bb9c7fd51ac"},"sessionParameters":{"confcurrency":"EUR","confCurrency":"EUR","ItemsForPage":"10","SelectedCategoryId":"a1F6E0000011XWxUAM","CurrentPage":"1","catalogId":"a1J6E000000QrQKUA0","isMultiCurrency":"false","GetAllData":true,"GetStructure":true,"countitem_a1F6E0000011JTpUAM":0,"countitem_a1F6E0000011XWrUAM":0,"countitem_a1F6E0000011XWxUAM":15},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"CorporatecarpoolOffer","LicCategoryName":"B2BRechargeManager","LicCatalogName":"E-mobility","productdescription":"","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Corporate_carpool_Offer_a0z0D000000FM88QAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dxQAC","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"","XC_Product_Subtype__c":"","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"12345","minqty":0,"categoryid":"a1F6E0000011XWxUAM","startdate":"20190404","productid":"a216E000000Dz1cQAC","catalogitemid":"a1I6E000000yAqqUAE","sequence":0,"name":"0610","recurringchargefrequency":"Monthly","categoryname":"B2BRechargeManager","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"CorporatecarpoolOffer","active":true,"enginecode":"a0z0D000000FM88QAG","visible":"false","thumbnailimage":"","productenginecode":"a1f0D000000D7dxQAC","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"crjpj4b7tg","itemCode":"crjpj4b7tg","itemheaderId":"","configurationtype":"","sourceId":"a0z0D000000FM88QAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm5QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Corporate","hidden":"false","id":"a1b6E000000DRm5QAG","LicName":"Corporate"}},{"id":"a1b6E000000DRm4QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Fake","hidden":"false","id":"a1b6E000000DRm4QAG","LicName":"Fake"}}],"listOfAttributes":[],"id":"a1I6E000000yAqqUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfCharacteristics":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfBundle":[],"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__CommercialModelId__c":"a1O6E000000FeddUAC","configurationdate":"2019-05-16T10:26:07.045Z"},"cart":[],"additionalData":{},"action":null,"errorCode":"' + this.errorCode + '","errorMessage":""}');
                    response.setStatusCode(this.statusCode); 
                    
                } else if(req.getEndpoint().endsWith('UpsertItems')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"' + this.errorCode + '","errorMessage":""}');
                                     response.setStatusCode(this.statusCode); 
                                     
                                     } else if(req.getEndpoint().endsWith('SaveConfiguration')) {
                                         response.setHeader('Content-Type', 'application/json');
                                         response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"' + this.errorCode + '","errorMessage":""}');
                                                          response.setStatusCode(this.statusCode); 
                                                          
                                                          }else if(req.getEndpoint().endsWith('RemoveItems')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"removeItems": {"sessionInfo": {"Id": "27e174239d68dc7e851f51199c07693e6da169ce"},"sessionParameters": {},"page": "","language": "en_US","complexProductId": "","categoryId": "a1p0D000003bh38QAA","catalogId": "a1t0D000000QFjqQAG","itemsToRemove": [{"fields": {"itemCode": "fbgtoiv1f-step-2"}}]} }');
                response.setStatusCode(this.statusCode); 
            }else if(req.getEndpoint().endsWith('B2WGin_retrieveData')){
                response.setHeader('Content-Type', 'application/json');
                String result = '{"sessionParameters":{},"sessionInfo":{"attributes":{"type":"NE__Bit2Win_Session__c"}},"messages":[],"listOfItems":[],"listOfCategories":[],"listOfBundle":[],"errorMessage":"","errorCode":"' + this.errorCode + '","configuration":{"attributes":{"type":"NE__Order__c","url":"/services/data/v46.0/sobjects/NE__Order__c/a1x6E000000EpFlQAK"},"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__OptyId__c":"0066E000006XV6ZQAW","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__BillAccId__c":"0016E00000pFqsTQAS","NE__Configuration_SubType__c":"Standard","NE__AccountId__c":"0016E00000pFqsTQAS","XC_RegisteredOnRechargeApp__c":true,"NE__OrderStatus__c":"Pending","NE__Recurring_Charge_Total__c":0.0,"NE__Configuration_Type__c":"New","B2WZC__ZPaymentMethodType__c":"OneShot","XC_eMobTransactionId__c":"ed412c29-2e54-4d69-8b5f-557943adf13d","RecordTypeId":"0126E000000EwzIQAS","NE__ServAccId__c":"0016E00000pFqsTQAS","NE__One_Time_Fee_Total__c":15.0,"Id":"' + [SELECT Id FROM NE__Order__c][0].Id + '","XC_OrderBillingAddress__c":"a4p6E000000Cff4QAC","NE__Type__c":"InOrder","NE__Channel__c":"Web","NE__ConfigurationStatus__c":"Valid","XC_SubChannel__c":"APP"},"cart":[{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[{"fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":"0","name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYUQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_w3wz5e0de-step-1","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"15","configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Human","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"Pay Per Use Basic","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"Recharge service with payment at the end of each recharge session based on the kWh consumed. The fee for quick chargers is € 0.35 / kWh and for  fast chargers € 0.49 / kWh. The registration fee is € 15 and includes a free coupon of 50kWh (valid for the first 3 months of the contract, from the date of subscription) and the new RFID card of Endesa X.","CategoryShippingCostOverride":"0","XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Basic_a0z0D000000FM0hQAG_E-mobility","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"15","recurringchargediscounted":"0","onetimefeeov":"15","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a1f0D000000D7dIQAS","HasUsage":"true","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"15","NE__UsageCode__c":"","qty":"1","maxqty":"999","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqXUAU","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1JQAS","catalogitemid":"a1I6E000000yAqXUAU","sequence":"0","name":"0591","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"Pay Per Use","active":"true","enginecode":"a0z0D000000FM0hQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dIQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"w3wz5e0de-step-1","itemCode":"w3wz5e0de-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0hQAG","startingbaseonetimefee":"15","productcatalogitem":"","isCart":"true"},"childItems":[]},{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYVQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_287fa917","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"0","configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Engine","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"RFID card for recharge service","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"0","recurringchargediscounted":"0","onetimefeeov":"0","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a2b9E000000434SQAQ","HasUsage":"false","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"0","NE__UsageCode__c":"","qty":"1","maxqty":"1","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":"0","name":"0699","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":"true","enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"287fa917","itemCode":"287fa917","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":"0","productcatalogitem":""},"childItems":[]}],"additionalData":{},"action":null}';
                result = result.escapeJava();
                response.setBody('{"result":"' + result + '","errorMessage":"","errorCode":"' + this.errorCode + '"}');
                response.setStatusCode(this.statusCode); 
            }

            return response;
        }
    }


    public without sharing class GenerateRequestTrue_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('generateToken')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","token":"cab1cf94d366a93c952a6c634c36d43320f"}');
                response.setStatusCode(200); 
            }else if(req.getEndpoint().endsWith('RetrieveCatalogs')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[],"listOfCategories":[{"id":"a1F6E0000011JTpUAM","categoryFields":{"countitem":0,"sequence":0,"name":"eHome-SPA","enginecode":"a0s1w0000004OeXAAU","visibleWeb":"true","hidden":"false","depth":0,"LicName":"eHome","CartMaxQTY":null,"commercial_visit_req":false,"skill":"","id":"a1F6E0000011JTpUAM","parentcategory":"","childCounter":0}}],"listOfBundle":[],"configuration":{},"cart":[],"additionalData":{},"action":null,"catalogs":[{"catalog":{"Name":"eHome","Id":"a1G6E000002ErMvUAK"}},{"catalog":{"Name":"E-mobility","Id":"a1G6E000002ErbcUAC"}}],"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
            }
            else if(req.getEndpoint().endsWith('RetrieveItems')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"429e975b916b13c44fa1f7b3aed22bb9c7fd51ac"},"sessionParameters":{"confcurrency":"EUR","confCurrency":"EUR","ItemsForPage":"10","SelectedCategoryId":"a1F6E0000011XWxUAM","CurrentPage":"1","catalogId":"a1J6E000000QrQKUA0","isMultiCurrency":"false","GetAllData":true,"GetStructure":true,"countitem_a1F6E0000011JTpUAM":0,"countitem_a1F6E0000011XWrUAM":0,"countitem_a1F6E0000011XWxUAM":15},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"CorporatecarpoolOffer","LicCategoryName":"B2BRechargeManager","LicCatalogName":"E-mobility","productdescription":"","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Corporate_carpool_Offer_a0z0D000000FM88QAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dxQAC","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"","XC_Product_Subtype__c":"","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"12345","minqty":0,"categoryid":"a1F6E0000011XWxUAM","startdate":"20190404","productid":"a216E000000Dz1cQAC","catalogitemid":"a1I6E000000yAqqUAE","sequence":0,"name":"0610","recurringchargefrequency":"Monthly","categoryname":"B2BRechargeManager","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"CorporatecarpoolOffer","active":true,"enginecode":"a0z0D000000FM88QAG","visible":"false","thumbnailimage":"","productenginecode":"a1f0D000000D7dxQAC","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"crjpj4b7tg","itemCode":"crjpj4b7tg","itemheaderId":"","configurationtype":"","sourceId":"a0z0D000000FM88QAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm5QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Corporate","hidden":"false","id":"a1b6E000000DRm5QAG","LicName":"Corporate"}},{"id":"a1b6E000000DRm4QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Fake","hidden":"false","id":"a1b6E000000DRm4QAG","LicName":"Fake"}}],"listOfAttributes":[],"id":"a1I6E000000yAqqUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfCharacteristics":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfBundle":[],"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__CommercialModelId__c":"a1O6E000000FeddUAC","configurationdate":"2019-05-16T10:26:07.045Z"},"cart":[{"fields":{"eligible":"Y","NE__UsageCode__c":"12345","NE__SmartPartNumber__c":"","eligibilitycomments":"","visible":"true","configurationstatus":"Valid"},"listOfAttributes":[{"id":"a2Y5E000000LcHzUAK","fields":{"readonly":"true","hiddenInCart":false,"propid":"a275E000001DZk3QAG","familyProperty":"Payment details:Payment Method"}}]}],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200);
            }
            else if(req.getEndpoint().endsWith('UpsertItems')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","errorMessage":"","sessionInfo": {"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"eligible":"Y","NE__UsageCode__c":"12345","NE__SmartPartNumber__c":"","eligibilitycomments":"","visible":"true","configurationstatus":"Valid"},"listOfAttributes":[{"id":"a2Y5E000000LcHzUAK","fields":{"readonly":"true","hiddenInCart":false,"propid":"a275E000001DZk3QAG","familyProperty":"Payment details:Payment Method"}}],"childItems":[{"fields":{"LicProductName":"Promocion","XC_Product_Type__c":"Billing","XC_Product_Subtype__c":"Promotion"},"listOfAttributes":[{"fields":{"LicName":"Tipo promocion"},"listOfDomains":[{"fields":{"eligible":"Y","LicName":"12 Meses 20%"}}]}]},{"fields":{"NE__UsageCode__c":"56789"},"listOfAttributes":[{"fields":{"Value":"Test"}}]}]}],"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
            }else if(req.getEndpoint().endsWith('SaveConfiguration')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","errorMessage":"","sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
            }else if(req.getEndpoint().endsWith('RemoveItems')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"removeItems": {"sessionInfo": {"Id": "27e174239d68dc7e851f51199c07693e6da169ce"},"sessionParameters": {},"page": "","language": "en_US","complexProductId": "","categoryId": "a1p0D000003bh38QAA","catalogId": "a1t0D000000QFjqQAG","itemsToRemove": [{"fields": {"itemCode": "fbgtoiv1f-step-2"}}]} }');
                response.setStatusCode(200); 
            }else if(req.getEndpoint().endsWith('B2WGin_retrieveData')){
                response.setHeader('Content-Type', 'application/json');
                String result = '{"sessionParameters":{},"sessionInfo":{"attributes":{"type":"NE__Bit2Win_Session__c"}},"messages":[],"listOfItems":[],"listOfCategories":[],"listOfBundle":[],"errorMessage":"","errorCode":"0","configuration":{"attributes":{"type":"NE__Order__c","url":"/services/data/v46.0/sobjects/NE__Order__c/a1x6E000000EpFlQAK"},"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__OptyId__c":"0066E000006XV6ZQAW","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__BillAccId__c":"0016E00000pFqsTQAS","NE__Configuration_SubType__c":"Standard","NE__AccountId__c":"0016E00000pFqsTQAS","XC_RegisteredOnRechargeApp__c":true,"NE__OrderStatus__c":"Pending","NE__Recurring_Charge_Total__c":0.0,"NE__Configuration_Type__c":"New","B2WZC__ZPaymentMethodType__c":"OneShot","XC_eMobTransactionId__c":"ed412c29-2e54-4d69-8b5f-557943adf13d","RecordTypeId":"0126E000000EwzIQAS","NE__ServAccId__c":"0016E00000pFqsTQAS","NE__One_Time_Fee_Total__c":15.0,"Id":"' + [SELECT Id FROM NE__Order__c][0].Id + '","XC_OrderBillingAddress__c":"a4p6E000000Cff4QAC","NE__Type__c":"InOrder","NE__Channel__c":"Web","NE__ConfigurationStatus__c":"Valid","XC_SubChannel__c":"APP"},"cart":[{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[{"fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":"0","name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYUQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_w3wz5e0de-step-1","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"15","configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Human","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"Pay Per Use Basic","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"Recharge service with payment at the end of each recharge session based on the kWh consumed. The fee for quick chargers is € 0.35 / kWh and for  fast chargers € 0.49 / kWh. The registration fee is € 15 and includes a free coupon of 50kWh (valid for the first 3 months of the contract, from the date of subscription) and the new RFID card of Endesa X.","CategoryShippingCostOverride":"0","XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Basic_a0z0D000000FM0hQAG_E-mobility","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"15","recurringchargediscounted":"0","onetimefeeov":"15","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a1f0D000000D7dIQAS","HasUsage":"true","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"15","NE__UsageCode__c":"","qty":"1","maxqty":"999","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqXUAU","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1JQAS","catalogitemid":"a1I6E000000yAqXUAU","sequence":"0","name":"0591","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"Pay Per Use","active":"true","enginecode":"a0z0D000000FM0hQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dIQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"w3wz5e0de-step-1","itemCode":"w3wz5e0de-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0hQAG","startingbaseonetimefee":"15","productcatalogitem":"","isCart":"true"},"childItems":[]},{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYVQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_287fa917","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"0","configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Engine","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"RFID card for recharge service","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"0","recurringchargediscounted":"0","onetimefeeov":"0","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a2b9E000000434SQAQ","HasUsage":"false","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"0","NE__UsageCode__c":"","qty":"1","maxqty":"1","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":"0","name":"0699","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":"true","enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"287fa917","itemCode":"287fa917","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":"0","productcatalogitem":""},"childItems":[]}],"additionalData":{},"action":null}';
                result = result.escapeJava();
                response.setBody('{"result":"' + result + '","errorMessage":"","errorCode":"0"}');
                response.setStatusCode(200); 
            }

            return response;
        }
    }


    public without sharing class GenerateRequestRetrieveItemFalse_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('generateToken')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","token":"cab1cf94d366a93c952a6c634c36d43320f"}');
                response.setStatusCode(200); 
            }
            else if(req.getEndpoint().endsWith('RetrieveCatalogs')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[],"listOfCategories":[{"id":"a1F6E0000011JTpUAM","categoryFields":{"countitem":0,"sequence":0,"name":"eHome-SPA","enginecode":"a0s1w0000004OeXAAU","visibleWeb":"true","hidden":"false","depth":0,"LicName":"eHome","CartMaxQTY":null,"commercial_visit_req":false,"skill":"","id":"a1F6E0000011JTpUAM","parentcategory":"","childCounter":0}}],"listOfBundle":[],"configuration":{},"cart":[],"additionalData":{},"action":null,"catalogs":[{"catalog":{"Name":"eHome","Id":"a1G6E000002ErMvUAK"}},{"catalog":{"Name":"E-mobility","Id":"a1G6E000002ErbcUAC"}}],"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
            }
            else if(req.getEndpoint().endsWith('RetrieveItems')) {
                response.setHeader('Content-Type', 'application/json');
                  response.setBody('{"sessionInfo":{"Id":"429e975b916b13c44fa1f7b3aed22bb9c7fd51ac"},"sessionParameters":{"confcurrency":"EUR","confCurrency":"EUR","ItemsForPage":"10","SelectedCategoryId":"a1F6E0000011XWxUAM","CurrentPage":"1","catalogId":"a1J6E000000QrQKUA0","isMultiCurrency":"false","GetAllData":true,"GetStructure":true,"countitem_a1F6E0000011JTpUAM":0,"countitem_a1F6E0000011XWrUAM":0,"countitem_a1F6E0000011XWxUAM":15},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"CorporatecarpoolOffer","LicCategoryName":"B2BRechargeManager","LicCatalogName":"E-mobility","productdescription":"","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Corporate_carpool_Offer_a0z0D000000FM88QAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dxQAC","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"","XC_Product_Subtype__c":"","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"12345","minqty":0,"categoryid":"a1F6E0000011XWxUAM","startdate":"20190404","productid":"a216E000000Dz1cQAC","catalogitemid":"a1I6E000000yAqqUAE","sequence":0,"name":"0610","recurringchargefrequency":"Monthly","categoryname":"B2BRechargeManager","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"CorporatecarpoolOffer","active":true,"enginecode":"a0z0D000000FM88QAG","visible":"false","thumbnailimage":"","productenginecode":"a1f0D000000D7dxQAC","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"crjpj4b7tg","itemCode":"crjpj4b7tg","itemheaderId":"","configurationtype":"","sourceId":"a0z0D000000FM88QAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm5QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Corporate","hidden":"false","id":"a1b6E000000DRm5QAG","LicName":"Corporate"}},{"id":"a1b6E000000DRm4QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Fake","hidden":"false","id":"a1b6E000000DRm4QAG","LicName":"Fake"}}],"listOfAttributes":[],"id":"a1I6E000000yAqqUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfCharacteristics":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfBundle":[],"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__CommercialModelId__c":"a1O6E000000FeddUAC","configurationdate":"2019-05-16T10:26:07.045Z"},"cart":[],"additionalData":{},"action":null,"errorCode":"-1","errorMessage":""}');
                response.setStatusCode(200);
            }

            return response;
        }
    }

    public without sharing class GenerateRequestRetrieveCatFalse_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('generateToken')){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","token":"cab1cf94d366a93c952a6c634c36d43320f"}');
                response.setStatusCode(200); 
            }
            else if(req.getEndpoint().endsWith('RetrieveCatalogs')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[],"listOfCategories":[{"id":"a1F6E0000011JTpUAM","categoryFields":{"countitem":0,"sequence":0,"name":"eHome-SPA","enginecode":"a0s1w0000004OeXAAU","visibleWeb":"true","hidden":"false","depth":0,"LicName":"eHome","CartMaxQTY":null,"commercial_visit_req":false,"skill":"","id":"a1F6E0000011JTpUAM","parentcategory":"","childCounter":0}}],"listOfBundle":[],"configuration":{},"cart":[],"additionalData":{},"action":null,"catalogs":[{"catalog":{"Name":"eHome","Id":"a1G6E000002ErMvUAK"}},{"catalog":{"Name":"E-mobility","Id":"a1G6E000002ErbcUAC"}}],"errorCode":"-1","errorMessage":"error"}');
                response.setStatusCode(200); 
            }

            return response;
        }
    }

    public without sharing class CartCheckout_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String result = '{"sessionParameters":{},"sessionInfo":{"attributes":{"type":"NE__Bit2Win_Session__c"}},"messages":[],"listOfItems":[],"listOfCategories":[],"listOfBundle":[],"errorMessage":"","errorCode":"0","configuration":{"attributes":{"type":"NE__Order__c","url":"/services/data/v46.0/sobjects/NE__Order__c/a1x6E000000EpFlQAK"},"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__OptyId__c":"0066E000006XV6ZQAW","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__BillAccId__c":"0016E00000pFqsTQAS","NE__Configuration_SubType__c":"Standard","NE__AccountId__c":"0016E00000pFqsTQAS","XC_RegisteredOnRechargeApp__c":true,"NE__OrderStatus__c":"Pending","NE__Recurring_Charge_Total__c":0.0,"NE__Configuration_Type__c":"New","B2WZC__ZPaymentMethodType__c":"OneShot","XC_eMobTransactionId__c":"ed412c29-2e54-4d69-8b5f-557943adf13d","RecordTypeId":"0126E000000EwzIQAS","NE__ServAccId__c":"0016E00000pFqsTQAS","NE__One_Time_Fee_Total__c":15.0,"Id":"' + [SELECT Id FROM NE__Order__c][0].Id + '","XC_OrderBillingAddress__c":"a4p6E000000Cff4QAC","NE__Type__c":"InOrder","NE__Channel__c":"Web","NE__ConfigurationStatus__c":"Valid","XC_SubChannel__c":"APP"},"cart":[{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[{"fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":"0","name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYUQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_w3wz5e0de-step-1","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"15","configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Human","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"Pay Per Use Basic","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"Recharge service with payment at the end of each recharge session based on the kWh consumed. The fee for quick chargers is € 0.35 / kWh and for  fast chargers € 0.49 / kWh. The registration fee is € 15 and includes a free coupon of 50kWh (valid for the first 3 months of the contract, from the date of subscription) and the new RFID card of Endesa X.","CategoryShippingCostOverride":"0","XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Basic_a0z0D000000FM0hQAG_E-mobility","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"15","recurringchargediscounted":"0","onetimefeeov":"15","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a1f0D000000D7dIQAS","HasUsage":"true","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"15","NE__UsageCode__c":"","qty":"1","maxqty":"999","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqXUAU","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1JQAS","catalogitemid":"a1I6E000000yAqXUAU","sequence":"0","name":"0591","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"Pay Per Use","active":"true","enginecode":"a0z0D000000FM0hQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dIQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"w3wz5e0de-step-1","itemCode":"w3wz5e0de-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0hQAG","startingbaseonetimefee":"15","productcatalogitem":"","isCart":"true"},"childItems":[]},{"listOfRules":null,"listOfPenalties":[],"listOfFamilies":[],"listOfDiscounts":[],"listOfAttributes":[],"fields":{"ConfigurationItemId":"a1t6E000004jMYVQA2","NE__Configuration_item_update_key__c":"a1x6E000000EpFlQAK_287fa917","configurationRecurringCharge":"0","hasDefaultChildren":"false","configurationOneTimeFee":"0","configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":"false","Picked_By__c":"Engine","onetimefeeovapplied":"false","recurringchargeovapplied":"false","requiredChildren":"","rootRequiredAdded":"true","configured__c":"false","eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":"0","visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"App Mobile","LicCatalogName":"E-mobility","productdescription":"RFID card for recharge service","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":"0","CategoryShippingCostThreshold":"0","skill":"","partnumber":"","usagecode":"","hiddenInCart":"false","onetimefeediscounted":"0","recurringchargediscounted":"0","onetimefeeov":"0","recurringchargeov":"0","recurringeditable":"false","onetimeeditable":"false","productexternalid":"a2b9E000000434SQAQ","HasUsage":"false","ConvergentBillType":"","StartingFrom":null,"EligibleAccountType":"","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":"0","baseonetimefee":"0","NE__UsageCode__c":"","qty":"1","maxqty":"1","unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":"false","NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":"false","NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":"0","categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":"0","name":"0699","recurringchargefrequency":"Monthly","categoryname":"App Mobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":"true","enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"287fa917","itemCode":"287fa917","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":"0","productcatalogitem":""},"childItems":[]}],"additionalData":{},"action":null}';
            result = result.escapeJava();
            response.setBody('{"result":"' + result + '","errorMessage":"","errorCode":"0"}');
            response.setStatusCode(200); 
            return response;
        }
    }

     public without sharing class RemoveItems_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String result = '{"sessionInfo": {"Id": "27e174239d68dc7e851f51199c07693e6da169ce"},"sessionParameters": {"catalogId": "a1t0D000000QFjqQAG","GetAllData": false,"dateTarget": "2020-11-19T14:36:51.561+0200","CurrentPage": "1","UserChannel": "Commodity Partner","GetStructure": false,"ItemsForPage": "100","confcurrency": "COP","userLanguage": "it","priceListName": "eHome - COL","validateitems": "false","sourcePlatform": "CRM","isMultiCurrency": "false","currentcatalogid": "a1t0D000000QFjqQAG","SelectedCategoryId": "a1p0D000003bh38QAA","currentcatalogname": "eHome - COL"}}';
            result = result.escapeJava();
            response.setBody('{"result":"' + result + '","errorMessage":"","errorCode":"0"}');
            response.setStatusCode(200); 
            return response;
        }
    }

}