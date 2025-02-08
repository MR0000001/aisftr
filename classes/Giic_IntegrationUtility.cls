/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description class for Integration
*/
public without Sharing class Giic_IntegrationUtility {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_IntegrationUtility');   
    
    public static void createPOReceiptStaging(List<Id> porIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createPOReceiptStaging----->>' );
        if(porIds.size()>0){
            List<gii__PurchaseOrderReceipt__c> lstPOR=new List<gii__PurchaseOrderReceipt__c> ();
            List<gii__PurchaseOrderReceiptLine__c> lstPORL=new List<gii__PurchaseOrderReceiptLine__c> ();
            map<Id,gii__PurchaseOrderReceiptStaging__c> mapPOandPORS=new map<Id,gii__PurchaseOrderReceiptStaging__c>();
            List<gii__PurchaseOrderReceiptLineStaging__c> lstPORLStagging=new List<gii__PurchaseOrderReceiptLineStaging__c> ();
            if(Schema.sObjectType.gii__PurchaseOrderReceipt__c.isQueryable()){
                lstPOR= [SELECT Id,Name,gii__PurchaseOrder__c,giic_TargetSystem__c,giic_MaterialDocument__c,giic_Status__c,giic_DeliveryDocumentID__c,giic_YearDocument__c,giic_DeliveryDate__c,giic_IntegrationStatus__c,gii__ReceiptDate__c,giic_IntegrationOperation__c 
                         FROM gii__PurchaseOrderReceipt__c WHERE  Id IN:porIds];
            }
            for(gii__PurchaseOrderReceipt__c objPOR:lstPOR){
                mapPOandPORS.put(objPOR.gii__PurchaseOrder__c,new gii__PurchaseOrderReceiptStaging__c(giic_PurchaseOrder__c=objPOR.gii__PurchaseOrder__c,
                                                                                                      giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate,
                                                                                                      giic_IntegrationOperation__c=System.Label.giic_CancellationRequest,
                                                                                                      giic_ReceiptDate__c=objPOR.gii__ReceiptDate__c, 
                                                                                                      giic_MaterialDocument__c = objPOR.giic_MaterialDocument__c,
																									  giic_YearDocument__c = objPOR.giic_YearDocument__c,
                                                                                                      giic_DeliveryDate__c = objPOR.giic_DeliveryDate__c,
                                                                                                      giic_DeliveryDocumentID__c = objPOR.giic_DeliveryDocumentID__c,
                                                                                                      giic_Status__c = objPOR.giic_Status__c,
                                                                                                      giic_TargetSystem__c=System.Label.giic_TargetSystemSAP 
                                                                                                     ));
            }
            if(Schema.sObjectType.gii__PurchaseOrderReceiptStaging__c.isCreateable()){
                insert mapPOandPORS.values();}
            if(Schema.sObjectType.gii__PurchaseOrderReceiptLine__c.isQueryable()){
                lstPORL= [SELECT Id,gii__ProductSerial__c,gii__PurchaseOrder__c,gii__PurchaseOrderLine__c,gii__UnitPrice__c,gii__ReceivedQuantity__c,gii__Location__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c FROM gii__PurchaseOrderReceiptLine__c WHERE  gii__PurchaseOrderReceipt__c IN:porIds];
            }
            System.debug('lstPORL'+lstPORL);
            for(gii__PurchaseOrderReceiptLine__c objPORL:lstPORL){
                gii__PurchaseOrderReceiptLineStaging__c objPORLS= new gii__PurchaseOrderReceiptLineStaging__c();
                if(objPORL.gii__Product__r.gii__SerialControlled__c){
                    objPORLS.giic_Product__c=objPORL.gii__Product__c;
                    objPORLS.giic_Location__c=objPORL.gii__Location__c;
                    objPORLS.giic_PurchaseOrder__c=objPORL.gii__PurchaseOrder__c;
                    objPORLS.giic_PurchaseOrderLine__c=objPORL.gii__PurchaseOrderLine__c;
                    objPORLS.giic_ReceivedQuantity__c=objPORL.gii__ReceivedQuantity__c;
                    objPORLS.giic_ProductSerial__c=objPORL.gii__ProductSerial__c;
                    objPORLS.giic_UnitPrice__c = objPORL.gii__UnitPrice__c;
                    objPORLS.giic_PurchaseOrderReceiptStaging__c=mapPOandPORS.get(objPORL.gii__PurchaseOrder__c).Id;   
                    lstPORLStagging.add(objPORLS);
                }
                else{
                    objPORLS.giic_Product__c=objPORL.gii__Product__c;
                    objPORLS.giic_Location__c=objPORL.gii__Location__c;
                    objPORLS.giic_PurchaseOrder__c=objPORL.gii__PurchaseOrder__c;
                    objPORLS.giic_PurchaseOrderLine__c=objPORL.gii__PurchaseOrderLine__c;
                    objPORLS.giic_ReceivedQuantity__c=objPORL.gii__ReceivedQuantity__c;
                    objPORLS.giic_UnitPrice__c = objPORL.gii__UnitPrice__c;
                    objPORLS.giic_PurchaseOrderReceiptStaging__c=mapPOandPORS.get(objPORL.gii__PurchaseOrder__c).Id; 
                    lstPORLStagging.add(objPORLS);
                }
            } 
            System.debug('lstPORLStagging'+lstPORLStagging);
            if(Schema.sObjectType.gii__PurchaseOrderReceiptLineStaging__c.isCreateable()){
                insert lstPORLStagging;}
        }
    }
    /**
    * @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
    * @date Creation 03/07/2019
    * @date Modification 04/07/2019
    * @description Method to change Integration Status as ready to integrate in case of Receipt (When Created)
    * @param porIds list of gii__PurchaseOrderReceipt__c id
    */
    public static void setReceiptStatusReadytoIntegrate(List<Id> porIds){
          XC_UTIL_Debug.debug(DEBUGACTIVE,'In setReceiptStatusReadytoIntegrate----->>' );
        List<gii__Receipt__c> lstPOR= new List<gii__Receipt__c>();
        if(Schema.sObjectType.gii__Receipt__c.isQueryable()){
            lstPOR= [SELECT Id,Name,giic_IntegrationStatus__c FROM gii__Receipt__c WHERE  Id=:porIds];
            for(gii__Receipt__c objPOR:lstPOR){
                objPOR.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                objPOR.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
                objPOR.giic_TargetSystem__c=System.Label.giic_TargetSystemAFC;
            }
        }
        
        if(Schema.sObjectType.gii__Receipt__c.isUpdateable()){update lstPOR;}
    }
    
    /**
    * @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
    * @date Creation 03/07/2019
    * @date Modification 04/07/2019
    * @description Method to change Integration Status as ready to integrate in case of Receipt Queue(When Created)
    * @param porIds list of gii__PurchaseOrderReceipt__c id
    */
    public static void setReceiptQueueStatusReadytoIntegrate(List<Id> porIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setReceiptQueueStatusReadytoIntegrate----->>' );
        List<gii__ReceiptQueue__c> lstPOR= new List<gii__ReceiptQueue__c>();
        if(Schema.sObjectType.gii__ReceiptQueue__c.isQueryable()){
            lstPOR= [SELECT Id,Name,giic_IntegrationStatus__c,gii__TransferOrder__c,gii__TransferOrder__r.giic_LegalEntity__c FROM gii__ReceiptQueue__c WHERE  Id=:porIds];
            for(gii__ReceiptQueue__c objPOR:lstPOR){
               
                objPOR.giic_LegalEntity__c = objPOR.gii__TransferOrder__r.giic_LegalEntity__c;  
            }
        }
        if(Schema.sObjectType.gii__ReceiptQueue__c.isUpdateable()){update lstPOR;}
    }
    
    
    
    public static void setLEFromTO(List<gii__ReceiptQueue__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In setLEFromTO----->>' );
        List<String> toIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__TransferOrder__c');
        map<Id,gii__TransferOrder__c> p2Maps = new  map<Id,gii__TransferOrder__c> ([SELECT Id, giic_LegalEntity__c FROM gii__TransferOrder__c WHERE Id IN: toIds ]);
        System.debug('p2Maps = '+p2Maps.values());
        for(gii__ReceiptQueue__c t : listNew){   
             for(gii__TransferOrder__c w : p2Maps.values()){
                 if(t.gii__TransferOrder__c == w.Id && w.giic_LegalEntity__c != null){
                    	t.giic_LegalEntity__c = w.giic_LegalEntity__c;
                 }
             }
            
        }
        
    }
        
    
    
    
    
    
       /**
    * @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
    * @date Creation 03/07/2019
    * @date Modification 04/07/2019
    * @description Method to create Purchase Order Receipt Stagging when a purchase Order Receipt is deleted.
    * @param shipId list of gii__Shipment__c id
    */
    public static void createShipmentStaging(List<Id> shipId){  
          XC_UTIL_Debug.debug(DEBUGACTIVE,'In createShipmentStaging----->>' );
            map<Id,gii__ShipmentStaging__c> mapSHPandSHPDStaging=new map<Id,gii__ShipmentStaging__c>();
            List<gii__ShipmentDetailStaging__c> lstSHIPDStaging=new List<gii__ShipmentDetailStaging__c> (); 
            
            List<gii__Shipment__c> lstShip = new List<gii__Shipment__c>([SELECT Id,Name,gii__SalesOrder__c
                                                                         FROM gii__Shipment__c 
                                                                         WHERE  Id IN:shipId]);
            
            if(lstShip.isEmpty()){ return; }
            for(gii__Shipment__c objShip : lstShip){
                mapSHPandSHPDStaging.put(objShip.gii__SalesOrder__c,new gii__ShipmentStaging__c(giic_SalesOrder__c=objShip.gii__SalesOrder__c));
            }
        
            XC_UTIL_Sobject.insertListRecords(mapSHPandSHPDStaging.values());
         	
            List<gii__ShipmentDetail__c> lstSHPDet = new List<gii__ShipmentDetail__c> ([SELECT Id, gii__SalesOrderLine__c,gii__Shipment__r.gii__SalesOrder__c,gii__ShippedQuantity__c,
                                                                                        giic_AFCPrice__c
                                                                                        FROM gii__ShipmentDetail__c
                                                                                        WHERE gii__Shipment__c IN:shipId ]); 
             
            for(gii__ShipmentDetail__c objSHPDet : lstSHPDet){
                gii__ShipmentDetailStaging__c objSHPDetS= new gii__ShipmentDetailStaging__c(); 
                    objSHPDetS.giic_SalesOrderLine__c= objSHPDet.gii__SalesOrderLine__c; 
                    objSHPDetS.giic_AFCPrice__c= objSHPDet.giic_AFCPrice__c; 
                	objSHPDetS.giic_ShippedQuantity__c = objSHPDet.gii__ShippedQuantity__c;
                    objSHPDetS.giic_ShipmentStaging__c=mapSHPandSHPDStaging.get(objSHPDet.gii__Shipment__r.gii__SalesOrder__c).Id;   
                lstSHIPDStaging.add(objSHPDetS);  
            } 
            
        XC_UTIL_Debug.debug(DEBUGACTIVE,'lstSHIPDStaging----->>' +lstSHIPDStaging);
        XC_UTIL_Sobject.insertListRecords(lstSHIPDStaging); 
        
    }
    
   
    
    
 
    
}