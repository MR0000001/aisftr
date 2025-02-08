/** 
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 02/09/2019
* @description Class of future methods for integration with glovia
*/
public without sharing class giic_UTIL_CheckInventory_D{

    
/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param prodCode
* @return  Map<Id,gii__Product2Add__c>
* @description getProductRef
*/  
    public static Map<Id,gii__Product2Add__c> getProductRef(List<String> prodCode){ 
       return new Map<Id,gii__Product2Add__c>([SELECT Id,gii__ProductCode__c,gii__SerialControlled__c 
                                                                                    FROM gii__Product2Add__c 
                                                                                    WHERE gii__ProductCode__c IN :prodCode]);
    }

/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param prodCode
* @param eanCode
* @return  Map<Id,gii__Product2Add__c>
* @description getProductRef
*/  
    public static Map<Id,gii__Product2Add__c> getProductRef(List<String> prodCode, List<String> eanCode){ 
       return new Map<Id,gii__Product2Add__c>([SELECT Id,gii__ProductCode__c,gii__SerialControlled__c ,giic_EANReference__c, gii__LotControlled__c, giic_SKUCode__c
                                                                                    FROM gii__Product2Add__c 
                                                                                    WHERE gii__ProductCode__c IN :prodCode 
                                                                                    OR gii__ProductCode__c IN :eanCode]);
    }
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param prodCode
* @param eanCode
* @return  Map<Id,gii__Product2Add__c>
* @description getProductRef
*/  
    public static Map<Id,gii__Product2Add__c> getProductRef(List<String> prodCode, List<String> eanCode, List<String> skuCode){ 
       return new Map<Id,gii__Product2Add__c>([SELECT Id,gii__ProductCode__c,gii__SerialControlled__c ,giic_EANReference__c, gii__LotControlled__c, giic_SKUCode__c
                                                                                    FROM gii__Product2Add__c 
                                                                                    WHERE gii__ProductCode__c IN :prodCode 
                                                                                    OR gii__ProductCode__c IN :eanCode OR
                                              giic_skuCode__c IN: skuCode]);
    }
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param locationTo
* @return  Map<Id,gii__Location__c>
* @description getLocations
*/  
    public static Map<Id,gii__Location__c> getLocations(List<String> locationTo){ 
       return new Map<Id,gii__Location__c>([SELECT Id,Name 
                                            FROM gii__Location__c
                                            WHERE Name IN :locationTo]);
    }
    
      public static Map<Id,gii__Location__c> getLocationsByWH(List<String> locationTo, List<String> whCodeList){ 
       return new Map<Id,gii__Location__c>([SELECT Id,Name 
                                            FROM gii__Location__c
                                            WHERE Name IN :locationTo and gii__warehouse__r.giic_WarehouseCode__c IN: whCodeList]);
    }
/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param warehouseCode
* @param locations
* @return  Map<Id,gii__Warehouse__c>
* @description getWarehouse
*/  
    public static Map<Id,gii__Warehouse__c> getWarehouse(List<String> warehouseCode,List<String> locations){ 
       return new Map<Id,gii__Warehouse__c>([SELECT Id,giic_WarehouseCode__c ,
                                                                           (SELECT Id,Name 
                                                                            FROM gii__Locations__r
                                                                            WHERE Name IN :locations)
                                                                           FROM gii__Warehouse__c 
                                                                           WHERE giic_WarehouseCode__c IN :warehouseCode]);
    }
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param serialName
* @param prodCode
* @return  List<gii__ProductSerial__c>
* @description getSerial
*/  
    public static List<gii__ProductSerial__c> getSerial(List<String> serialName,List<String> prodCode){ 
       return new List<gii__ProductSerial__c>([SELECT Id ,Name,gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c
                                                                                    FROM gii__ProductSerial__c 
                                                                                    WHERE Name IN :serialName 
                                                                                    AND gii__Product__r.gii__ProductCode__c in :prodCode]); 
    }
    
        /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param serialName
* @param prodCode
* @return  List<gii__ProductSerial__c>
* @description getSerial
*/  
    public static List<gii__ProductLot__c> getLot(List<String> lotName,List<String> prodCode){ 
       return new List<gii__ProductLot__c>([SELECT Id ,Name,gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c
                                                                                    FROM gii__ProductLot__c 
                                                                                    WHERE Name IN :lotName 
                                                                                    AND gii__Product__r.gii__ProductCode__c in :prodCode]); 
    }
        /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param Ids
* @return  List<gii__ProductSerial__c>
* @description getSerialFromId
*/  
    public static List<gii__ProductSerial__c> getSerialFromId(List<String> ids){ 
       return new List<gii__ProductSerial__c>([SELECT Id ,Name,gii__Product__r.gii__ProductCode__c,gii__Product__r.giic_EANReference__c
                                                                                    FROM gii__ProductSerial__c 
                                                                                    WHERE Id IN :ids 
                                                                                   ]); 
    }
    
           /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param Ids
* @return  List<gii__ProductSerial__c>
* @description getSerialFromId
*/  
    public static List<gii__ProductLot__c> getLotFromId(List<String> ids){ 
       return new List<gii__ProductLot__c>([SELECT Id ,Name,gii__Product__r.gii__ProductCode__c,gii__Product__r.giic_EANReference__c
                                                                                    FROM gii__ProductLot__c 
                                                                                    WHERE Id IN :ids 
                                                                                   ]); 
    }
    
        /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param warehouseCode
* @param locations
* @param prodCode
* @return  List<gii__ProductInventoryQuantityDetail__c>
* @description getSerial
*/  
    public static List<gii__ProductInventoryQuantityDetail__c> getPIQD(List<String> warehouseCode,List<String> locations,List<String> prodCode){ 
        System.debug('Entrato in getPIQD con '+warehouseCode+' '+locations+' '+prodCode);
       return new List<gii__ProductInventoryQuantityDetail__c>([SELECT Id, gii__Location__c ,gii__Product__r.gii__ProductCode__c,gii__ProductSerial__r.Name,gii__ProductLot__c,
                                                                gii__ProductLot__r.Name,gii__Warehouse__r.giic_WarehouseCode__c,gii__Location__r.Name,gii__ProductSerial__c,
                                                                gii__Product__c,gii__Warehouse__c,gii__ProductInventory__c
                                                                FROM gii__ProductInventoryQuantityDetail__c
                                                                WHERE gii__Product__r.gii__ProductCode__c IN: prodCode  
                                                                AND gii__Warehouse__r.giic_WarehouseCode__c IN: warehouseCode 
																AND gii__Location__r.Name  IN: locations]);
    }
    
        /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param warehouseCode
* @param locations
* @param prodCode
* @return  Map<Id,gii__ProductInventory__c>
* @description getSerial
*/  
    public static  Map<Id,gii__ProductInventory__c> getProductInventory(List<String> warehouseCode,List<String> locations,List<String> prodCode){ 
       return new Map<Id,gii__ProductInventory__c>([SELECT Id ,gii__Product__r.gii__ProductCode__c, gii__Warehouse__r.giic_WarehouseCode__c,
                                                                                                (SELECT giic_Reserved__c,giic_Status__c,
                                                                                                gii__MovableQuantity__c,gii__ProductSerial__c,gii__ProductSerial__r.Name,
                                                                                                gii__Product__r.gii__ProductCode__c, 
                                                                                                gii__Warehouse__r.giic_WarehouseCode__c,
                                                                                                gii__LotRestricted__c, gii__ProductInventory__c, 
                                                                                                gii__ProductInventorybyLocation__c, 
                                                                                                gii__OnHandQuantity__c,gii__BlockedQuantity__c,
                                                                                                gii__Available__c,gii__Location__c,gii__Location__r.Name,
                                                                                                gii__Warehouse__c,gii__Product__c,
                                                                                                gii__ProductLot__c,gii__ProductLot__r.Name
                                                                                                FROM gii__ProductInventoryQuantityDetails__r
                                                                                                WHERE gii__Location__r.Name  IN: locations)
                                                                                                FROM gii__ProductInventory__c 
                                                                                                WHERE gii__Product__r.gii__ProductCode__c IN: prodCode  
                                                                                                AND gii__Warehouse__r.giic_WarehouseCode__c IN: warehouseCode 
                                                                                                ]);
    }
}