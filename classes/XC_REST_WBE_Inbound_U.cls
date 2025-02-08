/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 18/02/2020
* @description REST INTERFACE : 
*/
public class XC_REST_WBE_Inbound_U {

    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper {
        public List<WbeWrapper> wbes;
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
     * @description wrapper class for wbe
     */
    public class WbeWrapper {
        public String wbe;
        public String wbs;
        public String scope;
        public String sap_pillar;
        public String company_code;
        public String product_line;
        public String product_service_code;
        public String business_model_code;        
        public String order_number;
        public String configuration_id;
        public String configuration_item_id;
        public String execution_project_id;
        public String client_identifier;
        public String cost_center_responsible;
        public String market;
        public String customer_segment;
        public String legal_entity_geografy;
        public String type_of_location;
        public String channel;
        public String customer_relevance;
        public String customer_size;
        public String type_of_customer;
        public String customer_geografy;
        public String kit_logistic;
        public String contract;
        public String wbe_first_level;
        public String sfdc_id;
        public String activity;
        public String wbe_second_level;
        public String wbe_third_level;
        public String type_of_sending;
        public String status;
        public String sales_order;
        public String odv_intercompany;
        
        public String order_id;
        public String wbe_error_code;
        public String wbe_message;
        public String projectDimension;
        
        public Date contractStartDate;
        public Date contractEndDate;
        public Decimal estimatedRevenue;
        public Decimal estimatedCost;
        public Boolean updateWBEcapex;
        public String contractType;
        public String DocumentType;
        public String DocumentNumber;          
        public String customerName;
        public Boolean ownership;
        public String location;

    }    
    
    /**
    * @description validate request
    * @param params the wrapper
    * @param header the header
    * @return the wrapper result
    */
    /*public static XC_UTIL_Integration.WrapperResult validatePostRequest(RequestWrapper params, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }

        if(params.wbes == null){
            result.errorMessage = 'ERROR. Missing mandatory field: wbes';
            result.errorFlag = true;
            return result; 
        }

        Map<String,Object> wbesMandatory = new Map<String,Object>{
            'wbe' => params.wbes.wbe,
            'wbs' => params.wbes.wbs,
            'scope' => params.wbes.scope,
            'sap_pillar' => params.wbes.sap_pillar,
            'company_code' => params.wbes.company_code,
            'product_line' => params.wbes.product_line,
            'product_service_code' => params.wbes.product_service_code,
            'cost_center_responsible' => params.wbes.cost_center_responsible,
            'market' => params.wbes.market,
            'wbe_first_level' => params.wbes.wbe_first_level,
            'sfdc_id' => params.wbes.sfdc_id,
            'wbe_second_level' => params.wbes.wbe_second_level,
            'wbe_third_level' => params.wbes.wbe_third_level,
            'type_of_sending' => params.wbes.type_of_sending,
            'status' => params.wbes.status,
            'sales_order' => params.wbes.sales_order
        };

        result = XC_UTIL_Integration.checkMandatory(wbesMandatory); 
        if(result.errorFlag) {
            return result; 
        }

        return result;
    }*/


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
     
        if(params.wbes == null || params.wbes.isEmpty()){
            result.errorMessage = 'ERROR. Missing mandatory field: wbes';
            result.errorFlag = true;
            return result; 
        }

        for(WbeWrapper w : params.wbes){
            Map<String,Object> wbesMandatory = new Map<String,Object>{
                'wbe' => w.wbe,
                'sfdc_id' => w.sfdc_id,
                'order_id' => w.order_id,
                'wbe_error_code' => w.wbe_error_code,
                'wbe_message' => w.wbe_message
            };
                        
            result = XC_UTIL_Integration.checkMandatory(wbesMandatory);
            if(result.errorFlag) {
                return result; 
            }
        }
        
        return result;
    }

    

    /**
     * @description goodReceiptUpdate
     * @param reqWR the wrapper
     * @return the wrapper result
     */
   /* 
    * 
    * ESEMPIO
    * 
    * 
    public static ResponseWrapper goodReceiptUpdate(RequestWrapper reqWR, Map<String, String> mapHeader){
        ResponseWrapper result = new ResponseWrapper();
        List<gii__PurchaseOrderReceipt__c> purchaseOrderReceiptList = new List<gii__PurchaseOrderReceipt__c>();
        List<gii__PurchaseOrderReceiptStaging__c> purchaseOrderReceiptStagingList = new  List<gii__PurchaseOrderReceiptStaging__c>();
        
        if(mapHeader.get('Operation') == 'Update'){
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
            
            if(reqWR.goods_receipt.goods_receipts_result == '0'){
                purchaseOrderReceipt.giic_MaterialDocument__c = reqWR.goods_receipt.goods_receipt_number;
                purchaseOrderReceipt.giic_YearDocument__c =  reqWR.goods_receipt.accounting_period;
                purchaseOrderReceipt.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
                purchaseOrderReceipt.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                purchaseOrderReceipt.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
            }else{   
                purchaseOrderReceipt.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
                purchaseOrderReceipt.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                purchaseOrderReceipt.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
                
                if(reqWR.goods_receipt.gr_results != null){
                    for(GrResultsWrapper singleError : reqWR.goods_receipt.gr_results){
                        giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
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
                result.result.error_code = '200';
            } else {
                result.result.message = 'INTERNAL ERROR';
                result.result.error_code = '500';
            } 
        }
        if(mapHeader.get('Operation') == 'UpdateCancellation'){
            purchaseOrderReceiptStagingList = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                FROM gii__PurchaseOrderReceiptStaging__c  WHERE Id =: reqWR.goods_receipt.sfdc_id 
            ]; 
       
        if(purchaseOrderReceiptStagingList.isEmpty()){
            result.result.message = 'Error: goods_receipt not found';
            result.result.error_code = '404';
            return result; 
        }
            
        List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>(); 
     	gii__PurchaseOrderReceiptStaging__c purchaseOrderReceiptStaging = purchaseOrderReceiptStagingList[0];
     
        if(reqWR.goods_receipt.goods_receipts_result == '0'){ 
            purchaseOrderReceiptStaging.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
            purchaseOrderReceiptStaging.giic_IntegrationOperation__c = Label.giic_CancellationRequest;
            purchaseOrderReceiptStaging.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
        }else{   
            purchaseOrderReceiptStaging.giic_IntegrationStatus__c = Label.giic_IntegrationStatusFailure;
            purchaseOrderReceiptStaging.giic_IntegrationOperation__c = Label.giic_CancellationRequest;
            purchaseOrderReceiptStaging.Giic_TargetSystem__c = Label.giic_TargetSystemGlovia;
            
            for(GrResultsWrapper singleError : reqWR.goods_receipt.gr_results){
                giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                errorLog.giic_PurchaseOrderReceiptStaging__c = purchaseOrderReceiptStaging.Id;
                errorLog.giic_ErrorDescription__c = singleError.Message;
                errorLog.giic_NumberError__c = singleError.message_number;
                errorLog.giic_ClassMessage__c = singleError.class_message;
                errorLogList.add(errorLog);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLogList);

        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(purchaseOrderReceiptStaging);   
        if(wr.success){
            result.result.message = 'Operation completed successfully';
            result.result.error_code = '200';
        } else {
            result.result.message = 'INTERNAL ERROR';
            result.result.error_code = '500';
        }
 }
        return result;       
    }
    */

}