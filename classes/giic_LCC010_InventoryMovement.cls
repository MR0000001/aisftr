/**
* @author FirstName : LORENZO ORLANDUCCI
* @date Creation 11/11/2019
* @date Modification dd/mm/yyyy
* @description - 
*/
public without sharing class giic_LCC010_InventoryMovement {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_LCC010_InventoryMovement');
    
    public class XC_UTIL_InventoryMovementWrapper {

    @AuraEnabled
    public Boolean success = false;
    @AuraEnabled
    public String resultMessage = '';
    @AuraEnabled 
    public String productId = '';
    @AuraEnabled 
    public String productName = '';
    @AuraEnabled 
    public String productCode = '';
    @AuraEnabled 
    public String SKUCode = '';
    @AuraEnabled 
    public String wareHouseId;
    @AuraEnabled 
    public String wareHouseName;
    @AuraEnabled 
    public List<gii__ProductInventoryQuantityDetail__c> piqdList;
   
    /** @description NON CANCELLARE!**/
        public XC_UTIL_InventoryMovementWrapper(){
            System.debug('XC_UTIL_InventoryMovementWrapper');
        }  
            
    }

    @AuraEnabled
    public static XC_UTIL_InventoryMovementWrapper getPIinfoAndAllpiqd(String productInventoryId){
        XC_UTIL_InventoryMovementWrapper wr = new XC_UTIL_InventoryMovementWrapper();
        wr.success = true;
        gii__ProductInventory__c pi = [SELECT Id, gii__Warehouse__c,gii__Warehouse__r.Name,  gii__Product__c, gii__Product__r.Name,gii__Product__r.gii__ProductCode__c,gii__Product__r.giic_SKUCode__c,
                                                                                         (SELECT Id, Name,gii__location__c, gii__location__r.Name, gii__ProductSerial__c,gii__ProductSerial__r.Name,gii__ProductLot__r.Name, gii__OnHandQuantity__c, 
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetails__r)
                                                                                         from gii__ProductInventory__c WHERE Id=: productInventoryId];
        wr.productId = pi.gii__Product__c;
        wr.productName =    pi.gii__Product__r.Name;
        wr.productCode =    pi.gii__Product__r.gii__ProductCode__c;
        wr.SKUCode =    pi.gii__Product__r.giic_SKUCode__c;
        wr.wareHouseId = pi.gii__Warehouse__c;
        wr.wareHouseName =   pi.gii__Warehouse__r.Name;
        wr.piqdList = pi.gii__ProductInventoryQuantityDetails__r;
        return wr;
    }
    
    
    @AuraEnabled
    public static List<gii__ProductInventoryQuantityDetail__c> getPiqdFiltered(String productInventoryId,String locationValue,String productSerialValue,String lotValue){
        System.debug('Enter in getPiqdFiltered con loc value = '+locationValue+' AND serial = '+productSerialValue);
        System.debug('productInventoryId = '+productInventoryId);
         List<gii__ProductInventoryQuantityDetail__c> quantityDetails = new List<gii__ProductInventoryQuantityDetail__c>();  
         if(locationValue!=null && (productSerialValue==null || productSerialValue==''   )){
             quantityDetails = [SELECT Id, Name, gii__location__c, gii__location__r.Name, gii__ProductSerial__c,gii__ProductSerial__r.Name, gii__OnHandQuantity__c,gii__ProductLot__r.Name, 
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetail__c
                                                                                          WHERE gii__ProductInventory__c=:productInventoryId AND gii__Location__c=:locationValue];
         }
         else if(productSerialValue!=null && (locationValue==null || locationValue=='' )){
             quantityDetails =  [SELECT Id, Name, gii__location__c, gii__location__r.Name, gii__ProductSerial__c,gii__ProductSerial__r.Name, gii__OnHandQuantity__c, gii__ProductLot__r.Name,
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetail__c
                                                                                          WHERE gii__ProductInventory__c=:productInventoryId AND gii__ProductSerial__c=:productSerialValue];
         }else if(productSerialValue!=null && productSerialValue!='' && locationValue!=null && locationValue!='' ){
             quantityDetails =  [SELECT Id, Name, gii__location__c, gii__location__r.Name, gii__ProductSerial__c,gii__ProductSerial__r.Name, gii__OnHandQuantity__c, gii__ProductLot__r.Name,
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetail__c
                               WHERE gii__ProductInventory__c=:productInventoryId AND gii__Location__c=:locationValue AND gii__ProductSerial__c=:productSerialValue];
         }else if(lotValue!=null){
             quantityDetails =  [SELECT Id, Name, gii__location__c, gii__location__r.Name, gii__ProductLot__r.Name,gii__ProductSerial__c,gii__ProductSerial__r.Name, gii__OnHandQuantity__c, 
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetail__c
                               WHERE gii__ProductInventory__c=:productInventoryId AND gii__ProductLot__c=:lotValue];
             
         }
        
        else{
              quantityDetails =  [SELECT Id,Name, gii__location__c, gii__location__r.Name, gii__ProductSerial__c,gii__ProductSerial__r.Name, gii__OnHandQuantity__c, gii__ProductLot__r.Name,
                                                                                          gii__ReservedQuantity__c, gii__MovableQuantity__c FROM gii__ProductInventoryQuantityDetail__c
                               WHERE gii__ProductInventory__c=: productInventoryId ];
         }
        return quantityDetails;
        
    }
    
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper inventoryMovement(String productInventoryId, String locationTo, String mapIdToOnHand, String mapIdPiqdToLocationFrom){
        List<giic_InventoryMovement__c> imToInsert = new List<giic_InventoryMovement__c>();
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        List<gii.InventoryMovement.InventoryMovementDetails> listwr = new List<gii.InventoryMovement.InventoryMovementDetails>();
        Map<String, Object> piqdIdToQuantity = (Map<String, Object>)JSON.deserializeUntyped(mapIdToOnHand);
        Map<String, Object> piqdIdToLocationFrom = (Map<String, Object>)JSON.deserializeUntyped(mapIdPiqdToLocationFrom);
        Map<Id,gii__ProductInventoryQuantityDetail__c> piqdMap = new Map<Id,gii__ProductInventoryQuantityDetail__c>([SELECT id, gii__Product__c, gii__Product__r.gii__ProductCode__c, gii__Warehouse__c, gii__Location__c,
                                                                                                                     gii__Warehouse__r.giic_WarehouseCode__c, gii__ProductSerial__c FROM gii__ProductInventoryQuantityDetail__c 
                                                                                                                     WHERE  Id IN:piqdIdToQuantity.keySet() ]);
         
        if(locationTo!=null){
            for(String piqdId : piqdIdToQuantity.keySet()){
                 	gii.InventoryMovement.InventoryMovementDetails wr = new gii.InventoryMovement.InventoryMovementDetails();
                 	wr.QuantitytoBeMoved = Decimal.valueOf(String.valueOf(piqdIdToQuantity.get(piqdId))); // quantità della PIQD
                    wr.BlockedQuantity = 0;
                    String key = piqdMap.get(piqdId).gii__Product__r.gii__ProductCode__c + piqdMap.get(piqdId).gii__Warehouse__r.giic_WarehouseCode__c  + piqdMap.get(piqdId).gii__Location__c;
                    wr.SourceProductInventoryQuantityDetail = piqdMap.get(piqdId); // oggetto PIQD
                    wr.TargetLocationId = locationTo; 
                    giic_InventoryMovement__c invMov = new giic_InventoryMovement__c();
                    invMov.giic_MovementDate__c = Date.today() ;
                    invMov.giic_MovedQuantity__c = Decimal.valueOf(String.valueOf(piqdIdToQuantity.get(piqdId)));
                
                    invMov.giic_LocationTo__c = locationTo;
                    invMov.giic_Location__c = String.valueOf(piqdIdToLocationFrom.get(piqdId));
                	if(invMov.giic_LocationTo__c ==  invMov.giic_Location__c){
                        rw.resultMessage = Label.giic_ErrorInventoryMovement ; //'Warning: location To and Location From cannot be the same!';
                    	return rw;
                	}
              
                    invMov.giic_ProductInventoryQuantityDetail__c = piqdId;
                    invMov.giic_Product__c= piqdMap.get(piqdId).gii__Product__c;
                    invMov.giic_ProductInventory__c=  productInventoryId;
                
                    invMov.giic_ProductSerial__c=   piqdMap.get(piqdId).gii__ProductSerial__c;
                    invMov.giic_Warehouse__c =   piqdMap.get(piqdId).gii__Warehouse__c ;
                    invMov.giic_Reason__c= 'Inventory Movement';
                    imToInsert.add(invMov);
                    listwr.add(wr); 

            }
            rw.success = true;
            rw.resultMessage = Label.giic_CL_InventoryMovementSuccess; 
            List<XC_UTIL_ResultWrapper> rwList = XC_UTIL_Glovia.insertRecords(imToInsert);
            for(XC_UTIL_ResultWrapper r : rwList){
                if(!r.success){
                    rw.success = false;
                    rw.resultMessage = r.resultMessage;
                    return rw;
                }
            }
            gii.InventoryMovement.InventoryMovementResult res = gii.InventoryMovement.TransferInventory(listwr);
         }else{
             
             rw.resultMessage = Label.giic_InventoryMovementLocationMandatory ;// 'Warning: location is mandatory!';
             
         }
            
    	
        return rw;
    }


}