/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 28/12/2018 
* @description REST INTERFACE : WorkOrder Object 
*/   
@RestResource(urlMapping='/v1/WorkOrderMC/*')   
global without sharing class XC_REST_WorkOrder_MC {       

    /** Value for Header.Operation field in case of Getting Slots (MC) */
    public static FINAL String GET_APP_OPERATION_LABEL_MC = 'ReadAppointmentSlotsMC';
    
    /** Value for Header.Operation field in case of Editing Appointment (MC) */
    public static FINAL String PUT_APP_OPERATION_LABEL_MC = 'EditAppointmentMC';

    /** Value for Header.Operation field in case of Scheduling Appointment */
    public static FINAL String POST_APP_OPERATION_LABEL = 'ScheduleAppointment';

    /**
    * @description handle the Get request
    */
    @HttpGet 
    global static void doGet() { 
        String requestURL = '';    
        String msgResponse = ''; 
        String logError = ''; 
        RestRequest request = RestContext.request;
        
        XC_REST_WorkOrder_W.GetResultWrapper wrResp = new XC_REST_WorkOrder_W.GetResultWrapper(); 
        Map<String,String> header = new Map<String,String>(); 
        
        try {
            header = request.headers;           
            String apiKey = request.params.remove('api_key');
            
            XC_UTIL_Integration.WrapperResult result = XC_REST_WorkOrder_VV.validateReadRequest(request.params, header);
            if(result.errorFlag){
                wrResp.Result.Message = result.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                setGetResponse(wrResp, header, result.errorMessage);
                return;
            } 

            /******************************************** Get Slots ********************************************/
            if (header.get('Operation') == GET_APP_OPERATION_LABEL_MC ) {
            /************************************************ **************************************************/
                    
                XC_UTIL_Schedule.BookingResult bookRes = XC_REST_WorkOrder_S.ReadSlots(request.params);

                if(bookRes.success) {
                    wrResp.AppointmentSlots = XC_REST_WorkOrder_W.createWrapperSlot(bookRes.Slots, DateTime.valueOf(request.params.get('AppointmentSlotDate')+' 00:00:00'),bookRes.DueDate);
                    wrResp.ReadAppointmentSlots = new XC_REST_WorkOrder_W.GetAppointmentWrapper();
                    wrResp.ReadAppointmentSlots.WorkOrderNumber = request.params.get('WorkOrderNumber');
                    wrResp.ReadAppointmentSlots.WorkOrderID = request.params.get('WorkOrderID');  
                    wrResp.ReadAppointmentSlots.ServiceAppointmentID = request.params.get('ServiceAppointmentID'); 
                    wrResp.ReadAppointmentSlots.LeadID = request.params.get('LeadID'); 
                    wrResp.ReadAppointmentSlots.OpportunityID = request.params.get('OpportunityID'); 
                    wrResp.Result.Message = 'Operation completed successfully'; 
                    wrResp.Result.ErrorCode = '0';
                    setGetResponse(wrResp, header, logError);
                    return;
                } 
                
                if(bookRes.IntegrationError!='') { 
                    wrResp.Result.Message = bookRes.IntegrationError; 
                    wrResp.Result.ErrorCode = '400';
                    logError = bookRes.message;
                    setGetResponse(wrResp, header, logError+' '+bookRes.IntegrationError);
                    return;

                } else {
                    wrResp.Result.Message = 'INTERNAL ERROR'; 
                    wrResp.Result.ErrorCode = '500';
                    logError = bookRes.message;
                    setGetResponse(wrResp, header, logError+' '+bookRes.IntegrationError);
                    return;
                }               

            } 
        
        } catch(exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR'; 
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            setGetResponse(wrResp, header, logError);
            return;
            
        } 
    }
    
    /**
    * @description handle the Post request
    */
    @HttpPost
    global static void doPost() {
        
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        RestRequest request = RestContext.request;
        
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
        Map<String,String> header = new Map<String,String>();
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        
        try {
            header = request.headers;
            
            // If it is a request coming from MC, handle as GET 
            if(header.get('Operation') == GET_APP_OPERATION_LABEL_MC) {
                doGet();
                return;

            } else if(header.get('Operation') == PUT_APP_OPERATION_LABEL_MC) {
                doPut();
                return;
            }

            msgRequest = request.requestbody.tostring();
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);
            
            XC_UTIL_Integration.WrapperResult check = XC_REST_WorkOrder_VVV.validateCreateRequest(wrReq, header);
            if(check.errorFlag) {
                wrResp.result.message = check.errorMessage;
                wrResp.result.errorCode = '400';
                setResponse(wrResp, header, check.errorMessage);
                return;
            } 

           
            if( header.get('Operation') == POST_APP_OPERATION_LABEL) { 
            /******************************* *********************************************/
                
                XC_UTIL_Schedule.BookingResult bookingResult = XC_REST_WorkOrder_S.ScheduleAppointment(wrReq.BookAppointment);
                wrResp = manageBookingResult(bookingResult, wrReq, header);
                return;

            }
            
        } catch(exception e) {
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.errorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            setResponse(wrResp, header, logError);
            return;

        } finally {                
            if(wrResp.Result.ErrorCode != '0' && header.get('Operation') == POST_APP_OPERATION_LABEL){
                Database.rollback(beforeInsertSavepoint);
            }        
        }
    }
    
    /**
    * @description handle the Put request
    */
    @HttpPut
    global static void doPut() {
        
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = '';  
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
        Map<String,String> header = new Map<String,String>();
        System.Savepoint beforeUpdateSavepoint = Database.setSavepoint();
        
        try {
            header=request.headers;
            msgRequest = request.requestbody.tostring();
            
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);
            intLog.insertIntegReqInboundLog('WorkOrder', msgRequest);
            intLog.setTransactionID(header.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            XC_UTIL_Integration.WrapperResult check = XC_REST_WorkOrder_V.validateUpdateRequest(wrReq, header);
            if(check.errorFlag) {
                wrResp.result.message = check.errorMessage;
                wrResp.result.errorCode = '400';
                setResponse(wrResp, header, check.errorMessage);
                return;

            }   
                        
            /****************** Update WorkOrder *****************************************/
            if (header.get('Operation') == PUT_APP_OPERATION_LABEL_MC) { 
            /**************************** ******************************************************/
                XC_UTIL_Schedule.BookingResult bookingResult = XC_REST_WorkOrder_S.ScheduleAppointment(wrReq.BookAppointment);   
                wrResp = manageBookingResult(bookingResult, wrReq, header);
                return;    
            }
            
        } catch(exception e){
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.errorCode = '500';
            setResponse(wrResp, header, logError);
            return;

        } finally {
            if(wrResp.Result.ErrorCode != '0'){
                Database.rollback(beforeUpdateSavepoint);
            }        
        }
    }

    /**
     * @description Handle the response of the schedule class
      * @param bookingResult
     * @param wrReq
     * @param header 
     * @return the wrapper response
     */
    private static XC_REST_WorkOrder_W.Wrapper manageBookingResult(XC_UTIL_Schedule.BookingResult bookingResult,  XC_REST_WorkOrder_W.Wrapper wrReq, Map<String, String> header){
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
 
        if(bookingResult.success) {
            wrResp.bookAppointment = XC_REST_WorkOrder_W.getBookAppWrapper(wrReq, bookingResult); 
            wrResp.result.message = 'Operation completed successfully';
            wrResp.result.errorCode = '0';
            setResponse(wrResp, header, '');  
            return wrResp;
        } 

        if(bookingResult.IntegrationError!='') {
            wrResp.result.message = bookingResult.IntegrationError;
            wrResp.result.errorCode = '400';
            setResponse(wrResp, header, bookingResult.IntegrationError);

        } else {
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.errorCode = '500';
            setResponse(wrResp, header, bookingResult.message);
        }             

        return wrResp;
    }
     
    /**
     * @description Sets the response.
     *
     * @param wrResp the response to set
     * @param header the header
     * @param logError the log error description
     */
    private static void setGetResponse(XC_REST_WorkOrder_W.GetResultWrapper wrResp, Map<String, String> header, String logError){
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 

        intLog.insertIntegReqInboundLog('WorkOrder', JSON.serialize(RestContext.request.params));
        intLog.setTransactionID(header.get('TransactionID'));
        intLog.setHttpMethod(RestContext.request.httpMethod);

        if (wrResp.result.errorCode != '0') {
            wrResp.workOrder = null;
            wrResp.AppointmentSlots = null;
            intLog.insertIntegRespInboundLog(wrResp.result.errorCode, false, JSON.serialize(wrResp, true), logError);

        } else {
            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(wrResp, true), logError);
        
        }

        if (string.isNotBlank(header.get('debugMode'))) { 
            wrResp.Result.message +=' '+ logError;
        }   

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
        restContextResponseWrapper.mapHeader = header;
        restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
        XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        RestContext.response = restContextResponseWrapper.res;
        header = restContextResponseWrapper.mapHeader;        
        return; 
    }

    /**
     * @description Sets the response.
     *
     * @param wrResp the wr resp
     * @param header the header
     * @param logError the log error
     */
    private static void setResponse(XC_REST_WorkOrder_W.Wrapper wrResp, Map<String, String> header, String logError){
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 
        
        intLog.insertIntegReqInboundLog('WorkOrder', RestContext.request.requestbody.tostring());
        intLog.setTransactionID(header.get('TransactionID'));
        intLog.setHttpMethod(RestContext.request.httpMethod);
        
        if (wrResp.result.errorCode != '0') {
            wrResp.workOrder = null;
            wrResp.AppointmentSlots = null; 
            wrResp.BookAppointment = null;
            intLog.insertIntegRespInboundLog(wrResp.result.errorCode, false, JSON.serialize(wrResp, true), logError);
        
        } else{
            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(wrResp, true), logError);
        
        }

        if (string.isNotBlank(header.get('debugMode'))) {
            wrResp.Result.message +=' '+ logError; 
        } 

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
        restContextResponseWrapper.mapHeader = header;
        restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
        XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        RestContext.response = restContextResponseWrapper.res;
        header = restContextResponseWrapper.mapHeader;
        return; 
    }

}