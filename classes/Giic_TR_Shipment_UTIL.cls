public without sharing class Giic_TR_Shipment_UTIL {
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_Shipment_UTIL');
     


     public static void checkIfDeliveryChange(List<gii__Shipment__c > listNew, Map<Id, gii__Shipment__c > mapOld ,  Map<Id, gii__Shipment__c > mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Enter in checkIfDeliveryChange');
        List<String> fieldToCheck = new List<String> {'giic_DeliveryDate__c','giic_DeliveryDocumentID__c'}; 
	    listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
         
        Set<Id> porIds = XC_UTIL_Sobject.getSetIds(listNew);
        rebaltOnWo(porIds);
 
    }
    
    public static void rebaltOnWo(Set<Id> porIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Enter in rebaltOnWo');
        List<Workorder> woToUpdate = new List<Workorder>();
        List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>();  
        map<Id,gii__Shipment__c> porMap = new  map<Id,gii__Shipment__c>([SELECT Id, giic_DeliveryDate__c, giic_DeliveryDocumentID__c,gii__TransferOrder__c, gii__TransferOrder__r.giic_SalesOrder__c,
                                                                         gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrderLineItem__c,gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__c,
                                                                         gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__r.XC_WorkTypeCategory__c,
                                                                         gii__TransferOrder__r.giic_SalesOrder__r.giic_IsDelivery__c
                                                                         FROM gii__Shipment__c
                                                                         WHERE Id IN: porIds 
                                                                         ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@porMAp '+porMap);
        if(!porMap.values().isEmpty()){
            for(gii__Shipment__c por : porMap.values()){
                
                if(por.gii__TransferOrder__r.giic_SalesOrder__c!=null && por.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__c!=null){
                    if(por.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrderLineItem__c!=null){
                        //NR2122 if(por.gii__TransferOrder__r.giic_SalesOrder__r.giic_IsDelivery__c){
                        	WorkOrderLineItem woli = new WorkOrderLineItem(Id = por.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrderLineItem__c,
                                                                       XC_DeliveryId__c=por.giic_DeliveryDocumentID__c,
                                                                       XC_EffectiveDeliveryDate__c=por.giic_DeliveryDate__c);
                       
                        	woliToUpdate.add(woli); 
                        //NR2122}
                    }else{
                        Workorder wo = new Workorder(Id=por.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__c, XC_DeliveryId__c=por.giic_DeliveryDocumentID__c, XC_EffectiveDeliveryDate__c=por.giic_DeliveryDate__c);
                        woToUpdate.add(wo);
                    }
                }
                
            }
        }
        XC_UTIL_SObject.updateListRecords(woToUpdate);
        XC_UTIL_SObject.updateListRecords(woliToUpdate);
        
    }
    
    
     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
     public static void fillAFCPrice(List<gii__ShipmentDetail__c> listNew){
         List<String> salesOrderLineList = XC_UTIL_SObject.getListFieldValues(listNew, 	'gii__SalesOrderLine__c');
         if(salesOrderLineList.isEmpty()){ return; }
         Map<String, Double> currencyRates  =  new Map <String, Double>(); 
         for (CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
             currencyRates.put(cRates.IsoCode, cRates.ConversionRate);
         }
         Map<Id, gii__SalesOrderLine__c> mapSalesOrderLine = new Map<Id, gii__SalesOrderLine__c> ([
             												SELECT Id, gii__Product__c, gii__Product__r.giic_AveragePrice__c,gii__SalesOrder__r.gii__DropShip__c,gii__Product__r.CurrencyIsoCode,
                                                                (SELECT Id,gii__LineNetAmount__c ,gii__Product__c,gii__Product__r.gii__ProductCode__c,gii__OrderQuantity__c ,CurrencyIsoCode
                                                                 FROM gii__Purchase_Order_Lines__r)
             												FROM gii__SalesOrderLine__c
             												WHERE Id in :salesOrderLineList ]);
		 if(mapSalesOrderLine.values().isEmpty()){ return; } 
         
         for(gii__ShipmentDetail__c shp : listNew){
             if(mapSalesOrderLine.containsKey(shp.gii__SalesOrderLine__c)){
                 if(mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__SalesOrder__r.gii__DropShip__c){
                     if(!mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Purchase_Order_Lines__r.isEmpty()) {
                     for(gii__PurchaseOrderLine__c pol : mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Purchase_Order_Lines__r ){
                         if(shp.giic_ProductCode__c == pol.gii__Product__r.gii__ProductCode__c){
                            if(pol.gii__LineNetAmount__c == 0 || pol.gii__LineNetAmount__c == null){
                                shp.giic_AFCPrice__c = mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Product__r.giic_AveragePrice__c;
                            } else{
                                String currencyProd = mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Product__r.CurrencyIsoCode;
                                system.debug('###currencyProd' +currencyProd);
                                system.debug('### pol.CurrencyIsoCode' + pol.CurrencyIsoCode);
                                if(currencyProd != pol.CurrencyIsoCode ){
                                    Decimal afcPrice =  pol.gii__LineNetAmount__c / pol.gii__OrderQuantity__c ;
                                    Decimal covertValue = Giic_POReceiptLineUtility.convertCurrency(pol.CurrencyIsoCode,currencyProd,afcPrice, currencyRates);
                                    shp.giic_AFCPrice__c = covertValue;
                                }else{
                                    shp.giic_AFCPrice__c = pol.gii__LineNetAmount__c / pol.gii__OrderQuantity__c ;
                                }
                            } 
                         }
                     }
                    } else {
                         shp.giic_AFCPrice__c = mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Product__r.giic_AveragePrice__c; //Fix WA EnelSole
                    	}
                 }else{
                     shp.giic_AFCPrice__c = mapSalesOrderLine.get(shp.gii__SalesOrderLine__c).gii__Product__r.giic_AveragePrice__c;
                 }
             }
             system.debug('### pol.CurrencyIsoCode' + shp.giic_AFCPrice__c );
         }
         
                             
         
     }

}