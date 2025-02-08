/**  
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 10/09/2019
* @description Class to integrate Good Issue Process
*/
public without sharing class XC_TR_WorkOrder_U_CreateGoodIssue {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateGoodIssue');

    /**
    * @description create good issue
    * @param listNew the list new
    */  
     
	@future  
    public static void createGoodIssueFromSalesOrder(List<Id> listNew){ 
		List<WorkOrder> woList  = new List<WorkOrder> ([SELECT Id,XC_AssignedPartner__c FROM WorkOrder WHERE Id IN:listNew]) ;      
        if(!woList.isEmpty()){
            createGoodIssueFromSalesOrder(woList);
        }        
    }
       
    public static void createGoodIssueFromSalesOrder(List<WorkOrder> listNew){ 
            List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AssignedPartner__c');
            List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listNew); 
            if(listPartnerIds.isEmpty()){
                    return;
            }        
            Map<Id, Id> mapPartnerIdWarehouseId = getMapPartnerWarehouse(listPartnerIds);
            Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds); 
        	if(mapWorkOrder.values().isEmpty()){
              return;
            } 
        	Map<Id,String> product2 = createProductList(mapWorkOrder); 
        	if(product2.values().isEmpty()){
            	return;
       		}
            Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia = new Map<Id,gii__Product2Add__c> ();
            Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2.values());

            if(prGloviaMap.values().isEmpty()){
              return;
            }             
            for(gii__Product2Add__c pr : prGloviaMap.values()){
                mapProduct2ToProductGlovia.put(pr.gii__ProductReference__c, pr);
            }
            processGoodIssue(mapWorkOrder.values(), mapPartnerIdWarehouseId, mapProduct2ToProductGlovia);
        }  


    
    /**
    * @description processGoodIssue 
    * @param listWO the list new
    * @param mapPartnerIdWarehouseId 
    * @param mapProduct2ToProductGlovia  
    */  
    private static void processGoodIssue(List<WorkOrder> listWO, Map<Id, Id> mapPartnerIdWarehouseId,  Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia){
         List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
         Map<String, String> assetSerialNumber = getSerialNumber(listWO);
         List<WorkOrder> woNewList = new List<WorkOrder>();
            for(WorkOrder wo : listWO){ 
                if(!wo.XC_SentGoodIssue__c && wo.XC_SentToGlovia__c){ 
                    Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
                    soWrap.account = wo.AccountId;
                    soWrap.warehouse = mapPartnerIdWarehouseId.get(wo.XC_AssignedPartner__c);
                    soWrap.fslWorkOrder = wo.WorkOrderNumber;
                    
                    soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
                    if(wo.Status == Label.XC_CL_Cancelled || wo.Status == Label.XC_CL_CannotComplete ){
                        soWrap.SalesOrderLineList.addAll(getGoodIssueLineCancelled( wo, mapProduct2ToProductGlovia,assetSerialNumber)); 
                    }else{
                        soWrap.SalesOrderLineList.addAll(getGoodIssueLine( wo, mapProduct2ToProductGlovia,assetSerialNumber));  
                    } 
                    WorkOrder woNew = new WorkOrder();
                    woNew.Id = wo.Id;
                    woNew.XC_SentGoodIssue__c = true;
                    woNewList.add(woNew);
                    soWrapList.add(soWrap);                
                } 
            }
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList); 
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woNewList);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
    } 
    
    /**
    * @description getGoodIssueLine
    * @param wo the list new
    * @param mapProduct2ToProductGlovia 
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(WorkOrder wo, Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia, Map<String, String> assetSerialNumber){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
     //   Map<String, String> assetSerialNumber = getSerialNumber(wo);
 
        for(ProductRequired pr : wo.ProductsRequired){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            sol.product = mapProduct2ToProductGlovia.get(pr.Product2Id).Id ;  
            sol.productRequiredID = pr.ProductRequiredNumber;
            // isSerialControlled , productConsumedID
            sol.orderQuantity = pr.QuantityRequired;
            sol.consumedQuantity = pr.QuantityRequired; 
            //Assigning Serial. As consumed Quantity is two so need to assigned two quantity
            List<String> assetList = new List<String>();
            sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
            if(mapProduct2ToProductGlovia.get(pr.Product2Id).gii__SerialControlled__c){
                assetList = (pr.XC_Concat_AssetId__c).split(';');  
                for(String assetID : assetList){
                    Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                    serials.serialNumber = assetSerialNumber.get(assetID);   //Adding first Serial TODO verificare
                    sol.assignedSerials.add(serials); 
               
                }
            }
            salesOrderLineList.add(sol);
        }
       return salesOrderLineList;
    }

   /**
    * @description getGoodIssueLineCancelled
    * @param wo the list new
    * @param mapProduct2ToProductGlovia 
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLineCancelled(WorkOrder wo, Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia, Map<String, String> assetSerialNumber ){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
       // Map<String, String> assetSerialNumber = getSerialNumber(wo);
 
        for(ProductRequired pr : wo.ProductsRequired){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            sol.product = mapProduct2ToProductGlovia.get(pr.Product2Id).Id ;  
            sol.productRequiredID = pr.ProductRequiredNumber;
            sol.orderQuantity = pr.QuantityRequired;
            sol.consumedQuantity = 0; 
            salesOrderLineList.add(sol);
        }
       return salesOrderLineList;
    }
    
     /**
    * @description getSerialNumber
    * @param wo the list new
    * @return Map<String, String> 
    */  
    private static Map<String, String> getSerialNumber(List<WorkOrder> woList){ 
        List<String> listIdAsset = new List<String>();
        for(WorkOrder wo : woList){
            for(ProductRequired pr : wo.ProductsRequired){
                List<String> assetIDs  = new List<String>();
                if(pr.XC_Concat_AssetId__c!=null){
                    assetIDs = (pr.XC_Concat_AssetId__c).split(';');
                }
                listIdAsset.addAll(assetIDs);
            }
        }        
        List<Asset> assetList = new List<Asset> ([SELECT Id, SerialNumber FROM Asset WHERE Id IN :listIdAsset ]);
        Map<String, String> assetSerialNumber = new Map<String, String>();
        for(Asset a : assetList){
            assetSerialNumber.put(a.Id, a.SerialNumber);
        }
        return assetSerialNumber; 
    }


     /**
    * @description getMapPartnerWarehouse
    * @param listPartnerIds the list new
    * @return Map<Id,Id>
    */  
    public static Map<Id, Id> getMapPartnerWarehouse(List<String> listPartnerIds){
        Map<Id, gii__Warehouse__c> warehouseMap  = new  Map<Id,gii__Warehouse__c>(
                [SELECT Id, gii__Account__c 
                 FROM gii__Warehouse__c  
                 WHERE gii__Account__c IN: listPartnerIds ]
        );
        Map<Id, Id> mapPartnerIdWarehouseId = new Map<Id, Id>();
            for(Id warehouseId : warehouseMap.keySet()){
                mapPartnerIdWarehouseId.put(warehouseMap.get(warehouseId).gii__Account__c, warehouseId);
            }
        return mapPartnerIdWarehouseId;
    }
    
    /**
    * @description getWorkOrder
    * @param listWorkOrderIds the list new
    * @return Map<Id,WorkOrder>
    */  
    private static Map<Id, WorkOrder> getWorkOrder(List<Id> listWorkOrderIds){
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>(
                [SELECT Id, CurrencyIsoCode,XC_AssignedPartner__c,AccountId,WorkOrderNumber,XC_SerialNumber__c,XC_SentGoodIssue__c,Status,XC_SentToGlovia__c,
                 (SELECT Id, Product2Id,XC_Concat_AssetId__c,ProductRequiredNumber,XC_Asset__c,XC_Asset__r.SerialNumber, XC_ProcurementType__c, 
                  QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c FROM ProductsRequired WHERE XC_Mode__c = 'Add' AND XC_ProcurementType__c = 'Transfer')
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
    public static  Map<Id,gii__Product2Add__c> getGloviaProduct(List<String> product2){
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
                SELECT Id, gii__ProductReference__c,gii__SerialControlled__c 
                FROM gii__Product2Add__c 
                WHERE gii__ProductReference__c IN : product2]
        );  
        return prGloviaMap;
    }

    /**
    * @description createProductList
    * @param mapWorkOrder the list new
    * @return Map<Id,String>
    */  
    private static Map<Id,String>  createProductList(Map<Id, WorkOrder> mapWorkOrder){
        Map<Id,String> product2 = new Map<Id, String >();
        for(Id woId : mapWorkOrder.keySet()){
            for (ProductRequired pr : mapWorkOrder.get(woId).ProductsRequired){
                product2.put(pr.Id, pr.Product2Id);
            }
        }
        return product2;
    }

    
  
 
}