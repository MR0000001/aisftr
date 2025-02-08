/**
* @author Antonio D'Onofrio andonofrio@deloitte.it
* @date Creation 06/12/2020 
* @description XC_TR_ECI_TEST – Test class for XC_TR_ECI
*/



@isTest
public class XC_TR_ECI_TEST {

    @isTest
    static void insertTest(){
        Test.startTest();
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item',  migrationTool__c = true, B2WExtCat__External_Catalog__c= externalCatalog.Id);
        List<B2WExtCat__External_Catalog_Item__c> ecis = new List<B2WExtCat__External_Catalog_Item__c>();
        ecis.add(eci);
        insert ecis;
 
        Test.stopTest();
    }
        
    
    @isTest
    static void updateTest(){
        Test.startTest();
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item',  migrationTool__c = true, B2WExtCat__External_Catalog__c= externalCatalog.Id);
        List<B2WExtCat__External_Catalog_Item__c> ecis = new List<B2WExtCat__External_Catalog_Item__c>();
        ecis.add(eci);
        insert ecis;
        update ecis;
 
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest(){
        Test.startTest();
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item',  migrationTool__c = true, B2WExtCat__External_Catalog__c= externalCatalog.Id);
        List<B2WExtCat__External_Catalog_Item__c> ecis = new List<B2WExtCat__External_Catalog_Item__c>();
        ecis.add(eci);
        insert ecis;
        delete ecis;
 
        Test.stopTest();
    }
    


}