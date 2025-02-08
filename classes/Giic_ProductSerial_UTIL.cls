public without sharing class Giic_ProductSerial_UTIL {
    
     
    public static void setProductInventoryOnPS(List<gii__ProductSerial__c> listNew){
        System.debug( 'listNew: ' + listNew);
        List<String> receiptIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__InventoryAdjustment__c');
        map<Id,gii__InventoryAdjustment__c> receiptMap = new map<Id,gii__InventoryAdjustment__c>([SELECT Id, gii__ProductInventory__c,gii__Warehouse__c,gii__Location__c 
                                                                                                  FROM gii__InventoryAdjustment__c  
                                                                                                  WHERE Id IN: receiptIds
                                                                                                  AND gii__Reason__c = 'Soft Reservation' 
                                                                                                  AND gii__AdjustmentQuantity__c < 0]);
        if(receiptMap.values().isEmpty()){
            return;
        }
        
        for(gii__ProductSerial__c p : listNew){
            if(receiptMap.containsKey(p.gii__InventoryAdjustment__c)) {
           	 if(p.gii__InventoryAdjustment__c !=null && p.gii__ProductInventory__c==null && receiptMap.get(p.gii__InventoryAdjustment__c).gii__ProductInventory__c!=null && p.giic_StatusCode__c != 'Installed'){
            	    p.gii__ProductInventory__c = receiptMap.get(p.gii__InventoryAdjustment__c).gii__ProductInventory__c;
                	p.gii__Warehouse__c = receiptMap.get(p.gii__InventoryAdjustment__c).gii__Warehouse__c;
            	   // p.gii__Location__c = receiptMap.get(p.gii__InventoryAdjustment__c).gii__Location__c;
            	}
            }
        } 
   } 
    
    
    
     public static void populateInstallationDate(List<gii__ShipmentDetail__c> psList ){
         List<gii__ProductSerial__c> serialsToUpdate = new List<gii__ProductSerial__c>();
         List<String> serialIds = XC_UTIL_Sobject.getListFieldValues(psList, 'gii__ProductSerial__c');
         Map<id,gii__ProductSerial__c> prodSerList = new Map<Id,gii__ProductSerial__c>([SELECT Id,gii__InventoryAdjustment__r.gii__Reason__c,giic_FirstInstallationDate__c,gii__SalesOrder__r.giic_WorkOrder__r.EndDate,
                                                                                        giic_OwnedByEnelX__c,gii__TransactionType__c,giic_StatusCode__c,giic_LastInstallationDate__c
                                                                                        FROM gii__ProductSerial__c
                                                                                        WHERE id IN:serialIds]); 
         for(gii__ShipmentDetail__c ps : psList){    
             if(ps.gii__ProductSerial__c != null && prodSerList.containskey(ps.gii__ProductSerial__c) ){
                 system.debug('### dentro IF transaction' );
                 if(prodSerList.get(ps.gii__ProductSerial__c).giic_FirstInstallationDate__c == null ){ 
                     system.debug('### dentro IF giic_FirstInstallationDate__c' ); 
                     gii__ProductSerial__c psNew = new gii__ProductSerial__c();
                     psNew.id = ps.gii__ProductSerial__c;
                     psNew.giic_FirstInstallationDate__c = Date.valueof(prodSerList.get(ps.gii__ProductSerial__c).gii__SalesOrder__r.giic_WorkOrder__r.EndDate);   
                     serialsToUpdate.add(psNew);
                 }else if(prodSerList.get(ps.gii__ProductSerial__c).giic_FirstInstallationDate__c != null &&  prodSerList.get(ps.gii__ProductSerial__c).giic_LastInstallationDate__c == null){ 
                     gii__ProductSerial__c psNew = new gii__ProductSerial__c();
                     psNew.id = ps.gii__ProductSerial__c;
                     psNew.giic_LastInstallationDate__c = Date.valueof(prodSerList.get(ps.gii__ProductSerial__c).gii__SalesOrder__r.giic_WorkOrder__r.EndDate);   
                     serialsToUpdate.add(psNew);
                 }
             }
        } 
        XC_UTIL_Sobject.updateListRecords(serialsToUpdate);
    }

/**
* @author FirstName : Alberto Pompei alberto.pompei@nttadata.com
* @date Creation 21/06/2021
* @date Modification dd/mm/yyyy
* @description - Duplicate rule on gii__ProductSerial__c
* @param listNew -  List of gii__ProductSerial__c
*/

    public static void pSDuplicationRule(List<gii__ProductSerial__c> pSList){
        map<id,String> prodToSerial = new map<id,String>();
        for(gii__ProductSerial__c p : pSList){
            prodToSerial.put(p.gii__Product__c, p.Name );
        }
        map<Id,gii__ProductSerial__c> pSMap = new map<Id,gii__ProductSerial__c>([SELECT Id, Name, gii__Product__c FROM gii__ProductSerial__c WHERE gii__Product__c IN: prodToSerial.keySet() AND Name IN: prodToSerial.values()]);
        if(!pSMap.values().isEmpty()){
            for(gii__ProductSerial__c pSOld : pSMap.values()){
                for(gii__ProductSerial__c pSNew : pSList){
                    if(psNew.gii__Product__c != null && pSNew.gii__Product__c == pSOld.gii__Product__c && pSNew.Name == pSOld.Name){
                        pSNew.addError('A Product Serial for this Product already exists');
                    }
                }
            }
        }
    }

    public static void checkSerialDuplicate(List<gii__ProductSerial__c> pSList, Map<id,gii__ProductSerial__c> psMapNew, Map<id,gii__ProductSerial__c> psMapOld){
        list<String> fieldsToCheck = new List<string>{'Name', 'gii__Product__c'};
        list<gii__ProductSerial__c> listPsChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, psMapOld, psMapNew);

        if(listPsChanged.size() > 0){
            pSDuplicationRule(listPsChanged);
        }
    }
}