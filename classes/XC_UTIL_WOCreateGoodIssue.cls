/**
* @author FSL Team - marco.rosa@nttdata.com
* @date Creation 10/06/2020
* @description  – XC_UTIL_WOCreateGoodIssue  -  
*/ 
public without sharing class XC_UTIL_WOCreateGoodIssue {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WOCreateGoodIssue');

    
    /**
    * @description getGoodIssueLine
    * @param wo - WorkOrder
    * @param mapProduct2ToProductGlovia - Map<Id,gii__Product2Add__c> 
    * @param assetSerialNumber - Map<String, String> assetSerialNumber
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(WorkOrder wo, Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia, Map<String, String> assetSerialNumber){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
     //   Map<String, String> assetSerialNumber = getSerialNumber(wo);
 
        for(ProductRequired pr : wo.ProductsRequired){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            sol.product = mapProduct2ToProductGlovia.get(pr.Product2Id).Id ;  
            sol.productRequiredID = pr.ProductRequiredNumber;
            sol.isSerialControlled = mapProduct2ToProductGlovia.get(pr.Product2Id).gii__SerialControlled__c;
            sol.isLotControlled = false;
            sol.orderQuantity = pr.QuantityRequired;
            sol.consumedQuantity = pr.QuantityRequired; 
            //Assigning Serial. As consumed Quantity is two so need to assigned two quantity
            List<String> assetList = new List<String>();
            sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
            if(mapProduct2ToProductGlovia.get(pr.Product2Id).gii__SerialControlled__c){
                if(pr.XC_Concat_AssetId__c!=null){
                    assetList = (pr.XC_Concat_AssetId__c).split(';');  
                    for(String assetID : assetList){
                        Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                        serials.serialNumber = assetSerialNumber.get(assetID);   //Adding first Serial TODO verificare
                        sol.assignedSerials.add(serials); 
                    }
                }
            }
            salesOrderLineList.add(sol);
        }
       return salesOrderLineList;
    }
    
     /**
    * @description getSerialNumber
    * @param woList - List<WorkOrder>
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
    

    private static Map<String, String> getSerialNumberB2B(List<WorkOrder> woList){
        Map<String, String> assetSerialNumber = new Map<String, String>();
        List<XC_ProductConsumed__c> consumed = new List<XC_ProductConsumed__c> ([select id, TAM_Asset__c, TAM_Asset__r.SerialNumber, TAM_Asset__r.Product2Id, TAM_Asset__r.TAM_IsTechnical__c
                                                                                    from XC_ProductConsumed__c
                                                                                    where TAM_Asset__r.TAM_IsTechnical__c = true and XC_WorkOrder__c  IN :woList ]);


        for(WorkOrder wo : woList){
            for(ProductRequired pr : wo.ProductsRequired){
                for(XC_ProductConsumed__c pc : consumed){
                    if(pr.Product2Id == pc.TAM_Asset__r.Product2Id){
                        assetSerialNumber.put(pc.TAM_Asset__c, pc.TAM_Asset__r.SerialNumber);
                    }
                }
            }
        }

        return assetSerialNumber;


        /*
        Map<String, String> assetSerialNumber = new Map<String, String>();

        List<String> listIdAsset = new List<String>();
        Map<Id, List<Id>> mapWoidListProd2 = new Map<Id, List<Id>>();
        List<Id> prod2Id = new List<Id>();
        for(WorkOrder wo : woList){
            for(ProductRequired pr : wo.ProductsRequired){
                 if(pr.XC_SerialControlled__c){
                     if(!mapWoidListProd2.containsKey(wo.Id)){
                         mapWoidListProd2.put(wo.Id, new List<Id>());
                         system.debug('Dl+++mapWoidListProd2' + mapWoidListProd2);
                     }
                     mapWoidListProd2.get(wo.Id).add(pr.Product2Id);
                 }
            }
            if(mapWoidListProd2.get(wo.Id)!=null) {
                prod2Id.addAll(mapWoidListProd2.get(wo.Id));
            }
        }     
        
        Map<Id, WorkOrderLineItem> mapWOLI = new Map<Id, WorkOrderLineItem>([
            SELECT Id,WorkOrderId, 
                (
                    SELECT Id, TAM_Asset__r.SerialNumber,TAM_Asset__r.Product2Id 
                    FROM Products_Consumed__r
                    WHERE TAM_Asset__r.Product2Id IN: prod2Id
                ) 
                FROM WorkOrderLineItem 
                WHERE WorkOrderId IN: mapWoidListProd2.keySet()
        ]);
        system.debug('Dl+++mapWOLI' + mapWOLI);
        Map<Id, List<WorkOrderLineItem>> mapWoListWOLI = new Map<Id, List<WorkOrderLineItem>>();
        for(WorkOrderLineItem woli : mapWOLI.values()){
            if(!mapWoListWOLI.containsKey(woli.WorkOrderId)){
                mapWoListWOLI.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
            }
            mapWoListWOLI.get(woli.WorkOrderId).add(woli);
        }
        
        
        for(WorkOrder wo : woList){
            List<WorkOrderLineItem> listWOLI = mapWoListWOLI.get(wo.Id);
            List<Id> listProd2Id = mapWoidListProd2.get(wo.Id);
            if(listWOLI != null) {
                for (WorkOrderLineItem woli : listWOLI) {
                    WorkOrderLineItem workOrderLineItem = mapWOLI.get(woli.Id);
                    List<XC_ProductConsumed__c> listPC = workOrderLineItem.Products_Consumed__r;
                    system.debug('Dl+++listWOLI' + listWOLI);

                    for (XC_ProductConsumed__c pc : listPC) {
                        if (listProd2Id.contains(pc.TAM_Asset__r.Product2Id)) {
                            assetSerialNumber.put(pc.TAM_Asset__c, pc.TAM_Asset__r.SerialNumber);
                            system.debug('Dl+++pc' + pc.TAM_Asset__c);
                            system.debug('Dl+++pc' + pc.TAM_Asset__r.SerialNumber);
                        }

                    }
                }
            }
        } 
        return assetSerialNumber; */
    }

    /**
    * @description processGoodIssue 
    * @param listWO the list new
    * @param mapWorkOrderIdWarehouseId 
    * @param mapProduct2ToProductGlovia  
    */  
    private static List<XC_UTIL_Sobject.WrapperResult> processGoodIssue(List<WorkOrder> listWO, Map<Id, Id> mapWorkOrderIdWarehouseId,  Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        
        List<WorkOrder> listWOB2C = new List<WorkOrder>();
        List<WorkOrder> listWOB2B = new List<WorkOrder>();
        for(WorkOrder wo : listWO){
            if(wo.XC_Segment__c == 'B2C'){
                listWOB2C.add(wo);
            } else {
                listWOB2B.add(wo);
            }
        }
        Map<String, String> assetSerialNumberB2C = new Map<String, String>();
        Map<String, String> assetSerialNumberB2B = new Map<String, String>();
        if(!listWOB2C.isEmpty()){
            assetSerialNumberB2C = getSerialNumber(listWOB2C);
        }
        if(!listWOB2B.isEmpty()){
            assetSerialNumberB2B = getSerialNumberB2B(listWOB2B);
            system.debug('DL+++' + assetSerialNumberB2B);
        }
        Map<String, String> assetSerialNumber =  new Map<String, String>();
        assetSerialNumber.putAll(assetSerialNumberB2C);
        assetSerialNumber.putAll(assetSerialNumberB2B);
        
        //Map<String, String> assetSerialNumber = getSerialNumber(listWO); 
        for(WorkOrder wo : listWO){ 
             // SS 17/06/2020 before was  if(!wo.XC_SentGoodIssue__c && wo.XC_SentToGlovia__c)
            Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
            soWrap.account = wo.AccountId;
            soWrap.warehouse = mapWorkOrderIdWarehouseId.get(wo.Id);
            soWrap.fslWorkOrder = wo.WorkOrderNumber;
            
            soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
            if(wo.Status == Label.XC_CL_Cancelled || wo.Status == Label.XC_CL_CannotComplete || wo.XC_ReCalculateSalesOrder__c){
                soWrap.SalesOrderLineList.addAll(getGoodIssueLineCancelled( wo, mapProduct2ToProductGlovia,assetSerialNumber)); 
            }else{
                soWrap.SalesOrderLineList.addAll(getGoodIssueLine( wo, mapProduct2ToProductGlovia,assetSerialNumber));  
            }  
            soWrapList.add(soWrap);                
            
        }
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        if(goodsIssueResponse==null){
            return wrapperResultList;
        }
        if(goodsIssueResponse.isSuccess){
            XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'SalesOrder success'); 
        }else{
            if(goodsIssueResponse.errorList[0].errorMsg != null){
                XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
                wrapperResult.errorMessage = goodsIssueResponse.errorList[0].errorMsg;
                wrapperResultList.add(wrapperResult);
            }
        }
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
        return wrapperResultList;
    } 
    

    /**
    * @description getWorkOrder
    * @param listWorkOrderIds - List<Id>
    * @return Map<Id,WorkOrder>
    */  
    private static Map<Id, WorkOrder> getWorkOrder(List<Id> listWorkOrderIds){
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>(
            [SELECT Id, XC_Segment__c, CurrencyIsoCode,XC_AssignedPartner__c,AccountId,WorkOrderNumber,XC_SerialNumber__c, Status, XC_ReCalculateSalesOrder__c, // SS 17/06/2020 before also  XC_SentGoodIssue__c,XC_SentToGlovia__c
            (SELECT Id, Product2Id,XC_Concat_AssetId__c,ProductRequiredNumber,XC_Asset__c,XC_Asset__r.SerialNumber, XC_ProcurementType__c, 

                  QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c, XC_SerialControlled__c FROM ProductsRequired WHERE XC_Mode__c = 'Add')
                 FROM WorkOrder 
                 WHERE Id IN: listWorkOrderIds]
            );
        return mapWO;  
    }

    /**
    * @description getGoodIssueLineCancelled
    * @param wo - WorkOrder wo
    * @param mapProduct2ToProductGlovia - Map<Id,gii__Product2Add__c>
    * @param assetSerialNumber - Map<String, String>
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
    * @description getGloviaProduct
    * @param product2 - List<String>
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
    * @param mapWorkOrder - Map<Id, WorkOrder>
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

    /********************************************* CreateGoodIssueRepair **************************************************************/    
    
    /**
    * @description createGoodIssueRepair
    * @author FSL Team - marco.rosa@nttdata.com
    * @param listWo - List<WorkOrder>
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> createGoodIssueRepair(List<WorkOrder> listWo){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listWo, 'XC_AssignedPartner__c');
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWo); 
        if(listPartnerIds.isEmpty()){
            return wrapperResultList;
        }        
        Map<Id, Id> mapWorkOrderIdWarehouseId = XC_UTIL_Glovia.getMapWorkOrderWarehouse(listWo); //XC_TR_WorkOrder_U_CreateGoodIssue.getMapPartnerWarehouse(listPartnerIds);
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
            return wrapperResultList;
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
            return wrapperResultList;
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
            SELECT Id, gii__ProductReference__c ,gii__ProductCode__c, gii__SerialControlled__c,
                (SELECT id, gii__ProductReference__c, gii__ProductCode__c, gii__SerialControlled__c
                FROM gii__ProductStyleReferences__r) 
            FROM gii__Product2Add__c 
            WHERE gii__ProductCode__c IN : techProd AND giic_LegalEntity__c = :listWo[0].XC_LegalEntity__c
        AND gii__ProductReference__r.XC_ProductSubType__c = 'Enel Spare Part']
        ); 
        if(!prGloviaMap.values().isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap.values()){
                prodCodeToGlovia.put(pr.gii__ProductCode__c, pr);
            }
        }else{ 
            return wrapperResultList; 
        }
         
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>(); 
        Map<String, String> assetSerialNumber = new  Map<String, String>();
        for(NE__Order__c order : neOrders){ 
            if(mapOrderAssetItem.containskey(order.Id)){                
                Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
                soWrap.account = order.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c;
                soWrap.warehouse = mapWorkOrderIdWarehouseId.get(order.NE__OptyId__r.XC_WorkOrder__c);
                soWrap.fslWorkOrder = order.NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber ; 
                soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
                
                if(order.NE__OptyId__r.XC_WorkOrder__r.Status == Label.XC_CL_Cancelled || order.NE__OptyId__r.XC_WorkOrder__r.Status == Label.XC_CL_CannotComplete ){
                    soWrap.SalesOrderLineList.addAll(getGoodIssueLineCancelled( mapOrderAssetItem.get(order.Id),prodCodeToGlovia));
                    system.debug('@@@@@@@  soWrap.SalesOrderLineList Cancelled' +  soWrap.SalesOrderLineList); 
                }else{
                    soWrap.SalesOrderLineList.addAll(getGoodIssueLine(mapOrderAssetItem.get(order.Id),prodCodeToGlovia)); 
                    system.debug('@@@@@@@  soWrap.SalesOrderLineList' +  soWrap.SalesOrderLineList); 
                } 
                soWrapList.add(soWrap);
            }
        }
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        if(goodsIssueResponse.isSuccess){ 
            XC_UTIL_Sobject.WrapperResult wrSuccess = new XC_UTIL_Sobject.WrapperResult();
            wrSuccess.success = true;
            wrapperResultList.add(wrSuccess);
        }else{
            if(goodsIssueResponse.errorList[0].errorMsg != null){
                XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
                wrapperResult.errorMessage = goodsIssueResponse.errorList[0].errorMsg;
                wrapperResultList.add(wrapperResult);
            }
        }
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
        return wrapperResultList;
    } 
     
      /**
    * @description getGoodIssueLineCancelled
    * @param assetItem - List<NE__AssetItemAttribute__c>
    * @param prodCodeToGlovia - Map<String,gii__Product2Add__c>
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLineCancelled(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>(); 
        for(NE__AssetItemAttribute__c asset : assetItem){
            if(prodCodeToGlovia.containskey(asset.NE__Value__c)){
                gii__Product2Add__c prGlovia = prodCodeToGlovia.get(asset.NE__Value__c);
                Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
                sol.product = prGlovia.Id ;  
                sol.productRequiredID = 'PREQ-'+asset.NE__Value__c;
                sol.orderQuantity = asset.NE__Asset__r.Quantity;
                sol.consumedQuantity = 0; 
                salesOrderLineList.add(sol);
                //create extra products
                for(gii__Product2Add__c prGloviaChild : prGlovia.gii__ProductStyleReferences__r){ 
                    Giic_GoodsIssueSO.SalesOrderLine solC = new Giic_GoodsIssueSO.SalesOrderLine();
                    solC.product = prGloviaChild.Id ;  
                    solC.productRequiredID = 'PREQ-'+prGloviaChild.gii__ProductCode__c; 
                    solC.orderQuantity = asset.NE__Asset__r.Quantity;
                    solC.consumedQuantity = 0; 
                    salesOrderLineList.add(solC);
                }
            }
        }
       return salesOrderLineList;
    }
          /**
    * @description getGoodIssueLineCancelled
    * @param assetItem - List<NE__AssetItemAttribute__c>
    * @param prodCodeToGlovia - Map<String, gii__Product2Add__c> 
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */  
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>(); 
        for(NE__AssetItemAttribute__c asset : assetItem){
            if(prodCodeToGlovia.containskey(asset.NE__Value__c)){
                gii__Product2Add__c prGlovia = prodCodeToGlovia.get(asset.NE__Value__c);
                Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
                sol.product = prGlovia.Id ;  
                sol.productRequiredID = 'PREQ-'+asset.NE__Value__c;
                sol.isSerialControlled = prGlovia.gii__SerialControlled__c;
                sol.isLotControlled = false;
                sol.orderQuantity = asset.NE__Asset__r.Quantity;
                sol.consumedQuantity = asset.NE__Asset__r.Quantity; 
                sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
                Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                if(sol.isSerialControlled){
                    serials.serialNumber =  asset.NE__Asset__r.SerialNumber; 
                    sol.assignedSerials.add(serials); 
                }
                salesOrderLineList.add(sol); 
                //create extra products
                for(gii__Product2Add__c prGloviaChild : prGlovia.gii__ProductStyleReferences__r){ 
                    Giic_GoodsIssueSO.SalesOrderLine solC = new Giic_GoodsIssueSO.SalesOrderLine();
                    solC.product = prGloviaChild.Id ;  
                    solC.productRequiredID = 'PREQ-'+prGloviaChild.gii__ProductCode__c; 
                    solC.isSerialControlled = prGloviaChild.gii__SerialControlled__c;
                    solC.isLotControlled = false;
                    solC.orderQuantity = asset.NE__Asset__r.Quantity;
                    solC.consumedQuantity = asset.NE__Asset__r.Quantity; 
                    solC.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
                    Giic_GoodsIssueSO.AssignedSerial serialsC = new Giic_GoodsIssueSO.AssignedSerial();
                    if(solC.isSerialControlled){
                        serialsC.serialNumber = asset.NE__Asset__r.SerialNumber;  
                        solC.assignedSerials.add(serialsC); 
                    }                   
                    salesOrderLineList.add(solC); 
                }
            }
        }
       return salesOrderLineList;
    }

    /**
    * @description createGoodIssueFromSalesOrder
    * @author FSL Team - marco.rosa@nttdata.com
    * @param listWo - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    /*public static List<XC_UTIL_Sobject.WrapperResult> createGoodIssueFromSalesOrder(List<WorkOrder> listWo){
        XC_UTIL_Sobject.WrapperResult wrapperResult = new  XC_UTIL_Sobject.WrapperResult();
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listWo, 'XC_AssignedPartner__c');
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWo); 
        if(listPartnerIds.isEmpty()){
            wrapperResult.errorMessage = 'Missing assigned partner on Work Order';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }        
        Map<Id, Id> mapWorkOrderIdWarehouseId = XC_UTIL_Glovia.getMapWorkOrderWarehouse(listWo);//getMapPartnerWarehouse(listPartnerIds);
        Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds); 
        Map<Id,String> product2 = createProductList(mapWorkOrder); 
        if(product2.values().isEmpty()){
            wrapperResult.errorMessage = 'Missing product required on Work Order';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }
        Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia = new Map<Id,gii__Product2Add__c> ();
        Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2.values());

        if(prGloviaMap.values().isEmpty()){
            wrapperResult.errorMessage = 'Product not configured';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }             
        for(gii__Product2Add__c pr : prGloviaMap.values()){
            mapProduct2ToProductGlovia.put(pr.gii__ProductReference__c, pr);
        }
        wrapperResultList = processGoodIssue(mapWorkOrder.values(), mapWorkOrderIdWarehouseId, mapProduct2ToProductGlovia);
        return wrapperResultList;
    }*/
    
    public static List<XC_UTIL_Sobject.WrapperResult> createGoodIssueFromSalesOrder(List<WorkOrder> listWo){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<WorkOrder> listWoWithPartner = new List<WorkOrder>();
        for(WorkOrder wo : listWo){
            if(wo.XC_AssignedPartner__c != null){
                listWoWithPartner.add(wo);
            } else {
                wrapperResultList.add(createWrapperError(wo.Id, 'Missing assigned partner on Work Order'));
            }
        }
        Map<Id, Id> mapWorkOrderIdWarehouseId = XC_UTIL_Glovia.getMapWorkOrderWarehouse(listWoWithPartner);
        List<WorkOrder> listWoWithWarehouse = new List<WorkOrder>();
        
        for(WorkOrder wo : listWoWithPartner){
            if(mapWorkOrderIdWarehouseId.containsKey(wo.Id)){
                listWoWithWarehouse.add(wo);
            } else {
                wrapperResultList.add(createWrapperError(wo.Id, 'Missing warehouse'));
            }
        }
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWoWithWarehouse);         
        Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds);
        Map<Id, WorkOrder> mapWorkOrderWithProducts = new Map<Id, WorkOrder>();
        for(WorkOrder wo : mapWorkOrder.values()){
            if(!wo.ProductsRequired.isEmpty()){
                mapWorkOrderWithProducts.put(wo.Id, wo);
            } else {
                wrapperResultList.add(createWrapperError(wo.Id, 'Missing product required on Work Order'));
            }
        }
        Map<Id,String> product2 = createProductList(mapWorkOrderWithProducts); 
        Map<Id,gii__Product2Add__c> mapProduct2ToProductGlovia = new Map<Id,gii__Product2Add__c> ();
        Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2.values());
        for(gii__Product2Add__c pr : prGloviaMap.values()){
            mapProduct2ToProductGlovia.put(pr.gii__ProductReference__c, pr);
        }
        Map<Id, WorkOrder> mapWorkOrderWithGloviaProducts = new Map<Id, WorkOrder>();
        for(WorkOrder wo : mapWorkOrderWithProducts.values()){
            Boolean found = false;
            for(ProductRequired pr : wo.ProductsRequired){
                if(mapProduct2ToProductGlovia.containsKey(pr.Product2Id)){
                    found = true;
                    break;
                }
            }
            if(found){
                mapWorkOrderWithGloviaProducts.put(wo.Id, wo);
            } else {
                wrapperResultList.add(createWrapperError(wo.Id, 'Product not configured'));
            }
        }
        wrapperResultList = processGoodIssue(mapWorkOrderWithGloviaProducts.values(), mapWorkOrderIdWarehouseId, mapProduct2ToProductGlovia);
        return wrapperResultList;
    }  
    
    @TestVisible
    private static XC_UTIL_Sobject.WrapperResult createWrapperError(String recordId, String errorMessage){
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.errorMessage = errorMessage;
        wr.recordId = recordId;
        return wr;
    }  

}