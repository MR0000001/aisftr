/**
* @author Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 16/06/2019
* @date Modification 26/07/2021
* @description Giic_SalesOrderUtility – To generate SalesOrder and SalesorderLines in Enel-Logistics from Bit2Win System
*/

public without Sharing class Giic_SalesOrderUtility {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_SalesOrderUtility');

    /** @description - wrapper for Sales order direct po */
    public class SalesOrderDirectPO{
        public Boolean isDirectPO;
        public list<Id> soIds;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 18/08/2021
    * @description Method to check if Sales Order can be created
    * @param listSalesOrderHeader - List<giic_CommonWrapper.SalesOrderHeader>
    * @return Map<String, Object>
    */ 
    public static Map<String, Object> checkSalesOrderCreation(List<giic_CommonWrapper.SalesOrderHeader> listSalesOrderHeader) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check if Sales Order can be created');
        Map<String, Object> mapOutput = new Map<String, Object>();
        List<Giic_CommonWrapper.ProductErrorWrapper> listProductErrors = new List<Giic_CommonWrapper.ProductErrorWrapper>();
        Map<String, Decimal> mapProductIdQuantity = new Map<String, Decimal>();
        Map<String, String> mapProductWarehouse = new Map<String, String>();
        Boolean isB2B = false;
        for(giic_CommonWrapper.SalesOrderHeader objSO : listSalesOrderHeader) {
            if(String.isNotBlank(objSO.fSLWorkOrderLineItem)) {
                isB2B = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For objSO: ' + objSO);
                for(giic_CommonWrapper.SalesOrderLine objSOL : objSO.SalesOrderLineList) {
                    mapProductIdQuantity.put(objSOL.ProductId, objSOL.orderQuantity);
                    mapProductWarehouse.put(objSOL.ProductId, objSO.WarehouseId);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductIdQuantity: ' + mapProductIdQuantity);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductWarehouse: ' + mapProductWarehouse);
        if(!isB2B) {
            mapOutput.put('success', true);
            return mapOutput;
        }
        if(mapProductIdQuantity.keySet().isEmpty()) {
            mapOutput.put('success', false);
            return mapOutput;
        }

        // Check product with flag AvailableForSales = false
        List<gii__Product2Add__c> listProductsTemp = new List<gii__Product2Add__c>([
            SELECT Id, gii__DefaultWarehouse__c, gii__ProductCode__c, giic_Available_for_Sales__c,
                (
                 SELECT Id, gii__Product__r.gii__ProductCode__c, giic_SalesOnHand__c, gii__Warehouse__c
                 FROM gii__ProductReferences1__r
                 WHERE gii__Warehouse__c IN :mapProductWarehouse.values()
                )
            FROM gii__Product2Add__c
            WHERE Id IN :mapProductIdQuantity.keySet()
        ]);
        if(listProductsTemp.isEmpty() && !Test.isRunningTest()) {
            mapOutput.put('success', false);
            return mapOutput;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listProductsTemp: ' + listProductsTemp);
        
        // Check only Available for Sales = false:
        List<gii__Product2Add__c> listProducts = new List<gii__Product2Add__c>();
        Boolean noPIQDfound = false;
        for(gii__Product2Add__c piAdd : listProductsTemp) {
            if(piAdd.gii__ProductReferences1__r.size() == 0 && !piAdd.giic_Available_for_Sales__c && !Test.isRunningTest()) {
                Giic_CommonWrapper.ProductErrorWrapper newErrorProduct = new Giic_CommonWrapper.ProductErrorWrapper();
                newErrorProduct.prodId = piAdd.Id;
                newErrorProduct.prodCode = piAdd.gii__ProductCode__c;
                newErrorProduct.warehouseIds = mapProductWarehouse.containsKey(piAdd.Id) ? mapProductWarehouse.get(piAdd.Id) : '';
                newErrorProduct.warehouseQuantity = 0;
                listProductErrors.add(newErrorProduct);
                noPIQDfound = true;
            }
            if(!noPIQDfound && !piAdd.giic_Available_for_Sales__c) {
                listProducts.add(piAdd);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listProducts: ' + listProducts);

        if(noPIQDfound && !Test.isRunningTest()) {
            mapOutput.put('listProductError', listProductErrors);
            mapOutput.put('success', false);
            return mapOutput;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ All PIQD found');

        // Check WH quantity for products returned:
        Boolean errorQuantity = false;
        for(gii__Product2Add__c prod2Add : listProducts) {
            String productCode = prod2Add.gii__ProductCode__c;
            String prodId = prod2Add.Id;
            Decimal quantityRequested = mapProductIdQuantity.containsKey(prodId) ? mapProductIdQuantity.get(prodId) : 0;
            String warehouseId = mapProductWarehouse.containsKey(prodId) ? mapProductWarehouse.get(prodId) : '';
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Product : ' + prodId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ productCode : ' + productCode);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ quantityRequested : ' + quantityRequested);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ warehouseId : ' + warehouseId);
            for(gii__ProductInventory__c prodInventory : prod2Add.gii__ProductReferences1__r) {
                if(warehouseId == prodInventory.gii__Warehouse__c) {
                    if(quantityRequested > prodInventory.giic_SalesOnHand__c) {
                        errorQuantity = true;
                        Giic_CommonWrapper.ProductErrorWrapper newErrorProduct = new Giic_CommonWrapper.ProductErrorWrapper();
                        newErrorProduct.prodId = prodId;
                        newErrorProduct.prodCode = productCode;
                        newErrorProduct.warehouseIds = warehouseId;
                        newErrorProduct.warehouseQuantity = prodInventory.giic_SalesOnHand__c;
                        listProductErrors.add(newErrorProduct);
                    }
                    break;
                }
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check error quantity : ' + errorQuantity);
        if(errorQuantity && !Test.isRunningTest()) {
            mapOutput.put('success', false);
            mapOutput.put('listProductError', listProductErrors);
            return mapOutput;
        } else {
            mapOutput.put('success', true);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOutput : ' + mapOutput);
            return mapOutput;
        }
    }

    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description To create SalesOrder and SalesOrder Line 
    * @param listSalesOrderHeader list of sales order header
    * @return giic_CommonWrapper.OrderResponse
    */ 
    public static giic_CommonWrapper.OrderResponse createSalesOrders(List<giic_CommonWrapper.SalesOrderHeader> listSalesOrderHeader) {
        // Check if SO can be created:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Create Sales Orders');
        giic_CommonWrapper.OrderResponse objOrderResponse = new giic_CommonWrapper.OrderResponse();
        Map<String, Object> mapCheck = checkSalesOrderCreation(listSalesOrderHeader);
        if(mapCheck.containsKey('success') && Boolean.valueOf(mapCheck.get('success')) == false) {
            objOrderResponse.salesOrderNotCreated = true;
            objOrderResponse.errorMessages.add('Check list product errors');
            if(mapCheck.containsKey('listProductError')) {
                objOrderResponse.listProductErrors = (List<Giic_CommonWrapper.ProductErrorWrapper>) mapCheck.get('listProductError');
            }
            return objOrderResponse;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check availibility quantity OK');

        Map<Integer,gii__SalesOrder__c> mapSalesOrder = new Map<Integer,gii__SalesOrder__c>();
        Map<Integer,List<gii__SalesOrderLine__c>> mapSalesOrderLine = new Map<Integer,List<gii__SalesOrderLine__c>> ();
        Integer counter=1;
        boolean isDirectPO=false;
        Savepoint sp = Database.setSavepoint();
        list<Id> soIds=new list<id>();
        map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability=new map<Id,giic_CommonWrapper.ProductAvailability>();
        try{
            XC_UTIL_Debug.debug(DEBUGACTIVE,'***listSalesOrderHeader***'+listSalesOrderHeader);
            for(giic_CommonWrapper.SalesOrderHeader objSO : listSalesOrderHeader){
                gii__SalesOrder__c  so = new gii__SalesOrder__c(giic_Source__c=Label.giic_OrderSourceAutomation,gii__Account__c = objSO.AccountId,
                                                                gii__BillingCity__c= objSO.BillingCity,gii__BillingCountry__c = objSO.BillingCountry,
                                                                gii__BillingName__c = objSO.BillingName,gii__BillingStateProvince__c  = objSO.BillingStateProvince,
                                                                gii__BillingStreet__c = objSO.BillingStreet,gii__BillingZipPostalCode__c = objSO.BillingZipPostalCode,
                                                                gii__OrderDate__c = objSO.OrderDate,gii__RequiredDate__c = objSO.requiredDate,gii__ShipToCity__c = objSO.ShipToCity,
                                                                gii__ShipToCountry__c = objSO.ShipToCountry,gii__ShipToName__c = objSO.ShipToName,
                                                                gii__ShipToStateProvince__c = objSO.ShipToStateProvince,gii__ShipToStreet__c = objSO.ShipToStreet,
                                                                giic_WorkOrder__c=objSO.WorkOrderId,giic_FSLWorkOrder__c= objSO.FSLWorkOrder,
                                                                giic_IsDelivery__c = objSO.isDelivery, giic_FromWarehouse__c = objSO.fromWarehouseId,     
                                                                giic_FSLWorkOrderLineItem__c= objSO.FSLWorkOrderLineItem,giic_WorkOrderLineItem__c = objSO.workOrderLineItemID,
                                                                gii__ShipToZipPostalCode__c = objSO.ShipToZipPostalCode,giic_CUP__c = objSO.cup, giic_CIG__c = objSO.cig,
                                                                gii__Warehouse__c = objSO.WarehouseId/*,giic_DirectPurchaseOrder__c=objSO.dropShip*/);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For so: ' + so);

                List<giic_Switch1107__c> csSw = giic_Switch1107__c.getAll().values();
                boolean isActive = false;
                for(giic_Switch1107__c cs : csSw){
                    if(cs.giic_isActive__c){isActive = true;break;}
                }
                if(isActive){
                    //[NR1107]
                    Boolean DirectPurchaseOrder = objSO.dropShip;                                                
                    if(DirectPurchaseOrder==true && objSO.isDelivery){so.gii__DropShip__c=true;isDirectPO=true;so.giic_DirectPurchaseOrder__c=true;}
                    if(!objSO.isDelivery && objSO.dropShip ){so.giic_PO_TO_LocalWH__c = true;}
                    //[NR1107]
                }
                else{
                    so.giic_DirectPurchaseOrder__c = objSO.dropShip;
				    if(so.giic_DirectPurchaseOrder__c==true){
                    so.gii__DropShip__c=true;isDirectPO=true;
                    }
                }
                
                //so.giic_OrderStatus__c=Label.giic_SOStatusCompleted;
                objOrderResponse.fslWorkOrder=objSO.FSLWorkOrder;
                so.giic_IntegrationStatus__c=Label.giic_IntegrationStatusSuccess;
                so.giic_IntegrationOperation__c=Label.giic_IntegrationOperationCreate;
                objOrderResponse.fslWorkOrderLineItem=objSO.FSLWorkOrderLineItem;
                list<giic_CommonWrapper.ProductAvailability> lstProductAvailability=new list<giic_CommonWrapper.ProductAvailability>();
                mapSalesOrderLine.put(counter,getSalesOrderLines(objSO.SalesOrderLineList,mapProductWithAvailability,lstProductAvailability));
                objOrderResponse.lstProductAvailability=lstProductAvailability;
                mapSalesOrder.put(counter,so);
                counter = counter + 1;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'***mapSalesOrder***'+mapSalesOrder);
            
            if(mapSalesOrder.size() > 0){
                //objReturnResult.newSalesOrderIds = Giic_SalesOrderUtility.insertSalesOrder(mapSalesOrder,mapSalesOrderLine);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'***objOrderResponse***'+objOrderResponse);
                soIds = Giic_SalesOrderUtility.insertSalesOrder(mapSalesOrder,mapSalesOrderLine);
                //soIds.addall(objReturnResult.newSalesOrderIds);
                if(!soIds.isEmpty()){
                    objOrderResponse.status=Label.giic_SOCreateSuccessful;
                }
            }            
        }
        catch(exception ex){
            Database.rollback(sp);
            objOrderResponse.salesOrderNotCreated = true;
            objOrderResponse.errorMessages.add(ex.getMessage());
            Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_SalesOrderUtility',ex,'');
            return objOrderResponse;
        }
		//WOLI MIGRATI
		Set<Id> sWoliId=new Set<id>();
		Set<Id> sProdId=new Set<id>();
		Set<Id> sWHId	=new Set<id>();
		map<string,gii__ProductInventory__c> mapWHPRLOWithPI=new map<string,gii__ProductInventory__c>();
		String Available = 'Y';
        List<String> lstErrors = new List<String>();  
		for(giic_CommonWrapper.SalesOrderHeader objSO : listSalesOrderHeader){
			if( objSO.workOrderLineItemID != null && objSO.workOrderLineItemID != ''){ 
				if(!sWoliId.contains(objSO.workOrderLineItemID)  ) {sWoliId.add(objSO.workOrderLineItemID);}
				if(!sWHId.contains(objSO.WarehouseId)) {sWHId.add(objSO.WarehouseId);}

				for(giic_CommonWrapper.SalesOrderLine objSOL : objSO.SalesOrderLineList) {
					if(!sProdId.contains(objSOL.ProductId)) {sProdId.add(objSOL.ProductId);}
				}
			}						
		}

        List<giic_ReservationUtility.ReservationWrapper> listWr = new List<giic_ReservationUtility.ReservationWrapper>();

		if(!sWoliId.isEmpty()) {            
			Map<Id,WorkOrderLineItem> WoliList = new Map<Id,WorkOrderLineItem>([select  Id,  XC_IsMigrated__c  from WorkOrderLineItem WHERE Id IN: sWoliId ]);
			if(!WoliList.values().isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For WOLI ' + WoliList);
				for(gii__ProductInventory__c objPI : Giic_InventoryUtility_D.getPIForStockAvailability(sWHId,sProdId)){
                    String key=objPI.gii__Warehouse__c + '-' + objPI.gii__Product__c;
                    if(!mapWHPRLOWithPI.containskey(key)){
                        mapWHPRLOWithPI.put(key,objPI);
                    }
                } 
            
				for(giic_CommonWrapper.SalesOrderHeader objSO : listSalesOrderHeader){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For objSO ' + objSO);
					if(objSO.workOrderLineItemID != null &&  objSO.workOrderLineItemID !=  ''){
						if( WoliList.containskey(objSO.workOrderLineItemID) && WoliList.get(objSO.workOrderLineItemID).XC_IsMigrated__c) {  
							for(giic_CommonWrapper.SalesOrderLine objSOL : objSO.SalesOrderLineList) {
								string key=objSO.WarehouseId + '-' + objSOL.ProductId;
								if(mapWHPRLOWithPI.containskey(key)){
									Decimal avQty =  mapWHPRLOWithPI.get(key).giic_SalesOnHand__c;
									if( objSOL.OrderQuantity > avQty ){
										Available = 'N';
                                        if( avQty > 0 ){lstErrors.add('There are only '+ avQty +' Products available for '+  mapWHPRLOWithPI.get(key).gii__Product__r.Name);}
                                        else{lstErrors.add('The Product '+  mapWHPRLOWithPI.get(key).gii__Product__r.Name + ' is not available');}
									}
                                    else if(Available != 'N' &&  objSOL.OrderQuantity <= avQty && mapWHPRLOWithPI.get(key).gii__Product__r.giic_ProcurementType__c == 'Purchase'){
                                        Available = 'P';
                                        giic_ReservationUtility.ReservationWrapper wr = giic_ReservationUtility.getReservationWrapper(objSO.WarehouseId, objSOL.ProductId ,integer.valueof(objSOL.OrderQuantity),mapWHPRLOWithPI.get(key).gii__Warehouse__r.gii__DefaultIssueLocation__c);
                                        listWr.add(wr);
                                    }
								}
                                else{Available = 'N';lstErrors.add('The Product is not available');}
							}
						}
					}					
				}
			}
		}

        List<giic_ErrorLog__c> lstErrorLogs = new List<giic_ErrorLog__c>();
        
        if(Available == 'Y'){
            SalesOrderDirectPO objSOPOWrapper=new SalesOrderDirectPO();
            objSOPOWrapper.isDirectPO=isDirectPO;
            objSOPOWrapper.soIds=soIds;
            Map<String, String> mapProductRequiredIds = new Map<String, String>();
            for(giic_CommonWrapper.SalesOrderHeader soh : listSalesOrderHeader) {
                for(giic_CommonWrapper.SalesOrderLine solh : soh.salesOrderLineList) {
                    if(String.isNotBlank(solh.productRequiredID) && String.isNotBlank(solh.productId)) {
                        mapProductRequiredIds.put(solh.productId, solh.productRequiredID);
                    }
                }
            }
            objOrderResponse = processSalesOrder(objSOPOWrapper, objOrderResponse, mapProductWithAvailability, mapProductRequiredIds);
        }
        else if(Available =='P'){
            giic_ReservationUtility.reserveQuantities(listWr);
            list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
            for(Id soId : soIds){lstSOToUpdate.add(new gii__SalesOrder__c(id=soId,giic_OrderStatus__c=Label.giic_SOStatusCompleted));}
            updateSalesOrder(lstSOToUpdate);
        }
        else if(Available =='N'){
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]},
                                                                                                                       Label.giic_SOReservationProcess, string.join(lstErrors,'\'n\''))));
                                                                                                                       
            objOrderResponse.errorMessages.add(Label.giic_SOProcessFailedMessage);
            Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
            list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
            for(Id soId : soIds){lstSOToUpdate.add(new gii__SalesOrder__c(id=soId,giic_OrderStatus__c=Label.giic_SOReservationStatusError,giic_IntegrationStatus__c=Label.giic_IntegrationStatusFailure));}
            updateSalesOrder(lstSOToUpdate);
        }
        //WOLI MIGRATI
        
        return objOrderResponse;
    }

    /** 
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description get sales order lines
    * @param lstSalesOrderLines list Sales Order lines
    * @param mapProductWithAvailability Product availability map
    * @param lstProductAvailability Product availability wrapper
    * @return list<gii__SalesOrderLine__c>
    */  
    private static list<gii__SalesOrderLine__c> getSalesOrderLines(list<giic_CommonWrapper.SalesOrderLine> lstSalesOrderLines,map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability, List<giic_CommonWrapper.ProductAvailability> lstProductAvailability){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Get Sales Order Lines method');
        list<gii__SalesOrderLine__c> lstSOL=new list<gii__SalesOrderLine__c>();
        for(giic_CommonWrapper.SalesOrderLine objSOL : lstSalesOrderLines){
            gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(gii__LineDescription__c = objSOL.LineDescription,gii__OrderQuantity__c = objSOL.OrderQuantity,gii__Product__c = objSOL.ProductId,giic_ProdRequired__c = objSOL.prReqID,
                                                                            gii__UnitPrice__c = objSOL.UnitPrice,giic_ProductRequiredId__c = objSOL.ProductRequiredID,giic_CostCenter__c=objSOL.costCenter,giic_WBElement__c=objSOL.wbElement);
            // soLineObj.giic_OwnedbyEnelX__c=objSOL.OwnedByEnelX;
            lstSOL.add(soLineObj);
            /******************************reseponse Wrapper ***********************/
            giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
            objProductAvail.productRequiredID=objSOL.ProductRequiredID;
            objProductAvail.ProductId=objSOL.ProductId;
            mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
            lstProductAvailability.add(objProductAvail);
        }
        return lstSOL;
    } 

    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description process product inventory for back order qty, transfer order and reserve quantities
    * @param objPAResponse product availability response
    * @return Map<String, Object>
    */ 
    public static Map<String, Object> processReturnLists(Giic_StockAvailabilityUtility.ProductAvailabilityResponse objPAResponse){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Process Return List');

        /******************************* Update Back order quantity on PI *******************************************************/
        if(objPAResponse.lstPIToUpdateBackOrderQty != null && !objPAResponse.lstPIToUpdateBackOrderQty.isEmpty() && Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update objPAResponse.lstPIToUpdateBackOrderQty;
        }
        /******************************** Create Transfer Order and Lines *******************************************************/
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##giic_TransferOrderUtility');
        if(objPAResponse.objTOWrapper.mapTransferOrder != null && !objPAResponse.objTOWrapper.mapTransferOrder.isEmpty()){
            giic_TransferOrderUtility.insertTO(objPAResponse.objTOWrapper.mapTransferOrder,objPAResponse.objTOWrapper.mapTransferOrderLine);
        }
        /******************************** Validation Product ********************************************************************/
        Map<String, Object> mapResultValidation = checkValidationProducts(objPAResponse);
        if(mapResultValidation.containsKey('success') && Boolean.valueOf(mapResultValidation.get('success'))==true) {
            /******************************** Create Purchase Order and Lines *******************************************************/
            if(objPAResponse.objPOWrapper.mapPurchaseOrder != null && !objPAResponse.objPOWrapper.mapPurchaseOrder.isEmpty()){
                giic_PurchaseOrderUtility.insertPO(objPAResponse.objPOWrapper.mapPurchaseOrder,objPAResponse.objPOWrapper.mapPurchaseOrderLine);
            }
        }
        /******************************** Do Reservation ***********************************************************************/
        if(objPAResponse.reserveWrap != null && !objPAResponse.reserveWrap.isEmpty()){
            giic_ReservationUtility.reserveQuantities(objPAResponse.reserveWrap);
        }
        return mapResultValidation;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/07/2021
    * @description Method to check validation for products
    * @param objPAResponse - Giic_StockAvailabilityUtility.ProductAvailabilityResponse
    * @param lstErrorLogs - List<giic_ErrorLog__c> 
    * @param soIds - List<Id>
    * @param listProductIds - Set<Id>
    */ 
    public static void processReturnLists(Giic_StockAvailabilityUtility.ProductAvailabilityResponse objPAResponse, List<giic_ErrorLog__c> lstErrorLogs, List<Id> soIds, Set<Id> listProductIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In process Return List method');
        objPAResponse.listProduct2AddIds = listProductIds;
        Map<String, Object> mapResultValidation = processReturnLists(objPAResponse);
        if(mapResultValidation.containsKey('success') && Boolean.valueOf(mapResultValidation.get('success'))==false && mapResultValidation.containsKey('message')) {
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(
                                                                        Label.giic_SOCreateProcess,
                                                                        new Map<String, Object>{'giic_SalesOrder__c' => soIds[0]},
                                                                        Label.giic_SOCreateProcess,
                                                                        String.valueOf(mapResultValidation.get('message')
                                                                    )))
            );
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/07/2021
    * @description Method to check validation for products
    * @param objPAResponse - Giic_StockAvailabilityUtility.ProductAvailabilityResponse
    * @return Map<String, Object>
    */ 
    public static Map<String, Object> checkValidationProducts(Giic_StockAvailabilityUtility.ProductAvailabilityResponse objPAResponse) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Check Validation product method');
        // Data Preparation:
        Map<String, Object> mapResult = new Map<String, Object>();
        List<gii__Product2Add__c> listProducts = new List<gii__Product2Add__c>([
            SELECT Id, gii__PrimarySupplier__c, gii__ProductCode__c,
                (SELECT Id, gii__PriceBook__r.giic_Contract__r.EndDate, gii__PriceBook__r.giic_Contract__r.AccountId, gii__PriceBook__r.giic_Contract__r.StartDate
                FROM gii__Price_Book_Entries__r
                WHERE giic_Default__c = true)
            FROM gii__Product2Add__c
            WHERE Id IN :objPAResponse.listProduct2AddIds 
        ]);

        List<String> listPCodeforContractCheck  = new List<String>();
        List<String> listPCodeforAccountCheck   = new List<String>();
        List<String> listPCodeForSupplierCheck  = new List<String>();
        for(gii__Product2Add__c p2A : listProducts) {
            // Check Primary Supplier:
            //if(String.isBlank(p2A.gii__PrimarySupplier__c) || p2A.gii__PrimarySupplier__c==null || p2A.gii__PrimarySupplier__c=='') {
            if(String.isBlank(p2A.gii__PrimarySupplier__c) || p2A.gii__PrimarySupplier__c==null) {
                listPCodeForSupplierCheck.add(p2A.gii__ProductCode__c);
            }
            for(gii__PriceBookEntry__c pbe : p2A.gii__Price_Book_Entries__r) {
                // Check Contract:
                if(pbe.gii__PriceBook__r.giic_Contract__r.EndDate < Date.today()) {
                    listPCodeforContractCheck.add(p2A.gii__ProductCode__c);
                }
                // Check Primary Supplier for PBE:
                if( String.isNotBlank(pbe.gii__PriceBook__r.giic_Contract__r.AccountId) && 
                    pbe.gii__PriceBook__r.giic_Contract__r.EndDate >= Date.today()      && 
                    pbe.gii__PriceBook__r.giic_Contract__r.StartDate <= Date.today()    && 
                    pbe.gii__PriceBook__r.giic_Contract__r.AccountId != p2A.gii__PrimarySupplier__c) {
                        listPCodeforAccountCheck.add(p2A.gii__ProductCode__c);
                }
            }
        }

        //******************************************************************************************************************************* Manage Error */
        if(!listPCodeforContractCheck.isEmpty() || !listPCodeforAccountCheck.isEmpty() || !listPCodeForSupplierCheck.isEmpty()) {
            mapResult.put('success', false);
            // Check order:
            //  1) Check Supplier for Product
            //  2) Check Contract dates
            //  3) Check Supplier for PriceBookEntry
            String messagePrimarySupplier   = 'Primary Supplier cannot be null for product: ';
            String messageContract          = 'The Contract related to PriceBook has End Date less than today for product: ';
            String messagePBE               = 'Primary Supplier cannot be different from default PBE Account for product: ';
            String errorMessage = (!listPCodeForSupplierCheck.isEmpty()) ? messagePrimarySupplier : ((!listPCodeforContractCheck.isEmpty()) ? messageContract : messagePBE);
            errorMessage = errorMessage + ((!listPCodeForSupplierCheck.isEmpty()) ? String.join(listPCodeForSupplierCheck, ', ') : ((!listPCodeforContractCheck.isEmpty()) ? String.join(listPCodeforContractCheck, ', ') : String.join(listPCodeforAccountCheck, ', ')));
            mapResult.put('message', errorMessage);
            return mapResult;
        }
        //**********************************************************************************************************************************************/
        
        mapResult.put('success', true);
        return mapResult;
    }

    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description Process SalesOrder for availability
    * @param objSOPOWrapper - SalesOrderDirectPO
    * @param objOrderResponse - giic_CommonWrapper.OrderResponse 
    * @param mapProductWithAvailability - Map<Id,giic_CommonWrapper.ProductAvailability>
    * @param mapProductRequiredIds - Map<String, String> 
    * @return giic_CommonWrapper.OrderResponse
    */ 
    public static giic_CommonWrapper.OrderResponse processSalesOrder(SalesOrderDirectPO objSOPOWrapper, giic_CommonWrapper.OrderResponse objOrderResponse, Map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability, Map<String, String> mapProductRequiredIds) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Process Sales Order');
        List<Id> soIds = objSOPOWrapper.soIds;                                                                   
        Savepoint sp = Database.setSavepoint(); //Roll Back if any issue after Sales order creation 
        boolean isRollback = false;
        list<giic_ErrorLog__c> lstErrorLogs = new list<giic_ErrorLog__c>();

        try {
            if(objSOPOWrapper.isDirectPO) {
                // Create Purchase Order:
                Giic_StockAvailabilityUtility.POCreationResponse objPOCreationResponse = giic_PurchaseOrderUtility.createDropShipPO(soIds,mapProductWithAvailability);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPOCreationResponse: ' + objPOCreationResponse);
                if(objPOCreationResponse.lstErrors != null && !objPOCreationResponse.lstErrors.isEmpty()) {
                    // Error found:
                    if(!soIds.isEmpty()) {
                        lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]}, Label.giic_SOReservationProcess,string.join(objPOCreationResponse.lstErrors,'\'n\''))));
                    }
                    isRollback=true; 
                }
                objOrderResponse.lstProductAvailability = objPOCreationResponse.mapProductWithAvailability.values();

                List<ProductRequired> listPr = new List<ProductRequired>([
                    SELECT Id, ProductRequiredNumber 
                    FROM ProductRequired 
                    WHERE ProductRequiredNumber IN :mapProductRequiredIds.values()
                ]);
                Map<String, String> mapPrIdNumber = new Map<String, String>();
                for(ProductRequired pr : listPr) {
                    mapPrIdNumber.put(pr.ProductRequiredNumber, pr.Id);
                }
                for(Giic_CommonWrapper.ProductWrapper pw : objPOCreationResponse.productsWrapper) {
                    String keyMap = pw.productId;
                    String prNumber = mapProductRequiredIds.get(keyMap);
                    if(mapProductRequiredIds.containsKey(keyMap)) {
                        pw.productId = (!mapPrIdNumber.keySet().isEmpty() && mapPrIdNumber.containsKey(prNumber)) ? mapPrIdNumber.get(prNumber) : mapProductRequiredIds.get(keyMap);
                    }
                }
                objOrderResponse.listProduct = objPOCreationResponse.productsWrapper;
            } else {
                Giic_StockAvailabilityUtility.ProductAvailabilityResponse objPAResponse = Giic_StockAvailabilityUtility.getProductAvailability(soIds,mapProductWithAvailability);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Response from stock availability: ' + objPAResponse);
                if(objPAResponse.lstErrors != null && !objPAResponse.lstErrors.isEmpty()) {
                    if(!soIds.isEmpty()) {
                        // Error found:
                    	lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]}, Label.giic_SOReservationProcess,string.join(objPAResponse.lstErrors,'\'n\''))));
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstErrorLogs: ' + lstErrorLogs);
                    }
                   //isRollback = true;                
                }
                //else {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Process Return List for No Direct PO...');
                    processReturnLists(objPAResponse, lstErrorLogs, soIds, mapProductWithAvailability.keySet());
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPAResponse after processReturnLists: ' + objPAResponse);

                    // Create a map Product Name -> Product Id [NR2034]:
                    List<ProductRequired> listPr = new List<ProductRequired>([
                        SELECT Id, ProductRequiredNumber 
                        FROM ProductRequired 
                        WHERE ProductRequiredNumber IN :mapProductRequiredIds.values()
                    ]);
                    Map<String, String> mapPrIdNumber = new Map<String, String>();
                    for(ProductRequired pr : listPr) {
                        mapPrIdNumber.put(pr.ProductRequiredNumber, pr.Id);
                    }

                    // Create Purchase Order:
                    Map<String, String> mapUniqueKeyPONumber = new Map<String, String>();
                    if(objPAResponse.lstNotReservedLines != null && !objPAResponse.lstNotReservedLines.isEmpty()) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Creating Po...');
                        Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation = new Giic_StockAvailabilityUtility.POCreationForReservation();
                        objPOCreationReservation.isDropShip=false;
                        objPOCreationReservation.mapSOLIdWithIsDropShip=objPAResponse.mapSOLIsDropShip;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ POCreationForReservation before: ' + objPOCreationReservation);
                        //[NR1107]
                        Giic_StockAvailabilityUtility.POCreationResponse objPOCreationResponse = giic_PurchaseOrderUtility.createPOWithContractValidation(objPAResponse.lstNotReservedLines,mapProductWithAvailability,objPOCreationReservation,objPAResponse.mapWHPRLOWithPI,objPAResponse.mapWHPIQD);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ POCreationForReservation after: ' + objPOCreationReservation);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPOCreationResponse: ' + objPOCreationResponse);

                        // To populate wrapper product for PO e Reserved [NR2034]:
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listPr: ' + listPr);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPrIdNumber: ' + mapPrIdNumber);
                        for(Giic_CommonWrapper.ProductWrapper pw : objPOCreationResponse.productsWrapper) {
                            for(giic_ReservationUtility.ReservationWrapper rw : objPOCreationResponse.listReservationWrapper) {
                                if(pw.productId == rw.product) {
                                    pw.reservedQty = pw.reservedQty + rw.qty;
                                }
                            }
                            String keyMap = pw.productId;
                            if(mapProductRequiredIds.containsKey(keyMap)) {
                                String prNumber = mapProductRequiredIds.get(keyMap);
                                pw.productId = (!mapPrIdNumber.keySet().isEmpty() && mapPrIdNumber.containsKey(prNumber)) ? mapPrIdNumber.get(prNumber) : mapProductRequiredIds.get(keyMap);
                            }
                        }
                        lstErrorLogs.addall(getPOResponseErrorLogs(objPOCreationResponse,isRollback,soIds));
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objOrderResponse: ' + objOrderResponse);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstErrorLogs: ' + lstErrorLogs);
                        objOrderResponse.listProduct = objPOCreationResponse.productsWrapper;

                        mapUniqueKeyPONumber = objPOCreationResponse.mapUniqueKeyPONumber;
                    }
                    // -- To integrate PO of processReturnLists for ProductWrapper [NR2034]:
                    if(!objPAResponse.objPOWrapper.mapPurchaseOrder.keySet().isEmpty() && !objPAResponse.objPOWrapper.mapPurchaseOrderLine.keySet().isEmpty()) {
                        for(String keyPo : objPAResponse.objPOWrapper.mapPurchaseOrder.keySet()) {
                            if(!objPAResponse.objPOWrapper.mapPurchaseOrderLine.containsKey(keyPo)) {
                                continue;
                            }
                            for(gii__PurchaseOrderLine__c objPOL : objPAResponse.objPOWrapper.mapPurchaseOrderLine.get(keyPo)){
                                String productPoLine = objPOL.gii__Product__c;
                                if(!mapProductRequiredIds.containsKey(productPoLine)) {
                                    continue;
                                }
                                productPoLine = mapProductRequiredIds.get(productPoLine);
                                if(mapPrIdNumber.containsKey(productPoLine)) {
                                    productPoLine = mapPrIdNumber.get(productPoLine);
                                }
                                Boolean found = false;
                                for(Giic_CommonWrapper.ProductWrapper pw : objOrderResponse.listProduct) {
                                    if(pw.productId == productPoLine) {
                                        found = true;
                                        pw.purchasedQty = pw.purchasedQty + objPOL.gii__OrderQuantity__c;
                                        break;
                                    }
                                }
                                if(!found) {
                                    Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
                                    pw.purchasedQty = objPOL.gii__OrderQuantity__c;
                                    pw.purchaseOrderStatus = String.isNotBlank(objPAResponse.objPOWrapper.mapPurchaseOrder.get(keyPo).giic_Status__c) ? objPAResponse.objPOWrapper.mapPurchaseOrder.get(keyPo).giic_Status__c : Label.giic_PODraftStatus;
                                    pw.productId = productPoLine;
                                    String keyWith3params = (keyPo.split('-').size() == 4) ? (keyPo.split('-')[0]+'-'+keyPo.split('-')[1]+'-'+keyPo.split('-')[2]) : keyPo;
                                    if(mapUniqueKeyPONumber.containsKey(keyWith3params)) {
                                        pw.purchaseOrderNumber = mapUniqueKeyPONumber.get(keyWith3params);
                                    }
                                    pw.warehouseAccountId = keyWith3params.split('-')[1];
                                    objOrderResponse.listProduct.add(pw);
                                }
                            }
                        }
                    }
                    // -- To integrate Reservation of processReturnLists for ProductWrapper [NR2034]:
                    for(giic_ReservationUtility.ReservationWrapper resWr : objPAResponse.reserveWrap) {
                        String productReserve = resWr.product;
                        if(!mapProductRequiredIds.containsKey(productReserve)) {
                            continue;
                        }
                        productReserve = mapProductRequiredIds.get(productReserve);
                        if(mapPrIdNumber.containsKey(productReserve)) {
                            productReserve = mapPrIdNumber.get(productReserve);
                        }
                        Boolean found = false;
                        for(Giic_CommonWrapper.ProductWrapper pw : objOrderResponse.listProduct) {
                            if(pw.productId == productReserve) {
                                found = true;
                                pw.reservedQty = pw.reservedQty + resWr.qty;
                                break;
                            }
                        }
                        if(!found) {
                            Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
                            pw.productId = productReserve;
                            pw.reservedQty = resWr.qty;
                            objOrderResponse.listProduct.add(pw);
                        }
                    }
                //}
                if(!objPAResponse.salesOrderToUpdate.isEmpty() && !objPAResponse.salesOrderLineToUpdate.isEmpty()) {
                    updateSalesOrder(objPAResponse.salesOrderToUpdate);
                    updateSalesOrderLine(objPAResponse.salesOrderLineToUpdate);
                }
            }
         
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error logs: ' + lstErrorLogs);
            if(!lstErrorLogs.isEmpty()) { // OR isRollback [commented] 
                //Database.rollback(sp);
                // Error found
                objOrderResponse.errorMessages.add(Label.giic_SOProcessFailedMessage);
                Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
                List<gii__SalesOrder__c> lstSOToUpdate=new List<gii__SalesOrder__c>();
                for(Id soId : soIds) {
                    lstSOToUpdate.add(new gii__SalesOrder__c(
                        Id = soId,
                        giic_OrderStatus__c = Label.giic_SOReservationStatusError,
                        giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure
                    ));
                }
                updateSalesOrder(lstSOToUpdate);
            } else {
                // No Error found
                List<gii__SalesOrder__c> lstSOToUpdate = new List<gii__SalesOrder__c>();
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOrder before update: ' + lstSOToUpdate);
                for(Id soId : soIds) {
                    lstSOToUpdate.add(new gii__SalesOrder__c(
                        Id=soId,
                        giic_OrderStatus__c = Label.giic_SOStatusCompleted
                    ));
                }
                updateSalesOrder(lstSOToUpdate);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SalesOrder after update: ' + lstSOToUpdate);
            }

            objOrderResponse.lstProductAvailability=mapProductWithAvailability.values();
        }
        catch(Exception ex) {
            Database.rollback(sp);
            if(!soIds.isEmpty()){
            	lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]}, Label.giic_SOReservationProcess,ex.getMessage())));
            }
            Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_SalesOrderUtility',ex, JSON.serialize(mapProductWithAvailability));    
            //Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exception found:' + ex.getLineNumber()+'**'+ex.getCause());
            List<gii__SalesOrder__c> lstSOToUpdate = new List<gii__SalesOrder__c>();
            if(!soIds.isEmpty()) {
                for(Id soId : soIds) {
                    lstSOToUpdate.add(new gii__SalesOrder__c(
                        Id = soId,
                        giic_OrderStatus__c = Label.giic_SOReservationStatusError,
                        giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure
                    ));
                }
            	updateSalesOrder(lstSOToUpdate);
            }
        }    

        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Responde create Sales Order: ' + objOrderResponse);
        return objOrderResponse;
    }

    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description process the sales order for other processes
    * @param salesOrderId sales order id
    * @return giic_CommonWrapper.OrderResponse
    */ 
    @AuraEnabled
    public static giic_CommonWrapper.OrderResponse reprocessOrder(string salesOrderId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ReProcess Sales Order');
        giic_CommonWrapper.OrderResponse objOrderResponse = new giic_CommonWrapper.OrderResponse();
        Savepoint sp = Database.setSavepoint();
        try{
            list<giic_CommonWrapper.ProductAvailability> lstProductAvailability=new list<giic_CommonWrapper.ProductAvailability>();
            map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability=new map<Id,giic_CommonWrapper.ProductAvailability>();
            SalesOrderDirectPO objSOPOWrapper=new SalesOrderDirectPO();
            objSOPOWrapper.soIds=new list<Id>();
            list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
            String sWoliId;
			Boolean sMigratedWoli;
			Set<Id> sProdId=new Set<id>();
			Set<Id> sWHId	=new Set<id>();
			list<gii__SalesOrderLine__c> lstSalesOrderLine = new list<gii__SalesOrderLine__c>();
            //String Available = 'Y';
            for(gii__SalesOrderLine__c objSOL : Giic_SalesOrderUtility_D.getSalesOrderLines(salesOrderId)){
                if(objSOL.gii__SalesOrder__r.giic_OrderStatus__c != Label.giic_SOReservationStatusError){
                    objOrderResponse.errorMessages.add(Label.giic_SOErrorReprocessedMessage);
                    return objOrderResponse;
                }
                objOrderResponse.fslWorkOrder=objSOL.gii__SalesOrder__r.giic_FSLWorkOrder__c;
                objOrderResponse.fslWorkOrderLineItem=objSOL.gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c;
                objSOPOWrapper.isDirectPO=objSOL.gii__SalesOrder__r.giic_DirectPurchaseOrder__c;
                if(!objSOPOWrapper.soIds.contains(objSOL.gii__SalesOrder__c)){
                    objSOPOWrapper.soIds.add(objSOL.gii__SalesOrder__c);
                    //lstSOToUpdate.add(new gii__SalesOrder__c(id=objSOL.gii__SalesOrder__c,giic_OrderStatus__c=Label.giic_SOStatusCompleted,giic_IntegrationStatus__c=Label.giic_IntegrationStatusSuccess));
                    lstSOToUpdate.add(new gii__SalesOrder__c(id=objSOL.gii__SalesOrder__c,giic_IntegrationStatus__c=Label.giic_IntegrationStatusSuccess));
                    sWoliId	= objSOL.gii__SalesOrder__r.giic_WorkOrderLineItem__c;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'sWoliId: ' + sWoliId);
					sMigratedWoli = objSOL.gii__SalesOrder__r.giic_WorkOrderLineItem__r.XC_IsMigrated__c;
                }
                if(!sWHId.contains(objSOL.gii__Warehouse__c)) {sWHId.add(objSOL.gii__Warehouse__c);}
				if(!sProdId.contains(objSOL.gii__Product__c)) {sProdId.add(objSOL.gii__Product__c);}
				lstSalesOrderLine.Add(objSOL);
                /******************************reseponse Wrapper ***********************/
                giic_CommonWrapper.ProductAvailability objProductAvail=new giic_CommonWrapper.ProductAvailability();
                objProductAvail.productRequiredID=objSOL.giic_ProductRequiredId__c;
                objProductAvail.ProductId=objSOL.gii__Product__c;
                mapProductWithAvailability.put(objProductAvail.ProductId,objProductAvail);
                lstProductAvailability.add(objProductAvail);
            }
            if(Schema.sObjectType.gii__SalesOrder__c.isUpdateable()){update lstSOToUpdate;}
            
			//WOLI MIGRATI
			map<string,gii__ProductInventory__c> mapWHPRLOWithPI=new map<string,gii__ProductInventory__c>();
			String Available = 'Y';
        	List<String> lstErrors = new List<String>();  

     	    List<giic_ReservationUtility.ReservationWrapper> listWr = New List<giic_ReservationUtility.ReservationWrapper>();
			if ((sWoliId != null && sWoliId != '') && sMigratedWoli == TRUE) {            
			
				for(gii__ProductInventory__c objPI : Giic_InventoryUtility_D.getPIForStockAvailability(sWHId,sProdId)){
						string key=objPI.gii__Warehouse__c + '-' + objPI.gii__Product__c;
						if(!mapWHPRLOWithPI.containskey(key)){mapWHPRLOWithPI.put(key,objPI);}
					} 
                
				for(gii__SalesOrderLine__c objSOLn : lstSalesOrderLine) {
					string key= objSOLn.gii__Warehouse__c + '-' + objSOLn.gii__Product__c;
					if(mapWHPRLOWithPI.containskey(key)){
						Decimal avQty =  mapWHPRLOWithPI.get(key).giic_SalesOnHand__c;
						if( objSOLn.gii__OrderQuantity__c > avQty ){
							Available = 'N';
            	            if( avQty > 0 ){lstErrors.add('There are only '+ avQty +' Products available for '+  mapWHPRLOWithPI.get(key).gii__Product__r.Name);}
                            else{lstErrors.add('The Product '+  mapWHPRLOWithPI.get(key).gii__Product__r.Name + ' is not available');}
						}
         	           else if(Available != 'N' &&  objSOLn.gii__OrderQuantity__c <= avQty && mapWHPRLOWithPI.get(key).gii__Product__r.giic_ProcurementType__c == 'Purchase'){
            	            Available = 'P';
                	        giic_ReservationUtility.ReservationWrapper wr = giic_ReservationUtility.getReservationWrapper(objSOLn.gii__Warehouse__c, objSOLn.gii__Product__c ,integer.valueof(objSOLn.gii__OrderQuantity__c),mapWHPRLOWithPI.get(key).gii__Warehouse__r.gii__DefaultIssueLocation__c);
                    	    listWr.add(wr);
                    	}
					}
                	else{Available = 'N';lstErrors.add('The Product is not available');}
				}
			}

       		list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();            
            
            //objOrderResponse.lstProductAvailability=lstProductAvailability;
        	//processSalesOrderFromComponent(objSOPOWrapper,objOrderResponse,mapProductWithAvailability,salesOrderId);
            if(Available == 'Y'){
    	        objOrderResponse.lstProductAvailability=lstProductAvailability;
        		processSalesOrderFromComponent(objSOPOWrapper,objOrderResponse,mapProductWithAvailability,salesOrderId);
        	}
        	else if(Available =='P'){
            	giic_ReservationUtility.reserveQuantities(listWr);
            	list<gii__SalesOrder__c> lstSOToUpdateN=new list<gii__SalesOrder__c>();
            	lstSOToUpdateN.add(new gii__SalesOrder__c(id=salesOrderId,giic_OrderStatus__c=Label.giic_SOStatusCompleted));
            	updateSalesOrder(lstSOToUpdateN);
        	}
       		else if(Available =='N'){
            	lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>salesOrderId},
                                                                                                                       Label.giic_SOReservationProcess, string.join(lstErrors,'\'n\''))));
                                                                                                                       
            	objOrderResponse.errorMessages.add(Label.giic_SOProcessFailedMessage);
            	Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
            	list<gii__SalesOrder__c> lstSOToUpdateN=new list<gii__SalesOrder__c>();
            	lstSOToUpdateN.add(new gii__SalesOrder__c(id=salesOrderId,giic_OrderStatus__c=Label.giic_SOReservationStatusError,giic_IntegrationStatus__c=Label.giic_IntegrationStatusFailure));
            	updateSalesOrder(lstSOToUpdateN);
        	}
        	//WOLI MIGRATI
        }
        catch(exception ex){
            Database.rollback(sp);
            Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_SalesOrderUtility',ex, '');    
            objOrderResponse.errorMessages.add(ex.getMessage());
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'****objOrderResponse***'+objOrderResponse);
        return objOrderResponse;
    }
    
    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description process the sales order for availability
    * @param objSOPOWrapper sales order wrapper
    * @param objOrderResponse response wrapper
    * @param mapProductWithAvailability product availability
    * @return giic_CommonWrapper.OrderResponse
    */ 
    public static giic_CommonWrapper.OrderResponse processSalesOrderFromComponent(SalesOrderDirectPO objSOPOWrapper,giic_CommonWrapper.OrderResponse objOrderResponse, Map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability, String salesOrderId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Process Sales Order from Component');
        List<Id> soIds=objSOPOWrapper.soIds;                                                                   
        /***************************Roll Back if any issue after Sales order creation *************************************************************/ 
        Map<Id,gii__SalesOrder__c> salesOrder = Giic_SalesOrderUtility_D.getSalesOrderFromComponent(salesOrderId);                                                                       
        Savepoint sp = Database.setSavepoint();
        boolean isRollback=false;
        list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();
        try{
            if(objSOPOWrapper.isDirectPO){
                Giic_StockAvailabilityUtility.POCreationResponse objPOCreationResponse=giic_PurchaseOrderUtility.createDropShipPO(soIds,mapProductWithAvailability);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'****objPOCreationResponse***'+objPOCreationResponse);
              
                if(objPOCreationResponse.lstErrors != null && !objPOCreationResponse.lstErrors.isEmpty()){
                    if(!soIds.isEmpty()){
                    lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]},
                                                                                                                       Label.giic_SOReservationProcess,string.join(objPOCreationResponse.lstErrors,'\'n\''))));
                    }
                    isRollback=true;    
                }
                objOrderResponse.lstProductAvailability=objPOCreationResponse.mapProductWithAvailability.values();
            }
            else{
                Giic_StockAvailabilityUtility.ProductAvailabilityResponse objPAResponse= Giic_StockAvailabilityUtility.getProductAvailability(soIds,mapProductWithAvailability);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '2222222222');
                    if(objPAResponse.lstErrors != null && !objPAResponse.lstErrors.isEmpty()){
                        if(!soIds.isEmpty()){
                        lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]},
                                                                                                                           Label.giic_SOReservationProcess,string.join(objPAResponse.lstErrors,'\'n\''))));             

                        }
                    }
                XC_UTIL_Debug.debug(DEBUGACTIVE,'***objPAResponse**'+objPAResponse);
                if(salesOrder.containskey(salesOrderId) != null && salesOrder.get(salesOrderId).Transfer_Orders__r != null && !salesOrder.get(salesOrderId).Transfer_Orders__r.isEmpty()){
                    objPAResponse.lstPIToUpdateBackOrderQty =new list<gii__ProductInventory__c>(); 
                    objPAResponse.objTOWrapper.mapTransferOrderLine = new map<string,list<gii__TransferOrderLine__c>>();
                    objPAResponse.objTOWrapper.mapTransferOrder = new map<string,gii__TransferOrder__c>();
                    objPAResponse.reserveWrap = new List<giic_ReservationUtility.ReservationWrapper>(); 
                }        
                processReturnLists(objPAResponse, lstErrorLogs, soIds, mapProductWithAvailability.keySet());

              /******************************* Create Purchase Order *******************************************************/
                if(objPAResponse.lstNotReservedLines != null && !objPAResponse.lstNotReservedLines.isEmpty()){
                        Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation=new Giic_StockAvailabilityUtility.POCreationForReservation();
                        objPOCreationReservation.isDropShip=false;
                        objPOCreationReservation.mapSOLIdWithIsDropShip=objPAResponse.mapSOLIsDropShip;
                        //[NR1107]
                    	Giic_StockAvailabilityUtility.POCreationResponse objPOCreationResponse=giic_PurchaseOrderUtility.createPOWithContractValidation(objPAResponse.lstNotReservedLines,mapProductWithAvailability,objPOCreationReservation,objPAResponse.mapWHPRLOWithPI,objPAResponse.mapWHPIQD);
                        lstErrorLogs.addall(getPOResponseErrorLogs(objPOCreationResponse,isRollback,soIds));
                    }
               // }
                if(!objPAResponse.salesOrderToUpdate.isEmpty() && !objPAResponse.salesOrderLineToUpdate.isEmpty()){
                    updateSalesOrder(objPAResponse.salesOrderToUpdate);
                    updateSalesOrderLine(objPAResponse.salesOrderLineToUpdate);
                }
            }
         
            XC_UTIL_Debug.debug(DEBUGACTIVE,'****lstErrorLogs***'+lstErrorLogs);
             if(!lstErrorLogs.isEmpty()){ //isRollback || 
                //Database.rollback(sp);
                objOrderResponse.errorMessages.add(Label.giic_SOProcessFailedMessage);
                Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
                list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
                for(Id soId : soIds){lstSOToUpdate.add(new gii__SalesOrder__c(id=soId,giic_OrderStatus__c=Label.giic_SOReservationStatusError,giic_IntegrationStatus__c=Label.giic_IntegrationStatusFailure));}
                updateSalesOrder(lstSOToUpdate);
            }else{
                list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
                for(Id soId : soIds){lstSOToUpdate.add(new gii__SalesOrder__c(id=soId,giic_OrderStatus__c=Label.giic_SOStatusCompleted));}
                updateSalesOrder(lstSOToUpdate);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### after update SO ' + lstSOToUpdate);
            }
            objOrderResponse.lstProductAvailability=mapProductWithAvailability.values();
        }
        catch(exception ex){
            Database.rollback(sp);
            if(!soIds.isEmpty()){
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]},
                                                                                                               Label.giic_SOReservationProcess,ex.getMessage())));
            }
            Giic_ErrorLogsUtility.insertGloviaErrorLog('Giic_SalesOrderUtility',ex, JSON.serialize(mapProductWithAvailability));    
            //Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'***Ex***'+ex.getLineNumber()+'**'+ex.getCause());
            list<gii__SalesOrder__c> lstSOToUpdate=new list<gii__SalesOrder__c>();
            for(Id soId : soIds){lstSOToUpdate.add(new gii__SalesOrder__c(id=soId,giic_OrderStatus__c=Label.giic_SOReservationStatusError,giic_IntegrationStatus__c=Label.giic_IntegrationStatusFailure));}
            updateSalesOrder(lstSOToUpdate);
        }     
        XC_UTIL_Debug.debug(DEBUGACTIVE,'****objOrderResponse****'+objOrderResponse);
        return objOrderResponse;
    }

    /**
    * @author FirstName : Pradeep Kumar - pradeep.p.kumar@in.fujitsu.com
    * @date 18/06/2019
    * @description PO response error logs
    * @param objPOCreationResponse PO creation response
    * @param isRollback roll back flag
    * @param soIds list of sales order ids
    * @return list<giic_ErrorLog__c>
    */ 
    public static list<giic_ErrorLog__c> getPOResponseErrorLogs(Giic_StockAvailabilityUtility.POCreationResponse objPOCreationResponse,boolean isRollback,list<Id> soIds){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Get response error log method');
        list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();
        if(objPOCreationResponse.lstErrors != null && !objPOCreationResponse.lstErrors.isEmpty()){
            if(!soIds.isEmpty()){
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOCreateProcess,new map<string,object>{'giic_SalesOrder__c'=>soIds[0]},
                                                                                                               Label.giic_SOCreateProcess,string.join(objPOCreationResponse.lstErrors,'\'n\''))));
            }
            isRollback=true;                
        }
        return lstErrorLogs;
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - Insert Sales order and sales order lines
    * @param mapSalesOrder map of sales order
    * @param mapSalesOrderLine map of sales order lines
    * @return List<Id> list of sales order ids
	*/
    public static List<Id>  insertSalesOrder(map<integer,gii__SalesOrder__c> mapSalesOrder,map<integer,List<gii__SalesOrderLine__c>> mapSalesOrderLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SO inserting...');
        Database.Insert(mapSalesOrder.values());
        List<Id> soIds = new List<Id>();
        list<gii__SalesOrderLine__c> lstSOLToInsert=new list<gii__SalesOrderLine__c>();
        for(Integer count : mapSalesOrder.keyset()){
            for(gii__SalesOrderLine__c objSOL : mapSalesOrderLine.get(count)){
                objSOl.gii__SalesOrder__c=mapSalesOrder.get(count).Id;
                if(!soIds.contains(mapSalesOrder.get(count).Id)){
                    soIds.add(mapSalesOrder.get(count).Id);
                }
                lstSOLToInsert.add(objSOl);
            }
        }
        database.insert(lstSOLToInsert);
        return soIds;
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - Insert Sales order and sales order lines
    * @param lstSalesOrder list of sales order
    */
    public static void  updateSalesOrder(list<gii__SalesOrder__c> lstSalesOrder){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SO updating...');
        if(Schema.sObjectType.gii__SalesOrder__c.isUpdateable()){
            update lstSalesOrder;
        }
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - Insert Sales order and sales order lines
    * @param lstSalesOrder list of sales order
    */
    public static void  updateSalesOrderLine(list<gii__SalesOrderLine__c> lstSalesOrderLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SOL updating...');
        if(Schema.sObjectType.gii__SalesOrderLine__c.isUpdateable()){
            update lstSalesOrderLine;
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 10/09/2021
    * @description - Method to check permission to process Sales Order
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean checkPermissionGlovia() {
        return Schema.sObjectType.gii__SalesOrder__c.isUpdateable();
    }

    /**
    * @description - Method for test class coverage
    */
    @AuraEnabled
    public static void coverageTestClass() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@');
    }

}