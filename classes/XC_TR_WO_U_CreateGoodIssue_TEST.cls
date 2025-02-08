/**
* @author Domenico Del Prete domenico.delprete@nttdata.com
* @date Creation  06/02/2020
* @description XC_TR_WO_U_CreateGoodIssue_TEST – Test class for XC_TR_WorkOrder_U_CreateGoodIssue && XC_TR_WorkOrder_U_CreateGoodIssue_U
*/ 
@isTest
public without sharing class XC_TR_WO_U_CreateGoodIssue_TEST {

    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
    }

    @isTest
    static void createGoodIssueFromSalesOrderTEST (){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Boiler', Label.XC_CL_WorkType_DeliveryInstallation);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
        listOfWo[0].XC_SentToGlovia__c = true;
        insert listOfWo;
        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
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
        insert wa;       
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test'
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
            Product2Id = p2.Id,
            QuantityRequired = 1,
            XC_Mode__c = 'Add',
            ParentRecordId = listOfWo[0].Id,
            XC_ProcurementType__c = 'Transfer'
        );
        insert pr;
        List<Id> listIdOfWo = new List<Id>();
        listIdOfWo.add(listOfWo[0].Id);
        XC_TR_WorkOrder_U_CreateGoodIssue.createGoodIssueFromSalesOrder(listIdOfWo);
        System.assert(!listIdOfWo.isEmpty());
    }
    
    @isTest
    static void createGoodIssueForRepairTEST2(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);


        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - Gas', Label.XC_CL_WorkType_Repair);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
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

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'Propano';
        update pAdd;

        List<gii__Product2Add__c> pAddDebug = new List<gii__Product2Add__c>([
            SELECT Id, giic_ProcurementType__c, gii__ProductCode__c
            FROM gii__Product2Add__c
        ]);
        System.debug('pAddDebug---> '+pAddDebug);
        List<NE__OrderItem__c> listOfOI = XC_DF_OrderItem.createOrderItems(1);
        insert listOfOI;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_WorkOrder__c = listOfWo[0].Id;
        insert listOfOpp;
        List<NE__OrderItem__c> listOfOrder = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id =: listOfOI[0].Id]);
        NE__Order__c order = new NE__Order__c(Id = listOfOrder[0].NE__OrderId__c);
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order;
        List<Asset> listOfAsset = XC_DF_Asset.createAssets(1);
        listOfAsset[0].XC_Product_Type__c = 'Technical';
        listOfAsset[0].XC_Product_Subtype__c = 'Product';
        listOfAsset[0].NE__Order_Config__c  = order.Id;
        insert listOfAsset;
        NE__AssetItemAttribute__c assetItem = new NE__AssetItemAttribute__c();
        assetItem.Name = 'Referencia';
        assetItem.NE__Asset__c = listOfAsset[0].Id;
        assetItem.NE__Value__c = 'Propano';
        insert assetItem;
        List<Id> listIdOfWo = new List<Id>();
        listIdOfWo.add(listOfWo[0].Id);
        XC_TR_WorkOrder_U_CreateGoodIssue_U.createGoodIssueForRepair(listIdOfWo);
    }
    
     @isTest
    static void createGoodIssueForRepairTEST(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);


        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - Gas', Label.XC_CL_WorkType_Repair);
        listOfWo[0].XC_AssignedPartner__c = accountList[0].Id;
        listOfWo[0].Status = 'New';
        insert listOfWo;
        listOfWo[0].Status = 'Canceled';
        update listOfWo;

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

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'Propano';
        update pAdd;

        List<gii__Product2Add__c> pAddDebug = new List<gii__Product2Add__c>([
            SELECT Id, giic_ProcurementType__c, gii__ProductCode__c
            FROM gii__Product2Add__c
        ]);
        System.debug('pAddDebug---> '+pAddDebug);
        List<NE__OrderItem__c> listOfOI = XC_DF_OrderItem.createOrderItems(1);
        insert listOfOI;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_WorkOrder__c = listOfWo[0].Id;
        insert listOfOpp;
        List<NE__OrderItem__c> listOfOrder = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c FROM NE__OrderItem__c WHERE Id =: listOfOI[0].Id]);
        NE__Order__c order = new NE__Order__c(Id = listOfOrder[0].NE__OrderId__c);
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order;
        List<Asset> listOfAsset = XC_DF_Asset.createAssets(1);
        listOfAsset[0].XC_Product_Type__c = 'Technical';
        listOfAsset[0].XC_Product_Subtype__c = 'Product';
        listOfAsset[0].NE__Order_Config__c  = order.Id;
        insert listOfAsset;
        NE__AssetItemAttribute__c assetItem = new NE__AssetItemAttribute__c();
        assetItem.Name = 'Referencia';
        assetItem.NE__Asset__c = listOfAsset[0].Id;
        assetItem.NE__Value__c = 'Propano';
        insert assetItem;
        List<Id> listIdOfWo = new List<Id>();
        listIdOfWo.add(listOfWo[0].Id);
        XC_TR_WorkOrder_U_CreateGoodIssue_U.createGoodIssueForRepair(listIdOfWo);
    }
}