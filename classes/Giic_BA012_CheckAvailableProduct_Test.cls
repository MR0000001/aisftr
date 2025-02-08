@isTest(SeeAllData=false)
public class Giic_BA012_CheckAvailableProduct_Test {
    
    @isTest static void CheckAvailableProduct_Test(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c,giic_Stream__c FROM gii__Product2Add__c limit 1];
		prodRefObj.giic_Stream__c = 'B2BG';
		Update prodRefObj;
		Product2 P2 = [SELECT Id, XC_SapType__c FROM Product2 limit 1];
		P2.XC_SapType__c = 'Material';
		Update p2;
        Giic_UtilityClass_Test.contractCreation();
        Contract Cont = [SELECT Id, giic_TotalAmount__c, XC_ContractType__c FROM Contract LIMIT 1];
        Cont.giic_TotalAmount__c = 10000;
        Cont.XC_ContractType__c = 'MATERIAL';
        Update Cont;
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        
        Test.startTest();
        Giic_BA012_CheckAvailableProduct batchobj = new Giic_BA012_CheckAvailableProduct();
        Id batchId=DataBase.executeBatch(batchobj); 
        Test.stopTest();    
        
    }
    
}