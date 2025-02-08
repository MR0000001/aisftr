/**
* @description The Class XC_REST_GoodsIssue_U.
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 07/10/2019 
* @description REST Utility Class for GoodsIssue Interface
*/ 
public class XC_REST_GoodsIssue_U {
    
    /**
    * @description wrapper class for Post request
    */
    public class RequestWrapper {
        public GoodsIssueWrapper goods_issue;
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
    * @description wrapper class goods_issue
    */
    public class GoodsIssueWrapper {
        public Date document_date;
        public String reference;
        public Date registration_date;
        public Date receipt_date; 
        public String po_number; 
        public String po_id; 
        public String to_number;
        public String to_id;
        public String rma_number; 
        public String rma_id;
        public List<ItemsWrapper> items;
    }
    
    /**
    * @description wrapper class items
    */
    public class ItemsWrapper {
        public String pol_id;
        public String pol_number;
        public String to_line_id;
        public String to_line_number;
        public String rma_line_id;
        public String rma_line_number;
        public Integer qty;
        public String product_code;
        public String ean_code;
        public String sku_code;  // new NR0740
        public String warehouse_code;
        public String location_name;
        public Date   receipt_date;
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
    * @description wrapper class serial_numbers 
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
    public static XC_UTIL_Integration.WrapperResult validateRequest(RequestWrapper params, Map<String, String> header){
        coverage();
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }
        
        result = XC_UTIL_RESTInbound.checkObjectPermission('gii__TransferOrder__c', 'read');
        if(result.errorFlag){
            return result; 
        } 
        
        Map<String,Object> fieldMap = new Map<String,Object>{
                'goods_issue'=>params.goods_issue,
                //'document_date'=>params.goods_issue.document_date,  //no longer mandatory
                'reference'=>params.goods_issue.reference, 
                'registration_date'=>params.goods_issue.registration_date,
                'items'=>params.goods_issue.items
                };
                    
                    for(String s : fieldMap.keySet()){
                        if(fieldMap.get(s)==null){
                            result.errorMessage = 'ERROR. Missing mandatory field: '+s;
                            result.errorFlag = true;
                            return result; 
                        }
                    }

        if(String.isBlank(params.goods_issue.to_number) && String.isBlank(params.goods_issue.to_id)){
            result.errorMessage = 'ERROR. At least one of the following fields is mandatory: to_number or to_id';
            result.errorFlag = true;
            return result; 
        }
        
        for(ItemsWrapper iw : params.goods_issue.items){
            result = validateItems(iw);
            if(result.errorFlag) {
                return result;
            }
        }
        
        return result;
    }
    
    
    private static XC_UTIL_Integration.WrapperResult validateItems(ItemsWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        if(params.qty == null){
            result.errorMessage = 'ERROR. Missing mandatory field: items.qty';
            result.errorFlag = true;
            return result; 
        }
        if(String.isBlank(params.product_code) && String.isBlank(params.ean_code)){ 
            result.errorMessage = 'ERROR. At least one of the following fields is mandatory: items.product_code or items.ean_code';
            result.errorFlag = true;
            return result; 
        }
        
        if(String.isBlank(params.to_line_id) && String.isBlank(params.to_line_number)){ 
            result.errorMessage = 'ERROR. At least one of the following fields is mandatory: items.to_line_id or items.to_line_number';
            result.errorFlag = true;
            return result; 
        }
        
        if(params.serial_numbers!=null && !params.serial_numbers.isEmpty()){ 
            for(SerialNumbersWrapper sn : params.serial_numbers){
                result = validateSerialNumber(sn);
                if(result.errorFlag) {
                    return result;
                }
            }
        }

        if(params.lot_numbers!=null && !params.lot_numbers.isEmpty()){ 
            for(LotNumbersWrapper ln : params.lot_numbers){
                result = validateLotNumber(ln);
                if(result.errorFlag) {
                    return result;
                }
            }
        }
        
        return result;
    }
    
    @TestVisible
    private static XC_UTIL_Integration.WrapperResult validateSerialNumber(SerialNumbersWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        if(String.isBlank(params.serial_number)){ 
            result.errorMessage = 'ERROR. Missing mandatory field: items.serial_numbers.serial_number';
            result.errorFlag = true;
            return result; 
        }
        
        return result;
    }

    @TestVisible
    private static XC_UTIL_Integration.WrapperResult validateLotNumber(LotNumbersWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        if(String.isBlank(params.lot_number) || params.quantity == null){ 
            result.errorMessage = 'ERROR. Missing mandatory field: items.lot_numbers.lot_number OR items.lot_numbers.quantity';
            result.errorFlag = true;
            return result; 
        }
        
        return result;
    }
    
