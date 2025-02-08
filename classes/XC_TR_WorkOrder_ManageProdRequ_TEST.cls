/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/02/2020
* @description XC_TR_WorkOrder_ManageProdRequ_TEST – Test Class for XC_TR_WorkOrder_ManageProductRequired
*/

@isTest
private class XC_TR_WorkOrder_ManageProdRequ_TEST {
    
    @isTest
    static void createProductRequiredTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;  
        Test.startTest();
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrdersAsset(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation, 'Boiler');
        insert listWo;
        System.assert(listWo.isEmpty() == false);
        Test.stopTest();
    }

    @isTest
    static void onUtility(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;  
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
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

        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].NE__Qty__c = 1;
        listOrderItem[0].XC_Product_Type__c = 'Equipment';
        listOrderItem[0].XC_Product_Subtype__c = 'Photovoltaic';
        insert listOrderItem;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_BillingModel__c = '3 years renting';
        insert listAsset;
        Test.startTest();
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].AssetId = listAsset[0].Id;
        listWo[0].XC_Configuration_Item__c = listOrderItem[0].Id;
         listWo[0].XC_LegalEntity__c  = 'EndesaX';
        insert listWo;
        
        B2WExtCat__External_Catalog__c cat = new B2WExtCat__External_Catalog__c ();
        cat.B2WExtCat__External_Catalog_Name__c = 'test';
        insert cat;
        
        B2WExtCat__External_Catalog_Item__c catItem = new B2WExtCat__External_Catalog_Item__c ();
        catItem.B2WExtCat__Type__c = 'item';
        catItem.B2WExtCat__External_Catalog__c = cat.Id;
        catItem.B2WExtCat__External_Catalog_Item_Name__c = 'test';
        insert catItem;        
        
        B2WExtCat__External_Catalog_Association__c catAss = new B2WExtCat__External_Catalog_Association__c();
        catAss.XC_TechnicalProduct__c = p2.Id;
        catAss.B2WExtCat__Commercial_Catalog_Item__c = listOrderItem[0].NE__CatalogItem__c;
        catAss.B2WExtCat__External_Catalog_Item__c = catItem.Id;
        insert catAss;

        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c,XC_AssignedPartner__c, Asset.XC_CMCostCenter__c, Asset.XC_WBE__c, Asset.Id, XC_Configuration_Item__r.NE__ProdId__c, XC_Configuration_Item__r.NE__Qty__c, Asset.XC_BillingModel__c
            FROM WorkOrder 
            WHERE Id = :listWo[0].Id
        ]);

        
        XC_TR_WorkOrder_ManageProductRequired.getSerialController(new Set<String>{p2.Id});
        XC_TR_WorkOrder_ManageProductRequired.createProductRequired(listWorkOrder[0], new Map<String, Decimal>{p2.Id=>1}, 1);
        System.assert(listWo.isEmpty() == false);
        Test.stopTest();
    }
    
    @isTest
    static void onUtilityTEchProd(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;  
        Product2 p2 = new Product2(
            ProductCode = 'testCode',
            isActive = true,
            Name = 'Test',
             giic_LegalEntity__C = 'EndesaX'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'testCode';
        update pAdd;
        
        

        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(2);
        listOrderItem[0].NE__Qty__c = 1;
        listOrderItem[0].XC_Product_Type__c = 'Technical';
        listOrderItem[0].XC_Product_Subtype__c = 'Product';
        listOrderItem[1].NE__Qty__c = 1;
        listOrderItem[1].XC_Product_Type__c = 'Technical';
        listOrderItem[1].NE__OrderId__c =  listOrderItem[0].NE__OrderId__c;
        listOrderItem[1].XC_Product_Subtype__c = 'Product';
        listOrderItem[1].XC_ProvisioningSpareParts__c = false;
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id, XC_LegalEntity__c FROM NE__Order__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        }
        update orderList;
        List<Asset> listAsset = XC_DF_Asset.createAssets(2);
        Id recordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('XC_ESP_Customer').getRecordTypeId();
        for(Asset ast : listAsset){
            ast.recordTypeId = recordTypeId;
            ast.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        }
        listAsset[0].XC_Product_Type__c = 'Technical';
        listAsset[0].XC_Product_Subtype__c = 'Product';
        listAsset[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        listAsset[0].NE__Order_Config__c = listOrderItem[0].NE__OrderId__c;
        listAsset[0].XC_BillingModel__c = 'One Shot';
        listAsset[1].XC_BillingModel__c = 'One Shot';
        listAsset[1].NE__Order_Config__c = listOrderItem[0].NE__OrderId__c;
        listAsset[1].XC_Configuration_Item__c = listOrderItem[1].Id;
        listAsset[1].XC_Product_Type__c = 'Technical';
        listAsset[1].XC_Product_Subtype__c = 'Product';
        insert listAsset;
        
        List<NE__AssetItemAttribute__c> listAttr = new List<NE__AssetItemAttribute__c>();
        NE__AssetItemAttribute__c attr = new NE__AssetItemAttribute__c();
        attr.Name = 'Referencia';
        attr.NE__Value__c = 'testCode';
        attr.NE__Asset__c = listAsset[0].Id;
        listAttr.add(attr);
        NE__AssetItemAttribute__c attr2 = new NE__AssetItemAttribute__c();
        attr2.Name = 'Referencia';
        attr2.NE__Value__c = 'testCode';
        attr2.NE__Asset__c = listAsset[1].Id;
        listAttr.add(attr2);
        insert listAttr;
        
        
        Test.startTest(); 
        
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].AssetId = listAsset[0].Id;
        listWo[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        listWo[0].XC_LegalEntity__c  = 'EndesaX';
        insert listWo;
        
         

        Test.stopTest();
    }
}