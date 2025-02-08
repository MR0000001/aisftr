/**
* @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 15/10/2019 
* @description REST INTERFACE : 
*/
public class XC_REST_TransferOrder_Inbound_U {
    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper {
        public TransferOrderWrapper transfer_order;
    }
    /**
     * @description wrapper class for request 
     */
    public class TransferOrderWrapper {
        public String account_name;
        public String from_warehouse_code;
        public String to_warehouse_code;
        public Date order_date;
        public Date required_date;
        public String ship_postal_code;
        public String ship_street;
        public String ship_state;
        public String ship_name;
        public String ship_country;
        public String ship_city;
        public String to_id;
        public String sfdc_id;
        public String delivery_tracking;
        public String status;
        public Date date_delivery;
        public String carrier_name;
        public Date new_required_date;

        public String transfer_order_type;
        public String ship_email;
        public String ship_primary_phone;
        public String ship_secondary_phone; 
        public String to_number;
        
        public List<ItemsWrapper> items;
          /*** NR1923 */
        public boolean Partner_GI_GR_Required;
        public List<AddressWrapper> ship_from;
        
    }
    /**
     * @description wrapper class for request  
     */
    public class ItemsWrapper {
        public Integer quantity;
        public String description;
        public String product_code;
        public Date required_date;
        public String tol_id; 
        public String tol_number;
        public String sfdc_id;
        public String delivery_tracking;
        public String status;
        public Date new_required_date;
        public Date date_delivery;
        public Integer shipped_quantity;

        public String ean_code;
        
        public String sku_code;
        public String carrier_name; //RP

    }
    
    /**
     * @description wrapper class for address supplier NR1923
     */
    public class AddressWrapper {
        public string Ship_from_name;
		public string Ship_from_address;
		public string Ship_from_Province;
		public string Ship_from_zip_code;
		public string Ship_from_City;
		public string Ship_from_Country;

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
     * @description validate request
     * @param params the wrapper
     * @param header the header
     * @return the wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validatePutRequest(RequestWrapper params, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }

        result = XC_UTIL_RESTInbound.checkObjectPermission('gii__TransferOrder__c', 'read');
        if(result.errorFlag){
            return result; 
        } 

        if(params.transfer_order == null){
            result.errorMessage = 'ERROR. Missing mandatory field: transfer_order';
            result.errorFlag = true;
            return result; 
        }  
        Map<String,Object> transferOrderMandatory = new Map<String,Object>{
            //'to_id'=>params.transfer_order.to_id,
            //'delivery_tracking'=>params.transfer_order.delivery_tracking,
            'status'=>params.transfer_order.status
            //'date_delivery'=>params.transfer_order.date_delivery,
            //'carrier_name'=>params.transfer_order.carrier_name
        };      

        result = XC_UTIL_Integration.checkMandatory(transferOrderMandatory);
        if(result.errorFlag) {
            return result; 
        }
        
        if(String.isBlank(params.transfer_order.to_id)&&String.isBlank(params.transfer_order.to_number)){
            result.errorMessage = 'ERROR. Missing mandatory one of this fields: transfer_order.to_id, transfer_order.to_number';
            result.errorFlag = true;
            return result; 
        }

        if(params.transfer_order.items!=null) {
            for(ItemsWrapper itm : params.transfer_order.items){
                result = validateItemPut(itm);
                if(result.errorFlag) {
                    return result; 
                } 
            }
        }
        return result;
    }

    private static XC_UTIL_Integration.WrapperResult validateItemPut(ItemsWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        /*
        Map<String,Object> itemMandatory = new Map<String,Object>{
            'items.tol_number'=>params.tol_number,
            'items.sfdc_id'=>params.sfdc_id,
            'items.delivery_tracking'=>params.delivery_tracking,
            'items.status'=>params.status
        };
        
        result = XC_UTIL_Integration.checkMandatory(itemMandatory);
        if(result.errorFlag) { 
            return result; 
        }
		*/
        
        if(String.isBlank(params.tol_id)&&String.isBlank(params.tol_number)){
            result.errorMessage = 'ERROR. Missing mandatory one of this fields: transfer_order.items.tol_id, transfer_order.items.tol_number';
            result.errorFlag = true;
            return result; 
        }
        
        return result;
    }
    

