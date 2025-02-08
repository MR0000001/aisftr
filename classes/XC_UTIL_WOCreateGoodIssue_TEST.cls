/**
* @author Domenico Del Prete domenico.delprete@nttdata.com
* @date Creation  12/06/2020
* @description XC_UTIL_WOCreateGoodIssue_TEST – Test class for XC_UTIL_WOCreateGoodIssue 
*/ 
@isTest
public without sharing class XC_UTIL_WOCreateGoodIssue_TEST {
    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
    }

    @isTest
    static void createGoodIssueFromSalesOrderTEST (){
        Test.startTest();
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        System.debug('GetDML Statement after glovia -->'+Limits.getQueries());
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Boiler', Label.XC_CL_WorkType_DeliveryInstallation);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
        listOfWo[0].XC_LegalEntity__c  = 'EndesaX';
        //listOfWo[0].XC_SentToGlovia__c = true;  // SS: 22/06/2020
        listOfWo[0].XC_Segment__c = 'B2C';
        insert listOfWo;
        System.debug('GetDML Statement after account + glovia -->'+Limits.getQueries());
        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
        insert wareHouseG;
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Central Warehouse3',
                                      giic_WarehouseType__c='Central',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = accountList[0].Id, 
                                      gii__WarehouseGroup__c = wareHouseG.Id,
                                      giic_WarehouseCode__c = 'CW3',
                                      giic_warehousecountryPick__c = 'Spain',
                                      giic_LegalEntity__c = 'EndesaX'               
                                      );
        insert wa;   
        System.debug('GetDML Statement warehouse -->'+Limits.getQueries());
        Test.stopTest();    
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
        System.debug('GetDML Statement product -->'+Limits.getQueries());
        ProductRequired pr = new ProductRequired(
            Product2Id = p2.Id,
            QuantityRequired = 1,
            XC_Mode__c = 'Add',
            ParentRecordId = listOfWo[0].Id,
            XC_ProcurementType__c = 'Transfer'
        );
        insert pr;
        List<WorkOrder> listWoAllFields = XC_UTIL_Sobject.selectAllFields(listOfWo[0].Id);
        XC_UTIL_WOCreateGoodIssue.createGoodIssueFromSalesOrder(listWoAllFields);
        System.assert(pr != null);

    }
    
    @isTest
    static void createGoodIssueForRepairTEST2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);


        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - Gas', Label.XC_CL_WorkType_Repair);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
             listOfWo[0].XC_LegalEntity__c  = 'EndesaX';
        insert listOfWo;

        /*gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
        insert wareHouseG;
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Central Warehouse3',
                                      giic_WarehouseType__c='Central',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = accountList[0].Id, 
                                      gii__WarehouseGroup__c = wareHouseG.Id,
                                      giic_WarehouseCode__c = 'CW3',
                                      giic_warehousecountryPick__c = 'Spain',
                                      giic_LegalEntity__c = 'EnelX'               
                                      );
        insert wa;    */ 
        Test.startTest();
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano',
            XC_ProductSubType__c = 'Enel Spare Part',
             giic_LegalEntity__C = 'EndesaX'
        ); 
        Product2 p3 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano2',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        insert new List<Product2>{p2, p3};
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c
            FROM gii__Product2Add__c
            LIMIT 2
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'Propano';
        pAdd[1].giic_ProcurementType__c = 'Transfer';
        pAdd[1].gii__ProductCode__c = 'Propano'; 
        padd[1].gii__ProductStyle__c = pAdd[0].Id;
        update pAdd;  
 
        List<NE__OrderItem__c> listOfOI = XC_DF_OrderItem.createOrderItems(1);
        insert listOfOI;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        listOfOpp[0].XC_WorkOrder__c = listOfWo[0].Id;
        insert listOfOpp;
        List<NE__OrderItem__c> listOfOrder = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id =: listOfOI[0].Id]);
        NE__Order__c order = new NE__Order__c(Id = listOfOrder[0].NE__OrderId__c);
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        update order;
        List<Asset> listOfAsset = XC_DF_Asset.createAssets(1);
        listOfAsset[0].XC_Product_Type__c = 'Technical';
        listOfAsset[0].XC_Product_Subtype__c = 'Product';
        listOfAsset[0].NE__Order_Config__c  = order.Id;
        listOfAsset[0].XC_LegalEntity__c = 'EndesaX';
        listOfAsset[0].XC_Segment__c = 'B2C';
        insert listOfAsset;
        NE__AssetItemAttribute__c assetItem = new NE__AssetItemAttribute__c();
        assetItem.Name = 'Referencia';
        assetItem.NE__Asset__c = listOfAsset[0].Id;
        assetItem.NE__Value__c = 'Propano';
        insert assetItem;
        Test.stopTest();
        XC_UTIL_WOCreateGoodIssue.createGoodIssueRepair(listOfWo);
    }
    
     @isTest
    static void createGoodIssueForRepairTEST(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation(); 
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1); 
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - Gas', Label.XC_CL_WorkType_Repair);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
        listOfWo[0].Status = 'New';
        listOfWo[0].XC_LegalEntity__c  = 'EndesaX';
        insert listOfWo;
        listOfWo[0].Status = 'Canceled';
        listOfWo[0].XC_Digitized__c = true;
        update listOfWo; 
        Test.startTest();
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        Product2 p3 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano2',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX'
        );
        insert new List<Product2>{p2, p3};
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c
            FROM gii__Product2Add__c
            LIMIT 2
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'Propano';
        pAdd[1].giic_ProcurementType__c = 'Transfer';
        pAdd[1].gii__ProductCode__c = 'Propano'; 
        padd[1].gii__ProductStyle__c = pAdd[0].Id;
        update pAdd; 
 
        List<NE__OrderItem__c> listOfOI = XC_DF_OrderItem.createOrderItems(1);
        insert listOfOI;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        listOfOpp[0].XC_WorkOrder__c = listOfWo[0].Id;
        insert listOfOpp;
        List<NE__OrderItem__c> listOfOrder = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id =: listOfOI[0].Id]);
        NE__Order__c order = new NE__Order__c(Id = listOfOrder[0].NE__OrderId__c);
        order.XC_LegalEntity__c = 'EndesaX'; 
        order.XC_Segment__c = 'B2C'; 
        order.NE__OptyId__c = listOfOpp[0].Id;
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        update order;
        List<Asset> listOfAsset = XC_DF_Asset.createAssets(1);
        listOfAsset[0].XC_Product_Type__c = 'Technical';
        listOfAsset[0].XC_Product_Subtype__c = 'Product';
        listOfAsset[0].NE__Order_Config__c  = order.Id;
        listOfAsset[0].XC_LegalEntity__c = 'EndesaX';
        listOfAsset[0].XC_Segment__c = 'B2C';
        insert listOfAsset;
        NE__AssetItemAttribute__c assetItem = new NE__AssetItemAttribute__c();
        assetItem.Name = 'Referencia';
        assetItem.NE__Asset__c = listOfAsset[0].Id;
        assetItem.NE__Value__c = 'Propano';
        insert assetItem;
        Test.stopTest();
        XC_UTIL_WOCreateGoodIssue.createGoodIssueRepair(listOfWo);
    }
    @isTest
    static void createWrapperErrorTEST (){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - Gas', Label.XC_CL_WorkType_Repair);
        listOfWo[0].Status = 'New';
        listOfWo[0].XC_LegalEntity__c  = 'EndesaX';
        insert listOfWo;
        XC_UTIL_WOCreateGoodIssue.createWrapperError(listOfWo[0].Id, 'Error Message');
    }
}