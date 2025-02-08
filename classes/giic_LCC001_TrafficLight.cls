/**
* @author FirstName : LORENZO ORLANDUCCI
* @date Creation 11/11/2019
* @date Modification dd/mm/yyyy
* @description - */

public without sharing class giic_LCC001_TrafficLight {

private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_LCC001_TrafficLight');    
    
 /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Check SO indicator.
    *@param recordId the record id
    *@param objectName
    *@return the XC_UTIL_Result_Wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper setTrafficLight(String recordId,String objectName){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'In setTrafficLight');
        if(objectName=='gii__SalesOrder__c'){
            return setTrafficLightOnSO(recordId);
        }else{
            return setTrafficLightOnSOLine(recordId);
        }
        
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Check SO indicator.
    *@param recordId the record id
    *@return the XC_UTIL_Result_Wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper setTrafficLightOnSO(String recordId){
    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in setTrafficLightOnSO con recordId = '+recordId);
         Integer foundGreen = 0;
         Integer foundYellow = 0;
         Integer foundRed = 0;
         XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
         rw.success = false; 
         gii__SalesOrder__c salesOrder = new gii__SalesOrder__c();
         Map<Id,gii__SalesOrder__c> soMap = new Map<Id,gii__SalesOrder__c>([SELECT Id, gii__Warehouse__c, gii__Warehouse__r.giic_WarehouseType__c, gii__DropShip__c, (SELECT Id,gii__OrderQuantity__c,gii__Product__c,gii__ProductInventory__c,gii__ProductInventory__r.gii__AvailableQuantity__c,gii__ProductInventory__r.giic_OnHandNew__c,
                                                                                                           gii__ProductInventory__r.giic_Reserved__c,gii__ProductInventory__r.giic_SalesOnHand__c,gii__ProductInventory__r.gii__InTransitQuantity__c,gii__ProductInventory__r.gii__SalesOrderQuantity__c FROM gii__SalesOrder__r)
         																								   FROM gii__SalesOrder__c WHERE Id =: recordId LIMIT 1]); 
         if(!(soMap.values()).isEmpty()){
         	salesOrder = soMap.values()[0];
             if(salesOrder.gii__Warehouse__r.giic_WarehouseType__c == 'Virtual'){
                  rw.success = true;
                  rw.resultMessage = 'notraffic';
                  System.debug('return notraffic');
                  return rw;
                 
             }
             
             List<gii__SalesOrderLine__c> soLines = salesOrder.gii__SalesOrder__r;   
             
             if(!soLines.isEmpty()){
             rw.success = true;
             for(gii__SalesOrderLine__c sol : soLines){
               
                 if(sol.gii__OrderQuantity__c > (sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c )){
                     foundRed++;
                     rw.resultMessage = 'red';
                     break;
                     return rw;
                 }
                 if(sol.gii__ProductInventory__r.gii__SalesOrderQuantity__c <=(sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c )
                    && sol.gii__OrderQuantity__c <=(sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c )){
                     foundGreen++;
                 }
                 if((sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c ) < sol.gii__ProductInventory__r.gii__SalesOrderQuantity__c){
                     foundYellow++;
                     rw.resultMessage = 'yellow';
                     
                 }
             }
             }else{
                  rw.success = true;
                  rw.resultMessage = 'notraffic';
                  System.debug('return notraffic');
                  return rw;
                 
             }
             
             if(foundGreen == soLines.size()){
                 rw.success = true;
                 rw.resultMessage = 'green';
             }
             
         }       
         System.debug('rw = '+rw);
         return rw;
    }
    
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Check SOLine indicator.
    *@param recordId the record id
    *@return the XC_UTIL_Result_Wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper setTrafficLightOnSOLine(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true; 
        Map<Id,gii__SalesOrderLine__c> solMap = new Map<Id,gii__SalesOrderLine__c>([SELECT Id,gii__Product__c,gii__salesOrder__r.gii__DropShip__c, gii__salesOrder__r.gii__Warehouse__r.giic_WarehouseType__c, gii__ProductInventory__r.giic_Reserved__c,gii__ProductInventory__c,gii__OrderQuantity__c,gii__ProductInventory__r.gii__AvailableQuantity__c,
                                                                                   gii__ProductInventory__r.gii__InTransitQuantity__c,gii__ProductInventory__r.giic_SalesOnHand__c,gii__ProductInventory__r.gii__SalesOrderQuantity__c, gii__ProductInventory__r.giic_OnHandNew__c FROM gii__SalesOrderLine__c
                                                                                   WHERE Id =: recordId LIMIT 1]);
         gii__SalesOrderLine__c sol = solMap.values()[0];
        
         if(sol.gii__salesOrder__r.gii__Warehouse__r.giic_WarehouseType__c == 'Virtual'){
                  rw.success = true;
                  rw.resultMessage = 'notraffic';
                  return rw;
         }
        
         if(sol.gii__OrderQuantity__c > (sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c )  ){
                     rw.resultMessage = 'red';
               		 return rw;
         }else{
         	if(sol.gii__OrderQuantity__c <= (sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c ) && 
               sol.gii__ProductInventory__r.gii__SalesOrderQuantity__c <= (sol.gii__ProductInventory__r.giic_SalesOnHand__c + sol.gii__ProductInventory__r.giic_Reserved__c ) ){
                     rw.resultMessage = 'green';
         	}else { 
                rw.resultMessage = 'yellow';}
            }
        
         return rw;
    }
    
    
}