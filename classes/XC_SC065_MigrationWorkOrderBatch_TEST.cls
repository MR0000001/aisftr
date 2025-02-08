/**
* @author Danilo Ortolani - dortolani@deloitte.it
* @description Test of the XC_SC065_MigrationWorkOrderBatch class
*/

@isTest
public class XC_SC065_MigrationWorkOrderBatch_TEST {
    
    @testSetup
    private static void setup() {
        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        insert prodList;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<Asset> mainAsset = XC_DF_Asset.createAssets(1);
        mainAsset[0].XC_Product_Type__c = 'Service';
        mainAsset[0].XC_Product_SubType__c = 'test';
        mainAsset[0].NE__Order_Config__c = order.Id;
        mainAsset[0].Status = 'Active';
        
        insert mainAsset;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        assetList[0].XC_Product_Type__c = 'Equipment';
        assetList[0].XC_Product_SubType__c = 'test';
        assetList[0].NE__Bundle_Configuration__c = mainAsset[0].Id;
        assetList[0].Status = 'Active';
        
        assetList[1].XC_Product_Type__c = 'Coverage';
        assetList[1].XC_Product_SubType__c = 'Maintenance';
        assetList[1].NE__Order_Config__c = order.Id;
        assetList[1].NE__Root_Order_Item__c = mainAsset[0].Id;
        assetList[1].Status = 'Active';
        
        assetList[2].XC_Product_Type__c = 'Coverage';
        assetList[2].XC_Product_SubType__c = 'Maintenance';
        assetList[2].NE__Order_Config__c = order.Id;
        assetList[2].NE__Bundle_Configuration__c = mainAsset[0].Id;
        assetList[2].NE__ProdID__c = prodList[0].Id; 
        assetList[2].Status = 'Active';
        insert assetList;
        
        System.debug('###: ' + XC_DF_Product.createProducts(1)[0]?.Id);

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, 'Diagnostic');
        woList[0].Status = 'Cannot Complete';
        woList[0].AssetId = mainAsset[0].Id;
        insert woList;
        
        List<NE__DocumentationCharacterist__c> docCharacteristList = new List<NE__DocumentationCharacterist__c>();
        docCharacteristList.add(new NE__DocumentationCharacterist__c(Name = 'Coverage Type', NE__Product__c = assetList[2].NE__ProdID__c, NE__Value__c = 'test'));
        insert docCharacteristList;
    }
    
    @isTest
    private static void startBatchTEST() {
        Id batchId = Database.executeBatch(new XC_SC065_MigrationWorkOrderBatch(NULL), 200);
    }

}