/**
* @author FirstName : Pradeep Kumar
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description - all inventory related query  for PI,PIBL and PIQD
*/

public without sharing class Giic_InventoryUtility_D {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_InventoryUtility_D');

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - return all PIQD for the warehouse, product and location
    * @param setWarehouseIds set of warehouse id
    * @param setProductIds set of product reference id
    * @param setLocationIds set of location ids
    * @return list<gii__ProductInventoryQuantityDetail__c>
    */
    public static list<gii__ProductInventoryQuantityDetail__c> getPIQD(set<Id> setWarehouseIds,set<Id> setProductIds,set<Id> setLocationIds){
        List<gii__ProductInventoryQuantityDetail__c> piqdList = new List<gii__ProductInventoryQuantityDetail__c>([
            SELECT Id,gii__Product__c,gii__Product__r.gii__PrimarySupplier__c, gii__Product__r.giic_EndDate__c, gii__Location__c, gii__Location__r.giic_LocationType__c,
            gii__Warehouse__c,gii__ProductInventory__c,gii__Warehouse__r.gii__Account__c,gii__Available__c,gii__ProductInventory__r.giic_BackOrderNew__c 
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE   gii__Location__c in: setLocationIds 
                    AND gii__Product__c in :setProductIds 
                    AND gii__Warehouse__c in :setWarehouseIds
                    AND gii__OnHandQuantity__c > 0
        ]);
        return piqdList;
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - return all PI for the warehouse, product and location
    * @param setWarehouseIds set of warehouse id
    * @param setProductIds set of product reference id
    * @return list<gii__ProductInventory__c>
    */
	public static list<gii__ProductInventory__c> getPIForStockAvailability(set<Id> setWarehouseIds,set<Id> setProductIds){
       list<gii__ProductInventory__c> piqdList = new list<gii__ProductInventory__c>([SELECT Id,gii__Product__c,gii__Product__r.giic_EndDate__c, gii__Product__r.giic_ProcurementType__c, gii__TotalOnOrder__c,
                                                                                     gii__OrderPointQuantity__c,giic_SalesOnHand__c,gii__Warehouse__c, gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                                                     giic_BackOrderNew__c , giic_AvgTransferTime__c ,gii__Product__r.gii__PrimarySupplier__c ,  gii__Product__r.Name, gii__Product__r.gii__ProductCode__c
                                                                                     FROM gii__ProductInventory__c 
                                                                                     WHERE gii__Product__c in :setProductIds 
                                                                                     AND gii__Warehouse__c in :setWarehouseIds
                                                                                    ]);
        
        return piqdList;
    }
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - return all PI for the warehouse, product 
    * @param setWarehouseIds set of warehouse id
    * @param setProductIds set of product reference id
    * @return list<gii__ProductInventoryQuantityDetail__c>
    */
	public static list<gii__ProductInventory__c> getProductInventory(set<string> setWarehouseIds,set<string> setProductIds){
       if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            return [SELECT Id,giic_MaxQuantity__c,giic_OnHandNew__c,Name,gii__Product__c,gii__AvailableQuantity__c,gii__TotalOnOrder__c,gii__Warehouse__c,gii__Warehouse__r.giic_WarehouseType__c ,gii__BackOrderQuantity__c From gii__ProductInventory__c WHERE gii__Warehouse__c IN: setWarehouseIds AND gii__Product__c IN: setProductIds];
       }
       return null;
    }
     /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - return available qty for product inventory
    * @param setPIIds set of product inventory id
    * @return map<string,integer>
    */
    public static  map<string,integer>  getAvailQtyFromPIBL(set<Id> setPIIds){
        map<string,integer> mapPRODWHLOCWithAvailQty=new map<string,integer>();
        
        AggregateResult[] groupedResults;
        if(Schema.sObjectType.gii__ProductInventorybyLocation__c.isQueryable()){
            groupedResults  = [SELECT gii__Location__c loc,gii__Product__c prod,gii__Warehouse__c wh, sum(gii__AvailableQuantity__c) availQty
                               FROM gii__ProductInventorybyLocation__c where gii__ProductInventory__c in :setPIIds 
                               GROUP BY gii__Location__c,gii__Product__c,gii__Warehouse__c];   
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'groupedResults------->>'+groupedResults); 
        for (AggregateResult ar : groupedResults)  {
            string key=(string)ar.get('prod') + '-' + (string)ar.get('wh')+ '-' + (string)ar.get('loc');
            if(ar.get('availQty') != null){
                mapPRODWHLOCWithAvailQty.put(key,integer.valueof(ar.get('availQty') ));   
            }
        }
        return mapPRODWHLOCWithAvailQty;
    }
     /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - return available qty for product+warehouse+location in map
    * @param setWarehouseIds set of warehouse id
    * @param setProductIds set of product reference id
    * @param setLocationIds set of location ids
    * @return map<string,integer>
    */
    public static  map<string,integer>  getAvailQtyFromPIBL(set<Id> setWarehouseIds,set<Id> setProductIds,set<id> setLocationIds){
        map<string,integer> mapPRODWHLOCWithAvailQty=new map<string,integer>();
        AggregateResult[] groupedResults;
        if(Schema.sObjectType.gii__ProductInventorybyLocation__c.isQueryable()){
            groupedResults = [SELECT gii__Location__c loc,gii__Product__c prod,gii__Warehouse__c wh, sum(gii__AvailableQuantity__c) availQty FROM gii__ProductInventorybyLocation__c where gii__Location__c in :setLocationIds and gii__Warehouse__c in: setWarehouseIds and  gii__Product__c in :setProductIds GROUP BY gii__Location__c,gii__Product__c,gii__Warehouse__c];
        }
        for (AggregateResult ar : groupedResults)  {
            string key=(string)ar.get('prod') + '-' + (string)ar.get('wh')+ '-' + (string)ar.get('loc');
            if(ar.get('availQty') != null){
                mapPRODWHLOCWithAvailQty.put(key,integer.valueof(ar.get('availQty') ));
            }
        }
        return mapPRODWHLOCWithAvailQty;
    }
    
}