/**
 * The Class XC_REST_ChangeAPI_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 20/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_ChangeAPI
 **/


@isTest
public without sharing class XC_REST_ChangeAPI_TEST {

    
    @TestSetup
    static void setup(){ 
       /* OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;*/
		insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<XC_CS_UtilityGlobalValues__c> csList = new List<XC_CS_UtilityGlobalValues__c>();
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_ChangeAPI_ActiveRetry', Value__c = 'True'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_ChangeAPI_Nattempts', Value__c = '1'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_ChangeAPI_errorStatusSet', Value__c = '503;'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_ActiveRetry', Value__c = 'True'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_Nattempts', Value__c = '1'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_errorStatusSet', Value__c = '503;'));
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_ChangeAPI_Sleep', Value__c = '1000')); //[DeAv 16/12/2021 added row for code coverage]
        csList.add(new XC_CS_UtilityGlobalValues__c(Name='XC_REST_CartAPI_Sleep', Value__c = '1000')); //[DeAv 16/12/2021 added row for code coverage]
        insert csList;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        insert catItem;

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = '{"Order":{"Channel":"EnelEnergiaItalia","Document":[{"ContractUrl":"http:z"}],"IntegrationID":"1231213123","LegalEntity":"EnelXItalia","OrderItem":[{"Attribute":[{"Name":"Test:Pfp","ProductFamilyPropertyID":"a1V1l000000PNaMEAW","Value":"Monthly"}],"BaseOneTimeFee":0.00,"BaseRecurringCharge":7.50,"BundleConfiguration":null,"ContractType":"Light","ProdID":"TestCatItem","Quantity":1}],"OrderStatus":"In progress"}}';
        qr.XC_ClientSystem__c = 'CommodityItalyB2C';
        qr.XC_TransactionId__c = 'Test';
        insert qr;
    }


    // ChangeAPI True
    @isTest
    static void testChangeAPITrue(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ChangeAPITrue_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    // ChangeAPI True - UniqueService
    @isTest
    static void testChangeAPIUniqueServiceTrue(){

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
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('account', Json.Serialize(new Map<String, Object>()));
        infos.put('configurationInfos', Json.Serialize(new Map<String, Object>()));
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));
        infos.put('catalogCategoryAndCatalogItems', JSON.serialize(mapCategoryIdCatalogItemList));
        infos.put('catalogCategoryAndOrderItems', JSON.serialize(mapCategoryIdOrderItemList));

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ChangeAPITrue_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    public without sharing class ChangeAPITrue_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/services/apexrest/NE/GetConfigurationXML')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","orderXml":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('bit2winapis/generateToken')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('<tokenResponse><errorCode>0</errorCode><errorMessage></errorMessage><token>jifc57ttgf8o9e33bja0a6ld2</token></tokenResponse>');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('bit2winapis/applyChangeOrder')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"ApplyChangeOrderMessage":{"changeResult":{"serviceaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__TotalRecurringFrequency__c":"","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__type__c":"ChangeOrder","NE__accountid__c":"0016E00000mz6PYQAY","channel":"","billprofid":"","NE__Recurring_Charge_Total__c":0,"datamapname":"sfdcAsset2Xml","assetitementerpriseid":"02i6E000004SNfYQAW","RecordTypeId":"0126E000000EwzJQAS","NE__billingprofid__c":"","NE__servaccid__c":"0016E00000mz6PYQAY","NE__Quote__c":"","NE__EngineType__c":"b2wgin","NE__OptyId__c":"0066E0000071GsfQAE","NE__configurationstatus__c":"Inprogress","NE__billaccid__c":"0016E00000mz6PYQAY","NE__Version__c":0,"configuration_type":"Change","NE__OrderStatus__c":"Pending","configuration_subtype":"Changeorder","NE__order_date__c":"2019-06-18","NE__One_Time_Fee_Total__c":0,"parameters":""},"billingaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"account":{"accountid":"","Country__c":"","scoring":"","subsector":"","accounttype":"","AccntId":"","industry":"","company":"","XC_AccountType":"Residential","sector":"","BirthDate":"","desctiption":""},"cartitem":[{"listOfAttributes":[],"listOfCharacteristic":[{"fields":{"compare":"","visible":false,"productid":"","valueboolean":false,"parentid":"","valuenumber":0,"filter":"","sequence":0,"name":"RFID:","ranking":"","id":"a1V6E000009H9IhUAK","valuedate":"","value":"Yes"}}],"childItems":[],"fields":{"complexcategoryname":"","parent":"","ConvergentBillType":"","orderitempromoid":"","productid":"a216E000000Dz1LQAS","recurringeditable":false,"bundleElement":"","XC_Product_Type__c":"Service","startdate":"","type":"Product","sourcelineitemid":"","vid":"02i6E000004SNfYQAW","LicProductName":"FlatSmall","recurringchargediscounted":16.99,"NE__Penalty__c":false,"context":"true","taxmodelsapplied":"","configurationRecurringCharge":0,"itemHeader":"","reservation":"","action":"None","id":"a1I6E000000yAqZUAU","billaccount":"0016E00000mz6PYQAY","discountid":"","brand":"","XC_Product_Subtype__c":"Tariff","recurringchargetaxfree":"16.99","recurringchargeov":16.99,"pickedby":"Human","XC_Discounted_Recurring_duration__c":0,"usagecode":"","NE__Commitment_UOM__c":"","active":true,"configurationtype":"Standard","prodid":"a216E000000Dz1LQAS","MinAge":0,"catalogid":"a1J6E000000QrQKUA0","enddate":"","NE__Commitment__c":false,"visiblefromdb":"true","XC_ineligible_channels":"","thumbnailimage":"","asset_item_account":"","recurringchargeovapplied":false,"status":"Active","parentvid":"","NE__Penalty_Type__c":"","Picked_By__c":"Human","productenginecode":"a1f0D000000D7dKQAS","XC_Orig_RecurringCharge__c":0,"XC_Business_Line":"","programname":"Flat_Small_a0z0D000000FM0jQAG_E-mobility","onetimefeeov":0.00,"account":"0016E00000mz6PYQAY"}}]},"errorCode":"0"}}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('generateToken')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","token":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                response.setStatusCode(200); 
                
            } else if(req.getEndpoint().endsWith('RetrieveCatalogs')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[],"listOfCategories":[{"id":"a1F6E0000011JTpUAM","categoryFields":{"countitem":0,"sequence":0,"name":"eHome-SPA","enginecode":"a0s1w0000004OeXAAU","visibleWeb":"true","hidden":"false","depth":0,"LicName":"eHome","CartMaxQTY":null,"commercial_visit_req":false,"skill":"","id":"a1F6E0000011JTpUAM","parentcategory":"","childCounter":0}}],"listOfBundle":[],"configuration":{},"cart":[],"additionalData":{},"action":null,"catalogs":[{"catalog":{"Name":"eHome","Id":"a1G6E000002ErMvUAK"}},{"catalog":{"Name":"E-mobility","Id":"a1G6E000002ErbcUAC"}}],"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
                
            } else if(req.getEndpoint().endsWith('RetrieveItems')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"429e975b916b13c44fa1f7b3aed22bb9c7fd51ac"},"sessionParameters":{"confcurrency":"EUR","confCurrency":"EUR","ItemsForPage":"10","SelectedCategoryId":"a1F6E0000011XWxUAM","CurrentPage":"1","catalogId":"a1J6E000000QrQKUA0","isMultiCurrency":"false","GetAllData":true,"GetStructure":true,"countitem_a1F6E0000011JTpUAM":0,"countitem_a1F6E0000011XWrUAM":0,"countitem_a1F6E0000011XWxUAM":15},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"CorporatecarpoolOffer","LicCategoryName":"B2BRechargeManager","LicCatalogName":"E-mobility","productdescription":"","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Corporate_carpool_Offer_a0z0D000000FM88QAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dxQAC","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"","XC_Product_Subtype__c":"","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"12345","minqty":0,"categoryid":"a1F6E0000011XWxUAM","startdate":"20190404","productid":"a216E000000Dz1cQAC","catalogitemid":"a1I6E000000yAqqUAE","sequence":0,"name":"0610","recurringchargefrequency":"Monthly","categoryname":"B2BRechargeManager","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"CorporatecarpoolOffer","active":true,"enginecode":"a0z0D000000FM88QAG","visible":"false","thumbnailimage":"","productenginecode":"a1f0D000000D7dxQAC","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"crjpj4b7tg","itemCode":"crjpj4b7tg","itemheaderId":"","configurationtype":"","sourceId":"a0z0D000000FM88QAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm5QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Corporate","hidden":"false","id":"a1b6E000000DRm5QAG","LicName":"Corporate"}},{"id":"a1b6E000000DRm4QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Fake","hidden":"false","id":"a1b6E000000DRm4QAG","LicName":"Fake"}}],"listOfAttributes":[],"id":"a1I6E000000yAqqUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfCharacteristics":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IvUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1cQAC"},"id":"a1V6E000009H9IvUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfBundle":[],"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__CommercialModelId__c":"a1O6E000000FeddUAC","configurationdate":"2019-05-16T10:26:07.045Z"},"cart":[],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 
            
            } else if(req.getEndpoint().endsWith('UpsertItems')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('SaveConfiguration')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"sessionInfo":{"Id":"327a20985b1d14519587705635a475b996534ea3"},"sessionParameters":{},"messages":[],"listOfItems":[{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":false,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":"","bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"PayPerUseGuestUser","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"ChargingservicewithpaymentattheendofeachrechargesessionofafeeparameterisedtothekWhwithdrawn.TheservicefeeisdifferentiatedbetweenEndesaQuickplug0,45€/kWh,EndesaFastplug0,59€/kWh.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Pay_Per_Use_Guest_User_a0z0D000000FM0rQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dSQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":0,"maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqhUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1TQAS","catalogitemid":"a1I6E000000yAqhUAE","sequence":0,"name":"0601","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"PayPerUseGuestUser","active":true,"enginecode":"a0z0D000000FM0rQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dSQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"0ov479y9b","itemCode":"0ov479y9b","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0rQAG","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[{"id":"a1b6E000000DRm1QAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Guest","hidden":"false","id":"a1b6E000000DRm1QAG","LicName":"Guest"}}],"listOfAttributes":[],"id":"a1I6E000000yAqhUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IoUAK","name":"RFID:","value":"No","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1TQAS"},"id":"a1V6E000009H9IoUAK"}],"listOfDiscounts":[],"listOfPenalties":[]}],"listOfCategories":[],"listOfBundle":[],"configuration":{"NE__type__c":"InOrder","NE__Recurring_Charge_Total__c":31.99,"NE__One_Time_Fee_Total__c":0,"NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__configurationstatus__c":"Valid","NE__ConfigurationStatus__c":"Valid","editableprices":false},"cart":[{"fields":{"configurationRecurringCharge":31.99,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"Monthly","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Human","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":31.99,"visiblefromdb":"true","cartDescription":"","deeprelationship":"Product","LicProductName":"FlatMedium","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"MonthlyrechargeservicewithafixedamountofkWh.Whenthethresholdisexceeded,payperusebillingisactivated.IncludesthenewRFIDcardfromEndesaX.","CategoryShippingCostOverride":0,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"Flat_Medium_a0z0D000000FM0kQAG_E-mobility","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":31.99,"onetimefeeov":0,"recurringchargeov":31.99,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a1f0D000000D7dLQAS","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":31.99,"baseonetimefee":0,"NE__UsageCode__c":"","qty":"1","maxqty":999,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"Tariff","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yAqaUAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20190404","productid":"a216E000000Dz1MQAS","catalogitemid":"a1I6E000000yAqaUAE","sequence":0,"name":"0594","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"FlatMedium","active":true,"enginecode":"a0z0D000000FM0kQAG","visible":"true","thumbnailimage":"","productenginecode":"a1f0D000000D7dLQAS","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cl2evgas97-step-1","itemCode":"cl2evgas97-step-1","itemheaderId":"","configurationtype":"Standard","sourceId":"a0z0D000000FM0kQAG","startingbaseonetimefee":0,"productcatalogitem":"","isCart":true},"listOfFamilies":[{"id":"a1b6E000000DRlwQAG","fields":{"TestDateField":"","TestBoolenField":null,"TestDouble":null,"TestDecimalField":null,"TestNumericField":null,"numberOfAttributes":0,"name":"Private","hidden":"false","id":"a1b6E000000DRlwQAG","LicName":"Private"}}],"listOfAttributes":[],"id":"a1I6E000000yAqaUAE","listOfCharacteristic":[{"fields":{"compare":"false","valueboolean":false,"ranking":"","filter":"false","sequence":"1","id":"a1V6E000009H9IiUAK","name":"RFID:","value":"Yes","valuedate":"","valuenumber":null,"visible":true,"productid":"a216E000000Dz1MQAS"},"id":"a1V6E000009H9IiUAK"}],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]},{"fields":{"configurationRecurringCharge":0,"hasDefaultChildren":false,"configurationOneTimeFee":0,"configurationRecurringFrequency":"","XC_RelatedProduct__c":"","XC_Discounted_OneTime_price__c":null,"XC_Discounted_Recurring_price__c":null,"XC_Discount_Reason__c":"","XC_Discounted_Recurring_duration__c":null,"XC_Orig_OneTimeFee__c":null,"XC_Orig_RecurringCharge__c":null,"isCatalogItem":false,"Picked_By__c":"Engine","onetimefeeovapplied":false,"recurringchargeovapplied":false,"requiredChildren":"","rootRequiredAdded":true,"configured__c":false,"eligible":"Y","NE__SmartPartNumber__c":"","eligibilitycomments":"","orderitemid":"","configurationstatus":"Valid","source":"","bundleElement":"","bundleId":null,"bundlevid":"","logicalParent":"","startingbaserecurringcharge":0,"visiblefromdb":"false","cartDescription":"","deeprelationship":"Product","LicProductName":"RFIDautoadd","LicCategoryName":"AppMobile","LicCatalogName":"E-mobility","productdescription":"RFIDcardforrechargeservice","CategoryShippingCostOverride":null,"XC_Brand":"","MinAge":null,"MaxAge":null,"taxcode":"","shortdescription":"","brand":"","XC_ineligible_channels":"","programname":"a1s9E000000JSAkQAO_a140D000000DWjVQAW","CategoryShippingCost":0,"CategoryShippingCostThreshold":0,"skill":"","partnumber":"","usagecode":"","hiddenInCart":false,"onetimefeediscounted":0,"recurringchargediscounted":0,"onetimefeeov":0,"recurringchargeov":0,"recurringeditable":false,"onetimeeditable":false,"productexternalid":"a2b9E000000434SQAQ","NE__Penalty_Type__c":"","promotionid":"","baserecurringcharge":0,"baseonetimefee":0,"NE__UsageCode__c":"","qty":1,"maxqty":1,"unitcreditcode":"","recurringchargecode":"","XC_Product_Type__c":"Service","XC_Product_Subtype__c":"RFID","NE__Commitment__c":false,"NE__Commitment_Period__c":"","NE__Commitment_UOM__c":"","NE__Penalty__c":false,"NE__Penalty_Fee__c":null,"id":"a1I6E000000yC22UAE","minqty":0,"categoryid":"a1F6E0000011XWwUAM","startdate":"20150528","productid":"a216E000000Dz8JQAS","catalogitemid":"a1I6E000000yC22UAE","sequence":0,"name":"0699","recurringchargefrequency":"Monthly","categoryname":"AppMobile","onetimefeecode":"","enddate":"99999999","catalogid":"a1J6E000000QrQKUA0","productname":"RFID","active":true,"enginecode":"a1s9E000000JSAkQAO","visible":"false","thumbnailimage":"","productenginecode":"a2b9E000000434SQAQ","itemHeader":"","brochureimage":"","currency":"EUR","MatrixItemIdentifier":"","parent":"","parentvid":"","rootvid":"","childproductcategory":"","defaultQty":null,"complexcategoryname":"","type":"Product","vid":"cfc7a138","itemCode":"cfc7a138","itemheaderId":"","configurationtype":"Standard","sourceId":"a1s9E000000JSAkQAO","startingbaseonetimefee":0,"productcatalogitem":""},"listOfFamilies":[],"listOfAttributes":[],"id":"a1I6E000000yC22UAE","listOfCharacteristic":[],"listOfDiscounts":[],"listOfPenalties":[],"childItems":[]}],"additionalData":{},"action":null,"errorCode":"0","errorMessage":""}');
                response.setStatusCode(200); 

            }

            return response;
        }
    }


    // getConfigurationXMLInputs False
    @isTest
    static void testGetConfigurationXMLInputsFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetConfigurationXMLInputsFalse_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    public without sharing class GetConfigurationXMLInputsFalse_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"errorCode":"-1","orderXml":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
            response.setStatusCode(200); 
            return response;
        }
    }


    // GenerateTokenChange False
    @isTest
    static void testGenerateTokenChangeFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateTokenChangeFalse_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }
                                 
    @isTest
    static void dd0_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 0, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                 
                                 @isTest
    static void dd1_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 1, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd2_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 2, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd3_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 3, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd4_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 4, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd5_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 5, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd6_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 6, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd7_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 7, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

    }
                                   @isTest
    static void dd8_test(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DD_Callouts('0', 200, 8, 0));
        System.enqueueJob(changeAPI);
        
        
        test.stopTest();

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
                if(req.getEndpoint().endsWith('/services/apexrest/NE/GetConfigurationXML')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"errorCode":"' + this.errorCode + '","orderXml":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                    response.setStatusCode(this.statusCode); 
                    
                } else if(req.getEndpoint().endsWith('bit2winapis/generateToken')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('<tokenResponse><errorCode>' + this.errorCode + '</errorCode><errorMessage></errorMessage><token>jifc57ttgf8o9e33bja0a6ld2</token></tokenResponse>');
                    response.setStatusCode(this.statusCode); 
                    
                } else if(req.getEndpoint().endsWith('bit2winapis/applyChangeOrder')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"ApplyChangeOrderMessage":{"changeResult":{"serviceaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__TotalRecurringFrequency__c":"","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__type__c":"ChangeOrder","NE__accountid__c":"0016E00000mz6PYQAY","channel":"","billprofid":"","NE__Recurring_Charge_Total__c":0,"datamapname":"sfdcAsset2Xml","assetitementerpriseid":"02i6E000004SNfYQAW","RecordTypeId":"0126E000000EwzJQAS","NE__billingprofid__c":"","NE__servaccid__c":"0016E00000mz6PYQAY","NE__Quote__c":"","NE__EngineType__c":"b2wgin","NE__OptyId__c":"0066E0000071GsfQAE","NE__configurationstatus__c":"Inprogress","NE__billaccid__c":"0016E00000mz6PYQAY","NE__Version__c":0,"configuration_type":"Change","NE__OrderStatus__c":"Pending","configuration_subtype":"Changeorder","NE__order_date__c":"2019-06-18","NE__One_Time_Fee_Total__c":0,"parameters":""},"billingaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"account":{"accountid":"","Country__c":"","scoring":"","subsector":"","accounttype":"","AccntId":"","industry":"","company":"","XC_AccountType":"Residential","sector":"","BirthDate":"","desctiption":""},"cartitem":[{"listOfAttributes":[],"listOfCharacteristic":[{"fields":{"compare":"","visible":false,"productid":"","valueboolean":false,"parentid":"","valuenumber":0,"filter":"","sequence":0,"name":"RFID:","ranking":"","id":"a1V6E000009H9IhUAK","valuedate":"","value":"Yes"}}],"childItems":[],"fields":{"complexcategoryname":"","parent":"","ConvergentBillType":"","orderitempromoid":"","productid":"a216E000000Dz1LQAS","recurringeditable":false,"bundleElement":"","XC_Product_Type__c":"Service","startdate":"","type":"Product","sourcelineitemid":"","vid":"02i6E000004SNfYQAW","LicProductName":"FlatSmall","recurringchargediscounted":16.99,"NE__Penalty__c":false,"context":"true","taxmodelsapplied":"","configurationRecurringCharge":0,"itemHeader":"","reservation":"","action":"None","id":"a1I6E000000yAqZUAU","billaccount":"0016E00000mz6PYQAY","discountid":"","brand":"","XC_Product_Subtype__c":"Tariff","recurringchargetaxfree":"16.99","recurringchargeov":16.99,"pickedby":"Human","XC_Discounted_Recurring_duration__c":0,"usagecode":"","NE__Commitment_UOM__c":"","active":true,"configurationtype":"Standard","prodid":"a216E000000Dz1LQAS","MinAge":0,"catalogid":"a1J6E000000QrQKUA0","enddate":"","NE__Commitment__c":false,"visiblefromdb":"true","XC_ineligible_channels":"","thumbnailimage":"","asset_item_account":"","recurringchargeovapplied":false,"status":"Active","parentvid":"","NE__Penalty_Type__c":"","Picked_By__c":"Human","productenginecode":"a1f0D000000D7dKQAS","XC_Orig_RecurringCharge__c":0,"XC_Business_Line":"","programname":"Flat_Small_a0z0D000000FM0jQAG_E-mobility","onetimefeeov":0.00,"account":"0016E00000mz6PYQAY"}}]},"errorCode":"' + this.errorCode + '"}}');
                    response.setStatusCode(this.statusCode);
                } else if(req.getEndpoint().endsWith('generateToken')) {
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

     // GenerateTokenChange False
    @isTest
    static void testGenerateTokenChangeUSFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateTokenChangeFalse_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    public without sharing class GenerateTokenChangeFalse_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/services/apexrest/NE/GetConfigurationXML')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","orderXml":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('bit2winapis/generateToken')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('<tokenResponse><errorCode>1</errorCode><errorMessage></errorMessage><token>jifc57ttgf8o9e33bja0a6ld2</token></tokenResponse>');
                response.setStatusCode(200); 

            }

            return response;
        }
    }


    // ApplyChangeOrder False
    @isTest
    static void testApplyChangeOrderFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ApplyChangeOrderFalse_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    // ApplyChangeOrder False
    @isTest
    static void testApplyChangeOrderUSFalse(){

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', 'hubcqvrouqrob1er');
        infos.put('ServerURL_Change', 'hubcqvrouqrob1er');
        infos.put('Password', '134719834hf143');
        infos.put('PasswordToken', 'qwvfei12u43f1w');
        infos.put('UserToken', '31451345');
        infos.put('token_Change', '31451345');
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('currentStep', JSON.serialize([SELECT XC_StepSequence__c, XC_ExecutionResponse__c  FROM XC_QueuedRequestStep__c LIMIT 1][0]));

        XC_REST_ChangeAPI changeAPI = new XC_REST_ChangeAPI(infos);

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ApplyChangeOrderFalse_Mock());
		System.enqueueJob(changeAPI);
        test.stopTest();

        System.assertNotEquals('60c0c5bfd4213a1f52628a5f85e6e974183e90bb', infos.get('orderXml'), 'Wrong assert result');
    }

    public without sharing class ApplyChangeOrderFalse_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/services/apexrest/NE/GetConfigurationXML')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"errorCode":"0","orderXml":"60c0c5bfd4213a1f52628a5f85e6e974183e90bb"}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('bit2winapis/generateToken')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('<tokenResponse><errorCode>0</errorCode><errorMessage></errorMessage><token>jifc57ttgf8o9e33bja0a6ld2</token></tokenResponse>');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('bit2winapis/applyChangeOrder')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"ApplyChangeOrderMessage":{"changeResult":{"serviceaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"configuration":{"NE__CatalogId__c":"a1J6E000000QrQKUA0","NE__TotalRecurringFrequency__c":"","NE__CommercialModelId__c":"a1O6E000000FeddUAC","NE__type__c":"ChangeOrder","NE__accountid__c":"0016E00000mz6PYQAY","channel":"","billprofid":"","NE__Recurring_Charge_Total__c":0,"datamapname":"sfdcAsset2Xml","assetitementerpriseid":"02i6E000004SNfYQAW","RecordTypeId":"0126E000000EwzJQAS","NE__billingprofid__c":"","NE__servaccid__c":"0016E00000mz6PYQAY","NE__Quote__c":"","NE__EngineType__c":"b2wgin","NE__OptyId__c":"0066E0000071GsfQAE","NE__configurationstatus__c":"Inprogress","NE__billaccid__c":"0016E00000mz6PYQAY","NE__Version__c":0,"configuration_type":"Change","NE__OrderStatus__c":"Pending","configuration_subtype":"Changeorder","NE__order_date__c":"2019-06-18","NE__One_Time_Fee_Total__c":0,"parameters":""},"billingaccount":{"country":"","city":"","postalcode":0,"street":"","servaccid":"","state":"","region":""},"account":{"accountid":"","Country__c":"","scoring":"","subsector":"","accounttype":"","AccntId":"","industry":"","company":"","XC_AccountType":"Residential","sector":"","BirthDate":"","desctiption":""},"cartitem":[{"listOfAttributes":[],"listOfCharacteristic":[{"fields":{"compare":"","visible":false,"productid":"","valueboolean":false,"parentid":"","valuenumber":0,"filter":"","sequence":0,"name":"RFID:","ranking":"","id":"a1V6E000009H9IhUAK","valuedate":"","value":"Yes"}}],"childItems":[],"fields":{"complexcategoryname":"","parent":"","ConvergentBillType":"","orderitempromoid":"","productid":"a216E000000Dz1LQAS","recurringeditable":false,"bundleElement":"","XC_Product_Type__c":"Service","startdate":"","type":"Product","sourcelineitemid":"","vid":"02i6E000004SNfYQAW","LicProductName":"FlatSmall","recurringchargediscounted":16.99,"NE__Penalty__c":false,"context":"true","taxmodelsapplied":"","configurationRecurringCharge":0,"itemHeader":"","reservation":"","action":"None","id":"a1I6E000000yAqZUAU","billaccount":"0016E00000mz6PYQAY","discountid":"","brand":"","XC_Product_Subtype__c":"Tariff","recurringchargetaxfree":"16.99","recurringchargeov":16.99,"pickedby":"Human","XC_Discounted_Recurring_duration__c":0,"usagecode":"","NE__Commitment_UOM__c":"","active":true,"configurationtype":"Standard","prodid":"a216E000000Dz1LQAS","MinAge":0,"catalogid":"a1J6E000000QrQKUA0","enddate":"","NE__Commitment__c":false,"visiblefromdb":"true","XC_ineligible_channels":"","thumbnailimage":"","asset_item_account":"","recurringchargeovapplied":false,"status":"Active","parentvid":"","NE__Penalty_Type__c":"","Picked_By__c":"Human","productenginecode":"a1f0D000000D7dKQAS","XC_Orig_RecurringCharge__c":0,"XC_Business_Line":"","programname":"Flat_Small_a0z0D000000FM0jQAG_E-mobility","onetimefeeov":0.00,"account":"0016E00000mz6PYQAY"}}]},"errorCode":"0"}}');
                response.setStatusCode(500);
            }

            return response;
        }
    }
}