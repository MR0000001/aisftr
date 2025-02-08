/**
 * @description The Class XC_REST_PurchaseOrder_Inbound_U.
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation 07/10/2019 
 * @description REST Utility Class for PurchaseOrder Interface
 */ 
public class XC_REST_PurchaseOrder_Inbound_U {

    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper {
        public PurchaseOrderWrapper purchase_order;     
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
     * @description wrapper class for purchase_order 
     */
    public class PurchaseOrderWrapper {
        public String cessionary;
        public String cig;
        public String company;
        public String contract_id;
        public String contract_number;
        public String contract_supervisor;
        public String cup;
        public Date end_date;        
        public Date po_new_date;
        public String po_number;
        public String partner_id;
        public String partner_sap_id;
        public String payment_condition;
        public String po_currency;   
        public Date purchase_order_date;
        public String purchase_order_type;
        public String purchasing_group;
        public String purchasing_org;
        public Date po_required_date;
        public String sfdc_id;
        public String short_description;
        public String short_subject;
        public String solidal_resp;
        public String source_system;
        public Date start_date;
        public String supplier_code_ef;
        public String supplier_code_io;
        public String target_system;
        public String tender_category;
        public Date transfer_date;
        public String warranty_reference;
        public String po_result;

        public String warehouse_code;
        public String status;
        public String ship_email;
        public String ship_primary_phone;
        public String ship_secondary_phone;

        public String noteQualityCheck;
        public Boolean QualityCheckFailed_NO_GR;

        public List<ItemsWrapper> items; 
        
        public LocationWrapper location;
        
        public List<PoResultsWrapper> po_results;
        /*** NR1923 */
        public date Pickup_Date;
        public boolean Delivery_4PL_Required;
        public boolean Partner_GR_Required ;
        public date New_Delivery_Date;
		public string Tracking_Substate;
	    public string URL_Delivery_Tracking;
		public string Carrier_Name;
 		public date New_Pickup_Date;

        public List<AddressSupplierWrapper> ship_from;
    }

    /**
     * @description wrapper class for purchase_order
     */
    public class ItemsWrapper {
        public String accounting_category;
        public String applicant_unit;
        public String communication_language;
        public String contract_number;
        public Integer contract_pos_number;
        public String cost_center;
        public String division;
        public String goods_group;
        public String iva_code;
        public String material_code;
        public Decimal net_price;
        public Integer price;
        public Integer price_unit; 
        public Date promise_date;
        public Decimal qty;
        public String sap_pos_category;
        public Integer sap_pos_po;
        public String sfdc_id;  
        public String shipping_address;
        public String short_description;
        public String unit_of_measure;  
        public String warehouse_id;  
        public String wbs_element; 
        
        public String po_item_id;
        public String location_name;
        public String location_type;
        public String street_type;
        public String address;
        public String street_number;
        public String zip_code;
        public String city;
        public String country;

        public String warehouse_code;
        public String ean_code;
        public String sku_code;
        public String pol_number;

        public List<ItemsServiceWrapper> items_services;

    }  

    /**
     * @description wrapper class for items_services
     */
    public class ItemsServiceWrapper {
        public String sap_currency;
        public Integer sap_pos_po;
        public Integer sap_row_number;
        public String sap_service_code;
        public String cost_center;
        public Decimal gross_price;
        public Integer price_unit;
        public Decimal qty;
        public String short_description;
        public String unit_of_measure; 
        public String wbs_element;
    }

    /**
     * @description wrapper class for location
     */
    public class LocationWrapper {
        public String location_name;
        public String location_type;
        public String street_type;
        public String address;
        public String street_number;
        public String zip_code;
        public String city;
        public String country;
       
    }

    /**
     * @description wrapper class for po_results
     */
    public class PoResultsWrapper {
        public String class_message;
        public Integer message_number;
        public String message;
        public String error_code;
    }
	
     /**
     * @description wrapper class for address supplier NR1923
     */
    public class AddressSupplierWrapper {
      	public string Ship_from_name;
		public string Ship_from_address;
		public string Ship_from_Province;
		public string Ship_from_zip_code;
		public string Ship_from_City;
		public string Ship_from_Country;

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
        if(params != null && params.purchase_order != null &&  params.purchase_order.QualityCheckFailed_NO_GR == true && params.purchase_order.noteQualityCheck == null){
            result.errorFlag = true;
            result.errorMessage = Label.XC_CL_PurchaseOrder_MissingFieldQualityCheck;
            return result;
        }
    /*    if(header.get('ClientSystenoteQualityCheckm')=='S4P'){
            return checkUpdateFromS4P(params);

        } else if(header.get('ClientSystem')=='Supplier'){
            return checkUpdateFromSupplier(params);

        } else {
            result.errorMessage = 'Error. Invalid ClientSystem: '+header.get('ClientSystem');
            result.errorFlag = true;
            return result; 
        }*/
 return result; 
    }


   /* private static XC_UTIL_Integration.WrapperResult checkUpdateFromS4P(RequestWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        Map<String,Object> purchaseOrderMandatory = new Map<String,Object>{ 
            'purchase_order'=>params.purchase_order,
            'po_number'=>params.purchase_order.po_number,
            'sfdc_id'=>params.purchase_order.sfdc_id,
            'po_result'=>params.purchase_order.po_result
        };

        result = XC_UTIL_Integration.checkMandatory(purchaseOrderMandatory); 
        if(result.errorFlag){
            return result; 
        } 

        if(!params.purchase_order.po_results.isEmpty()){
            for(PoResultsWrapper pw : params.purchase_order.po_results){
                Map<String,Object> poResultsMandatory = new Map<String,Object>{
                    'po_results.class_message'=>pw.class_message,
                    'po_results.message_number'=>pw.message_number,
                    'po_results.message'=>pw.message
                };
                result = XC_UTIL_Integration.checkMandatory(poResultsMandatory);
                if(result.errorFlag){
                    return result;  
                } 
            }
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkUpdateFromSupplier(RequestWrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        Map<String,Object> purchaseOrderMandatory = new Map<String,Object>{
            'purchase_order'=>params.purchase_order,
            'sfdc_id'=>params.purchase_order.sfdc_id,
            'source_system'=>params.purchase_order.source_system,
            'target_system'=>params.purchase_order.target_system,
            'po_result'=>params.purchase_order.po_result,
            'po_results'=>params.purchase_order.po_results,
            'items'=>params.purchase_order.items 
        };

        result = XC_UTIL_Integration.checkMandatory(purchaseOrderMandatory);
        if(result.errorFlag){
            return result; 
        } 

        for(PoResultsWrapper pw : params.purchase_order.po_results){
            Map<String,Object> poResultsMandatory = new Map<String,Object>{
                'po_results.error_code'=>pw.error_code,
                'po_results.message'=>pw.message
            };
            result = XC_UTIL_Integration.checkMandatory(poResultsMandatory);
            if(result.errorFlag){
                return result; 
            } 
        }

        if(params.purchase_order.items.isEmpty()){
            result.errorMessage = 'ERROR. Missing mandatory field: items';
            result.errorFlag = true;
            return result; 
        }

        for(ItemsWrapper iw : params.purchase_order.items){
            Map<String,Object> itemsMandatory = new Map<String,Object>{
                'items.sfdc_id'=>iw.sfdc_id
            };
            result = XC_UTIL_Integration.checkMandatory(itemsMandatory);
            if(result.errorFlag){
                return result;  
            } 
        }

        return result;
    }
*/
    /**
     * @description updatePurchaseOrder
     * @param reqWR the wrapper
     * @return the wrapper result
     */
    public static ResponseWrapper purchaseOrderUpdate(RequestWrapper reqWR){
        ResponseWrapper result = new ResponseWrapper();
        Id sfdcId = Id.valueOf(reqWR.purchase_order.sfdc_id);
        String objectType = sfdcId.getSObjectType().getDescribe().getName();
        if(objectType == 'gii__PurchaseOrder__c'){
            Map<Id, gii__PurchaseOrder__c > purchaseOrderList = new Map<Id, gii__PurchaseOrder__c >([ 
                SELECT Id, giic_POCode__c,giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_MultiTargetSystem__c, giic_Status__c,
                giic_NewDeliveryDate__c,giic_TrackingSubstate__c,giic_DeliveryTracking__c, giic_CarrierName__c,giic_NewPickupDate__c
                FROM gii__PurchaseOrder__c  WHERE Id = : reqWR.purchase_order.sfdc_id  
            ]);
            if(purchaseOrderList.isEmpty()){
                result.result.message = 'Error: purchase_order not found';
                result.result.error_code = '404';
                return result; 
            }

            List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
            gii__PurchaseOrder__c purchaseOrder = purchaseOrderList.values();
            
            if(reqWR.purchase_order.target_system != null && reqWR.purchase_order.target_system !=''){
            	if(reqWR.purchase_order.po_result == 'OK'){
                	if(purchaseOrder.giic_IntegrationOperation__c == Label.giic_IntegrationOperationCreate){
                    	purchaseOrder.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                    	purchaseOrder.giic_POCode__c = reqWR.purchase_order.po_number;
                	} 
         			//NR1923
                	/*purchaseOrder.giic_NewDeliveryDate__c=reqWR.purchase_order.New_Delivery_Date;
                	purchaseOrder.giic_TrackingSubstate__c=reqWR.purchase_order.Tracking_Substate;
                	purchaseOrder.giic_DeliveryTracking__c=reqWR.purchase_order.URL_Delivery_Tracking;
                	purchaseOrder.giic_CarrierName__c=reqWR.purchase_order.Carrier_Name;
                	purchaseOrder.giic_NewPickupDate__c=reqWR.purchase_order.New_Pickup_Date;*/
                	purchaseOrder.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
                	Set<String> values = new Set<String>();
                	values.add(Label.giic_TargetSystemGlovia);
                	purchaseOrder.Giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(purchaseOrder.Giic_MultiTargetSystem__c  ,  values);
                
            	}else{ 
                	if(purchaseOrder.giic_IntegrationOperation__c == Label.giic_IntegrationOperationCreate){
                    	purchaseOrder.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate; 
                	} 
                	purchaseOrder.giic_IntegrationStatus__c =Label.giic_IntegrationStatusFailure; 
                	Set<String> values = new Set<String>();
                	values.add(Label.giic_TargetSystemGlovia);
                	purchaseOrder.Giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(purchaseOrder.Giic_MultiTargetSystem__c , values);
                	system.debug('reqWR.purchase_order.po_results: '+ reqWR.purchase_order.po_results);
                	for(XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper singleError : reqWR.purchase_order.po_results){
                    	giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    	errorLog.giic_PurchaseOrder__c = purchaseOrder.Id;
                    	errorLog.giic_Process__c = 'Integration SAP';//Label.giic_ErrorLogIntegration; 
                    	errorLog.Name = Label.giic_ErrorLogIntegration;
                    	errorLog.giic_ErrorDescription__c = singleError.Message;
                    	errorLog.giic_NumberError__c = singleError.message_number;
                    	errorLog.giic_ClassMessage__c = singleError.class_message;
                    	errorLogList.add(errorLog);
                	}
                	XC_UTIL_Sobject.insertListRecords(errorLogList); 
            	}  
            }else{
                if(purchaseOrder.giic_IntegrationOperation__c == Label.giic_IntegrationOperationCreate){
                    	purchaseOrder.giic_IntegrationOperation__c = Label.giic_IntegrationOperationUpdate;
                    	purchaseOrder.giic_POCode__c = reqWR.purchase_order.po_number;
                	} 
         			//NR1923
                	purchaseOrder.giic_NewDeliveryDate__c=reqWR.purchase_order.New_Delivery_Date;
                	purchaseOrder.giic_TrackingSubstate__c=reqWR.purchase_order.Tracking_Substate;
                	purchaseOrder.giic_DeliveryTracking__c=reqWR.purchase_order.URL_Delivery_Tracking;
                	purchaseOrder.giic_CarrierName__c=reqWR.purchase_order.Carrier_Name;
                	purchaseOrder.giic_NewPickupDate__c=reqWR.purchase_order.New_Pickup_Date;
                	purchaseOrder.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess; 
                	Set<String> values = new Set<String>();
                	values.add(Label.giic_TargetSystemGlovia);
                	purchaseOrder.Giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(purchaseOrder.Giic_MultiTargetSystem__c  ,  values);
            }
            
            if(reqWR.purchase_order.QualityCheckFailed_NO_GR != null && reqWR.purchase_order.noteQualityCheck != null){
                purchaseOrder.giic_QualityCheckKONOEMFlag__c = reqWR.purchase_order.QualityCheckFailed_NO_GR;
                purchaseOrder.giic_NoteQualityCheck__c = reqWR.purchase_order.noteQualityCheck;
            }

            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(purchaseOrder);   
            if(wr.success){
                result.result.message = 'Operation completed successfully';
                result.result.error_code = '200';
            } else {
                result.result.message = 'INTERNAL ERROR';
                result.result.error_code = '500';
            }
        }else if(objectType == 'WorkOrderLineItem'){
            Map<Id, WorkOrderLineItem > workOrderLineItemList = new Map<Id, WorkOrderLineItem >([ 
                SELECT id, XC_ErrorClass__c, XC_ErrorCode__c, XC_ErrorDescription__c, XC_ErrorMessage__c, XC_SentToSAP__c, XC_PurchaseOrderCode__c, XC_Oda_Cancellation_Sent__c, Status FROM WorkOrderLineItem WHERE id = : reqWR.purchase_order.sfdc_id 
            ]);
            if(workOrderLineItemList.isEmpty()){
                result.result.message = 'Error: work order line item not found';
                result.result.error_code = '404';
                return result; 
            }

            List<giic_ErrorLog__c> errorLogList = new List<giic_ErrorLog__c>();
            WorkOrderLineItem woli = workOrderLineItemList.values();
            
            if(reqWR.purchase_order.po_result == 'OK'){

                woli.XC_ErrorMessage__c = Label.giic_IntegrationStatusSuccess;
                if(reqWR.purchase_order.po_number != null ){
                    woli.XC_PurchaseOrderCode__c = reqWR.purchase_order.po_number;
                }
                if(!woli.XC_Oda_Cancellation_Sent__c ){
                    woli.Status = 'Completed';
                }else{
                    woli.Status = 'Cancelled';
                }
                
            }else{ 
                if(!woli.XC_Oda_Cancellation_Sent__c ){
                    woli.XC_SentToSAP__c = false;
                }else{
                    woli.XC_Oda_Cancellation_Sent__c = false;
                }
                woli.XC_ErrorMessage__c =Label.giic_IntegrationStatusFailure; 

                for(XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper singleError : reqWR.purchase_order.po_results){
                    giic_ErrorLog__c errorLog = new giic_ErrorLog__c();
                    errorLog.XC_WorkOrderLineItem__c = woli.Id;
                    errorLog.giic_Process__c = 'Integration SAP';//Label.giic_ErrorLogIntegration; 
                    errorLog.Name = Label.giic_ErrorLogIntegration;
                    errorLog.giic_ErrorDescription__c = singleError.Message;
                    errorLog.giic_NumberError__c = singleError.message_number;
                    errorLog.giic_ClassMessage__c = singleError.class_message;
                    errorLogList.add(errorLog);
                }
                XC_UTIL_Sobject.insertListRecords(errorLogList); 
            }

            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(woli);   
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


}