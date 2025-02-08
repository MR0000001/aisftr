/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC052_SelectAvblAcctFromIndi_TEST – Test class for XC_LCC052_SelectAvaibleAccountFromIndiv
*/ 
@isTest
public  class XC_LCC052_SelectAvblAcctFromIndi_TEST {
     //Test Method selectAvaibleAccount
     
    @isTest
    static void selectAvaibleAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 


        List<Map<String,String>> result = XC_LCC052_SelectAvaibleAccountFromIndiv.selectAvaibleAccount(c[0].Id);
        System.assert(!result.isEmpty());
        XC_LCC052_SelectAvaibleAccountFromIndiv.showResidentialAddress([SELECT Id FROM RecordType WHERE DeveloperName = 'XC_Opportunity_ITA'][0].Id);
        XC_LCC052_SelectAvaibleAccountFromIndiv.showResidentialAddress([SELECT Id FROM RecordType LIMIT 1][0].Id);
        XC_LCC052_SelectAvaibleAccountFromIndiv.checkAvaibleLE([SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name LIKE '%italy%'][0].Id);
        Test.stopTest();
    }


    @isTest
    static void getAddressesForOppTest(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 

        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        insert addresses;

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.getAddressesForOpp(acc[0].Id);
        Test.stopTest();

    }

    @isTest
    static void checkChangeAddress(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 

        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        insert addresses;

        List<Opportunity> optyList = XC_DF_Opportunity.createOpportunityWithoutVisit(c, addresses[0]);
        insert optyList;

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.checkChangeAddress(optyList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void getProductTypeSubtypeValuesTest(){
        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.getProductTypeValues();
            XC_LCC052_SelectAvaibleAccountFromIndiv.getProductSubTypeValues();
        Test.stopTest();
    }

    @isTest
    static void createAssetApexTest(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        insert addresses;
        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        insert catItem;
        NE__Catalog_Category__c catCategory = [SELECT ID FROM NE__Catalog_Category__c LIMIT 1];
        NE__Catalog__c catalog = [SELECT ID FROM NE__Catalog__c LIMIT 1];

        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('contactId',c[0].Id);
        inputMap.put('accountId',acc[0].Id);
        inputMap.put('catalog',catalog.Id);
        inputMap.put('catalogCategory',catCategory.Id);
        inputMap.put('addressId',addresses[0].Id);
        inputMap.put('description','test equipment');
        inputMap.put('modelValue','TEST MODEL');
        inputMap.put('productType','TEST');
        inputMap.put('productSubType','TEST');

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.createAssetApex(JSON.serialize(inputMap));
        Test.stopTest();


    }

    @isTest
    static void updateOpportunityAddressTest(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        addresses[0].XC_ElectricCUPS__c = '0393839338';
        addresses[0].XC_GasCUPS__c = '393383839';
        insert addresses;
        List<Opportunity> optyList = XC_DF_Opportunity.createOpportunityWithoutVisit(c, addresses[0]);
        insert optyList;

        Map<String,Object> inputFields = new Map<String,Object>();
        inputFields.put('addressId',addresses[0].Id);
        inputFields.put('opportunityId',optyList[0].Id);

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.updateOpportunityAddress(JSON.serialize(inputFields));
        Test.stopTest();
    }


    @isTest
    static void getAccountFromOpportunityTest(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        insert addresses;
        List<Opportunity> optyList = XC_DF_Opportunity.createOpportunityWithoutVisit(c, addresses[0]);
        insert optyList;

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.getAccountFromOpportunity(optyList[0].Id);
        Test.stopTest();

    }

    @isTest
    static void selectAvaibleContactTest(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<Contact> c= XC_DF_Contact.createResidentialContacts(acc);
        insert c ; 

        List<XC_Address__c> addresses = XC_DF_Address.createAddress(acc);
        insert addresses;

        Test.startTest();
            XC_LCC052_SelectAvaibleAccountFromIndiv.selectAvaibleContact(acc[0].Id);
        Test.stopTest();
    }
 
}