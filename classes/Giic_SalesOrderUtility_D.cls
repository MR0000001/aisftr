/**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description - all sales order and sales order lines related queries
*/
public without sharing class Giic_SalesOrderUtility_D {
    /**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @param lstSOIds list of sales order ids
* @description - fetch all salesorder for the passed ids
* @return - list<gii__SalesOrder__c>
*/
    public static list<gii__SalesOrder__c> getSalesOrder(list<Id> lstSOIds){
        list<gii__SalesOrder__c> soList = new list<gii__SalesOrder__c>([SELECT id,gii__Warehouse__c,Name,gii__Warehouse__r.Name,giic_FromWarehouse__c,gii__Warehouse__r.giic_ParentWarehouse__c,
                      gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__Warehouse__r.gii__WareHouseCountry__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c,
                      gii__Account__c,gii__Warehouse__r.gii__WarehouseGroup__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c, 
                      gii__Warehouse__r.gii__Account__c , giic_LegalEntity__c,gii__Warehouse__r.giic_LegalEntity__c
                      FROM gii__SalesOrder__c
                      WHERE id in :lstSOIds]);
        
        return soList;
    }
    /**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @param setSOIds set of sales order ids
* @description - method will return sales order lines for the sales order Id passed as parameter
* @param list<gii__SalesOrderLine__c> list of sales order lines
* @return - list<gii__SalesOrderLine__c>
*/
    public static list<gii__SalesOrderLine__c> getSalesOrderLines(set<Id> setSOIds){
        list<gii__SalesOrderLine__c> lstSalesOrderLine = new list<gii__SalesOrderLine__c>([SELECT id,gii__SalesOrder__r.gii__RequiredDate__c,gii__Product__r.giic_EndDate__c,gii__Product__r.gii__ProductCode__c,
                                 gii__SalesOrder__r.giic_FromWarehouse__c, gii__SalesOrder__r.giic_IsDelivery__c,gii__SalesOrder__r.gii__Account__c,
                                 gii__SalesOrder__r.gii__ShipToCity__c,gii__SalesOrder__r.gii__ShipToCountry__c,gii__SalesOrder__r.gii__ShipToName__c,
                                 gii__SalesOrder__r.gii__ShipToStateProvince__c,gii__SalesOrder__r.gii__ShipToStreet__c,gii__SalesOrder__r.gii__ShipToZipPostalCode__c,
                                 gii__OrderQuantity__c,gii__Product__c,gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                 gii__Product__r.gii__PrimarySupplier__c,gii__SalesOrder__c,gii__Warehouse__r.gii__WareHouseCountry__c,gii__SalesOrder__r.giic_CUP__c,gii__SalesOrder__r.giic_CIG__c,
                                 gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c,gii__Product__r.giic_ProcurementType__c,gii__Warehouse__r.giic_LegalEntity__c,
                                 gii__Warehouse__r.gii__WarehouseGroup__c,gii__Warehouse__r.gii__Account__c,giic_ProductRequiredId__c,gii__Warehouse__c,
                                 gii__Warehouse__r.gii__DefaultIssueLocation__c  , gii__SalesOrder__r.giic_WorkOrder__c, gii__ProductInventory__r.giic_SalesOnHand__c,gii__SalesOrder__r.giic_LegalEntity__c, gii__Warehouse__r.giic_WarehouseType__c, gii__SalesOrder__r.gii__Warehouse__c,gii__SalesOrder__r.gii__DropShip__c, gii__SalesOrder__r.giic_PO_TO_LocalWH__c, gii__SalesOrder__r.giic_OrderStatus__c
                                 FROM gii__SalesOrderLine__c 
                                 WHERE gii__SalesOrder__c in :setSOIds]);
        
        return lstSalesOrderLine;
    }
    /**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @param salesOrderId sales order id
* @description - method will return sales order lines for the sales order Id passed as parameter
* @return list<gii__SalesOrderLine__c> for salesorder
*/
    public static list<gii__SalesOrderLine__c> getSalesOrderLines(Id salesOrderId){
        list<gii__SalesOrderLine__c> lstSalesOrderLine = new list<gii__SalesOrderLine__c>();
        if(Schema.sObjectType.gii__SalesOrderLine__c.isQueryable()){
            lstSalesOrderLine = [select id,gii__Warehouse__c, gii__OrderQuantity__c,giic_ProductRequiredId__c,gii__Warehouse__r.gii__WareHouseCountry__c,gii__Warehouse__r.giic_LegalEntity__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c,gii__Product__c,gii__SalesOrder__c,gii__SalesOrder__r.giic_OrderStatus__c,gii__SalesOrder__r.giic_FSLWorkOrder__c,
                                 gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__SalesOrder__r.giic_DirectPurchaseOrder__c,gii__SalesOrder__r.giic_LegalEntity__c,gii__SalesOrder__r.giic_WorkOrderLineItem__c, gii__SalesOrder__r.giic_WorkOrderLineItem__r.XC_IsMigrated__c from gii__SalesOrderLine__c where gii__SalesOrder__c =:salesOrderId];
        }
        return lstSalesOrderLine;
    }
    /**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @param lstSOIds list of sales order ids
* @description - fetch all salesorder for the passed ids
* @return - list<gii__SalesOrder__c>
*/    
      public static Map<Id,gii__SalesOrder__c> getSalesOrderFromComponent(Id lstSOIds){
       Map<Id,gii__SalesOrder__c> soList = new Map<Id,gii__SalesOrder__c>([SELECT Id,
                                                                        (SELECT Id FROM Transfer_Orders__r ),
                                                                        (SELECT Id FROM gii__Purchase_Orders__r )
                                                                        FROM gii__SalesOrder__c 
                                                                        WHERE id = :lstSOIds] );
        return soList;
    }
}