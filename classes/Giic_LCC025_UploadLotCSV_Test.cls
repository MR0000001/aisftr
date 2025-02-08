@isTest
public class Giic_LCC025_UploadLotCSV_Test {
    
    
     @isTest static void separateCommasTest(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_LCC025_UploadLotCSV.separateCommas('test,test');
     }
         
         
     @isTest static void getCSVObjectTest(){
         Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_LCC025_UploadLotCSV.getCSVObject('test;test');
         
         
         
     }
    
    @isTest static void getCSVHeaderTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_CSVHeader h = new Giic_CSVHeader('Test','Text');
        Giic_LCC025_UploadLotCSV.getCSVObject('test\ntest\ntest');
         
         
         
     }
         
    
    

}