/**  
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 10/09/2019
* @description Class to integrate Good Issue Process
*/
public without sharing class XC_TR_WorkOrder_U_CreateGoodIssue_U {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateGoodIssue_U');
    
    /**
* @description create good issue
* @param listNew the list new
*/  
    
    @future  
    public static void createGoodIssueForRepair(List<Id> listNew){ 
        List<WorkOrder> woList  = new List<WorkOrder> ([SELECT Id,XC_AssignedPartner__c 
                                                        FROM WorkOrder 
                                                        WHERE Id IN:listNew
                                                       ]) ;      
        if(!woList.isEmpty()){
            createGoodIssue(woList);
        }        
    }
    
    public static void createGoodIssue(List<WorkOrder> listNew){ 
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AssignedPartner__c');
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listNew); 
        if(listPartnerIds.isEmpty()){
            return;
        }        
        Map<Id, Id> mapPartnerIdWarehouseId = XC_TR_WorkOrder_U_CreateGoodIssue.getMapPartnerWarehouse(listPartnerIds);
        List<NE__Order__c> neOrders = new List<NE__Order__c>([
            SELECT Id,NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c, Name ,NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber, NE__OptyId__r.XC_WorkOrder__c,
            NE__OptyId__r.XC_WorkOrder__r.Status,
            (SELECT Id, NE__ProdId__c, XC_Wbe__c, XC_CMCostCenter__c,Name,NE__Qty__c
             FROM NE__Order_Items__r)
            FROM NE__Order__c 
            WHERE NE__OptyId__r.XC_WorkOrder__c IN:listWorkOrderIds 
            AND RecordType.DeveloperName = 'Order'
        ]);
        
        if(neOrders.isEmpty()){
            return;
        } 
        
         Map<Id, NE__AssetItemAttribute__c>  mapAssetItemAtt = new Map<Id, NE__AssetItemAttribute__c>(
            [SELECT Id,NE__Value__c,NE__Asset__r.XC_CostCenter__c, NE__Asset__r.SerialNumber, NE__Asset__r.XC_WBE__c, NE__Asset__r.Quantity,NE__Asset__r.NE__Order_Config__c, NE__Asset__r.XC_Product_Type__c, NE__Asset__r.XC_Product_Subtype__c 
             FROM NE__AssetItemAttribute__c 
             WHERE XC_DeveloperName__c = 'Referencia' 
             AND NE__Asset__r.XC_Product_Type__c = 'Technical'
             AND NE__Asset__r.XC_Product_Subtype__c = 'Product'
             AND NE__Asset__r.NE__Order_Config__c  IN :neOrders
            ]);
        
        if(mapAssetItemAtt.isEmpty()){
            return;
        } 
        Map<String , List<NE__AssetItemAttribute__c>> mapOrderAssetItem = new  Map<String , List<NE__AssetItemAttribute__c>>();
        for(NE__AssetItemAttribute__c assItem : mapAssetItemAtt.values()){
            if(!mapOrderAssetItem.containsKey(assItem.NE__Asset__r.NE__Order_Config__c)){
                mapOrderAssetItem.put(assItem.NE__Asset__r.NE__Order_Config__c, new List<NE__AssetItemAttribute__c>());
            }
            mapOrderAssetItem.get(assItem.NE__Asset__r.NE__Order_Config__c).add(assItem);
        }

        List<String> techProd = XC_UTIL_Sobject.getListFieldValues(mapAssetItemAtt.values(), 'NE__Value__c'); 
        Map<String, gii__Product2Add__c> prodCodeToGlovia = new Map<String, gii__Product2Add__c>();
        
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c ,gii__ProductCode__c
            FROM gii__Product2Add__c 
            WHERE gii__ProductCode__c IN : techProd
        AND gii__ProductReference__r.XC_ProductSubType__c = 'Enel Spare Part']
        ); 
        if(!prGloviaMap.values().isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap.values()){
                prodCodeToGlovia.put(pr.gii__ProductCode__c, pr);
            }
        }else{ return; }
         
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>(); 
         Map<String, String> assetSerialNumber = new  Map<String, String>();
         List<WorkOrder> woNewList = new List<WorkOrder>();
            for(NE__Order__c order : neOrders){ 
                if(mapOrderAssetItem.containskey(order.Id)){                
                    Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
                    soWrap.account = order.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c;
                    soWrap.warehouse = mapPartnerIdWarehouseId.get(order.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c);
                    soWrap.fslWorkOrder = order.NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber ; 
                    soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
                    
                    if(order.NE__OptyId__r.XC_WorkOrder__r.Status == Label.XC_CL_Cancelled || order.NE__OptyId__r.XC_WorkOrder__r.Status == Label.XC_CL_CannotComplete ){
                        soWrap.SalesOrderLineList.addAll(getGoodIssueLineCancelled( mapOrderAssetItem.get(order.Id),prodCodeToGlovia));
                        system.debug('@@@@@@@  soWrap.SalesOrderLineList Cancelled' +  soWrap.SalesOrderLineList); 
                    }else{
                        soWrap.SalesOrderLineList.addAll(getGoodIssueLine(mapOrderAssetItem.get(order.Id),prodCodeToGlovia)); 
                        system.debug('@@@@@@@  soWrap.SalesOrderLineList' +  soWrap.SalesOrderLineList); 
                    } 
                    WorkOrder woNew = new WorkOrder();
                    woNew.Id = order.NE__OptyId__r.XC_WorkOrder__c; 
                    woNew.XC_SentGoodIssue__c = true;
                    woNewList.add(woNew);
                    soWrapList.add(soWrap);
                }
            }
         Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
         XC_UTIL_Sobject.updateListRecords(woNewList);
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
    } 
     
      /**
    * @description getGoodIssueLineCancelled
    * @param wo the list new
    * @param mapProduct2ToProductGlovia 
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLineCancelled(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia  ){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>(); 
        for(NE__AssetItemAttribute__c asset : assetItem){
            if(prodCodeToGlovia.containskey(asset.NE__Value__c)){
                Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
                sol.product = prodCodeToGlovia.get(asset.NE__Value__c).Id ;  
                sol.productRequiredID = asset.NE__Value__c;
                sol.orderQuantity = asset.NE__Asset__r.Quantity;
                sol.consumedQuantity = 0; 
                salesOrderLineList.add(sol);
                
            }
        }
       return salesOrderLineList;
    }
          /**
    * @description getGoodIssueLineCancelled
    * @param wo the list new
    * @param mapProduct2ToProductGlovia 
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia ){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>(); 
        for(NE__AssetItemAttribute__c asset : assetItem){
             if(prodCodeToGlovia.containskey(asset.NE__Value__c)){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            sol.product = prodCodeToGlovia.get(asset.NE__Value__c).Id ;  
            sol.productRequiredID = asset.NE__Value__c;
            sol.orderQuantity = asset.NE__Asset__r.Quantity;
            sol.consumedQuantity = asset.NE__Asset__r.Quantity; 
            sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
            Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
            serials.serialNumber =  asset.NE__Asset__r.SerialNumber  ;   //Adding first Serial TODO verificare
            sol.assignedSerials.add(serials); 
            salesOrderLineList.add(sol);
             }
        }
       return salesOrderLineList;
    }
     
      /**
    * @description getGloviaProduct
    * @param product2 the list new
    * @return Map<Id,gii__Product2Add__c>
    */  
    public static  Map<String,gii__Product2Add__c> getGloviaProduct(Set<Id> product2){
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
                SELECT Id, gii__ProductReference__c,gii__SerialControlled__c 
                FROM gii__Product2Add__c 
                WHERE gii__ProductReference__c IN : product2]
        );  
        
        List<gii__Product2Add__c> prGlovia = prGloviaMap.values();
        Map<String,gii__Product2Add__c> product2ToProductGlovia = new  Map<String,gii__Product2Add__c>();
        if(!prGlovia.isEmpty()){
            for(gii__Product2Add__c pr : prGlovia){
                product2ToProductGlovia.put(pr.gii__ProductReference__c, pr);
            }
        }         
        return product2ToProductGlovia; 
    }
    /**
* @description createProductList
* @param mapWorkOrder the list new
* @return Map<Id,String>
*/  /* -----------------------------NOT USEDE ANYWHERE DDP 06022020-------------------------------------
    private static Map<String,String> createProductList(List<NE__Order__c> neOrders){
      List<Id> commercialProd = new List<Id>(); 
        for(NE__Order__c neOrder : neOrders){
            for(NE__OrderItem__c neItem : neOrder.NE__Order_Items__r){
                commercialProd.add(neItem.NE__ProdId__c);
            }  
        }
        
        Map<Id, B2WExtCat__External_Catalog_Association__c>  mapProdExternalCatalog = new Map<Id, B2WExtCat__External_Catalog_Association__c>(
            [SELECT Id,  Name, XC_TechnicalProduct__c,XC_TechnicalProduct__r.ProductCode,XC_Quantity__c, B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c, B2WExtCat__Commercial_Product__c , B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c 
             FROM B2WExtCat__External_Catalog_Association__c  
             WHERE B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c IN :commercialProd
             OR B2WExtCat__Commercial_Product__c IN :commercialProd 
            ]);
         
        List<String> techProd = new List<String>();
        Map<String,String> mapCommTech = new Map<String,String>();
        for(B2WExtCat__External_Catalog_Association__c extCat : mapProdExternalCatalog.values()){
            String prodId = (extCat.B2WExtCat__Commercial_Product__c !=null) ? extCat.B2WExtCat__Commercial_Product__c : extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            techProd.add(extCat.XC_TechnicalProduct__c); 
            mapCommTech.put(prodId,extCat.XC_TechnicalProduct__c);
        }
         
       return mapCommTech;
    }*/
}