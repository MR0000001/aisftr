@IsTest
public class XC_LCC_SummaryAssetSection_Test {

    @TestSetup
    static void setup(){
    Account acc = new Account();
      acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
      acc.Name = 'Test Account n.';
      acc.PrimaryEmail__c = 'test_con@email.com'; 
      acc.XC_DocumentCountry__c = 'Spain';
      acc.IdentityType__c = 'NIF';
      acc.IdentityNumber__c = '84715536G';
      insert acc;
    Asset assetTest = new Asset();
        assetTest.XC_LegalEntity__c = 'EndesaX';
        assetTest.XC_Segment__c = 'B2B';
        assetTest.Name = 'BOMBILLA LED LG DICROICA 5_4W MR16';
        assetTest.AccountId = acc.Id;
        insert assetTest;  
}
    @isTest
     static void queryAssetTest(){
     String recordId = [SELECT Id FROM Asset LIMIT 1].Id;
       Test.startTest();
            XC_LCC_SummaryAssetSection.queryAsset(recordId);
        Test.stopTest();
    }  
    @isTest
     static void queryAssetCommercialTest(){
     String recordId = [SELECT Id FROM Asset LIMIT 1].Id;
       Test.startTest();
            XC_LCC_SummaryAssetSection.queryAssetCommercial(recordId);
        Test.stopTest();
    }
}