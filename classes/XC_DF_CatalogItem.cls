/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the NE__Catalog_Item__c object
*/
@isTest
public class XC_DF_CatalogItem {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description creates an instance of the NE__Catalog_Item__c object
    * @return the catalog item
    */
    public static NE__Catalog_Item__c createCatalogItem() {

        NE__Catalog__c catalog = new NE__Catalog__c();
        catalog.XC_LIC_Name__c = 'eHome';
        insert catalog;
		system.debug('@@@@### catalog '+ catalog);
        NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        //catalogCat.Name = 'Boiler';
        catalogCat.XC_LIC_Category_Name__c = 'Boiler';
        catalogCat.NE__CatalogId__c = catalog.Id;
        insert catalogCat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c();
        catItem.NE__Catalog_Category_Name__c = catalogCat.Id;
        catItem.NE__Catalog_Id__c = catalog.Id;
        catItem.NE__Type__c = 'Product';
        catItem.NE__Engine_Code__c = '134135';
        
        return catItem;
    }
}