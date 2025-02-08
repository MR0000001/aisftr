/**
* @author Antonio D'Onofrio andonofrio@deloitte.it
* @date Creation 06/12/2020 
* @description XC_TR_ECA_TEST – Test class for XC_TR_ECA
*/



@isTest
public class XC_TR_ECA_TEST {

    @isTest
    static void insertTest(){
        Test.startTest();
        NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        
        NE__Catalog_Item__c ci = new NE__Catalog_Item__c(NE__Id__c = 'textxxx', NE__Catalog_Id__c = cat.Id);
        insert ci;
        
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item', B2WExtCat__External_Catalog__c= externalCatalog.Id);
        
        insert eci;
        
        B2WExtCat__External_Catalog_Association__c eca = new B2WExtCat__External_Catalog_Association__c(B2WExtCat__External_Catalog_Item__c = eci.id, migrationTool__c =true,SourceCommercialCatalogItemId__c = 'testxxx',B2WExtCat__Commercial_Catalog_Item__c = ci.id);
        List<B2WExtCat__External_Catalog_Association__c>  ecas = new List<B2WExtCat__External_Catalog_Association__c>();
        ecas.add(eca);
        insert ecas;
 
       
 
        Test.stopTest();
    }
        
    
    @isTest
    static void updateTest(){
        Test.startTest();

        
NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        
        NE__Catalog_Item__c ci = new NE__Catalog_Item__c(NE__Id__c = 'textxxx', NE__Catalog_Id__c = cat.Id);
        insert ci;
        
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item', B2WExtCat__External_Catalog__c= externalCatalog.Id);
        
        insert eci;
        
        B2WExtCat__External_Catalog_Association__c eca = new B2WExtCat__External_Catalog_Association__c(B2WExtCat__External_Catalog_Item__c = eci.id, migrationTool__c =true,SourceCommercialCatalogItemId__c = 'testxxx',B2WExtCat__Commercial_Catalog_Item__c = ci.id);
        List<B2WExtCat__External_Catalog_Association__c>  ecas = new List<B2WExtCat__External_Catalog_Association__c>();
        ecas.add(eca);
        insert ecas;
 
        update ecas;
        Test.stopTest();
 
        
    }
    
    @isTest
    static void deleteTest(){
        Test.startTest();
       NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        
        B2WExtCat__External_Catalog__c externalCatalog = new B2WExtCat__External_Catalog__c(B2WExtCat__External_Catalog_Name__c = 'Billing Catalog');
        insert externalCatalog;
        
        NE__Catalog_Item__c ci = new NE__Catalog_Item__c(NE__Id__c = 'textxxx', NE__Catalog_Id__c = cat.Id);
        insert ci;
        
        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
        zqu__ProductRatePlan__c prp= new zqu__ProductRatePlan__c(legacyId__c = 'xxx',
                                                                zqu__ZProduct__c = zp.Id,
                                                                name = 'test');
        insert prp;
        
        B2WExtCat__External_Catalog_Item__c eci = new B2WExtCat__External_Catalog_Item__c(B2WExtCat__External_Catalog_Item_Name__c = 'test',legacyCode__c = 'xxx',B2WExtCat__Type__c = 'Item', B2WExtCat__External_Catalog__c= externalCatalog.Id);
        
        insert eci;
        
        B2WExtCat__External_Catalog_Association__c eca = new B2WExtCat__External_Catalog_Association__c(B2WExtCat__External_Catalog_Item__c = eci.id, migrationTool__c =true,SourceCommercialCatalogItemId__c = 'testxxx',B2WExtCat__Commercial_Catalog_Item__c = ci.id);
        List<B2WExtCat__External_Catalog_Association__c>  ecas = new List<B2WExtCat__External_Catalog_Association__c>();
        ecas.add(eca);
        insert ecas;
 
        delete ecas;
 
        Test.stopTest();
    }
    


}