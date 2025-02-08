@isTest
public with sharing class TA_LCC250_SelectAccount_Test {
    
    @isTest
    private static void initialize_Test() {
        TA_LCC250_SelectAccount.InitializeWrapper wr = new TA_LCC250_SelectAccount.InitializeWrapper();
        TA_LCC250_SelectAccount.CreateWorkOrderResult createWo = new TA_LCC250_SelectAccount.CreateWorkOrderResult();
        createWo.workOrderId = 'test';
        Test.startTest();
        wr = TA_LCC250_SelectAccount.initialize();
        Test.stopTest();
    }


    @isTest
    private static void populateProductTypePicklist_Test() {
        List<String> result = new List<String>();
        Test.startTest();
        result = TA_LCC250_SelectAccount.populateProductTypePicklist('test');
        Test.stopTest();
    }

    @isTest
    private static void searchAccount_Test() {

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        XC_Address__c add = XC_DF_Address.createAddress(1)[0];
        add.XC_Account__c = acc.Id;
        insert add;

        List<TA_LCC250_SelectAccount.AccountWrapper> accountWrapperListToReturn = new List<TA_LCC250_SelectAccount.AccountWrapper>();

        Test.startTest();
        accountWrapperListToReturn = TA_LCC250_SelectAccount.searchAccount('test');
        accountWrapperListToReturn = TA_LCC250_SelectAccount.searchAccount('testNull');
        Test.stopTest();
    }

    @isTest
    private static void createWorkOrder_Test1() {

        WorkType wt = new WorkType();
        wt.Name = 'Commercial Visit - Electric Installation';
        wt.EstimatedDuration = 1.0;
        insert wt;
        

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.IsActive = true;
        sr.Name = 'Jacopo Scaravaggi';
        insert sr;

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;


        Test.startTest();
        system.debug(TA_LCC250_SelectAccount.createWorkOrder(acc.Id, '', null, null));
        Test.stopTest();
    } 

    @isTest
    private static void createWorkOrder_Test2() {

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.IsActive = true;
        sr.Name = 'Jacopo Scaravaggi';
        insert sr;

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        Test.startTest();
        system.debug(TA_LCC250_SelectAccount.createWorkOrder(acc.Id, 'Boiler', null, null));
        Test.stopTest();
    } 

    @isTest
    private static void createWorkOrder_Test3() {

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.IsActive = true;
        sr.Name = 'Jacopo Scaravaggi';
        insert sr;

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        List<Contact> contList = XC_DF_Contact.createResidentialContacts(new List<Account> {acc});
        insert contList;

        Test.startTest();
        system.debug(TA_LCC250_SelectAccount.createWorkOrder(acc.Id, '', null, null));
        Test.stopTest();
    } 

    @isTest
    private static void createWorkOrder_Test4() {

        ServiceResource sr = new ServiceResource();
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.IsActive = true;
        sr.Name = 'Jacopo Scaravaggi';
        insert sr;

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        List<Contact> contList = XC_DF_Contact.createResidentialContacts(new List<Account> {acc});
        insert contList;

        Test.startTest();
        system.debug(TA_LCC250_SelectAccount.createWorkOrder(acc.Id, 'Boiler', null, null));
        Test.stopTest();
    } 

    @isTest
    private static void createWorkOrder_Test5() {

        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        Test.startTest();
        system.debug(TA_LCC250_SelectAccount.createWorkOrder(acc.Id, 'Boiler', null, null));
        Test.stopTest();
    } 


    @isTest
    private static void createAddress_Test() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.XC_FirstName__c = 'test';
        acc.XC_LastName__c = 'test';
        acc.PrimaryEmail__c = 'test@test.it';
        acc.XC_DocumentCountry__c = 'italy';
        acc.IdentityType__c='CF';
        acc.IdentityNumber__c='TSTTST80A01A794V';
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        insert acc;

        Map<String, Object> addressMap = new Map<String, Object>();

        // TA_LCC250_SelectAccount.AddressWrapper addWrapper = new TA_LCC250_SelectAccount.AddressWrapper();
        // addWrapper.addressId = 'Test';
        // addWrapper.streetType = 'Test';
        // addWrapper.streetName = 'Test';
        // addWrapper.streetNumber = 'Test';
        // addWrapper.city = 'Test';
        // addWrapper.postalCode = 'Test';
        // addWrapper.selected = false;

        Test.startTest();
        TA_LCC250_SelectAccount.createAddress(addressMap, acc.id);
        TA_LCC250_SelectAccount.createAddress(addressMap, null);
        Test.stopTest();
    }
}