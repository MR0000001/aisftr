/**
* @author FirstName : pradeep kumar pradeep.p.kumar@in.fujitsu.com
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_ReceiptUtility – Utility class for all receipt
*/
public with sharing class Giic_ReceiptUtility {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_ReceiptUtility');
	/**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/08/2019
    * @date Modification dd/mm/yyyy
    * @description  to update back order qty on PI and do the reservation for back order qty
    * @param lstReceipt - list of Receipt
    */
    public static void clearBackOrderQtyOnPI(List<gii__Receipt__c > lstReceipt){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Called ----- clearBackOrderQtyOnPI'+lstReceipt);
        if(lstReceipt != null && !lstReceipt.isEmpty()){
            map<Id,gii__ProductInventory__c> mapProductInventory=new map<Id,gii__ProductInventory__c>();
            map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new map<string,giic_ReservationUtility.ReservationWrapper>();
            for(gii__Receipt__c receipt : [SELECT id, gii__ReceiptQuantity__c,gii__Warehouse__c, gii__Warehouse__r.gii__DefaultReceivingLocation__c,gii__ProductInventory__c,
                                                             gii__ProductInventory__r.gii__Product__c,gii__ProductInventory__r.giic_BackOrderNew__c, gii__ProductInventory__r.gii__WorkOrderQuantity__c
                                                             FROM  gii__Receipt__c 
                                                             WHERE  id in : lstReceipt and gii__ProductInventory__r.giic_BackOrderNew__c  > 0 and gii__OrderType__c='Transfer' and gii__Warehouse__c != null and gii__Warehouse__r.gii__DefaultReceivingLocation__c != null]){
              
				 if(!mapProductInventory.containsKey(receipt.gii__ProductInventory__c)){
                     mapProductInventory.put(receipt.gii__ProductInventory__c,new gii__ProductInventory__c(Id=receipt.gii__ProductInventory__c,giic_BackOrderNew__c=receipt.gii__ProductInventory__r.giic_BackOrderNew__c));
                 }
                 if(mapProductInventory.containsKey(receipt.gii__ProductInventory__c) && mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c > 0){
                        decimal reservedQty=getReservedQty(receipt,mapProductInventory);
                        //mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c=mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c -receipt.gii__ReceiptQuantity__c; 
                        mapRW=prepareReceiptReserveWrapper(receipt,reservedQty,mapRW);
                     
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'mapRW***'+mapRW);
            if(mapRW.size()>0)
            {
                giic_ReservationUtility.clearBackOrderQty(mapRW.values(),mapProductInventory);
            }
        }
        
    }
    /**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/08/2019
    * @date Modification dd/mm/yyyy
    * @description prepareReceiptReserveWrapper - return reserved quantity
    * @param receipt - receipt object
    * @param mapProductInventory - map of product inventory
    * @return decimal qty
    */
    public static decimal getReservedQty(gii__Receipt__c receipt,map<Id,gii__ProductInventory__c> mapProductInventory){
        decimal reservedQty=0;
        decimal woQty = receipt.gii__ProductInventory__r.gii__WorkOrderQuantity__c;
        system.debug('woQty: '+woQty);
        system.debug('receiptQty: '+ receipt.gii__ReceiptQuantity__c);
        woQty = woQty - receipt.gii__ReceiptQuantity__c;
        mapProductInventory.get(receipt.gii__ProductInventory__c).gii__WorkOrderQuantity__c = woQty; 
        if(mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c -receipt.gii__ReceiptQuantity__c >= 0){
            reservedQty= receipt.gii__ReceiptQuantity__c; 
            mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c=mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c -receipt.gii__ReceiptQuantity__c; 
            
        }
        else{
            reservedQty=mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c ; 
            mapProductInventory.get(receipt.gii__ProductInventory__c).giic_BackOrderNew__c=0; 
        }
        return reservedQty;
    }
    /**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/08/2019
    * @date Modification dd/mm/yyyy
    * @description  to update back order qty on PI and do the reservation for back order qty
    * @param receipt - object receipt
    * @param reservedQty reserved qty
    * @param mapRW - map of wrapper
    * @return map<string,giic_ReservationUtility.ReservationWrapper> map of reservation wrapper
    */
    public static map<string,giic_ReservationUtility.ReservationWrapper> prepareReceiptReserveWrapper(gii__Receipt__c receipt,
                                             decimal reservedQty,
                                             map<string,giic_ReservationUtility.ReservationWrapper> mapRW){
        string key=receipt.gii__Warehouse__c + '-' +  receipt.gii__ProductInventory__r.gii__Product__c + '-' +receipt.gii__Warehouse__r.gii__DefaultReceivingLocation__c; 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'key-------'+key);
        if(!mapRW.containsKey(key)){
            giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
            objRW.warehouseId = receipt.gii__Warehouse__c;
            objRW.Product = receipt.gii__ProductInventory__r.gii__Product__c;
            objRW.location =receipt.gii__Warehouse__r.gii__DefaultReceivingLocation__c;  
            objRW.qty = reservedQty;
            mapRW.put(key,objRW);
        }
        else{
            mapRW.get(key).qty += reservedQty;
        }
        return mapRW;
    }
    /**
    * @author FirstName : Shubee
    * @date Creation 01/09/2019
    * @date Modification dd/mm/yyyy
    * @description 
    
    public static map<Id,Boolean> getReadyToIntegrateReceipt(Map<Id, Sobject> mapOldS, 
                                                             Map<Id, Sobject> mapNewS){
        map<Id,Boolean> returnmap=new map<Id,Boolean>();
        Set<Id> updatePORasSuccess= new Set<Id>();
        for(gii__Receipt__c objPOR : (list<gii__Receipt__c>)mapNewS.values()){
            if(objPOR.giic_IntegrationStatus__c==System.Label.giic_TOIntegrationStatusReadyToIntegrate && objPOR.giic_TargetSystem__c==System.Label.giic_TargetSystemAFC
               &&objPOR.giic_IntegrationOperation__c==System.Label.giic_IntegrationOperationCreate && objPOR.giic_IntegrationStatus__c!=((gii__Receipt__c)mapOldS.get(objPOR.Id)).giic_IntegrationStatus__c){
                   updatePORasSuccess.add(objPOR.Id);
                   System.debug('****SentInfo*****');
               }
        }
       /* if(updatePORasSuccess.size()>0){
            returnmap=Giic_ClassforIntegrationtesting.getResponceforreceipt(updatePORasSuccess);
        }                                                        
        return returnmap; 
    }*/
    
            /**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description  method for changing PI Work Order Value based on new TOL qty
* @param lstReceipt - list of receipt
*/
    public static void changeQtyToWOPI(List<gii__Receipt__c > lstReceipt){
       XC_UTIL_Debug.debug(DEBUGACTIVE,'changeQtyToWOPI----------');
        Set<String> piSet = new Set<String>();
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
        
        for(gii__Receipt__c rcpt : lstReceipt){
            piSet.add(rcpt.gii__ProductInventory__c);
        }
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__WorkOrderQuantity__c,gii__Warehouse__c,gii__AvailableQuantity__c,giic_Reserved__c,giic_BackOrderNew__c FROM 
                                                                gii__ProductInventory__c WHERE Id IN: piSet]);   
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI----------'+mapOfIdVsPI.values());
        if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty() && Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI----------'+mapOfIdVsPI);
            for(gii__Receipt__c rcpt : lstReceipt){
                String key = rcpt.gii__ProductInventory__c;
                if(mapOfIdVsPI.containsKey(key)){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'containsKey----------'+key);
                    mapOfIdVsPI.get(key).gii__WorkOrderQuantity__c = mapOfIdVsPI.get(key).gii__WorkOrderQuantity__c != null ? mapOfIdVsPI.get(key).gii__WorkOrderQuantity__c : 0;
                    mapOfIdVsPI.get(key).gii__WorkOrderQuantity__c = mapOfIdVsPI.get(key).gii__WorkOrderQuantity__c - rcpt.gii__ReceiptQuantity__c;
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI----------'+mapOfIdVsPI.values());
            update mapOfIdVsPI.values();
        }
    }
    
    /*
    public static void populatePIOnProductSerial(List<gii__Receipt__c> lstReceipt){
        List<gii__ProductSerial__c> psToUpdate = new List<gii__ProductSerial__c>();
        for(gii__Receipt__c r : lstReceipt){
            System.debug('r.gii__ProductInventory__c = '+r.gii__ProductInventory__c);
            if(r.gii__ProductInventory__c!=null){
                gii__ProductSerial__c ps = new gii__ProductSerial__c(Id = r.gii__ProductSerial__c);
                ps.gii__ProductInventory__c = r.gii__ProductInventory__c;
                
                System.debug('r.gii__ProductSerial__c = '+r.gii__ProductSerial__c);
                psToUpdate.add(ps);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrList = XC_UTIL_DML.updateRecords(psToUpdate);
        System.debug('wrList = '+wrList);
        
    }    */
    
    
}