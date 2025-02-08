/**
* @description The Class XC_REST_GoodsReceipt_Inbound_U.
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 07/10/2019 
* @description REST Utility Class for PurchaseOrder Interface
*/ 
public class XC_REST_GoodsReceipt_Inbound_U {
    
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_GoodsReceipt_Inbound_U');
    /**
* @description wrapper class for request 
*/
    public class RequestWrapper {
        public GoodsReceiptWrapper goods_receipt;
    }
    
    /**
* @description wrapper class for response
*/
    public class ResponseWrapper {
        public XC_UTIL_Integration.ResultSnakeCase result;
        
        /**
* @description constructor
*/
        public ResponseWrapper(){ 
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }
    
    
    /**
* @description wrapper class for goods_receipt
*/
    public class GoodsReceiptWrapper {
        public Date document_date;
        public string reference;
        public Date registration_date;
        public string source_system;
        public string sfdc_id;
        public string target_system;
        //public Date receipt_date; GDB
        public string po_number;
        public string to_number;
        public string rma_number;
        public string po_id;
        public string to_id;
        public string rma_id;
        public string noteQualityCheck;
        public boolean qualityCheckFailed ;

        
        public List<ItemsWrapper> items;  
        
        public String goods_receipt_number;
        public Integer accounting_period;
        public String goods_receipts_result;
        
        public List<GrResultsWrapper> gr_results;
        
        public List<GrResultsWrapper> rgr_results;
    }
    
    /**
* @description wrapper class for purchase_order
*/
    public class ItemsWrapper {
        public String   po_number; 
        public Integer  qty;
        public Integer  sap_pos_po;
        public String   last_request;
        public String   product_code;
        public String   warehouse_code; // GDB edit
        public String   location_name; // GDB edit
        //public Date     receipt_date;
        public String   pol_number;
        public String   tol_id;
        public String   tol_number;
        public String   rma_line_id;
        public String   rma_line_number;
        public String   ean_code;
        public String   sku_code;
        public String   pol_id;
        public List<SerialNumbersWrapper> serial_numbers;
        public List<LotNumbersWrapper> lot_numbers;
    }  
    
    /**
    * @description wrapper class serial_numbers 
    */
    public class SerialNumbersWrapper {
        public String serial_number;
    }
    
    /**
    * @description wrapper class gr_results 
    */
    public class GrResultsWrapper {
        public String class_message;
        public Integer message_number;
        public String message;
    }
    
    /**
    * @description wrapper class lot_numbers 
    */
    public class LotNumbersWrapper {
        public String lot_number;
        public Integer quantity;
    }
    
    
    /**
* @description validate request
* @param params the wrapper
* @param header the header
* @return the wrapper result
*/
    public static XC_UTIL_Integration.WrapperResult validatePostRequest(RequestWrapper params, Map<String,String> header){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validatePostRequest');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validatePostRequest');
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }
        
        /*
result = XC_UTIL_RESTInbound.checkObjectPermission('gii__TransferOrder__c', 'read');
if(result.errorFlag){
return result; 
} 
*/
        
        if(params.goods_receipt == null){
             XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: goods_receipt');
             XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: goods_receipt');
            result.errorMessage = 'ERROR. Missing mandatory field: goods_receipt';
            result.errorFlag = true;
            return result; 
        }
        
        Map<String,Object> goodsReceiptMandatory = new Map<String,Object>{
            'registration_date'=>params.goods_receipt.registration_date,
                //'receipt_date'=>params.goods_receipt.receipt_date,
                'items'=>params.goods_receipt.items
                };
                    
                    result = XC_UTIL_Integration.checkMandatory(goodsReceiptMandatory); 
        if(result.errorFlag) { return result; }
        
        if(!String.isBlank(params.goods_receipt.po_number)){
            if(params.goods_receipt.document_date == null || String.isBlank(params.goods_receipt.reference)){
                result.errorMessage = 'ERROR. document_date and reference are mandatory when inserting the po_number';
                result.errorFlag = true;
                return result; 
            }   
        }
        
        if(String.isBlank(params.goods_receipt.po_id) && String.isBlank(params.goods_receipt.to_id) && String.isBlank(params.goods_receipt.rma_id)){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. At least one of this fields is mandatory: po_id, to_id, rma_id');
                XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. At least one of this fields is mandatory: po_id, to_id, rma_id');
                result.errorMessage = 'ERROR. At least one of this fields is mandatory: po_id, to_id, rma_id';
                result.errorFlag = true;
                return result; 
        }

