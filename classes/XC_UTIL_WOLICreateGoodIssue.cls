/**
* @author dpalamides
* @date Creation 10/06/2020
* @description  – XC_UTIL_WOLICreateGoodIssue  -  
*/
public without sharing class XC_UTIL_WOLICreateGoodIssue {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WOCreateGoodIssue');
    private static Map<id,Giic_GoodsIssueSO.SalesOrderLine> existingSOL = new Map<id,Giic_GoodsIssueSO.SalesOrderLine>();
    /**
    * @description createGoodIssueFromSalesOrder
    * @author dpalamides
    * @param listWo - List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> createGoodIssueFromSalesOrder(List<WorkOrderLineItem> listWoli){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listWoli, 'XC_AccountId__c');

        List<Id> listWoliIds = XC_UTIL_Sobject.getIds(listWoli);
        if(listPartnerIds.isEmpty()){
            return wrapperResultList;
        }
        Map<Id, Id> mapWorkOrderIdWarehouseId = getMapWorkOrderLineItemWarehouse(listWoli);//getMapPartnerWarehouse(listPartnerIds);

        Map<Id, WorkOrderLineItem> mapWOLI = getWorkOrderLineItems(listWoliIds);
        if(mapWOLI.values().isEmpty()){
            return wrapperResultList;
        }


        Map<Id,String> product2 = createProductList(mapWOLI);
        if(product2.values().isEmpty()){
            return wrapperResultList;
        }

        List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> listProduct2ToProductGlovia = new List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference>();
        for(Id woId : mapWOLI.keySet()){
            for (XC_ProductConsumed__c pr : mapWOLI.get(woId).Products_Consumed__r){
                XC_UTIL_FSLLogistic.ParamGetGloviaProductReference gloPr = new XC_UTIL_FSLLogistic.ParamGetGloviaProductReference();
                gloPr.productReferenceId = pr.XC_Product2Id__c;
                listProduct2ToProductGlovia.add(gloPr);
            }
        }

        listProduct2ToProductGlovia = XC_UTIL_TechnicalCart.loadProductReferenceFromGlovia(listProduct2ToProductGlovia);
        if(listProduct2ToProductGlovia.isEmpty()){
            return wrapperResultList;
        }
        Map<Id,Id> mapProduct2ToProductGlovia = new Map<Id,Id>();
        for(XC_UTIL_FSLLogistic.ParamGetGloviaProductReference pr : listProduct2ToProductGlovia){
            mapProduct2ToProductGlovia.put(pr.productReferenceId, pr.Id);
        }

        wrapperResultList = processGoodIssue(mapWOLI.values(), mapWorkOrderIdWarehouseId, mapProduct2ToProductGlovia);
        return wrapperResultList;
    }


    public static Map<Id, Id> getMapWorkOrderLineItemWarehouse(List<WorkOrderLineItem> listWOLI) {
        Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();

        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.listWOLI = listWOLI;
            wrapper.operation = 'getMapWorkOrderLineItemWarehouse';
            wrapper.userType = UserInfo.getUserType();
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
            mapWorkOrderIdWarehouseId = response.mapWorkOrderIdWarehouseId;
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }

        /*
        Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
        for(WorkOrderLineItem woli : listWOLI) {
            if(woli.XC_AccountId__c!=null && woli.XC_ShipToStateProvince__c!=null) {
                if (!mapAccountProvinces.containsKey(woli.XC_AccountId__c)) {
                    mapAccountProvinces.put(woli.XC_AccountId__c, new List<String>());
                }
                mapAccountProvinces.get(woli.XC_AccountId__c).add(woli.XC_ShipToStateProvince__c);
            }
        }
        if(mapAccountProvinces.isEmpty()) {
            return mapWorkOrderIdWarehouseId;
        }

        Map<String, gii__Warehouse__c> mapKeyWarehouse = XC_UTIL_Glovia.getMapWarehouses(mapAccountProvinces);
        for(WorkOrderLineItem woli : listWOLI) {
            if(woli.XC_ShipToStateProvince__c != null && mapKeyWarehouse.containsKey(woli.XC_ShipToStateProvince__c+'_'+woli.XC_AccountId__c)) {
                Id warehouseId = mapKeyWarehouse.get(woli.XC_ShipToStateProvince__c+'_'+woli.XC_AccountId__c).Id;
                mapWorkOrderIdWarehouseId.put(woli.Id, warehouseId);
            }
        }*/
        return mapWorkOrderIdWarehouseId;
    }

    private static Map<id,WorkOrderLineItem> getMaterialSupplyByGoodsIssue(List<WorkOrderLineItem> goodsIssueWoli){
        List<String> woList = new List<String>(); //XC_UTIL_Sobject.getListFieldValues(goodsIssueWoli,'workOrderId');
        List<String> woliDirectLookupList = new List<String>();
        for(WorkOrderLineItem woli : goodsIssueWoli){
            woList.add(woli.workOrder.RootWorkOrderId);
            woliDirectLookupList.add(woli.XC_MaterialRequest__c);
        }
        Map<id,WorkOrderLineItem> retMap = new Map<id,WorkOrderLineItem>();
        Map<id,WorkOrderLineItem> matReqMap = new Map<id,WorkOrderLineItem>(
            [select id,XC_WarehouseId__c,XC_Project_Task__c, XC_Project_Task__r.XC_OrderItem__c,WorkOrder.WorkOrderNumber, workOrderId,LineItemNumber,
                    (select id, ProductRequiredNumber from Products_Required__r)
               from WorkOrderLineItem where id in :woliDirectLookupList or (workOrderId in :woList and RecordType.developername like '%_MR_WOLI')]
        );
        //workOrder.XC_Project_Task__c, workOrder.XC_Project_Task__r.XC_OrderItem__c
        for(WorkOrderLineItem gi : goodsIssueWoli){
            for(WorkOrderLineItem mr : matReqMap.values()){
                if((mr.XC_Project_Task__r.XC_OrderItem__c == null && gi.workOrder.RootWorkOrderId == mr.workOrderId) ||
                   (mr.XC_Project_Task__r.XC_OrderItem__c != null && gi.workOrder.XC_Project_Task__r.XC_OrderItem__c == mr.XC_Project_Task__r.XC_OrderItem__c)){
                    retMap.put(gi.Id,mr); //key goodsIssue - value material supply
                }
                if(gi.XC_MaterialRequest__c == mr.Id){
                    retMap.put(gi.Id,mr);
                    break;
                }
            }
        }
        return retMap;
    }

    /**
    * @description processGoodIssue 
    * @param listWO the list new
    * @param mapWorkOrderIdWarehouseId 
    * @param mapProduct2ToProductGlovia  
    */
    private static List<XC_UTIL_Sobject.WrapperResult> processGoodIssue(List<WorkOrderLineItem> listWOLI, Map<Id, Id> mapWorkOrderIdWarehouseId,  Map<Id,Id> mapProduct2ToProductGlovia){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        
        List<WorkOrderLineItem> listWOLIB2B = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem wo : listWOLI){
            listWOLIB2B.add(wo);
        }
        Map<String, String> assetSerialNumber = new Map<String, String>();

        if(!listWOLIB2B.isEmpty()){
            assetSerialNumber = getSerialNumberB2B(listWOLIB2B);
        }

        Map<id,WorkOrderLineItem> materialSupplyByGoodsIssue = getMaterialSupplyByGoodsIssue(listWOLIB2B);

        //Map<String, String> assetSerialNumber = getSerialNumber(listWO);
        List<WorkOrderLineItem> woNewList = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem wo : listWOLI){
            WorkOrderLineItem matReqWoli = materialSupplyByGoodsIssue.get(wo.Id);
            Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
            soWrap.account = wo.XC_AccountId__c;
            soWrap.lastGoodIssue = wo.XC_LastWoliCheck__c;
            soWrap.warehouse = matReqWoli.XC_WarehouseId__c!=null ? matReqWoli.XC_WarehouseId__c : mapWorkOrderIdWarehouseId.get(wo.Id) != null ? mapWorkOrderIdWarehouseId.get(wo.Id) : wo.XC_WarehouseId__c;
            soWrap.fslWorkOrderLineItem = matReqWoli!=null ? matReqWoli.Id : null; //si deve mettere il WOLI di material supply su cui c'è il sales order
            soWrap.fslWorkOrder = '';//matReqWoli!=null ? matReqWoli.WorkOrder.WorkOrderNumber : null;

            soWrap.salesOrderLineListForWOLI = new List<Giic_GoodsIssueSO.SalesOrderLine>();
            soWrap.salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
            if(wo.Status == Label.XC_CL_Cancelled || wo.Status == Label.XC_CL_CannotComplete ){
                soWrap.salesOrderLineList.addAll(getGoodIssueLineCancelled( wo, mapProduct2ToProductGlovia,assetSerialNumber));
            }else{
                soWrap.salesOrderLineList.addAll(getGoodIssueLine( wo, mapProduct2ToProductGlovia,soWrap));
            }
            system.debug('soWrap--'+soWrap);
            system.debug('soWrap.SalesOrderLineList--'+soWrap.salesOrderLineList);
            system.debug('soWrap.salesOrderLineListForWOLI--'+soWrap.salesOrderLineListForWOLI);
            WorkOrderLineItem woNew = new WorkOrderLineItem();
            woNew.Id = wo.Id;
            //woNew.XC_SentGoodIssue__c = true; // SS 17/06/2020
            //if(woNew.XC_LastWoliCheck__c == true) {
                woNew.Status = 'Completed';
            //}
            woNewList.add(woNew);
            soWrapList.add(soWrap);

        }
        //Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList); //TODO workaround
        XC_UTIL_ResultWrapper goodsIssueResponse = createGoodsIssueGlovia(soWrapList);
        if(goodsIssueResponse!=null && goodsIssueResponse.success){
            //XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            //XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            wrapperResultList = XC_UTIL_Sobject.updateListRecords(woNewList);

            XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
            wrapperResult.success = true;
            wrapperResult.errorMessage = null;
            wrapperResultList.add(wrapperResult);
            //XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            //XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }else{
            if(goodsIssueResponse!=null && goodsIssueResponse.resultMessage != null){
                XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
                wrapperResult.success = false;
                wrapperResult.errorMessage = goodsIssueResponse.resultMessage;
                wrapperResultList.add(wrapperResult);
            }
            else{
                XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
                wrapperResult.success = false;
                //wrapperResult.errorMessage = goodsIssueResponse.resultMessage;
                wrapperResultList.add(wrapperResult);
            }
        }
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
        return wrapperResultList;
    }


    public static XC_UTIL_ResultWrapper createGoodsIssueGlovia (List<Giic_GoodsIssueSO.SalesOrder> soWrapList){

        XC_UTIL_ResultWrapper resWrapper = new  XC_UTIL_ResultWrapper();
        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.wrapperToGloviaGoodIssueSO = soWrapList;
            wrapper.operation = 'createGoodsIssueGlovia';
            wrapper.userType = UserInfo.getUserType();
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);

            /*List<XC_UTIL_TechnicalCart.paramToGloviaSoli> wrapperToGloviaSoli= new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>();
            wrapperToGloviaSoli = XC_UTIL_TechnicalCart.setSendGlovia(wrapperToGloviaSoli,inputWrapper.listProductRequired,inputWrapper.pRGlovia);
            system.debug('@@@@ getAllProductRequired - wrapperToGlovia:' + wrapperToGloviaSoli);
            system.debug('@@@@ getAllProductRequired - inputWrapper.wrapperToGloviaSO:' + inputWrapper.wrapperToGloviaSO);
            resWrapper = XC_UTIL_TechnicalCart.CreateSOSOLIGlovia(wrapperToGloviaSoli,inputWrapper.wrapperToGloviaSO, inputWrapper.listProductRequired);
            */

            resWrapper.success = response.success;
            resWrapper.resultMessage = response.message;// + ' ' +  response.errorMessageList;
            //System.debug('*Donato* '+ response.errorMessageList);
            /*for(String s : response.errorMessageList){
                System.debug('*Donato* '+ s);
            }*/
            if(!response.errorMessageList.isEmpty()){
                resWrapper.success = false;
                resWrapper.resultMessage = String.valueOf(response.errorMessageList);
            }


        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return resWrapper;
    }

    /**
    * @description getGoodIssueLine
    * @param wo - WorkOrder
    * @param mapProduct2ToProductGlovia - Map<Id,gii__Product2Add__c> 
    * @param assetSerialNumber - Map<String, String> assetSerialNumber
    * @return List<Giic_GoodsIssueSO.SalesOrderLine>
    */
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(WorkOrderLineItem wo, Map<Id,Id> mapProduct2ToProductGlovia, Giic_GoodsIssueSO.SalesOrder soWrap){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        //   Map<String, String> assetSerialNumber = getSerialNumber(wo);

        for(XC_ProductConsumed__c pr : wo.Products_Consumed__r){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            if(!existingSOL.containsKey(pr.XC_Product2Id__c)){
                sol.product = mapProduct2ToProductGlovia.get(pr.XC_Product2Id__c);
                sol.productConsumedID = pr.XC_ProductRequired__r.XC_FromConsumed__c ? String.valueOf(pr.XC_ProductRequired__c) : (pr.XC_ProductRequired__r.ProductRequiredNumber != null ? pr.XC_ProductRequired__r.ProductRequiredNumber : pr.XC_ProductConsumedNumber__c); //pr.XC_ProductRequired__r.ProductRequiredNumber != null ? pr.XC_ProductRequired__r.ProductRequiredNumber : pr.XC_ProductConsumedNumber__c;
                sol.productRequiredID = pr.XC_ProductRequired__r.XC_FromConsumed__c ? String.valueOf(pr.XC_ProductRequired__c) : (pr.XC_ProductRequired__r.ProductRequiredNumber != null ? pr.XC_ProductRequired__r.ProductRequiredNumber : pr.XC_ProductConsumedNumber__c); //pr.XC_ProductRequired__r.ProductRequiredNumber; //pr.XC_ProductConsumedNumber__c;
                // isSerialControlled , productConsumedID
                sol.orderQuantity = pr.XC_OrderQuantity__c;
                sol.wbe = pr.XC_WBE__c;
                //sol.openQuantity = pr.XC_QuantityConsumed__c;//pr.XC_OrderQuantity__c;
                sol.warehouse = soWrap.warehouse; // mapWorkOrderIdWarehouseId.get(wo.Id) != null ? mapWorkOrderIdWarehouseId.get(wo.Id) : wo.XC_WarehouseId__c;
                sol.consumedQuantity = pr.XC_QuantityConsumed__c;
                //Assigning Serial. As consumed Quantity is two so need to assigned two quantity
                List<String> assetList = new List<String>();
                sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>();
                sol.lstAssignedLot =  new List<Giic_GoodsIssueSO.ProductLot>();
                /*if(mapProduct2ToProductGlovia.get(pr.Product2Id).gii__SerialControlled__c){
                    assetList = (pr.XC_Concat_AssetId__c).split(';');
                    for(String assetID : assetList){
                        Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                        serials.serialNumber = assetSerialNumber.get(assetID);   //Adding first Serial
                        sol.assignedSerials.add(serials);

                    }
                }*/
                if(pr.XC_LotNumber__c != null) {
                    Giic_GoodsIssueSO.ProductLot lots = new Giic_GoodsIssueSO.ProductLot();
                    lots.lotNumber = pr.XC_LotNumber__c;
                    lots.lotQty = Integer.valueOf(pr.XC_QuantityConsumed__c);
                    sol.lstAssignedLot.add(lots);
                } else if((pr.TAM_Asset__r != null && pr.TAM_Asset__r.SerialNumber!= null) ||  pr.XC_SerialNumber__c!=null) {
                    Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                    serials.serialNumber = pr.TAM_Asset__r != null ? pr.TAM_Asset__r.SerialNumber : pr.XC_SerialNumber__c;   //Adding first Serial
                    sol.assignedSerials.add(serials);
                    sol.isSerialControlled = true;
                }
                salesOrderLineList.add(sol);
            }else{
                sol = existingSOL.get(pr.XC_Product2Id__c);
                sol.orderQuantity = (sol.orderQuantity != null ? sol.orderQuantity : 0) + (pr.XC_OrderQuantity__c != null ? pr.XC_OrderQuantity__c : 0);
                sol.consumedQuantity = (sol.consumedQuantity != null ? sol.consumedQuantity : 0) + (pr.XC_QuantityConsumed__c != null ? pr.XC_QuantityConsumed__c : 0);
            }
            existingSOL.put(pr.XC_Product2Id__c,sol);
        }
        return salesOrderLineList;
    }

    /**
     * @description getGoodIssueLineCancelled
     * @param wo - WorkOrder wo
     * @param mapProduct2ToProductGlovia - Map<Id,gii__Product2Add__c>
     * @param assetSerialNumber - Map<String, String>
     * @return List<Giic_GoodsIssueSO.SalesOrderLine>
     */
    private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLineCancelled(WorkOrderLineItem wo, Map<Id,Id> mapProduct2ToProductGlovia, Map<String, String> assetSerialNumber ){
        List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        // Map<String, String> assetSerialNumber = getSerialNumber(wo);

        for(XC_ProductConsumed__c pr : wo.Products_Consumed__r){
            Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
            sol.product = mapProduct2ToProductGlovia.get(pr.XC_Product2Id__c) ;
            sol.productRequiredID = pr.Id;
            sol.orderQuantity = pr.XC_OrderQuantity__c;
            sol.consumedQuantity = 0;
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

    private static Map<String, String> getSerialNumberB2B(List<WorkOrderLineItem> listWOLI){
        Map<String, String> assetSerialNumber = new Map<String, String>();

            for(WorkOrderLineItem workOrderLineItem : listWOLI){

                List<XC_ProductConsumed__c> listPC = workOrderLineItem.Products_Consumed__r;

                for(XC_ProductConsumed__c pc : listPC){
                    assetSerialNumber.put(pc.TAM_Asset__c, pc.TAM_Asset__r.SerialNumber );
                }
            }

        return assetSerialNumber;
    }

    /**
    * @description getWorkOrder
    * @param listWorkOrderIds - List<Id>
    * @return Map<Id,WorkOrder>
    */
    private static Map<Id, WorkOrderLineItem> getWorkOrderLineItems(List<Id> listWoliIds){
        Map<Id, WorkOrderLineItem> mapWO = new Map<Id, WorkOrderLineItem>(
        [SELECT Id, XC_MaterialRequest__c,CurrencyIsoCode,XC_AccountId__c,WorkOrderId, workOrder.RootWorkOrderId, Status,WorkOrder.WorkOrderNumber,LineItemNumber,XC_LastWoliCheck__c,XC_WarehouseId__c,workOrder.XC_Project_Task__c, workOrder.XC_Project_Task__r.XC_OrderItem__c,
        (SELECT Id, Name, CurrencyIsoCode,  XC_WorkOrderLineItem__c, XC_WorkOrder__c, XC_UnitPrice__c, XC_QuantityConsumed__c, XC_ProductRequired__c,XC_ProductRequired__r.ProductRequiredNumber, XC_ProductConsumedNumber__c, XC_ProductConsumedExternalID__c, XC_POPos__c, XC_IndexWOLI__c,XC_ProductRequired__r.XC_FromConsumed__c,
                       XC_FinalDelivery__c, XC_Description__c, XC_CreatedDate__c, XC_CostCenter__c, XC_WBE__c, XC_productConsumedID__c, XC_assignedSerials__c, TAM_Asset__c, TAM_Asset__r.SerialNumber, XC_OrderQuantity__c, XC_Product2Id__c, XC_LotNumber__c, XC_SerialNumber__c,XC_WorkOrderLineItem__r.XC_WarehouseId__c
                from Products_Consumed__r where XC_QuantityConsumed__c > 0)
        FROM WorkOrderLineItem
        WHERE Id IN: listWoliIds]
        );
        return mapWO;
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
    private static Map<Id,String>  createProductList(Map<Id, WorkOrderLineItem> mapWOLI){
        Map<Id,String> product2 = new Map<Id, String >();
        for(Id woId : mapWOLI.keySet()){
            for (XC_ProductConsumed__c pr : mapWOLI.get(woId).Products_Consumed__r){
                product2.put(pr.Id, pr.XC_Product2Id__c);
            }
        }
        return product2;
    }

    /********************************************* CreateGoodIssueRepair **************************************************************/

    /**
    * @description createGoodIssueRepair
    * @author dpalamides
    * @param listWo - List<WorkOrder>
    **/
    /*public static List<XC_UTIL_Sobject.WrapperResult> createGoodIssueRepair(List<WorkOrder> listWo){
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
                SELECT Id, gii__ProductReference__c ,gii__ProductCode__c
                FROM gii__Product2Add__c
                WHERE gii__ProductCode__c IN : techProd
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
        List<WorkOrder> woNewList = new List<WorkOrder>();
        for(NE__Order__c order : neOrders){
            if(mapOrderAssetItem.containskey(order.Id)){
                Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
                soWrap.account = order.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c;
                soWrap.warehouse = mapWorkOrderIdWarehouseId.get(order.NE__OptyId__r.XC_WorkOrder__c);
                soWrap.fslWorkOrder = ''; //order.NE__OptyId__r.XC_WorkOrder__r.WorkOrderNumber ;
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
                // woNew.XC_SentGoodIssue__c = true; // SS 17/06/2020
                woNewList.add(woNew);
                soWrapList.add(soWrap);
            }
        }
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
        if(goodsIssueResponse.isSuccess){
            wrapperResultList = XC_UTIL_Sobject.updateListRecords(woNewList);
        }else{
            if(goodsIssueResponse.errorList[0].errorMsg != null){
                XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
                wrapperResult.errorMessage = goodsIssueResponse.errorList[0].errorMsg;
                wrapperResultList.add(wrapperResult);
            }
        }
        system.debug('*******the Goods issue response is*******'+goodsIssueResponse);
        return wrapperResultList;
    }*/

    /**
  * @description getGoodIssueLineCancelled
  * @param assetItem - List<NE__AssetItemAttribute__c>
  * @param prodCodeToGlovia - Map<String,gii__Product2Add__c>
  * @return List<Giic_GoodsIssueSO.SalesOrderLine>
  */
   /* private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLineCancelled(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia){
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
    }*/
    /**
* @description getGoodIssueLineCancelled
* @param assetItem - List<NE__AssetItemAttribute__c>
* @param prodCodeToGlovia - Map<String, gii__Product2Add__c> 
* @return List<Giic_GoodsIssueSO.SalesOrderLine>
*/
   /* private static List<Giic_GoodsIssueSO.SalesOrderLine> getGoodIssueLine(List<NE__AssetItemAttribute__c> assetItem,Map<String, gii__Product2Add__c> prodCodeToGlovia){
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
    }*/
}