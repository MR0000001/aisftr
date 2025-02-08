/**
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 
* @date Modification 
* @description Giic_TR_ReturnToSupplierShip_UTIL – Utility to manage the RTS Shipment.
*/
public without sharing class Giic_TR_ReturnToSupplierShip_UTIL {
    
    
    public static void checkValidSerialNumber(List<gii__ReturntoSupplierLineShipment__c> listNew){
        
        map<id, gii__ReturntoSupplierLineShipment__c> RTSToLine= new Map<id, gii__ReturntoSupplierLineShipment__c>();
        
        map<id, Id> rmaToRTS = new  map<id, Id>();
        map<id, Id> rtsToRMA = new  map<id, Id>();
        for(gii__ReturntoSupplierLineShipment__c rt : listNew){
            RTSToLine.put(rt.gii__ReturntoSupplier__c,rt);
        }
        
        map<id, gii__ReturntoSupplier__c> idToRTS = new map<id, gii__ReturntoSupplier__c>([SELECT Id, giic_RMA__c
                                                                                           FROM gii__ReturntoSupplier__c WHERE Id IN: RTSToLine.keySet()]);
        
        
        for(gii__ReturntoSupplier__c rts: idToRTS.values()){
            if(rts.giic_RMA__c != null){
                rmaToRTS.put(rts.giic_RMA__c, rts.Id);
                rtsToRMA.put(rts.Id,rts.giic_RMA__c);
            }
        }
         
        map<id, gii__RMADisposition__c> idToRMADisp = new map<id, gii__RMADisposition__c>([SELECT Id, gii__RMAReceipt__r.gii__RMA__c, gii__DispositionLocation__r.giic_LocationType__c,
                                                                                           gii__ProductSerial__c,gii__ProductLot__c , gii__Product__r.gii__SerialControlled__c,
                                                                                           gii__Product__r.gii__LotControlled__c
                                                                                           FROM gii__RMADisposition__c 
                                                                                           WHERE gii__RMAReceipt__r.gii__RMA__c IN:rmaToRTS.keySet() 
                                                                                           AND gii__DispositionLocation__r.giic_LocationType__c != :Label.giic_LocationTypeSales 
                                                                                           AND gii__DispositionLocation__r.giic_LocationType__c != :Label.giic_CL_VanLocation]);
        
        
        for(gii__ReturntoSupplierLineShipment__c rt : listNew){
            Boolean foundS = false;
            if(rtsToRMA.containsKey(rt.gii__ReturntoSupplier__c)){
                
                for(gii__RMADisposition__c rmaD : idToRMADisp.values()){ 
                    if(!rmaD.gii__Product__r.gii__SerialControlled__c && !rmaD.gii__Product__r.gii__lotControlled__c){
                        foundS = true;
                    }
                    if(rt.gii__ReturntoSupplier__c == rmaToRTS.get(rmaD.gii__RMAReceipt__r.gii__RMA__c)){                        
                        if(rt.gii__ProductSerial__c != null && rt.gii__ProductSerial__c == rmaD.gii__ProductSerial__c){  
                            foundS = true;
                        }else if(rt.gii__ProductLot__c != null && rt.gii__ProductLot__c == rmaD.gii__ProductLot__c){
                            foundS = true;
                        }                       
                    }
                }
            }else{
                foundS = true; 
            }
            if(!foundS){
                rt.addError('This Product is not related to the RMA!');
            }
                       
        }
      
        
    }
    
}