/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 25/07/2019
* @date Modification dd/mm/yyyy
* @description - Utility Class for Warehouse.
*/
public without sharing class Giic_WarehouseUtility {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_WarehouseUtility');
    public static String currentRecordId;
    public String currentRecordName='';
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @date Modification dd/mm/yyyy
    * @description - Constructor called from button on WH to calculate WH value.
    * @param controller - ApexPages.StandardController
    */ 
    public giic_WarehouseUtility(ApexPages.StandardController controller) {
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        currentRecordName=ApexPages.CurrentPage().getparameters().get('objectname');
    } 
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 25/07/2019
    * @date Modification dd/mm/yyyy
    * @description - To calculate the warehouse value for all the warehouses.
    * @param whList - List<gii__Warehouse__c> 
    */ 
    public static void calculateValueForWH(List<gii__Warehouse__c> whList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calculateValueForWH');
        CurrencyType defaultCurrency; 
        Map<String, Double> currencyRates  =  new Map <String, Double>(); 
        for(CurrencyType cRates : [SELECT ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE]) {
            currencyRates.put(cRates.IsoCode, cRates.ConversionRate);
            if(cRates.IsCorporate){
            	defaultCurrency = cRates;
            }
        }
        Map<String,gii__Warehouse__c> mapOfWHidVsWH = new Map<String,gii__Warehouse__c>(whList);
        AggregateResult[] listOfPIForWHVal;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            listOfPIForWHVal = [SELECT gii__Warehouse__c warehouseId,SUM(giic_Value__c)value FROM gii__ProductInventory__c 
                                WHERE gii__Warehouse__c IN: whList GROUP BY gii__Warehouse__c]; 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'listOfPIForWHVal------->>'+listOfPIForWHVal);        
        if(listOfPIForWHVal != null && !listOfPIForWHVal.isEmpty()){
            for(AggregateResult arObj : listOfPIForWHVal){
                if( mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).currencyISOCode == defaultCurrency.ISOCode){
                	mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).giic_WarehouseValue__c = (Decimal)arObj.get('value');
                }else{
                    mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).giic_WarehouseValue__c = Giic_ProductReference_UTIL.convertCurrency(defaultCurrency.ISOCode,mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).currencyISOCode,(Decimal)arObj.get('value'),currencyRates);
                }
            }
        }
        if(mapOfWHidVsWH != null && !mapOfWHidVsWH.values().isEmpty()){
            update mapOfWHidVsWH.values();
        }
    }
    
    
    
    public static PageReference calculateValueForWHPage(){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calculateValueForWHPage');
        List<gii__Warehouse__c> lstWH = new List<gii__Warehouse__c>();
        if(Schema.sObjectType.gii__Warehouse__c.isQueryable()){
            lstWH = [SELECT Id,giic_WarehouseValue__c,giic_StorageCapacity__c,CurrencyISOCode FROM gii__Warehouse__c WHERE Id=:currentRecordId];
        }
        calculateValueForWH(lstWH);
        PageReference pg = new PageReference('/'+ApexPages.CurrentPage().getparameters().get('id') );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'pg = '+pg);
        pg.setRedirect(true);
        return pg; 
    }
    
 
    @AuraEnabled
    public static void calculateValueForWHPage(String whId){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calculateValueForWHPage');
        List<gii__Warehouse__c> lstWH = new List<gii__Warehouse__c>();
        if(Schema.sObjectType.gii__Warehouse__c.isQueryable()){
            lstWH = [SELECT Id,giic_WarehouseValue__c,giic_StorageCapacity__c,CurrencyISOCode FROM gii__Warehouse__c WHERE Id=:whId];
        }
        giic_WarehouseUtility.calculateValueForWH(lstWH);
        // PageReference pg = new PageReference('/'+ApexPages.CurrentPage().getparameters().get('id') );
        //pg.setRedirect(true);
        // return pg; 
    }


       /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - Method called from action on WH record page to calculate WH value.
    * @param whId - Id of Warehouse
    */    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper calculateROP(String piID){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calculateROP');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        List<String> errorMessageList = new  List<String>();
        List<gii__ProductInventory__c> lstPI= new List<gii__ProductInventory__c> ([SELECT gii__Product__c, giic_LegalEntity__c, gii__Warehouse__r.gii__Account__c,gii__Product__r.gii__ProductCode__c,gii__Product__r.giic_EndDate__c,
                                                                                   gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c,
                                                                                   gii__Warehouse__r.gii__WarehouseGroup__c, gii__OrderQuantityMultiple__c, gii__AvailableQuantity__c,
                                                                                   gii__MinimumOrderQuantity__c,gii__TotalOnOrder__c,gii__Product__r.gii__PrimarySupplier__c, gii__OrderPointQuantity__c,
                                                                                   gii__Warehouse__r.giic_WarehouseType__c, gii__Warehouse__r.giic_ParentWarehouse__c,gii__Warehouse__c,gii__Product__r.gii__PlanningPolicy__c,
                                                                                   gii__Warehouse__r.gii__WareHouseCountry__c, gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c  
                                                                                   FROM gii__ProductInventory__c 
                                                                                   WHERE gii__Product__r.gii__PlanningPolicy__c= :Label.giic_PlanningPolicy
                                                                                   AND gii__OrderPointQuantity__c != null 
                                                                                   AND gii__OrderPointQuantity__c!= 0
                                                                                   AND Id = :piID]);
         XC_UTIL_Debug.debug(DEBUGACTIVE,'lstPI = '+lstPI);
        if(!lstPI.isEmpty()){
            if(lstPI[0].gii__Warehouse__r.giic_WarehouseType__c == Label.giic_WarehouseTypeLocal ){
               errorMessageList = giic_TransferOrderUtility.runROPForLocalWarehouse(lstPI); 
                 if(!errorMessageList.isEmpty()){ return populateErrorWrapper(errorMessageList[0]); }
            }else if(lstPI[0].gii__Warehouse__r.giic_WarehouseType__c == Label.giic_WarehouseTypeCentral){
                
               errorMessageList = giic_PurchaseOrderUtility.runROPForCentralWarehouse(lstPI); 
                if(!errorMessageList.isEmpty()){ return populateErrorWrapper(errorMessageList[0]); }
                
            }else{ rw = populateErrorWrapper('Warehouse type is different from Local or Central'); }
        }else{ rw = populateErrorWrapper('Missing mandatory fields : OrderPointQuantity , PlanningPolicy'); }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Exit calculateROP con rw: '+rw);
		return rw;        
    }
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - get all warehouses for warehouse network
    * @param setWarehouseGroupIds - set<Id>
    * @return list<gii__Warehouse__c>
    */   
    public static list<gii__Warehouse__c> getAllWarehousesForNetwork(set<Id> setWarehouseGroupIds){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'IN getAllWarehousesForNetwork');
        List<gii__Warehouse__c> lstWH = new List<gii__Warehouse__c>();
        if(Schema.sObjectType.gii__Warehouse__c.isQueryable()){
            lstWH = [SELECT Id,gii__WarehouseGroup__c,giic_WarehouseType__c,
                     gii__DefaultIssueLocation__c FROM gii__Warehouse__c WHERE gii__WarehouseGroup__c in :setWarehouseGroupIds ORDER BY giic_WarehouseType__c desc]; 
        }
        return lstWH;
    }
    
    
    
    public static XC_UTIL_ResultWrapper populateErrorWrapper(String message){
    	XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        rw.resultMessage = message;
        return rw;
        
    }
    
    
    
}