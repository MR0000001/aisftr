/**
* @author FSL Team - marco.rosa@nttdata.com
* @date Creation 15/06/2020
* @description  – XC_UTIL_WOCreateSalesOrder  - Util class to call Glovia services 
*/ 
public without sharing class XC_UTIL_WOCreateSalesOrder {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WOCreateSalesOrder');    


    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @description
    * @date Creation 15/06/2020
    * @param listWorkOrderIds - List<Id> 
    * @return Map<Id, WorkOrder>
    */
    private static Map<Id, WorkOrder> getWorkOrder(List<Id> listWorkOrderIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'class XC_UTIL_WOCreateSalesOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getWorkOrder method');
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>(
               [SELECT Id, XC_FSLAssignmentKey__c, XC_Segment__c, AccountId,Status,XC_LegalEntity__c, Account.Name,WorkOrderNumber,XC_AssignedPartner__c,XC_Address__r.XC_City__c ,XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c,XC_Address__r.XC_StreetNumber__c,
                XC_Address__r.XC_Address__c, XC_Address__r.XC_Stair__c,XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_Door__c, XC_Address__r.XC_Floor__c, XC_WorkTypeCategory__c,Asset.XC_WBE__c ,Asset.XC_CMCostCenter__c,Asset.XC_CostCenter__c,XC_forSATO__c,ParentWorkOrder.XC_WorkTypeCategory__c,ParentWorkOrderId,
                    (SELECT Id , SchedStartTime  FROM ServiceAppointments ),
                    (SELECT Id, Product2Id,Product2.ProductCode, XC_ProcurementType__c, ProductRequiredNumber, QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c, XC_ConcatenatedCostCenter__c, XC_ConcatenatedWBE__c FROM ProductsRequired WHERE XC_Mode__c = 'Add' )
                FROM WorkOrder 
                WHERE Id IN: listWorkOrderIds]
            );
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWorkOrderIds -> ' + listWorkOrderIds);
        return mapWO;  
    }

    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 15/06/2020
    * @description
    * @param product2 - Map<Id, Id>
    * @return Map<Id,Id>
    */
    public static Map<Id,Id> mapProduct2ToProductGlovia(List<String> product2) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTER in class XC_UTIL_WOCreateSalesOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapProduct2ToProductGlovia method');
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c 
            FROM gii__Product2Add__c 
            WHERE gii__ProductReference__c IN : product2]
        );  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prGloviaMap -> ' + prGloviaMap);
        List<gii__Product2Add__c> prGlovia = prGloviaMap.values();
        Map<Id,Id> product2ToProductGlovia = new  Map<Id,Id>();
        if(!prGlovia.isEmpty()){
            for(gii__Product2Add__c pr : prGlovia){
                product2ToProductGlovia.put(pr.gii__ProductReference__c, pr.Id);
            }
        }         
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ product2ToProductGlovia -> ' + product2ToProductGlovia);
        return product2ToProductGlovia;       
    }


    
    /**
    * @description getWorkOrder
    * @param listWorkOrder the list new
    * @return Map<Id,WorkOrder>
    */  
    private static Map<Id, WorkOrder> getWorkOrderParent(List<WorkOrder> listWorkOrder){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getWorkOrderParent method');
        List<Id> woParentList = new List<Id>();
        for(WorkOrder wo : listWorkOrder){
            if(wo.ParentWorkOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution ){
                woParentList.add(wo.ParentWorkOrderId);
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWorkOrder -> ' + listWorkOrder);
        if(woParentList.isEmpty()){
            return new Map<Id, WorkOrder>();
        }
        return new Map<Id, WorkOrder>([SELECT Id,(SELECT Id , SchedStartTime  FROM ServiceAppointments)FROM WorkOrder WHERE Id IN: woParentList]);
    }

    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 15/06/2020
    * @description
    * @param mapWorkOrder - Map<Id, WorkOrder> mapWorkOrder
    * @return List<String>
    **/ 
    private static List<String>  createProductList(Map<Id, WorkOrder> mapWorkOrder){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createProductList method');
        Map<Id,String> product2 = new Map<Id, String >();
        for(Id woId : mapWorkOrder.keySet()){
            for (ProductRequired pr : mapWorkOrder.get(woId).ProductsRequired){
                product2.put(pr.Id, pr.Product2Id);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWorkOrder -> ' + mapWorkOrder);
        return product2.values();
    }

    /**
    * @description createSOLine
    * @param productRequiredList
    * @param wo workorder 
    * @param product2ToGlovia 
    * @return List<giic_CommonWrapper.SalesOrderLine>
    */  
    private static List<giic_CommonWrapper.SalesOrderLine> createSOLine(List<ProductRequired> productRequiredList, WorkOrder wo, Map<Id, Id> product2ToGlovia ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOLine method');
        List<giic_CommonWrapper.SalesOrderLine> solList = new List<giic_CommonWrapper.SalesOrderLine>();  
        if(String.isNotBlank(wo.AssetId)) {
            for(ProductRequired pr : productRequiredList){
                solList.add(createSOLineWrapper(pr.QuantityRequired, product2ToGlovia.get(pr.Product2Id), pr.ProductRequiredNumber, pr.Id, wo.Asset.XC_CMCostCenter__c, wo.Asset.XC_WBE__c));  
            }  
            return solList;
        } else {
            List<WorkOrder> listWoChildWithProdRequired = new List<WorkOrder>([
                SELECT Id, Asset.XC_CMCostCenter__c, Asset.XC_WBE__c,
                    (SELECT Id, Product2Id, QuantityRequired, XC_Asset__c, XC_Concat_AssetId__c, XC_ConcatenatedCostCenter__c, XC_ConcatenatedWBE__c, XC_OwnedByEnelX__c 
                    FROM ProductsRequired 
                    WHERE XC_Mode__c = 'Add' )
                FROM WorkOrder
                WHERE ParentWorkOrderId = :wo.Id
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWoChildWithProdRequired -> ' + listWoChildWithProdRequired);
            Map<String, ProductRequired> mapParentPrId = new Map<String, ProductRequired>();
            Map<String, Decimal> mapKeyQuantity = new Map<String, Decimal>();
            for(ProductRequired parentPr : productRequiredList) {
                mapParentPrId.put(parentPr.Product2Id, parentPr);
            }
            for(WorkOrder woChild : listWoChildWithProdRequired) {
                for(ProductRequired pr : woChild.ProductsRequired) {
                    String key = woChild.Asset.XC_WBE__c + '__' + woChild.Asset.XC_CMCostCenter__c + '__' + pr.Product2Id;
                    if(!mapKeyQuantity.containsKey(key)) {
                        mapKeyQuantity.put(key, 0);
                    } 
                    Decimal newValueQuantity = mapKeyQuantity.get(key)+pr.QuantityRequired;
                    mapKeyQuantity.put(key, newValueQuantity);
                }
            }
            for(String key : mapKeyQuantity.keySet()) {
                List<String> listKeys = key.split('__');
                String wbe = listKeys[0];
                String costCenter = listKeys[1];
                String productId = listKeys[2];
                solList.add(createSOLineWrapper(mapKeyQuantity.get(key), product2ToGlovia.get(productId), mapParentPrId.get(productId).ProductRequiredNumber, mapParentPrId.get(productId).Id, costCenter, wbe));
            }
            return solList;
        }
    }
    
    @TestVisible
    private static giic_CommonWrapper.SalesOrderLine createSOLineWrapper(Decimal orderQuantity, String productId, String productRequiredID, String prReqID, String costCenter, String wbe){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOLineWrapper method');
        giic_CommonWrapper.SalesOrderLine solObj = new giic_CommonWrapper.SalesOrderLine();
        solObj.orderQuantity = orderQuantity; 
        solObj.productId = productId; 
        solObj.productRequiredID = productRequiredID; 
        solObj.prReqID = prReqID;
        solObj.costCenter = costCenter;
        solObj.wbElement = wbe;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ solObj -> ' + solObj);
        return solObj;
    }

    /**
    * @description createSOHeaderSupplier 
    * @param wo -  workorder 
    * @param mapWorkOrderIdWarehouseId - Map<Id, Id>
    * @param appointmentDate - Date 
    * @return giic_CommonWrapper.SalesOrderHeader
    */  
    private static giic_CommonWrapper.SalesOrderHeader createSOHeaderDeliveryInstallation(WorkOrder wo, Map<Id, Id> mapWorkOrderIdWarehouseId, Date appointmentDate ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOHeaderDeliveryInstallation method');
        giic_CommonWrapper.SalesOrderHeader soHderObjSupplier = new giic_CommonWrapper.SalesOrderHeader();
        soHderObjSupplier.AccountId = wo.XC_AssignedPartner__c;
        soHderObjSupplier.DirectPurchaseOrder = false;
        soHderObjSupplier.requiredDate = appointmentDate; 
        soHderObjSupplier.OrderDate =  Date.today() ; 
        soHderObjSupplier.warehouseId = mapWorkOrderIdWarehouseId.get(wo.Id);
        soHderObjSupplier.fSLWorkOrder = wo.WorkOrderNumber;
        soHderObjSupplier.workOrderId = wo.Id;

        //soHderObjSupplier.legalEntity = wo.XC_LegalEntity__c;
        //soHderObjSupplier.segment = wo.XC_Segment__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soHderObjSupplier -> ' + soHderObjSupplier);

        return soHderObjSupplier;
    }
    
    /**
    * @description createSOHeaderLogisticPartner 
    * @param wo - WorkOrder
    * @param bestDate - Date
    * @param bestWH - Id
    * @return giic_CommonWrapper.SalesOrderHeader
    */
    @TestVisible
    private static giic_CommonWrapper.SalesOrderHeader createSOHeaderDelivery(WorkOrder wo, Date bestDate, Id bestWH ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOHeaderDelivery method');
        List<gii__Warehouse__c> whVirtual = new List<gii__Warehouse__c>([
            SELECT Id 
            FROM gii__Warehouse__c 
            WHERE giic_LegalEntity__c = :wo.XC_LegalEntity__c
            AND giic_WarehouseType__c = 'Virtual'
            LIMIT 1
        ]);
        giic_CommonWrapper.SalesOrderHeader soHderObjLogistic = new giic_CommonWrapper.SalesOrderHeader();
        soHderObjLogistic.AccountId = wo.AccountId;
        soHderObjLogistic.DirectPurchaseOrder = false;
        soHderObjLogistic.fSLWorkOrder = wo.WorkOrderNumber;
        soHderObjLogistic.workOrderId = wo.Id;
        soHderObjLogistic.requiredDate = bestDate; 
        soHderObjLogistic.OrderDate = Date.today(); 
        if(whVirtual != null && !whVirtual.isEmpty() ){
            soHderObjLogistic.warehouseId =  whVirtual[0].id;
        }
        
        soHderObjLogistic.fromWarehouseId = bestWH;
        soHderObjLogistic.isDelivery = true;
        soHderObjLogistic.shipToName = wo.Account.Name;
        soHderObjLogistic.ShipToCity = wo.XC_Address__r.XC_City__c ; 
        soHderObjLogistic.ShipToCountry = wo.XC_Address__r.XC_AddressCountry__c ; 
        soHderObjLogistic.ShipToStateProvince = wo.XC_Address__r.XC_AddressProvince__c ;
        String floor =  wo.XC_Address__r.XC_Floor__c != null ? ', Floor ' + wo.XC_Address__r.XC_Floor__c : '';
        String door =  wo.XC_Address__r.XC_Door__c != null ? ', Door ' + wo.XC_Address__r.XC_Door__c : '';
        String stair =  wo.XC_Address__r.XC_Stair__c != null ? ', Stair ' + wo.XC_Address__r.XC_Stair__c : '';
        soHderObjLogistic.ShipToStreet = wo.XC_Address__r.XC_Address__c +', '+wo.XC_Address__r.XC_StreetNumber__c + floor + door + stair ; 
        soHderObjLogistic.ShipToZipPostalCode = wo.XC_Address__r.XC_PostalCode__c ; 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soHderObjLogistic -> ' + soHderObjLogistic);
        return soHderObjLogistic;
    }

    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 15/06/2020
    * @description 
    * @param listNew - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static XC_UTIL_Sobject.WrapperResult createSalesOrder(List<WorkOrder> listToCheck) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSalesOrder method');
        List<WorkOrder> listNew = new List<WorkOrder>();
        Map<Id, WorkOrder> mapWorkOrderWithSO = new Map<Id, WorkOrder>([
            SELECT ID, ParentWorkOrderId, 
                (SELECT Id, Product2Id, QuantityRequired,XC_Asset__c, XC_Concat_AssetId__c, XC_ConcatenatedCostCenter__c, XC_ConcatenatedWBE__c 
                FROM ProductsRequired WHERE XC_Mode__c = 'Add' ),
                (SELECT ID FROM Sales_Orders__r)
            FROM Workorder
            WHERE Id IN: listToCheck OR ParentWorkOrderId IN: listToCheck
        ]);
        for(WorkOrder wo : listToCheck){
            if(mapWorkOrderWithSO.containsKey(wo.Id) && mapWorkOrderWithSO.get(wo.Id).ParentWorkOrderId == null && mapWorkOrderWithSO.get(wo.Id).Sales_Orders__r.isEmpty()){
                listNew.add(wo);
            }
        }
        XC_UTIL_Sobject.WrapperResult wrapperResult = new  XC_UTIL_Sobject.WrapperResult();
        if(listNew.isEmpty()){
            wrapperResult.success = true;
            return wrapperResult;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSalesOrder method');
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AssignedPartner__c');
        if(listPartnerIds.isEmpty()){
            wrapperResult.errorMessage = 'Missing assigned partner on Work Order';
            return wrapperResult;
        }

        Map<Id, Id> mapWorkOrderIdWarehouseId =  XC_UTIL_Glovia.getMapWorkOrderWarehouse(listNew);    
        if(mapWorkOrderIdWarehouseId.isEmpty()){
            wrapperResult.errorMessage = 'Missing warehouse';
            return wrapperResult;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWorkOrderIdWarehouseId -> ' + mapWorkOrderIdWarehouseId);
        XC_UTIL_WOCreateSalesOrder_U.createExtraProductRequired(mapWorkOrderWithSO.values());    
        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds);
        Map<Id, WorkOrder> workOrderParent = getWorkOrderParent(mapWorkOrder.values());
        List<String> product2 =  createProductList(mapWorkOrder); 
        if(product2.isEmpty()){
            wrapperResult.errorMessage = 'Missing product required on Work Order';
            return wrapperResult;
        }  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'product2 ' + product2);
        Map<Id,Id> product2ToGlovia = mapProduct2ToProductGlovia(product2); 
        List<giic_CommonWrapper.SalesOrderHeader> soList = new List<giic_CommonWrapper.SalesOrderHeader>(); 
        for(WorkOrder wo : mapWorkOrder.values()){
            giic_CommonWrapper.SalesOrderHeader soHderObjSupplier = new  giic_CommonWrapper.SalesOrderHeader();
            if(wo.ParentWorkOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution ){
                soHderObjSupplier = createSOHeaderDeliveryInstallation( wo, mapWorkOrderIdWarehouseId, Date.valueof(workOrderParent.get(wo.ParentWorkOrderId).ServiceAppointments[0].SchedStartTime)); 
            }else{
                soHderObjSupplier = createSOHeaderDeliveryInstallation( wo, mapWorkOrderIdWarehouseId, Date.valueOf(wo.ServiceAppointments[0].SchedStartTime) ); 
            }           
            soHderObjSupplier.SalesOrderLineList = new List<giic_CommonWrapper.SalesOrderLine>();
            soHderObjSupplier.SalesOrderLineList.addAll(createSOLine(mapWorkOrder.get(wo.Id).ProductsRequired, wo,  product2ToGlovia ));            
            soList.add(soHderObjSupplier);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '§§§§§§§§ ' + soList);
        giic_CommonWrapper.OrderResponse  soCreationResult = giic_SalesOrderUtility.createSalesOrders(soList); 
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        if(soCreationResult.salesOrderNotCreated){
            wr.errorMessage = soCreationResult.errorMessages[0];
            return wr;
        }
        wr.success = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ result call Glovia' + soCreationResult);
        return wr;
    }

     /**
    * @author FSL Team - salvatore.scarpato@nttdata.com
    * @date Creation 18/08/2021
    * @description cancel existing Sales Order
    * @param listNew - WorkOrder
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static XC_UTIL_Sobject.WrapperResult cancelSalesOrder(WorkOrder inputWO) { 
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        List<gii__SalesOrder__c> salesOrderList = new List<gii__SalesOrder__c>([SELECT Id, giic_WorkOrder__c, giic_FSLWorkOrder__c
                                                                                FROM gii__SalesOrder__c 
                                                                                WHERE giic_WorkOrder__c =: inputWo.Id LIMIT 1]);
        if(salesOrderList.isEmpty()){
            wr.success = false;
            wr.errorMessage = 'Sales Order not found';
            return wr;
        }
        List<XC_UTIL_Sobject.WrapperResult> listDMLResultOnCreateGI = XC_UTIL_WOCreateGoodIssue.createGoodIssueFromSalesOrder(new List<WorkOrder>{inputWO});
        for(XC_UTIL_Sobject.WrapperResult wrapperResult : listDMLResultOnCreateGI){
            if(!wrapperResult.success){
                wr.success = false;
                wr.errorMessage = 'Error in good issue creation: ' + wrapperResult.errorMessage;
                return wr;
            } else {
                wr.success = true;
            }
        }
        gii__SalesOrder__c salesOrder = salesOrderList[0];
        salesOrder.giic_FSLWorkOrder__c = '';
        salesOrder.giic_WorkOrder__c = null; 

        XC_UTIL_Sobject.WrapperResult dMLResult = XC_UTIL_Sobject.updateRecord(salesOrder);
        if(!dMLResult.success){
            wr.success = false;
            wr.errorMessage = 'Error in sales order update: ' + dMLResult.errorMessage;
        } else {
            wr.success = true;
        }
        return wr;
    }

    /**
    * @description createSOLine
    * @param neOrder - NE__Order__c
    * @return List<giic_CommonWrapper.SalesOrderLine>
    */  
    private static List<giic_CommonWrapper.SalesOrderLine> createSOLine(NE__Order__c neOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOLine method');
        List<giic_CommonWrapper.SalesOrderLine> solList = new List<giic_CommonWrapper.SalesOrderLine>();  
        Map<Id, NE__AssetItemAttribute__c>  mapAssetItemAtt = new Map<Id, NE__AssetItemAttribute__c>([
            SELECT Id,NE__Value__c,NE__Asset__r.XC_CostCenter__c,  NE__Asset__r.XC_CMCostCenter__c,NE__Asset__r.XC_WBE__c, NE__Asset__r.Quantity,NE__Asset__r.NE__Order_Config__c, NE__Asset__r.XC_Product_Type__c, NE__Asset__r.XC_Product_Subtype__c 
            FROM NE__AssetItemAttribute__c 
            WHERE XC_DeveloperName__c = 'Referencia' AND NE__Asset__r.XC_Product_Type__c = 'Technical' AND NE__Asset__r.XC_Product_Subtype__c = 'Product' AND NE__Asset__r.NE__Order_Config__c = :neOrder.Id
        ]);
        //List<String> techProd = XC_UTIL_Sobject.getListFieldValues(mapAssetItemAtt.values(), 'NE__Value__c');
        Set<String> techProd = new Set<String>();
        for(NE__AssetItemAttribute__c aia : mapAssetItemAtt.values()) {
            if(String.isNotBlank(aia.NE__Value__c) && !aia.NE__Value__c.containsOnly('.')) {
                techProd.add(aia.NE__Value__c);
            }
        }
        if(techProd.isEmpty()){
            return solList;
        }
        Map<String, gii__Product2Add__c> prodCodeToGlovia = new Map<String, gii__Product2Add__c>();
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c ,gii__ProductCode__c,
                (SELECT id, gii__ProductReference__c, gii__ProductCode__c
                FROM gii__ProductStyleReferences__r) 
            FROM gii__Product2Add__c 
            WHERE gii__ProductReference__r.productcode IN : techProd AND gii__ProductReference__r.XC_ProductSubType__c = 'Enel Spare Part' AND giic_LegalEntity__c = :neOrder.XC_LegalEntity__c
        ]); 
        
        if(!prGloviaMap.values().isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap.values()){
                prodCodeToGlovia.put(pr.gii__ProductCode__c, pr);
            }
            for(NE__AssetItemAttribute__c assetItem : mapAssetItemAtt.values()){
                if(prodCodeToGlovia.containsKey(assetItem.NE__Value__c)) {
                    gii__Product2Add__c prGlovia = prodCodeToGlovia.get(assetItem.NE__Value__c);
                    giic_CommonWrapper.SalesOrderLine solObj = new giic_CommonWrapper.SalesOrderLine();
                    solObj.orderQuantity = assetItem.NE__Asset__r.Quantity;  
                    solObj.productId = prGlovia.Id; 
                    solObj.productRequiredID = 'PREQ-'+assetItem.NE__Value__c;  
                    solObj.costCenter = assetItem.NE__Asset__r.XC_CMCostCenter__c;  
                    solObj.wbElement = assetItem.NE__Asset__r.XC_WBE__c;
                    solList.add(solObj);  
                    //create extra products
                    for(gii__Product2Add__c prGloviaChild : prGlovia.gii__ProductStyleReferences__r){
                        giic_CommonWrapper.SalesOrderLine solObjCh = new giic_CommonWrapper.SalesOrderLine();
                        solObjCh.orderQuantity = assetItem.NE__Asset__r.Quantity;  
                        solObjCh.productId = prGloviaChild.Id; 
                        solObjCh.productRequiredID = 'PREQ-'+prGloviaChild.gii__ProductCode__c;  
                        solObjCh.costCenter = assetItem.NE__Asset__r.XC_CMCostCenter__c;  
                        solObjCh.wbElement = assetItem.NE__Asset__r.XC_WBE__c;
                        solList.add(solObjCh); 
                    }
                }
            }
        }  
        return solList;
        }

    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 15/06/2020
    * @description  
    * @param listNew - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static  XC_UTIL_Sobject.WrapperResult  createSalesOrderDelivery(Id woID) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@@#@#');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSalesOrderDelivery method');
        XC_UTIL_Sobject.WrapperResult  wr = new  XC_UTIL_Sobject.WrapperResult();
        List<Id> listWorkOrderIds = new List<Id>();
        listWorkOrderIds.add(woID);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'woId->' + woId);
        
        List<WorkOrder> listNew = new List<WorkOrder>([
            SELECT ID, 
                (SELECT Id, Product2Id, QuantityRequired,XC_Asset__c, XC_Concat_AssetId__c, XC_ConcatenatedCostCenter__c, XC_ConcatenatedWBE__c 
                FROM ProductsRequired WHERE XC_Mode__c = 'Add'),
                (SELECT ID FROM Sales_Orders__r)
            FROM Workorder
            WHERE Id IN: listWorkOrderIds
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listNew -> ' + listNew);
        XC_UTIL_WOCreateSalesOrder_U.createExtraProductRequired(listNew);    

        
        
        Map<Id, WorkOrder> mapWorkOrder = getWorkOrder(listWorkOrderIds);
        if(!mapWorkOrder.values().isEmpty()){
            WorkOrder wo = mapWorkOrder.get(woID);
            List<String> product2 =  createProductList(mapWorkOrder); 
            Map<Id,Id> product2ToGlovia = mapProduct2ToProductGlovia(product2); 
            if(!product2ToGlovia.values().isEmpty() && !wo.ProductsRequired.isEmpty()){ 
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'product list not empty');
                List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>();           
                for(ProductRequired pr : wo.ProductsRequired){
                    Giic_StockAvailabilityUtility.stockAvailabilityWrapper stoclAvailobjwrapper = new Giic_StockAvailabilityUtility.stockAvailabilityWrapper();
                    
                    if(wo.XC_Address__c!=null){
                        stoclAvailobjwrapper.pdtCode = pr.Product2.ProductCode;
                        stoclAvailobjwrapper.province = String.isBlank(wo.XC_FSLAssignmentKey__c) ? '' : wo.XC_FSLAssignmentKey__c.toUpperCase();
                        stoclAvailobjwrapper.zipCode =  wo.XC_Address__r.XC_PostalCode__c ;
                        stoclAvailobjwrapper.legalEntity = wo.XC_LegalEntity__c;
                        stoclAvailobjwrapper.segment = wo.XC_Segment__c;
                        stoclAvailobjwrapper.reqQuantity = pr.QuantityRequired ; 
                        stoclAvailobjwrapper.requestType = Label.giic_StockReqTypeShipment;
                        stoclAvailobjwrapper.country = wo.XC_Address__r.XC_AddressCountry__c ;
                        stockAvailWrappList.add(stoclAvailobjwrapper);
                    }else{
                        System.debug('Work Order must have address associated');
                        wr.errorMessage = 'Work Order must have an address associated';
                        return wr;
                    }
                
                } 
                Date bestDate = null;
                Id bestWH;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'stockAvailWrappList ' + stockAvailWrappList);
                if(!Test.isRunningTest()){
                    List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> availabilityResult = Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
                    for(Giic_StockAvailabilityUtility.StockAvailabilityWrapper w : availabilityResult){                
                        if(w.errorMessage!=null && w.errorMessage!=''){
                            wr.errorMessage = w.errorMessage;
                            return wr;
                        }
                    }
                    if(!availabilityResult.isEmpty() && availabilityResult[0].availabilityTime!=null){
                        bestDate = availabilityResult[0].availabilityTime;
                        if(availabilityResult[0].toWarehouse != null){
                            bestWH = (Id)availabilityResult[0].toWarehouse  ; 
                        }
                    } 
                } else {
                    bestDate = Date.today();
                    bestWH = null;
                } 
                
                List<giic_CommonWrapper.SalesOrderHeader> soList = new List<giic_CommonWrapper.SalesOrderHeader>();
                giic_CommonWrapper.SalesOrderHeader soHderObjSupplier = new  giic_CommonWrapper.SalesOrderHeader(); 
                soHderObjSupplier = createSOHeaderDelivery(wo, bestDate, bestWH);               
                soHderObjSupplier.SalesOrderLineList = new List<giic_CommonWrapper.SalesOrderLine>();
                soHderObjSupplier.SalesOrderLineList.addAll(createSOLine(wo.ProductsRequired, wo,  product2ToGlovia ));            
                soList.add(soHderObjSupplier); 
                giic_CommonWrapper.OrderResponse  soCreationResult = giic_SalesOrderUtility.createSalesOrders(soList); 
                system.debug('@@@@@@@@ result call Glovia' + soCreationResult);
                wo.Status = Label.XC_CL_WorkOrder_InProgress;
                wo.XC_DeliveryDate__c = bestDate;
                wo.XC_forSATO__c = true;
                wo.XC_Digitized__c = true;
                wo.XC_ToBeManuallyDigitalized__c = true;
                if(soCreationResult.salesOrderNotCreated){
                    wr.errorMessage = soCreationResult.errorMessages[0];
                    return wr;
                } 
                wr = XC_UTIL_Sobject.updateRecord(wo);
            }
        }
        return wr;
    } 

    /**
    * @description createSOHeaderSupplier 
    * @param order - NE__Order__c 
    * @param mapWorkOrderIdWarehouseId - Map<Id, Id>
    * @return giic_CommonWrapper.SalesOrderHeader
    */  
    private static giic_CommonWrapper.SalesOrderHeader createSOHeader(NE__Order__c order, Map<Id, Id> mapWorkOrderIdWarehouseId ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSOHeader method');
        giic_CommonWrapper.SalesOrderHeader soHderObj = new giic_CommonWrapper.SalesOrderHeader();
        soHderObj.AccountId = order.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c;
        soHderObj.DirectPurchaseOrder = false;
        soHderObj.requiredDate = Date.today();
        soHderObj.OrderDate =  Date.today();
        soHderObj.warehouseId = mapWorkOrderIdWarehouseId.get(order.NE__OptyId__r.XC_WorkOrder__c);
        soHderObj.fSLWorkOrder = order.NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber  ;
        soHderObj.workOrderId = order.NE__OptyId__r.XC_WorkOrder__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soHderObj -> ' + soHderObj);
        return soHderObj;
    }

    /**
    * @author FSL Team - marco.rosa@nttdata.com
    * @date Creation 15/06/2020
    * @description Method to create Sales Order
    * @param orderID - orderID
    * @return giic_CommonWrapper.OrderResponse
    */ 
    public static giic_CommonWrapper.OrderResponse createSalesOrderFromConfig(ID orderID) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createSalesOrderFromConfig method');
        List<NE__Order__c> neOrders = new List<NE__Order__c>([
            SELECT Id,NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c, XC_LegalEntity__c, Name ,NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber, NE__OptyId__r.XC_WorkOrder__c,NE__OptyId__r.XC_WorkOrder__r.State,
                (SELECT Id, NE__ProdId__c, XC_Wbe__c, XC_CMCostCenter__c,Name,NE__Qty__c
                FROM NE__Order_Items__r)
            FROM NE__Order__c 
            WHERE Id = :orderID
        ]); 
        WorkOrder wo = new WorkOrder(Id= neOrders[0].NE__OptyId__r.XC_WorkOrder__c,
                                    XC_AssignedPartner__c = neOrders[0].NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c,
                                    State = neOrders[0].NE__OptyId__r.XC_WorkOrder__r.State,
                                    XC_LegalEntity__c = neOrders[0].XC_LegalEntity__c);

        Map<Id, Id> mapWorkOrderIdWarehouseId =  XC_UTIL_Glovia.getMapWorkOrderWarehouse(new List<WorkOrder>{wo});   
        List<giic_CommonWrapper.SalesOrderHeader> soList = new List<giic_CommonWrapper.SalesOrderHeader>();
        giic_CommonWrapper.SalesOrderHeader soHderObj = new  giic_CommonWrapper.SalesOrderHeader(); 
        soHderObj = createSOHeader(neOrders[0], mapWorkOrderIdWarehouseId );               
        soHderObj.SalesOrderLineList = new List<giic_CommonWrapper.SalesOrderLine>();
        soHderObj.SalesOrderLineList.addAll(createSOLine(neOrders[0]));   
        if(soHderObj.SalesOrderLineList.isEmpty()) {
            giic_CommonWrapper.OrderResponse respOutput = new giic_CommonWrapper.OrderResponse();
            respOutput.errorMessages = new List<String>{Label.XC_CL_Glovia_ReservationError};
            return respOutput;
        }         
        soList.add(soHderObj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soList -> ' + soList);
        return giic_SalesOrderUtility.createSalesOrders(soList);    //Salvatore Agrillo 25/11/2019
    } 
}