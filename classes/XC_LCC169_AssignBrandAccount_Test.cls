@isTest
public without sharing class XC_LCC169_AssignBrandAccount_Test {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @IsTest
    static void successTest(){
        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.XC_Brand__c = 'Test';
        insert catItem;
        Test.startTest();
        List<String> listOfBrand =XC_LCC169_AssignBrandAccount.retrievePickListValue();
        Test.stopTest();
        System.assert(!listOfBrand.isEmpty());
    }

    @IsTest
    static void successTest1(){
        List<Account> listOfAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listOfAccount;
        String typeSelected = 'Test';
        Test.startTest();
        XC_LCC169_AssignBrandAccount.ResultWrapper rw = XC_LCC169_AssignBrandAccount.assignBrand(listOfAccount[0].Id, typeSelected);
        Test.stopTest();
        System.assert(rw.success);  
    }

    @IsTest
    static void failedTest(){
        List<Account> listOfAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listOfAccount;
        String typeSelected = '--None--';
        Test.startTest();
        XC_LCC169_AssignBrandAccount.ResultWrapper rw = XC_LCC169_AssignBrandAccount.assignBrand(listOfAccount[0].Id, typeSelected);
        Test.stopTest();
        System.assert(!rw.success);  
    }

}