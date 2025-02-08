@isTest
public class XC_SC036_EMSAssetManagement_TEST {
	@isTest
    static void onRunEvent() {
          User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
        system.runAs(u){
        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        assetList[0].status = 'Active';
        assetList[1].status = 'Inactive';
        assetList[0].XC_Segment__c = 'B2B';
        assetList[0].XC_ActivationDate__c=system.today();
        assetList[1].XC_Segment__c = 'B2B';
        insert assetList;
        
        List<NE__Product__c> prod = XC_DF_Product.createProducts(1);
        prod[0].XC_LIC_Product_Name__c =  'Monitoring And Verification Start';
        insert prod;
        NE__Catalog_Item__c catalogItem =  XC_DF_CatalogItem.createCatalogItem();
        catalogItem.NE__ProductId__c = prod[0].id;
        
        insert catalogItem;
        assetList[0].NE__CatalogItem__c = catalogItem.id;
        assetList[1].NE__CatalogItem__c = catalogItem.id;
        update assetList;
        
        Test.startTest();
        Database.executeBatch(new XC_SC036_EMSAssetManagement());
        Test.stopTest();
    }
   }     
}