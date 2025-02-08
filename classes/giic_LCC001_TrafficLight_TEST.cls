@isTest
private class giic_LCC001_TrafficLight_TEST {
    
    @isTest static void setTrafficLightSOred() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_DF_Glovia.systemPolicyCreation();
        Giic_DF_Glovia.gloviaSystemSettingCreation();
        Test.startTest();
        
        gii__SalesOrder__c so =  Giic_DF_Glovia.createSalesOrder();
        insert so;
        gii__SalesOrderLine__c sol = Giic_DF_Glovia.createSalesOrderLine(so);
        insert sol;
        giic_LCC001_TrafficLight.setTrafficLight(so.Id,'gii__SalesOrder__c');
        Test.stopTest();
    }
     @isTest static void setTrafficLightSOyellow() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        gii__Warehouse__c wh = Giic_UtilityClass_Test.ObjWh; 
        Giic_UtilityClass_Test.locationCreation();
        gii__Location__c loc = Giic_UtilityClass_Test.objLocationCentral; 
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObjList = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        
        Test.startTest();
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.creationPI(wh,prodRefObjList);
        List<gii__ProductInventory__c> lstProductInventory = Giic_UtilityClass_Test.lstProductInventory;  
        Giic_UtilityClass_Test.creationPILocation(lstProductInventory[0],prodRefObjList[0]);
        gii__ProductInventoryByLocation__c piByLoc = Giic_UtilityClass_Test.objPILocation;  
        piByLoc.giic_SalesOnHand__c = 1;
        update piByLoc;
        gii__ProductInventoryQuantityDetail__c piQD = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=lstProductInventory[0].id,
                                                                                                 gii__ProductInventorybyLocation__c=piByLoc.id,
                                                                                                 gii__Warehouse__c = wh.Id,
                                                                                                 gii__Location__c = loc.Id,
                                                                                                 gii__Product__c=prodRefObjList[0].id,
                                                                                                 giic_Reserved__c = 1);
        insert piQD; 
        
        gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(gii__SalesOrder__c=so.Id, 
                                                                gii__Warehouse__c=so.gii__Warehouse__c, 
                                                                gii__ProductInventory__c=lstProductInventory[0].Id, 
                                                                gii__Product__c=prodRefObjList[0].Id,
                                                                gii__OrderQuantity__c = 1);
        insert sol;
        giic_LCC001_TrafficLight.setTrafficLight(so.Id,'gii__SalesOrder__c');
        Test.stopTest();
    }
    @isTest static void setTrafficLightSOLred() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_DF_Glovia.systemPolicyCreation();
        Giic_DF_Glovia.gloviaSystemSettingCreation();
        Test.startTest();
        gii__SalesOrder__c so = Giic_DF_Glovia.createSalesOrder();
        insert so;
        gii__SalesOrderLine__c sol = Giic_DF_Glovia.createSalesOrderLine(so);
        insert sol;
        giic_LCC001_TrafficLight.setTrafficLight(sol.Id,'gii__SalesOrderLine__c');
        Test.stopTest();
        
    }
    
    @isTest static void setTrafficLightSOLyellow() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        gii__Warehouse__c wh = Giic_UtilityClass_Test.ObjWh; 
        Giic_UtilityClass_Test.locationCreation();
        gii__Location__c loc = Giic_UtilityClass_Test.objLocationCentral; 
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObjList = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        
        Test.startTest();
        Giic_UtilityClass_Test.salesOrderCreation();
        gii__SalesOrder__c so = Giic_UtilityClass_Test.objSalesOrder; 
        Giic_UtilityClass_Test.creationPI(wh,prodRefObjList);
        List<gii__ProductInventory__c> lstProductInventory = Giic_UtilityClass_Test.lstProductInventory;  
        Giic_UtilityClass_Test.creationPILocation(lstProductInventory[0],prodRefObjList[0]);
        gii__ProductInventoryByLocation__c piByLoc = Giic_UtilityClass_Test.objPILocation;  
        piByLoc.giic_SalesOnHand__c = 1;
        update piByLoc;
        gii__ProductInventoryQuantityDetail__c piQD = new gii__ProductInventoryQuantityDetail__c(gii__ProductInventory__c=lstProductInventory[0].id,
                                                                                                 gii__ProductInventorybyLocation__c=piByLoc.id,
                                                                                                 gii__Warehouse__c = wh.Id,
                                                                                                 gii__Location__c = loc.Id,
                                                                                                 gii__Product__c=prodRefObjList[0].id,
                                                                                                 giic_Reserved__c = 1);
        insert piQD; 
        
        gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(gii__SalesOrder__c=so.Id, 
                                                                gii__Warehouse__c=so.gii__Warehouse__c, 
                                                                gii__ProductInventory__c=lstProductInventory[0].Id, 
                                                                gii__Product__c=prodRefObjList[0].Id,
                                                                gii__OrderQuantity__c = 1);
        insert sol;
        giic_LCC001_TrafficLight.setTrafficLight(sol.Id,'gii__SalesOrderLine__c');
        Test.stopTest();
     }
}