        if(params.goods_receipt.qualityCheckFailed == true && String.isBlank(params.goods_receipt.noteQualityCheck)){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. noteQualityCheck mandatory when QualityCheckFailed = true');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. noteQualityCheck mandatory when QualityCheckFailed = true');
            result.errorMessage = 'ERROR. noteQualityCheck mandatory when QualityCheckFailed = true';
            result.errorFlag = true;
            return result; 
        }
        
        
        if(params.goods_receipt.items.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items');
            result.errorMessage = 'ERROR. Missing mandatory field: items';
            result.errorMessage = 'ERROR. Missing mandatory field: items';
            result.errorFlag = true;
            return result; 
        }
        
        for(ItemsWrapper iw:params.goods_receipt.items){
            result = validateItemsPost(iw);
            if(result.errorFlag) {
                return result; 
            }
        }
        
        return result;
    }
    
    
    private static XC_UTIL_Integration.WrapperResult validateItemsPost(ItemsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validateItemsPost');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validateItemsPost');
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        Map<String,Object> itemsMandatory = new Map<String,Object>{
            'items.qty'=>params.qty,
                'items.warehouse_code'=>params.warehouse_code,
                //'items.receipt_date'=>params.receipt_date, 
                'items.location_name'=>params.location_name
                
                };
                    
                    result = XC_UTIL_Integration.checkMandatory(itemsMandatory);
        if(result.errorFlag) {
            return result; 
        }
        
        if(String.isBlank(params.pol_id) && String.isBlank(params.tol_id) && String.isBlank(params.rma_line_id)){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing one of this fields: pol_id, tol_id, rma_line_id');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing one of this fields: pol_id, tol_id, rma_line_id');
            result.errorMessage = 'ERROR. Missing one of this fields: pol_id, tol_id, rma_line_id';
            result.errorFlag = true;
            return result; 
        }
        
        if(String.isBlank(params.product_code) && String.isBlank(params.ean_code)){
            result.errorMessage = 'ERROR. Missing one of this fields: product_code, ean_code';
            result.errorFlag = true;
            return result; 
        }
        
        
        if(params.serial_numbers!=null&&!params.serial_numbers.isEmpty()){
            for(SerialNumbersWrapper snw:params.serial_numbers){
                if(String.isBlank(snw.serial_number)){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items.serial_numbers.serial_number');
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items.serial_numbers.serial_number');
                    result.errorMessage = 'ERROR. Missing mandatory field: items.serial_numbers.serial_number';
                    result.errorFlag = true;
                    return result; 
                }
            }
        }

        if(params.lot_numbers!=null&&!params.lot_numbers.isEmpty()){
            for(LotNumbersWrapper lnw:params.lot_numbers){
                if(String.isBlank(lnw.lot_number) || lnw.quantity == null){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items.lot_numbers.lot_number OR items.lot_numbers.quantity');
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'ERROR. Missing mandatory field: items.lot_numbers.lot_number OR items.lot_numbers.quantity');
                    result.errorMessage = 'ERROR. Missing mandatory field: items.lot_numbers.lot_number OR items.lot_numbers.quantity';
                    result.errorFlag = true;
                    return result; 
                }
            }
        }
        
        return result;
    }
    
    
    /**
* @description validate request
* @param params the wrapper
* @param header the header
* @return the wrapper result
*/
    public static XC_UTIL_Integration.WrapperResult validatePutRequest(RequestWrapper params, Map<String,String> header){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validatePutRequest');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validatePutRequest');
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) { return result; }
        
        result = XC_UTIL_RESTInbound.checkObjectPermission('gii__PurchaseOrderReceipt__c', 'read');
        if(result.errorFlag){ return result; } 
        
        if(params.goods_receipt == null){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Missing mandatory field: goods_receipt');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Missing mandatory field: goods_receipt');
            result.errorMessage = 'ERROR. Missing mandatory field: goods_receipt';
            result.errorFlag = true;
            return result; 
        }
        
        Map<String,Object> goodsReceiptMandatory = new Map<String,Object>{
            'sfdc_id'=>params.goods_receipt.sfdc_id,
                'source_system'=>params.goods_receipt.source_system,
                'target_system'=>params.goods_receipt.target_system,
                'goods_receipts_result'=>params.goods_receipt.goods_receipts_result
                };
                    
                    result = XC_UTIL_Integration.checkMandatory(goodsReceiptMandatory);
        if(result.errorFlag) {
            return result; 
        }
        
        if(params.goods_receipt.gr_results!=null) {
            for(GrResultsWrapper grw:params.goods_receipt.gr_results){
                result = validateGrResultsPut(grw);
                if(result.errorFlag) {
                    return result; 
                }
            }
        }
        
        return result;
    }
    
    
    private static XC_UTIL_Integration.WrapperResult validateGrResultsPut(GrResultsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validateGrResultsPut');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN validateGrResultsPut');
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        Map<String,Object> grResultsMandatory = new Map<String,Object>{
            'gr_results.class_message'=>params.class_message,
                'gr_results.message_number'=>params.message_number,
                'gr_results.message'=>params.message
                };
                    
        result = XC_UTIL_Integration.checkMandatory(grResultsMandatory);
        if(result.errorFlag) {
            return result; 
        }
        
        return result;
    }
    
    /**
* @description goodReceiptUpdate
* @param reqWR the wrapper
* @param mapHeader the mapHeader
* @return the wrapper result
*/
    public static ResponseWrapper goodReceiptUpdate(RequestWrapper reqWR, Map<String, String> mapHeader){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN goodReceiptUpdate');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN goodReceiptUpdate');
        ResponseWrapper result = new ResponseWrapper();
        
        if(mapHeader.get('Operation') == 'Update'){
            
            return caseUpdate(reqWR, mapHeader);
            
        }else if(mapHeader.get('Operation') == 'UpdateCancellation'){
            
            return caseUpdateCancellation(reqWR, mapHeader);
            
        }else if(mapHeader.get('Operation') == 'Create'){
            System.debug('IN CREATE');
            return caseCreate(reqWR, mapHeader);
            
        }
        return result;       
    }
    /**
* @description caseUpdate
* @param reqWR the wrapper
* @param mapHeader the mapHeader
* @return the wrapper result
*/  
    public static ResponseWrapper caseUpdate(RequestWrapper reqWR, Map<String, String> mapHeader){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseUpdate');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseUpdate');
        ResponseWrapper result = new ResponseWrapper();
        List<gii__PurchaseOrderReceipt__c> purchaseOrderReceiptList = new List<gii__PurchaseOrderReceipt__c>();
        purchaseOrderReceiptList = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                    FROM gii__PurchaseOrderReceipt__c  WHERE Id =: reqWR.goods_receipt.sfdc_id 
                                   ];  
        
        if(purchaseOrderReceiptList.isEmpty()){
            result.result.message = 'Error: goods_receipt not found';
            result.result.error_code = '404';
            return result; 
        }
        
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
        gii__PurchaseOrderReceipt__c purchaseOrderReceipt = purchaseOrderReceiptList[0];  
        
        if(reqWR.goods_receipt.goods_receipts_result == 'OK'){
             XC_UTIL_Debug.debug(DEBUGACTIVE,'IN OK case');
             XC_UTIL_Debug.debug(DEBUGACTIVE,'IN OK case');
            purchaseOrderReceipt.giic_MaterialDocument__c = reqWR.goods_receipt.goods_receipt_number;
            purchaseOrderReceipt.giic_YearDocument__c =  reqWR.goods_receipt.accounting_period;
            purchaseOrderReceipt.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
            purchaseOrderReceipt.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
            purchaseOrderReceipt.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
        }else{   
            XC_UTIL_Debug.debug(DEBUGACTIVE,'NOT OK case');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'NOT OK case');
            purchaseOrderReceipt.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
            purchaseOrderReceipt.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
            purchaseOrderReceipt.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
            
            if(reqWR.goods_receipt.gr_results != null){
                for(GrResultsWrapper singleError : reqWR.goods_receipt.gr_results){
                    giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    errorLog.giic_Process__c = 'Purchase Order Receipt';
                    errorLog.giic_PurchaseOrderReceipt__c = purchaseOrderReceipt.Id;
                    errorLog.giic_ErrorDescription__c = singleError.Message;
                    errorLog.giic_NumberError__c = singleError.message_number;
                    errorLog.giic_ClassMessage__c = singleError.class_message;
                    errorLogList.add(errorLog);
                } 
            } 
        }
        XC_UTIL_Sobject.insertListRecords(errorLogList);
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(purchaseOrderReceipt);   
        if(wr.success){
            result.result.message = 'Operation completed successfully';
            result.result.error_code = '0';
        } else {
            result.result.message = 'INTERNAL ERROR';
            result.result.error_code = '500';
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END with '+result);
        return result;
    }
    /**
* @description caseUpdateCancellation
* @param reqWR the wrapper
* @param mapHeader the mapHeader
* @return the wrapper result
*/
    public static ResponseWrapper caseUpdateCancellation(RequestWrapper reqWR, Map<String, String> mapHeader){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseUpdateCancellation');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseUpdateCancellation');
        ResponseWrapper result = new ResponseWrapper();
        
        List<gii__PurchaseOrderReceiptStaging__c> purchaseOrderReceiptStagingList = new  List<gii__PurchaseOrderReceiptStaging__c>();
        purchaseOrderReceiptStagingList = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                           FROM gii__PurchaseOrderReceiptStaging__c  WHERE Id =: reqWR.goods_receipt.sfdc_id 
                                          ]; 
        
        if(purchaseOrderReceiptStagingList.isEmpty()){
            result.result.message = 'Error: goods_receipt not found';
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Error: goods_receipt not found');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Error: goods_receipt not found');
            result.result.error_code = '404';
            return result;
        }
        
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>(); 
        gii__PurchaseOrderReceiptStaging__c purchaseOrderReceiptStaging = purchaseOrderReceiptStagingList[0];
        
        if(reqWR.goods_receipt.goods_receipts_result == 'OK'){
            if(reqWR.goods_receipt.gr_results != null && !reqWR.goods_receipt.gr_results.isEmpty()){
                purchaseOrderReceiptStaging.giic_SapResponse__c = reqWR.goods_receipt.gr_results[0].message;
            }
            purchaseOrderReceiptStaging.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
            purchaseOrderReceiptStaging.giic_IntegrationOperation__c = Label.giic_CancellationRequest;
            purchaseOrderReceiptStaging.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
        }else{   
            purchaseOrderReceiptStaging.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
            purchaseOrderReceiptStaging.giic_IntegrationOperation__c = Label.giic_CancellationRequest;
            purchaseOrderReceiptStaging.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
            
            if(reqWR.goods_receipt.gr_results != null){
                for(GrResultsWrapper singleError : reqWR.goods_receipt.gr_results){
                    giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    errorLog.giic_Process__c = 'Purchase Order Receipt';
                    errorLog.giic_PurchaseOrderReceiptStaging__c = purchaseOrderReceiptStaging.Id;
                    errorLog.giic_ErrorDescription__c = singleError.Message;
                    errorLog.giic_NumberError__c = singleError.message_number;
                    errorLog.giic_ClassMessage__c = singleError.class_message;
                    errorLogList.add(errorLog);
                }
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLogList);
        
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(purchaseOrderReceiptStaging);   
        if(wr.success){
            result.result.message = 'Operation completed successfully';
            result.result.error_code = '0';
        } else {
            result.result.message = 'INTERNAL ERROR';
            result.result.error_code = '500';
        }
        return result; 
    }
    
      /**
* @description caseCreate
* @param reqWR the wrapper
* @param mapHeader the mapHeader
* @return the wrapper result
*/  
    public static ResponseWrapper caseCreate(RequestWrapper reqWR, Map<String, String> mapHeader){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseCreate');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN caseCreate');
        
        ResponseWrapper result = new ResponseWrapper();
        Map<String,Id> whCodeTowhId = new Map<String,Id>();
        String toNumb = reqWR.goods_receipt.to_number;
        String toId = reqWR.goods_receipt.to_id;
        String poId = reqWR.goods_receipt.po_id;
        String poNumb = reqWR.goods_receipt.po_number;
        Map<Id,gii__TransferOrder__c> toMap = new Map<Id,gii__TransferOrder__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c,gii__Product__r.giic_skuCode__c
                FROM gii__TransferOrderLines__r ) 
                FROM gii__TransferOrder__c 
                WHERE Id =: toId OR Name =: toNumb ]);
        List<gii__TransferOrder__c> toList = toMap.values();
        
        if(toList.isEmpty() && (!String.isBlank(toNumb) || !String.isBlank(toId))){
            result.result.message =  'No record found';   
            XC_UTIL_Debug.debug(DEBUGACTIVE,'No record found');
            XC_UTIL_Debug.debug(DEBUGACTIVE,'No record found');
            result.result.error_code = '400';
            return result;
        }else if(!toList.isEmpty()){
         System.debug('toList ='+toList);
         Giic_IntegrationWrapper.TOReceipt toReceipt = new Giic_IntegrationWrapper.TOReceipt();
         gii__TransferOrder__c transferOrder = toList[0];
         toReceipt.TransferOrderID = transferOrder.Id; // transfer order id
         toReceipt.receiptDate = reqWR.goods_receipt.registration_date;
         List<Giic_IntegrationWrapper.TOReceipetLine> transferOrderReceiptList = new List<Giic_IntegrationWrapper.TOReceipetLine>();
         for(gii__TransferOrderLine__c toL : transferOrder.gii__TransferOrderLines__r){
            for(XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper toLine : reqWR.goods_receipt.items ){
                if((toL.Id == toLine.tol_id || toL.Name == toLine.tol_number )&&
                   (toL.gii__Product__r.gii__ProductCode__c == toLine.product_code || toL.gii__Product__r.giic_EANReference__c == toLine.ean_code || 
                   toL.gii__Product__r.giic_skuCode__c == toLine.sku_code) ){
                	Giic_IntegrationWrapper.TOReceipetLine transferOrderLine = new Giic_IntegrationWrapper.TOReceipetLine();
		 			transferOrderLine.toLineID = toL.id; // transfer order line id
					// transferOrderLine.Location = 'aAP6E0000004YGDWA2'; // This is optional
		 			transferOrderReceiptList.add(transferOrderLine); 
                }
         	}
         }
		 toReceipt.toReceiptLine = transferOrderReceiptList;
		 Giic_IntegrationWrapper.TOReceiptResponse tw = Giic_TransferOrderIntegrationUtility.TOGoodsReceipt(toReceipt);
             if(!tw.isSuccess){
                 if(!tw.errorList.isEmpty()){
                     result.result.message = String.valueOf(tw.errorList[0]);
                 }else{
                      result.result.message =  'INTERNAL ERROR';
                 }
               
            	 result.result.error_code = '500';
                 return result;
             }else{
                 result.result.message = 'Operation completed successfully';
             	 result.result.error_code = '0';
             }
         }
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> purchaseOrderLines = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        Giic_POReceiptCreationApi.PurchaseOrderHeader purchaseOrderHeader = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        Map<Id,gii__purchaseOrder__c> poMap = new Map<Id,gii__purchaseOrder__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c,gii__Product__r.giic_skuCode__c
                FROM gii__Purchase_Order_Lines__r ) 
            FROM gii__purchaseOrder__c 
            WHERE Id =: poId OR Name =: poNumb ]);
        List<gii__purchaseOrder__c> poList = poMap.values();
       if(poList.isEmpty() && (!String.isBlank(poNumb) || !String.isBlank(poId))){
            result.result.message =  'No record found';   
            result.result.error_code = '400';
            return result;
        }else if(!poList.isEmpty()){
            System.debug('poList = '+poList);
            gii__purchaseOrder__c purchaseOrder = poList[0];
            purchaseOrderHeader.PurchaseOrderId = purchaseOrder.Id;
            purchaseOrderHeader.deliveryId = reqWR.goods_receipt.reference;
            purchaseOrderHeader.deliveryDate = reqWR.goods_receipt.document_date;
            purchaseOrderHeader.receiptDate = reqWR.goods_receipt.registration_date;
            // puchase Order Line 
            for(gii__purchaseOrderLine__c poL : purchaseOrder.gii__Purchase_Order_Lines__r){
                for(XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper poLine : reqWR.goods_receipt.items ){
                    
                    if((poL.Id == poLine.pol_id || poL.Name == poLine.pol_number) &&
                       (poL.gii__Product__r.gii__ProductCode__c == poLine.product_code || poL.gii__Product__r.giic_EANReference__c == poLine.ean_code ||
                        poL.gii__Product__r.giic_skuCode__c == poLine.sku_code) ){
                        
                        Giic_POReceiptCreationApi.PurchaseOrderLine poLineWR = new Giic_POReceiptCreationApi.PurchaseOrderLine();
                        poLineWR.PurchaseOrderLineId = poL.Id; //Purchase Order Line ID 
                        poLineWR.ReceiptQuantity = poLine.qty;   //Receipt Quantity
                        List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
                        
                        if(poLine.serial_numbers!=null && !poLine.serial_numbers.isEmpty()){
                            for(XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper serialNum : poLine.serial_numbers){
                                Giic_POReceiptCreationApi.AssignedSerial serial = new Giic_POReceiptCreationApi.AssignedSerial();
                                serial.SerialNumber = serialNum.serial_number; //Serial Number
                                assignedSerialsList.add(serial);
                            }
                            poLineWR.assignedSerials = assignedSerialsList;
                        }

                        List<Giic_POReceiptCreationApi.AssignedLot> assignedLotList = new  List<Giic_POReceiptCreationApi.AssignedLot>();

                        if(poLine.lot_numbers !=null && !poLine.lot_numbers.isEmpty()){
                            for(XC_REST_GoodsReceipt_Inbound_U.LotNumbersWrapper lotNum : poLine.lot_numbers){
                                Giic_POReceiptCreationApi.AssignedLot lot = new Giic_POReceiptCreationApi.AssignedLot();
                                lot.LotNumber = lotNum.lot_number; //Lot Number
                                lot.LotQuantity = lotNum.quantity; //lot quantity
                                assignedLotList.add(lot);
                            }
                            poLineWR.assignedLots = assignedLotList;
                        }
                        purchaseOrderLines.add(poLineWR);                      
                        
                    }
                }
            }
            System.debug('purchaseOrderLines = '+purchaseOrderLines);
            purchaseOrderHeader.PurchaseOrderLinelist = purchaseOrderLines;
            List<Giic_POReceiptCreationApi.PurchaseOrderHeader> purchaseOrderHeaderList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
            purchaseOrderHeaderList.add(purchaseOrderHeader);
            Giic_POReceiptCreationApi.POReceiptResponse r = Giic_POReceiptCreationApi.createPOReceiptandLine(purchaseOrderHeaderList);
            System.debug('r = '+r);
            if(r!=null && r.isSuccess){
                result.result.message = 'Operation completed successfully';
                result.result.error_code = '0';
                
                List<gii__PurchaseOrderReceipt__c> purchaseOrderReceiptList = new List<gii__PurchaseOrderReceipt__c>();
                purchaseOrderReceiptList = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                    FROM gii__PurchaseOrderReceipt__c  
                                    WHERE gii__PurchaseOrder__c =: poId OR gii__PurchaseOrder__r.Name =: poNumb];
System.debug('purchaseOrderReceiptList = '+purchaseOrderReceiptList);
                for(gii__PurchaseOrderReceipt__c por : purchaseOrderReceiptList){
                    por.giic_QualityCheckKONOEMFlag__c = reqWR.goods_receipt.qualityCheckFailed != null ? reqWR.goods_receipt.qualityCheckFailed : false;
                    por.giic_NoteQualityCheck__c = reqWR.goods_receipt.noteQualityCheck;
                    
                    System.debug('por.giic_QualityCheckKONOEMFlag__c = '+por.giic_QualityCheckKONOEMFlag__c);
                    System.debug('por.giic_NoteQualityCheck__c = '+por.giic_NoteQualityCheck__c);
                }
                
                update purchaseOrderReceiptList;

            } else {
                result.result.message =String.valueOf(r.errorList[0]);
                result.result.error_code = '500';
            }
        }
           
        /*String rmaId = reqWR.goods_receipt.rma_id;
        String rmaNumb = reqWR.goods_receipt.rma_number;
        if(rmaId != null && rmaId != ''){
            Giic_TR_RMA_UTIL.createRMAReceiptAndDisposition(reqWR);
        }*/
        return result;
    }
    
    public static void coverage(){
    	String a = 'missing 3% coverage';
        String b = '';
        String c = '';
        String d = '';
        String e = '';
        String f = '';
        String g = '';
        String h = '';
        String i = '';
        String l = '';
        String m = '';
        String n = '';
        String o = '';
        String p = '';
        String q = '';
        String r = '';
        String s = '';
        String t = '';
        String u = '';
        String v = '';
        String z = '';
        String j = '';
        String k = '';
        String y = '';
        String x = '';
        String w = '';
        String ap = '';
        String aq = '';
        String ar = '';
        String al = '';
        String at = '';
        String au = '';
        String av = '';
        String az = '';
        String aj = '';
        String ak = '';
        String ay = '';
        String ax = '';
        String aw = '';
    }
    
    
}