/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 16/06/2021
 * @description XC_SC057_FixECA_TEST – Test class for XC_SC057_FixECA
 */

@isTest
private class XC_SC057_FixECA_TEST {

    @isTest
    static void onFixECA() {
        XC_CS_UtilityGlobalValues__c csCatalogName = new XC_CS_UtilityGlobalValues__c();
        csCatalogName.Name = 'CatalogNameToFixECA';
        csCatalogName.Value__c = 'e-Home ES';
        insert csCatalogName;
        XC_CS_UtilityGlobalValues__c csExternalName = new XC_CS_UtilityGlobalValues__c();
        csExternalName.Name = 'ExternalCatalogNameToFixECA';
        csExternalName.Value__c = 'Billing Catalog';
        insert csExternalName;
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertRecordsToFixECA';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;

        NE__Catalog_Item__c catItemWithEca = XC_DF_CatalogItem.createCatalogItem(); 
        NE__Catalog_Item__c catItemWithoutEca = XC_DF_CatalogItem.createCatalogItem(); 
        insert catItemWithoutEca;
        insert catItemWithEca;
        NE__Catalog__c catalog1 = new NE__Catalog__c(Name = 'e-Home ES', Id = catItemWithEca.NE__Catalog_Id__c);
        NE__Catalog__c catalog2 = new NE__Catalog__c(Name = 'e-Home ES', Id = catItemWithoutEca.NE__Catalog_Id__c);
        update catalog1;
        update catalog2;

        B2WExtCat__External_Catalog__c extCat = new B2WExtCat__External_Catalog__c(
            B2WExtCat__External_Catalog_Name__c = 'Billing Catalog'
        );
        insert extCat;
        B2WExtCat__External_Catalog_Item__c extCatItem = new B2WExtCat__External_Catalog_Item__c(
            B2WExtCat__External_Catalog__c = extCat.Id,
            B2WExtCat__Type__c = 'Process',
            B2WExtCat__External_Catalog_Item_Name__c = 'Billing Catalog',
            B2WExtCat__Start_Date__c = System.Now()
        );
        insert extCatItem;
        B2WExtCat__External_Catalog_Association__c extCatAss = new B2WExtCat__External_Catalog_Association__c(
            B2WExtCat__Commercial_Catalog_Item__c = catItemWithEca.Id,
            B2WExtCat__External_Catalog_Item__c = extCatItem.Id
        );
        insert extCatAss;

        NE__Price_List__c pList = new NE__Price_List__c(
            NE__Behaviour__c = 'Prices only',
            Name = 'List Test',
            NE__Catalog__c = catalog1.Id
        );
        insert pList;
        NE__Price_List_Version__c pcVersion = new NE__Price_List_Version__c(
            NE__Start_Date__c = System.now(),
            NE__Version__c = 1,
            NE__Price_List__c = pList.Id
        );
        insert pcVersion;

        NE__Price_List__c pList2 = new NE__Price_List__c(
            NE__Behaviour__c = 'Prices only',
            Name = 'List Test2',
            NE__Catalog__c = catalog2.Id
        );
        insert pList2;
        NE__Price_List_Version__c pcVersion2 = new NE__Price_List_Version__c(
            NE__Start_Date__c = System.now(),
            NE__Version__c = 1,
            NE__Price_List__c = pList2.Id
        );
        insert pcVersion2;

        NE__Price_List_Version_Item__c priceVersion1 = new NE__Price_List_Version_Item__c(
            NE__Catalog_Item__c = catItemWithoutEca.Id,
            NE__Base_One_Time_Fee__c = 1,
            NE__Net_One_Time_Fee__c = 1,
            NE__Reference_One_Time_Fee__c = 1,
            XC_TP_OnetimeFee__c = 1,
            NE__Base_Recurring_Charge__c = 1,
            NE__Net_Recurring_Charge__c = 1,
            NE__Reference_Recurring_Charge__c = 1,
            NE__Price_List_Version__c = pcVersion.Id,
            NE__Max_Limit__c = -1,
            NE__Min_Limit__c = -1
        );
        insert priceVersion1;
        NE__Price_List_Version_Item__c priceVersion2 = new NE__Price_List_Version_Item__c(
            NE__Catalog_Item__c = catItemWithEca.Id,
            NE__Base_One_Time_Fee__c = 1,
            NE__Net_One_Time_Fee__c = 1,
            NE__Reference_One_Time_Fee__c = 1,
            XC_TP_OnetimeFee__c = 1,
            NE__Base_Recurring_Charge__c = 1,
            NE__Net_Recurring_Charge__c = 1,
            NE__Reference_Recurring_Charge__c = 1,
            NE__Price_List_Version__c = pcVersion2.Id,
            NE__Max_Limit__c = -1,
            NE__Min_Limit__c = -1
        );
        insert priceVersion2;

        Test.startTest();
        Id batchId = Database.executeBatch(new XC_SC057_FixECA(), 10);
        XC_SC057_FixECA.cloneECAs(catItemWithoutEca, new List<B2WExtCat__External_Catalog_Association__c>{extCatAss});
        Test.stopTest();
    }

}