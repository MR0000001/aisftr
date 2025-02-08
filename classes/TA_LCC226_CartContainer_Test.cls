/*
@CreatedBy      - Benjamin Geronimo (benjamindelina.geronimo@webresults.it), 2020/01/20
@Description    - Test class for TA_LCC226_CartContainer
*/
@isTest
public with sharing class TA_LCC226_CartContainer_Test 
{
    @testSetup 
    static void setup( ) 
    {
        //TA_UTIL_Test.loadSetup( );
        // Giic_UtilityClass_Test.systemPolicyCreation();
        // Giic_UtilityClass_Test.gloviaSystemSettingCreation(); 
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            //XC_Country__c = 'Spain',
            giic_LegalEntity__c     = 'EnelXItalia',
            XC_Product_Type__c      = 'Technical Catalog',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        
        // gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        
          NE__Product__c prod = new NE__Product__c(
            Name = 'Test',
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = 'enginecode'
        );
        insert prod;
        NE__Product__c prodPromo = new NE__Product__c(
            Name = 'Test',
            NE__IsPromo__c = true,
            XC_LIC_Product_Name__c = 'Test',
            NE__Engine_Code__c = 'enginecode'
        );
        insert prodPromo;
        NE__Catalog__c cat = new NE__Catalog__c();
        insert cat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c(
            NE__ProductId__c = prod.Id,
            NE__Min_Qty__c = 1,
            NE__Catalog_Id__c = cat.Id
        );
        insert catItem;
        NE__Promotion__c prom = new NE__Promotion__c(
            NE__Min_Qty__c = 1,
            NE__Start_Date__c = Datetime.now(),
            NE__Catalog_Id__c = cat.Id,
            NE__Commercial_Product__c = prodPromo.Id,
            NE__Prodotto__c = p2.Id
        );
        insert prom;
        NE__Promotion_Item__c promItem = new NE__Promotion_Item__c(
            NE__Catalog_Item__c = catItem.Id,
            NE__Promotion_Id__c = prom.Id
        );
        insert promItem;
        B2WExtCat__External_Catalog__c cec = new B2WExtCat__External_Catalog__c(
            B2WExtCat__External_Catalog_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now()
        );
        insert cec;
        B2WExtCat__External_Catalog_Item__c ceci = new B2WExtCat__External_Catalog_Item__c(
            B2WExtCat__External_Catalog_Item_Name__c = 'Test',
            B2WExtCat__Start_Date__c = Datetime.now(),
            B2WExtCat__Type__c = 'Item',
            B2WExtCat__External_Catalog__c = cec.Id
        );
        insert ceci;
        B2WExtCat__External_Catalog_Association__c ceca = new B2WExtCat__External_Catalog_Association__c(
            XC_TechnicalProduct__c = p2.Id,
            XC_Quantity__c = 1, 
            B2WExtCat__External_Catalog_Item__c = ceci.Id,
            B2WExtCat__Commercial_Catalog_Item__c = catItem.Id
        );
        insert ceca;

        Product2 p2_2 = new Product2
        (
            isActive = true,
            Name                    = 'Test2',
            ProductCode             = 'Test2',
            //XC_Country__c         = 'Spain',
            giic_LegalEntity__c     = 'EnelXItalia',
            XC_Product_Type__c      = 'Technical Catalog',
            XC_ProductSubType__c    = 'Extra Service'
        );
        insert p2_2;
    }

    @isTest
    static void initialize_TA_LCP230_CartTechnicalCatalog_test( ) 
    {
        Test.startTest( );
        TA_LCC226_CartContainer.initialize_TA_LCP230_CartTechnicalCatalog( );
        Test.stopTest( );
    }

    @isTest
    static void initialize_TA_LCP229_CartMainProduct_test( ) 
    {
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs ( admin ) 
        {
            List<Account> listAccounts = XC_DF_Account.insertPartnerAccounts(1);
            List<Contact> listContacts = XC_DF_Contact.createPartnerContacts( listAccounts );
            insert listContacts;
            List<User> userList = XC_DF_User.createCommunityUsers( listContacts );
            user_1 = userList[0];
            insert user_1;
        }

        System.runAs ( user_1 ) 
        {
            String listOfItemsSerialized = '[{"fields": {"productenginecode": "enginecode"}}]';
        
            Test.startTest( );
            TA_LCC226_CartContainer.initialize_TA_LCP229_CartMainProduct( listOfItemsSerialized );
            TA_LCC226_CartContainer.initialize_TA_LCP229_CartMainProduct( null );
            Test.stopTest( );
        }
    }

    @isTest
    static void initialize_TA_LCP226_CartContainer_test() 
    {
        Test.startTest( );
        Map<String, Object> customConfigSerialized = new Map<String, Object>();
        customConfigSerialized.put('catalogName', 'test');
        TA_LCC226_CartContainer.initialize_TA_LCP226_CartContainer(JSON.serialize(customConfigSerialized));
        Test.stopTest( );
    }

    @isTest
    static void initialize_TA_LCP230_CartTechnicalCatalog_test_2( ) 
    {
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        System.runAs ( admin ) 
        {
            List<Account> listAccounts = XC_DF_Account.insertPartnerAccounts(1);
            List<Contact> listContacts = XC_DF_Contact.createPartnerContacts( listAccounts );
            insert listContacts;
            List<User> userList = XC_DF_User.createCommunityUsers( listContacts );
            user_1 = userList[0];
            user_1.XC_LegalEntity__c = 'EnelXItalia';
            insert user_1;
        }

        System.runAs ( user_1 ){       
        
            Test.startTest( );
            TA_LCC226_CartContainer.initialize_TA_LCP230_CartTechnicalCatalog( );
            Test.stopTest( );
        }
        
    }

    @isTest
    static void getDynamicLookupValue_Test() {
        NE__Dynamic_Lookup__c dynamicLookup = new NE__Dynamic_Lookup__c();
        dynamicLookup.NE__Name__c = 'KIT_Lookup';
        dynamicLookup.NE__Columns__c = 'test';
        dynamicLookup.NE__Search_specification__c = 'test';
        dynamicLookup.NE__sObject__c = 'test';
        insert dynamicLookup;

        String listAttributeDynamicLookupSerialized = '[{"id":"a1y6E000000Ga7ZQAS","fields":{"siis":null,"sourcedynamicpropertyid":"a270D000001O5loQAC","sourcefamilyid":"a2B0D000000prrIUAQ","offlineattribute":false,"DefaultValue":"","LicFamilyName":"Kit configurations","LicName":"Descrizione Kit","lastvalue":"","validationerror":"","readonly":"false","showInItem":false,"hiddenInCart":false,"itemCode":"a1y6E000000Ga7ZQAS","attributeCode":"Kit configurations:Descrizione Kit","pfpId":"a1y6E000000Ga7ZQAS","required":"Yes","hidden":"false","vid":"a1y6E000000Ga7ZQAS","dynamiclookup":"KIT_Lookup","showAs":"List","multiSelect":"false","idattr":"a1X6E000000EropUAC","type":"Dynamic Lookup","description":"","idfamily":"a1b6E000000EE0zQAG","familyname":"Kit configurations","id":"a1y6E000000Ga7ZQAS","name":"Descrizione Kit","validationexpression":"","value":"","familyProperty":"Kit configurations:Descrizione Kit","propid":"a1X6E000000EropUAC","idLineAttribute":"","enterpriseId":"","lineId":"","requiredfromdb":"No","previousvalue":""},"listOfDomains":[],"addToRoot":"true"}]';
        Test.startTest();
        TA_LCC226_CartContainer.getDynamicLookupValue(listAttributeDynamicLookupSerialized, '', '', '', '');
        Test.stopTest();
    }
}