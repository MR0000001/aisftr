@isTest
private class Giic_LCC017_TransferOrderPath_Test {
    
    @isTest static void saveStatusTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreationTO();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.transferOrderCreation();
        
        Test.startTest();
        Giic_LCC017_TransferOrderPath.saveStatus(Giic_UtilityClass_Test.objTO.Id,'Open');
        Test.stopTest();
        
    }

}