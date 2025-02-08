/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 06/10/2021
 * @description giic_BA014_InventoryMaintenance_TEST - Test Class for giic_BA014_InventoryMaintenance
 */

@isTest
private class giic_BA014_InventoryMaintenance_TEST {

    @isTest
    static void onExecuteNoSerialProduct() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef = [SELECT Id, gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd LIMIT 1];
        Giic_UtilityClass_Test.transferOrderCreation();
        List<gii__TransferOrder__c> lstTO = new List<gii__TransferOrder__c>();
        lstTO.add(Giic_UtilityClass_Test.objTO);
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        prodinvntyforLocal.gii__OrderQuantityMultiple__c=1;
        prodinvntyforLocal.gii__MinimumOrderQuantity__c=1;
        prodinvntyforLocal.gii__OrderPointQuantity__c=1;
        insert prodinvntyforLocal;  
        Gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c LIMIT 1];
        prodRefObj.gii__SerialControlled__c=true;
        prodRefObj.gii__PrimarySupplier__c = giic_UtilityClass_Test.objAccountSupplier.id;
        update prodRefObj;    
        List<gii__ProductInventory__c> listPI = Database.query(XC_UTIL_Sobject.selectAllFieldsGetSelect('gii__ProductInventory__c') + ' FROM gii__ProductInventory__c');
        for(gii__ProductInventory__c pi : listPI) {
            gii__ProductInventorybyLocation__c objPILocation = new gii__ProductInventorybyLocation__c(
                gii__ProductInventory__c = pi.id,
                gii__Product__c = objProdRef.id,
                gii__Warehouse__c = pi.gii__Warehouse__c,
                gii__Location__c = Giic_UtilityClass_Test.objLocationlocal.id
            );
            insert objPILocation;
            gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(
                gii__ProductInventory__c = pi.id,
                gii__Warehouse__c = pi.gii__Warehouse__c,
                gii__Location__c= Giic_UtilityClass_Test.objLocationlocal.id,
                gii__Product__c = objProdRef.id,
                gii__ProductInventorybyLocation__c = objPILocation.Id,
                gii__OnHandQuantity__c = 1.00
            );
            insert objPID;
            gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c(
                gii__ProductInventory__c = pi.Id,
                gii__AGC__c = 'Business Sales',
                gii__AdjustmentDate__c = Date.today(),
                gii__AdjustmentQuantity__c = 1,
                gii__Location__c = Giic_UtilityClass_Test.objLocationlocal.id,
                gii__ProductInventoryQuantityDetail__c = objPID.Id,
                gii__ProductInventorybyLocation__c = objPILocation.Id,
                gii__Product__c = objProdRef.Id,
                gii__Reason__c = 'Stock Cleaning',
                gii__StockUM__c = 'Each',
                gii__Warehouse__c = pi.gii__Warehouse__c
            );
            insert adjToInsert;
        }

        Test.startTest();
        Database.executeBatch(new giic_BA014_InventoryMaintenance(), 1);
        giic_BA014_InventoryMaintenance.insertBatchErrorLog('TestClass');
        Map<Id, gii__ProductInventory__c> mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>{listPI[0].Id => listPI[0]};
        Map<String, Map<String, Decimal>> mapNewCalculatedQuantity = new Map<String, Map<String, Decimal>>{listPI[0].Id => new Map<String, Decimal>{
                                                                                                                'qtyBackOrder' => 0,
                                                                                                                'qtyReserved' => 0,
                                                                                                                'qtySalesOnHand' => 0,
                                                                                                                'qtyAvailability' => 0
                                                                                                            }};
        Map<String, Map<String, Decimal>> mapRecentQuantity = new Map<String, Map<String, Decimal>>{listPI[0].Id => new Map<String, Decimal>{
                                                                                                        'qtyBackOrder' => 1,
                                                                                                        'qtyReserved' => 1,
                                                                                                        'qtySalesOnHand' => 1,
                                                                                                        'qtyAvailability' => 1
                                                                                                    }};
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapResultsQuantityDetail = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        String queryPIQD = XC_UTIL_Sobject.selectAllFieldsGetSelect('gii__ProductInventoryQuantityDetail__c') + ' , gii__ProductSerial__r.giic_StatusCode__c, gii__ProductSerial__r.gii__TransferOrderId__r.gii__TransferToWarehouse__c, gii__ProductInventory__r.gii__Warehouse__c FROM gii__ProductInventoryQuantityDetail__c ';
        List<gii__ProductInventoryQuantityDetail__c> listPiqdForMap = Database.query(queryPIQD);
        for(gii__ProductInventoryQuantityDetail__c singlePIQD : listPiqdForMap) {
            if(!mapResultsQuantityDetail.containsKey(singlePIQD.gii__ProductInventory__c)) {
                mapResultsQuantityDetail.put(singlePIQD.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>());
            }
            mapResultsQuantityDetail.get(singlePIQD.gii__ProductInventory__c).add(singlePIQD);
        }
        giic_BA014_InventoryMaintenance.getMapQuantityDetail(listPi);                               
        giic_BA014_InventoryMaintenance.checkAfterMaintenance(mapPiWithNewValues, mapPiWithNewValues, mapNewCalculatedQuantity, mapRecentQuantity, true, true, true, new Set<String>{listPi[0].Id});
        giic_BA014_InventoryMaintenance.checkAfterMaintenance(mapPiWithNewValues, mapPiWithNewValues, mapNewCalculatedQuantity, mapRecentQuantity, false, false, false, new Set<String>());
        giic_BA014_InventoryMaintenance.maintenanceInventory(listPI, mapRecentQuantity, mapNewCalculatedQuantity, mapResultsQuantityDetail, true, true, true, new Set<String>{listPi[0].Id});
        giic_BA014_InventoryMaintenance.maintenanceInventory(listPI, mapRecentQuantity, mapNewCalculatedQuantity, mapResultsQuantityDetail, false, false, false, new Set<String>());
        giic_BA014_InventoryMaintenance.doShipment(listPI);
        Test.stopTest();
    }

    @isTest
    static void onExecuteSerialProduct() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef = [SELECT Id, gii__ProductCode__c FROM gii__Product2Add__c WHERE gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd LIMIT 1];
        Giic_UtilityClass_Test.transferOrderCreation();
        List<gii__TransferOrder__c> lstTO = new List<gii__TransferOrder__c>();
        lstTO.add(Giic_UtilityClass_Test.objTO);
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        gii__ProductInventory__c prodinvntyforLocal= new gii__ProductInventory__c();
        prodinvntyforLocal.gii__Product__c=objProdRef.Id;
        prodinvntyforLocal.gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id;
        prodinvntyforLocal.gii__OrderQuantityMultiple__c=1;
        prodinvntyforLocal.gii__MinimumOrderQuantity__c=1;
        prodinvntyforLocal.gii__OrderPointQuantity__c=1;
        insert prodinvntyforLocal;  
        Gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c LIMIT 1];
        prodRefObj.gii__SerialControlled__c=true;
        prodRefObj.gii__PrimarySupplier__c = giic_UtilityClass_Test.objAccountSupplier.id;
        update prodRefObj;    
        List<gii__ProductInventory__c> listPI = Database.query(XC_UTIL_Sobject.selectAllFieldsGetSelect('gii__ProductInventory__c') + ' FROM gii__ProductInventory__c');
        for(gii__ProductInventory__c pi : listPI) {
            gii__ProductInventorybyLocation__c objPILocation = new gii__ProductInventorybyLocation__c(
                gii__ProductInventory__c = pi.id,
                gii__Product__c = objProdRef.id,
                gii__Warehouse__c = pi.gii__Warehouse__c,
                gii__Location__c = Giic_UtilityClass_Test.objLocationlocal.id
            );
            insert objPILocation;
            gii__ProductInventoryQuantityDetail__c objPID = new gii__ProductInventoryQuantityDetail__c(
                gii__ProductInventory__c = pi.id,
                gii__Warehouse__c = pi.gii__Warehouse__c,
                gii__Location__c= Giic_UtilityClass_Test.objLocationlocal.id,
                gii__Product__c = objProdRef.id,
                gii__ProductInventorybyLocation__c = objPILocation.Id,
                gii__OnHandQuantity__c = 1.00
            );
            insert objPID;
            gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c(
                gii__ProductInventory__c = pi.Id,
                gii__AGC__c = 'Business Sales',
                gii__AdjustmentDate__c = Date.today(),
                gii__AdjustmentQuantity__c = 1,
                gii__Location__c = Giic_UtilityClass_Test.objLocationlocal.id,
                gii__ProductInventoryQuantityDetail__c = objPID.Id,
                gii__ProductInventorybyLocation__c = objPILocation.Id,
                gii__Product__c = objProdRef.Id,
                gii__Reason__c = 'Stock Cleaning',
                gii__StockUM__c = 'Each',
                gii__Warehouse__c = pi.gii__Warehouse__c
            );
            insert adjToInsert;
        }

        insert new giic_GloviaUTIL__c(
            Name = 'GeneralSetting',
            giic_CalculateShippedQuantity__c = true,
            giic_CheckSerialMaintenanceInventory__c = true,
            giic_forceRecalculateMultiSales__c = false,
            giic_OnlyCheck__c = false,
            giic_QueryMaintenanceInventory__c = 'LIMIT 10'
        );

        gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c();
        adjToInsert.gii__ProductInventory__c = listPI[0].Id;
        adjToInsert.gii__AGC__c = 'Business Sales';
        adjToInsert.gii__AdjustmentDate__c = Date.today();
        adjToInsert.gii__AdjustmentQuantity__c = 1;
        adjToInsert.gii__Product__c = listPI[0].gii__Product__c;
        adjToInsert.gii__Reason__c = 'Stock Cleaning';
        adjToInsert.gii__StockUM__c = 'Each';
        adjToInsert.gii__Warehouse__c = listPI[0].gii__Warehouse__c;
        insert adjToInsert;

        Test.startTest();
        Database.executeBatch(new giic_BA014_InventoryMaintenance(), 1);
        giic_BA014_InventoryMaintenance.insertBatchErrorLog('TestClass');
        Map<Id, gii__ProductInventory__c> mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>{listPI[0].Id => listPI[0]};
        Map<String, Map<String, Decimal>> mapNewCalculatedQuantity = new Map<String, Map<String, Decimal>>{listPI[0].Id => new Map<String, Decimal>{
                                                                                                                'qtyBackOrder' => 0,
                                                                                                                'qtyReserved' => 0,
                                                                                                                'qtySalesOnHand' => 0,
                                                                                                                'qtyAvailability' => 0
                                                                                                            }};
        Map<String, Map<String, Decimal>> mapRecentQuantity = new Map<String, Map<String, Decimal>>{listPI[0].Id => new Map<String, Decimal>{
                                                                                                        'qtyBackOrder' => 1,
                                                                                                        'qtyReserved' => 1,
                                                                                                        'qtySalesOnHand' => 1,
                                                                                                        'qtyAvailability' => 1
                                                                                                    }};
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapResultsQuantityDetail = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        String queryPIQD = XC_UTIL_Sobject.selectAllFieldsGetSelect('gii__ProductInventoryQuantityDetail__c') + ' , gii__ProductSerial__r.giic_StatusCode__c, gii__ProductSerial__r.gii__TransferOrderId__r.gii__TransferToWarehouse__c, gii__ProductInventory__r.gii__Warehouse__c FROM gii__ProductInventoryQuantityDetail__c ';
        List<gii__ProductInventoryQuantityDetail__c> listPiqdForMap = Database.query(queryPIQD);
        for(gii__ProductInventoryQuantityDetail__c singlePIQD : listPiqdForMap) {
            if(!mapResultsQuantityDetail.containsKey(singlePIQD.gii__ProductInventory__c)) {
                mapResultsQuantityDetail.put(singlePIQD.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>());
            }
            mapResultsQuantityDetail.get(singlePIQD.gii__ProductInventory__c).add(singlePIQD);
        }
        giic_BA014_InventoryMaintenance.getMapQuantityDetailSerialProduct(listPi);                               
        giic_BA014_InventoryMaintenance.checkAfterMaintenanceSerialProduct(mapPiWithNewValues, mapNewCalculatedQuantity, mapPiWithNewValues, new List<String>{'TestClass'}, false, new Set<String>{'Test'}, Database.setSavepoint());
        giic_BA014_InventoryMaintenance.coverageClass();
        Test.stopTest();
    }
}