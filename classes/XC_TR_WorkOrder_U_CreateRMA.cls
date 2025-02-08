/** 
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 10/09/2019
* @description Class to integrate RMA Process
*/
public without sharing class XC_TR_WorkOrder_U_CreateRMA {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateRMA');
    
    @future  
    /**
    * @description create RMA
    * @param listNew the list new
    */  
    public static void createRMA(List<Id> listNew){ 
		List<WorkOrder> woList  = new List<WorkOrder> ([SELECT Id,XC_AssignedPartner__c FROM WorkOrder WHERE Id IN:listNew]) ;      
        if(!woList.isEmpty()){
            createRMA(woList);
        }        
    }
    /**
    * @description create RMA
    * @param listNew the list new
    */  
    public static void createRMA(List<WorkOrder> listNew){  
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AssignedPartner__c');
        if(listPartnerIds.isEmpty()){
            return;
        }   
        Map<Id, gii__Warehouse__c> mapPartnerIdWarehouseId = getMapPartnerWarehouse(listPartnerIds);
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds);
        
        Map<Id, List<ProductRequired>> mapWorkOrderProductRequiredToReturn = new Map<Id, List<ProductRequired>>();
        List<String> product2 = new List<String>();
        if(!mapWorkOrder.values().isEmpty()){
            for(Id woId : mapWorkOrder.keySet()){
                for (ProductRequired pr : mapWorkOrder.get(woId).ProductsRequired){
                    product2.add(pr.Product2Id);
                }
            } 
            if(product2.isEmpty()){
                return;
            }
            Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2); 
            if(prGloviaMap.values().isEmpty()){
                return;
            }
            Map<Id,gii__Product2Add__c> product2ToGlovia = getProduct2ToGlovia(prGloviaMap.values());   
            List<WorkOrder> woNewList = new List<WorkOrder>();
            List<Giic_CommonWrapper.RMAHeader> rmaList = new List<Giic_CommonWrapper.RMAHeader>();
            
            Map<String, Id> mapSerialNumberID =  getSerialProductID(mapWorkOrder.values());
            for(WorkOrder wo : mapWorkOrder.values()){
                Giic_CommonWrapper.RMAHeader objRMA = new Giic_CommonWrapper.RMAHeader();
            
                    objRMA.accountId = wo.XC_AssignedPartner__c;
                    objRMA.warehouseId = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).Id;
                    objRMA.workOrderId = wo.Id;
                    objRMA.CurrencyIsoCode = wo.CurrencyIsoCode; 
                    objRMA.reason ='Other'; // TODO possibili valori:  Damaged, Incorrect Shipment, Bad Quality, Other
                    objRMA.rMADate = Date.today();
                    objRMA.accountName  = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).gii__Account__r.Name ;
                    objRMA.street = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).gii__WareHouseStreet__c;
                    objRMA.city = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).gii__WareHouseCity__c;
                    objRMA.stateProvince = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).gii__WareHouseStateProvince__c; 
                    objRMA.zipPostalCode = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).gii__WareHouseZipPostalCode__c;
                    objRMA.country = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c).giic_WareHouseCountryPick__c;  
                    objRMA.RMALines = new  List<Giic_CommonWrapper.RmaLine> ();
                    objRMA.RMALines.addAll(getRMALines( wo, mapSerialNumberID ,  product2ToGlovia )); 
               
                rmaList.add(objRMA);
                WorkOrder woNew = new WorkOrder();
                woNew.Id = wo.Id;
                woNew.XC_SentGoodIssue__c = true;
                woNewList.add(woNew);
            }
            Giic_CommonWrapper.RMAResponse responseRMA = Giic_RMAUtility.createRMAs(rmaList);
            system.debug('*******responseRMA*******'+responseRMA);
            XC_UTIL_Sobject.updateListRecords(woNewList);
        }else{
            return;
        }
        
    }
    
    /**
* @description getMapPartnerWarehouse
* @param listPartnerIds the list new
* @return Map<Id,Id>
*/  
    private static Map<Id, gii__Warehouse__c> getMapPartnerWarehouse(List<String> listPartnerIds){
        Map<Id, gii__Warehouse__c> warehouseMap  = new  Map<Id,gii__Warehouse__c>(
            [SELECT Id, gii__Account__c, gii__WareHouseCity__c, giic_WareHouseCountryPick__c,gii__Account__r.Name,
		     gii__WareHouseStateProvince__c, gii__WareHouseStreet__c, gii__WareHouseZipPostalCode__c
             FROM gii__Warehouse__c  
             WHERE gii__Account__c IN: listPartnerIds ]
        );
        Map<Id, gii__Warehouse__c> mapPartnerIdWarehouse = new Map<Id, gii__Warehouse__c>();
        for(Id warehouseId : warehouseMap.keySet()){
            mapPartnerIdWarehouse.put(warehouseMap.get(warehouseId).gii__Account__c, warehouseMap.get(warehouseId) );
        }
        return mapPartnerIdWarehouse;
    }
    
    /**
* @description getWorkOrder
* @param listWorkOrderIds the list new
* @return Map<Id,WorkOrder>
*/  
    private static Map<Id, WorkOrder> getWorkOrder(List<Id> listWorkOrderIds){
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>(
            [SELECT Id, CurrencyIsoCode,XC_AssignedPartner__c,AccountId,WorkOrderNumber,XC_SerialNumber__c,Asset.XC_Warranty_End_Date__c,
             (SELECT Id, Product2Id,ProductRequiredNumber, XC_ProcurementType__c, XC_Asset__r.SerialNumber,QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c 
              FROM ProductsRequired 
              WHERE XC_Mode__c = 'Remove' )
             FROM WorkOrder 
             WHERE Id IN: listWorkOrderIds]
        );
        return mapWO;  
    }
    
    /**
* @description getGloviaProduct
* @param product2 the list new
* @return Map<Id,gii__Product2Add__c>
*/  
    private static  Map<Id,gii__Product2Add__c> getGloviaProduct(List<String> product2){
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c,gii__SerialControlled__c 
            FROM gii__Product2Add__c 
            WHERE gii__ProductReference__c IN : product2]
                                                                                 );  
        return prGloviaMap;
    }
    
    /**
* @description getProduct2ToGlovia
* @param prGloviaMap the list new
* @return Map<Id,gii__Product2Add__c>
*/
    private static  Map<Id,gii__Product2Add__c> getProduct2ToGlovia(List<gii__Product2Add__c> prGloviaMap){
        Map<Id,gii__Product2Add__c> product2ToGlovia =  new  Map<Id,gii__Product2Add__c>();
        if(!prGloviaMap.isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap){
                product2ToGlovia.put(pr.gii__ProductReference__c, pr);
            }
        }   
        return product2ToGlovia;
    }
    
    /**
* @description getProduct2ToGlovia
* @param wo the list new
* @return Map<String,Id>
*/
    private static Map<String, Id> getSerialProductID(List<WorkOrder> woList){
        List<String> serialNumbers = new List<String>();
        Map<String, Id> mapSerialNumberIds = new  Map<String, Id>();
        List<String> parterAssigned = new List<String>();
        for(WorkOrder wo : woList){
            parterAssigned.add(wo.XC_AssignedPartner__c);
            for(ProductRequired pr : wo.ProductsRequired ){
                if(pr.XC_Asset__c != null){
                    serialNumbers.add(pr.XC_Asset__r.SerialNumber);
                }
            }
        }        
        List<gii__ProductSerial__c> prodSerial = new List<gii__ProductSerial__c>([
                                                    SELECT Id, Name FROM gii__ProductSerial__c 
                                                    WHERE  Name IN :serialNumbers]);
        
        for(gii__ProductSerial__c ps : prodSerial){
            mapSerialNumberIds.put(ps.Name , ps.Id);
        }
        return mapSerialNumberIds;
    }
    /**
* @description getRMALines
* @param wo the list new
* @param mapWorkOrderProductRequiredToReturn
* @param product2ToGlovia
* @return List<Giic_CommonWrapper.RmaLine>
*/
    private static List<Giic_CommonWrapper.RmaLine> getRMALines( WorkOrder wo,  Map<String, Id> mapSerialNumberID , Map<Id,gii__Product2Add__c> product2ToGlovia ){
        List<Giic_CommonWrapper.RmaLine> rmaLines = new List<Giic_CommonWrapper.RmaLine>();  
        for(ProductRequired pr :  wo.ProductsRequired){
            Giic_CommonWrapper.RmaLine objRMALine = new Giic_CommonWrapper.RmaLine();
            objRMALine.rmaQuantity = pr.QuantityRequired;
            objRMALine.productId = product2ToGlovia.get(pr.Product2Id).Id;
            if(product2ToGlovia.get(pr.Product2Id).gii__SerialControlled__c ) {
                objRMALine.productSerialId = mapSerialNumberID.get(pr.XC_Asset__r.SerialNumber) ; 
            }else{
                objRMALine.productSerialId = null; 
            }   
            if(System.today() < wo.Asset.XC_Warranty_End_Date__c ) {
                objRMALine.underWarranty = true;  
            }else{
                objRMALine.underWarranty = false; 
            }          
            rmaLines.add(objRMALine);
        }
        return rmaLines;
    }
    
    
}