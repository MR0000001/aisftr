/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_SalesOrder_Test
*/

@isTest
private class giic_TR_PriceBook_Test {
    
    @isTest
    static void priceBookTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'IT2K';
        update Giic_UtilityClass_Test.objContract;
        Test.startTest();
        try{
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookCreationDuplicate();
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.giic_PriceBookDuplicationError) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }    
		 System.assertEquals('Test',Giic_UtilityClass_Test.objPriceBook.Name);
        Test.stopTest();
        
    }
    
     @isTest
    static void priceBookUpdateTest(){
       Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'IT2K';
        update Giic_UtilityClass_Test.objContract;
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Test.startTest();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        System.assertEquals('Test',Giic_UtilityClass_Test.objPriceBook.Name);
        update Giic_UtilityClass_Test.objPriceBook;
        update Giic_UtilityClass_Test.objPriceBookEntry;
        Test.stopTest();    
    }
    
    
    
    @isTest
    static void priceBookDeleteTest(){
       Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'IT2K';
        update Giic_UtilityClass_Test.objContract;
        Giic_UtilityClass_Test.objContract.XC_CompanyCode__c = 'ES5R';
        update Giic_UtilityClass_Test.objContract;
        Test.startTest();
        Giic_UtilityClass_Test.priceBookCreation();
        gii__PriceBook__c priceBook = Giic_UtilityClass_Test.objPriceBook;
        delete priceBook;
        List<gii__PriceBook__c> priceBookList = [SELECT Id FROM gii__PriceBook__c WHERE Name = 'Test'];
		System.assertEquals(false,priceBookList.size()>0);
        Test.stopTest();    
    }
    
    

}