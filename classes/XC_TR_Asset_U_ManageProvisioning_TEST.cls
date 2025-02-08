/**
 * The Class XC_TR_Asset_U_ManageProvisioning_TEST.
 *
 * @author            : Roberta Cossiga rcossiga@deloitte.it
 * @date Creation     : 25/03/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_TR_Asset_U_ManageProvisioning
 **/
@isTest
public without sharing class XC_TR_Asset_U_ManageProvisioning_TEST {
    
     @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }
    
     @isTest
    static void manageProvisioningTest(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<NE__OrderItem__c> listConfItem = XC_DF_OrderItem.createOrderItems(1); 
        insert listConfItem;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(listConfItem[0].Id);
        ps.XC_Step_Order__c = 1;
        insert ps;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Active';
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ProvisioningStep__c = ps.Id;
        insert assetList;
        
        test.startTest();
        assetList[0].XC_ElectricalConnectionType__c = 'Test';
        assetList[0].XC_ElectricalConnectionDate__c = System.today();
		update assetList;
        test.stopTest();
    }
    
    
    @isTest
    static void manageProvisioningServiceTypeTest(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        //NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        //NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c confItem = confItemList[0];
        insert confItem;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c = 1;
        insert ps;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Purchased';
        assetList[0].XC_Product_Type__c = Label.XC_CL_AssetType_Service;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ProvisioningStep__c = ps.Id;
        insert assetList;
        
        test.startTest();
        assetList[0].Status = 'Active';
        assetList[0].XC_ElectricalConnectionType__c = 'Test';
        assetList[0].XC_ElectricalConnectionDate__c = System.today();
		update assetList;
        test.stopTest();
    }


    @isTest
    static void manageProvisioningUpdateCheckRelatedProductActivationStep(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c confItem = confItemList[0];
        confItem.XC_RelatedProduct__c = 'Test';
        insert confItem;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c = 1;
        insert ps;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Purchased';
        assetList[0].XC_Product_Type__c = Label.XC_CL_AssetType_Service;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ProvisioningStep__c = ps.Id;
        assetList[0].XC_Configuration_Item__c = confItem.Id;
        assetList[0].NE__Item_Code__c = 'Test';
        insert assetList;
        
        test.startTest();
        assetList[0].Status = 'Active';
        assetList[0].XC_ElectricalConnectionType__c = 'Test';
        assetList[0].XC_ElectricalConnectionDate__c = System.today();
		update assetList;
        test.stopTest();
    }

    @isTest
    static void testCheckIfUpdateCheckAssetJuicebox(){
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        insert account;
        List<NE__Order__c> order = XC_DF_Order.createOrders(1, 'In Order');
        order[0].NE__AccountId__c = account[0].Id;
        insert order;
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order[0]);
        orderItem.NE__Account__c=account[0].id;
        insert orderItem;
        NE__OrderItem__c configurationItem =[SELECT id, NE__Account__c FROM NE__OrderItem__c LIMIT 1]; 
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(configurationItem.Id);
        ps.XC_Status__c = Label.XC_CL_InProgress; 
        ps.XC_Flow_API_Name__c = 'XC_FL_Provisioning_CheckAssetJuiceBox';
        ps.XC_Configuration_Item__c = configurationItem.Id;
        ps.XC_Step_Order__c = 1;
        insert ps;
        List<Asset> assetList = XC_DF_Asset.createAssets(account);
        assetList[0].Status = 'Purchased';
        insert assetList;
        
        test.startTest();
        assetList[0].Status = 'Active';
        assetList[0].XC_SpecialOfferType__c = Label.XC_CL_OpenCharge;
		update assetList;
        test.stopTest();
    }
    
    @isTest
    static void manageDeactivationStep(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c confItem = confItemList[0];
        confItem.XC_RelatedProduct__c = 'Test';
        confItem.XC_DeliveryStatus__c = 'In Progress';
        confItem.XC_DeliveryStatusList__c = 'In Progress,Delivered';
        insert confItem;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c = 1;
        insert ps;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Purchased';
        assetList[0].XC_Product_Type__c = Label.XC_CL_AssetType_Service;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ProvisioningStep__c = ps.Id;
        assetList[0].XC_Configuration_Item__c = confItem.Id;
        assetList[0].NE__Item_Code__c = 'Test';
        insert assetList;
        
        test.startTest();
        assetList[0].Status = 'Inactive';
        assetList[0].XC_ElectricalConnectionType__c = 'Test';
        assetList[0].XC_ElectricalConnectionDate__c = System.today();
		update assetList;
        test.stopTest();
    }
    
    @isTest
    static void updateCheckRelatedProductActivationStepTEST(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c confItem = confItemList[0];
        confItem.XC_RelatedProduct__c = 'Test';
        confItem.XC_DeliveryStatus__c = 'In Progress';
        confItem.XC_DeliveryStatusList__c = 'In Progress,Delivered';
        insert confItem;
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Step_Order__c = 1;
        insert ps;
        Map<Id, Asset> mapOldAsset = new Map<Id, Asset>();
        Map<Id, Asset> mapNewAsset = new Map<Id, Asset>();
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Purchased';
        assetList[0].XC_Product_Type__c = Label.XC_CL_AssetType_Service;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ProvisioningStep__c = ps.Id;
        assetList[0].XC_Configuration_Item__c = confItem.Id;
        assetList[0].NE__Item_Code__c = 'Test';
        assetList[0].Status = 'Purchased';
        insert assetList;
        for(Asset ast : assetList){
            mapOldAsset.put(ast.Id, ast);
        }
        assetList[0].Status = 'Active';
        assetList[0].NE__Item_Code__c = 'Test2';
        update assetList;
        for(Asset ast : assetList){
            mapNewAsset.put(ast.Id, ast);
        }
        test.startTest();
		XC_TR_Asset_U_ManageProvisioning.updateCheckRelatedProductActivationStep(assetList,mapOldAsset,mapNewAsset);
        test.stopTest();
    }
}