/**
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_TR_SalesOrder_Test
*/

@isTest
private class Giic_TR_RMA_Test {
    
    @isTest
    static void rmaInsertTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        gii__Warehouse__c  objWh = new gii__Warehouse__c(Name = 'Virtual Warehouse',
                                      giic_WarehouseType__c='Virtual',
                                      giic_WarehouseCode__c = 'VWW',
                                      giic_warehousecountryPick__c = 'Spain',
                                      gii__WareHouseCountry__c = 'Spain',
                                      giic_LegalEntity__c = 'EndesaX'
                                      );
        insert objWh;
		Test.startTest();
       gii__RMA__c ObjRMA = new gii__RMA__c( gii__Account__c = Giic_UtilityClass_Test.objAccountLocal.Id,
                                              gii__Warehouse__c = Giic_UtilityClass_Test.objWh.Id,
                                              CurrencyIsoCode = 'EUR');
        System.assertEquals('EUR', ObjRMA.CurrencyIsoCode);
        Test.stopTest();   
    }
    
     @isTest
    static void rmaUpdateTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
       
		Test.startTest();
        Giic_UtilityClass_Test.rmaCreation();
        update Giic_UtilityClass_Test.ObjRMA;
        System.assertEquals('EUR', Giic_UtilityClass_Test.ObjRMA.CurrencyIsoCode);
        Test.stopTest();   
    }
    
     @isTest
    static void rmaDeleteTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
       
		Test.startTest();
        Giic_UtilityClass_Test.rmaCreation();
        delete Giic_UtilityClass_Test.ObjRMA;
        List<gii__RMA__c> rmaList = [SELECT Id FROM gii__RMA__c WHERE CurrencyIsoCode = 'EUR']; 
        System.assertEquals(false, rmaList.size()>0);
        Test.stopTest();   
    }


}