/**
 * The Class XC_REST_MobilityOrder_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 20/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_MobilityOrder - XC_REST_MobilityOrder_U - XC_REST_MobilityOrder_V - XC_REST_MobilityOrder_D -
 *                      XC_REST_MobilityOrder_W - XC_REST_MobilityOrder_Z - XC_REST_MobilityOrder_B - XC_REST_MobilityOrder_C
 **/


@isTest
public without sharing class XC_REST_MobilityOrder_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Tariff';
        prod.XC_Product_Type__c = 'Service';
        prod.XC_LIC_Product_Name__c = 'LUZ';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__Engine_Code__c = '001';
        catItem.NE__UsageCode__c = 'OKLUZ';
        catItem.NE__ProductId__c = prod.id;
        insert catItem;

        NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
        catalog.XC_LIC_Name__c = 'eHome - ES';
        update catalog; 

        //NE__Order__c order = XC_DF_Order.createOrder('Order');

        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accountList);
        if( billProfList[0].NE__Payment__c == null || billProfList[0].NE__Payment__c == ''){
            billProfList[0].NE__Payment__c = 'Credit Card'; 
        }
        update billProfList;
        
        
        
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        bpliList[0].XC_BillToContactId__c = conList[0].Id;
        bpliList[0].XC_SoldToContactId__c = conList[0].Id;
        bpliList[0].XC_LegalEntity__c = 'EndesaX';
        update bpliList;

        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = address[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_EmobilityWebAppType__c = 'JuiceNet Manager PRO';
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.XC_BillingProfileLineItem__c = bpliList[0].Id;
        if( item.XC_PaymentMethod__c == null || item.XC_PaymentMethod__c == ''){
			item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Credit Card'; 
            item.XC_Installation_Address__c = address[0].Id;
            item.NE__Account__c = accountList[0].id;
        } 
        insert item;
        update order;

        List<Asset> assetList = XC_DF_Asset.createAssets(accountList);
        assetList[0].XC_Configuration_Item__c = item.Id;
        assetList[0].NE__Order_Config__c = order.Id;
        assetList[0].ContactId = conList[0].Id;
        insert assetList;

    
        XC_CS004_Bit2WinCredentials__c b2wCredentials = new XC_CS004_Bit2WinCredentials__c();
        b2wCredentials.XC_ServerURL__c = 'sFDSgdfgedWafdhaj';
        b2wCredentials.XC_ClientId__c = '2647256726572';
        b2wCredentials.XC_OrganizationId__c = '24726572451';
        b2wCredentials.XC_Country__c = 'SPAIN';
        insert b2wCredentials;
        
        XC_CS005_Bit2WinChangeAPI__c b2wChangeCredentials = new XC_CS005_Bit2WinChangeAPI__c();
        b2wChangeCredentials.XC_Password__c = '143t25g3141';
        b2wChangeCredentials.XC_PasswordToken__c = '2647256726572';
        b2wChangeCredentials.XC_ServerURL__c = 'sFDSgdfgedWafdhaj';
        b2wChangeCredentials.XC_UserToken__c = 'ff135y4fd2';
        b2wChangeCredentials.XC_Country__c = 'SPAIN';
        insert b2wChangeCredentials;

    }


    // POST Correct
    /*@isTest
    static void testDoPost(){
        
        List<XC_Voucher__c> voucherList = XC_DF_Voucher.generateSingleVoucher(1);
        voucherList[0].XC_CompanyCode__c = 'CompanyCode';
        voucherList[0].XC_CostCenter__c = 'CostCenter';
        insert voucherList;

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_Account__c, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLi.XC_LegalEntity__c = 'EndesaX';
        update billingProfLi;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = billingProfLi.XC_Account__c; 
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        /*body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';*/
        /*body.Order.CouponCode = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = billingProfLi.XC_ExternalKey__c;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/


    // POST CompanyCode CostCenter
    @isTest
    static void testDoPostCompanyCode(){
        
        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        prodList[0].XC_Product_Type__c = 'Service';
        prodList[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtype_B2BTariff;
        insert prodList;
        
        NE__Family__c f = new NE__Family__c();
        f.XC_LIC_Family_Name__c = Label.XC_CL_Family_JNManager;
        insert f;
        
        NE__ProductFamily__c pf = new NE__ProductFamily__c();
        pf.NE__FamilyId__c = f.Id;
        pf.NE__ProdId__c = prodList[0].Id;
        insert pf;
        
        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_Account__c, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLi.XC_LegalEntity__c = 'EndesaX';
        update billingProfLi;
        
        Asset a = [SELECT Id FROM Asset LIMIT 1];
        a.XC_LegalEntity__c = 'EndesaX';
        a.XC_CompanyCode__c = '12345X';
        a.XC_CostCenter__c = '12345X';
        a.XC_BillingProfileLineItem__c = billingProfLi.Id;
        a.NE__ProdId__c = prodList[0].Id;
        a.NE__Order_Config__c = [SELECT Id FROM NE__Order__c WHERE XC_EmobilityWebAppType__c != '' LIMIT 1][0].Id;
        update a;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = billingProfLi.XC_Account__c; 
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345X';
        body.Order.CostCenter = '12345X';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile = null;
		
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        System.debug(LoggingLevel.FINEST, wrResp);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }
    
    
    // POST CompanyCode CostCenter No Order
    @isTest
    static void testDoPostCompanyCodeNoOrder(){

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_Account__c, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLi.XC_LegalEntity__c = 'EndesaX';
        update billingProfLi;

        Asset a = [SELECT Id FROM Asset LIMIT 1];
        a.XC_CompanyCode__c = '12345X';
        a.XC_CostCenter__c = '12345X';
        a.XC_BillingProfileLineItem__c = billingProfLi.Id;
        update a;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = billingProfLi.XC_Account__c; 
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345X';
        body.Order.CostCenter = '12345X';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile = null;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        System.debug(LoggingLevel.FINEST, wrResp);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Smart Residential
    /*@isTest
    static void testDoPostSmartResidential(){
        
        List<XC_Voucher__c> voucherList = XC_DF_Voucher.generateSingleVoucher(1);
        voucherList[0].XC_CompanyCode__c = 'CompanyCode';
        voucherList[0].XC_CostCenter__c = 'CostCenter';
        insert voucherList;

        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        prodList[0].XC_LIC_Product_Name__c = 'X-Energía Smart';
        prodList[0].XC_Product_Subtype__c = 'Tariff';
        prodList[0].XC_Product_Type__c = 'Service';
        insert prodList;

        NE__Catalog_Item__c ci = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0];
        ci.NE__ProductId__c = prodList[0].Id;
        update ci;

        Contact c = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true];
        XC_PersonalDocument__c pd = new XC_PersonalDocument__c(XC_Account__c = c.AccountId,XC_Country__c = 'Spain');
        insert pd;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = c.AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        body.Order.CouponCode = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = ci.NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile = null;
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/


    // POST Smart Condominium
    /*@isTest
    static void testDoPostSmartCondominium(){
        
        List<XC_Voucher__c> voucherList = XC_DF_Voucher.generateSingleVoucher(1);
        voucherList[0].XC_CompanyCode__c = 'CompanyCode';
        voucherList[0].XC_CostCenter__c = 'CostCenter';
        insert voucherList;

        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        prodList[0].XC_LIC_Product_Name__c = 'X-Energía Smart';
        prodList[0].XC_Product_Subtype__c = 'Tariff';
        prodList[0].XC_Product_Type__c = 'Service';
        insert prodList;

        NE__Catalog_Item__c ci = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0];
        ci.NE__ProductId__c = prodList[0].Id;
        update ci;

        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        contactList[0].XC_PrimaryContact__c = true;
        insert contactList;

        List<XC_Address__c> addrList = XC_DF_Address.createAddress([SELECT Id FROM Account]);
        insert addrList;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = contactList[0].AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        body.Order.CouponCode = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = ci.NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile = null;
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/


    // POST Smart Condominium No Address
    /*@isTest
    static void testDoPostSmartCondominiumNoAddress(){
        
        List<XC_Voucher__c> voucherList = XC_DF_Voucher.generateSingleVoucher(1);
        voucherList[0].XC_CompanyCode__c = 'CompanyCode';
        voucherList[0].XC_CostCenter__c = 'CostCenter';
        insert voucherList;

        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        prodList[0].XC_LIC_Product_Name__c = 'X-Energía Smart';
        prodList[0].XC_Product_Subtype__c = 'Tariff';
        prodList[0].XC_Product_Type__c = 'Service';
        insert prodList;

        NE__Catalog_Item__c ci = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0];
        ci.NE__ProductId__c = prodList[0].Id;
        update ci;

        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        contactList[0].XC_PrimaryContact__c = true;
        insert contactList;
        
        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = contactList[0].AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        body.Order.CouponCode = [SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = ci.NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile = null;
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/

    

    // POST Wrong Coupon Code
    @isTest
    static void testDoPostWrongCouponCode(){

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_Account__c, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        //body.Order.AccountID = [SELECT Id FROM Account][0].Id;
        body.Order.AccountID = billingProfLi.XC_Account__c;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'JuicenetLimited';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        /*body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';*/
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.CouponCode = 'X3W1231Z';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = billingProfLi.XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
        XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        System.debug(LoggingLevel.FINEST, wrResp);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }
    
    
    // POST Wrong Coupon Code
    @isTest
    static void testDoPostWrongCouponCode2(){

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_Account__c, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];
        
        XC_PersonalDocument__c pd = new XC_PersonalDocument__c(XC_Country__c ='Spain', XC_DocumentType__c = 'Passport', XC_DocumentNumber__c = '94848494', XC_Account__c = billingProfLi.XC_Account__c);
		insert pd;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        //body.Order.AccountID = [SELECT Id FROM Account][0].Id;
        body.Order.AccountID = billingProfLi.XC_Account__c;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'JuicenetLimited';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        /*body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';*/
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.CouponCode = 'X3W1231Z';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = billingProfLi.XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
        XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        System.debug(LoggingLevel.FINEST, wrResp);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Engine Code
    @isTest
    static void testDoPostWrongEngineCode(){

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = 'a';
        body.Order.OrderStatus = 'a';
        body.Order.LegalEntity = 'a';
        body.Order.ContractCode = 'a';
        body.Order.ContractDate = 'a';
        body.Order.CompanyCode = 'a';
        body.Order.CostCenter = 'a';
        body.Order.TotalOneTimeFee = 'a';
        body.Order.PaymentMode = 'a';
        body.Order.Channel = 'a';
        body.Order.SubChannel = 'a';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = 'a';
        body.Order.CouponCode = 'a';
        body.Order.DestinationCode = 'a';
        body.Order.CertifiedEmail = 'a';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'a';
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = 'a';
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Credit Card External Key
    @isTest
    static void testDoPostWrongCreditCardKey(){

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = 'a';
        body.Order.OrderStatus = 'a';
        body.Order.LegalEntity = 'a';
        body.Order.ContractCode = 'a';
        body.Order.ContractDate = 'a';
        body.Order.CompanyCode = 'a';
        body.Order.CostCenter = 'a';
        body.Order.TotalOneTimeFee = 'a';
        body.Order.PaymentMode = 'a';
        body.Order.Channel = 'a';
        body.Order.SubChannel = 'a';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = 'a';
        body.Order.CouponCode = 'a';
        body.Order.DestinationCode = 'a';
        body.Order.CertifiedEmail = 'a';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = 'a';

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Account
    @isTest
    static void testDoPostWrongAccount(){

        Contact con = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true][0];
        String accountID = con.AccountId;
        XC_Address__c address = [SELECT Id FROM  XC_Address__c WHERE XC_Account__c =: accountID LIMIT 1];

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id, XC_ExternalKey__c FROM  XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLi.XC_BillToAddress__c = address.Id;
        billingProfLi.XC_SoldToAddress__c = address.Id;
        billingProfLi.XC_BillToContactId__c = con.Id; 
        update billingProfLi;

        NE__Billing_Profile__c billingProfile = [SELECT Id, NE__Payment__c FROM NE__Billing_Profile__c WHERE NE__Account__c =: accountID];
        billingProfile.NE__Payment__c = 'Credit Card';
        update billingProfile;

        Account accToUpdate = new Account(XC_DocumentCountry__c = 'Spain', Id = accountID);
        update accToUpdate; 


        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.AccountID = 'a';
        body.Order.OrderStatus = 'a';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = 'a';
        body.Order.ContractDate = 'a';
        body.Order.CompanyCode = 'a';
        body.Order.CostCenter = 'a';
        body.Order.TotalOneTimeFee = 'a';
        body.Order.PaymentMode = 'a';
        body.Order.Channel = 'a';
        body.Order.SubChannel = 'a';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = 'a';
        body.Order.CouponCode = 'a';
        body.Order.DestinationCode = 'a';
        body.Order.CertifiedEmail = 'a';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.Quantity = 1;
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        body.BillingProfile.CreditCardExternalkey = billingProfLi.XC_ExternalKey__c;

        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Header
    @isTest
    static void testDoPostWrongHeader(){

        System.RestContext.request = generateRestRequestPOSTGood();
        String t = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.request.requestBody = Blob.valueOf('{}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Functionality
    @isTest
    static void testDoPostWrongFunctionality(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addheader('Functionality', 'WRONG');
        System.RestContext.request.requestBody = Blob.valueOf('{}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Order
    @isTest
    static void testDoPostNoOrder(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{}');

        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Required Parameters
    @isTest
    static void testDoPostNoRequiredParameters(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Recharge App
    @isTest
    static void testDoPostNoRechargeApp(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a"}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Order Item
    @isTest
    static void testDoPostNoOrderItem(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a","RegisteredOnRechargeApp":true}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Engine Code
    @isTest
    static void testDoPostNoEngineCode(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a","RegisteredOnRechargeApp":true,"OrderItem":[{}]}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Quantity
    @isTest
    static void testDoPostNoQuantity(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a","RegisteredOnRechargeApp":true,"OrderItem":[{"EngineCode":"a"}]}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Billing Profile
    @isTest
    static void testDoPostNoBillingProfile(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a","RegisteredOnRechargeApp":true,"OrderItem":[{"EngineCode":"a","Quantity":1}]}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No External Key
    @isTest
    static void testDoPostNoExternalKey(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"AccountID":"a","LegalEntity":"a","PaymentMode":"a","Channel":"a","SubChannel":"a","CreatedDate":"a","RegisteredOnRechargeApp":true,"OrderItem":[{"EngineCode":"a","Quantity":1}]},"BillingProfile":{}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Catch
    @isTest
    static void testDoPostCatch(){

        test.startTest();

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('');

        System.RestContext.response = new RestResponse();

		XC_REST_MobilityOrder.doPost();
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
        test.stopTest();
    }


    // Put Correct Change Offer
    @isTest
    static void testDoPutChangeOffer(){
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = '001';
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Change Billing Profile
    @isTest
    static void testDoPutChangeBillingProfile(){

        Contact con = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true][0];
        String accountID = con.AccountId;
        XC_Address__c address = [SELECT Id FROM  XC_Address__c WHERE XC_Account__c =: accountID LIMIT 1];

        XC_BillingProfileLineItem__c billingProfLi = [SELECT Id FROM  XC_BillingProfileLineItem__c LIMIT 1];
        billingProfLi.XC_BillToAddress__c = address.Id;
        billingProfLi.XC_SoldToAddress__c = address.Id;
        billingProfLi.XC_BillToContactId__c = con.Id; 
        billingProfLi.XC_LegalEntity__c = 'EndesaX'; 
        update billingProfLi;

        Account accToUpdate = new Account(XC_DocumentCountry__c = 'Spain', Id = accountID);
        update accToUpdate; 
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = [SELECT Id, XC_Configuration_Item__r.NE__CatalogItem__r.NE__Engine_Code__c FROM Asset][0].XC_Configuration_Item__r.NE__CatalogItem__r.NE__Engine_Code__c;
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ExternalKey__c FROM Asset][0].XC_Configuration_Item__r.XC_BillingProfileLineItem__r.XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        System.debug(LoggingLevel.FINEST, wrResp);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }
    
    
    // Put Change Offer Asset Suspended
    @isTest
    static void testDoPutChangeOfferAssetSuspended(){
        
        Asset a = [SELECT Id, Status FROM Asset LIMIT 1];
        a.Status = 'Suspended';
        update a;
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = a.Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = '001';
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }
    
    
    // Put Change Offer No Bit2Win Credentials
    @isTest
    static void testDoPutNoBit2WinCredentials(){
        
        XC_CS004_Bit2WinCredentials__c b2wCred = [SELECT Id FROM XC_CS004_Bit2WinCredentials__c];
        delete b2wCred;
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = '001';
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }
    
    
    // Put Change Offer No Bit2Win Change Credentials
    @isTest
    static void testDoPutNoBit2WinChangeCredentials(){
        
        XC_CS005_Bit2WinChangeAPI__c b2wChangeCred = [SELECT Id FROM XC_CS005_Bit2WinChangeAPI__c];
        delete b2wChangeCred;
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = '001';
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Change Billing Profile Wrong
    @isTest
    static void testDoPutChangeBillingProfileWrong(){
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = [SELECT Id, XC_Configuration_Item__r.NE__CatalogItem__r.NE__Engine_Code__c FROM Asset][0].XC_Configuration_Item__r.NE__CatalogItem__r.NE__Engine_Code__c;
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = '761457845';
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Wrong Asset
    @isTest
    static void testDoPutWrongAsset(){
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.AccountID = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true][0].AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = 'a';
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Wrong Asset Status
    @isTest
    static void testDoPutWrongAssetStatus(){

        Asset a = [SELECT Id FROM Asset LIMIT 1];
        a.Status = 'Inactive';
        update a;
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.AccountID = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true][0].AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = a.Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Wrong Engine Code
    @isTest
    static void testDoPutWrongEngineCode(){
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.AccountID = [SELECT Id, AccountId FROM Contact WHERE XC_PrimaryContact__c = true][0].AccountId;
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = 'WRONG';
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // Put Wrong Account
    @isTest
    static void testDoPutWrongAccount(){
        
        System.RestContext.request = generateRestRequestPutGood();
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.OrderID = '12345';
        body.Order.AccountID = 'a';
        body.Order.OrderStatus = 'In Progress';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.ContractCode = '123';
        body.Order.ContractDate = '2019-05-22';
        body.Order.CompanyCode = '12345';
        body.Order.CostCenter = '12345';
        body.Order.TotalOneTimeFee = '1';
        body.Order.PaymentMode = 'OneShot';
        body.Order.Channel = 'Web';
        body.Order.SubChannel = 'APP';
        body.Order.RegisteredOnRechargeApp = true;
        body.Order.CreatedDate = '2019-05-21T13:44:43.587';
        body.Order.DestinationCode = '1233';
        body.Order.CertifiedEmail = 'atest@gmail.com';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.OldAssetID = [SELECT Id FROM Asset][0].Id;
        ordItem.OldSubscriptionID = 'a';
        ordItem.NewEngineCode = [SELECT Id, NE__Engine_Code__c FROM NE__Catalog_Item__c][0].NE__Engine_Code__c;
        ordItem.NewQuantity = 1;
        body.Order.OrderItem = ordItem;
        body.BillingProfile.CreditCardExternalkey = [SELECT Id, XC_ExternalKey__c FROM XC_BillingProfileLineItem__c][0].XC_ExternalKey__c;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }



    // POST Commodity - without billing profile
    /*@isTest
    static void testDoPostForCommodityWithoutBP(){
        

        List<Account> accList =  [SELECT Id, IdentityType__c, IdentityNumber__c FROM Account LIMIT 1];

        List<XC_Address__c > addrList = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, 
                                         XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c 
                                         FROM XC_Address__c];
        XC_Address__c address = addrList[0];            

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.ContractCode = '5795955050505';
        body.Order.CommodityBillingCycleFrequency = 'Monthly';
        body.Order.DeactivationBasedOnRegulatory = '11';
        body.Order.AccountFiscalCode = accList[0].IdentityType__c + '|' + accList[0].IdentityNumber__c;
        body.Order.BillingProfileData = 'Commodity Bill';
        body.Order.BillingAddressData = address.XC_AddressCountry__c + '|' + address.XC_AddressProvince__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '||';
        body.Order.InstallationAddressData =address.XC_AddressCountry__c + '|' + address.XC_AddressProvince__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + + '||';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKLUZ';
        ordItem.Quantity = 1;
        
        XC_REST_MobilityOrder_W.WrapperDiscount oiDiscount = new XC_REST_MobilityOrder_W.WrapperDiscount();
        oiDiscount.Code = 'EXU';
        oiDiscount.OneTimePrice = 20.0;
        oiDiscount.OneTimeValue = 20.0;
        oiDiscount.RecurringPrice = 20.0;
        oiDiscount.RecurringValue = 20.0;
        oiDiscount.Status = 'Active';
        oiDiscount.Type = '%';
        ordItem.OrderItemDiscount = new List<XC_REST_MobilityOrder_W.WrapperDiscount>();
        ordItem.OrderItemDiscount.add(oiDiscount);
        
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
       
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/


    // POST Commodity - with billing profile
    @isTest
    static void testDoPostForCommodityWithBP(){
        

        List<Account> accList =  [SELECT Id, IdentityType__c, IdentityNumber__c, (SELECT Id FROM Contacts) FROM Account LIMIT 1];
    
        List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accList);
        billProfList[0].NE__Payment__c = 'Direct Debt';
        billProfList[0].NE__Iban__c = 'ES0989878367467';
        billProfList[0].XC_Status__c = 'Active';
        billProfList[0].XC_LegalEntity__c = 'EndesaX';
        update billProfList;       
        
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillToAddress__c,XC_BillingProfile__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: billProfList[0].Id][0];
        bpli.XC_Status__c = 'Active';
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli; 

        List<XC_Address__c > addrList = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, 
                                         XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c 
                                         FROM XC_Address__c WHERE Id =: bpli.XC_BillToAddress__c];
        XC_Address__c address = addrList[0];            

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.AccountFiscalCode = accList[0].IdentityType__c + '|' + accList[0].IdentityNumber__c;
        body.Order.BillingProfileData = billProfList[0].NE__Payment__c + '|' + billProfList[0].NE__Iban__c;
        body.Order.BillingAddressData = address.XC_AddressCountry__c + '|' + address.XC_AddressProvince__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '||';
        body.Order.InstallationAddressData =address.XC_AddressCountry__c + '|' + address.XC_AddressProvince__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + + '||';
        body.Order.CommodityBillingCycleFrequency = 'Monthly';
        body.Order.DeactivationBasedOnRegulatory = '11';
        
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKLUZ';
        ordItem.Quantity = 1;
        XC_REST_MobilityOrder_W.WrapperAttribute ordItemAttribute = new XC_REST_MobilityOrder_W.WrapperAttribute();
        ordItemAttribute.Name = 'Region';
        ordItemAttribute.Value = 'Peninsula';
        ordItemAttribute.ProductFamilyPropertyID = '';
        ordItem.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        ordItem.Attribute.add(ordItemAttribute);
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Commodity - Wrong Address
    /*@isTest
    static void testDoPostForCommodityWrongAddress(){
        

         List<Account> accList =  [SELECT Id, IdentityType__c, IdentityNumber__c, (SELECT Id FROM Contacts) FROM Account LIMIT 1];
    
        List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accList);
        billProfList[0].NE__Payment__c = 'Direct Debt';
        billProfList[0].NE__Iban__c = 'ES0989878367467';
        billProfList[0].XC_Status__c = 'Active';
        billProfList[0].XC_LegalEntity__c = 'EndesaX';
       
        update billProfList;       
        
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillToAddress__c,XC_BillingProfile__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: billProfList[0].Id][0];
        bpli.XC_Status__c = 'Active';
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli; 

        List<XC_Address__c > addrList = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, 
                                         XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c 
                                         FROM XC_Address__c WHERE Id =: bpli.XC_BillToAddress__c];
        XC_Address__c address = addrList[0];            

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.ContractCode = '91829928282';
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.AccountFiscalCode = accList[0].IdentityType__c + '|' + accList[0].IdentityNumber__c;
        body.Order.BillingProfileData = billProfList[0].NE__Payment__c + '|' + billProfList[0].NE__Iban__c;
        body.Order.BillingAddressData = 'Spain|Madrid|Costa Adeje|38660|AV|Agala|8|1|4';
        body.Order.InstallationAddressData = 'Spain|Madrid|Costa Adeje|38660|AV|Agala|8|1|4';
        body.Order.CommodityBillingCycleFrequency = '11';
        body.Order.DeactivationBasedOnRegulatory = '11';
      
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKLUZ';
        ordItem.Quantity = 1;
        XC_REST_MobilityOrder_W.WrapperAttribute ordItemAttribute = new XC_REST_MobilityOrder_W.WrapperAttribute();
        ordItemAttribute.Name = 'Region';
        ordItemAttribute.Value = 'Peninsula';
        ordItemAttribute.ProductFamilyPropertyID = '';
        ordItem.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        ordItem.Attribute.add(ordItemAttribute);
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallZuora_Mock());
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(0, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/

    // POST Commodity - Wrong Engine Code
    @isTest
    static void testDoPostForCommodityWrongEngineCode(){
        

        List<Account> accList =  [SELECT Id, IdentityType__c, IdentityNumber__c FROM Account LIMIT 1];
    
        List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accList);
        billProfList[0].NE__Payment__c = 'Direct Debt';
        billProfList[0].NE__Iban__c = 'ES0989878367467';
        billProfList[0].XC_LegalEntity__c = 'EndesaX';
        update billProfList;           
        
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillToAddress__c,XC_BillingProfile__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =: billProfList[0].Id][0];
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli; 

        List<XC_Address__c > addrList = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_PostalCode__c, XC_StreetTypeText__c, 
                                         XC_Address__c, XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_AddressProvince__c 
                                         FROM XC_Address__c WHERE Id =: bpli.XC_BillToAddress__c];
        XC_Address__c address = addrList[0];          


        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.CommodityBillingCycleFrequency = '11';
        body.Order.DeactivationBasedOnRegulatory = '11';
        body.Order.AccountFiscalCode = accList[0].IdentityType__c + '|' + accList[0].IdentityNumber__c;
        body.Order.BillingProfileData = billProfList[0].NE__Payment__c + '|' + billProfList[0].NE__Iban__c;
        body.Order.BillingAddressData = address.XC_AddressCountry__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '||';
        body.Order.InstallationAddressData = address.XC_AddressCountry__c + '|' + address.XC_City__c + '|' + address.XC_PostalCode__c + '|' + address.XC_StreetTypeText__c + '|' + address.XC_Address__c + '|' + address.XC_StreetNumber__c + '||';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKGAS';
        ordItem.Quantity = 1;
        XC_REST_MobilityOrder_W.WrapperAttribute ordItemAttribute = new XC_REST_MobilityOrder_W.WrapperAttribute();
        ordItemAttribute.Name = 'Region';
        ordItemAttribute.Value = 'Peninsula';
        ordItemAttribute.ProductFamilyPropertyID = '';
        ordItem.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        ordItem.Attribute.add(ordItemAttribute);
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Commodity- Wrong Billing Profile
    /*@isTest
    static void testDoPostForCommodityWrongBP(){
        

        List<Account> accList =  [SELECT Id, IdentityType__c, IdentityNumber__c FROM Account LIMIT 1];
    
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.CommodityBillingCycleFrequency = '11';
        body.Order.DeactivationBasedOnRegulatory = '11';
        body.Order.AccountFiscalCode = accList[0].IdentityType__c + '|' + accList[0].IdentityNumber__c;
        body.Order.BillingProfileData = 'Direct Debt' + '|' + 'Test';
        body.Order.BillingAddressData = 'Spain|Santa Cruz de Tenerife|38004|Street|Anaga|2||';
        body.Order.InstallationAddressData = 'Spain|Santa Cruz de Tenerife|38004|Street|Anaga|2||';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKLUZ';
        ordItem.Quantity = 1;
        body.Order.OrderItem = ordItem;
        XC_REST_MobilityOrder_W.WrapperAttribute ordItemAttribute = new XC_REST_MobilityOrder_W.WrapperAttribute();
        ordItemAttribute.Name = 'Region';
        ordItemAttribute.Value = 'Peninsula';
        ordItemAttribute.ProductFamilyPropertyID = '';
        body.Order.OrderItem.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        body.Order.OrderItem.Attribute.add(ordItemAttribute);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }*/

    // POST Commodity- Wrong Account
    @isTest
    static void testDoPostForCommodityWrongAccount(){
        
        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.addHeader('ClientSystem', 'CommoditySpainB2C');
        XC_REST_MobilityOrder_W.WrapperRequest body = new XC_REST_MobilityOrder_W.WrapperRequest();
        body.Order.LegalEntity = 'EndesaX';
        body.Order.OrderStatus = 'In Progress';
        body.Order.Channel = 'Market';
        body.Order.OrderType = 'New';
        body.Order.CommodityBillingCycleFrequency = '11';
        body.Order.DeactivationBasedOnRegulatory = '11';
        body.Order.AccountFiscalCode = 'Test' + '|' + 'Test';
        body.Order.BillingProfileData = 'Direct Debt' + '|' + 'Test';
        body.Order.BillingAddressData = 'Spain|Santa Cruz de Tenerife|38004|Street|Anaga|2||';
        body.Order.InstallationAddressData = 'Spain|Santa Cruz de Tenerife|38004|Street|Anaga|2||';
        XC_REST_MobilityOrder_W.OrderItemWrapper ordItem = new XC_REST_MobilityOrder_W.OrderItemWrapper();
        ordItem.EngineCode = 'OKLUZ';
        ordItem.Quantity = 1;
        body.Order.OrderItem = ordItem;
        XC_REST_MobilityOrder_W.WrapperAttribute ordItemAttribute = new XC_REST_MobilityOrder_W.WrapperAttribute();
        ordItemAttribute.Name = 'Region';
        ordItemAttribute.Value = 'Peninsula';
        ordItemAttribute.ProductFamilyPropertyID = '';
        ordItem.Attribute = new List<XC_REST_MobilityOrder_W.WrapperAttribute>();
        ordItem.Attribute.add(ordItemAttribute);
        body.Order.OrderItemList = new List<XC_REST_MobilityOrder_W.OrderItemWrapper>();
        body.Order.OrderItemList.add(ordItem);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPost();
        test.stopTest();
        
        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT Wrong Header
    @isTest
    static void testDoPutWrongHeader(){

        System.RestContext.request = generateRestRequestPUTGood();
        String t = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.request.requestBody = Blob.valueOf('{}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT No Required Parameters
    @isTest
    static void testDoPutNoRequiredParameters(){

        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT No Order Item
    @isTest
    static void testDoPutNoOrderItem(){

        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"OrderID":"a"}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT No EngineCode
    @isTest
    static void testDoPutNoEngineCode(){

        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"OrderID":"a","OrderItem":{}}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT No Quantity
    @isTest
    static void testDoPutNoQuantity(){

        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"Order":{"OrderID":"a","OrderItem":{"OldAssetID":"a","OldSubscriptionID":"a","NewEngineCode":"a"}}}');

        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // PUT Catch
    @isTest
    static void testDoPutCatch(){

        System.RestContext.request = generateRestRequestPUTGood();
        System.RestContext.request.requestBody = Blob.valueOf('');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_MobilityOrder.doPut();
        test.stopTest();

        XC_REST_MobilityOrder_W.WrapperResponse wrResp = (XC_REST_MobilityOrder_W.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_MobilityOrder_W.WrapperResponse.class);
        //System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }



    private static RestRequest generateRestRequestPOSTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'OrderManagement');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/mobilityOrder/*';

        return request; 
    }


    private static RestRequest generateRestRequestPUTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'OrderManagement');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/MobilityOrder/*';

        return request; 
    }

     /*
	*@ Description mock class to call zuora
	*/
    public without sharing class CallZuora_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/accounts')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/payment-method')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0002", "Success":true, "ZuoraAccountId":null}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().endsWith('/v1/object/account/a0001')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Errors":null, "Id":"a0001", "Success":true}');
                response.setStatusCode(200); 

            }
            return response;
        }
    }


    @isTest
    static void createOpportunityForOrderTest(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            NE__Product__c prod = new NE__Product__c();
            prod.XC_Product_Subtype__c = 'Tariff';
            prod.XC_Product_Type__c = 'Service';
            prod.XC_LIC_Product_Name__c = 'LUZ';
            insert prod;
    
            NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
            catItem.NE__Engine_Code__c = '001';
            catItem.NE__UsageCode__c = 'OKLUZ';
            catItem.NE__ProductId__c = prod.id;
            insert catItem;
    
            NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
            catalog.XC_LIC_Name__c = 'eHome -Ita';
            update catalog;
    
            List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
            insert accountList;
            List<Contact> conList = new List<Contact>();
            Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accountList[0].Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contsoldTo@test.it');
             insert contsoldTo;
             conList.add(contsoldTo);
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
            insert address;
     
     
            List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accountList);
            if( billProfList[0].NE__Payment__c == null || billProfList[0].NE__Payment__c == ''){
                billProfList[0].NE__Payment__c = 'Credit Card'; 
            }
            update billProfList;
            List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
            bpliList[0].XC_BillToContactId__c = conList[0].Id;
            bpliList[0].XC_SoldToContactId__c = conList[0].Id;
            bpliList[0].XC_LegalEntity__c = 'EndesaX';
            update bpliList;
        
            /*Opportunity opportunityToInsert = new Opportunity();
            opportunityToInsert.Name = 'OP00001';
            opportunityToInsert.XC_Contact__c = conList[0].Id;
            opportunityToInsert.AccountId = accountList[0].id;
          //  opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            //opportunityToInsert.XC_Source__c = 'BLOG';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_Address__c = address[0].Id;
            //opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
            insert opportunityToInsert;*/

            Opportunity opportunityToInsert = [SELECT Id FROM Opportunity LIMIT 1];
            
            Map<String, String> infos = new  Map<String, String>();
            infos.put('NE__AccountId__c',accountList[0].id);
            infos.put('stream','B2B');
            infos.put('clientSystem','CommodityItalyB2C'); 
            infos.put('productCategory','Service'); 
            infos.put('XC_Company_Code__c','test'); 
            infos.put('optyIdRM',opportunityToInsert.id); 
            infos.put('XC_DeliveryAddress__c',address[0].id); 
            infos.put('XC_Cost_Center__c','Tariff'); 
            infos.put('ChannelForOpp','channelTest'); 
            infos.put('productCategory','Service'); 

            
           
            XC_REST_MobilityOrder_W.createOpportunityForOrder(infos,'EndesaX');
            test.stopTest();
        }

    }
    
     @isTest
    static void createOpportunityForOrderTest2(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
       
        System.runAs(user[0]){
            test.startTest();
            NE__Product__c prod = new NE__Product__c();
            prod.XC_Product_Subtype__c = 'Tariff';
            prod.XC_Product_Type__c = 'Service';
            prod.XC_LIC_Product_Name__c = 'LUZ';
            insert prod;
    
            NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
            catItem.NE__Engine_Code__c = '001';
            catItem.NE__UsageCode__c = 'OKLUZ';
            catItem.NE__ProductId__c = prod.id;
            insert catItem;
    
            NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
            catalog.XC_LIC_Name__c = 'eHome -Ita';
            update catalog;
    
            List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
            insert accountList;
            List<Contact> conList = new List<Contact>();
            Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accountList[0].Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contsoldTo@test.it');
             insert contsoldTo;
             conList.add(contsoldTo);
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
            insert address;
     
     
            List<NE__Billing_Profile__c> billProfList = XC_DF_BillingProfile.createBillingProfile(1, accountList);
            if( billProfList[0].NE__Payment__c == null || billProfList[0].NE__Payment__c == ''){
                billProfList[0].NE__Payment__c = 'Credit Card'; 
            }
            update billProfList;
            List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
            bpliList[0].XC_BillToContactId__c = conList[0].Id;
            bpliList[0].XC_SoldToContactId__c = conList[0].Id;
            bpliList[0].XC_LegalEntity__c = 'EndesaX';
            update bpliList;
        
            /*Opportunity opportunityToInsert = new Opportunity();
            opportunityToInsert.Name = 'OP00001';
            opportunityToInsert.XC_Contact__c = conList[0].Id;
            opportunityToInsert.AccountId = accountList[0].id;
          //  opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            //opportunityToInsert.XC_Source__c = 'BLOG';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_Address__c = address[0].Id;
            //opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
            insert opportunityToInsert;*/

            Opportunity opportunityToInsert = [SELECT Id FROM Opportunity LIMIT 1];
            
            Map<String, String> infos = new  Map<String, String>();
            infos.put('NE__AccountId__c',accountList[0].id);
            infos.put('stream','B2C');
            infos.put('clientSystem','EnelXMSP'); 
            infos.put('productCategory','Service'); 
            infos.put('XC_Company_Code__c','test'); 
            infos.put('optyIdRM',opportunityToInsert.id); 
            infos.put('XC_DeliveryAddress__c',address[0].id); 
            infos.put('XC_Cost_Center__c','Tariff'); 
            infos.put('ChannelForOpp','channelTest'); 
            infos.put('productCategory','Service'); 

            
           
            XC_REST_MobilityOrder_W.createOpportunityForOrder(infos,'EndesaX');
            XC_REST_MobilityOrder_U.skipTestMFL();
            test.stopTest();
        }

    }

    

}