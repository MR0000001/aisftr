/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 26/02/2020
* @description XC_TR_WorkOrder_U_CreateChildrenWO_TEST - Test class for XC_TR_WorkOrder_U_CreateChildrenWO
*/  

@isTest
private class XC_TR_WorkOrder_U_CreateChildrenWO_TEST {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateChildrenWO_TEST');

    @isTest
    private static void onInsert() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;        
        List<Asset> listParentAsset = XC_DF_Asset.createAssets(1);
        for(Asset ass : listParentAsset) {
            ass.XC_Address__c = listAddress[0].Id;
            ass.XC_Product_type__c = Label.XC_CL_AssetType_Service;
            ass.XC_Product_Subtype__c = Label.XC_CL_ProductSubTypeGas;
        }
        insert listParentAsset;

        NE__Product__c prodToInsert = XC_DF_Product.createProducts(1)[0];
        prodToInsert.Name = 'Coverage Asset';
        prodToInsert.XC_LIC_Product_Name__c = 'Coverage Asset';
        insert prodToInsert;

        List<Asset> listAssetChild = XC_DF_Asset.createAssets(2);
        for(Asset ass : listAssetChild) {
            ass.ParentId = listParentAsset[0].Id;
            ass.XC_Product_Subtype__c = Label.XC_CL_Subtype_Maintenance;
            ass.AccountId = listParentAsset[0].AccountId;
            ass.NE__ProdId__c = prodToInsert.Id;
        }
        insert listAssetChild;
        
        NE__DocumentationCharacterist__c docChar2 = new NE__DocumentationCharacterist__c();
        docChar2.Name = Label.XC_CL_Asset_CoverageType;
        docChar2.NE__Value__c = 'Boiler; Heaters; Equipment';
        docChar2.NE__Product__c = prodToInsert.Id;
        insert docChar2;

        Asset a = new Asset(
            Name = 'Baxi',
            XC_Address__c = listAddress[0].Id,
            XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment,
            XC_Product_Subtype__c = 'Boiler',
            Status = Label.XC_CL_Asset_StatusActive,
            AccountId = listParentAsset[0].AccountId
        );
        insert a;

        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        listWo[0].AssetId = listParentAsset[0].Id;

        Test.startTest();
        insert listWo;
        listWo[0].Status = 'Assigned';
        update listWo;
        System.assertNotEquals(null, listWo[0].Id);
        Test.stopTest();
    }

}