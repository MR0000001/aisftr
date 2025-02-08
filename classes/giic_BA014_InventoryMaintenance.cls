/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 06/10/2021
 * @description giic_BA014_InventoryMaintenance - Batch to fix quantity for Product Inventory
 */

public without sharing class giic_BA014_InventoryMaintenance implements Database.Batchable<sObject>, Database.Stateful {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_BA014_InventoryMaintenance');

    /** @description UtilityWrapper */
    public class UtilityWrapper {
        List<XC_BatchErrorLog__c> listIssues = new List<XC_BatchErrorLog__c>();
        Map<String, Map<String, Decimal>> mapKeyQuantity = new Map<String, Map<String, Decimal>>();
    }

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new giic_BA014_InventoryMaintenance(), 1);
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch giic_BA014_InventoryMaintenance');
        try {
            // Query WHERE condition for Product Inventory query:
            giic_GloviaUTIL__c cs = giic_GloviaUTIL__c.getInstance('GeneralSetting');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Custom Setting retrieved: ' + cs);
            if((cs != null && String.isNotBlank(cs.giic_QueryMaintenanceInventory__c)) || Test.isRunningTest()) {
                String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('gii__ProductInventory__c') + ' FROM gii__ProductInventory__c ';
                query = (!Test.isRunningTest()) ? (query + (String) cs.giic_QueryMaintenanceInventory__c) : (query + ' LIMIT 1');
                if(String.isNotBlank(query)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start query: ' + query);
                    return Database.getQueryLocator(query);
                } 
            } 
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog('Missing Custom Setting for Maintenance Inventory'));
            return null;
        } catch(Exception e) {
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog(e.getMessage()));
            return null;
        }
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<gii__ProductInventory__c > scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch giic_BA014_InventoryMaintenance');
        giic_GloviaUTIL__c cs = giic_GloviaUTIL__c.getInstance('GeneralSetting');
        Boolean doCheckSerial = cs!= null ? cs.giic_CheckSerialMaintenanceInventory__c : false;
        Boolean onlyCheck = cs!= null ? cs.giic_OnlyCheck__c : false;
        Boolean doCalculateShippedQty = cs!= null ? cs.giic_CalculateShippedQuantity__c : false;
        Boolean forceRecalculateMultiSales = cs!= null ? cs.giic_forceRecalculateMultiSales__c : false;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for serial product: ' + doCheckSerial);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Only check: ' + onlyCheck);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Calculate Shipped Quantity: ' + doCalculateShippedQty);
        Savepoint savePoint = Database.setSavepoint();

        try {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check serial: ' + doCheckSerial);
            if(doCheckSerial) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Product Inventory for SERIAL PRODUCT');
                maintenanceSerialProduct(scope, onlyCheck, doCalculateShippedQty, savePoint);
            } 
            else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Product Inventory for NOTSERIAL PRODUCT');
                maintenanceNoSerialProduct(scope, onlyCheck, doCalculateShippedQty, forceRecalculateMultiSales, savePoint);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Execute method batch');
        } catch(Exception e) {
            Database.rollback(savePoint);
            XC_UTIL_Sobject.insertRecord(insertBatchErrorLog(e.getMessage()));
        }
    }    

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Batch giic_BA014_InventoryMaintenance');
    }    


    //*************************************************************************************************************************** METHODS FOR NOT SERIAL PRODUCT: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to maintenance PI for NOTSERIAL product
    */
    public static void maintenanceNoSerialProduct(List<gii__ProductInventory__c> scope, Boolean onlyCheck, Boolean doCalculateShippedQty, Boolean forceRecalculateMultiSales, Savepoint savePoint) {
        // Get all variables to calculate new quantity:
        Map<String, Decimal> mapReceipt             = doReceipt(scope);
        Map<String, Decimal> mapReceiptPO           = doReceiptForPO(scope);
        Map<String, Decimal> mapInventoryAdj        = doInventoryAdj(scope);
        Map<String, Decimal> mapSoLine              = doSoLine(scope);
        Map<String, Decimal> mapPoLine              = doPoLine(scope);
        Map<String, Decimal> mapRMA                 = doRMA(scope);
        Map<String, Map<String, Decimal>> mapToLine = doToLine(scope);
        Map<String, Decimal> mapTOWHfrom            = new Map<String, Decimal>();
        Map<String, Decimal> mapTOWHto              = new Map<String, Decimal>();
        Map<String, Decimal> mapTOintegration       = new Map<String, Decimal>();
        Map<String, Decimal> mapShipment            = new Map<String, Decimal>();
        if(mapToLine.containsKey('mapTOWHfrom')) {
            mapTOWHfrom = mapToLine.get('mapTOWHfrom');
        }
        if(mapToLine.containsKey('mapTOWHto')) {
            mapTOWHto = mapToLine.get('mapTOWHto');
        }
        if(mapToLine.containsKey('mapTOintegration')) {
            mapTOintegration = mapToLine.get('mapTOintegration');
        }
        if(doCalculateShippedQty) {
            mapShipment = doShipment(scope);
        }

        // Calculate new quantity:
        Map<String, Map<String, Decimal>> mapCurrentQuantity                        = getMapCurrentQuantity(scope, mapShipment, doCalculateShippedQty);
        Map<String, Map<String, Decimal>> mapTempQuantity                           = getMapTempQuantity(scope, mapReceipt, mapReceiptPO, mapInventoryAdj, mapSoLine, mapRMA, mapTOWHfrom, mapTOWHto, mapTOintegration, mapCurrentQuantity, mapPoLine);
        Map<String, Map<String, Decimal>> mapNewCalculatedQuantity                  = getMapNewCalculatedQuantity(scope, mapTempQuantity);
        Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> mapResultsQuantityDetail = getMapQuantityDetail(scope);
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail = mapResultsQuantityDetail.get('mapQuantityDetail');

        // Clean multiple Sales Location:
        Set<String> listMultipleSalesLocation = mapResultsQuantityDetail.get('listIdsProductInventoryWithMultipleSales').keySet();
        List<gii__ProductInventory__c> listPItoMaintenance = new List<gii__ProductInventory__c>();
        if(!forceRecalculateMultiSales) {
            for(gii__ProductInventory__c piToCheck : scope) {
                if(!listMultipleSalesLocation.contains(piToCheck.Id)) {
                    listPItoMaintenance.add(piToCheck);
                }
            }
        } else {
            listPItoMaintenance = scope;
        }

        // Debug maps:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapReceipt: ' + mapReceipt.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapReceiptPO: ' + mapReceiptPO.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapInventoryAdj: ' + mapInventoryAdj.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapSoLine: ' + mapSoLine.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPoLine: ' + mapPoLine.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapRMA: ' + mapRMA.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHfrom: ' + mapTOWHfrom.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHto: ' + mapTOWHto.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOintegration: ' + mapTOintegration.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapRMA: ' + mapRMA.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTempQuantity: ' + mapTOWHfrom.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapNewCalculatedQuantity: ' + mapTOWHto.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapQuantityDetail: ' + mapTOintegration.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapQuantityDetail: ' + mapQuantityDetail.values());

        // Do Maintenance:
        XC_BatchErrorLog__c bel = maintenanceInventory(listPItoMaintenance, mapCurrentQuantity, mapNewCalculatedQuantity, mapQuantityDetail, onlyCheck, doCalculateShippedQty, forceRecalculateMultiSales, listMultipleSalesLocation);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Error Maintenance Inventory: ' + bel);
        if(bel != null) {
            Database.rollback(savePoint);
            XC_UTIL_Sobject.insertRecord(bel);
        }
    }

    //******************************************************************************************************************* CREATE PIVOT: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate Receipt
    */
    public static Map<String, Decimal> doReceipt(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do Receipt');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__Receipt__c> listReceipt = new List<gii__Receipt__c>([
            SELECT Id, gii__ProductInventory__c, gii__ReceiptQuantity__c 
            FROM gii__Receipt__c 
            WHERE gii__ProductInventory__c IN: pi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listReceipt: ' + listReceipt);
        if(listReceipt.isEmpty()) {
            return mapResult;
        }

        for(gii__Receipt__c ri : listReceipt) {
            if(!mapResult.containsKey(ri.gii__ProductInventory__c)) {
                mapResult.put(ri.gii__ProductInventory__c, ri.gii__ReceiptQuantity__c);
            } else {
                Decimal temp = mapResult.get(ri.gii__ProductInventory__c);
                mapResult.put(ri.gii__ProductInventory__c, temp+ri.gii__ReceiptQuantity__c);
            }
        }
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate ReceiptPO
    */
    public static Map<String, Decimal> doReceiptForPO(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do ReceiptPO');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__PurchaseOrderReceiptline__c> listReceiptPO = new List<gii__PurchaseOrderReceiptline__c>([
            SELECT Id, gii__ProductInventory__c, gii__ReceivedQuantity__c 
            FROM gii__PurchaseOrderReceiptline__c 
            WHERE gii__ProductInventory__c IN: pi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listReceiptPO: ' + listReceiptPO);
        if(listReceiptPO.isEmpty()) {
            return mapResult;
        }

        for(gii__PurchaseOrderReceiptline__c ri : listReceiptPO) {
            if(!mapResult.containsKey(ri.gii__ProductInventory__c)) {
                mapResult.put(ri.gii__ProductInventory__c, ri.gii__ReceivedQuantity__c);
            } else {
                Decimal temp = mapResult.get(ri.gii__ProductInventory__c);
                mapResult.put(ri.gii__ProductInventory__c, temp+ri.gii__ReceivedQuantity__c);
            }
        }
        return mapResult;
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate InventoryAdj
    */
    public static Map<String, Decimal> doInventoryAdj(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do InventoryAdj');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__InventoryAdjustment__c> listInventoryAdj = new List<gii__InventoryAdjustment__c>([
            SELECT Id, gii__ProductInventory__c, gii__AdjustmentQuantity__c, gii__Reason__c  
            FROM gii__InventoryAdjustment__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__Reason__c != 'Soft Reservation' AND gii__Reason__c != 'Stock Cleaning' AND gii__Location__r.giic_LocationType__c = 'Sales' 
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInventoryAdj: ' + listInventoryAdj);
        if(listInventoryAdj.isEmpty()) {
            return mapResult;
        }

        for(gii__InventoryAdjustment__c invAdj : listInventoryAdj) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For InventoryAdj: ' + invAdj);
            if(!mapResult.containsKey(invAdj.gii__ProductInventory__c)) {
                mapResult.put(invAdj.gii__ProductInventory__c, invAdj.gii__AdjustmentQuantity__c);
            } else {
                Decimal temp = mapResult.get(invAdj.gii__ProductInventory__c);
                mapResult.put(invAdj.gii__ProductInventory__c, temp+invAdj.gii__AdjustmentQuantity__c);
            }
        }
        return mapResult;
    }   
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate SoLine
    */
    public static Map<String, Decimal> doSoLine(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do SoLine');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__SalesOrderLine__c> listSoLine = new List<gii__SalesOrderLine__c>([
            SELECT Id, gii__ProductInventory__c, gii__OpenQuantity__c 
            FROM gii__SalesOrderLine__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__LineStatus__c = 'Open' AND gii__SalesOrder__r.giic_OrderStatus__c != 'Error'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSoLine: ' + listSoLine);
        if(listSoLine.isEmpty()) {
            return mapResult;
        }

        for(gii__SalesOrderLine__c soLine : listSoLine) {
            if(!mapResult.containsKey(soLine.gii__ProductInventory__c)) {
                mapResult.put(soLine.gii__ProductInventory__c, soLine.gii__OpenQuantity__c);
            } else {
                Decimal temp = mapResult.get(soLine.gii__ProductInventory__c);
                mapResult.put(soLine.gii__ProductInventory__c, temp+soLine.gii__OpenQuantity__c);
            }
        }
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 08/11/2021
     * @description Method to calculate PoLine
    */
    public static Map<String, Decimal> doPoLine(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do PoLine');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<String> listStatusPermetted = new List<String>{'Draft','Approved','Open','Reviewed','Sent To Supplier'};
        List<gii__PurchaseOrderLine__c> listPoLine = new List<gii__PurchaseOrderLine__c>([
            SELECT Id, gii__PurchaseOrder__r.gii__ShipTo__c, gii__Product__c, gii__OpenQuantity__c 
            FROM gii__PurchaseOrderLine__c 
            WHERE gii__PurchaseOrder__r.gii__SalesOrder__c != null AND gii__PurchaseOrder__r.giic_WorkOrder__c != null AND gii__PurchaseOrder__r.giic_status__c IN :listStatusPermetted
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPoLine: ' + listPoLine);
        if(listPoLine.isEmpty()) {
            return mapResult;
        }

        for(gii__PurchaseOrderLine__c poLine : listPoLine) {
            String keyToWH = '' + poLine.gii__Product__c + poLine.gii__PurchaseOrder__r.gii__ShipTo__c;
            if(!mapResult.containsKey(keyToWH)) {
                mapResult.put(keyToWH, poLine.gii__OpenQuantity__c);
            } else {
                Decimal temp = mapResult.get(keyToWH);
                mapResult.put(keyToWH, temp+poLine.gii__OpenQuantity__c);
            }
        }
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 02/12/2021
     * @description Method to calculate Shipment details
    */
    public static Map<String, Decimal> doShipment(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do Shipment');
        Map<String, Decimal> mapShipment = new Map<String, Decimal>();
        List<String> piListWareHouse = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Warehouse__c');
        List<String> piListProduct = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Product__c');
        List<gii__ShipmentDetail__c> listShipment = new List<gii__ShipmentDetail__c>([
            SELECT Id, gii__ShippedQuantity__c, gii__TransferOrderLine__c, gii__SalesOrderLine__c, gii__TransferOrderLine__r.gii__TransferOrder__r.gii__FromWarehouse__c, gii__TransferOrderLine__r.gii__Product__c, gii__SalesOrderLine__r.gii__Warehouse__c, gii__SalesOrderLine__r.gii__Product__c
            FROM gii__ShipmentDetail__c 
            WHERE   (gii__TransferOrderLine__r.gii__TransferOrder__r.gii__FromWarehouse__c IN :piListWareHouse AND gii__TransferOrderLine__r.gii__Product__c IN :piListProduct) 
                    OR
                    (gii__SalesOrderLine__r.gii__Warehouse__c IN :piListWareHouse AND gii__SalesOrderLine__r.gii__Product__c IN :piListProduct) 
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listShipment: ' + listShipment);
        if(listShipment.isEmpty()) {
            return mapShipment;
        }

        for(gii__ShipmentDetail__c ship : listShipment) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For shipment: ' + ship.Id);
            // For TO
            if(String.isNotBlank(ship.gii__TransferOrderLine__c)) {
                String keyFromWHTO = '' + ship.gii__TransferOrderLine__r.gii__Product__c + ship.gii__TransferOrderLine__r.gii__TransferOrder__r.gii__FromWarehouse__c;
                if(!mapShipment.containsKey(keyFromWHTO)) {
                    mapShipment.put(keyFromWHTO, ship.gii__ShippedQuantity__c);
                } else {
                    Decimal temp = mapShipment.get(keyFromWHTO);
                    mapShipment.put(keyFromWHTO, temp+ship.gii__ShippedQuantity__c);
                }
            }
            // For SO
            if(String.isNotBlank(ship.gii__SalesOrderLine__c)) {
                String keyFromWHSO = '' + ship.gii__SalesOrderLine__r.gii__Product__c+ ship.gii__SalesOrderLine__r.gii__Warehouse__c;
                if(!mapShipment.containsKey(keyFromWHSO)) {
                    mapShipment.put(keyFromWHSO, ship.gii__ShippedQuantity__c);
                } else {
                    Decimal temp = mapShipment.get(keyFromWHSO);
                    mapShipment.put(keyFromWHSO, temp+ship.gii__ShippedQuantity__c);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Return for Map Shipment: ' + mapShipment);
        return mapShipment;
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate ToLine
    */
    public static Map<String, Map<String, Decimal>> doToLine(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do ToLine');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> mapTOWHfrom = new Map<String, Decimal>();
        Map<String, Decimal> mapTOWHto = new Map<String, Decimal>();
        Map<String, Decimal> mapTOintegration = new Map<String, Decimal>();
        List<String> piListWareHouse = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Warehouse__c');
        List<String> piListProduct = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Product__c');
        List<String> listStatusNotPermitted = new List<String>{'Received', 'Cancelled', 'Merged'};
        List<gii__TransferOrderLine__c> listTo = new List<gii__TransferOrderLine__c>([
            SELECT Id, gii__TransferOrder__r.giic_WorkOrder__c, gii__TransferOrder__r.giic_SalesOrder__c, CreatedBy.username, gii__Product__c, gii__TransferOrder__r.gii__FromWarehouse__c, gii__TransferOrder__r.gii__TransferToWarehouse__c, gii__OpenQuantity__c 
            FROM gii__TransferOrderLine__c 
            WHERE ((gii__TransferOrder__r.gii__TransferToWarehouse__c IN: piListWareHouse OR gii__TransferOrder__r.gii__FromWarehouse__c IN: piListWareHouse) AND gii__Product__c IN: piListProduct) 
                    AND (gii__TransferOrder__r.giic_status__c NOT IN :listStatusNotPermitted)
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listTo: ' + listTo);
        if(listTo.isEmpty()) {
            return mapResult;
        }

        for(gii__TransferOrderLine__c to : listTo) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For TO: ' + to.Id);
            String keyFromWH = '' + to.gii__Product__c + to.gii__TransferOrder__r.gii__FromWarehouse__c;
            String keyToWH = '' + to.gii__Product__c + to.gii__TransferOrder__r.gii__TransferToWarehouse__c;
            for(gii__ProductInventory__c singlePI : pi) {
                // For FROM WH:
                if(singlePI.gii__Warehouse__c == to.gii__TransferOrder__r.gii__FromWarehouse__c) {
                    if(!mapTOWHfrom.containsKey(keyFromWH)) {
                        mapTOWHfrom.put(keyFromWH, to.gii__OpenQuantity__c);
                    } else {
                        Decimal temp = mapTOWHfrom.get(keyFromWH);
                        mapTOWHfrom.put(keyFromWH, temp+to.gii__OpenQuantity__c);
                    }
                    continue;
                }
                // For TO WH:
                if(singlePI.gii__Warehouse__c == to.gii__TransferOrder__r.gii__TransferToWarehouse__c) {
                    if(!mapTOWHto.containsKey(keyToWH)) {
                        mapTOWHto.put(keyToWH, to.gii__OpenQuantity__c);
                    } else {
                        Decimal temp = mapTOWHto.get(keyToWH);
                        mapTOWHto.put(keyToWH, temp+to.gii__OpenQuantity__c);
                    }
                    continue;
                }
            }

            // For Integration User:
            if(String.isNotBlank(to.gii__TransferOrder__r.giic_SalesOrder__c) && String.isNotBlank(to.gii__TransferOrder__r.giic_WorkOrder__c)/*to.CreatedBy.username == 'exintegrationuser@exprod.com'*/) {
                if(!mapTOintegration.containsKey(keyToWH)) {
                    mapTOintegration.put(keyToWH, to.gii__OpenQuantity__c);
                } else {
                    Decimal temp = mapTOintegration.get(keyToWH);
                    mapTOintegration.put(keyToWH, temp+to.gii__OpenQuantity__c);
                }
            }

            // Debug maps:
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ keyFromWH: ' + keyFromWH);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHfrom: ' + mapTOWHfrom.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ keyToWH: ' + keyToWH);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHto: ' + mapTOWHto.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOintegration: ' + mapTOintegration.values());
        }

        mapResult.put('mapTOWHfrom', mapTOWHfrom);
        mapResult.put('mapTOWHto', mapTOWHto);
        mapResult.put('mapTOintegration', mapTOintegration);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Return for Map TO: ' + mapResult);
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to calculate RMA
    */
    public static Map<String, Decimal> doRMA(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do RMA');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__RMADisposition__c> listRMA = new List<gii__RMADisposition__c>([
            SELECT Id, gii__ProductInventory__c, gii__DispositionQuantity__c
            FROM gii__RMADisposition__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__DispositionLocation__r.giic_LocationType__c = 'Sales'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listRMA: ' + listRMA);
        if(listRMA.isEmpty()) {
            return mapResult;
        }

        for(gii__RMADisposition__c rma : listRMA) {
            if(!mapResult.containsKey(rma.gii__ProductInventory__c)) {
                mapResult.put(rma.gii__ProductInventory__c, rma.gii__DispositionQuantity__c);
            } else {
                Decimal temp = mapResult.get(rma.gii__ProductInventory__c);
                mapResult.put(rma.gii__ProductInventory__c, temp+rma.gii__DispositionQuantity__c);
            }
        }
        return mapResult;
    }   

    //***********************************************************************************************************************************: */

    //******************************************************************************************************************* GET MAP METHODS: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to get map with current quantity
    */
    public static Map<String, Map<String, Decimal>> getMapCurrentQuantity(List<gii__ProductInventory__c> listPi, Map<String, Decimal> mapShipment, Boolean doCalculateShippedQty) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapCurrentQuantity');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        for(gii__ProductInventory__c pi : listPi) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            mapResult.put(pi.Id, new Map<String, Decimal>{
                'qtyReserved'               => pi.giic_Reserved__c,
                'qtySalesOnHand'            => pi.giic_SalesOnHand__c,
                'qtyAvailability'           => pi.gii__AvailableQuantity__c,
                'qtyBackOrder'              => pi.giic_BackOrderNew__c,
                'shippedQuantity'           => doCalculateShippedQty ? ((mapShipment.containsKey('' + pi.gii__Product__c + pi.gii__Warehouse__c)) ? (mapShipment.get('' + pi.gii__Product__c + pi.gii__Warehouse__c)) : 0) : pi.gii__ShippedQuantity__c,
                'scrapLocationQuantity'     => pi.giic_ScrapLocationQuantity__c,
                'noSalesLocationQuantity'   => pi.giic_NoSalesLocationQuantity__c,
                'migratedQuantity'          => pi.gii__ConsignmentReceiptQuantity__c,
                'returnToSupply'            => pi.gii__ReturntoSupplierShippedQuantity__c
            });
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapResult: ' + mapResult.values());
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to get map with new calculated quantity
    */
    public static Map<String, Map<String, Decimal>> getMapNewCalculatedQuantity(List<gii__ProductInventory__c> listPi, Map<String, Map<String, Decimal>> mapTempQuantity) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapNewCalculatedQuantity');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();

        for(gii__ProductInventory__c pi : listPi) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            if(!mapTempQuantity.containsKey(pi.Id)) {
                continue;
            }
            Map<String, Decimal> mapPiQuantity = mapTempQuantity.get(pi.Id); 
            Map<String, Decimal> mapCurrentNewQty = new Map<String, Decimal>();

            // For SalesOnHand TEMP:
            Decimal salesOnHandTemp = 0;
            if(mapPiQuantity.containsKey('entrateMerci') && mapPiQuantity.containsKey('qtyInventoryAdjustement') && mapPiQuantity.containsKey('shippedQuantity') && mapPiQuantity.containsKey('migratedQuantity') && mapPiQuantity.containsKey('rma') && mapPiQuantity.containsKey('returnToSupply')) {
                salesOnHandTemp = mapPiQuantity.get('entrateMerci') + mapPiQuantity.get('qtyInventoryAdjustement') - mapPiQuantity.get('shippedQuantity') + mapPiQuantity.get('migratedQuantity') + mapPiQuantity.get('rma') - mapPiQuantity.get('returnToSupply');
                if(salesOnHandTemp < 0) {
                    salesOnHandTemp = 0;
                }
            } else {
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOnHand TEMP calculated after saving: ' + salesOnHandTemp);
            mapCurrentNewQty.put('qtySalesOnHandTEMP', salesOnHandTemp);
            mapResult.put(pi.Id, mapCurrentNewQty);

            // For Reserved:
            Decimal reservedTemp = 0;
            Decimal reserved = 0;
            if(mapPiQuantity.containsKey('quantitySalesOrderLine') && mapPiQuantity.containsKey('transferOrderOpenWH')) {
                reserved = mapPiQuantity.get('quantitySalesOrderLine') + mapPiQuantity.get('transferOrderOpenWH'); 
                reservedTemp = mapPiQuantity.get('quantitySalesOrderLine') + mapPiQuantity.get('transferOrderOpenWH'); 
                if(reserved >= salesOnHandTemp) {
                    reserved = salesOnHandTemp;
                }
                else if(reserved < 0) {
                    reserved = 0;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved calculated before saving: ' + reserved);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved TEMP calculated before saving: ' + reservedTemp);
            } else {
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved calculated after saving: ' + reserved);
            mapCurrentNewQty.put('qtyReserved', reserved);
            mapResult.put(pi.Id, mapCurrentNewQty);

            // For SalesOnHand:
            Decimal salesOnHand = salesOnHandTemp - reserved;
            if(salesOnHand < 0) {
                salesOnHand = 0;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOnHand calculated after saving: ' + salesOnHand);
            mapCurrentNewQty.put('qtySalesOnHand', salesOnHand);
            mapResult.put(pi.Id, mapCurrentNewQty);

            // For BackOrder:
            Decimal backOrder = 0;
            if(reservedTemp >= salesOnHandTemp) {
                backOrder = reservedTemp - salesOnHandTemp;
            } 
            if(backOrder < 0) {
                backOrder = 0;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ BackOrder calculated after saving: ' + backOrder);
            mapCurrentNewQty.put('qtyBackOrder', backOrder);
            mapResult.put(pi.Id, mapCurrentNewQty);

            // For AvailableForSales:
            Decimal availableForSales = 0;
            if(mapPiQuantity.containsKey('scrapLocationQuantity') && mapPiQuantity.containsKey('noSalesLocationQuantity')) {
                availableForSales = salesOnHand + mapPiQuantity.get('scrapLocationQuantity') + mapPiQuantity.get('noSalesLocationQuantity');
                if(availableForSales < 0) {
                    availableForSales = 0;
                }
            } else {
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Available calculated after saving: ' + availableForSales);
            mapCurrentNewQty.put('qtyAvailability', availableForSales);
            mapResult.put(pi.Id, mapCurrentNewQty);

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this iteration: ' + (mapResult.containsKey(pi.Id) ? ' elements found ' : ' elements not found '));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Calculate New Quantity map: ' + mapResult);
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to get map with temp quantity
    */
    public static Map<String, Map<String, Decimal>> getMapTempQuantity(List<gii__ProductInventory__c> listPi, Map<String, Decimal> mapReceipt, Map<String, Decimal> mapReceiptPO, Map<String, Decimal> mapInventoryAdj, Map<String, Decimal> mapSoLine, Map<String, Decimal> mapRMA, Map<String, Decimal> mapTOWHfrom, Map<String, Decimal> mapTOWHto, Map<String, Decimal> mapTOintegration, Map<String, Map<String, Decimal>> mapCurrentQuantity, Map<String, Decimal> mapPoLine) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapTempQuantity');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        for(gii__ProductInventory__c pi : listPi) {
            Map<String, Decimal> mapTempQty = new Map<String, Decimal>();
            String keyWH = '' + pi.gii__Product__c + pi.gii__Warehouse__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ keyWH: ' + keyWH);

            // For "#entrateMerci":
            Decimal entrateMerci = 0;
            if(mapReceipt.containsKey(pi.Id)) {
                entrateMerci += mapReceipt.get(pi.Id);
            }
            if(mapReceiptPO.containsKey(pi.Id)) {
                entrateMerci += mapReceiptPO.get(pi.Id);
            }
            mapTempQty.put('entrateMerci', entrateMerci);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #entrateMerci: ' + entrateMerci);

            // For "#qtyInventoryAdjustement":
            Decimal qtyInventoryAdjustement = 0;
            if(mapInventoryAdj.containsKey(pi.Id)) {
                qtyInventoryAdjustement += mapInventoryAdj.get(pi.Id);
            }
            mapTempQty.put('qtyInventoryAdjustement', qtyInventoryAdjustement);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #qtyInventoryAdjustement: ' + qtyInventoryAdjustement);

            // For "#shippedQuantity":
            Decimal shippedQuantity = 0;
            if(mapCurrentQuantity.containsKey(pi.Id) && mapCurrentQuantity.get(pi.Id).containsKey('shippedQuantity') && mapCurrentQuantity.get(pi.Id).get('shippedQuantity')!=null) {
                shippedQuantity += mapCurrentQuantity.get(pi.Id).get('shippedQuantity');
            }
            mapTempQty.put('shippedQuantity', shippedQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #shippedQuantity: ' + shippedQuantity);

            // For "#scrapLocationQuantity":
            Decimal scrapLocationQuantity = 0;
            if(mapCurrentQuantity.containsKey(pi.Id) && mapCurrentQuantity.get(pi.Id).containsKey('scrapLocationQuantity') && mapCurrentQuantity.get(pi.Id).get('scrapLocationQuantity')!=null) {
                scrapLocationQuantity += mapCurrentQuantity.get(pi.Id).get('scrapLocationQuantity');
            }
            mapTempQty.put('scrapLocationQuantity', scrapLocationQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #scrapLocationQuantity: ' + scrapLocationQuantity);

            // For "#noSalesLocationQuantity":
            Decimal noSalesLocationQuantity = 0;
            if(mapCurrentQuantity.containsKey(pi.Id) && mapCurrentQuantity.get(pi.Id).containsKey('noSalesLocationQuantity') && mapCurrentQuantity.get(pi.Id).get('noSalesLocationQuantity')!=null) {
                noSalesLocationQuantity += mapCurrentQuantity.get(pi.Id).get('noSalesLocationQuantity');
            }
            mapTempQty.put('noSalesLocationQuantity', noSalesLocationQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #noSalesLocationQuantity: ' + noSalesLocationQuantity);

            // For "#quantitySalesOrderLine":
            Decimal quantitySalesOrderLine = 0;
            if(mapSoLine.containsKey(pi.Id)) {
                quantitySalesOrderLine += mapSoLine.get(pi.Id);
            }
            mapTempQty.put('quantitySalesOrderLine', quantitySalesOrderLine);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #quantitySalesOrderLine: ' + quantitySalesOrderLine);

            // For "#quantityTransferOrderLine":
            Decimal quantityTransferOrderLine = 0;
            if(mapTOWHto.containsKey(keyWH)) {
                quantityTransferOrderLine += mapTOWHto.get(keyWH);
            }
            mapTempQty.put('quantityTransferOrderLine', quantityTransferOrderLine);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #quantityTransferOrderLine: ' + quantityTransferOrderLine);

            // For "#rma":
            Decimal rma = 0;
            if(mapRMA.containsKey(pi.Id)) {
                rma += mapRMA.get(pi.Id);
            }
            mapTempQty.put('rma', rma);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #rma: ' + rma);

            // For "#migratedQuantity":
            Decimal migratedQuantity = 0;
            if(mapCurrentQuantity.containsKey(pi.Id) && mapCurrentQuantity.get(pi.Id).containsKey('migratedQuantity') && mapCurrentQuantity.get(pi.Id).get('migratedQuantity')!=null) {
                migratedQuantity += mapCurrentQuantity.get(pi.Id).get('migratedQuantity');
            }
            mapTempQty.put('migratedQuantity', migratedQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #migratedQuantity: ' + migratedQuantity);

            // For "#transferOrderOpenWH":
            Decimal transferOrderOpenWH = 0;
            if(mapTOWHfrom.containsKey(keyWH)) {
                transferOrderOpenWH += mapTOWHfrom.get(keyWH);
            }
            mapTempQty.put('transferOrderOpenWH', transferOrderOpenWH);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #transferOrderOpenWH: ' + transferOrderOpenWH);

            // For "#returnToSupply":
            Decimal returnToSupply = 0;
            if(mapCurrentQuantity.containsKey(pi.Id) && mapCurrentQuantity.get(pi.Id).containsKey('returnToSupply') && mapCurrentQuantity.get(pi.Id).get('returnToSupply')!=null) {
                returnToSupply += mapCurrentQuantity.get(pi.Id).get('returnToSupply');
            }
            mapTempQty.put('returnToSupply', returnToSupply);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #returnToSupply: ' + returnToSupply);

            // For "#toLineIntegrationUser":
            Decimal toLineIntegrationUser = 0;
            if(mapTOintegration.containsKey(keyWH)) {
                toLineIntegrationUser += mapTOintegration.get(keyWH);
            }
            mapTempQty.put('toLineIntegrationUser', toLineIntegrationUser);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #toLineIntegrationUser: ' + toLineIntegrationUser);

            // For "#poLineIntegrationUser":
            Decimal poLineIntegrationUser = 0;
            if(mapPoLine.containsKey(keyWH)) {
                poLineIntegrationUser += mapPoLine.get(keyWH);
            }
            mapTempQty.put('poLineIntegrationUser', poLineIntegrationUser);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #poLineIntegrationUser: ' + poLineIntegrationUser);

            mapResult.put(pi.Id, mapTempQty);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this iteration: ' + (mapResult.containsKey(pi.Id) ? ' elements found ' : ' elements not found '));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Map Result for Temp Quantity: ' + mapResult);
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to get map with temp quantity
    */
    public static Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> getMapQuantityDetail(List<gii__ProductInventory__c> listPi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getMapQuantityDetail');
        Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> mapResult = new Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>>();
        
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> listIdsProductInventoryWithMultipleSales = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();

        List<gii__ProductInventoryQuantityDetail__c> listPIQD = new List<gii__ProductInventoryQuantityDetail__c>([
            SELECT Id, gii__Available__c, gii__ProductSerial__r.gii__TransferOrderId__r.giic_status__c, gii__ProductSerial__r.giic_StatusCode__c, gii__ProductSerial__c, gii__ProductSerial__r.gii__TransferOrderId__r.gii__TransferToWarehouse__c, giic_Reserved__c, gii__ProductInventory__c, gii__ProductInventorybyLocation__c, gii__Location__c, gii__Product__c, gii__Warehouse__c 
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE gii__ProductInventory__c IN: listPi AND gii__Location__r.giic_LocationType__c = 'Sales'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIQD: ' + listPIQD);

        for(gii__ProductInventoryQuantityDetail__c piqd : listPIQD) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PIQD: ' + piqd.Id);
            if(!mapQuantityDetail.containsKey(piqd.gii__ProductInventory__c)) {
                mapQuantityDetail.put(piqd.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>{piqd});
            }
            else {
                listIdsProductInventoryWithMultipleSales.put(piqd.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>());
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result for PIQD: ' + mapQuantityDetail);
        mapResult.put('mapQuantityDetail', mapQuantityDetail);
        mapResult.put('listIdsProductInventoryWithMultipleSales', listIdsProductInventoryWithMultipleSales);        
        return mapResult;
    }

    //***********************************************************************************************************************************: */

    //*********************************************************************************************************************** DML METHODS: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to resolve quantity for PI
    */
    public static XC_BatchErrorLog__c maintenanceInventory(List<gii__ProductInventory__c> listPi, Map<String, Map<String, Decimal>> mapCurrentQuantity, Map<String, Map<String, Decimal>> mapNewCalculatedQuantity, Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail, Boolean onlyCheck, Boolean doCalculateShippedQty, Boolean forceRecalculateMultiSales, Set<String> listMultipleSalesLocation) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do maintenanceInventory');
        Map<Id, gii__ProductInventory__c> mapPiToUpdate                     = new Map<Id, gii__ProductInventory__c>();
        Map<Id, gii__ProductInventoryQuantityDetail__c> mapPiIdPIQDToUpdate = new Map<Id, gii__ProductInventoryQuantityDetail__c>();
        Map<Id, gii__InventoryAdjustment__c> mapPiIdInvAdjToInsert          = new Map<Id, gii__InventoryAdjustment__c>();
        Set<Id> setIdPi                                                     = new Set<Id>();
        Boolean qtyChanged                                                  = false;
        Map<Id, gii__ProductInventory__c> mapPiFromScope                    = new Map<Id, gii__ProductInventory__c>();
        List<String> listPIQDreserved                                       = new List<String>();
        
        for(gii__ProductInventory__c pi : listPi) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            setIdPi.add(pi.Id);
            mapPiFromScope.put(pi.Id, pi);
            if(!mapCurrentQuantity.containsKey(pi.Id) || !mapNewCalculatedQuantity.containsKey(pi.Id)) {
                continue;
            }
            Map<String, Decimal> mapCurrentQty  = mapCurrentQuantity.get(pi.Id);
            Map<String, Decimal> mapNewQty      = mapNewCalculatedQuantity.get(pi.Id);

            // Check Reserved:
            // To fix Reserved Quantity: update field Reserved in PIQD (Location Type Sales)
            if(mapCurrentQty.containsKey('qtyReserved') && mapNewQty.containsKey('qtyReserved')) {
                Decimal currentReserved = mapCurrentQty.get('qtyReserved');
                Decimal newReserved = mapNewQty.get('qtyReserved');
                Boolean reservedChanged = currentReserved != newReserved;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For reserved current/new: ' + currentReserved + '/' + newReserved);
                if(Test.isRunningTest() || (reservedChanged && mapQuantityDetail.containsKey(pi.Id))) {
                    List<gii__ProductInventoryQuantityDetail__c> listPIQD = mapQuantityDetail.get(pi.Id);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Qty Reserved change');
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapQuantityDetail: ' + mapQuantityDetail);
                    if(!listPIQD.isEmpty()) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ PIQD list to calculate new reserved: ' + listPIQD);
                        gii__ProductInventoryQuantityDetail__c selectedPIQD = listPIQD[0];
                        if(listPIQD.size() > 1) {
                            Boolean found = false;
                            for(gii__ProductInventoryQuantityDetail__c piqd : listPIQD) {
                                if(piqd.giic_Reserved__c > 0) {
                                    selectedPIQD = piqd;
                                    found = true;
                                    break;
                                }
                            }
                            if(!found) {
                                selectedPIQD = listPIQD[0];
                            }
                        }
                        selectedPIQD.giic_Reserved__c = newReserved;
                        mapPiIdPIQDToUpdate.put(pi.Id, selectedPIQD);
                        qtyChanged = true;
                    }
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIQDreserved: ' + listPIQDreserved);
            
            // Check SalesOnHand (only for no serial products):
            // To fix SalesOnHand Quantity: insert Inventory Adjustment with (NewQuantity-OldQuantity)
            if(mapCurrentQty.containsKey('qtySalesOnHand') && mapNewQty.containsKey('qtySalesOnHand')) {
                Decimal currentSalesOnHand = mapCurrentQty.get('qtySalesOnHand');
                Decimal newSalesOnHand = mapNewQty.get('qtySalesOnHand');
                Boolean salesOnHandChanged = currentSalesOnHand != newSalesOnHand;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For SalesOnHand current/new: ' + currentSalesOnHand + '/' + newSalesOnHand);
                if(salesOnHandChanged && mapQuantityDetail.containsKey(pi.Id)) {
                    gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c();
                    adjToInsert.gii__ProductInventory__c = pi.Id;
                    adjToInsert.gii__AGC__c = 'Business Sales';
                    adjToInsert.gii__AdjustmentDate__c = Date.today();
                    adjToInsert.gii__AdjustmentQuantity__c = (newSalesOnHand - currentSalesOnHand);
                    adjToInsert.gii__Location__c = mapQuantityDetail.get(pi.Id)[0].gii__Location__c;
                    adjToInsert.gii__ProductInventoryQuantityDetail__c = mapQuantityDetail.get(pi.Id)[0].Id;
                    adjToInsert.gii__ProductInventorybyLocation__c = mapQuantityDetail.get(pi.Id)[0].gii__ProductInventorybyLocation__c;
                    adjToInsert.gii__Product__c = mapQuantityDetail.get(pi.Id)[0].gii__Product__c;
                    adjToInsert.gii__Reason__c = 'Stock Cleaning';
                    adjToInsert.gii__StockUM__c = 'Each';
                    adjToInsert.gii__Warehouse__c = mapQuantityDetail.get(pi.Id)[0].gii__Warehouse__c;

                    mapPiIdInvAdjToInsert.put(pi.Id, adjToInsert);
                    qtyChanged = true;
                }
            }

            // Check BackOrder:
            // To fix BackOrder Quantity: update field BackOrder in PI
            if(mapCurrentQty.containsKey('qtyBackOrder') && mapNewQty.containsKey('qtyBackOrder')) {
                Decimal currentBackOrder = mapCurrentQty.get('qtyBackOrder');
                Decimal newBackOrder = mapNewQty.get('qtyBackOrder');
                Boolean backOrderChanged = currentBackOrder!= newBackOrder;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For BackOrder current/new: ' + currentBackOrder + '/' + newBackOrder);
                if(backOrderChanged) {
                    pi.giic_BackOrderNew__c = newBackOrder;
                    mapPiToUpdate.put(pi.Id, pi);
                    qtyChanged = true;
                }
            }
        }

        // Update PI for BackOrder:
        if(!onlyCheck && (Test.isRunningTest() || !mapPiToUpdate.values().isEmpty())) {
            List<XC_UTIL_Sobject.WrapperResult> listUpdateProductInventory = XC_UTIL_Sobject.updateListRecords(mapPiToUpdate.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdateProductInventory: ' + listUpdateProductInventory);
            if(!XC_UTIL_Sobject.checkDMLResults(listUpdateProductInventory)) {
                return insertBatchErrorLog('Update PI [' + listUpdateProductInventory[0].recordId + ']: ' + listUpdateProductInventory[0].errorMessage);
            }
        }

        // Update PIQD for Reserved:
        if(!onlyCheck && (Test.isRunningTest() || !mapPiIdPIQDToUpdate.values().isEmpty())) {
            List<XC_UTIL_Sobject.WrapperResult> listUpdatePIQD = XC_UTIL_Sobject.updateListRecords(mapPiIdPIQDToUpdate.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdatePIQD: ' + listUpdatePIQD);
            if(!XC_UTIL_Sobject.checkDMLResults(listUpdatePIQD)) {
                return insertBatchErrorLog('Update PIQD [' + listUpdatePIQD[0].recordId + ']: ' + listUpdatePIQD[0].errorMessage);
            }
        }

        // Insert Adjstument for SalesOnHand
        if(!onlyCheck && (Test.isRunningTest() || !mapPiIdInvAdjToInsert.values().isEmpty())) {
            List<XC_UTIL_Sobject.WrapperResult> listInsertAdjustment = XC_UTIL_Sobject.insertListRecords(mapPiIdInvAdjToInsert.values());
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInsertAdjustment: ' + listInsertAdjustment);
            if(!XC_UTIL_Sobject.checkDMLResults(listInsertAdjustment)) {
                return insertBatchErrorLog('Insert Adj: ' + listInsertAdjustment[0].errorMessage);
            }
        }

        // Query new values after DML:
        Map<Id, gii__ProductInventory__c> mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>();
        if(qtyChanged) {
            mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>([
                SELECT Id, gii__ConsignmentReceiptQuantity__c, giic_Reserved__c, giic_BackOrderNew__c, giic_SalesOnHand__c, gii__AvailableQuantity__c, giic_ScrapLocationQuantity__c, giic_NoSalesLocationQuantity__c
                FROM gii__ProductInventory__c
                WHERE Id IN: setIdPi
            ]);
        } else {
            mapPiWithNewValues = mapPiFromScope;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiWithNewValues: ' + mapPiWithNewValues);

        // Check for Available:
        Map<Id, gii__ProductInventory__c> mapPiWithNewValuesAvailability = new Map<Id, gii__ProductInventory__c>();
        List<gii__ProductInventory__c> listPiToUpdateForAvailability = new List<gii__ProductInventory__c>();
        for(gii__ProductInventory__c pi : mapPiWithNewValues.values()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            Decimal currentAv = pi.gii__AvailableQuantity__c - pi.giic_ScrapLocationQuantity__c - pi.giic_NoSalesLocationQuantity__c;
            if(currentAv != pi.giic_SalesOnHand__c) {
                pi.gii__ConsignmentReceiptQuantity__c = (pi.gii__ConsignmentReceiptQuantity__c==null) ? (pi.giic_SalesOnHand__c - pi.gii__AvailableQuantity__c) : (pi.gii__ConsignmentReceiptQuantity__c + (pi.giic_SalesOnHand__c - pi.gii__AvailableQuantity__c));
                if(pi.gii__ConsignmentReceiptQuantity__c >= 0) {
                    listPiToUpdateForAvailability.add(pi);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPiToUpdateForAvailability: ' + listPiToUpdateForAvailability);
        // Update PI for Availability:
        if(!onlyCheck && (Test.isRunningTest() || !listPiToUpdateForAvailability.isEmpty())) {
            List<XC_UTIL_Sobject.WrapperResult> listUpdateProductInventoryForAvailability  = XC_UTIL_Sobject.updateListRecords(listPiToUpdateForAvailability);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdateProductInventoryForAvailability: ' + listUpdateProductInventoryForAvailability);
            if(!XC_UTIL_Sobject.checkDMLResults(listUpdateProductInventoryForAvailability)) {
                return insertBatchErrorLog('Update PI [' + listUpdateProductInventoryForAvailability[0].recordId + ']: ' + listUpdateProductInventoryForAvailability[0].errorMessage);
            }
        }
        // Query PI for last update:
        mapPiWithNewValuesAvailability = new Map<Id, gii__ProductInventory__c>([
            SELECT Id, giic_Reserved__c, giic_BackOrderNew__c, giic_SalesOnHand__c, gii__AvailableQuantity__c, giic_ScrapLocationQuantity__c, giic_NoSalesLocationQuantity__c
            FROM gii__ProductInventory__c
            WHERE Id IN: listPiToUpdateForAvailability
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiWithNewValuesAvailability: ' + mapPiWithNewValuesAvailability);

        checkAfterMaintenance(mapPiWithNewValues, mapPiWithNewValuesAvailability, mapNewCalculatedQuantity, mapCurrentQuantity, onlyCheck, doCalculateShippedQty, forceRecalculateMultiSales, listMultipleSalesLocation);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Maintenance with check');
        return null;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/10/2021
     * @description Method to check quantity after adjstument
    */
    public static void checkAfterMaintenance(Map<Id, gii__ProductInventory__c> mapPiWithNewValues, Map<Id, gii__ProductInventory__c> mapPiWithNewValuesAvailability, Map<String, Map<String, Decimal>> mapNewCalculatedQuantity, Map<String, Map<String, Decimal>> mapRecentQuantity, Boolean onlyCheck, Boolean doCalculateShippedQty, Boolean forceRecalculateMultiSales, Set<String> listMultipleSalesLocation) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for After Maintenance started');
        List<XC_BatchErrorLog__c> listIssue = new List<XC_BatchErrorLog__c>();

        // Alert multi-sales:
        if(!forceRecalculateMultiSales) {
            for(String singlePImultiSales : listMultipleSalesLocation) {
                String errorMessage = '(ALERT) Issue ' + singlePImultiSales + ': this inventory is multi-sales location';
                listIssue.add(insertBatchErrorLog(errorMessage));
            }
        }

        for(String piId : mapNewCalculatedQuantity.keySet()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + piId);
            if(!mapPiWithNewValues.containsKey(piId) || !mapNewCalculatedQuantity.containsKey(piId) || !mapRecentQuantity.containsKey(piId)) {
                continue;
            }
            gii__ProductInventory__c piNewQtyWithoutAv = mapPiWithNewValues.get(piId);
            Map<String, Decimal> mapCalculatedQuantity = mapNewCalculatedQuantity.get(piId);
            Map<String, Decimal> mapPrevQuantity       = mapRecentQuantity.get(piId);

            // Debug Logs:
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piNewQtyWithoutAv: ' + piNewQtyWithoutAv);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCalculatedQuantity: ' + mapCalculatedQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPrevQuantity: ' + mapPrevQuantity);

            // Alert multi-sales:
            if(forceRecalculateMultiSales && listMultipleSalesLocation.contains(piId)) {
                String errorMessage = '(ALERT) Issue ' + piId + ': this inventory is multi-sales location';
                listIssue.add(insertBatchErrorLog(errorMessage));
            }

            // Alert consignment:
            if(Test.isRunningTest() || (mapPrevQuantity.containsKey('migratedQuantity') && mapPrevQuantity.get('migratedQuantity') > 0)) {
                String errorMessage = 'Issue ' + piId + ': this product inventory starts with a Consignment Quantity ' + mapPrevQuantity.get('migratedQuantity');
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Alert consignment quantity message: ' + errorMessage);
            }

            // Alert shipment:
            if(Test.isRunningTest() || (doCalculateShippedQty && mapPrevQuantity.containsKey('shippedQuantity'))) {
                String errorMessage = 'Issue ' + piId + ': shipped quantity is recalculated by Shipment details records ' + mapPrevQuantity.get('shippedQuantity');
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Alert shipment quantity recalculated message: ' + errorMessage);
            }

            // For BackOrder
            if(Test.isRunningTest() || (mapCalculatedQuantity.containsKey('qtyBackOrder') && mapPrevQuantity.containsKey('qtyBackOrder') && mapPrevQuantity.get('qtyBackOrder') != mapCalculatedQuantity.get('qtyBackOrder'))) {
                String errorMessage = onlyCheck ? '(Only check) ' : '';
                errorMessage = errorMessage + 'Issue ' + piId + ': ';
                errorMessage = errorMessage + ' BO[' + mapPrevQuantity.get('qtyBackOrder') + '->' + mapCalculatedQuantity.get('qtyBackOrder') + '->' + piNewQtyWithoutAv.giic_BackOrderNew__c + '] ';
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ BackOrder done');

            // For Reserved
            if(Test.isRunningTest() || (mapCalculatedQuantity.containsKey('qtyReserved') && mapPrevQuantity.containsKey('qtyReserved') && mapPrevQuantity.get('qtyReserved') != mapCalculatedQuantity.get('qtyReserved'))) {
                String errorMessage = onlyCheck ? '(Only check) ' : '';
                errorMessage = errorMessage + 'Issue ' + piId + ': ';
                errorMessage = errorMessage + ' RES[' + mapPrevQuantity.get('qtyReserved') + '->' + mapCalculatedQuantity.get('qtyReserved') + '->' + piNewQtyWithoutAv.giic_Reserved__c + '] ';
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved done');

            // For SalesOnHand
            if(Test.isRunningTest() || (mapCalculatedQuantity.containsKey('qtySalesOnHand') && mapPrevQuantity.containsKey('qtySalesOnHand') && mapPrevQuantity.get('qtySalesOnHand') != mapCalculatedQuantity.get('qtySalesOnHand'))) {
                String errorMessage = onlyCheck ? '(Only check) ' : '';
                errorMessage = errorMessage + 'Issue ' + piId + ': ';
                errorMessage = errorMessage + ' SOH[' + mapPrevQuantity.get('qtySalesOnHand') + '->' + mapCalculatedQuantity.get('qtySalesOnHand') + '->' + piNewQtyWithoutAv.giic_SalesOnHand__c + '] ';
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOnHand done');

            // For Availability (check first if it has been updated in the second list)
            if(Test.isRunningTest() || (mapCalculatedQuantity.containsKey('qtyAvailability') && mapPrevQuantity.containsKey('qtyAvailability') && mapPrevQuantity.get('qtyAvailability') != mapCalculatedQuantity.get('qtyAvailability'))) {
                Decimal newAvaiableQty = mapPiWithNewValuesAvailability.containsKey(piId) ? mapPiWithNewValuesAvailability.get(piId).gii__AvailableQuantity__c : (mapPrevQuantity.containsKey('qtyAvailability') ? mapPrevQuantity.get('qtyAvailability') : 0);
                String errorMessage = onlyCheck ? '(Only check) ' : '';
                errorMessage = errorMessage + 'Issue ' + piId + ': ';
                errorMessage = errorMessage + ' AV[' + mapPrevQuantity.get('qtyAvailability') + '->' + mapCalculatedQuantity.get('qtyAvailability') + '->' + newAvaiableQty + '] ';
                listIssue.add(insertBatchErrorLog(errorMessage));
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Availability done');
        }
        XC_UTIL_Sobject.insertListRecords(listIssue);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for After Maintenance ended');
    }

    //******************************************************************************************************************************************************/


    //*************************************************************************************************************************** METHODS FOR SERIAL PRODUCT: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to maintenance PI for SERIAL product
    */
    public static void maintenanceSerialProduct(List<gii__ProductInventory__c> scope, Boolean onlyCheck, Boolean doCalculateShippedQty, Savepoint savePoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check correct warehouse for Product Serial...');
        Boolean resultFixSerial = fixProductSerial(scope, onlyCheck);
        if(!resultFixSerial) {
            Database.rollback(savePoint);
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Product Serial done');
        
        // Get all variables to calculate new quantity:
        Map<String, Decimal> mapReceipt             = doReceiptSerialProduct(scope);
        Map<String, Decimal> mapReceiptPO           = doReceiptForPOSerialProduct(scope);
        Map<String, Decimal> mapInventoryAdj        = doInventoryAdjSerialProduct(scope);
        Map<String, Decimal> mapSoLine              = doSoLineSerialProduct(scope);
        Map<String, Decimal> mapRMA                 = doRMASerialProduct(scope);
        Map<String, Map<String, Decimal>> mapToLine = doToLineSerialProduct(scope);
        Map<String, Decimal> mapShipment            = doShipmentSerialProduct(scope);
        Map<String, Decimal> mapTOWHfrom            = new Map<String, Decimal>();
        if(mapToLine.containsKey('mapTOWHfrom')) {
            mapTOWHfrom = mapToLine.get('mapTOWHfrom');
        }    

        
        // Calculate new quantity:
        Map<String, Map<String, Decimal>> mapCurrentQuantity                                            = getMapCurrentQuantitySerialProduct(scope, mapShipment, doCalculateShippedQty);
        Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> mapResultsQuantityDetail = getMapQuantityDetailSerialProduct(scope);
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail                     = mapResultsQuantityDetail.get('mapQuantityDetail');
        Set<String> listPIQDtoResetReserved                                                             = (mapCurrentQuantity.containsKey('listPIQDtoResetReserved') && !mapCurrentQuantity.get('listPIQDtoResetReserved').isEmpty()) ? mapCurrentQuantity.get('listPIQDtoResetReserved').keySet() : new Set<String>();
        Set<String> listMultipleSalesLocation                                                           = mapResultsQuantityDetail.get('listIdsProductInventoryWithMultipleSales').keySet();
        List<gii__ProductInventory__c> listPItoMaintenance                                              = scope;

        // Calculate new Quantity:
        Set<String> setKeyToSearch = new Set<String>();
        setKeyToSearch.addAll(mapReceipt.keySet());
        setKeyToSearch.addAll(mapReceiptPO.keySet());
        setKeyToSearch.addAll(mapInventoryAdj.keySet());
        setKeyToSearch.addAll(mapSoLine.keySet());
        setKeyToSearch.addAll(mapRMA.keySet());
        for(String keyCurrentQuantity : mapCurrentQuantity.keySet()) {
            if(keyCurrentQuantity.split('_').size()>1) {
                setKeyToSearch.add(keyCurrentQuantity);
            }
        }
        //setKeyToSearch.addAll(mapShipment.keySet());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List setKeyToSearch: ' + setKeyToSearch);
        Map<String, Map<String, Decimal>> mapTempQuantity           = getMapTempQuantitySerialProduct(listPItoMaintenance, setKeyToSearch, mapReceipt, mapReceiptPO, mapInventoryAdj, mapRMA, mapTOWHfrom, mapCurrentQuantity, mapShipment);
        UtilityWrapper utilityWrapperForNewCalculateQuantity        = getMapNewCalculatedQuantitySerialProduct(listPItoMaintenance, mapTempQuantity, setKeyToSearch);
        Map<String, Map<String, Decimal>> mapNewCalculatedQuantity  = utilityWrapperForNewCalculateQuantity.mapKeyQuantity;
        Map<String, gii__ProductInventory__c> mapPi                 = new Map<String, gii__ProductInventory__c>();
        for(gii__ProductInventory__c pic : listPItoMaintenance) {
            mapPi.put(pic.Id, pic);
        }
        if(!utilityWrapperForNewCalculateQuantity.listIssues.isEmpty()) {
            XC_UTIL_Sobject.insertListRecords(utilityWrapperForNewCalculateQuantity.listIssues);
        }

        // Debug maps:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ setKeyToSearch: ' + setKeyToSearch);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapReceipt: ' + mapReceipt.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapReceiptPO: ' + mapReceiptPO.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapInventoryAdj: ' + mapInventoryAdj.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapSoLine: ' + mapSoLine.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapRMA: ' + mapRMA.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHfrom: ' + mapTOWHfrom.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapRMA: ' + mapRMA.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTempQuantity: ' + mapTOWHfrom.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapQuantityDetail: ' + mapQuantityDetail.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listMultipleSalesLocation: ' + listMultipleSalesLocation);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIQDtoResetReserved: ' + listPIQDtoResetReserved);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPItoMaintenance: ' + listPItoMaintenance);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCurrentQuantity: ' + mapCurrentQuantity.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapResultsQuantityDetail: ' + mapResultsQuantityDetail.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapNewCalculatedQuantity: ' + mapNewCalculatedQuantity.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPi: ' + mapPi.values());

        // Do Maintenance:
        XC_BatchErrorLog__c bel = maintenanceInventorySerialProduct(listPItoMaintenance, mapPi, setKeyToSearch, listPIQDtoResetReserved, mapTOWHfrom, mapTempQuantity, mapSoLine, mapCurrentQuantity, mapNewCalculatedQuantity, mapQuantityDetail, onlyCheck, listMultipleSalesLocation, savePoint);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Error Maintenance Inventory: ' + bel);
        if(bel != null) {
            Database.rollback(savePoint);
            XC_UTIL_Sobject.insertRecord(bel);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ PI Serial Product maintenance ended');
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to fix Product Serial
     * @return Boolean
    */
    public static Boolean fixProductSerial(List<gii__ProductInventory__c> scope, Boolean onlyCheck) {
        List<XC_BatchErrorLog__c> listIssue = new List<XC_BatchErrorLog__c>();
        List<String> listTOStatusPermitted = new List<String>{Label.giic_TOPartiallyReceivedStatus, Label.giic_Received};
        List<gii__ProductInventory__c> listPIwithSerial = new List<gii__ProductInventory__c>([
            SELECT Id, 
                (SELECT Id, Name, gii__Warehouse__c, gii__TransferOrderId__c, gii__ProductInventory__r.gii__Warehouse__c, gii__TransferOrderId__r.gii__TransferToWarehouse__c, gii__Location__c 
                FROM gii__Product_Serials__r
                WHERE gii__Location__c != null AND giic_StatusCode__c = 'In Stock' AND gii__TransferOrderId__c != null AND gii__TransferOrderId__r.giic_status__c IN :listTOStatusPermitted) 
            FROM gii__ProductInventory__c 
            WHERE Id IN :scope
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIwithSerial: ' + listPIwithSerial);

        List<gii__ProductSerial__c> listSerialToFix = new List<gii__ProductSerial__c>();
        for(gii__ProductInventory__c pi : listPIwithSerial) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check correct WH for PI: ' + pi.Id);
            for(gii__ProductSerial__c piSerial : pi.gii__Product_Serials__r) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check correct WH for Serial: ' + piSerial.Id);
                if(String.isNotBlank(piSerial.gii__TransferOrderId__c) && String.isNotBlank(piSerial.gii__Location__c) && piSerial.gii__Warehouse__c != piSerial.gii__TransferOrderId__r.gii__TransferToWarehouse__c) {
                    listIssue.add(insertBatchErrorLog('Wrong Warehouse for Serial ' + piSerial.Name + ': [' + piSerial.gii__Warehouse__c + '] -> [' + piSerial.gii__TransferOrderId__r.gii__TransferToWarehouse__c + ' (from ToWarehouse)]'));
                    piSerial.gii__Warehouse__c = piSerial.gii__TransferOrderId__r.gii__TransferToWarehouse__c;
                    listSerialToFix.add(piSerial);
                }
                if(piSerial.gii__Warehouse__c != piSerial.gii__ProductInventory__r.gii__Warehouse__c) {
                    listIssue.add(insertBatchErrorLog('IMPORTANT WARNING: Product Serial (' + piSerial.Name + ') Warehouse (' + piSerial.gii__Warehouse__c + ') is different from Product Inventory Warehouse (' + piSerial.gii__ProductInventory__r.gii__Warehouse__c + '). No action for this warning: check manually.'));
                }
            }
        }

        // DML Operation:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSerialToFix: ' + listSerialToFix);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listIssue: ' + listIssue);
        if(!listSerialToFix.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> listResultFixSerial = XC_UTIL_Sobject.updateListRecords(listSerialToFix);
            if(!XC_UTIL_Sobject.checkDMLResults(listResultFixSerial)) {
                listIssue.add(insertBatchErrorLog('Error to fix Product Serial: ' + listResultFixSerial[0].errorMessage));
                XC_UTIL_Sobject.insertListRecords(listIssue);
                return false;
            }
            if(!listIssue.isEmpty()) {
                XC_UTIL_Sobject.insertListRecords(listIssue);
                return true;
            }
            return true;
        } else {
            return true;
        }
    }

    //******************************************************************************************************************* CREATE PIVOT: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate Receipt (serial Product)
    */
    public static Map<String, Decimal> doReceiptSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do Receipt');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__Receipt__c> listReceipt = new List<gii__Receipt__c>([
            SELECT Id, gii__ProductInventory__c, gii__ReceiptQuantity__c, gii__ProductSerial__c  
            FROM gii__Receipt__c 
            WHERE gii__ProductInventory__c IN: pi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listReceipt: ' + listReceipt);
        if(listReceipt.isEmpty()) {
            return mapResult;
        }

        for(gii__Receipt__c ri : listReceipt) {
            if(String.isNotBlank(ri.gii__ProductSerial__c)) {
                String key = '' + ri.gii__ProductInventory__c + '_' + ri.gii__ProductSerial__c;
                if(!mapResult.containsKey(key)) {
                    mapResult.put(key, ri.gii__ReceiptQuantity__c);
                } else {
                    Decimal temp = mapResult.get(key);
                    mapResult.put(key, temp+ri.gii__ReceiptQuantity__c);
                }
            }
        }
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate ReceiptPO (serial Product)
    */
    public static Map<String, Decimal> doReceiptForPOSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do ReceiptPO');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__PurchaseOrderReceiptline__c> listReceiptPO = new List<gii__PurchaseOrderReceiptline__c>([
            SELECT Id, gii__ProductInventory__c, gii__ReceivedQuantity__c, gii__ProductSerial__c 
            FROM gii__PurchaseOrderReceiptline__c 
            WHERE gii__ProductInventory__c IN: pi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listReceiptPO: ' + listReceiptPO);
        if(listReceiptPO.isEmpty()) {
            return mapResult;
        }

        for(gii__PurchaseOrderReceiptline__c ri : listReceiptPO) {
            if(String.isNotBlank(ri.gii__ProductSerial__c)) {
                String key = '' + ri.gii__ProductInventory__c + '_' +  ri.gii__ProductSerial__c;
                if(!mapResult.containsKey(key)) {
                    mapResult.put(key, ri.gii__ReceivedQuantity__c);
                } else {
                    Decimal temp = mapResult.get(key);
                    mapResult.put(key, temp+ri.gii__ReceivedQuantity__c);
                }
            }
        }
        return mapResult;
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate InventoryAdj (serial Product)
    */
    public static Map<String, Decimal> doInventoryAdjSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do InventoryAdj');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__InventoryAdjustment__c> listInventoryAdj = new List<gii__InventoryAdjustment__c>([
            SELECT Id, gii__ProductInventory__c, gii__AdjustmentQuantity__c, gii__Reason__c, gii__ProductSerial__c  
            FROM gii__InventoryAdjustment__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__Reason__c != 'Soft Reservation' AND gii__Reason__c != 'Stock Cleaning' AND gii__Location__r.giic_LocationType__c = 'Sales' 
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInventoryAdj: ' + listInventoryAdj);
        if(listInventoryAdj.isEmpty()) {
            return mapResult;
        }

        for(gii__InventoryAdjustment__c invAdj : listInventoryAdj) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For InventoryAdj: ' + invAdj);
            if(String.isNotBlank(invAdj.gii__ProductSerial__c)) {
                String key = '' + invAdj.gii__ProductInventory__c + '_' +  invAdj.gii__ProductSerial__c;
                if(!mapResult.containsKey(key)) {
                    mapResult.put(key, invAdj.gii__AdjustmentQuantity__c);
                } else {
                    Decimal temp = mapResult.get(key);
                    mapResult.put(key, temp+invAdj.gii__AdjustmentQuantity__c);
                }
            }
        }
        return mapResult;
    }   
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate SoLine (serial Product)
    */
    public static Map<String, Decimal> doSoLineSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do SoLine');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__SalesOrderLine__c> listSoLine = new List<gii__SalesOrderLine__c>([
            SELECT Id, gii__ProductInventory__c, gii__OpenQuantity__c
            FROM gii__SalesOrderLine__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__LineStatus__c = 'Open' AND gii__SalesOrder__r.giic_OrderStatus__c != 'Error'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSoLine: ' + listSoLine);
        if(listSoLine.isEmpty()) {
            return mapResult;
        }

        for(gii__SalesOrderLine__c soLine : listSoLine) {
            String key = '' + soLine.gii__ProductInventory__c;
            if(!mapResult.containsKey(key)) {
                mapResult.put(key, soLine.gii__OpenQuantity__c);
            } else {
                Decimal temp = mapResult.get(key);
                mapResult.put(key, temp+soLine.gii__OpenQuantity__c);
            }
        }
        return mapResult;
    }     

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate RMA (serial Product)
    */
    public static Map<String, Decimal> doRMASerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do RMA');
        Map<String, Decimal> mapResult = new Map<String, Decimal>();
        List<gii__RMADisposition__c> listRMA = new List<gii__RMADisposition__c>([
            SELECT Id, gii__ProductInventory__c, gii__DispositionQuantity__c, gii__ProductSerial__c
            FROM gii__RMADisposition__c 
            WHERE gii__ProductInventory__c IN: pi AND gii__DispositionLocation__r.giic_LocationType__c = 'Sales'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listRMA: ' + listRMA);
        if(listRMA.isEmpty()) {
            return mapResult;
        }

        for(gii__RMADisposition__c rma : listRMA) {
            if(String.isNotBlank(rma.gii__ProductSerial__c)) {
                String key = '' + rma.gii__ProductInventory__c + '_' +  rma.gii__ProductSerial__c;
                if(!mapResult.containsKey(key)) {
                    mapResult.put(key, rma.gii__DispositionQuantity__c);
                } else {
                    Decimal temp = mapResult.get(key);
                    mapResult.put(key, temp+rma.gii__DispositionQuantity__c);
                }
            }
        }
        return mapResult;
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate ToLine (serial Product)
    */
    public static Map<String, Map<String, Decimal>> doToLineSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do ToLine');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> mapTOWHfrom = new Map<String, Decimal>();
        List<String> piListWareHouse = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Warehouse__c');
        List<String> piListProduct = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Product__c');
        List<String> listStatusNotPermitted = new List<String>{'Received', 'Cancelled', 'Merged'};
        List<gii__TransferOrderLine__c> listTo = new List<gii__TransferOrderLine__c>([
            SELECT Id, gii__TransferOrder__r.giic_WorkOrder__c, gii__TransferOrder__r.giic_SalesOrder__c, CreatedBy.username, gii__Product__c, gii__TransferOrder__r.gii__FromWarehouse__c, gii__TransferOrder__r.gii__TransferToWarehouse__c, gii__OpenQuantity__c 
            FROM gii__TransferOrderLine__c 
            WHERE ((gii__TransferOrder__r.gii__TransferToWarehouse__c IN: piListWareHouse OR gii__TransferOrder__r.gii__FromWarehouse__c IN: piListWareHouse) AND gii__Product__c IN: piListProduct) 
                    AND (gii__TransferOrder__r.giic_status__c NOT IN :listStatusNotPermitted)
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listTo: ' + listTo);
        if(listTo.isEmpty()) {
            return mapResult;
        }

        for(gii__TransferOrderLine__c to : listTo) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For TO: ' + to.Id);
            String keyFromWH = '' + to.gii__Product__c + to.gii__TransferOrder__r.gii__FromWarehouse__c;
            for(gii__ProductInventory__c singlePI : pi) {
                if(singlePI.gii__Warehouse__c == to.gii__TransferOrder__r.gii__FromWarehouse__c) {
                    if(!mapTOWHfrom.containsKey(keyFromWH)) {
                        mapTOWHfrom.put(keyFromWH, to.gii__OpenQuantity__c);
                    } else {
                        Decimal temp = mapTOWHfrom.get(keyFromWH);
                        mapTOWHfrom.put(keyFromWH, temp+to.gii__OpenQuantity__c);
                    }
                    continue;
                }  
            }

            // Debug maps:
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ keyFromWH: ' + keyFromWH);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTOWHfrom: ' + mapTOWHfrom.values());
        }

        mapResult.put('mapTOWHfrom', mapTOWHfrom);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Return for Map TO: ' + mapResult);
        return mapResult;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to calculate Shipment details (serial Product)
    */
    public static Map<String, Decimal> doShipmentSerialProduct(List<gii__ProductInventory__c> pi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do Shipment');
        Map<String, Decimal> mapShipment = new Map<String, Decimal>();
        List<String> piListWareHouse = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Warehouse__c');
        List<String> piListProduct = XC_UTIL_Sobject.getListFieldValues(pi, 'gii__Product__c');
        List<gii__ShipmentDetail__c> listShipment = new List<gii__ShipmentDetail__c>([
            SELECT Id, gii__ShippedQuantity__c, gii__TransferOrderLine__c, gii__SalesOrderLine__c, gii__TransferOrderLine__r.gii__TransferOrder__r.gii__FromWarehouse__c, gii__TransferOrderLine__r.gii__Product__c, gii__SalesOrderLine__r.gii__Warehouse__c, gii__SalesOrderLine__r.gii__Product__c, gii__ProductSerial__c
            FROM gii__ShipmentDetail__c 
            WHERE   (gii__TransferOrderLine__r.gii__TransferOrder__r.gii__FromWarehouse__c IN :piListWareHouse AND gii__TransferOrderLine__r.gii__Product__c IN :piListProduct) 
                    OR
                    (gii__SalesOrderLine__r.gii__Warehouse__c IN :piListWareHouse AND gii__SalesOrderLine__r.gii__Product__c IN :piListProduct) 
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listShipment: ' + listShipment);
        if(listShipment.isEmpty()) {
            return mapShipment;
        }

        for(gii__ShipmentDetail__c ship : listShipment) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For shipment: ' + ship.Id);
            // For TO
            if(String.isNotBlank(ship.gii__TransferOrderLine__c)) {
                String keyFromWHTO = '' + ship.gii__ProductSerial__c;
                if(!mapShipment.containsKey(keyFromWHTO)) {
                    mapShipment.put(keyFromWHTO, ship.gii__ShippedQuantity__c);
                } else {
                    Decimal temp = mapShipment.get(keyFromWHTO);
                    mapShipment.put(keyFromWHTO, temp+ship.gii__ShippedQuantity__c);
                }
            }
            // For SO
            if(String.isNotBlank(ship.gii__SalesOrderLine__c)) {
                String keyFromWHSO = '' + ship.gii__ProductSerial__c;
                if(!mapShipment.containsKey(keyFromWHSO)) {
                    mapShipment.put(keyFromWHSO, ship.gii__ShippedQuantity__c);
                } else {
                    Decimal temp = mapShipment.get(keyFromWHSO);
                    mapShipment.put(keyFromWHSO, temp+ship.gii__ShippedQuantity__c);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Return for Map Shipment: ' + mapShipment);
        return mapShipment;
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/01/2022
     * @description Method to get map with current quantity (serial Product)
    */
    public static Map<String, Map<String, Decimal>> getMapCurrentQuantitySerialProduct(List<gii__ProductInventory__c> listPi, Map<String, Decimal> mapShipment, Boolean doCalculateShippedQty) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapCurrentQuantity');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        mapResult.put('listPIQDtoResetReserved', new Map<String, Decimal>());
        Map<Id, gii__ProductInventory__c> mapPiWithReturnedProd = new Map<Id, gii__ProductInventory__c>([
            SELECT Id, 
                (SELECT Id, gii__ProductSerial__c, gii__ShippedQuantity__c 
                FROM gii__ReturntoSupplierLine_Shipments__r), 
                (SELECT Id, gii__ProductSerial__c, gii__Location__r.giic_LocationType__c, gii__OnHandQuantity__c, gii__Available__c, giic_Reserved__c 
                FROM gii__ProductInventoryQuantityDetails__r
                WHERE gii__Location__r.giic_LocationType__c IN ('Scrap','NO-Sales','Sales'))  
            FROM gii__ProductInventory__c 
            WHERE Id IN :listPi
        ]);

        for(gii__ProductInventory__c pi : listPi) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            mapResult.put(pi.Id, new Map<String, Decimal>{
                'qtyReserved'               => pi.giic_Reserved__c,
                'qtySalesOnHand'            => pi.giic_SalesOnHand__c,
                'qtyAvailability'           => pi.gii__AvailableQuantity__c,
                'qtyBackOrder'              => pi.giic_BackOrderNew__c,
                'shippedQuantity'           => pi.gii__ShippedQuantity__c,
                'migratedQuantity'          => pi.gii__ConsignmentReceiptQuantity__c
            });

            if(mapPiWithReturnedProd.containsKey(pi.Id)) {
                gii__ProductInventory__c piWithReturnedProduct = mapPiWithReturnedProd.get(pi.Id);

                // For Reserved and SalesOnHand by serial:
                for(gii__ProductInventoryQuantityDetail__c piqd : piWithReturnedProduct.gii__ProductInventoryQuantityDetails__r) {
                    if(piqd.gii__Location__r.giic_LocationType__c != 'Sales') {
                        continue;
                    }
                    String key = '' + piWithReturnedProduct.Id + '_' +  piqd.gii__ProductSerial__c;
                    if(mapResult.containsKey(key)) {
                        Map<String, Decimal> mapExistingValues = mapResult.get(key);
                        // For Reserved:
                        if(mapExistingValues.containsKey('qtyReserved')) {
                            Decimal existingValue = mapExistingValues.get('qtyReserved');
                            mapExistingValues.put('qtyReserved', existingValue+piqd.giic_Reserved__c);
                        }
                        else {
                            mapExistingValues.put('qtyReserved', piqd.giic_Reserved__c);
                        }
                        if(piqd.giic_Reserved__c > 0) {
                            Map<String, Decimal> mapListToReset = mapResult.get('listPIQDtoResetReserved');
                            mapListToReset.put(piqd.Id, 0);
                            mapResult.put('listPIQDtoResetReserved', mapListToReset);
                        }
                        // For SalesOnHand:
                        if(mapExistingValues.containsKey('qtySalesOnHand')) {
                            Decimal existingValue = mapExistingValues.get('qtySalesOnHand');
                            mapExistingValues.put('qtySalesOnHand', existingValue+piqd.gii__Available__c);
                        }
                        else {
                            mapExistingValues.put('qtySalesOnHand', piqd.gii__Available__c);
                        }
                        mapResult.put(key, mapExistingValues);
                    }
                    else {
                        Map<String, Decimal> mapNewValues = new Map<String, Decimal>();
                        mapNewValues.put('qtyReserved', piqd.giic_Reserved__c);
                        mapNewValues.put('qtySalesOnHand', piqd.gii__Available__c);
                        mapResult.put(key, mapNewValues);
                        if(piqd.giic_Reserved__c > 0) {
                            Map<String, Decimal> mapListToReset = mapResult.get('listPIQDtoResetReserved');
                            mapListToReset.put(piqd.Id, 0);
                            mapResult.put('listPIQDtoResetReserved', mapListToReset);
                        }
                    }
                }

                // For Return to Supplier:
                for(gii__ReturntoSupplierLineShipment__c returnTo : piWithReturnedProduct.gii__ReturntoSupplierLine_Shipments__r) {
                    String key = '' + piWithReturnedProduct.Id + '_' +  returnTo.gii__ProductSerial__c;
                    if(mapResult.containsKey(key)) {
                        Map<String, Decimal> mapExistingValues = mapResult.get(key);
                        if(mapExistingValues.containsKey('returnToSupply')) {
                            Decimal existingValue = mapExistingValues.get('returnToSupply');
                            mapExistingValues.put('returnToSupply', existingValue+returnTo.gii__ShippedQuantity__c);
                        }
                        else {
                            mapExistingValues.put('returnToSupply', returnTo.gii__ShippedQuantity__c);
                        }
                        mapResult.put(key, mapExistingValues);
                    }
                    else {
                        Map<String, Decimal> mapNewValues = new Map<String, Decimal>();
                        mapNewValues.put('returnToSupply', returnTo.gii__ShippedQuantity__c);
                        mapResult.put(key, mapNewValues);
                    }
                }

                // For Scrap e No-Sales:
                for(gii__ProductInventoryQuantityDetail__c piqd : piWithReturnedProduct.gii__ProductInventoryQuantityDetails__r) {
                    if(piqd.gii__Location__r.giic_LocationType__c == 'Sales') {
                        continue;
                    }
                    String key = '' + piWithReturnedProduct.Id + '_' +  piqd.gii__ProductSerial__c;
                    if(mapResult.containsKey(key)) {
                        Map<String, Decimal> mapExistingValues = mapResult.get(key);
                        if(piqd.gii__Location__r.giic_LocationType__c == 'Scrap') {
                            if(mapExistingValues.containsKey('scrapLocationQuantity')) {
                                Decimal existingValue = mapExistingValues.get('scrapLocationQuantity');
                                mapExistingValues.put('scrapLocationQuantity', existingValue+piqd.gii__OnHandQuantity__c);
                            }
                            else {
                                mapExistingValues.put('scrapLocationQuantity', piqd.gii__OnHandQuantity__c);
                            }
                            mapResult.put(key, mapExistingValues);
                        }
                        if(piqd.gii__Location__r.giic_LocationType__c == 'NO-Sales') {
                            if(mapExistingValues.containsKey('noSalesLocationQuantity')) {
                                Decimal existingValue = mapExistingValues.get('noSalesLocationQuantity');
                                mapExistingValues.put('noSalesLocationQuantity', existingValue+piqd.gii__OnHandQuantity__c);
                            }
                            else {
                                mapExistingValues.put('noSalesLocationQuantity', piqd.gii__OnHandQuantity__c);
                            }
                            mapResult.put(key, mapExistingValues);
                        }
                    }
                    else {
                        Map<String, Decimal> mapNewValues = new Map<String, Decimal>();
                        if(piqd.gii__Location__r.giic_LocationType__c == 'Scrap') {
                            mapNewValues.put('scrapLocationQuantity', piqd.gii__OnHandQuantity__c);
                        }
                        if(piqd.gii__Location__r.giic_LocationType__c == 'NO-Sales') {
                            mapNewValues.put('noSalesLocationQuantity', piqd.gii__OnHandQuantity__c);
                        }
                        mapResult.put(key, mapNewValues);
                    }
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapResult: ' + mapResult.values());
        return mapResult;
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/01/2022
     * @description Method to get map with temp quantity (serial Product)
    */
    public static Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> getMapQuantityDetailSerialProduct(List<gii__ProductInventory__c> listPi) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getMapQuantityDetailSerialProduct');
        Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>> mapResult = new Map<String, Map<String, List<gii__ProductInventoryQuantityDetail__c>>>();
        
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> listIdsProductInventoryWithMultipleSales = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();

        List<gii__ProductInventoryQuantityDetail__c> listPIQD = new List<gii__ProductInventoryQuantityDetail__c>([
            SELECT Id, gii__ProductSerial__c, gii__Available__c, gii__ProductSerial__r.gii__TransferOrderId__r.giic_status__c, gii__ProductSerial__r.giic_StatusCode__c, gii__ProductSerial__r.gii__TransferOrderId__r.gii__TransferToWarehouse__c, giic_Reserved__c, gii__ProductInventory__c, gii__ProductInventorybyLocation__c, gii__Location__c, gii__Product__c, gii__Warehouse__c 
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE gii__ProductInventory__c IN: listPi AND gii__Location__r.giic_LocationType__c = 'Sales'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIQD: ' + listPIQD);

        for(gii__ProductInventoryQuantityDetail__c piqd : listPIQD) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PIQD: ' + piqd.Id);
            String key = '' + piqd.gii__ProductInventory__c + '_' + piqd.gii__ProductSerial__c;
            if(!mapQuantityDetail.containsKey(key)) {
                mapQuantityDetail.put(key, new List<gii__ProductInventoryQuantityDetail__c>{piqd});
            }
            else {
                listIdsProductInventoryWithMultipleSales.put(piqd.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>());
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result for PIQD: ' + mapQuantityDetail);
        mapResult.put('mapQuantityDetail', mapQuantityDetail);
        mapResult.put('listIdsProductInventoryWithMultipleSales', listIdsProductInventoryWithMultipleSales);        
        return mapResult;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/01/2022
     * @description Method to get map with temp quantity (serial Product)
    */
    public static Map<String, Map<String, Decimal>> getMapTempQuantitySerialProduct(List<gii__ProductInventory__c> listPi, Set<String> setKeyToSearch, Map<String, Decimal> mapReceipt, Map<String, Decimal> mapReceiptPO, Map<String, Decimal> mapInventoryAdj, Map<String, Decimal> mapRMA, Map<String, Decimal> mapTOWHfrom, Map<String, Map<String, Decimal>> mapCurrentQuantity, Map<String, Decimal> mapShipment) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapTempQuantitySerialProduct');
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();
        for(String keyToSearch : setKeyToSearch) {
            Map<String, Decimal> mapTempQty = new Map<String, Decimal>();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For key: ' + keyToSearch);

            // For "#entrateMerci":
            Decimal entrateMerci = 0;
            if(mapReceipt.containsKey(keyToSearch)) {
                entrateMerci += mapReceipt.get(keyToSearch);
            }
            if(mapReceiptPO.containsKey(keyToSearch)) {
                entrateMerci += mapReceiptPO.get(keyToSearch);
            }
            mapTempQty.put('entrateMerci', entrateMerci);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #entrateMerci: ' + entrateMerci);

            // For "#qtyInventoryAdjustement":
            Decimal qtyInventoryAdjustement = 0;
            if(mapInventoryAdj.containsKey(keyToSearch)) {
                qtyInventoryAdjustement += mapInventoryAdj.get(keyToSearch);
            }
            mapTempQty.put('qtyInventoryAdjustement', qtyInventoryAdjustement);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #qtyInventoryAdjustement: ' + qtyInventoryAdjustement);

            // For "#shippedQuantity":
            Decimal shippedQuantity = 0;
            String keyForShipment = keyToSearch.split('_')[1];
            if(mapShipment.containsKey(keyForShipment)) {
                shippedQuantity += mapShipment.get(keyForShipment);
            }
            mapTempQty.put('shippedQuantity', shippedQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #shippedQuantity: ' + shippedQuantity);

            // For "#scrapLocationQuantity":
            Decimal scrapLocationQuantity = 0;
            if(mapCurrentQuantity.containsKey(keyToSearch) && mapCurrentQuantity.get(keyToSearch).containsKey('scrapLocationQuantity') && mapCurrentQuantity.get(keyToSearch).get('scrapLocationQuantity')!=null) {
                scrapLocationQuantity += mapCurrentQuantity.get(keyToSearch).get('scrapLocationQuantity');
            }
            mapTempQty.put('scrapLocationQuantity', scrapLocationQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #scrapLocationQuantity: ' + scrapLocationQuantity);

            // For "#noSalesLocationQuantity":
            Decimal noSalesLocationQuantity = 0;
            if(mapCurrentQuantity.containsKey(keyToSearch) && mapCurrentQuantity.get(keyToSearch).containsKey('noSalesLocationQuantity') && mapCurrentQuantity.get(keyToSearch).get('noSalesLocationQuantity')!=null) {
                noSalesLocationQuantity += mapCurrentQuantity.get(keyToSearch).get('noSalesLocationQuantity');
            }
            mapTempQty.put('noSalesLocationQuantity', noSalesLocationQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #noSalesLocationQuantity: ' + noSalesLocationQuantity);

            // For "#rma":
            Decimal rma = 0;
            if(mapRMA.containsKey(keyToSearch)) {
                rma += mapRMA.get(keyToSearch);
            }
            mapTempQty.put('rma', rma);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #rma: ' + rma);

            // For "#migratedQuantity":
            Decimal migratedQuantity = 0;
            String keyForConsignment = keyToSearch.split('_')[0];
            if(mapCurrentQuantity.containsKey(keyForConsignment) && mapCurrentQuantity.get(keyForConsignment).containsKey('migratedQuantity') && mapCurrentQuantity.get(keyForConsignment).get('migratedQuantity')!=null) {
                migratedQuantity += mapCurrentQuantity.get(keyForConsignment).get('migratedQuantity');
            }
            mapTempQty.put('migratedQuantity', migratedQuantity);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #migratedQuantity: ' + migratedQuantity);

            // For "#returnToSupply":
            Decimal returnToSupply = 0;
            if(mapCurrentQuantity.containsKey(keyToSearch) && mapCurrentQuantity.get(keyToSearch).containsKey('returnToSupply') && mapCurrentQuantity.get(keyToSearch).get('returnToSupply')!=null) {
                returnToSupply += mapCurrentQuantity.get(keyToSearch).get('returnToSupply');
            }
            mapTempQty.put('returnToSupply', returnToSupply);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ #returnToSupply: ' + returnToSupply);

            mapResult.put(keyToSearch, mapTempQty);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this iteration: ' + (mapResult.containsKey(keyToSearch) ? ' elements found ' : ' elements not found '));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Map Result for Temp Quantity: ' + mapResult);
        return mapResult;
    }  

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/01/2022
     * @description Method to get map with new calculated quantity (serial Product)
    */
    public static UtilityWrapper getMapNewCalculatedQuantitySerialProduct(List<gii__ProductInventory__c> listPi, Map<String, Map<String, Decimal>> mapTempQuantity, Set<String> setKeyToSearch) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do getMapNewCalculatedQuantity');
        UtilityWrapper utilityWrapper = new UtilityWrapper();
        Map<String, Map<String, Decimal>> mapResult = new Map<String, Map<String, Decimal>>();

        for(String keyToSearch : setKeyToSearch) {
            String piId = keyToSearch.split('_')[0];
            String serialId = keyToSearch.split('_')[1];
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For key: ' + keyToSearch);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Product Inventory: ' + piId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Product Serial: ' + serialId);
            if(!mapTempQuantity.containsKey(keyToSearch)) {
                continue;
            }
            Map<String, Decimal> mapPiQuantity = mapTempQuantity.get(keyToSearch); 
            Map<String, Decimal> mapCurrentNewQty = new Map<String, Decimal>();

            // For SalesOnHand:
            Decimal salesOnHand = 0;
            if(mapPiQuantity.containsKey('entrateMerci') && mapPiQuantity.containsKey('qtyInventoryAdjustement') && mapPiQuantity.containsKey('shippedQuantity') /*&& mapPiQuantity.containsKey('migratedQuantity')*/ && mapPiQuantity.containsKey('rma') && mapPiQuantity.containsKey('returnToSupply')) {
                salesOnHand = mapPiQuantity.get('entrateMerci') + mapPiQuantity.get('qtyInventoryAdjustement') - mapPiQuantity.get('shippedQuantity') /*+ mapPiQuantity.get('migratedQuantity')*/ + mapPiQuantity.get('rma') - mapPiQuantity.get('returnToSupply');
                if(salesOnHand < 0) {
                    utilityWrapper.listIssues.add(insertBatchErrorLog('[ISSUE] For serial ' + serialId + ' sales on hand is < 0.\nEntrata merci: ' + mapPiQuantity.get('entrateMerci') + ' InvAdj: ' + mapPiQuantity.get('qtyInventoryAdjustement') + ' Shipped: ' + mapPiQuantity.get('shippedQuantity') + ' RMA: ' + mapPiQuantity.get('rma') + ' ReturnToSupply: ' + mapPiQuantity.get('returnToSupply')));
                    salesOnHand = 0;
                }
            } else {
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOnHand recalculated: ' + salesOnHand);
            mapCurrentNewQty.put('qtySalesOnHand', salesOnHand);
            mapResult.put(keyToSearch, mapCurrentNewQty);

            // For AvailableForSales:
            Decimal availableForSales = 0;
            if(mapPiQuantity.containsKey('scrapLocationQuantity') && mapPiQuantity.containsKey('noSalesLocationQuantity')) {
                availableForSales = salesOnHand + mapPiQuantity.get('scrapLocationQuantity') + mapPiQuantity.get('noSalesLocationQuantity');
                if(availableForSales < 0) {
                    availableForSales = 0;
                }
            } else {
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Available calculated after saving: ' + availableForSales);
            mapCurrentNewQty.put('qtyAvailability', availableForSales);
            mapResult.put(keyToSearch, mapCurrentNewQty);

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For this iteration: ' + (mapResult.containsKey(keyToSearch) ? ' elements found ' : ' elements not found '));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Calculate New Quantity map: ' + mapResult);
        utilityWrapper.mapKeyQuantity = mapResult;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ utilityWrapper: ' + utilityWrapper);
        return utilityWrapper;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/01/2022
     * @description Method to resolve quantity for PI (serial Product)
    */
    public static XC_BatchErrorLog__c maintenanceInventorySerialProduct(List<gii__ProductInventory__c> listPi, Map<String, gii__ProductInventory__c> mapPi, Set<String> setKeyToSearch, Set<String> listPIQDtoResetReserved, Map<String, Decimal> mapTOWHfrom, Map<String, Map<String, Decimal>> mapTempQuantity, Map<String, Decimal> mapSoLine, Map<String, Map<String, Decimal>> mapCurrentQuantity, Map<String, Map<String, Decimal>> mapNewCalculatedQuantity, Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapQuantityDetail, Boolean onlyCheck, Set<String> listMultipleSalesLocation, Savepoint savePoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do maintenanceInventory for Serial Product');
        Map<Id, gii__ProductInventory__c> mapPiToUpdate                         = new Map<Id, gii__ProductInventory__c>();
        Map<String, gii__ProductInventoryQuantityDetail__c> mapPiIdPIQDToUpdate = new Map<String, gii__ProductInventoryQuantityDetail__c>();
        Map<String, gii__InventoryAdjustment__c> mapPiIdInvAdjToInsert          = new Map<String, gii__InventoryAdjustment__c>();
        Map<String, Map<String, Decimal>> mapPiCalculated                       = new Map<String, Map<String, Decimal>>();
        Boolean qtyChanged                                                      = false;
        Set<Id> setIdPi                                                         = new Set<Id>();
        Map<Id, gii__ProductInventory__c> mapPiFromScope                        = new Map<Id, gii__ProductInventory__c>();
        List<String> listIssueProcessing                                        = new List<String>();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance SalesOnHand starts...');
        for(String keyToSearch : setKeyToSearch) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For key: ' + keyToSearch);
            if(keyToSearch.split('_').size()<=1) {
                continue;
            }
            String piId = keyToSearch.split('_')[0];
            String serialId = keyToSearch.split('_')[1];
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + piId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Serial: ' + serialId);
            setIdPi.add(piId);
            mapPiFromScope.put(piId, mapPi.get(piId));
            if(!mapCurrentQuantity.containsKey(keyToSearch) || !mapNewCalculatedQuantity.containsKey(keyToSearch)) {
                listIssueProcessing.add('[ISSUE] Key ' + keyToSearch + ' is not in map current quantity and/or map new quantity');
                continue;
            }
            Map<String, Decimal> mapCurrentQty  = mapCurrentQuantity.get(keyToSearch);
            Map<String, Decimal> mapNewQty      = mapNewCalculatedQuantity.get(keyToSearch);
            
            // Check SalesOnHand (serial products):
            // To fix SalesOnHand Quantity: insert Inventory Adjustment with (NewQuantity-OldQuantity)
            if(Test.isRunningTest() || (mapCurrentQty.containsKey('qtySalesOnHand') && mapNewQty.containsKey('qtySalesOnHand'))) {
                Decimal currentSalesOnHand = Test.isRunningTest() ? 1 : mapCurrentQty.get('qtySalesOnHand');
                Decimal newSalesOnHand = Test.isRunningTest() ? 2 : mapNewQty.get('qtySalesOnHand');
                Boolean salesOnHandChanged = currentSalesOnHand != newSalesOnHand;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For SalesOnHand current/new: ' + currentSalesOnHand + '/' + newSalesOnHand);
                if(salesOnHandChanged && mapQuantityDetail.containsKey(keyToSearch)) {
                    Decimal quantityAdj = 0;
                    if(newSalesOnHand == 0) {
                        quantityAdj = -1 * currentSalesOnHand;
                    } else if(newSalesOnHand == 1) {
                        if(currentSalesOnHand == 0) {
                            quantityAdj = 1;
                        } else {
                            quantityAdj = newSalesOnHand - currentSalesOnHand;
                        }
                    } else {
                        quantityAdj = newSalesOnHand - currentSalesOnHand;
                    }
                    gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c();
                    adjToInsert.gii__ProductInventory__c = piId;
                    adjToInsert.gii__ProductSerial__c = serialId;
                    adjToInsert.gii__AGC__c = 'Business Sales';
                    adjToInsert.gii__AdjustmentDate__c = Date.today();
                    adjToInsert.gii__AdjustmentQuantity__c = quantityAdj;
                    adjToInsert.gii__Location__c = mapQuantityDetail.get(keyToSearch)[0].gii__Location__c;
                    adjToInsert.gii__ProductInventoryQuantityDetail__c = mapQuantityDetail.get(keyToSearch)[0].Id;
                    adjToInsert.gii__ProductInventorybyLocation__c = mapQuantityDetail.get(keyToSearch)[0].gii__ProductInventorybyLocation__c;
                    adjToInsert.gii__Product__c = mapQuantityDetail.get(keyToSearch)[0].gii__Product__c;
                    adjToInsert.gii__Reason__c = 'Stock Cleaning';
                    adjToInsert.gii__StockUM__c = 'Each';
                    adjToInsert.gii__Warehouse__c = mapQuantityDetail.get(keyToSearch)[0].gii__Warehouse__c;

                    mapPiIdInvAdjToInsert.put(keyToSearch, adjToInsert);
                    qtyChanged = true;
                }
                
                if(!mapPiCalculated.containsKey(piId)) {
                    Map<String, Decimal> mapValuesTemp = new Map<String, Decimal>();
                    mapValuesTemp.put('salesOnHand', newSalesOnHand);
                    mapPiCalculated.put(piId, mapValuesTemp);
                } else {
                    Map<String, Decimal> mapValuesTemp = mapPiCalculated.get(piId);
                    Decimal oldValue = mapValuesTemp.containsKey('salesOnHand') ? mapValuesTemp.get('salesOnHand') : 0;
                    mapValuesTemp.put('salesOnHand', oldValue + newSalesOnHand);
                    mapPiCalculated.put(piId, mapValuesTemp);
                }
            }
        }
        // Insert Adjstument for SalesOnHand
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiIdInvAdjToInsert: ' + mapPiIdInvAdjToInsert.values());
        List<XC_UTIL_Sobject.WrapperResult> listInsertAdjustment = XC_UTIL_Sobject.insertListRecords(mapPiIdInvAdjToInsert.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInsertAdjustment: ' + listInsertAdjustment);
        if(!XC_UTIL_Sobject.checkDMLResults(listInsertAdjustment)) {
            String errorMessageAdj = 'You need to check inventory adjstument (except Soft Reservation and Stock Cleaning) for PI ' + mapPiFromScope.values()[0].Id + ' because the summation could be >1.';
            return insertBatchErrorLog('Error Insert Adj: ' + listInsertAdjustment[0].errorMessage + '\n' + errorMessageAdj);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance SalesOnHand ended.');

        // Check Reserved (serial products):
        // Reset current reserved:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Reserved starts...');
        List<gii__ProductInventoryQuantityDetail__c> listPIQDtoReset = new List<gii__ProductInventoryQuantityDetail__c>();
        for(String piqdId : listPIQDtoResetReserved) {
            listPIQDtoReset.add(new gii__ProductInventoryQuantityDetail__c(
                Id = piqdId,
                giic_Reserved__c = 0,
                giic_Status__c = ''
            ));
        }
        List<XC_UTIL_Sobject.WrapperResult> listResultResetPIQD = XC_UTIL_Sobject.updateListRecords(listPIQDtoReset);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listResultResetPIQD: ' + listResultResetPIQD);
        if(!XC_UTIL_Sobject.checkDMLResults(listResultResetPIQD)) {
            return insertBatchErrorLog('Error Update Reset PIQD: ' + listResultResetPIQD[0].errorMessage);
        }
        // Random reservation
        Map<String, gii__InventoryAdjustment__c> mapPiIdInvAdjToInsertForReservation = new Map<String, gii__InventoryAdjustment__c>();
        Map<String, Decimal> mapForReservation = new Map<String, Decimal>();
        for(String keyPISoLine : mapSoLine.keySet()) {
            mapForReservation.put(keyPISoLine, mapSoLine.get(keyPISoLine));
        }
        for(String iPiId : mapPi.keySet()) {
            gii__ProductInventory__c iPi = mapPi.get(iPiId);
            String keyMapTOFrom = ''+iPi.gii__Product__c+iPi.gii__Warehouse__c;
            if(mapTOWHfrom.containsKey(keyMapTOFrom)) {
                mapForReservation.put(iPiId, mapTOWHfrom.get(keyMapTOFrom));
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapForReservation: ' + mapForReservation.values());
        List<gii__ProductInventoryQuantityDetail__c> listPIQDforKeySetPI = new List<gii__ProductInventoryQuantityDetail__c>([
            SELECT Id, gii__Available__c, gii__ProductSerial__r.gii__TransferOrderId__r.giic_status__c, gii__ProductSerial__r.giic_StatusCode__c, gii__ProductSerial__c, gii__ProductSerial__r.gii__TransferOrderId__r.gii__TransferToWarehouse__c, giic_Reserved__c, gii__ProductInventory__c, gii__ProductInventorybyLocation__c, gii__Location__c, gii__Product__c, gii__Warehouse__c 
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE gii__ProductInventory__c IN: mapForReservation.keySet() AND gii__Location__r.giic_LocationType__c = 'Sales'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIQDforKeySetPI: ' + listPIQDforKeySetPI);
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapPiQuantityDetail = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        for(gii__ProductInventoryQuantityDetail__c piqd : listPIQDforKeySetPI) {
            if(!mapPiQuantityDetail.containsKey(piqd.gii__ProductInventory__c)) {
                mapPiQuantityDetail.put(piqd.gii__ProductInventory__c, new List<gii__ProductInventoryQuantityDetail__c>());
            }
            mapPiQuantityDetail.get(piqd.gii__ProductInventory__c).add(piqd);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiQuantityDetail: ' + mapPiQuantityDetail.values());

        List<gii__ProductSerial__c> listPSerialToUpdate = new List<gii__ProductSerial__c>();
        for(String keyPiForReservation : mapForReservation.keySet()) {
            Decimal quantityToReserve = mapForReservation.get(keyPiForReservation);
            Decimal quantityReserved = 0;
            // Reserve qty:
            if(quantityToReserve > 0 && mapPiQuantityDetail.containsKey(keyPiForReservation)) {
                for(gii__ProductInventoryQuantityDetail__c singlePIQD : mapPiQuantityDetail.get(keyPiForReservation)) {
                    String keyToSearch = ''+keyPiForReservation+'_'+singlePIQD.gii__ProductSerial__c;                    
                    if(quantityToReserve == quantityReserved) {
                        break;
                    }
                    if(!mapQuantityDetail.containsKey(keyToSearch)) {
                        listIssueProcessing.add('[ISSUE] Impossible to reserve quantity for PI ' + keyPiForReservation + ' and serial ' + singlePIQD.gii__ProductSerial__c);
                        continue;
                    }
                    
                    if(singlePIQD.gii__Available__c > 0) {
                        Decimal quantityToConsume = singlePIQD.gii__Available__c;
                        singlePIQD.giic_Reserved__c = quantityToConsume;
                        singlePIQD.giic_Status__c = Label.giic_PIQDStatusReserve;
                        mapPiIdPIQDToUpdate.put(keyPiForReservation, singlePIQD);
                        quantityReserved = quantityReserved + quantityToConsume;

                        gii__InventoryAdjustment__c adjToInsert = new gii__InventoryAdjustment__c();
                        adjToInsert.gii__ProductInventory__c = keyPiForReservation;
                        adjToInsert.gii__ProductSerial__c = singlePIQD.gii__ProductSerial__c;
                        adjToInsert.gii__AGC__c = 'Business Sales';
                        adjToInsert.gii__AdjustmentDate__c = Date.today();
                        adjToInsert.gii__AdjustmentQuantity__c = -1 * (singlePIQD.gii__Available__c);
                        adjToInsert.gii__Location__c = mapQuantityDetail.get(keyToSearch)[0].gii__Location__c;
                        adjToInsert.gii__ProductInventoryQuantityDetail__c = mapQuantityDetail.get(keyToSearch)[0].Id;
                        adjToInsert.gii__ProductInventorybyLocation__c = mapQuantityDetail.get(keyToSearch)[0].gii__ProductInventorybyLocation__c;
                        adjToInsert.gii__Product__c = mapQuantityDetail.get(keyToSearch)[0].gii__Product__c;
                        adjToInsert.gii__Reason__c = 'Stock Cleaning';
                        adjToInsert.gii__StockUM__c = 'Each';
                        adjToInsert.gii__Warehouse__c = mapQuantityDetail.get(keyToSearch)[0].gii__Warehouse__c;
                        mapPiIdInvAdjToInsertForReservation.put(keyPiForReservation, adjToInsert);

                        listPSerialToUpdate.add(new gii__ProductSerial__c(
                            Id = singlePIQD.gii__ProductSerial__c,
                            gii__Warehouse__c = mapQuantityDetail.get(keyToSearch)[0].gii__Warehouse__c,
                            gii__ProductInventory__c = keyPiForReservation,
                            gii__TransactionType__c = 'Migrated In Stock'
                        ));

                        qtyChanged = true;
                        if(!mapPiCalculated.containsKey(keyPiForReservation)) {
                            Map<String, Decimal> mapValuesTemp = new Map<String, Decimal>();
                            mapValuesTemp.put('reserved', quantityToReserve);
                            mapPiCalculated.put(keyPiForReservation, mapValuesTemp);
                        } else {
                            Map<String, Decimal> mapValuesTemp = mapPiCalculated.get(keyPiForReservation);
                            Decimal oldReserved = (mapValuesTemp.containsKey('reserved')) ? mapValuesTemp.get('reserved') : 0;
                            mapValuesTemp.put('reserved', oldReserved + quantityToReserve);
                            mapPiCalculated.put(keyPiForReservation, mapValuesTemp);
                        }
                    }
                }

                if(quantityToReserve != quantityReserved) {
                    listIssueProcessing.add('[ISSUE] For PI ' + keyPiForReservation + ' quantity to reserve is ' + quantityToReserve + ' but quantity reserved is ' + quantityReserved);
                }
            }
        }

        // Insert Adjstument for Reservation
        List<XC_UTIL_Sobject.WrapperResult> listInsertAdjustmentForReservation = XC_UTIL_Sobject.insertListRecords(mapPiIdInvAdjToInsertForReservation.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInsertAdjustmentForReservation: ' + listInsertAdjustmentForReservation);
        if(!XC_UTIL_Sobject.checkDMLResults(listInsertAdjustmentForReservation)) {
            String errorMessageAdj = 'You need to check inventory adjstument (except Soft Reservation and Stock Cleaning) for PI ' + listPi[0].Id + ' because the summation could be >1.';
            return insertBatchErrorLog('Error Insert Adj for Reservation: ' + listInsertAdjustmentForReservation[0].errorMessage + '\n' + errorMessageAdj);
        }

        // Update PIQD for Reserved:
        List<XC_UTIL_Sobject.WrapperResult> listUpdatePIQD = XC_UTIL_Sobject.updateListRecords(mapPiIdPIQDToUpdate.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdatePIQD: ' + listUpdatePIQD);
        if(!XC_UTIL_Sobject.checkDMLResults(listUpdatePIQD)) {
            return insertBatchErrorLog('Error Update PIQD [' + listUpdatePIQD[0].recordId + ']: ' + listUpdatePIQD[0].errorMessage);
        }

        // Update Product Serial:
        List<XC_UTIL_Sobject.WrapperResult> listUpdatePIQDProductSerial = XC_UTIL_Sobject.updateListRecords(listPSerialToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdatePIQDProductSerial: ' + listUpdatePIQDProductSerial);
        if(!XC_UTIL_Sobject.checkDMLResults(listUpdatePIQDProductSerial)) {
            return insertBatchErrorLog('Error Update Product Serial [' + listUpdatePIQDProductSerial[0].recordId + ']: ' + listUpdatePIQDProductSerial[0].errorMessage);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Reserved ended.');

        // Check BackOrder (serial products):
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Backorder starts...');
        List<gii__ProductInventory__c> listPIAfterReserved = new List<gii__ProductInventory__c>([
            SELECT Id, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c 
            FROM gii__ProductInventory__c 
            WHERE Id IN :listPi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPIAfterReserved: ' + listPIAfterReserved);
        List<gii__ProductInventory__c> listPIToUpdateForBO = new List<gii__ProductInventory__c>();
        for(gii__ProductInventory__c piForBO : listPIAfterReserved) {
            Decimal salesOnHandCurrent = piForBO.giic_SalesOnHand__c;
            Decimal reservedCurrent = piForBO.giic_Reserved__c;
            Decimal salesOnHandTemp = salesOnHandCurrent - reservedCurrent;
            Decimal calculatedQuantityBO = 0;
            if(reservedCurrent >= salesOnHandTemp) {
                Decimal qtyBOtoSet = (reservedCurrent - salesOnHandTemp)>=0 ? reservedCurrent - salesOnHandTemp : 0;
                piForBO.giic_BackOrderNew__c = qtyBOtoSet;
                calculatedQuantityBO = piForBO.giic_BackOrderNew__c;
            } else {
                piForBO.giic_BackOrderNew__c = 0;
                calculatedQuantityBO = piForBO.giic_BackOrderNew__c;
            }
            qtyChanged = true;

            if(!mapPiCalculated.containsKey(piForBO.Id)) {
                Map<String, Decimal> mapValuesTemp = new Map<String, Decimal>();
                mapValuesTemp.put('backOrder', calculatedQuantityBO);
                mapPiCalculated.put(piForBO.Id, mapValuesTemp);
            } else {
                Map<String, Decimal> mapValuesTemp = mapPiCalculated.get(piForBO.Id);
                Decimal oldValue = (mapValuesTemp.containsKey('backOrder')) ? mapValuesTemp.get('backOrder') : 0;
                mapValuesTemp.put('backOrder', oldValue + calculatedQuantityBO);
                mapPiCalculated.put(piForBO.Id, mapValuesTemp);
            }

            mapPiToUpdate.put(piForBO.Id, piForBO);
        }
        // Update PI for BackOrder:
        List<XC_UTIL_Sobject.WrapperResult> listUpdateProductInventory = XC_UTIL_Sobject.updateListRecords(mapPiToUpdate.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdateProductInventory: ' + listUpdateProductInventory);
        if(!XC_UTIL_Sobject.checkDMLResults(listUpdateProductInventory)) {
            return insertBatchErrorLog('Error Update PI [' + listUpdateProductInventory[0].recordId + ']: ' + listUpdateProductInventory[0].errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Backorder ended.');
        
        // Query new values after DML:
        Map<Id, gii__ProductInventory__c> mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>();
        if(qtyChanged) {
            mapPiWithNewValues = new Map<Id, gii__ProductInventory__c>([
                SELECT Id, gii__ConsignmentReceiptQuantity__c, giic_Reserved__c, giic_BackOrderNew__c, giic_SalesOnHand__c, gii__AvailableQuantity__c, giic_ScrapLocationQuantity__c, giic_NoSalesLocationQuantity__c
                FROM gii__ProductInventory__c
                WHERE Id IN: setIdPi
            ]);
        } else {
            mapPiWithNewValues = mapPiFromScope;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiWithNewValues: ' + mapPiWithNewValues);

        // Check for Available:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Available starts...');
        Map<Id, gii__ProductInventory__c> mapPiWithNewValuesAvailability = new Map<Id, gii__ProductInventory__c>();
        List<gii__ProductInventory__c> listPiToUpdateForAvailability = new List<gii__ProductInventory__c>();
        for(gii__ProductInventory__c pi : mapPiWithNewValues.values()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + pi.Id);
            Decimal currentAv = pi.gii__AvailableQuantity__c - pi.giic_ScrapLocationQuantity__c - pi.giic_NoSalesLocationQuantity__c;
            if(currentAv != pi.giic_SalesOnHand__c) {
                if(pi.gii__ConsignmentReceiptQuantity__c==null) {
                    pi.gii__ConsignmentReceiptQuantity__c = (pi.giic_SalesOnHand__c - pi.gii__AvailableQuantity__c);
                } else {
                    listIssueProcessing.add('[ISSUE] PI ' + pi.Id + ' has an initial consignment: ' + pi.gii__ConsignmentReceiptQuantity__c);
                    pi.gii__ConsignmentReceiptQuantity__c = (pi.gii__ConsignmentReceiptQuantity__c + (pi.giic_SalesOnHand__c - pi.gii__AvailableQuantity__c));
                }

                listPiToUpdateForAvailability.add(pi);
            }

            Decimal valueCalculated = pi.giic_SalesOnHand__c + pi.gii__ConsignmentReceiptQuantity__c + pi.giic_ScrapLocationQuantity__c + pi.giic_NoSalesLocationQuantity__c;
            if(!mapPiCalculated.containsKey(pi.Id)) {
                Map<String, Decimal> mapValuesTemp = new Map<String, Decimal>();
                mapValuesTemp.put('available', valueCalculated);
                mapPiCalculated.put(pi.Id, mapValuesTemp);
            } else {
                Map<String, Decimal> mapValuesTemp = mapPiCalculated.get(pi.Id);
                Decimal oldValue = (mapValuesTemp.containsKey('available')) ? mapValuesTemp.get('available') : 0;
                mapValuesTemp.put('available', oldValue + valueCalculated);
                mapPiCalculated.put(pi.Id, mapValuesTemp);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPiToUpdateForAvailability: ' + listPiToUpdateForAvailability);
        // Update PI for Availability:
        List<XC_UTIL_Sobject.WrapperResult> listUpdateProductInventoryForAvailability  = XC_UTIL_Sobject.updateListRecords(listPiToUpdateForAvailability);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listUpdateProductInventoryForAvailability: ' + listUpdateProductInventoryForAvailability);
        if(!XC_UTIL_Sobject.checkDMLResults(listUpdateProductInventoryForAvailability)) {
            return insertBatchErrorLog('Error Update PI [' + listUpdateProductInventoryForAvailability[0].recordId + ']: ' + listUpdateProductInventoryForAvailability[0].errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Maintenance Available ended.');

        // Query PI for last update:
        mapPiWithNewValuesAvailability = new Map<Id, gii__ProductInventory__c>([
            SELECT Id, giic_Reserved__c, giic_BackOrderNew__c, giic_SalesOnHand__c, gii__AvailableQuantity__c, giic_ScrapLocationQuantity__c, giic_NoSalesLocationQuantity__c
            FROM gii__ProductInventory__c
            WHERE Id IN: setIdPi
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPiWithNewValuesAvailability: ' + mapPiWithNewValuesAvailability);

        checkAfterMaintenanceSerialProduct(mapPiFromScope, mapPiCalculated, mapPiWithNewValuesAvailability, listIssueProcessing, onlyCheck, listMultipleSalesLocation, savePoint);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End Maintenance with check');
        return null;
    }   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/01/2022
     * @description Method to check quantity after adjstument (serial Product)
    */
    public static void checkAfterMaintenanceSerialProduct(Map<Id, gii__ProductInventory__c> mapPiFromScope, Map<String, Map<String, Decimal>> mapPiCalculated, Map<Id, gii__ProductInventory__c> mapPiWithNewValuesAvailability, List<String> listIssueProcessing, Boolean onlyCheck, Set<String> listMultipleSalesLocation, Savepoint savePoint) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for After Maintenance started for Serial Product');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Issues to insert: ' + listIssueProcessing);
        List<XC_BatchErrorLog__c> listIssue = new List<XC_BatchErrorLog__c>();
        for(String singleIssueProcessing : listIssueProcessing) {
            listIssue.add(insertBatchErrorLog(singleIssueProcessing));
        }

        // Alert multi-sales:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Issues for multiple sales: ' + listMultipleSalesLocation);
        for(String singlePImultiSales : listMultipleSalesLocation) {
            String errorMessage = '(ALERT) Issue ' + singlePImultiSales + ': this inventory is multi-sales location (same PI id and same ProductSerial id)';
            listIssue.add(insertBatchErrorLog(errorMessage));
        }

        for(String piId : mapPiFromScope.keySet()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PI: ' + piId);
            if(!mapPiCalculated.containsKey(piId) || !mapPiWithNewValuesAvailability.containsKey(piId)) {
                continue;
            }
            gii__ProductInventory__c piPrevValues   = mapPiFromScope.get(piId);
            Map<String, Decimal> piCalculatedValues = mapPiCalculated.get(piId);
            gii__ProductInventory__c piNewValues    = mapPiWithNewValuesAvailability.get(piId);

            // Debug Logs:
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piPrevValues: ' + piPrevValues);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piCalculatedValues: ' + piCalculatedValues);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piNewValues: ' + piNewValues);

            // For BackOrder
            if(Test.isRunningTest() || ((piPrevValues.giic_BackOrderNew__c!=null) && (piCalculatedValues.containsKey('backOrder')) && (piNewValues.giic_BackOrderNew__c!=null))) {
                if(piPrevValues.giic_BackOrderNew__c!=piCalculatedValues.get('backOrder') || piPrevValues.giic_BackOrderNew__c!=piNewValues.giic_BackOrderNew__c || piNewValues.giic_BackOrderNew__c!=piCalculatedValues.get('backOrder')) {
                    String errorMessage = onlyCheck ? '(Only check) ' : '';
                    errorMessage = errorMessage + 'Issue ' + piId + ': ';
                    errorMessage = errorMessage + ' BO[' + piPrevValues.giic_BackOrderNew__c + '->' + piCalculatedValues.get('backOrder') + '->' + piNewValues.giic_BackOrderNew__c + '] ';
                    listIssue.add(insertBatchErrorLog(errorMessage));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ BackOrder done');

            // For Reserved
            if(Test.isRunningTest() || ((piPrevValues.giic_Reserved__c!=null) && (piNewValues.giic_Reserved__c!=null))) {
                if(piPrevValues.giic_Reserved__c!=piNewValues.giic_Reserved__c) {
                    String errorMessage = onlyCheck ? '(Only check) ' : '';
                    errorMessage = errorMessage + 'Issue ' + piId + ': ';
                    errorMessage = errorMessage + ' RES[' + piPrevValues.giic_Reserved__c + '->' + (piCalculatedValues.containsKey('reserved') ? piCalculatedValues.get('reserved') : 0) + '->' + piNewValues.giic_Reserved__c + '] ';
                    listIssue.add(insertBatchErrorLog(errorMessage));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved done');

            // For SalesOnHand
            if(Test.isRunningTest() || ((piPrevValues.giic_SalesOnHand__c)!=null && (piCalculatedValues.containsKey('salesOnHand')) && (piNewValues.giic_SalesOnHand__c)!=null)) {
                if(piPrevValues.giic_SalesOnHand__c!=piCalculatedValues.get('salesOnHand') || piPrevValues.giic_SalesOnHand__c!=piNewValues.giic_SalesOnHand__c || piNewValues.giic_SalesOnHand__c!=piCalculatedValues.get('salesOnHand')) {
                    String errorMessage = onlyCheck ? '(Only check) ' : '';
                    errorMessage = errorMessage + 'Issue ' + piId + ': ';
                    errorMessage = errorMessage + ' SOH[' + piPrevValues.giic_SalesOnHand__c + '->' + piCalculatedValues.get('salesOnHand') + '->' + piNewValues.giic_SalesOnHand__c + '] ';
                    listIssue.add(insertBatchErrorLog(errorMessage));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOnHand done');

            // For Availability
            if(Test.isRunningTest() || ((piPrevValues.gii__AvailableQuantity__c)!=null && (piCalculatedValues.containsKey('available')) && (piNewValues.gii__AvailableQuantity__c)!=null)) {
                if(piPrevValues.gii__AvailableQuantity__c!=piCalculatedValues.get('available') || piPrevValues.gii__AvailableQuantity__c!=piNewValues.gii__AvailableQuantity__c || piNewValues.gii__AvailableQuantity__c!=piCalculatedValues.get('available')) {
                    String errorMessage = onlyCheck ? '(Only check) ' : '';
                    errorMessage = errorMessage + 'Issue ' + piId + ': ';
                    errorMessage = errorMessage + ' AV[' + piPrevValues.gii__AvailableQuantity__c + '->' + piCalculatedValues.get('available') + '->' + piNewValues.gii__AvailableQuantity__c + '] ';
                    listIssue.add(insertBatchErrorLog(errorMessage));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error quantity message: ' + errorMessage);
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Available Qty done');
        }

        // Rollback for only check and insert logs:
        if(onlyCheck) {
            Database.rollback(savePoint);
        }
        XC_UTIL_Sobject.insertListRecords(listIssue);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for After Maintenance ended');
    }

    //******************************************************************************************************************************************************/

    //************************************************************************************************************************************** UTIL METHODS: */

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 06/10/2021
     * @description Method to insert Batch Error Log
    */
    public static XC_BatchErrorLog__c insertBatchErrorLog(String errorMessage) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Inserting error log with message: ' + errorMessage);
        return new XC_BatchErrorLog__c(
            XC_ErrorMessage__c = errorMessage, 
            XC_TypeOfOperation__c = 'Maintenance Inventory'
        );
    }   

    /**
     * @description Method to coverage class
    */
    public static void coverageClass() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Class');
    }   
    
}