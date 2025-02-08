/** 
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 04/02/2020
* @description XC_UTIL_Glovia_TEST - Test class for XC_UTIL_Glovia
*/

@isTest
private class XC_UTIL_Glovia_TEST {       
   
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Glovia_TEST');

    @isTest
    private static void callGlovia() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        contractList[0].XC_CompanyCode__c = 'ES5R';
        contractList[0].recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ContractPartner').getRecordTypeId();
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        List<Account> listAcc = XC_DF_Account.createResidentialAccounts(1);
        listAcc[0].XC_Country__c = 'Spain';
        insert listAcc;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].Country__c = 'Spain';
        listAsset[0].XC_Address__c = listAddress[0].Id;
        insert listAsset;
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].PostalCode = '28050';
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].AccountId = listAcc[0].Id;
        listWo[0].AssetId = listAsset[0].Id;
        listWo[0].XC_LegalEntity__c = 'EnelXItalia';
        insert listWo;

        gii__WarehouseGroup__c wGroup = new gii__WarehouseGroup__c(
            Name = 'Test',
            giic_Warehouse_Group_Code__c = 'Test'
        );
        insert wGroup;
        gii__Warehouse__c wh = new gii__Warehouse__c(
            gii__Account__c = listWo[0].AccountId,
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test',
            gii__WarehouseGroup__c = wGroup.Id,
            giic_WarehouseType__c = Label.giic_WarehouseTypeCentral,            
            giic_LegalEntity__c = 'EndesaX'
        );
        insert wh;

        gii__ZoneTable__c zt = new gii__ZoneTable__c(gii__Type__c = 'Zip/Postal Code');
        insert zt;
        gii__ZoneTableZipPostalCode__c ztzp = new gii__ZoneTableZipPostalCode__c(
            gii__StartZipPostalCode__c = '28050',
            gii__ZoneTable__c = zt.Id
        );
        insert ztzp;
        giic_WarehaouseZoneZip__c whzp = new giic_WarehaouseZoneZip__c(
            giic_ZipPostalCode__c = ztzp.Id,
            giic_ZoneTable__c = zt.Id,
            giic_WarehouseGroup__c = wGroup.Id
        );
        insert whzp;      

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        update pAdd;
        ProductRequired pr = new ProductRequired(
            ParentRecordId = listWo[0].Id,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Add'
        );
        insert pr;

        gii__ProductInventory__c pi = new gii__ProductInventory__c(
            giic_AccountId__c = listWo[0].AccountId,
            gii__Warehouse__c = wh.Id,
            gii__Product__c = pAdd[0].Id,
            giic_LegalEntity__c = 'EndesaX'
        );
        insert pi;
        gii__ProductInventorybyLocation__c pil = new gii__ProductInventorybyLocation__c(
            gii__ProductInventory__c = pi.Id,
            gii__Product__c = pAdd[0].Id,
            gii__Warehouse__c = wh.Id,
            giic_SalesOnHand__c = 1
        );
        insert pil;

        Test.startTest();
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        XC_REST_Product_U.RequestWrapper wrAvailab = new XC_REST_Product_U.RequestWrapper();
        XC_REST_Product_U.CheckAvailabilityWrapper checkAvWrapper = new XC_REST_Product_U.CheckAvailabilityWrapper();
        checkAvWrapper.customer_zip_code = '28050';
        checkAvWrapper.address_id = listAddress[0].Id;
        checkAvWrapper.country = 'Spain';
        checkAvWrapper.partner_id = listSr[0].XC_Account__c;
        XC_REST_Product_U.ProductWrapper productWrapper = new XC_REST_Product_U.ProductWrapper();
        productWrapper.product_id = p2.Id;
        productWrapper.quantity = 1;
        productWrapper.request_type = 'Add';
        productWrapper.product_availability_date = Date.today();
        wrAvailab.product = new List<XC_REST_Product_U.ProductWrapper>{productWrapper};
        wrAvailab.check_availability = checkAvWrapper;
        
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].NE__Qty__c = 1;
        insert listOrderItem;
        List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id, NE__OptyId__c FROM NE__Order__c]);
        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.AccountId = listAcc[0].Id;
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Smart Home';
        opportunityToInsert.XC_WorkOrder__c = listWo[0].Id;
        insert opportunityToInsert;
        listOfOrder[0].NE__OptyId__c = opportunityToInsert.Id;
        update listOfOrder;
        XC_UTIL_Glovia.insertRecords(contractList);
        XC_UTIL_Glovia.getCompanyNameByCompanyCode(contractList);
        
        contractList[0].XC_CurrencyKey__c = 'USD';
         contractList[0].XC_CompanyCode__c = 'ES21';
        update contractList;
        listWo[0].XC_AssignedPartner__c = listAcc[0].Id;
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update listWo;
       // XC_UTIL_Glovia.AvailabilityResponseWrapper responseWrapper = XC_UTIL_Glovia.getAvailabilityWrapper(listWo[0].Id, new List<String>{listWo[0].AccountId});
        XC_UTIL_Glovia.checkAvailabilityShipment(wrAvailab);
        //XC_UTIL_Glovia.createSalesOrderFromConfig(listOfOrder[0].Id);
        listWo[0].XC_Configuration__c = listOfOrder[0].Id;
        update listWo;
        XC_UTIL_Glovia.updateRecord(listOfOrder[0]);
        XC_UTIL_Glovia.getBestPartner(new Map<Id, Date>{listSr[0].XC_Account__c => Date.today()});
        NE__Product__c prod = new NE__Product__c(
            Name = 'Test',
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = productWrapper.product_id
        );
        insert prod;
        NE__Product__c prodPromo = new NE__Product__c(
            Name = 'Test',
            NE__IsPromo__c = true,
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = productWrapper.product_id
        );
        insert prodPromo;
        NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c(
            NE__ProductId__c = prod.Id,
            NE__Min_Qty__c = 1,
            NE__Catalog_Id__c = cat.Id
        );
        insert catItem;
        NE__Promotion__c prom = new NE__Promotion__c(
            NE__Min_Qty__c = 1,
            NE__Start_Date__c = Datetime.now(),
            NE__Catalog_Id__c = cat.Id,
            NE__Commercial_Product__c = prodPromo.Id,
            NE__Prodotto__c = p2.Id
        );
        insert prom;
        NE__Promotion_Item__c promItem = new NE__Promotion_Item__c(
            NE__Catalog_Item__c = catItem.Id,
            NE__Promotion_Id__c = prom.Id
        );
        insert promItem;
        B2WExtCat__External_Catalog__c cec = new B2WExtCat__External_Catalog__c(
            B2WExtCat__External_Catalog_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now()
        );
        insert cec;
        B2WExtCat__External_Catalog_Item__c ceci = new B2WExtCat__External_Catalog_Item__c(
            B2WExtCat__External_Catalog_Item_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now(),
            B2WExtCat__Type__c = 'Item',
            B2WExtCat__External_Catalog__c = cec.Id
        );
        insert ceci;
        B2WExtCat__External_Catalog_Association__c ceca = new B2WExtCat__External_Catalog_Association__c(
            XC_TechnicalProduct__c = p2.Id,
            XC_Quantity__c = 1, 
            B2WExtCat__External_Catalog_Item__c = ceci.Id,
            B2WExtCat__Commercial_Catalog_Item__c = catItem.Id
        );
        List<B2WExtCat__External_Catalog_Association__c> ecaList = new List<B2WExtCat__External_Catalog_Association__c>();
        ecaList.add(ceca);
        XC_UTIL_Glovia.insertAndLogError(ecaList);
     
        
        XC_UTIL_Glovia.checkAvailabilityShipment(wrAvailab);               
        Test.stopTest();
        
        
        
    }
    
    
    @isTest
    private static void callGlovia2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        contractList[0].XC_CompanyCode__c = 'ES21';
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        List<Account> listAcc = XC_DF_Account.createResidentialAccounts(1);
        listAcc[0].XC_Country__c = 'Spain';
        insert listAcc;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].Country__c = 'Spain';
        listAsset[0].XC_Address__c = listAddress[0].Id;
        insert listAsset;
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].PostalCode = '28050';
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].AccountId = listAcc[0].Id;
        listWo[0].AssetId = listAsset[0].Id;
        insert listWo;

        gii__WarehouseGroup__c wGroup = new gii__WarehouseGroup__c(
            Name = 'Test',
            giic_Warehouse_Group_Code__c = 'Test'
        );
        insert wGroup;
        gii__Warehouse__c wh = new gii__Warehouse__c(
            gii__Account__c = listWo[0].AccountId,
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test',
            gii__WarehouseGroup__c = wGroup.Id,
            giic_WarehouseType__c = Label.giic_WarehouseTypeCentral,
            giic_LegalEntity__c = 'EndesaX'
        );
        insert wh;

        gii__ZoneTable__c zt = new gii__ZoneTable__c(gii__Type__c = 'Zip/Postal Code');
        insert zt;
        gii__ZoneTableZipPostalCode__c ztzp = new gii__ZoneTableZipPostalCode__c(
            gii__StartZipPostalCode__c = '28050',
            gii__ZoneTable__c = zt.Id
        );
        insert ztzp;
        giic_WarehaouseZoneZip__c whzp = new giic_WarehaouseZoneZip__c(
            giic_ZipPostalCode__c = ztzp.Id,
            giic_ZoneTable__c = zt.Id,
            giic_WarehouseGroup__c = wGroup.Id
        );
        insert whzp;      

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        update pAdd;
        ProductRequired pr = new ProductRequired(
            ParentRecordId = listWo[0].Id,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Add'
        );
        insert pr;

        gii__ProductInventory__c pi = new gii__ProductInventory__c(
            giic_AccountId__c = listWo[0].AccountId,
            gii__Warehouse__c = wh.Id,
            gii__Product__c = pAdd[0].Id,
            giic_LegalEntity__c = 'EndesaX'
        );
        insert pi;
        gii__ProductInventorybyLocation__c pil = new gii__ProductInventorybyLocation__c(
            gii__ProductInventory__c = pi.Id,
            gii__Product__c = pAdd[0].Id,
            gii__Warehouse__c = wh.Id,
            giic_SalesOnHand__c = 1
        );
        insert pil;

        Test.startTest();
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        XC_REST_Product_U.RequestWrapper wrAvailab = new XC_REST_Product_U.RequestWrapper();
        XC_REST_Product_U.CheckAvailabilityWrapper checkAvWrapper = new XC_REST_Product_U.CheckAvailabilityWrapper();
        checkAvWrapper.customer_zip_code = '28050';
        checkAvWrapper.address_id = listAddress[0].Id;
        checkAvWrapper.country = 'Spain';
        checkAvWrapper.partner_id = listSr[0].XC_Account__c;
        XC_REST_Product_U.ProductWrapper productWrapper = new XC_REST_Product_U.ProductWrapper();
        productWrapper.product_id = p2.Id;
        productWrapper.quantity = 1;
        productWrapper.request_type = 'Add';
        productWrapper.product_availability_date = Date.today();
        wrAvailab.product = new List<XC_REST_Product_U.ProductWrapper>{productWrapper};
        wrAvailab.check_availability = checkAvWrapper;
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].NE__Qty__c = 1;
        insert listOrderItem;

        XC_UTIL_Glovia.insertRecords(contractList);
        XC_UTIL_Glovia.getCompanyNameByCompanyCode(contractList);
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update listWo;
        XC_UTIL_Glovia.AvailabilityResponseWrapper responseWrapper = XC_UTIL_Glovia.getAvailabilityWrapper(listWo[0].Id, new List<String>{listWo[0].AccountId});
        
        
        try{
            Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();
            Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
            for(WorkOrder wo : listWo) {
                if(!mapAccountProvinces.containsKey(wo.XC_AssignedPartner__c)) {
                    mapAccountProvinces.put(wo.XC_AssignedPartner__c, new List<String>());
                }
                mapAccountProvinces.get(wo.XC_AssignedPartner__c).add(wo.State);
            }
            
            Map<String, gii__Warehouse__c> mapKeyWarehouse = XC_UTIL_Glovia.getMapWarehousesB2B(mapAccountProvinces);
            Map<String, gii__Warehouse__c> mapKeyWarehouse2 = XC_UTIL_Glovia.getMapWarehouses(mapAccountProvinces);
            
            XC_UTIL_Glovia.AvailabilityWrapper avWR = new XC_UTIL_Glovia.AvailabilityWrapper();
                avWR.zipCode                   = '28050';
                avWR.requestType               = 'Delivery Installation';
                avWR.country                   = 'Italy';
                avWR.partnerList               = new List<String>{listWo[0].AccountId};
                avWR.mapProductCodeQuantity    = new Map<String, Decimal>();
                //,engineCode                = 
                avWR.wo                        = listWo[0];
                avWR.legalEntity               = 'EnelXItalia';
                avWR.segment                   = 'B2B';
                avWR.fslKey                    = listWo[0].State;
          
            XC_UTIL_Glovia.checkAvailabilityDeliveryInstallation(avWR);
        }catch(Exception e){
            System.debug('TEST');
        }
        Test.stopTest();
        
        
        
    }


    @isTest
    private static void callGloviaB2C() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        contractList[0].XC_CompanyCode__c = 'ES21';
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        List<Account> listAcc = XC_DF_Account.createResidentialAccounts(1);
        listAcc[0].XC_Country__c = 'Spain';
        insert listAcc;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_BillingModel__c = '3 years renting';
        listAsset[0].Country__c = 'Spain';
        listAsset[0].XC_Address__c = listAddress[0].Id;
        insert listAsset;
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].PostalCode = '28050';
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].AccountId = listAcc[0].Id;
        listWo[0].AssetId = listAsset[0].Id;
        listWo[0].XC_NumberWorkOrdersDI__c = 1;
        insert listWo;

        gii__WarehouseGroup__c wGroup = new gii__WarehouseGroup__c(
            Name = 'Test',
            giic_Warehouse_Group_Code__c = 'Test'
        );
        insert wGroup;
        gii__Warehouse__c wh = new gii__Warehouse__c(
            gii__Account__c = listWo[0].AccountId,
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test',
            gii__WarehouseGroup__c = wGroup.Id,
            giic_WarehouseType__c = Label.giic_WarehouseTypeCentral,
            giic_LegalEntity__c = listWo[0].XC_LegalEntity__c
        );
        insert wh;

        gii__ZoneTable__c zt = new gii__ZoneTable__c(gii__Type__c = 'Zip/Postal Code');
        insert zt;
        gii__ZoneTableZipPostalCode__c ztzp = new gii__ZoneTableZipPostalCode__c(
            gii__StartZipPostalCode__c = '28050',
            gii__ZoneTable__c = zt.Id
        );
        insert ztzp;
        giic_WarehaouseZoneZip__c whzp = new giic_WarehaouseZoneZip__c(
            giic_ZipPostalCode__c = ztzp.Id,
            giic_ZoneTable__c = zt.Id,
            giic_WarehouseGroup__c = wGroup.Id
        );
        insert whzp;      

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        update pAdd;

        System.debug('###pAdd-->'+pAdd);
        ProductRequired pr = new ProductRequired(
            ParentRecordId = listWo[0].Id,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Add'
        );
        insert pr;

        gii__ProductInventory__c pi = new gii__ProductInventory__c(
            giic_AccountId__c = listWo[0].AccountId,
            gii__Warehouse__c = wh.Id,
            gii__Product__c = pAdd[0].Id
        );
        insert pi;
        gii__ProductInventorybyLocation__c pil = new gii__ProductInventorybyLocation__c(
            gii__ProductInventory__c = pi.Id,
            gii__Product__c = pAdd[0].Id,
            gii__Warehouse__c = wh.Id,
            giic_SalesOnHand__c = 1
        );
        insert pil;

        Test.startTest();
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        XC_REST_Product_U.RequestWrapper wrAvailab = new XC_REST_Product_U.RequestWrapper();
        XC_REST_Product_U.CheckAvailabilityWrapper checkAvWrapper = new XC_REST_Product_U.CheckAvailabilityWrapper();
        checkAvWrapper.customer_zip_code = '28050';
        checkAvWrapper.address_id = listAddress[0].Id;
        checkAvWrapper.country = 'Spain';
        checkAvWrapper.partner_id = listSr[0].XC_Account__c;
        XC_REST_Product_U.ProductWrapper productWrapper = new XC_REST_Product_U.ProductWrapper();
        productWrapper.product_id = p2.Id;
        productWrapper.quantity = 1;
        productWrapper.request_type = 'Add';
        productWrapper.product_availability_date = Date.today();
        wrAvailab.product = new List<XC_REST_Product_U.ProductWrapper>{productWrapper};
        wrAvailab.check_availability = checkAvWrapper;
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].NE__Qty__c = 1;
        insert listOrderItem;

        XC_UTIL_Glovia.insertRecords(contractList);
        XC_UTIL_Glovia.getCompanyNameByCompanyCode(contractList);
        listWo[0].XC_Address__c = listAddress[0].Id;
        listWo[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        update listWo;

        List<WorkOrder> listOfWoQueried = new List<WorkOrder>([
            SELECT Id, XC_ApplyCoverageFilterInBooking__c, XC_NumberWorkOrdersDI__c, XC_Conga_AssetProductName__c, XC_FSLAssignmentKey__c, XC_LegalEntity__c, XC_Segment__c, PostalCode, State, XC_AssignedPartner__c, XC_Configuration_Item__r.NE__ProdId__r.NE__Engine_Code__c,XC_Configuration_Item__r.NE__Qty__c,XC_Country__c,XC_Address__r.XC_AddressCountry__c ,
                (SELECT Id, Product2Id,Product2.ProductCode, ProductRequiredNumber,XC_Asset__r.SerialNumber, XC_Asset__c, XC_ProcurementType__c, QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c 
                FROM ProductsRequired 
                WHERE XC_Mode__c = 'Add'),
                (SELECT Id, XC_Conga_AssetProductName__c 
                FROM ChildWorkOrders
                WHERE XC_Conga_AssetProductName__c = 'Generic Technical Product')
            FROM WorkOrder
            WHERE Id = :listWo[0].Id
        ]);

        System.debug('###listWoQuery-->'+listOfWoQueried);
        XC_UTIL_Glovia.AvailabilityResponseWrapper responseWrapper = XC_UTIL_Glovia.getAvailabilityWrapper(listWo[0].Id, new List<String>{listWo[0].AccountId});            
            XC_UTIL_Glovia.AvailabilityWrapper avWR = new XC_UTIL_Glovia.AvailabilityWrapper();
                avWR.zipCode                   = '28050';
                avWR.requestType               = 'Delivery Installation';
                avWR.country                   = 'Italy';
                avWR.partnerList               = new List<String>{listWo[0].AccountId};
                avWR.mapProductCodeQuantity    = new Map<String, Decimal>();
                avWR.wo                        = listWo[0];
                avWR.legalEntity               = 'EnelXItalia';
                avWR.segment                   = 'B2C';
                avWR.fslKey                    = listWo[0].State;
            XC_UTIL_Glovia.checkAvailabilityDeliveryInstallation(avWR);
            listWo[0].XC_AssignedPartner__c = listWo[0].AccountId;
            XC_UTIL_Glovia.getMapWorkOrderWarehouse(listWo);
            Map<String, List<String>> mapAccountProvinces =  new Map<String, List<String>>();
            mapAccountProvinces.put(listWo[0].AccountId, new List<String>{listWo[0].State});
            XC_UTIL_Glovia.getMapWarehouses(mapAccountProvinces);
        Test.stopTest();    
    }


    

}