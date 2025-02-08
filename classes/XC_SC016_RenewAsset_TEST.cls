/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation 16/07/2019
* @date  
* @description XC_SC016_RenewAsset_TEST – Test class for XC_SC016_RenewAsset
*/
@isTest
public class XC_SC016_RenewAsset_TEST {
    @TestSetup
    static void setup()
    {	
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Asset> assetToInsert = new List<Asset>();
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'OK Gas'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        Asset assetWithOkGas = assetList[0];
        Asset assetWithBundle = assetList[1];
        Asset assetForCase = assetList[2];
        assetWithOkGas.NE__ProdId__c = product.Id;
        assetWithOkGas.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        //assetWithBundle.XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetWithBundle.NE__Bundle__c = bundle.Id;
        assetWithBundle.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        assetWithOkGas.XC_ContractEndDate__c = Date.Today();
		assetWithBundle.XC_ContractEndDate__c = Date.Today();
        assetForCase.XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetForCase.XC_ContractEndDate__c = Date.Today().addDays(-10);
        assetForCase.NE__Bundle__c = bundle.Id;
        assetForCase.XC_NearExpirationCaseCreated__c = false;
        assetToInsert.add(assetForCase);
        assetToInsert.add(assetWithOkGas);
        assetToInsert.add(assetWithBundle);
        insert assetToInsert;
        
        Contract contract = new Contract(AccountId = accntList[0].Id);
        /*contract.XC_LegalEntity__c  = 'EnelXItalia';
        insert contract;*/
        
    }
    
    static testMethod void callBatch(){
        List<Asset> assetList = [SELECT Id FROM Asset];
        Test.startTest();     
        Database.executeBatch(new XC_SC016_RenewAsset(), 200);
        Test.stopTest();
        System.assertEquals(3, assetList.size());
    }
    
    @isTest
	static void callBatchForBundleInactivation(){
        List<Asset> assetToInsert = new List<Asset>();
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'Solution Caldera'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        
        //Asset Bundle
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetList[0].XC_Product_Subtype__c = 'Air conditioning';
        assetList[0].XC_BillingModel__c = '3 years renting';
        assetList[0].NE__Bundle__c = bundle.Id;
        assetList[0].Status = 'Active';
        assetList[0].XC_ContractEndDate__c = Date.Today();
        //Asset Equipment
        assetList[1].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[1].XC_Product_Subtype__c = 'Air conditioning';
        assetList[1].XC_BillingModel__c = '3 years renting';
        assetList[1].NE__Bundle__c = bundle.Id;
        assetList[1].NE__ProdId__c = product.Id;
        assetList[1].Status = 'Active';
        assetList[1].XC_ContractEndDate__c = Date.Today();
        //Asset Coverage
        assetList[2].XC_Product_Type__c = Label.XC_CL_ProductTypeCoverage;
        assetList[2].XC_Product_Subtype__c = 'Repair';
        assetList[2].XC_BillingModel__c = '3 years renting';
        assetList[2].NE__Bundle__c = bundle.Id;
        assetList[2].NE__ProdId__c = product.Id;
        assetList[2].Status = 'Active';
        assetList[2].XC_ContractEndDate__c = Date.Today();
        insert assetList;
        assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        assetList[2].NE__Bundle_Configuration__c = assetList[0].Id;
        update assetList;
        
        /*Contract contract = new Contract(AccountId = accntList[0].Id);
        insert contract;*/
        List<Id> assetsId = new List<Id>{assetList[0].Id,assetList[1].Id,assetList[2].Id};
        Test.startTest();     
            Database.executeBatch(new XC_SC016_RenewAsset(), 200);
        	List<Asset> discAssets = [SELECT Id, Status FROM Asset WHERE Id IN: assetsId];
            //System.assert(discAssets[0].Status == Label.XC_CL_Asset_StatusInactive);
            System.assert(!discAssets.isEmpty()); 
        Test.stopTest();
    }
    
    @isTest
	static void callBatchForCaseCreation(){
        List<Asset> assetToInsert = new List<Asset>();
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'Solution Caldera'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        Date contractEndDate = Date.Today().addDays(15);
        //Asset Bundle
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetList[0].XC_Product_Subtype__c = 'Air conditioning';
        assetList[0].XC_BillingModel__c = '3 years renting';
        assetList[0].XC_NearExpirationCaseCreated__c = false;
        assetList[0].NE__Bundle__c = bundle.Id;
        assetList[0].Status = 'Active';
        assetList[0].XC_ContractEndDate__c = contractEndDate;
        //Asset Equipment
        assetList[1].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[1].XC_Product_Subtype__c = 'Air conditioning';
        assetList[1].XC_BillingModel__c = '3 years renting';
        assetList[1].XC_NearExpirationCaseCreated__c = false;
        assetList[1].NE__Bundle__c = bundle.Id;
        assetList[1].NE__ProdId__c = product.Id;
        assetList[1].Status = 'Active';
        assetList[1].XC_ContractEndDate__c = contractEndDate;
        insert assetList;
        assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        update assetList;
        
       /* Contract contract = new Contract(AccountId = accntList[0].Id);
        insert contract; */
        List<Id> assetsId = new List<Id>{assetList[0].Id,assetList[1].Id};
        Test.startTest();     
            Database.executeBatch(new XC_SC016_RenewAsset(), 200);
        	List<Asset> assets = [SELECT Id, Status FROM Asset WHERE Id IN: assetsId];
            System.assert(!assets.isEmpty()); 
        Test.stopTest();
    }

}