    /**
     * @description transferOrderUpdate
     * @param reqWR the wrapper
     * @return the wrapper result
     */
    public static ResponseWrapper transferOrderUpdate(RequestWrapper reqWr){
        ResponseWrapper result = new ResponseWrapper();
        String toNumb = reqWR.transfer_order.to_number;
        String toId = reqWR.transfer_order.to_id;
        Map<Id,gii__TransferOrder__c> toMap = new Map<Id,gii__TransferOrder__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c
                FROM gii__TransferOrderLines__r ) 
            FROM gii__TransferOrder__c 
            WHERE Id =: toId OR Name =: toNumb ]);
        List<gii__TransferOrder__c> toList = toMap.values();
        
        if(toList.isEmpty()){
            result.result.message = 'Error: TransferOrder not found';
            result.result.error_code = '404';
            return result; 
        }
         List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
        gii__TransferOrder__c transferOrder = toList[0];
        
        transferOrder.giic_DeliveryTracking__c = reqWr.transfer_order.delivery_tracking; 
        transferOrder.giic_NewDeliveryDate__c = reqWr.transfer_order.new_required_date;
        transferOrder.giic_CarrierName__c = reqWr.transfer_order.carrier_name;
        transferOrder.giic_status__c = reqWr.transfer_order.status;
        transferOrder.giic_IntegrationOperation__c = 'Update';
        transferOrder.Giic_TargetSystem__c = 'Glovia';
     
        for(gii__TransferOrderLine__c toL : transferOrder.gii__TransferOrderLines__r){
            for(ItemsWrapper toLine : reqWr.transfer_order.items){
                if(toL.Id == toLine.tol_id || toL.Name == toLine.tol_number ){ 
                    System.debug(' toLine.delivery_tracking = '+ toLine.delivery_tracking);
                    System.debug('toLine.carrier_name = '+toLine.carrier_name );
                    toL.giic_DeliveryTracking__c = toLine.delivery_tracking;
                    toL.giic_NewDeliveryDate__c = toLine.new_required_date; 
                    toL.giic_CarrierName__c = toLine.carrier_name ; 
           		 }
       		 }
        }
        List<SObject> updateList = new List<SObject>();
        updateList.add(transferOrder);
        updateList.addAll(transferOrder.gii__TransferOrderLines__r); 
        List<XC_UTIL_Sobject.WrapperResult> wr = XC_UTIL_Sobject.updateListRecords(updateList);  
        Boolean resultOk = true;
        for(XC_UTIL_Sobject.WrapperResult w : wr){
            if(!w.success){  
                transferOrder.giic_IntegrationStatus__c ='Integration Failure';  
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.giic_TransferOrder__c = transferOrder.Id; 
            	errorLog.giic_Process__c = 'Integration 3PL'; //Label.giic_ErrorLogIntegration; 
            	errorLog.Name = Label.giic_ErrorLogIntegration;
                errorLog.giic_ErrorDescription__c = w.errorMessage; 
                errorLogList.add(errorLog);
                resultOk = false;
            }else{
                
                transferOrder.giic_IntegrationStatus__c ='Integration Success';
                
            } 
        }
         if(!resultOk){
        	XC_UTIL_Sobject.insertListRecords(errorLogList); 
         }
        	XC_UTIL_Sobject.updateRecord(transferOrder);   
        
        
        if(errorLogList.isEmpty()){
            result.result.message = 'Operation completed successfully';
            result.result.error_code = '0';
        } else {
            result.result.message = 'INTERNAL ERROR';
            result.result.error_code = '500';
        }
         
        return result;
    }
    
  
}