/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation  22/01/2021
* @description XC_LCC215_SupplierAsset_TEST – Test class for XC_LCC215_SupplierAsset
*/ 
@isTest
public class XC_LCC215_SupplierAsset_TEST {

    @isTest
    static void getSupplierRepairTest(){
        List<Asset> assetList  = XC_DF_Asset.createAssets(1);
        assetList[0].Name = 'Assistenza h24';
        assetList[0].XC_ContractStartDate__c = Date.today();
        insert assetList;
        XC_CS007_SupplierAsset__c customSettingSupplierAsset = new XC_CS007_SupplierAsset__c();
        customSettingSupplierAsset.Name = 'TestCS';
        customSettingSupplierAsset.XC_TypeOfSupplier__c = 'Repair';
        customSettingSupplierAsset.XC_ContractStartDate__c = Date.today();
        customSettingSupplierAsset.XC_ContractEndDate__c = Date.today().addYears(1);
        customSettingSupplierAsset.XC_NameOfSupplier__c = 'Test';
        customSettingSupplierAsset.XC_ProductLicName__c = 'Assistenza h24';
        customSettingSupplierAsset.XC_TypeOfContract__c = 'New Contract';
        insert customSettingSupplierAsset;
        XC_LCC215_SupplierAsset.getSupplier(assetList[0].Id);
    }

    @isTest
    static void getSupplierInsuranceTest(){
        List<Asset> assetList  = XC_DF_Asset.createAssets(1);
        assetList[0].Name = 'Assistenza h24';
        assetList[0].XC_ContractStartDate__c = Date.today().addYears(-1).addMonths(-1);
        insert assetList;
        XC_CS007_SupplierAsset__c customSettingSupplierAsset = new XC_CS007_SupplierAsset__c();
        customSettingSupplierAsset.Name = 'TestCS';
        customSettingSupplierAsset.XC_TypeOfSupplier__c = 'Insurance';
        customSettingSupplierAsset.XC_ContractStartDate__c = Date.today().addYears(-1);
        customSettingSupplierAsset.XC_ContractEndDate__c = Date.today().addYears(1);
        customSettingSupplierAsset.XC_NameOfSupplier__c = 'Test';
        customSettingSupplierAsset.XC_ProductLicName__c = 'Assistenza h24';
        customSettingSupplierAsset.XC_TypeOfContract__c = 'Renewal';
        insert customSettingSupplierAsset;
        XC_LCC215_SupplierAsset.getSupplier(assetList[0].Id);
    }

    @isTest
    static void getSupplierNoCSTest(){
        List<Asset> assetList  = XC_DF_Asset.createAssets(1);
        assetList[0].Name = 'Assistenza h24';
        assetList[0].XC_ActivationDate__c = Datetime.now();
        insert assetList;
        XC_LCC215_SupplierAsset.getSupplier(assetList[0].Id);
    }
}