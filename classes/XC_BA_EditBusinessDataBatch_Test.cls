@isTest
public with sharing class XC_BA_EditBusinessDataBatch_Test {

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
      XC_Address__c add = new XC_Address__c();
        add.XC_AddressProvince__c = 'Test';
        insert add;
    Contract cont = new Contract();
        cont.AccountId       = acc.Id;
        cont.XC_ContractSAP__c = 'Example';
        cont.XC_LegalEntity__c = null;
        cont.StartDate       = Date.today();
        cont.ContractTerm    = 1;
        insert cont;
    Asset assetTest = new Asset();
        assetTest.XC_LegalEntity__c = 'EndesaX';
        assetTest.XC_Segment__c = 'B2B';
        assetTest.Name = 'BOMBILLA LED LG DICROICA 5_4W MR16';
        assetTest.AccountId = acc.Id;
        assetTest.XC_Address__c = add.Id;
        assetTest.TAM_PartnerContract__c = cont.Id;
       // assetTest.RecordTypeID = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Network').getRecordTypeId();

        insert assetTest;  
        AssetExt__c assetExtTest = new AssetExt__c();
        assetExtTest.XC_Asset__c = assetTest.Id;
        assetExtTest.XC_ChangeDate__c = System.today();
        assetExtTest.XC_NewTAMPartnerContract__c = cont.Id;
        assetExtTest.XC_NewTAMAvailablePhone__c = 'NewPhone';
        assetExtTest.XC_NewTAMAvailableEmail__c= 'NewEmail';
        insert assetExtTest;  
    
    }
    
    @isTest
    private static void updateTest() {
        List<AssetExt__c> assetList = [Select Id,XC_Asset__c,XC_NewAssetServicedById__c,XC_ChangeDate__c,XC_NewTAMPartnerContract__c,XC_NewTAMAvailablePhone__c,XC_NewTAMAvailableEmail__c from AssetExt__c LIMIT 10]; 
        Test.startTest();
        XC_BA_EditBusinessDataBatch batch = new XC_BA_EditBusinessDataBatch();
        batch.Execute(null,assetList);
        XC_SB_EditBusinessDataBatch batchJob = new XC_SB_EditBusinessDataBatch();
        String strSchedule = '0 ' + '0' + ' ' + '0' + ' ' + '31' + ' ' + '12' + ' ?' + ' ' +System.Now().year() ;

        System.schedule('Sample Job '+System.now() , strSchedule, batchJob);
        
        Test.stopTest();   
    }



}