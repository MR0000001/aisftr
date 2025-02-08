/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 03/12/2019
* @date 
* @description Giic_TR_manageWarehouse – Util class that implements logic for Warehouse handler
*/  
public without sharing class Giic_TR_manageWarehouse {
    
    
     /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method
     * @param listNew - listNew-> new value of record
     * @param mapOld - map Id -> old value of record
     * @param mapNew - map Id -> new value of record
    */
   /* public static void checkOnlyOneWarehouseInUpdate(List<gii__Warehouse__c> listNew,Map<Id,gii__Warehouse__c> mapOld, Map<Id,gii__Warehouse__c> mapNew){
        List<String> fieldList = new List<String>{'gii__Account__c'};
        List<gii__Warehouse__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        checkOnlyOneWarehouse(listChanged);
    }
    */
         
   /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method
     * @param listNew - listNew-> new value of record
    */ 
   /* public static void checkOnlyOneWarehouse(List<gii__Warehouse__c> listNew){
        List<String> accountIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__Account__c');
        map<Id,Account> accMap = new map<Id,Account>([SELECT Id, Name, (SELECT Id FROM gii__Warehouses__r WHERE giic_WarehouseType__c != :Label.giic_WarehouseTypeCentral) FROM Account WHERE Id IN:accountIds]);
        for(Account a : accMap.values()){
            for(gii__Warehouse__c w : listNew){
                if(w.gii__Account__c == a.Id && !(a.gii__warehouses__r).isEmpty() ){
                    w.addError(Label.giic_CL_AccountOnWarehouseError); 
                } 
            }
        } 
    }*/

	/**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method
     * @param listNew - listNew-> new value of record
     * @param mapOld - map Id -> old value of record
     * @param mapNew - map Id -> new value of record
    */
     public static void setCorrectCountryInUpdate(List<gii__Warehouse__c> listNew, Map<Id,gii__Warehouse__c> mapOld, Map<Id,gii__Warehouse__c> mapNew){                      
        List<String> fieldList = new List<String>{'giic_wareHouseCountryPick__c'};
        List<gii__Warehouse__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        } 
        setCorrectCountry(listChanged);
    }
        
   /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method
     * @param listNew - listNew-> new value of record
    */ 
    public static void setCorrectCountry(List<gii__Warehouse__c> listNew){
        for(gii__Warehouse__c w : listNew){
            if(w.giic_wareHouseCountryPick__c!=null){
                w.gii__WareHouseCountry__c = w.giic_wareHouseCountryPick__c;
            }
        }
    }
    
}