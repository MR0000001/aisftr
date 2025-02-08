/**
 * The Class XC_REST_Order.
 *
 * @author            : Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date	Creation	 : 10/12/2018
 * @date Modification : 09/04/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : REST Interface for Create / Update a Order / Order Item
 **/

 
@RestResource(urlMapping = '/v1/Order/*') 
global without sharing class XC_REST_Order {

    /**
     * @description Method to create an order by a external request 
     */
    @HttpPost
    global static void doPost() {
        
        Map<String,String> header = new Map<String,String>();
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        System.Savepoint beforeInsertOrderSavepoint; 
        if(!Test.isRunningTest()){
            beforeInsertOrderSavepoint = Database.setSavepoint();
        }
                  
         
        XC_REST_Order_U.WrapperIntegrationLog wrIntlog = new XC_REST_Order_U.WrapperIntegrationLog();
        try {
        	
            header = request.headers;
            wrIntlog.msgRequest = request.requestbody.toString(); 
            intLog.insertIntegReqInboundLog('Order', wrIntlog.msgRequest); //Create a record in Integration Log Object	
            intLog.setHeader(header);   		
            intLog.setHttpMethod(request.httpMethod);
            intLog.setTransactionID(header.get('TransactionID'));       
            XC_REST_Order_U.WrapperPOSTRequest wrReq = (XC_REST_Order_U.WrapperPOSTRequest) JSON.deserialize(wrIntlog.msgRequest, XC_REST_Order_U.WrapperPOSTRequest.class);
            
            Map<String, Object> mapUtil = new Map<String, Object>{  'header'=> header,
                                                                    'wrReq' => wrReq,
                                                                    'direction'=> 'Inbound'
                                                                };     

            XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'create');
            if(responseValidation.errorFlag){
                wrResp.Result.Message = responseValidation.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }                                                                     
                                                                    
            responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
            if(responseValidation.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
                wrResp.Result.ErrorCode = (responseValidation.errorCode!='401'&&responseValidation.errorCode!='402')?'400':responseValidation.errorCode;
                wrResp.Order = null;
                return;
            }else{
				/*20220316_NicoloFodera Ottimizzazione createOrder  start*/

				List<String> listOfClientSystemForAsyncTrigger = new List<String>();
                listOfClientSystemForAsyncTrigger = Label.XC_CL_AllClientSystemForAsyncTrigger.split(';');
                if(listOfClientSystemForAsyncTrigger.contains(header.get('ClientSystem'))){
					XC_TR_ConfigurationItem_Handler.asyncAggreateAfterUpdate = true;
				}/*20220316_NicoloFodera Ottimizzazione createOrder  end*/
                XC_REST_Order_U.insertOrders(wrReq, wrResp, mapUtil);
				/*20220316_NicoloFodera Ottimizzazione createOrder  start*/
				if(wrResp.Result.ErrorCode == '0' && listOfClientSystemForAsyncTrigger.contains(header.get('ClientSystem'))){
					System.enqueueJob((new XC_TR_ConfigurationItem_Handler.OnAfterUpdateAsyncAggregate(intLog)));
				}/*20220316_NicoloFodera Ottimizzazione createOrder  end*/

             } 
        } catch (Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR'; 
            wrResp.Result.ErrorCode = '500';
            wrIntlog.logError = 'INTERNAL ERROR: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

        } finally {

            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Order = null;
                if(!Test.isRunningTest()){
                    Database.rollback(beforeInsertOrderSavepoint);
                }
                
                /*if(String.isBlank(wrIntlog.logError)) {
                    wrIntlog.logError = wrResp.Result.logError;
                } else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_CannotBeUsed)){
                	wrResp.Result.Message = wrIntlog.logError;
                    wrResp.Result.ErrorCode = '461';
            	} else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_AlreadyUsedByAccount)){
                	wrResp.Result.Message = wrIntlog.logError;
                    wrResp.Result.ErrorCode = '462';
                }*/

                if(String.isBlank(wrIntlog.logError)) {
                    wrIntlog.logError = wrResp.Result.logError;
                }
                if(!String.isBlank(wrIntlog.logError)){
                    if(wrIntlog.logError.contains(Label.XC_CL_Voucher_CannotBeUsed)){
                        wrResp.Result.Message = wrIntlog.logError;
                        wrResp.Result.ErrorCode = '461';
                    } else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_AlreadyUsedByAccount)){
                        wrResp.Result.Message = wrIntlog.logError;
                        wrResp.Result.ErrorCode = '462';
                    }
                }

            }
            wrResp.Result.logError = null;
            wrIntlog.msgResponse = JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode == '0' ? true : false), wrIntlog.msgResponse, wrIntlog.logError);
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = wrIntlog.msgResponse;
            restContextResponseWrapper.mapHeader = header;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper); 
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            wrIntlog.msgResponse = restContextResponseWrapper.msgResponse;
            header = restContextResponseWrapper.mapHeader;
        }
    }

    
    /**
     * @description Method to create an order by a external request
     */
    @HttpPut
    global static void doPut() {
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        Map<String,String> header = request.headers;
        System.Savepoint beforeUpdateOrderSavepoint;
        if(!Test.isRunningTest()){
            beforeUpdateOrderSavepoint = Database.setSavepoint();
        }
       
        XC_REST_Order_U.WrapperIntegrationLog wrIntlog = new XC_REST_Order_U.WrapperIntegrationLog();
        
        try {
            wrIntlog.msgRequest = request.requestbody.toString();
            intLog.insertIntegReqInboundLog('Order', wrIntlog.msgRequest); //Create a record in Integration Log Object			
            intLog.setHeader(header);
            intLog.setHttpMethod(request.httpMethod);
            intLog.setTransactionID(header.get('TransactionID'));
            XC_REST_Order_U.WrapperPUTRequest wrReq = (XC_REST_Order_U.WrapperPUTRequest) JSON.deserialize(wrIntlog.msgRequest, XC_REST_Order_U.WrapperPUTRequest.class);
            
             Map<String, Object> mapUtil = new Map<String, Object>{ 'header'=> header,
                                                                    'wrReq' => wrReq,
                                                                    'direction'=> 'Inbound'
                                                                };    

            XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'update');
            if(responseValidation.errorFlag){
                wrResp.Result.Message = responseValidation.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }                                                                      
                                                                    
            responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
            if(responseValidation.errorFlag){
                wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
                wrResp.Result.ErrorCode = (responseValidation.errorCode!='401'&&responseValidation.errorCode!='402')?'400':responseValidation.errorCode;
                wrResp.Order = null;
                return;
            } else{
                Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
                Map<String, Object> mapOrder = new Map<String, Object>{ 'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
                                                                    'wrReq' => wrReq,
                                                                    'clientSystem' => header.get('ClientSystem')
                                                                };  
                XC_REST_Order_ZZ.checkConfigurationObjectsId(mapOrder, wrResp); 
                if(wrResp.Result.ErrorCode == '400'){
                    return;
                }

                if(header.get('Operation') == 'OptyToQuote'){
                    XC_REST_Order_U.manageOptyToQuote(mapOrder, wrResp, 'Quote'); 
                }else{
                    XC_REST_Order_U.updateOrders(mapOrder, wrResp );
                }
                
            }
            
        } catch (Exception e) {

            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            wrIntlog.logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();

        } finally {

            System.debug(LoggingLevel.INFO,'-- finally --');

            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Order = null;
                if(!Test.isRunningTest()){
                    Database.rollback(beforeUpdateOrderSavepoint);
                }
                
                   
                /*if(String.isBlank(wrIntlog.logError)) {
                    wrIntlog.logError = wrResp.Result.logError;
                } else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_CannotBeUsed)){
                	wrResp.Result.Message = wrIntlog.logError;
                    wrResp.Result.ErrorCode = '461';
            	} else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_AlreadyUsedByAccount)){
                	wrResp.Result.Message = wrIntlog.logError;
                    wrResp.Result.ErrorCode = '462';
                }*/

                if(String.isBlank(wrIntlog.logError)) {
                    wrIntlog.logError = wrResp.Result.logError;
                }
                if(!String.isBlank(wrIntlog.logError)){
                    if(wrIntlog.logError.contains(Label.XC_CL_Voucher_CannotBeUsed)){
                        wrResp.Result.Message = wrIntlog.logError;
                        wrResp.Result.ErrorCode = '461';
                    } else if(wrIntlog.logError.contains(Label.XC_CL_Voucher_AlreadyUsedByAccount)){
                        wrResp.Result.Message = wrIntlog.logError;
                        wrResp.Result.ErrorCode = '462';
                    }
                }
            }
            wrResp.Result.logError = null;
            wrIntlog.msgResponse = JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode == '0' ? true : false), wrIntlog.msgResponse, wrIntlog.logError);
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = wrIntlog.msgResponse;
            restContextResponseWrapper.mapHeader = header;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper); 
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            wrIntlog.msgResponse = restContextResponseWrapper.msgResponse;
            header = restContextResponseWrapper.mapHeader;
        }
    }


    /**
    *  @author       : Simone Trenta - strenta@deloitte.it
    *  @date		 : 28 / 01 / 2019 - LastModified : 
    * @description Do get.
    */
    @HttpGet
    global static void doGet(){ 
        String msgRequest = '';
        String msgResponse = '';
        String logError = '';
        
       	Map<String,String> header = new Map<String,String>();
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Order_U.WrapperGetRequest wrReq = new XC_REST_Order_U.WrapperGetRequest();
        XC_REST_Order_U.WrapperGetResponse wrResp = new XC_REST_Order_U.WrapperGetResponse();

        try {

            header = request.headers;
            String apiKey = request.params.remove('api_key');
            intLog.insertIntegReqInboundLog('Order', JSON.serialize(request.params));
            intLog.setHeader(header);   
            intLog.setTransactionID(header.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod); 
            List<NE__Order__c> orders = new List<NE__Order__c>();

            XC_REST_Order_VVV.validateGETRequest(request , orders, wrResp);
            if(wrResp.Result.ErrorCode == '400'){
                return;
            }
            //UniqueID check
            if(String.isNotBlank(header.get('X-UniqueID'))){
                String idf = '';

                if(String.isNotBlank(request.params.get('OrderID'))){
                    idf = request.params.get('OrderID');
                } else if(String.isNotBlank(request.params.get('AccountID'))){
                    idf = request.params.get('AccountID');
                } else if(String.isNotBlank(request.params.get('OpportunityID'))){
                    idf = request.params.get('OpportunityID');
                }

                XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.wso2AuthCheck(idf, header);
                if(validateResult.errorFlag) {  
                    wrResp.Result.Message = 'ERROR. ' + validateResult.errorMessage;
                    wrResp.Result.ErrorCode = validateResult.errorCode;
                    return;
                }
            }

			XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'read');
            if(responseValidation.errorFlag){
                wrResp.Result.Message = responseValidation.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }           
            
            if(Orders.isEmpty()) {
                wrResp.Result.Message = Label.XC_CL_OrderNotFound;
                wrResp.Result.ErrorCode = '400';
                wrResp.Order = new List<XC_UTIL_Order.OrderIFWrapper>();
                return;
            }
            
            XC_REST_Order_U.readOrders(wrResp, header, orders);

        } catch(exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR'; 
            wrResp.Result.ErrorCode = '500';
            wrResp.Order = null;
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        } finally{
            msgResponse =  JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('CurrencyX','Currency');
            if(wrResp.Result.ErrorCode != '0'){
                wrResp.Order = null;
                if(String.isBlank(logError)) {
                    logError = wrResp.Result.Message;
                }
            }
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = header;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper); 
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            header = restContextResponseWrapper.mapHeader;
        }
    }
}