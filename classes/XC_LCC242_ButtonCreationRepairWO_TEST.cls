/**
 * The Class XC_LCC242_ButtonCreationRepairWO_TEST.
 *
 * @author            : 
 * @date Creation     : 10/03/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_LCC242_ButtonCreationRepairWO 
 **/

@isTest
public without sharing class XC_LCC242_ButtonCreationRepairWO_TEST {

    @TestSetup
    static void setup(){

        List<Asset> assetlist = XC_DF_Asset.createAssets(5);
        Asset a  = assetlist[0];
        
        List<Account> accounts = new List<Account>([SELECT ID FROM Account WHERE Id = : a.AccountId]);
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accounts);
        insert addresses;

        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        NE__Bundle__c bundle = XC_DF_Bundle.createBundleRecords(1)[0];
        insert bundle;

        a.XC_Address__c = addresses[0].Id;
        a.Name = 'type service';
        a.XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        a.XC_Product_Subtype__c = 'Repair';
        a.Status = Label.XC_CL_Asset_StatusActive;
        a.ContactId = contacts[0].Id;
        insert a;
        
        NE__Product__c prodToInsert = XC_DF_Product.createProducts(1)[0];
        prodToInsert.Name = 'Coverage Asset';
        insert prodToInsert;
        
        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prodToInsert.Id;
        insert catItem;
        
        Asset assetTypeSErvice  = assetlist[2];
        assetTypeSErvice.XC_Address__c = addresses[0].Id;
        assetTypeSErvice.Name = 'type service';
        assetTypeSErvice.AccountId = a.AccountId;
        assetTypeSErvice.NE__Bundle__c = bundle.Id;
        assetTypeSErvice.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        assetTypeSErvice.XC_Product_Subtype__c = 'Repair';
        assetTypeSErvice.Status = Label.XC_CL_Asset_StatusActive;
        assetTypeSErvice.ContactId = contacts[0].Id;

        insert assetTypeSErvice;
        
        Asset assetCoverage  = assetlist[1];
        assetCoverage.NE__CatalogItem__c = catItem.Id;
        assetCoverage.NE__ProdId__c = prodToInsert.Id;
        assetCoverage.NE__Bundle_Configuration__c = assetTypeSErvice.Id;
        assetCoverage.XC_Address__c = addresses[0].Id;
        assetCoverage.Name = 'Baxi Cov';
        assetCoverage.AccountId = a.AccountId;
        assetCoverage.NE__Bundle__c = bundle.Id;
        assetCoverage.XC_Product_Type__c = Label.XC_CL_ProductTypeCoverage;
        assetCoverage.XC_Product_Subtype__c = 'Repair';
        assetCoverage.Status = Label.XC_CL_Asset_StatusActive;
        assetCoverage.ContactId = contacts[0].Id;

        insert assetCoverage;

        Case cs = XC_DF_CASE.createCases(1)[0];
        cs.XC_Address__c = addresses[0].Id;
        cs.Reason = 'XCMOT002';
        cs.Status = 'ESTA001';
        cs.SubCause__c = 'ATCL003';
        cs.XC_Subtype__c = 'XC161';
        cs.AccountId = accounts[0].Id;
        cs.ContactId = contacts[0].Id;
        cs.AssetId = a.Id;
        insert cs;
        
        Case case2 = XC_DF_CASE.createCases(1)[0];
        case2.XC_Address__c = addresses[0].Id;
        case2.Reason = 'XCMOT002';
        case2.Status = 'ESTA001';
        case2.SubCause__c = 'ATCL081';
        case2.AccountId = accounts[0].Id;
        case2.ContactId = contacts[0].Id;
        //case2.AssetId = a.Id;
        insert case2;
    }

    @isTest
    static void checkAndPrepareRepairPreconditionsTest(){
        Case c = [SELECT Id FROM Case WHERE AssetId != null LIMIT 1];
        
        Test.startTest();
        XC_UTIL_ResultWrapper result = XC_LCC242_ButtonCreationRepairWO.checkAndPrepareRepairPreconditions(c.Id);
        Test.stopTest();
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void checkAndPrepareRepairPreconditionsFailedTest(){
        Case c1 = [SELECT Id, AssetId FROM Case WHERE AssetId = null LIMIT 1];
        Test.startTest();
        XC_UTIL_ResultWrapper result = XC_LCC242_ButtonCreationRepairWO.checkAndPrepareRepairPreconditions(c1.Id);
        Test.stopTest();
        System.assertEquals(false, result.success);
    }
    
    @isTest
    static void checkAndPrepareRepairPreconditionsFailedTest2(){
        Case c = [SELECT Id, AssetId FROM Case WHERE AssetId != null LIMIT 1];
        Asset ass = [SELECT Id, XC_Address__c FROM Asset WHERE Id =: c.AssetId];
        Test.startTest();
        ass.XC_Address__c = null;
        update ass;
        XC_UTIL_ResultWrapper result = XC_LCC242_ButtonCreationRepairWO.checkAndPrepareRepairPreconditions(c.Id);
        Test.stopTest();
        System.assertEquals(false, result.success);
    }

    @isTest
    static void workOrderCreationTest1(){
        Case c = [SELECT Id, XC_Subtype__c FROM Case WHERE AssetId != null LIMIT 1];
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('recordId', c.Id);
        inputMap.put('subtype', c.XC_Subtype__c);
        
        Test.startTest();
        XC_UTIL_ResultWrapper result = XC_LCC242_ButtonCreationRepairWO.workOrderCreation(inputMap);
        Test.stopTest();
        //System.assertEquals(true, result.success);
    }
    
    @isTest
    static void workOrderCreationTest2(){
        Case c = [SELECT Id, XC_Subtype__c FROM Case WHERE SubCause__c = 'ATCL081' LIMIT 1];
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('recordId', c.Id);
        inputMap.put('subtype', c.XC_Subtype__c);
        
        Test.startTest();
        XC_UTIL_ResultWrapper result = XC_LCC242_ButtonCreationRepairWO.workOrderCreation(inputMap);
        Test.stopTest();
        //System.assertEquals(true, result.success);
    }


}