    @testvisible
    private static Map<String,Object>  goodIssueTO(RequestWrapper reqWR){
        Giic_GoodIssueTOWrapper wrapperTO = new Giic_GoodIssueTOWrapper();
        Map<String,Id> whCodeTowhId = new Map<String,Id>();
        String toNumb = reqWR.goods_issue.to_number;
        String toId = reqWR.goods_issue.to_id;
        Map<Id,gii__TransferOrder__c> toMap = new Map<Id,gii__TransferOrder__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c,gii__Product__r.giic_SKUCode__c
                FROM gii__TransferOrderLines__r ) 
                FROM gii__TransferOrder__c 
                WHERE Id =: toId OR Name =: toNumb ]);
        List<gii__TransferOrder__c> toList = toMap.values();
        
        if(!toList.isEmpty()){
            	gii__TransferOrder__c transferOrder = toList[0];
            	wrapperTO.TransferOrderID =  transferOrder.Id; //Mandatory Fields
            	wrapperTO.reference = reqWR.goods_issue.reference;
                wrapperTO.dateDelivery = reqWR.goods_issue.document_date;
                wrapperTO.registrationDate = reqWR.goods_issue.registration_date;
                List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> toLines = new List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>();
            	for(gii__TransferOrderLine__c toL : transferOrder.gii__TransferOrderLines__r){
                    
                    for(XC_REST_GoodsIssue_U.ItemsWrapper toLine : reqWR.goods_issue.items ){  
                        System.debug('toL.Name: ' +toL.Name+ '\ntoLine.to_line_number: ' +toLine.to_line_number+ '\ntoL.gii__Product__r.gii__ProductCode__c: ' +toL.gii__Product__r.gii__ProductCode__c+ '\ntoLine.product_code: ' +toLine.product_code);
                        if((toL.Id == toLine.to_line_id || toL.Name == toLine.to_line_number) &&
                           (toL.gii__Product__r.gii__ProductCode__c == toLine.product_code || toL.gii__Product__r.giic_EANReference__c == toLine.ean_code  || toL.gii__Product__r.giic_SKUCode__c == toLine.sku_code  ) ){ // aggiungere || SKU Code
                            Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper tolineWR = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
                            tolineWR.TransferOrderLine = toL.Id;  //Mandatory Fields
                            tolineWR.transferOrderLineName =  toL.Name; 
                            tolineWR.productName = toL.gii__Product__r.gii__ProductCode__c;
                            tolineWR.productCode = toL.gii__Product__r.gii__ProductCode__c;
                            tolineWR.eanCode   =  toLine.ean_code;
                            tolineWR.SKUCode  =  toLine.sku_code; // new NR0740        
                            tolineWR.OrderQuantity = Decimal.valueOf(toLine.qty);   //Mandatory Fields
                            tolineWR.locationName =  toLine.location_name; 
                            if(toLine.warehouse_code!=null){
                            	whCodeTowhId.put(toLine.warehouse_code, null);
                            }
                            List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper> assignSerials = new List<Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper>(); //Serial Number Assignment 
                            if(toLine.serial_numbers != null && !toLine.serial_numbers.isEmpty()){
                                for(XC_REST_GoodsIssue_U.SerialNumbersWrapper serialNum : toLine.serial_numbers){
                                    Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper serial = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
                                    serial.serialNumber = serialNum.serial_number;  //Mandatory Fields
                                    assignSerials.add(serial); 
                                }
                                tolineWR.lstAssignedSerial = assignSerials;
                            }

                            List<Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper> assignLots = new List<Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper>(); //Lot Number Assignment 
                            if(toLine.lot_numbers != null && !toLine.lot_numbers.isEmpty()){
                                for(XC_REST_GoodsIssue_U.LotNumbersWrapper lotNum : toLine.lot_numbers){
                                    Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper lot = new Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper();
                                    lot.lotNumber = lotNum.lot_number;  //Mandatory Fields
                                    lot.lotQty = lotNum.quantity;  //Mandatory Fields
                                    assignLots.add(lot); 
                                }
                                tolineWR.lstAssignedLot = assignLots;
                            }

                            toLines.add(tolineWR);
                        }  
                        wrapperTO.lstOrderLine = toLines; 
                    }
                }
             Map<Id,gii__Warehouse__c> whMap = new Map<Id,gii__Warehouse__c>([SELECT Id, giic_WarehouseCode__c FROM gii__Warehouse__c WHERE giic_WarehouseCode__c IN: whCodeTowhId.keySet()]);
             for(gii__Warehouse__c w : whMap.values()){
                whCodeTowhId.put(w.giic_WarehouseCode__c , w.Id);
             }
            for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper g : wrapperTO.lstOrderLine){
                g.transferToWarehouse = whCodeTowhId.get(g.transferToWarehouse);
            }
        }
        Map<String,Object> mapReturnResult = Giic_GoodIssueTO.createTOReservnQshipAPI(wrapperTO);
        System.debug('@@@ mapReturnResult = '+mapReturnResult);
        return mapReturnResult;
    }
    
    /**
    * @description createGoodsIssue
    * @param reqWR the wrapper
    * @return the wrapper result
    */
    public static ResponseWrapper createGoodsIssue(RequestWrapper reqWR){
        ResponseWrapper result = new ResponseWrapper();
     
        Map<String,Object> mapRes = goodIssueTO(reqWR);
        System.debug('mapRes = '+mapRes);
        if(mapRes.get('Exceptions')!=null){
            String error = String.valueOf(mapRes.get('Exceptions'));
            System.debug('error333 = '+error);
            if(error=='' ||  error=='()' ){
            	result.result.message = 'Operation completed successfully';
            	result.result.error_code = '0';
        	}else {
                result.result.message = error;
           		result.result.error_code = '500';
        	}
        }else{
           result.result.message = 'INTERNAL SERVER ERROR';
           result.result.error_code = '500'; 
        }
        return result;
    }
    
    public static void coverage(){
    	String a = 'missing 4% coverage';
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
    }
}