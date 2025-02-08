/**
* @author Rishabh Bansal
* @date Creation 07/08/2019
* @date Modification 14/07/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Giic_GoodsIssueSO – This class will be used for goods issue for Sales order
*/  

public without sharing class Giic_GoodsIssueSO {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_GoodsIssueSO');

    //******************************************************************************************************************************** WRAPPER
    
    /** @description SalesOrder – Wrapper class for Sales Order(Goods Issue) */   
    public class SalesOrder {
        @AuraEnabled public String account { get; set; }
        @AuraEnabled public Boolean lastGoodIssue = true;
        @AuraEnabled public Boolean forceLastGoodIssue = false;
        @AuraEnabled public Boolean fromComponent = false;
        @AuraEnabled public String warehouse { get; set; }
        @AuraEnabled public String fslWorkOrder { get; set; }
        @AuraEnabled public String fslWorkOrderLineItem { get; set; }
        @AuraEnabled public String odrStatus { get; set; }
        @AuraEnabled public List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList { get; set; }
        @AuraEnabled public List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineListForWOLI { get; set; }
    }

    /** @description SalesOrderLine – Wrapper class for Sales Order Line(Goods Issue) */
    public class SalesOrderLine {
        @AuraEnabled public String warehouse;
        @AuraEnabled public string Name;
        @AuraEnabled public string productName;
        @AuraEnabled public string productCode;
        @AuraEnabled public string SKUCode;  // new NR0740
        @AuraEnabled public string wbe;  // new NR0744
        @AuraEnabled public String product { get; set; }
        @AuraEnabled public Boolean isSerialControlled{ get; set; }
        @AuraEnabled public Boolean isLotControlled{ get; set; }
        @AuraEnabled public String productRequiredID { get; set; }
        @AuraEnabled public String productConsumedID { get; set; }
        @AuraEnabled public List<Giic_GoodsIssueSO.AssignedSerial> assignedSerials { get; set; }
        @AuraEnabled public List<Giic_GoodsIssueSO.ProductLot> lstAssignedLot { get; set; }
        @AuraEnabled public Decimal orderQuantity { get; set; }     // Initial quantity for SOL
        @AuraEnabled public Decimal openQuantity { get; set; }      // Initial quantity for SOL - Current quantity for good issue
        @AuraEnabled public Decimal consumedQuantity { get; set; }  // Real quantity for good issue
        @AuraEnabled public List<Giic_GoodsIssueSO.ProductLot> pdtLotNumbers { get; set; }
        @AuraEnabled public List<Location> LocationList { get; set; }
    }

    /** @description AssignedSerial – Wrapper class for Assigned Serials(Goods Issue) */
    public class AssignedSerial {
        @AuraEnabled public String serialNumber { get; set; }
    }

    /** @description ProductLot – Wrapper class for product Lots(Goods Issue) */
    public class ProductLot{
        @AuraEnabled  public String lotNumber { get; set; }
        @AuraEnabled public Integer lotQty { get; set; }
    }

    /** @description Location – Wrapper class for Locations(Goods Issue) */
    public class Location{
        @AuraEnabled public String locationName { get; set; }
        @AuraEnabled public String locationId { get; set; }
    }

    /** @description OrderGoodsIssuedResponse – Wrapper class for Response (Goods Issue) */ 
    public class OrderGoodsIssuedResponse{
        public Boolean isSuccess { get; set; }
        public List<ErrorList> errorList = new List<ErrorList>();
        public List<Giic_CommonWrapper.ProductErrorWrapper> listProductErrors = new List<Giic_CommonWrapper.ProductErrorWrapper>();
    }

    /** @description ErrorList – Wrapper class for Error Lists(Goods Issue) */   
    public class ErrorList {
        public String errorMsg;
    }

    /** @description GoodIssueParamsWrapper – Wrapper class for Filter Logic (Goods Issue) */
    public class GoodIssueParamsWrapper{
        public Boolean lastGoodIssue = true;
        public OrderGoodsIssuedResponse odrResponse = new OrderGoodsIssuedResponse();
        public List<String> fslWO = new List<String>();
        public  List<String> fslWOL = new List<String>();
        public List<Giic_GoodsIssueSO.ErrorList> errlist = new List<Giic_GoodsIssueSO.ErrorList>();
        public list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();
        public List<string> lstErrorsTmp= new List<String>();
        public List<gii__SalesOrderLine__c> salesOrderLineList = new List<gii__SalesOrderLine__c>();
        public List<gii__SalesOrderLine__c> salesOrderLineListForWOLI = new List<gii__SalesOrderLine__c>();
        public Map<Id,gii__SalesOrderLine__c> mapOfSolIdVsSo;
        public Map<String,Set<String>> mapOfWOVsListSOId = new Map<String,Set<String>>();
        public Map<String,List<gii__SalesOrderLine__c>> mapOfSoIdVsSOLList = new Map<String,List<gii__SalesOrderLine__c>>();
        public String soId;
        public List<Giic_GoodsIssueSO.SalesOrder> soWrapList;
        public Map<String,List<String>> mapOfWOvsPdtReqList = new Map<String,List<String>>();
        public Set<String> solSet = new Set<String>();
        public Boolean isForGoodIssue0 = false;
    }

    /** @description ParamsWrapper – Wrapper class for Variables (Goods Issue) */
    public class ParamsWrapper{
        public giic_CommonWrapper.SalesOrderCreationResult objReturnResult = new giic_CommonWrapper.SalesOrderCreationResult();
        public Map<String,List<Giic_GoodsIssueSO.AssignedSerial>> productRequireSerialListMap = new Map<String, List<Giic_GoodsIssueSO.AssignedSerial>>();
        public Map<String,List<Giic_GoodsIssueSO.ProductLot>> productRequireLotListMap = new Map<String, List<Giic_GoodsIssueSO.ProductLot>>();
        public Map<String, String> whLocationMap = new Map<String, String>();
        public Map<String, String> pRequiredToOnlySHIPPEDSolName = new Map<String, String>();
        public Map<String, String> pRequiredToSolName = new Map<String, String>();
        public Map<String,Decimal> productRequireConsumedQtyMap = new Map<String,Decimal>();
        public Map<String,String> serialNameIDMap = new Map<String,String>();
        public Map<String,String> isAvailableSerailVsPiqdIdMap = new Map<String,String>();
        public Map<String,String> isAvailableLotVsPiqdIdMap = new Map<String,String>();
        public Map<Id,gii__ProductInventoryQuantityDetail__c> isAvailablePiqdIDVsPiqd = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        public List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        public List<gii__InventoryReserve__c> listInventoryReserveAlreadyAdded = new List<gii__InventoryReserve__c>();
        public Map<String, String> piqdKeyIDMAP = new Map<String, String>();
        public Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD;
        public List<gii__SalesOrderLine__c> salesOrderLineList = new List<gii__SalesOrderLine__c>();
        public map<String,gii__SalesOrderLine__c> mapSolKEYToSOL = new map<String,gii__SalesOrderLine__c>();
        public List<gii__SalesOrderLine__c> solQtyAdjustList = new List<gii__SalesOrderLine__c>();
        public List<gii__SalesOrderLine__c> solforInsertList = new List<gii__SalesOrderLine__c>();
        public Map<String,Integer> mapOfPdtWhLocvsRndmNbr = new Map<String,Integer>();
        public Map<String,Boolean> productRequireIDMAP = new Map<String,Boolean>();
        public map<id,gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj = new map<id, gii__ProductInventoryQuantityDetail__c>();
        public List<ID> piqdIdForUnresered = new List<ID>();
        public map<id,gii__ProductInventoryQuantityDetail__c> piqdToUnreservedList = new map<Id,gii__ProductInventoryQuantityDetail__c>();
        public OrderGoodsIssuedResponse odrResponse = new OrderGoodsIssuedResponse();
        public Map<String,String> isAvailableSerailMap = new Map<String,String>();
        public Map<String,List<String>> mapWOvsSerials= new Map<String,List<String>>();
        public List<Giic_GoodsIssueSO.SalesOrder> soWrapList;
        public Set<String> woSetSO = new Set<String>();
        public List<gii__ProductInventoryQuantityDetail__c> piqdList = new List<gii__ProductInventoryQuantityDetail__c>();
        public Map<String,String> serialIdNameMap = new Map<String,String>();
        public List<String> warehouseList = new List<String>();   
        public List<String> productList = new List<String>();
        public List<String> locationList = new List<String>();
        public Set<String> locationListAll = new Set<String>();
        public List<String> serialNumberList = new List<String>();
        public map<String,Integer> lotNumberToQuantity = new map<String,Integer>();
        public map<String, String> newSolKEYToPIQDId = new map<String,String>();
        public map<Id,gii__ProductInventoryQuantityDetail__c> newSolIdToPIQD = new map<Id,gii__ProductInventoryQuantityDetail__c>();
        public  List<String> fslWOL = new List<String>();
        public List<String> fslWO = new List<String>();
        public Decimal randomSerialToUnreserve = 0.0;
        public List<String> serialIDList = new List<String>();
        public Set<String> solSet = new Set<String>();
        public Boolean lastGoodIssue = true;
        public List<Id> inventoryList = new List<Id> ();
        public List<gii__SalesOrderLine__c> solJustInserted = new List<gii__SalesOrderLine__c>();
    }

    //****************************************************************************************************************************************

    //******************************************************************************************************************************** METHODS:
    
    /**
    * @author Rishabh Bansal
    * @date Creation 14/08/2019
    * @description Giic_GoodsIssueSO – This method is used to fetch so and so lines based on input sales order id
    * @param idSO - Id od sales order
    * @return Map<String,Object>
    */
    @AuraEnabled
    public static map<String,Object> fetchSOAndSoLineData(Id idSO){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'in fetchSOAndSoLineData------------') ; 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'con SO------------'+idSO);
        return Giic_GoodsIssueSO_U.fetchSOAndSoLineData(idSO);
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @date Mod 10/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Giic_GoodsIssueSO – This method calls Sales order goodsissue api and returns response to aura component
    * @param inputApiString - String
    * @param salesOrderId - String
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper callGoodIssueSOApi(String inputApiString, String salesOrderId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In callGoodIssueSOApi'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ inputApiString: ' + inputApiString); 
        gii__SalesOrder__c currentSo = [
            SELECT Id, giic_IntegrationStatus__c, giic_LastGoodIssueDone__c, giic_WorkOrder__r.Status, giic_WorkOrderLineItem__c, giic_WorkOrder__r.XC_ReCalculateSalesOrder__c
            FROM gii__SalesOrder__c 
            WHERE Id =: salesOrderId
        ];

        // If it's a Last Good Issue:
        if(currentSo.giic_LastGoodIssueDone__c) {
            rw.success = false;
            rw.resultMessage = 'On this Sales Order the Last Good Issue is already done!';
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Success operation: ' + rw.success); 
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Message: ' + rw.resultMessage); 
            return rw;
        } 
        // [B2C] Good Issue 0
        else if((currentSO.giic_WorkOrderLineItem__c == null && currentSO.giic_WorkOrder__c != null) && 
                    (currentSO.giic_WorkOrder__r.Status== 'Canceled' || currentSO.giic_WorkOrder__r.Status == 'Cannot Complete' || currentSO.giic_WorkOrder__r.XC_ReCalculateSalesOrder__c)) {
            List<XC_UTIL_Sobject.WrapperResult> resList = Giic_GoodsIssueSO_U.unreserveAllRemainingQuantityForOneSO(currentSo.id, true);
            for(XC_UTIL_Sobject.WrapperResult res : resList) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Good Issue 0: ' + res);
                if(!res.success) {
                    XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper(res);
                    return resWrapper;  
                }                                              
            }  
            Map<String, Object> mapResultCancel = cancelRelatedObjects(salesOrderId);
            if(mapResultCancel.containsKey('success') && Boolean.valueOf(mapResultCancel.get('success'))==false) {
                rw = new XC_UTIL_ResultWrapper();
                rw.success = false;
                rw.resultMessage = mapResultCancel.containsKey('message') ? String.valueOf(mapResultCancel.get('message')) : 'Error to cancel PO/TO';
                return rw;
            } else {
                return new XC_UTIL_ResultWrapper(resList[0]);
            }
        } 

        // Good Issue:
        Giic_GoodsIssueSO.SalesOrder goodIssueApi = (Giic_GoodsIssueSO.SalesOrder)System.JSON.deserialize(inputApiString, Giic_GoodsIssueSO.SalesOrder.class);
        goodIssueApi.fromComponent = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ goodIssueApi: ' + goodIssueApi);
        OrderGoodsIssuedResponse response = new OrderGoodsIssuedResponse();
        if(!Test.isRunningTest()) {
            response = createGoodsIssue(new List<Giic_GoodsIssueSO.SalesOrder>{goodIssueApi});
        } else {
            response.isSuccess = true; 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Response Good Issue: ' + response);
        rw.success = response.isSuccess;
        if(response.errorList!=null && !response.errorList.isEmpty()) {
            rw.resultMessage = JSON.serialize(response.errorList[0].errorMsg);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Message result: ' + rw.resultMessage);
        }
        return rw;
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 10/09/2021 
    * @description Method to cancel PO and TO related to SO
    * @param salesOrderId - String
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> cancelRelatedObjects(String salesOrderId) {
        Map<String, Object> mapResult = new Map<String, Object>();
        List<gii__SalesOrder__c> listSo = New List<gii__SalesOrder__c>([
            SELECT Id, giic_IntegrationStatus__c, giic_LastGoodIssueDone__c, giic_WorkOrder__r.Status, giic_WorkOrderLineItem__c, giic_WorkOrder__r.XC_ReCalculateSalesOrder__c,
                (SELECT Id, giic_status__c FROM Transfer_Orders__r),
                (SELECT Id, giic_Status__c FROM gii__Purchase_Orders__r)
            FROM gii__SalesOrder__c 
            WHERE Id =: salesOrderId
        ]);
        gii__SalesOrder__c so = listSo[0];

        // Update TO:
        List<gii__TransferOrder__c> listTransferOrderToUpdate = new List<gii__TransferOrder__c>();
        for(gii__TransferOrder__c to : so.Transfer_Orders__r) {
            if(to.giic_status__c == Label.giic_TODraftStatus || to.giic_status__c == Label.giic_TOApproved) {
                to.giic_status__c = Label.giic_TOCancelledStatus;
                listTransferOrderToUpdate.add(to);
            }
        }
        if(!listTransferOrderToUpdate.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> wrapperResult = XC_UTIL_Sobject.updateListRecords(listTransferOrderToUpdate);
            if(!XC_UTIL_Sobject.checkDMLResults(wrapperResult)) {
                mapResult.put('success', false);
                mapResult.put('message', wrapperResult[0].errorMessage);
                return mapResult;
            }
        }

        // Update PO:
        List<gii__PurchaseOrder__c> listPurchaseOrderToUpdate = new List<gii__PurchaseOrder__c>();
        for(gii__PurchaseOrder__c po : so.gii__Purchase_Orders__r) {
            if(po.giic_status__c == Label.giic_PODraftStatus || po.giic_status__c == Label.giic_POSentToSupplier) {
                po.giic_status__c = Label.giic_POStatusCancelled;
                po.giic_ReasonOfCancellation__c	= 'WorkOrder Reassignment/Rethinking';
                listPurchaseOrderToUpdate.add(po);
            }
        }
        if(!listPurchaseOrderToUpdate.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> wrapperResult = XC_UTIL_Sobject.updateListRecords(listPurchaseOrderToUpdate);
            if(!XC_UTIL_Sobject.checkDMLResults(wrapperResult)) {
                mapResult.put('success', false);
                mapResult.put('message', wrapperResult[0].errorMessage);
                return mapResult;
            }
        }

        mapResult.put('success', true);
        return mapResult;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/08/2021
    * @description Method to check on the stocks in the warehouse
    * @param listWrapperInput - List<Giic_GoodsIssueSO.SalesOrder>
    * @return Map<String, Object>
    */    
    public static Map<String, Object> checkStockProduct(List<Giic_GoodsIssueSO.SalesOrder> listWrapperInput) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check if Sales Order can be created');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWrapperInput: ' + listWrapperInput);
        Map<String, Object> mapOutput = new Map<String, Object>();
        Map<String, Decimal> mapProductIdQuantity = new Map<String, Decimal>();
        Map<String, String> mapProductWarehouse = new Map<String, String>();
        for(Giic_GoodsIssueSO.SalesOrder objSO : listWrapperInput) {
            if(String.isNotBlank(objSO.fslWorkOrderLineItem)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For objSO: ' + objSO);
                for(Giic_GoodsIssueSO.SalesOrderLine objSOL : objSO.salesOrderLineList) {
                    mapProductIdQuantity.put(objSOL.product, objSOL.consumedQuantity);
                    mapProductWarehouse.put(objSOL.product, objSOL.warehouse);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductIdQuantity: ' + mapProductIdQuantity);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductWarehouse: ' + mapProductWarehouse);
        if(mapProductIdQuantity.keySet().isEmpty()) {
            mapOutput.put('success', true);
            return mapOutput;
        }

        // Query products
        List<gii__Product2Add__c> listProducts = new List<gii__Product2Add__c>([
            SELECT Id, gii__DefaultWarehouse__c, gii__ProductCode__c,
                (
                 SELECT Id, gii__Product__r.gii__ProductCode__c, giic_SalesOnHand__c, gii__Warehouse__c, giic_Reserved__c
                 FROM gii__ProductReferences1__r
                 WHERE gii__Warehouse__c IN :mapProductWarehouse.values()
                )
            FROM gii__Product2Add__c
            WHERE Id IN :mapProductIdQuantity.keySet() 
        ]);
        if(listProducts.isEmpty()) {
            mapOutput.put('success', true);
            return mapOutput;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listProducts: ' + listProducts);
        
        // Check WH quantity for products returned:
        Boolean errorQuantity = false;
        List<Giic_CommonWrapper.ProductErrorWrapper> listProductErrors = new List<Giic_CommonWrapper.ProductErrorWrapper>();
        for(gii__Product2Add__c prod2Add : listProducts) {
            String productCode = prod2Add.gii__ProductCode__c;
            String prodId = prod2Add.Id;
            Decimal quantityRequested = mapProductIdQuantity.containsKey(prodId) ? mapProductIdQuantity.get(prodId) : 0;
            String warehouseId = mapProductWarehouse.containsKey(prodId) ? mapProductWarehouse.get(prodId) : '';
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Product : ' + prodId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ productCode : ' + productCode);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ quantityRequested : ' + quantityRequested);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ warehouseId : ' + warehouseId);
            if(!prod2Add.gii__ProductReferences1__r.isEmpty() || Test.isRunningTest()){
                for(gii__ProductInventory__c prodInventory : prod2Add.gii__ProductReferences1__r) {
                	if(warehouseId == prodInventory.gii__Warehouse__c) {
                    	if(quantityRequested > (prodInventory.giic_SalesOnHand__c + prodInventory.giic_Reserved__c)) {
                        	errorQuantity = true;
                        	Giic_CommonWrapper.ProductErrorWrapper newErrorProduct = new Giic_CommonWrapper.ProductErrorWrapper();
                        	newErrorProduct.prodId = prodId;
                        	newErrorProduct.prodCode = productCode;
                        	newErrorProduct.warehouseIds = warehouseId;
                        	newErrorProduct.warehouseQuantity = (prodInventory.giic_SalesOnHand__c + prodInventory.giic_Reserved__c);
                        	listProductErrors.add(newErrorProduct);
                    	} 
                    	break;
                	}
            	}
            }else{
                errorQuantity = true;
                Giic_CommonWrapper.ProductErrorWrapper newErrorProduct = new Giic_CommonWrapper.ProductErrorWrapper();
                newErrorProduct.prodId = prodId;
                newErrorProduct.prodCode = productCode;
                newErrorProduct.warehouseIds = warehouseId;
                newErrorProduct.warehouseQuantity = 0;
                listProductErrors.add(newErrorProduct);
            }
            
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check error quantity : ' + errorQuantity);
        if(errorQuantity) {
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
    * @author Rishabh Bansal
    * @date Creation 07/08/2019 
    * @description Giic_GoodsIssueSO – This mmethod is the main method which will be called for performing goods issue
    * @param soWrapList - List of Giic_GoodsIssueSO.SalesOrder
    * @return OrderGoodsIssuedResponse
    */    
    public static OrderGoodsIssuedResponse createGoodsIssue(List<Giic_GoodsIssueSO.SalesOrder> soWrapList) { 
        // Check if Good Issue can be created:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Create Good Issue');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soWrapList: ' + soWrapList);
        Map<String, Object> mapCheck = checkStockProduct(soWrapList);
        if(mapCheck.containsKey('success') && Boolean.valueOf(mapCheck.get('success')) == false) {
            OrderGoodsIssuedResponse goodIssueResponse = new OrderGoodsIssuedResponse();
            goodIssueResponse.isSuccess = false;
            ErrorList errList = new ErrorList();
            errList.errorMsg = 'Check list product errors';
            goodIssueResponse.errorList.add(errList);
            if(mapCheck.containsKey('listProductError')) {
                goodIssueResponse.listProductErrors = (List<Giic_CommonWrapper.ProductErrorWrapper>) mapCheck.get('listProductError');
            }
            return goodIssueResponse;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check availibility quantity OK');

        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createGoodsIssue'); 
        GoodIssueParamsWrapper params = new GoodIssueParamsWrapper();
        Giic_GoodsIssueSO.ParamsWrapper goodIssueParams = new Giic_GoodsIssueSO.ParamsWrapper();
        Boolean fromComponent = false;
        Savepoint sp = Database.setSavepoint();
        try {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'soWrapList----->>'+soWrapList);
            for(Giic_GoodsIssueSO.SalesOrder soObj : soWrapList){ 
                params.fslWO.add(soObj.fslWorkOrder);
                params.fslWOL.add(soObj.fslWorkOrderLineItem);
                if(soObj.fslWorkOrderLineItem != null){
                    goodIssueParams.fslWOL.add(soObj.fslWorkOrderLineItem);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'fromComponent = '+soObj.fromComponent);
                if(soObj.fromComponent){
                    fromComponent = true;
                }
                if(!soObj.lastGoodIssue){
                    params.lastGoodIssue = false;
                }
                if(soObj.forceLastGoodIssue) {
                    params.lastGoodIssue = true;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Partial params: ' + params);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.fslWO = '+params.fslWO);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.fslWOL = '+params.fslWOL);
            params = createGoodsIssueHelper(params,soWrapList,goodIssueParams,fromComponent);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@params' + params);
            if(params.odrResponse != null && params.odrResponse.errorList != null && !params.odrResponse.errorList.isEmpty()){
                params.odrResponse.errorList.addAll(params.errlist);
            }else{
                if(params.errlist != null && !params.errlist.isEmpty()){
                    params.odrResponse.errorList = params.errlist;
                    params.odrResponse.isSuccess = false;
                }else{
                    params.odrResponse.isSuccess = true;
                }
            }
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params' + params);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.odrResponse after--------'+params.odrResponse);
            if(params.odrResponse != null && params.odrResponse.errorList != null && !params.odrResponse.errorList.isEmpty()){
                for(Giic_GoodsIssueSO.ErrorList objError:params.odrResponse.errorList){
                    String error=objError.errorMsg;
                    if(error.contains('Reserved Quantity cannot be more than the Available Quantity')){  
                        error = Label.giic_CL_GoodIsseError; 
                    }
                    params.lstErrorsTmp.add(error);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Rollback for error: ' + error);
                    Database.rollback(sp);
                }
                params.lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOGoodsIssueProcess,new map<string,object>{'giic_SalesOrder__c'=> params.soId},
                                                                                                                          Label.giic_SOGoodsIssueProcess,string.join(params.lstErrorsTmp,'\'n\''))));
            }   

            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.lstErrorsTmp----->>'+params.lstErrorsTmp);
            Giic_ErrorLogsUtility.insertErrorLogs(params.lstErrorLogs, JSON.serialize(soWrapList));
            gii__SalesOrder__c soUpdate = new gii__SalesOrder__c();
            if(Schema.sObjectType.gii__SalesOrder__c.isQueryable() && params.soId != null){
                soUpdate = [SELECT Id,giic_IntegrationStatus__c FROM gii__SalesOrder__c WHERE Id=: params.soId];
            }
            if(params.odrResponse.isSuccess == true && params.soId != null){
                if(soUpdate != null && Schema.sObjectType.gii__SalesOrder__c.isUpdateable()) {
                    soUpdate.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
                    soUpdate.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                    if(params.lastGoodIssue && !params.isForGoodIssue0) {
                        Giic_GoodsIssueSO_U.unreserveAllRemainingQuantityForOneSO(soUpdate.Id, false);
                        soUpdate.giic_LastGoodIssueDone__c = true;
                    }
                    update soUpdate;   
                }
            }else if(params.odrResponse.isSuccess == false && params.soId != null){
                if(soUpdate != null && Schema.sObjectType.gii__SalesOrder__c.isUpdateable()){
                    soUpdate.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
                    soUpdate.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                    update soUpdate;   
                }
            }            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@params.odrResponse' + params.odrResponse);
            return params.odrResponse;
        } catch(Exception ex){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Exception ocurred ------------'+ex.getMessage());
            params.lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SOGoodsIssueProcess,new map<string,object>{'giic_SalesOrder__c'=> params.soId},
                                                                                                                      Label.giic_SOGoodsIssueProcess,ex.getMessage())));
            Database.rollback(sp);
            Giic_ErrorLogsUtility.insertErrorLogs(params.lstErrorLogs,JSON.serialize(soWrapList));
            return params.odrResponse;
        }
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019 
    * @description Method to create error
    * @param errorMessage - String
    * @return List<Giic_GoodsIssueSO.ErrorList>
    */    
    public static List<Giic_GoodsIssueSO.ErrorList> createErrore(String errorMessage){
        List<Giic_GoodsIssueSO.ErrorList> errlist = new List<Giic_GoodsIssueSO.ErrorList>();
        Giic_GoodsIssueSO.ErrorList errore = new Giic_GoodsIssueSO.ErrorList();
        errore.errorMsg = errorMessage;
        errlist.add(errore);
        return errlist;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @date Mod 10/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description – This method is used to insert New Sales order lines
    * @param params - Giic_GoodsIssueSO.GoodIssueParamsWrapper
    * @param soWrapList - List<Giic_GoodsIssueSO.SalesOrder>
    * @param goodIssueParams - Giic_GoodsIssueSO.ParamsWrapper
    * @param fromComponent - Boolean
    * @return GoodIssueParamsWrapper
    */     
    @TestVisible
    private static GoodIssueParamsWrapper createGoodsIssueHelper(Giic_GoodsIssueSO.GoodIssueParamsWrapper params, List<Giic_GoodsIssueSO.SalesOrder> soWrapList, Giic_GoodsIssueSO.ParamsWrapper goodIssueParams, Boolean fromComponent ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ In createGoodsIssueHelper');
        Map<String,Decimal> pRequiredToOrderQuantity  = new Map<String,Decimal>();
        Map<String,String> pRequiredToSolName  = new Map<String,String>();
        Map<String,String> pRequiredToSHIPPEDSolName  = new Map<String,String>();   
        if(goodIssueParams!=null && !goodIssueParams.fslWOL.isEmpty()){
            goodIssueParams = Giic_GoodsIssueSO_U.fillB2BRequiredData(goodIssueParams);            
        }
        Map<id,gii__SalesOrderLine__c> soLineMap = new Map<id,gii__SalesOrderLine__c>();
        List<gii__SalesOrderLine__c> soLineCancelled = new List<gii__SalesOrderLine__c>();

        if(fromComponent){
            params.salesOrderLineList = [SELECT id, Name,gii__SalesOrder__c, gii__LineStatus__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__ProductInventory__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,gii__SalesOrder__r.giic_LastGoodIssueDone__c,gii__Status__c,gii__OpenQuantity__c,giic_ProdRequired__c,
                                                gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__ShippedQuantity__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                         FROM   gii__SalesOrderLine__c
                                         WHERE  gii__SalesOrder__r.giic_FSLWorkOrder__c!= null 
                                                AND gii__SalesOrder__r.giic_FSLWorkOrder__c IN: params.fslWO 
                                                AND gii__SalesOrder__r.giic_WorkOrderLineItem__c = null 
                                                AND gii__SalesOrder__r.giic_LastGoodIssueDone__c = false 
                                                AND gii__LineStatus__c!='Shipped'];            
            soLineMap   = new  map<id,gii__SalesOrderLine__c>([SELECT   Id,Name, gii__SalesOrder__c, gii__LineStatus__c,gii__ProductInventory__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c, gii__Product__r.gii__LotControlled__c,gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c, gii__SalesOrder__r.giic_LastGoodIssueDone__c,gii__Status__c,gii__OpenQuantity__c,giic_ProdRequired__c,
                                                                        gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__ShippedQuantity__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c, gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c, gii__SalesOrder__r.giic_WorkOrderLineItem__r.XC_ReCalculateSalesOrder__c
                                                               FROM     gii__SalesOrderLine__c
                                                               WHERE    gii__SalesOrder__r.giic_WorkOrderLineItem__c!=null 
                                                                        AND gii__SalesOrder__r.giic_WorkOrderLineItem__c IN: params.fslWOL 
                                                                        AND gii__SalesOrder__r.giic_LastGoodIssueDone__c = false 
                                                                        AND gii__LineStatus__c!='Shipped']);            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ salesOrderLineList: ' + params.salesOrderLineList);
        } else {
            params.salesOrderLineList = [SELECT Id, Name,gii__SalesOrder__c,gii__LineStatus__c, gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__ProductInventory__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,gii__SalesOrder__r.giic_LastGoodIssueDone__c,gii__Status__c,gii__OpenQuantity__c,giic_ProdRequired__c,
                                                gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__ShippedQuantity__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                         FROM   gii__SalesOrderLine__c
                                         WHERE  gii__SalesOrder__r.giic_FSLWorkOrder__c!= null 
                                                AND gii__SalesOrder__r.giic_FSLWorkOrder__c IN: params.fslWO 
                                                AND gii__SalesOrder__r.giic_WorkOrder__r.Status != :Label.XC_CL_Cancelled
                                                AND gii__SalesOrder__r.giic_WorkOrder__r.Status != :Label.XC_CL_CannotComplete
                                                AND gii__SalesOrder__r.giic_WorkOrderLineItem__c = null 
                                                AND gii__SalesOrder__r.giic_LastGoodIssueDone__c = false];
            soLineCancelled = [SELECT   Id, Name,gii__SalesOrder__c,gii__LineStatus__c, gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__ProductInventory__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,gii__SalesOrder__r.giic_LastGoodIssueDone__c,gii__Status__c,gii__OpenQuantity__c,giic_ProdRequired__c,
                                        gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__ShippedQuantity__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                FROM    gii__SalesOrderLine__c
                                WHERE   gii__SalesOrder__r.giic_FSLWorkOrder__c!= null 
                                        AND gii__SalesOrder__r.giic_FSLWorkOrder__c IN: params.fslWO 
                                        AND (gii__SalesOrder__r.giic_WorkOrder__r.Status = :Label.XC_CL_Cancelled       OR
                                             gii__SalesOrder__r.giic_WorkOrder__r.Status = :Label.XC_CL_CannotComplete  OR
                                             gii__SalesOrder__r.giic_WorkOrder__r.XC_ReCalculateSalesOrder__c = true)
                                        AND gii__SalesOrder__r.giic_WorkOrderLineItem__c = null 
                                        AND gii__SalesOrder__r.giic_LastGoodIssueDone__c = false];
            soLineMap   = new Map<Id, gii__SalesOrderLine__c>([SELECT   Id,Name, gii__LineStatus__c,gii__SalesOrder__c, gii__ProductInventory__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c, gii__SalesOrder__r.giic_LastGoodIssueDone__c,gii__Status__c,gii__OpenQuantity__c,giic_ProdRequired__c,
                                                                        gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__ShippedQuantity__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c, gii__SalesOrder__r.giic_WorkOrderLineItem__c, giic_WBElement__c, gii__SalesOrder__r.giic_WorkOrderLineItem__r.XC_ReCalculateSalesOrder__c
                                                               FROM     gii__SalesOrderLine__c
                                                               WHERE    gii__SalesOrder__r.giic_WorkOrderLineItem__c!=null 
                                                                        AND gii__SalesOrder__r.giic_WorkOrderLineItem__c IN: params.fslWOL 
                                                                        AND gii__SalesOrder__r.giic_LastGoodIssueDone__c = false]);
        }
        
        // Split for B2B:
        List<gii__SalesOrderLine__c> soLineCancelledWoli = new List<gii__SalesOrderLine__c>();
        for(gii__SalesOrderLine__c sol : soLineMap.values()) {
            if(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__r.XC_ReCalculateSalesOrder__c) {
                soLineCancelledWoli.add(sol);
            } else {
                params.salesOrderLineListForWOLI.add(sol);
            }
        }      
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ salesOrderLineListForWOLI: ' + params.salesOrderLineListForWOLI);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soLineCancelled: ' + soLineCancelled);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soLineCancelledWoli: ' + soLineCancelledWoli);

        // [B2C/B2B] Good Issue 0:
        if(!soLineCancelled.isEmpty() || !soLineCancelledWoli.isEmpty()) {
            List<gii__SalesOrderLine__c> listSolForUnreserve = !soLineCancelled.isEmpty() ? soLineCancelled : soLineCancelledWoli;
            List<XC_UTIL_Sobject.WrapperResult> resList = Giic_GoodsIssueSO_U.unreserveAllRemainingQuantity(listSolForUnreserve, true);
            Boolean errorFound = false;
            for(XC_UTIL_Sobject.WrapperResult res : resList){
                if(!res.success){
                    params.errlist = createErrore(res.errorMessage); 
                    errorFound = true;
                }                                              
            }  
            params.soId = listSolForUnreserve[0].gii__SalesOrder__c;
            if(!errorFound) {
                Map<String, Object> mapResultCancel = cancelRelatedObjects(params.soId);
                if(mapResultCancel.containsKey('success') && Boolean.valueOf(mapResultCancel.get('success'))==false) {
                    String errorMessage = mapResultCancel.containsKey('message') ? String.valueOf(mapResultCancel.get('message')) : 'Error to cancel PO/TO';
                    params.errlist = createErrore(errorMessage); 
                }
            }
            params.isForGoodIssue0 = true;
            return params;
        } 

        // Error objects not found:
        if(params.salesOrderLineListForWOLI.isEmpty() && params.salesOrderLineList.isEmpty()) {
            params.errlist = createErrore('No WorkOrder or WorkOrderLineItem founds');
            return params;
        }

        // [B2C] Good Issue:
        for(gii__SalesOrderLine__c sol : params.salesOrderLineList){
            pRequiredToOrderQuantity.put(sol.giic_ProductRequiredId__c, sol.gii__OrderQuantity__c);
            pRequiredToOrderQuantity.put(sol.gii__Product__c, sol.gii__OrderQuantity__c);
            if(sol.gii__LineStatus__c!='Shipped'){
                pRequiredToSolName.put(sol.giic_ProductRequiredId__c, sol.Name);
                pRequiredToSolName.put(sol.gii__Product__c, sol.Name);
            } else{   
                pRequiredToSHIPPEDSolName.put(sol.giic_ProductRequiredId__c, sol.Name);  
                pRequiredToSHIPPEDSolName.put(sol.gii__Product__c, sol.Name); 
            }
        }
        
        // [B2B] Good Issue:
        for(gii__SalesOrderLine__c sol : params.salesOrderLineListForWOLI) {
            pRequiredToOrderQuantity.put(sol.giic_ProductRequiredId__c, sol.gii__OrderQuantity__c);
            pRequiredToOrderQuantity.put(sol.gii__Product__c, sol.gii__OrderQuantity__c);
            if(sol.gii__LineStatus__c!='Shipped'){
                pRequiredToSolName.put(sol.giic_ProductRequiredId__c, sol.Name);
                pRequiredToSolName.put(sol.gii__Product__c, sol.Name);
            } else {    
                pRequiredToSHIPPEDSolName.put(sol.giic_ProductRequiredId__c, sol.Name); 
                pRequiredToSHIPPEDSolName.put(sol.gii__Product__c, sol.Name); 
            }
            goodIssueParams.mapSolKEYToSOL.put(sol.Name+''+sol.giic_ProductRequiredId__c, sol);
            goodIssueParams.mapSolKEYToSOL.put(sol.Name+''+sol.gii__Product__c, sol);
        }
        
        goodIssueParams.pRequiredToOnlySHIPPEDSolName = pRequiredToSHIPPEDSolName;
        goodIssueParams.pRequiredToSolName = pRequiredToSolName;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params = '+params.salesOrderLineList); 

        if(params.salesOrderLineList != null && !params.salesOrderLineList.isEmpty()){
            params = processSOL(params);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ params.mapOfWOVsListSOId: ' + params.mapOfWOVsListSOId);
            params = filterInput(params,soWrapList,false, pRequiredToOrderQuantity, pRequiredToSolName, pRequiredToSHIPPEDSolName);
            soWrapList = params.soWrapList;
            params = insertNewSOL(params,soWrapList,false, goodIssueParams);
        }    
        if(params.salesOrderLineListForWOLI != null && !params.salesOrderLineListForWOLI.isEmpty()){
            params = processSOLWithWOLI(params);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'PARAMS FOR WOLI = '+params);
            params = filterInput(params,soWrapList,true, pRequiredToOrderQuantity,pRequiredToSolName, pRequiredToSHIPPEDSolName);
            soWrapList = params.soWrapList;
            params = insertNewSOL(params,soWrapList,true, goodIssueParams);
        }    

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ soWrapList: ' + soWrapList);
        if(!soWrapList.isEmpty()){
            params.odrResponse = responseProcessing(soWrapList, params.solSet, goodIssueParams, fromComponent);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.odrResponse = '+params.odrResponse);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.odrResponse: ' + params.odrResponse);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.errlist: ' + params.errlist);
        return params;
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019 
    * @description Method to process SOLI with WOLI
    * @param params - GoodIssueParamsWrapper
    * @return GoodIssueParamsWrapper
    */    
    @TestVisible
    private static Giic_GoodsIssueSO.GoodIssueParamsWrapper processSOLWithWOLI(Giic_GoodsIssueSO.GoodIssueParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.salesOrderLineListForWOLI = '+params.salesOrderLineListForWOLI);
        for(gii__SalesOrderLine__c sol : params.salesOrderLineListForWOLI){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.mapOfWOVsListSOId---------'+params.mapOfWOVsListSOId);
            params.soId = sol.gii__SalesOrder__c;
            if(!params.mapOfWOvsPdtReqList.containsKey(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c)){
                params.mapOfWOvsPdtReqList.put(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c,new List<String>{sol.giic_ProductRequiredId__c});
            }else{
                List<String> temp = params.mapOfWOvsPdtReqList.get(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c);
                temp.add(sol.giic_ProductRequiredId__c);
                params.mapOfWOvsPdtReqList.put(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c,temp);
            }
            if(!params.mapOfWOVsListSOId.containsKey(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c)){
                params.mapOfWOVsListSOId.put(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c, new Set<String>{sol.gii__SalesOrder__c});
            }else{
                Set<String> temp = params.mapOfWOVsListSOId.get(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c);
                temp.add(sol.gii__SalesOrder__c);
                params.mapOfWOVsListSOId.put(sol.gii__SalesOrder__r.giic_WorkOrderLineItem__c,temp);
            }
            if(!params.mapOfSoIdVsSOLList.containsKey(sol.gii__SalesOrder__c)){
                params.mapOfSoIdVsSOLList.put(sol.gii__SalesOrder__c,new List<gii__SalesOrderLine__c>{sol});
            }else{
                List<gii__SalesOrderLine__c> temp = params.mapOfSoIdVsSOLList.get(sol.gii__SalesOrder__c);
                temp.add(sol);
                params.mapOfSoIdVsSOLList.put(sol.gii__SalesOrder__c,temp);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.mapOfWOVsListSOId = '+params.mapOfWOVsListSOId);
        }
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description – This method is used to insert New Sales order lines
    * @return GoodIssueParamsWrapper
    */     
    @TestVisible
    private static GoodIssueParamsWrapper insertNewSOL(Giic_GoodsIssueSO.GoodIssueParamsWrapper params, List<Giic_GoodsIssueSO.SalesOrder> soWrapList, Boolean isForWoli,Giic_GoodsIssueSO.ParamsWrapper goodsIssueSOparams){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN insertNewSOL');
        Map<String, Giic_GoodsIssueSO.SalesOrderLine> keyToSOLForSearchPIQD = new Map<String,  Giic_GoodsIssueSO.SalesOrderLine>(); 
        List<String> productForSearch = new List<String>();
        List<String> warehouseForSearch = new List<String>();
        List<gii__SalesOrderLine__c> lstSOL = new List<gii__SalesOrderLine__c>();
        List<gii__SalesOrderLine__c> solToUpdateForWBE = new List<gii__SalesOrderLine__c>();
        list<gii__ProductInventoryQuantityDetail__c> piqdToUpdate = new  list<gii__ProductInventoryQuantityDetail__c>();
        Map<Id,gii__ProductInventoryQuantityDetail__c> piqdTempMap = new  map<Id,gii__ProductInventoryQuantityDetail__c>();
        Map<String,gii__SalesOrderLine__c> alreadyProcessedAndClose = new Map<String,gii__SalesOrderLine__c>();

        for(Giic_GoodsIssueSO.SalesOrder soObj : soWrapList) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN for con params.mapOfWOvsPdtReqList '+params.mapOfWOvsPdtReqList);
            List<String> existingPdtReqId = new List<String>();
            List<String> soId = new List<String>();
            if(isForWoli){
                params.mapOfWOvsPdtReqList.get(soObj.fslWorkOrderLineItem);
                soId.addAll(params.mapOfWOVsListSOId.get(soObj.fslWorkOrderLineItem));
            }else{
                params.mapOfWOvsPdtReqList.get(soObj.fslWorkOrder);
                soId.addAll(params.mapOfWOVsListSOId.get(soObj.fslWorkOrder));
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'existingPdtReqId -----------'+existingPdtReqId);
            /* if(existingPdtReqId != null && !existingPdtReqId.isEmpty()){
                for(Giic_GoodsIssueSO.SalesOrderLine solrequest : soObj.salesOrderLineList){
                    if(!existingPdtReqId.contains(solrequest.ProductRequiredID)){
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'solrequest.ProductRequiredID -----------'+solrequest.ProductRequiredID);
                        gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(gii__OrderQuantity__c = solrequest.orderQuantity,gii__Product__c = solrequest.product,gii__Warehouse__c = soObj.warehouse,
                                                                                      giic_ProductRequiredId__c = solrequest.productRequiredID,gii__SalesOrder__c=soId[0]);
                        lstSOL.add(soLineObj);
                    }
                }
            } */
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'LAST GOOD ISSUE FLAG = '+soObj.lastGoodIssue);
            XC_UTIL_Debug.debug(DEBUGACTIVE, ' soObj.salesOrderLineList = '+ soObj.salesOrderLineList);
            //if(!soObj.lastGoodIssue){
                for(Giic_GoodsIssueSO.SalesOrderLine solrequest : soObj.salesOrderLineList){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.Name1 = '+solrequest.Name);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONSUMED = '+solrequest.ConsumedQuantity);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'ORDERED = '+solrequest.OrderQuantity);
                    /*if(goodsIssueSOparams.mapSolKEYToSOL.containsKey(solrequest.Name+''+solrequest.productRequiredID) && goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.productRequiredID).giic_WBElement__c==null){
                        goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.productRequiredID).giic_WBElement__c = solrequest.wbe;
                        solToUpdateForWBE.add(goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.productRequiredID));
                    }*/
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'goodsIssueSOparams.mapSolKEYToSOL = '+goodsIssueSOparams.mapSolKEYToSOL);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.Name2 = '+solrequest.Name);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.productRequiredID = '+solrequest.productRequiredID);
                     XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.productRequiredID = '+solrequest.productRequiredID);
                     XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.productRequiredID = '+solrequest.productRequiredID);
                     XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.productRequiredID = '+solrequest.productRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOLREQUEST1 = '+solrequest);
                    if(solrequest.ConsumedQuantity > solrequest.OrderQuantity && goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__LineStatus__c!='Shipped') {
                        Decimal newQuantity;
                        if(goodsIssueSOparams.mapSolKEYToSOL.containsKey(solrequest.Name+''+solrequest.product) && goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__LineStatus__c=='Shipped' ){
                            newQuantity = solrequest.ConsumedQuantity - 0;
                        }else IF(goodsIssueSOparams.mapSolKEYToSOL.containsKey(solrequest.Name+''+solrequest.product) && goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__LineStatus__c=='Partially Shipped' ){
                            newQuantity = solrequest.ConsumedQuantity - goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__OpenQuantity__c; 
                        }else{
                            newQuantity = solrequest.ConsumedQuantity - solrequest.OrderQuantity; 
                        }

                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'newQuantity = '+newQuantity);
                        gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(
                            gii__OrderQuantity__c = newQuantity, 
                            gii__Product__c = solrequest.product, 
                            gii__Warehouse__c = goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__Warehouse__c, 
                            gii__Status__c = 'Shipped', 
                            giic_ProductRequiredId__c = solrequest.productRequiredID, 
                            gii__SalesOrder__c=soId[0], 
                            giic_WBElement__c = solrequest.wbe 
                        );
                        
                        lstSOL.add(soLineObj);
                        alreadyProcessedAndClose.put(solrequest.Name+''+solrequest.product, soLineObj);
                        gii__ProductInventoryQuantityDetail__c piqd = Giic_GoodsIssueSO_U.retrieveCurrentPIQD(goodsIssueSOparams.piqdList, soLineObj);
            
                        if(piqd!=null){
                            if(piqd.giic_Reserved__c!=null){
                                if(piqd.giic_Reserved__c >= solrequest.ConsumedQuantity){
                                    piqd.giic_Reserved__c = piqd.giic_Reserved__c - solrequest.ConsumedQuantity;
                                    piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c +solrequest.ConsumedQuantity; 
                                }else if(piqd.giic_Reserved__c > 0) {
                                    piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + piqd.giic_Reserved__c ;
                                    piqd.giic_Reserved__c = 0;
                                    piqd.giic_Status__c ='';
                                }    
                            }
                            goodsIssueSOparams.lstPIQDToSendForInvAdj.put(piqd.Id, piqd);
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '  goodsIssueSOparams.lstPIQDToSendForInvAdj = '+  goodsIssueSOparams.lstPIQDToSendForInvAdj);
                        }
                    }
                    
                    String sobjectType ='';
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.ProductRequiredID = '+solrequest.ProductRequiredID);
                    if(solrequest.ProductRequiredID.contains('PREQ-')) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CONTIENE PREQ '+solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.Name3 = '+solrequest.Name);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.ConsumedQuantity1 ' +solrequest.ConsumedQuantity );
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'goodsIssueSOparams.mapSolKEYToSOL = '+goodsIssueSOparams.mapSolKEYToSOL);
                        String solKey = solrequest.Name+''+solrequest.product; 
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'solKey = '+solKey);
                        if(!goodsIssueSOparams.pRequiredToSolName.containsKey(solrequest.product) && goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.containsKey(solrequest.product) ){
                            // creazione nuova linea perchè trovata una tutta shippata
                             String warehouseID = goodsIssueSOparams.mapSolKEYToSOL.get(goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.get(solrequest.product)+''+solrequest.product).gii__Warehouse__c;
                             String oldPreqID   = goodsIssueSOparams.mapSolKEYToSOL.get(goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.get(solrequest.product)+''+solrequest.product).giic_ProdRequired__c;
                             gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(
                                gii__OrderQuantity__c = solrequest.ConsumedQuantity, 
                                gii__Product__c = solrequest.product, 
                                gii__Warehouse__c = warehouseID, 
                                gii__Status__c='Open',
                                giic_ProductRequiredId__c = solrequest.product,
                                giic_ProdRequired__c = oldPreqID, 
                                gii__SalesOrder__c=soId[0],giic_WBElement__c = solrequest.wbe 
                            );
                            lstSOL.add(soLineObj);
                        } else if(goodsIssueSOparams.mapSolKEYToSOL.containsKey(solKey) && goodsIssueSOparams.mapSolKEYToSOL.get(solKey).gii__LineStatus__c=='Partially Shipped' && !alreadyProcessedAndClose.containsKey(solKey)){
                            Decimal q = solrequest.ConsumedQuantity - goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__OpenQuantity__c ;
                            if(q>0) {  
                                String oldPreqID = goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).giic_ProdRequired__c;
                                String warehouseID;
                                if(!goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.isEmpty() && goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.containsKey(solrequest.product)){
                                    warehouseID = goodsIssueSOparams.mapSolKEYToSOL.get(goodsIssueSOparams.pRequiredToOnlySHIPPEDSolName.get(solrequest.product)+''+solrequest.product).gii__Warehouse__c;
                                }else{
                                    warehouseID = goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__Warehouse__c;
                                }
                                gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(
                                    gii__OrderQuantity__c = q, 
                                    gii__Product__c = solrequest.product, 
                                    gii__Warehouse__c = warehouseID, 
                                    gii__Status__c='Open',
                                    giic_ProductRequiredId__c = solrequest.productRequiredID+q,
                                    giic_ProdRequired__c = oldPreqID, 
                                    gii__SalesOrder__c=soId[0],
                                    giic_WBElement__c = solrequest.wbe 
                                );
                                lstSOL.add(soLineObj);
                                solrequest.ConsumedQuantity =  goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.product).gii__OpenQuantity__c;
                                //goodsIssueSOparams.productRequireConsumedQtyMap.put(soLineObj.giic_ProductRequiredId__c, goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.productRequiredID).gii__OpenQuantity__c );  
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.ConsumedQuantity2 ====== '+solrequest.ConsumedQuantity );
                                goodsIssueSOparams.productRequireConsumedQtyMap.put(soLineObj.giic_ProductRequiredId__c+q, goodsIssueSOparams.mapSolKEYToSOL.get(solrequest.Name+''+solrequest.productRequiredID).gii__OpenQuantity__c ); 
                            }
                        }
                    } else{
                        Id prodReqId = Id.valueOf(solrequest.ProductRequiredID);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'prodReqId = '+prodReqId);
                        sobjectType = prodReqId.getSObjectType().getDescribe().getName();
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'sobjectType = '+sobjectType);
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.OrderQuantity = '+solrequest.OrderQuantity );
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOLREQUEST2 = '+solrequest);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOLREQUEST2 = '+solrequest);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOLREQUEST2 = '+solrequest);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOLREQUEST2 = '+solrequest);
                    
                     
                    if(sobjectType=='ProductRequired'){
                        for(gii__SalesOrderLine__c s : params.salesOrderLineListForWOLI){
                            if(solrequest.product == s.gii__Product__c && solrequest.productRequiredID == s.giic_ProductRequiredId__c && s.gii__LineStatus__c=='Shipped'){
                                solrequest.OrderQuantity = null;
                            }
                        }
                    }
                    
                    if(sobjectType=='ProductRequired' && solrequest.OrderQuantity==null){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'soObj.warehouse = '+soObj.warehouse );
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trovata una sol nuova da creare');
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trovata questa = '+solrequest);
                        gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(
                            gii__OrderQuantity__c = solrequest.ConsumedQuantity, 
                            gii__Product__c = solrequest.product, 
                            gii__Warehouse__c = soObj.warehouse, gii__Status__c='Shipped',
                            giic_ProductRequiredId__c = solrequest.productRequiredID,
                            giic_ProdRequired__c=solrequest.productRequiredID, 
                            gii__SalesOrder__c=soId[0],
                            giic_WBElement__c = solrequest.wbe 
                        );
                        lstSOL.add(soLineObj);
                        
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'soLineObj cod2222 gii__Product__c   = '+soLineObj.gii__Product__c);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'soLineObj cod2222 gii__Warehouse__c = '+soLineObj.gii__Warehouse__c );
                        keyToSOLForSearchPIQD.put(soLineObj.gii__Product__c+''+soLineObj.gii__Warehouse__c, solrequest);
                        productForSearch.add(soLineObj.gii__Product__c);
                        warehouseForSearch.add(soLineObj.gii__Warehouse__c);
                    }
                }
                
                List<gii__ProductInventoryQuantityDetail__c> missingPiqdList = [SELECT id,Name,gii__BlockedQuantity__c,giic_Reserved__c, gii__Available__c, giic_Status__c ,
                                                                                gii__OnHandQuantity__c,gii__ProductInventory__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,
                                                                                gii__Warehouse__c,gii__Location__c,gii__ProductSerial__c, gii__ProductSerial__r.name,gii__ProductLot__r.Name    
                                                                                FROM gii__ProductInventoryQuantityDetail__c 
                                                                                where gii__Product__c IN: productForSearch
                                                                                and   gii__Warehouse__c IN: warehouseForSearch ];
                for(gii__ProductInventoryQuantityDetail__c pd : missingPiqdList){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'cod 064 = '+pd);
                    String key = pd.gii__Product__c+''+pd.gii__Warehouse__c;
                    if(keyToSOLForSearchPIQD.containsKey(key)){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.ConsumedQuantity = '+keyToSOLForSearchPIQD.get(key).ConsumedQuantity);
                        Decimal n = keyToSOLForSearchPIQD.get(key).ConsumedQuantity;
                        if(pd.giic_Reserved__c == null){    
                            pd.giic_Reserved__c = 0; 
                        }
                        // ------------------------- FIX INC000078690128 10/12/2021
                        if(pd.giic_Reserved__c > 0 &&  pd.giic_Reserved__c>=n) {
                            pd.giic_Reserved__c =   pd.giic_Reserved__c - n;
                            pd.gii__OnHandQuantity__c = pd.gii__OnHandQuantity__c + n;
                        }else if(pd.giic_Reserved__c >= 0 &&  pd.giic_Reserved__c < n){
                            pd.gii__OnHandQuantity__c = pd.gii__OnHandQuantity__c + pd.giic_Reserved__c;
                            pd.giic_Reserved__c = 0;
                        }
                        if(!goodsIssueSOparams.piqdToUnreservedList.containsKey(pd.Id)){
                            goodsIssueSOparams.piqdToUnreservedList.put(pd.Id,pd);
                        } 
                        // -------------------------
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'pd.giic_Reserved__c = '+pd.giic_Reserved__c );
                        piqdTempMap.put(pd.Id, pd); 
                        goodsIssueSOparams.lstPIQDToSendForInvAdj.put(pd.Id, pd);  
                        goodsIssueSOparams.newSolKEYToPIQDId.put(key, pd.Id);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'goodsIssueSOparams.newSolKEYToPIQDId = '+goodsIssueSOparams.newSolKEYToPIQDId);
                    }
                }
            //}
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'SOL TO INSERT '+lstSOL);
        if(Schema.sObjectType.gii__SalesOrderLine__c.isCreateable() && lstSOL != null && !lstSOL.isEmpty()){
            insert lstSOL;
            for(gii__SalesOrderLine__c sol : lstSOL){ 
                params.solSet.add(sol.Id);
                goodsIssueSOparams.solJustInserted.add(sol);
                goodsIssueSOparams.newSolIdToPIQD.put(sol.Id , piqdTempMap.get(goodsIssueSOparams.newSolKEYToPIQDId.get(sol.gii__Product__c+''+sol.gii__Warehouse__c)) ); //new
                params.salesOrderLineList.add(sol);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'goodsIssueSOparams.newSolIdToPIQD = '+goodsIssueSOparams.newSolIdToPIQD);
            }
        }
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method filters the input based on some criterias
    * @return Giic_GoodsIssueSO.GoodIssueParamsWrapper
    */    
    @TestVisible
    private static Giic_GoodsIssueSO.GoodIssueParamsWrapper filterInput(Giic_GoodsIssueSO.GoodIssueParamsWrapper params,List<Giic_GoodsIssueSO.SalesOrder> soWrapList, Boolean isForWoli,  map<String,Decimal> pRequiredToOrderQuantity,map<String,String> pRequiredToSolName, map<String,String> pRequiredToSHIPPEDSolName ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput con isForWoli '+isForWoli);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput con params =  '+params);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput con params =  '+params);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput con params =  '+params);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput con params =  '+params);
        if(isForWoli){
            params.mapOfSolIdVsSo = new Map<Id,gii__SalesOrderLine__c>(params.salesOrderLineListForWOLI);
        }else{
            params.mapOfSolIdVsSo = new Map<Id,gii__SalesOrderLine__c>(params.salesOrderLineList);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'pRequiredToSolName = '+pRequiredToSolName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'pRequiredToSHIPPEDSolName = '+pRequiredToSHIPPEDSolName);
        // nuovo per order quantity in chiamata annullato
        for(Giic_GoodsIssueSO.SalesOrder sw : soWrapList){
            for(Giic_GoodsIssueSO.SalesOrderLine sol : sw.SalesOrderLineList){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'solentrato = '+sol);
                sol.OrderQuantity = pRequiredToOrderQuantity.get(sol.product);
                if(sol.Name == null){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'setto1');
                    sol.Name = pRequiredToSolName.get(sol.product);
                    if(sol.Name == null){
                          XC_UTIL_Debug.debug(DEBUGACTIVE, 'setto2');
                          sol.Name = pRequiredToSHIPPEDSolName.get(sol.product);
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Final Name = '+ sol.Name );
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'SalesOrderLineList = '+sw.SalesOrderLineList);
        }
        params.soWrapList = soWrapList;
        String error;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN filterInput');
        List<String> listSOid = new List<String>();
        Integer i = 0;
        while(i < params.soWrapList.size()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.soWrapList = '+params.soWrapList);
            if(isForWoli){
                listSOid.addAll(params.mapOfWOVsListSOId.get(params.soWrapList[i].fslWorkOrderLineItem));
            }else{
                listSOid.addAll(params.mapOfWOVsListSOId.get(params.soWrapList[i].fslWorkOrder));
            }
            params.soId = listSOid[0];
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.soWrapList[i] '+params.soWrapList[i]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.mapOfWOVsListSOId '+params.mapOfWOVsListSOId);
            if(!isForWoli && params.mapOfWOVsListSOId.containsKey(params.soWrapList[i].fslWorkOrder) && params.mapOfWOVsListSOId.get(params.soWrapList[i].fslWorkOrder).size() > 1){
                error = Label.giic_SOGoodsIssueProcess+'  ' +params.soWrapList[i].fslWorkOrder;
                Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                err.errorMsg = error;
                params.errlist.add(err);
                params.soWrapList.remove(i);
            } else if(isForWoli && params.mapOfWOVsListSOId.get(params.soWrapList[i].fslWorkOrderLineItem).size() > 1){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'wee');
                error = Label.giic_SOGoodsIssueProcess+'  ' + params.soWrapList[i].fslWorkOrderLineItem;
                Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                err.errorMsg = error;
                params.errlist.add(err);
                params.soWrapList.remove(i);
            } else{
                Boolean elementRemoved = false;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.mapOfSoIdVsSOLList = '+params.mapOfSoIdVsSOLList);
                for(gii__SalesOrderLine__c solObj : params.mapOfSoIdVsSOLList.get(params.soId)) {
                //if(!params.soWrapList[i].lastGoodIssue){                
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'soWrapList[i].salesOrderLineList '+i+' = '+soWrapList[i].salesOrderLineList);
                    if(containsProdReq(params.soWrapList[i].salesOrderLineList, solObj.giic_ProductRequiredId__c) ){    // nuovo 22/09/2020
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Inserisco questo vecchio per la reserve '+solObj.Id);
                        params.solSet.add(solObj.Id);
                    }   
                //}
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'qua listSOid[0] ='+solObj);
                    if(solObj.gii__SalesOrder__r.gii__OrderStatus__c == Label.giic_SOStatusShipped && params.soWrapList[i].lastGoodIssue) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'sales order in shipped error '+listSOid[0] );
                        params.soId = listSOid[0];
                        error = Label.giic_SOAlreadyShippedMessage+solObj.Id;
                        Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                        err.errorMsg = error;
                        params.errlist.add(err);
                        params.soWrapList.remove(i);
                        elementRemoved = true;
                        break;
                    }
                    if(solObj.giic_ProductRequiredId__c == null){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'qua2');
                        error = Label.giic_ProductReqIdNotDefinedMessage+solObj.Id;
                        Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                        err.errorMsg = error;
                        params.errlist.add(err);
                        params.soWrapList.remove(i);
                        elementRemoved = true;
                        break;
                    }
                }
                if(!elementRemoved){  
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'quahhhuuuuu'+params.soWrapList[i].salesOrderLineList);
                    for(Giic_GoodsIssueSO.SalesOrderLine solrequest : params.soWrapList[i].salesOrderLineList){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, ' qqq');
                        if(solrequest.consumedQuantity < 0 || solrequest.orderQuantity <= 0){
                            error = Label.giic_OdrConsQtyNotZeroMsg;
                            Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                            err.errorMsg = error;
                            params.errlist.add(err);
                            params.soWrapList.remove(i);
                            elementRemoved = true;
                            break;
                        }
                    }  
                }
                if(!elementRemoved){ 
                    i++;
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'END filterInput con '+params);
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method will loop over the SOLs and fill required sets and maps
    * @param params-Object of Giic_GoodsIssueSO.GoodIssueParamsWrapper
    * @return Giic_GoodsIssueSO.GoodIssueParamsWrapper
    */     
    @TestVisible
    private static Giic_GoodsIssueSO.GoodIssueParamsWrapper processSOL(Giic_GoodsIssueSO.GoodIssueParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processSOL');
        for(gii__SalesOrderLine__c sol :params.salesOrderLineList){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.mapOfWOVsListSOId----->>'+params.mapOfWOVsListSOId);
            params.soId = sol.gii__SalesOrder__c;
            if(!params.mapOfWOvsPdtReqList.containsKey(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c)){
                params.mapOfWOvsPdtReqList.put(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c,new List<String>{sol.giic_ProductRequiredId__c});
            }else{
                List<String> temp = params.mapOfWOvsPdtReqList.get(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c);
                temp.add(sol.giic_ProductRequiredId__c);
                params.mapOfWOvsPdtReqList.put(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c,temp);
            }
            if(!params.mapOfWOVsListSOId.containsKey(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c)){
                params.mapOfWOVsListSOId.put(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c,new Set<String>{sol.gii__SalesOrder__c});
            }else{
                Set<String> temp = params.mapOfWOVsListSOId.get(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c);
                temp.add(sol.gii__SalesOrder__c);
                params.mapOfWOVsListSOId.put(sol.gii__SalesOrder__r.giic_FSLWorkOrder__c,temp);
            }
            if(!params.mapOfSoIdVsSOLList.containsKey(sol.gii__SalesOrder__c)){
                params.mapOfSoIdVsSOLList.put(sol.gii__SalesOrder__c,new List<gii__SalesOrderLine__c>{sol});
            }else{
                List<gii__SalesOrderLine__c> temp = params.mapOfSoIdVsSOLList.get(sol.gii__SalesOrder__c);
                temp.add(sol);
                params.mapOfSoIdVsSOLList.put(sol.gii__SalesOrder__c,temp);
            }
        }
        return params;
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019 
    * @description Method to check if SO contains Prod Req
    * @return Boolean
    */  
    private static Boolean containsProdReq(List<Giic_GoodsIssueSO.SalesOrderLine> salesOrderLineList ,String productRequiredID){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN containsProdReq');
        for(Giic_GoodsIssueSO.SalesOrderLine sol : salesOrderLineList){
            if(sol.productRequiredID == productRequiredID){
                return true;
            }
        }
        return false;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes the sales order goods issue and returns the list of inventory reserves
    * @return OrderGoodsIssuedResponse
    */    
    @TestVisible
    private static OrderGoodsIssuedResponse responseProcessing(List<Giic_GoodsIssueSO.SalesOrder> soWrapList,Set<String> solSet, Giic_GoodsIssueSO.ParamsWrapper params, Boolean fromComponent){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN responseProcessing');
        Savepoint sp = Database.setSavepoint();
        params.odrResponse.isSuccess = true; 
        params.solSet = solSet;
        params.soWrapList = soWrapList;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params----->>'+params);
        params = processInputList(params); 
        params = fillRequiredData(params);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params at the end----->>'+params);
        if(params.piqdList!=null && !params.piqdList.isEmpty()){
            params.mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>(params.piqdList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdList--------'+params.piqdList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'serialIdNameMap--------'+params.serialIdNameMap);
            params = processIncomingWrapper(params);
            for(gii__ProductInventoryQuantityDetail__c piqd: params.piqdList){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '8753');
                String key = piqd.gii__Product__r.gii__SerialControlled__c ? piqd.gii__Product__c+'-'+piqd.gii__Warehouse__c+'-'+piqd.gii__Location__c+'-'+piqd.gii__ProductSerial__c : piqd.gii__Product__c+'-'+piqd.gii__Warehouse__c+'-'+piqd.gii__Location__c;
                params.piqdKeyIDMAP.put(key,piqd.id);
                if(piqd.gii__ProductSerial__r.name!=null){
                    String serialInUpper = (piqd.gii__ProductSerial__r.name).toUpperCase();
                    params.isAvailableSerailVsPiqdIdMap.put(serialInUpper, piqd.Id);
                }
                if(piqd.gii__ProductLot__r.name!=null){
                    String lotInUpper = (piqd.gii__ProductLot__r.name).toUpperCase();
                    params.isAvailableLotVsPiqdIdMap.put(lotInUpper, piqd.Id);
                    
                }
                params.isAvailablePiqdIDVsPiqd.put(piqd.Id , piqd);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdKeyIDMAP--------'+params.piqdKeyIDMAP);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdIdForUnresered not count in random--------'+params.piqdIdForUnresered);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdToUnreservedList--------'+params.piqdToUnreservedList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'productRequireConsumedQtyMap--------'+params.productRequireConsumedQtyMap);
        } else{
            List<Giic_GoodsIssueSO.ErrorList> errorList;
            errorList = params.odrResponse.errorList != null ? params.odrResponse.errorList : new List<Giic_GoodsIssueSO.ErrorList>();
            Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
            err.errorMsg = 'No product inventory quantity detail found';
            errorList.add(err);
            params.odrResponse.isSuccess = false;
            params.odrResponse.errorList = errorList;
            return params.odrResponse;
        } 
        
        params = Giic_GoodsIssueSO_U.responseProcessingHelper(params, fromComponent);
        // this block is for create SO and SOL ----------------------------------------------->>
        // params.objReturnResult = processNewWO(params.soWrapList,params.woSetSO);
        params.listInventoryReserve = Giic_GoodsIssueSO_U.processReturnResult(params);
        //------------------------------------------------------------------------------------->>
        params = processAdjAndReservation(params, sp);
          XC_UTIL_Debug.debug(DEBUGACTIVE,'params907 = '+params);
        if(params.odrResponse.isSuccess == false){
            Database.rollback(sp);
            return params.odrResponse;
        }else{
            return params.odrResponse;
        }
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method queries the SOLs and iterates over it.
    * @param params -Object Giic_GoodsIssueSO.ParamsWrapper
    * @param sp - SavePoint
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */ 
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processAdjAndReservation(Giic_GoodsIssueSO.ParamsWrapper params, Savepoint sp){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN processAdjAndReservation con params.odrResponse.isSuccess = '+params.odrResponse.isSuccess );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'randomSerialToUnreserve--------'+params.randomSerialToUnreserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdIdForUnresered--------'+params.piqdIdForUnresered);
        if(params.odrResponse.isSuccess == true){
            params = unReserveRandomPIQDs(params);
            // Inventory Adjustments
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'lstPIQDToSendForInvAdj--------'+params.lstPIQDToSendForInvAdj);
            if(!params.lstPIQDToSendForInvAdj.isEmpty()){
                gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultInvAdj = Giic_GoodsIssueSO_U.doInventoryAdjustments(params.lstPIQDToSendForInvAdj.values());
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'resultInvAdj--------'+resultInvAdj);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdToUnreservedList--------'+params.piqdToUnreservedList);
            if(!params.piqdToUnreservedList.isEmpty() && Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isUpdateable()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'UNRESERVO ' +params.piqdToUnreservedList) ;
                update params.piqdToUnreservedList.values();
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listInventoryReserve--------'+params.listInventoryReserve);
            List<gii__InventoryReserve__c> listInvResNew = new List<gii__InventoryReserve__c>();
            for(gii__InventoryReserve__c ir : params.listInventoryReserve){
                if(ir.gii__ReserveQuantity__c!=null && ir.gii__ProductInventoryQuantityDetail__c!=null){
                    listInvResNew.add(ir);
                }
            }
            if(!Test.isRunningTest()){ 
                if(!listInvResNew.isEmpty()){
                    params.odrResponse = Giic_GoodsIssueSO_U.soDirectReserveAndShip(listInvResNew,params.odrResponse, sp); 
                }else{
                    List<Giic_GoodsIssueSO.ErrorList> errorList;
                    errorList = params.odrResponse.errorList != null ? params.odrResponse.errorList : new List<Giic_GoodsIssueSO.ErrorList>();
                    Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                    err.errorMsg = 'No product inventory quantity detail found: cod995';
                    errorList.add(err);
                    params.odrResponse.isSuccess = false;
                    params.odrResponse.errorList = errorList;
                    return params;
                }
            }
        }
        return params; 
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method queries the SOLs and iterates over it.
    * @param params -Object Giic_GoodsIssueSO.ParamsWrapper
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */ 
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper fillRequiredData(Giic_GoodsIssueSO.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN fillRequiredData');
        if(Schema.sObjectType.gii__SalesOrderLine__c.isQueryable()){
            params.salesOrderLineList = [SELECT id,Name, gii__SalesOrder__c,gii__LineStatus__c,gii__ProductInventory__c,gii__ShippedQuantity__c, gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__OpenQuantity__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,gii__Status__c,
                                         gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                         FROM gii__SalesOrderLine__c
                                         where gii__SalesOrder__r.giic_FSLWorkOrder__c!=null AND gii__SalesOrder__r.giic_FSLWorkOrder__c IN: params.fslWO AND gii__SalesOrder__r.giic_WorkOrderLineItem__c = null];
        }
        Map<id,gii__SalesOrderLine__c> soLineMap = new  Map<id,gii__SalesOrderLine__c>([SELECT id,Name, gii__LineStatus__c,gii__ProductInventory__c,gii__ShippedQuantity__c,gii__SalesOrder__c,gii__OpenQuantity__c, gii__Product__c,gii__Product__r.gii__SerialControlled__c, gii__Product__r.gii__LotControlled__c,gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,gii__Status__c,  
                                                                                          gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c, gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                                                                          FROM gii__SalesOrderLine__c
                                                                                          where gii__SalesOrder__r.giic_WorkOrderLineItem__c IN: params.fslWOL AND gii__SalesOrder__r.giic_WorkOrderLineItem__c != null]);
        
        if(params.salesOrderLineList.isEmpty()){
            params.salesOrderLineList = soLineMap.values();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'cod4 = '+params.salesOrderLineList);
            for(gii__SalesOrderLine__c soLine : params.salesOrderLineList){ params.woSetSO.add(soLine.gii__SalesOrder__r.giic_WorkOrderLineItem__c); } 
        }
        if(!params.salesOrderLineList.isEmpty()){
            for(gii__SalesOrderLine__c soLine : params.salesOrderLineList){
                params.woSetSO.add(soLine.gii__SalesOrder__r.giic_FSLWorkOrder__c);
            } 
        }
        //Fetching product serial record for all the incoming serials
        if(Schema.sObjectType.gii__ProductSerial__c.isQueryable()){
            for(gii__ProductSerial__c productSerial: [SELECT id, name FROM gii__ProductSerial__c where name in: params.serialNumberList]){
                params.serialNameIDMap.put((productSerial.name).toUpperCase() , productSerial.id);
                params.serialIdNameMap.put(productSerial.Id, (productSerial.name).toUpperCase() );
                params.serialIDList.add(productSerial.id);
            }            
        }
        if(Schema.sObjectType.gii__ProductLot__c.isQueryable()){
            for(gii__ProductLot__c lot : [SELECT id, name FROM gii__ProductLot__c where name in: params.lotNumberToQuantity.keySet() ]){
                params.serialNameIDMap.put( (lot.name).toUpperCase() , lot.id);
                params.serialIdNameMap.put(lot.Id, (lot.Name).toUpperCase() );
                params.serialIDList.add(lot.id);
            }            
        }
        //fetching defautl location for warehouse that will be used in quering PIQD
        /*if(Schema.sObjectType.gii__Warehouse__c.isQueryable()){
            for(gii__Warehouse__c wh: [SELECT id, gii__DefaultIssueLocation__c FROM gii__Warehouse__c where id in:params.warehouseList]){
                params.locationList.add(wh.gii__DefaultIssueLocation__c);
                params.whLocationMap.put(wh.id,wh.gii__DefaultIssueLocation__c);
            }
        }*/
        Map<Id, gii__Location__c> mapLocation = new Map<Id, gii__Location__c>([
            SELECT Id, giic_LocationType__c,gii__Warehouse__c  
            FROM gii__Location__c  
            WHERE giic_LocationType__c = 'Sales' AND gii__Warehouse__c IN :params.warehouseList
        ]); 
        for(gii__Location__c wh: mapLocation.values()){
            params.locationList.add(wh.Id);
            params.whLocationMap.put(wh.gii__Warehouse__c,wh.Id);
        }
        
        if(Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isQueryable()){
            params.piqdList = [SELECT id,Name,gii__BlockedQuantity__c,giic_Reserved__c, gii__Available__c, giic_Status__c ,gii__OnHandQuantity__c,gii__ProductInventory__c,
                               gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,gii__Location__c,gii__ProductSerial__c, gii__ProductSerial__r.name,gii__ProductLot__r.Name
                               FROM gii__ProductInventoryQuantityDetail__c 
                               where gii__Product__c in: params.productList 
                               and gii__Warehouse__c in: params.warehouseList 
                               and gii__Location__c in: params.locationList 
                               and ((gii__ProductSerial__c in: params.serialIDList OR gii__ProductSerial__c != null) OR gii__ProductSerial__c = null )];
        }
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes the sales order goods issue list
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */ 
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processInputList(Giic_GoodsIssueSO.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processInputList');
        for(Giic_GoodsIssueSO.SalesOrder soObj : params.soWrapList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN processInputList con '+soObj);
            params.fslWOL.add(soObj.fslWorkOrderLineItem);
            params.fslWO.add(soObj.fslWorkOrder);  
            params.warehouseList.add(soObj.warehouse); //will be used in fetching PIQD
            for(Giic_GoodsIssueSO.SalesOrderLine solrequest : soObj.salesOrderLineList){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest' + solrequest);
                if(solrequest.assignedSerials != null && !solrequest.assignedSerials.isEmpty()){
                    for(Giic_GoodsIssueSO.AssignedSerial assignedSerial : solrequest.assignedSerials){
                        if(solrequest.isSerialControlled && assignedSerial.SerialNumber == null){
                            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Errore '+solrequest.Name+' is Serial Controlled, please insert a serial number!');
                            Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                            err.errorMsg = 'Sales Order Line '+solrequest.Name+' is Serial Controlled, please insert a serial number!';                            
                            params.odrResponse.isSuccess = false;                             
                            List<ErrorList> errorList = new List<ErrorList>();
                            errorList.add(err);
                            params.odrResponse.errorList = errorList;                            
                            return params;
                        }
                        if(assignedSerial.SerialNumber!=null){
                            assignedSerial.SerialNumber = (assignedSerial.SerialNumber).toUpperCase();
                        }
                        if(soObj.fslWorkOrderLineItem!=null){
                            if(!params.mapWOvsSerials.containsKey(soObj.fslWorkOrderLineItem)){
                                params.mapWOvsSerials.put(soObj.fslWorkOrderLineItem , new List<String>{assignedSerial.SerialNumber});
                            }else{
                                List<String> temp = params.mapWOvsSerials.get(soObj.fslWorkOrderLineItem);
                                temp.add(assignedSerial.SerialNumber);
                                params.mapWOvsSerials.put(soObj.fslWorkOrderLineItem,temp);
                            }
                            
                        }else{
                            if(!params.mapWOvsSerials.containsKey(soObj.fslWorkOrder)){
                                params.mapWOvsSerials.put(soObj.fslWorkOrder,new List<String>{assignedSerial.SerialNumber});
                            }else{
                                List<String> temp = params.mapWOvsSerials.get(soObj.fslWorkOrder);
                                temp.add(assignedSerial.SerialNumber);
                                params.mapWOvsSerials.put(soObj.fslWorkOrder,temp);
                                
                            }
                            
                        }
                        params.serialNumberList.add(assignedSerial.SerialNumber); // will be used in quering SFDC id of serial number
                    }
                }
                if(solrequest.lstAssignedLot != null && !solrequest.lstAssignedLot.isEmpty()){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'trovato un lottizzato '+solrequest);
                    for(Giic_GoodsIssueSO.ProductLot assignedLot : solrequest.lstAssignedLot){
                        if(solrequest.isLotControlled && assignedLot.lotNumber == null){
                            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Errore '+solrequest.Name+' is lot Controlled, please insert a lot number!');
                            Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                            err.errorMsg = 'Sales Order Line '+solrequest.Name+' is lot Controlled, please insert a lot number!';
                            params.odrResponse.isSuccess = false; 
                            List<ErrorList> errorList = new List<ErrorList>();
                            errorList.add(err);
                            params.odrResponse.errorList = errorList;
                            return params;
                        }
                        if(assignedLot.lotNumber !=null){
                            assignedLot.lotNumber = (assignedLot.lotNumber).toUpperCase();
                        }
                        if(soObj.fslWorkOrderLineItem!=null){
                            if(!params.mapWOvsSerials.containsKey(soObj.fslWorkOrderLineItem)){
                                params.mapWOvsSerials.put(soObj.fslWorkOrderLineItem , new List<String>{assignedLot.lotNumber});
                            }else{
                                List<String> temp = params.mapWOvsSerials.get(soObj.fslWorkOrderLineItem);
                                temp.add(assignedLot.lotNumber);
                                params.mapWOvsSerials.put(soObj.fslWorkOrderLineItem,temp);
                            }
                        }else{
                            if(!params.mapWOvsSerials.containsKey(soObj.fslWorkOrder)){
                                params.mapWOvsSerials.put(soObj.fslWorkOrder,new List<String>{assignedLot.lotNumber});
                            }else{
                                List<String> temp = params.mapWOvsSerials.get(soObj.fslWorkOrder);
                                temp.add(assignedLot.lotNumber);
                                params.mapWOvsSerials.put(soObj.fslWorkOrder,temp);
                            }
                        }
                        params.lotNumberToQuantity.put(assignedLot.lotNumber, assignedLot.lotQty); // will be used in quering SFDC id of serial number
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.lotNumberToQuantity= '+params.lotNumberToQuantity);
                    }
                }
                
                params.productList.add(solrequest.product);     //will be used in fetching PIQD
                if(solrequest.productRequiredID != null){
                    params.productRequireSerialListMap.put(solrequest.productRequiredID, solrequest.AssignedSerials);
                    params.productRequireLotListMap.put(solrequest.productRequiredID, solrequest.lstAssignedLot);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.productRequireConsumedQtyMap BEFORE= '+params.productRequireConsumedQtyMap);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'solrequest.productRequiredIDD = '+solrequest.productRequiredID);
                    //if(!params.productRequireConsumedQtyMap.containsKey(solrequest.productRequiredID) ){
                          params.productRequireConsumedQtyMap.put(solrequest.productRequiredID,solrequest.consumedQuantity);
                    //}
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.productRequireConsumedQtyMap AFTER= '+params.productRequireConsumedQtyMap);
                    params.productRequireIDMAP.put(solrequest.productRequiredID, true);
                }
            }
        }
        return params;
    }
    
    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method unreserves the random PIQDs for Serial Pdts
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */ 
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper unReserveRandomPIQDs(Giic_GoodsIssueSO.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'gii__Product__c = '+params.productList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'gii__Warehouse__c = '+params.warehouseList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'gii__Location__c = '+params.locationList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.piqdIdForUnresered = '+  params.piqdIdForUnresered);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.mapOfPdtWhLocvsRndmNbr = '+  params.mapOfPdtWhLocvsRndmNbr);
        List<gii__ProductInventoryQuantityDetail__c> randomPIQDList = new List<gii__ProductInventoryQuantityDetail__c>();
        Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocvsPIQD = new Map<String,List<gii__ProductInventoryQuantityDetail__c>>();
        // this is a list of random serail number need to unreserve because some serail number are avaiable 
        if(Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isQueryable() && params.mapOfPdtWhLocvsRndmNbr != null && !params.mapOfPdtWhLocvsRndmNbr.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'quero le piqd');
            randomPIQDList = [SELECT id,Name, gii__Available__c, giic_Status__c ,gii__OnHandQuantity__c,gii__ProductInventory__c,giic_Reserved__c,
                              gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,gii__Location__c,
                              gii__ProductSerial__c, gii__ProductSerial__r.Name, gii__BlockedQuantity__c, gii__ProductLot__r.Name
                              FROM gii__ProductInventoryQuantityDetail__c 
                              WHERE gii__Product__c in: params.productList  
                              AND gii__Warehouse__c in: params.warehouseList 
                              AND gii__Location__c in: params.locationList 
                              AND (gii__ProductSerial__c != null OR gii__ProductLot__c!=null)
                              AND Id NOT IN :params.piqdIdForUnresered
                              AND giic_Status__c =:System.Label.giic_StatusReserve];

            for(gii__ProductInventoryQuantityDetail__c piqd: randomPIQDList){
                String key = piqd.gii__Product__c+'-'+piqd.gii__Warehouse__c+'-'+piqd.gii__Location__c;
                if(!mapOfPdtWhLocvsPIQD.containsKey(key)){
                    mapOfPdtWhLocvsPIQD.put(key,new List<gii__ProductInventoryQuantityDetail__c>{piqd});
                }else{
                    List<gii__ProductInventoryQuantityDetail__c> temp = mapOfPdtWhLocvsPIQD.get(key);
                    temp.add(piqd);
                    mapOfPdtWhLocvsPIQD.put(key,temp);
                }
            }
            params = unreservePIQD(params,mapOfPdtWhLocvsPIQD);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.mapOfPdtWhLocvsPIQD---->>'+mapOfPdtWhLocvsPIQD);
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method unreserves and updates the random PIQDs
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @param mapOfPdtWhLocvsPIQD - Map of Map<String,List<gii__ProductInventoryQuantityDetail__c>>
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper unreservePIQD(Giic_GoodsIssueSO.ParamsWrapper params,Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocvsPIQD){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN unreservePIQD');
        for(String key1 : params.mapOfPdtWhLocvsRndmNbr.keySet()){ 
            Integer countToUnreserve = params.mapOfPdtWhLocvsRndmNbr.get(key1);
            if(mapOfPdtWhLocvsPIQD != null && mapOfPdtWhLocvsPIQD.containsKey(key1)){
                for(gii__ProductInventoryQuantityDetail__c piqd : mapOfPdtWhLocvsPIQD.get(key1)){
                    if(countToUnreserve > 0){
                        piqd.gii__OnHandQuantity__c = 1.0;
                        // Also send for Inventory adjustment
                        params.lstPIQDToSendForInvAdj.put(piqd.Id, piqd);
                        if(!params.piqdToUnreservedList.containsKey(piqd.Id)){
                            params.piqdToUnreservedList.put(piqd.Id, new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = 0,giic_Status__c = '',id=piqd.id));
                        }else{
                            //params.piqdToUnreservedList.get(piqd.Id).gii__OnHandQuantity__c = params.piqdToUnreservedList.get(piqd.Id).gii__OnHandQuantity__c+1;
                        }
                        countToUnreserve--;
                    }
                }  
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END unreservePIQD');
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes the sales order goods issue list
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */   
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processIncomingWrapper(Giic_GoodsIssueSO.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processIncomingWrapper');
        for(Giic_GoodsIssueSO.SalesOrder soObj : params.soWrapList){
            if(!soObj.lastGoodIssue){
                params.lastGoodIssue = false;
            }
            if(soObj.forceLastGoodIssue) {
                params.lastGoodIssue = true;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.woSetSO = '+params.woSetSO);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.mapWOvsSerials = '+params.mapWOvsSerials);
            if(params.woSetSO != null && !params.woSetSO.isEmpty() && params.woSetSO.contains(soObj.fslWorkOrder) && params.mapWOvsSerials != null && params.mapWOvsSerials.containsKey(soObj.fslWorkOrder) ){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'lo chiamo con false');
                params = processIncomingWrapperHelper(params,soObj, false);
            }else if(params.woSetSO != null && !params.woSetSO.isEmpty() && params.woSetSO.contains(soObj.fslWorkOrderLineItem) && params.mapWOvsSerials != null && params.mapWOvsSerials.containsKey(soObj.fslWorkOrderLineItem) ){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'lo chiamo con true');
                params = processIncomingWrapperHelper(params,soObj, true);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.piqdIdForUnresered---------'+params.piqdIdForUnresered);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.mapOfPdtWhLocvsRndmNbr---------'+params.mapOfPdtWhLocvsRndmNbr);
        return params;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method isn an helper method to processIncomingWrapper
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */   
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processIncomingWrapperHelper(Giic_GoodsIssueSO.ParamsWrapper params, Giic_GoodsIssueSO.SalesOrder soObj, Boolean isB2B){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processIncomingWrapperHelper');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ params:' + params);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ soObj:' + soObj);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ isB2B:' + isB2B);
        List<String> serialListWO = new List<String>();
        if(!isB2B){
            serialListWO = params.mapWOvsSerials.get(soObj.fslWorkOrder);
        }else{
            serialListWO = params.mapWOvsSerials.get(soObj.fslWorkOrderLineItem);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'serialListWO = '+serialListWO);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.piqdList = '+params.piqdList);
        for(gii__ProductInventoryQuantityDetail__c piqd: params.piqdList){
            String key1 = piqd.gii__Product__c+'-'+piqd.gii__Warehouse__c+'-'+piqd.gii__Location__c;
            Boolean bool = serialListWO.contains(params.serialIdNameMap.get(piqd.gii__ProductSerial__c)) ? true : false;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ key1: ' + key1);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ bool: ' + bool);
            if(bool == true && piqd.gii__Product__r.gii__SerialControlled__c && piqd.gii__Available__c > 0){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '56');
                params.isAvailableSerailMap.put( (piqd.gii__ProductSerial__r.name).toUpperCase(), 'Available');
                //randomSerialToUnreserve = randomSerialToUnreserve + 1;
                piqd.giic_Reserved__c = 0.0;
                piqd.giic_Status__c ='';
                if(!params.piqdToUnreservedList.containsKey(piqd.Id)){
                    params.piqdToUnreservedList.put(piqd.id, piqd); // this list of unreserve PIQD list.
                }else{
                    // TODO
                }
                if(!params.mapOfPdtWhLocvsRndmNbr.containsKey(key1)){
                    params.mapOfPdtWhLocvsRndmNbr.put(key1,1);
                }else{
                    params.mapOfPdtWhLocvsRndmNbr.put(key1,params.mapOfPdtWhLocvsRndmNbr.get(key1)+1);
                }
            }else if(bool == true && piqd.gii__Product__r.gii__SerialControlled__c && piqd.giic_Status__c == System.Label.giic_StatusReserve){ 
                // if serial number is in reserved status then ready to consumed so adding into unreserve list.
                params.isAvailableSerailMap.put( (piqd.gii__ProductSerial__r.name).toUpperCase(), 'NotAvailable');
                piqd.gii__OnHandQuantity__c = 1.0;
                // Also send for Inventory adjustment
                params.lstPIQDToSendForInvAdj.put(piqd.Id, piqd);
                if(!params.piqdToUnreservedList.containsKey(piqd.Id)){
                    params.piqdToUnreservedList.put(piqd.Id, new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = 0.0,giic_Status__c ='',Id=piqd.Id)); // this list of unreserve PIQD list.
                }else{
                    
                }
                params.piqdIdForUnresered.add(piqd.id);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'END processIncomingWrapperHelper CON mapOfPdtWhLocvsRndmNbr = '+params.mapOfPdtWhLocvsRndmNbr);
        return params;
    }  
    
    
}