@isTest
public without sharing class TA_LCC266_TechnicalAssetSearching_Test {
    
    // FD 29-07-2022 - NR2330 - START
    @isTest
    static void searchAsset() {
        

        List<Asset> assets = XC_DF_Asset.createAssets(1);
        assets[0].TAM_IsTechnical__c = true;
        insert assets[0];

        String accId = assets[0].AccountId;

        List<Account> accounts = [SELECT id, Name FROM Account WHERE Id = :accId];
        String accName = accounts[0].Name;

        Test.startTest();
        TA_LCC266_TechnicalAssetSearching.searchAsset(accName, 'Test');
        Test.stopTest();
    }
    // FD 29-07-2022 - NR2330 - END
}