/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 28/12/2018 
* @description REST INTERFACE : WorkOrder Object  
*/   
@RestResource(urlMapping='/v1/WorkOrder/*')   
global without sharing class XC_REST_WorkOrder {       
    
    /** Value for Header.Operation field in case of Getting WorkOrder */
    public static final String GET_WO_OPERATION_LABEL = 'ReadWorkOrder'; 
    
    /** Value for Header.Operation field in case of Getting Slots */
    public static final String GET_APP_OPERATION_LABEL = 'ReadAppointmentSlots';
     
    /** Value for Header.Operation field in case of Getting Slots (MC) */
    public static final String GET_APP_OPERATION_LABEL_MC = 'ReadAppointmentSlotsMC';
    
    /** Value for Header.Operation field in case of Creating WorkOrder */
    public static final String POST_WO_OPERATION_LABEL = 'CreateWorkOrder';
    
    /** Value for Header.Operation field in case of Scheduling Appointment */
    public static final String POST_APP_OPERATION_LABEL = 'ScheduleAppointment';
    
    /** Value for Header.Operation field in case of Updating WorkOrder */
    public static final String PUT_WO_OPERATION_LABEL = 'UpdateWorkOrder';
    
    /** Value for Header.Operation field in case of Editing Appointment */
    public static final String PUT_APP_OPERATION_LABEL = 'EditAppointment';
    
    /** Value for Header.Operation field in case of Editing Appointment (MC) */
    public static final String PUT_APP_OPERATION_LABEL_MC = 'EditAppointmentMC';



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
        Map<String,String> header = request.headers; 
        XC_UTIL_IntegrationLog intLog = insertLog(header);
        
        try {
            
            XC_UTIL_Integration.WrapperResult result = XC_REST_WorkOrder_VV.validateReadRequest(request.params, header);
            if(result.errorFlag){
                wrResp.Result.Message = result.errorMessage; 
                wrResp.Result.ErrorCode = result.errorCode!='401'&&result.errorCode!='402'?'400':result.errorCode;
                setGetResponse(wrResp, header, logError, intLog);
                return;
            } 

            /******************************************** Get WorkOrder ********************************************/
            if(header.get('Operation') == GET_WO_OPERATION_LABEL) {
            /************************************************ ******************************************************/

                List<XC_UTIL_WorkOrder.WorkOrderWrapper> wolist = XC_REST_WorkOrder_UU.readWorkOrder(request.params, header.get('ClientSystem')); 
                wrResp.WorkOrder = wolist;


                //fis ST . tbd
                if(header.get('ClientSystem')!='XInstaller'){
                    for(XC_UTIL_WorkOrder.WorkOrderWrapper w:wolist){
                        for(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper s:w.ServiceAppointment){
                            s.CreatedDate = null;
                        }
                    } 
                }

            
                if(wolist.size()==0){ 
                    wrResp.Result.Message = 'ERROR. WorkOrder' + Label.XC_CL_NotFount; 
                    wrResp.Result.ErrorCode = '400';

                } else {      
                    wrResp.Result.Message = 'Operation completed successfully'; 
                    wrResp.Result.ErrorCode = '0';
                    
                    //fix 16/07/2020
                    if(header.get('ClientSystem')!='XInstaller'){
                        for(XC_UTIL_WorkOrder.WorkOrderWrapper w : wolist){
                            if(w.ServiceAppointment!=null){
                            	for(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper s : w.ServiceAppointment){
                                	s.CreatedDate = null;
                            	}
                            }
                        }
                    }
                }

                setGetResponse(wrResp, header, logError, intLog);
                return;

            /******************************************** Get Slots ********************************************/
            } else if ( header.get('Operation') == GET_APP_OPERATION_LABEL ) { //|| header.get('Operation') == GET_APP_OPERATION_LABEL_MC ) {
            /************************************************ **************************************************/
                    
                XC_UTIL_Schedule.BookingResult bookRes = XC_REST_WorkOrder_S.ReadSlots(request.params);

                if(bookRes.success) { 
                    wrResp.AppointmentSlots = XC_REST_WorkOrder_W.createWrapperSlot(bookRes.Slots, DateTime.valueOf(request.params.get('AppointmentSlotDate')+' 00:00:00'), bookRes.dueDate);
                    wrResp.ReadAppointmentSlots = new XC_REST_WorkOrder_W.GetAppointmentWrapper();
                    wrResp.ReadAppointmentSlots.WorkOrderNumber = bookRes.WorkOrderNumber;
                    wrResp.ReadAppointmentSlots.ServiceAppointmentID = request.params.get('ServiceAppointmentID'); 
                    wrResp.ReadAppointmentSlots.LeadID = request.params.get('LeadID'); 
                    wrResp.ReadAppointmentSlots.OpportunityID = request.params.get('OpportunityID'); 
                    wrResp.Result.Message = 'Operation completed successfully'; 
                    wrResp.Result.ErrorCode = '0';
                    setGetResponse(wrResp, header, logError, intLog);
                    return;
                }  
                
                if(bookRes.IntegrationError!='') { 
                    wrResp.Result.Message = bookRes.IntegrationError; 
                    wrResp.Result.ErrorCode = '400';
                    setGetResponse(wrResp, header, bookRes.IntegrationError, intLog);
                    return;

                } else {
                    wrResp.Result.Message = 'INTERNAL ERROR'; 
                    wrResp.Result.ErrorCode = '500';
                    setGetResponse(wrResp, header, bookRes.message, intLog);
                    return;
                }        
            } 
        
        } catch(exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR'; 
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
            restContextResponseWrapper.mapHeader = header;
            restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), JSON.serialize(wrResp, true), logError);
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            RestContext.response = restContextResponseWrapper.res;  
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
        Map<String,String> header = request.headers;
        XC_UTIL_IntegrationLog intLog = insertLog(header);
        System.Savepoint beforeInsertSavepoint = null;
        
        try {
            
            msgRequest = request.requestbody.tostring();
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);
            XC_UTIL_Integration.WrapperResult check = XC_REST_WorkOrder_VVV.validateCreateRequest(wrReq, header);
            if(check.errorFlag) {
                wrResp.result.message = check.errorMessage;
                wrResp.Result.ErrorCode = check.errorCode!='401'&&check.errorCode!='402'?'400':check.errorCode;
                setResponse(wrResp, header, logError, intLog);
                return;
            } 

            /************************ Work Order Creation ********************************/
            if( header.get('Operation') == POST_WO_OPERATION_LABEL) {
            /***************************** ***********************************************/ 
                beforeInsertSavepoint = Database.setSavepoint();
                wrReq.WorkOrder.WorkType = XC_UTIL_WorkType.getWorkTypeByNameAndLE(wrReq.WorkOrder.WorkType, wrReq.WorkOrder.LegalEntity);

                WorkOrder wo = new WorkOrder();
                wo.XC_CreatedAutomaticallyBySystem__c = true;

                workOrder resWo = XC_REST_WorkOrder_U.createWorkOrder(wrReq.WorkOrder, wo);
                XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.insertrecord(resWo);
                if(!resInsertWO.success) {
                    wrResp.result.message = 'INTERNAL ERROR';
                    wrResp.result.errorCode = '500'; 
                    logError = 'Error on insert WorkOrder: '+resInsertWO.errorMessage;
                    setResponse(wrResp, header, logError, intLog);
                    return;

                } else {            
                    wrResp.workorder = new XC_UTIL_WorkOrder.WorkOrderWrapper();
                    wrResp.workorder.WorkOrderNumber = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: resInsertWO.recordid][0].WorkOrderNumber ;  
                    wrResp.workorder.WorkOrderID = resInsertWO.recordid;
                    wrResp.workorder.WorkType = resWo.WorkType.Name;
                    wrResp.workOrder.status = resWo.status; 
                    wrResp.workOrder.AccountID = resWo.AccountId;
                    wrResp.WorkOrder.AssetID = resWo.AssetID;
                    wrResp.WorkOrder.Comments = resWo.XC_Comments__c;
                }
                
                list<workOrderLineItem> resWl = XC_REST_WorkOrder_U.createWorkOrderLine(wrReq.WorkOrder.WorkOrderLineItem, resWo.id);
                list<ServiceAppointment> resSa = XC_REST_WorkOrder_U.createServiceAppointment(wrReq.WorkOrder.ServiceAppointment, resWo.id);

                List<SObject> toIns = new List<SObject>(); 
                toIns.addAll(resSa);
                toIns.addAll(resWl);
 
                List<XC_UTIL_Sobject.WrapperResult> resInsert = XC_UTIL_Sobject.insertListRecords(toIns);
                for(XC_UTIL_Sobject.WrapperResult msg : resInsert) {
                    if(!msg.success) {
                        wrResp.result.message = 'INTERNAL ERROR';
                        wrResp.result.errorCode = '500';
                        logError = 'Error on insert: '+msg.errorMessage;
                        Database.rollback(beforeInsertSavepoint);
                        setResponse(wrResp, header, 'Error on insert: '+msg.errorMessage, intLog);
                        return;
                    } 
                }

                wrResp.workOrder.WorkOrderLineItem = XC_REST_WorkOrder_U.getWoliWrapperList(resWl);
                wrResp.workOrder.ServiceAppointment = XC_REST_WorkOrder_U.getServAppWrapperList(resSa);
                wrResp.result.message = 'Operation completed successfully';
                wrResp.result.errorCode = '0';
                setResponse(wrResp, header, logError, intLog);
                return; 

            /****************** Book Appointment *****************************************/
            } else if( header.get('Operation') == POST_APP_OPERATION_LABEL) { 
            /******************************* *********************************************/
                
                XC_UTIL_Schedule.BookingResult bookingResult = XC_REST_WorkOrder_S.ScheduleAppointment(wrReq.BookAppointment);
                wrResp = manageBookingResult(bookingResult, wrReq);
                setResponse(wrResp, header, logError, intLog);
                return;

            }
            
        } catch(exception e) {
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.errorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            if(beforeInsertSavepoint != null) {
                Database.rollback(beforeInsertSavepoint);
            }
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), JSON.serialize(wrResp, true), logError);
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
            restContextResponseWrapper.mapHeader = header;
            restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            RestContext.response = restContextResponseWrapper.res;  
            return;
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
        RestRequest request = RestContext.request;
        
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
        Map<String,String> header = request.headers;
        XC_UTIL_IntegrationLog intLog = insertLog(header);
        System.Savepoint beforeUpdateSavepoint = Database.setSavepoint();
        
        try {
            msgRequest = request.requestbody.tostring();
            
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);    
            
            XC_UTIL_Integration.WrapperResult check = XC_REST_WorkOrder_V.validateUpdateRequest(wrReq, header);
            if(check.errorFlag) {
                wrResp.result.message = check.errorMessage;
                wrResp.result.errorCode = '400';
                setResponse(wrResp, header, logError, intLog);
                return;
            }   
                        
            /****************** Update WorkOrder *****************************************/
            if(header.get('Operation') == PUT_WO_OPERATION_LABEL){ 
            /************************* ****************************************************/
            
                wrReq.WorkOrder.WorkType = XC_UTIL_WorkType.getWorkTypeByName(wrReq.WorkOrder.WorkType);
                
                WorkOrder woToMod = XC_REST_WorkOrder_UU.getWorkOrderForUpdate(wrReq);  
                
                /* Update WorkOrder */
                workOrder resWo = XC_REST_WorkOrder_U.createWorkOrder(wrReq.WorkOrder, woToMod);

                resWo.XC_UpdatedByApp__c = (header.get('ClientSystem')=='XInstaller');

                XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.updaterecord(resWo);
                if(!resInsertWO.success) {
                    wrResp.result.message = 'INTERNAL ERROR';
                    wrResp.result.errorCode = '500';
                    logError = 'Error on update WorkOrder' + resInsertWO.errorMessage;
                    setResponse(wrResp, header, logError, intLog);
                    return;
                    
                } else {
                    wrResp.workorder = new XC_UTIL_WorkOrder.WorkOrderWrapper();
                    wrResp.workorder.WorkOrderID = resWo.id;
                    wrResp.workorder.WorkOrderNumber = resWo.WorkOrderNumber;
                    wrResp.workorder.WorkType = resWo.WorkType.Name;
                    wrResp.workOrder.status = resWo.status;
                    wrResp.workOrder.AccountID = resWo.AccountId;
                    wrResp.WorkOrder.AssetID = resWo.AssetID;
                    wrResp.WorkOrder.Comments = resWo.XC_Comments__c;
                }

                for(WorkOrderLineItem woli : woToMod.WorkOrderLineItems) {
                    woli.XC_UpdatedByApp__c = (header.get('ClientSystem')=='XInstaller');
                }
                list<workOrderLineItem> resWl = XC_REST_WorkOrder_U.updateOrCreateWorkOrderLine(wrReq.WorkOrder.WorkOrderLineItem, resWo.id, woToMod.WorkOrderLineItems);
                list<ServiceAppointment> resSa = XC_REST_WorkOrder_U.updateOrCreateServiceAppointment(wrReq.WorkOrder.ServiceAppointment, resWo.id, woToMod.ServiceAppointments);

                List<SObject> toIns = new List<SObject>(); 
                toIns.addAll(resSa);
                toIns.addAll(resWl); 

                List<XC_UTIL_Sobject.WrapperResult> resInsert = XC_UTIL_Sobject.upsertListRecords(toIns);
                for(XC_UTIL_Sobject.WrapperResult msg : resInsert) {
                    if(!msg.success) {
                        wrResp.result.message = 'INTERNAL ERROR';
                        wrResp.result.errorCode = '500';
                        logError = 'Error on upsert: '+msg.errorMessage;
                        Database.rollback(beforeUpdateSavepoint);
                        setResponse(wrResp, header, logError, intLog);
                        return;
                    }
                }

                wrResp.workOrder.WorkOrderLineItem = XC_REST_WorkOrder_U.getWoliWrapperList(resWl);  
                wrResp.workOrder.serviceAppointment = XC_REST_WorkOrder_U.getServAppWrapperList(resSa);
                wrResp.result.message = 'Operation completed successfully';
                wrResp.result.errorCode = '0';   
                setResponse(wrResp, header, logError, intLog); 
                return;
                
            /****************** Reschedule Appointment *****************************************/
            } else if (header.get('Operation') == PUT_APP_OPERATION_LABEL) { //|| header.get('Operation') == PUT_APP_OPERATION_LABEL_MC) { 
            /**************************** ******************************************************/
                    
                XC_UTIL_Schedule.BookingResult bookingResult = XC_REST_WorkOrder_S.ScheduleAppointment(wrReq.BookAppointment);   
                wrResp = manageBookingResult(bookingResult, wrReq);
                setResponse(wrResp, header, logError, intLog);
                return; 
                    
            }
            
        } catch(exception e){
            wrResp.result.message = 'INTERNAL ERROR';
            wrResp.result.errorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            Database.rollback(beforeUpdateSavepoint);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), JSON.serialize(wrResp, true), logError);
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
            restContextResponseWrapper.mapHeader = header;
            restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            RestContext.response = restContextResponseWrapper.res;  
            return;
        } 
    }



    /**
     * @description Handle the response of the schedule class
     * @param bookingResult
     * @param wrReq
     * @return the wrapper response
     */
    private static XC_REST_WorkOrder_W.Wrapper manageBookingResult(XC_UTIL_Schedule.BookingResult bookingResult,  XC_REST_WorkOrder_W.Wrapper wrReq){
        XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();
 
        if(bookingResult.success) {
            wrResp.bookAppointment = XC_REST_WorkOrder_W.getBookAppWrapper(wrReq, bookingResult); 
            wrResp.result.message = 'Operation completed successfully';
            wrResp.result.errorCode = '0';

        } else if(bookingResult.IntegrationError!='') {
            wrResp.result.message = bookingResult.IntegrationError;
            wrResp.result.errorCode = '400';

        } else {
            wrResp.result.message = 'INTERNAL ERROR: '+bookingResult.message;
            wrResp.result.errorCode = '500';
        }             

        return wrResp;
    }


     
    private static XC_UTIL_IntegrationLog insertLog(Map<String, String> header){
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog(); 

        if(RestContext.request.httpMethod == 'GET'){
            intLog.insertIntegReqInboundLog('WorkOrder', JSON.serialize(RestContext.request.params));
        } else {
            intLog.insertIntegReqInboundLog('WorkOrder', RestContext.request.requestbody.tostring());
        }
        
        intLog.setHeader(header); 
        intLog.setTransactionID(header.get('TransactionID'));
        intLog.setHttpMethod(RestContext.request.httpMethod);

        return intLog;
    }



    /**
     * @description Sets the response.
     *
     * @param wrResp the response to set
     * @param header the header
     * @param logError the log error description
     */
    private static void setGetResponse(XC_REST_WorkOrder_W.GetResultWrapper wrResp, Map<String, String> header, String logError, XC_UTIL_IntegrationLog intLog){
 
        if (logError == Label.XC_CL_Schedule_NoSlot) {
            wrResp.AppointmentSlots = new List<XC_REST_WorkOrder_W.WrapperSlot>();
            wrResp.Result.Message = 'INTERNAL ERROR: No Slots found';
            wrResp.Result.ErrorCode = '452'; 
        } 

        if (wrResp.result.errorCode != '0') {
            wrResp.workOrder = null;
            intLog.insertIntegRespInboundLog(wrResp.result.errorCode, false, JSON.serialize(wrResp, true), logError);
            if(logError!='' && logError!=Label.XC_CL_Schedule_NoSlot){
                wrResp.Result.message +=': '+ logError;
            }
        } else {
            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(wrResp, true), logError);
        }

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
        restContextResponseWrapper.mapHeader = header;
        restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode;
        XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        RestContext.response = restContextResponseWrapper.res;  
        return; 
    }



    /**
     * @description Sets the response.
     *
     * @param wrResp the wr resp
     * @param header the header
     * @param logError the log error
     */
    private static void setResponse(XC_REST_WorkOrder_W.Wrapper wrResp, Map<String, String> header, String logError, XC_UTIL_IntegrationLog intLog){
        
        if (wrResp.result.errorCode != '0') {
            wrResp.workOrder = null;
            wrResp.AppointmentSlots = null; 
            wrResp.BookAppointment = null;
            intLog.insertIntegRespInboundLog(wrResp.result.errorCode, false, JSON.serialize(wrResp, true), logError); 
            if(logError!=''){
                wrResp.Result.message +=': '+ logError;
            }
        
        } else{
            if(wrResp.WorkOrder != null){
                if (wrResp.WorkOrder.WorkOrderLineItem != null && wrResp.WorkOrder.WorkOrderLineItem.isEmpty()){
                    wrResp.WorkOrder.WorkOrderLineItem = null;
                }
                if(wrResp.WorkOrder.ServiceAppointment != null && wrResp.WorkOrder.ServiceAppointment.isEmpty()){
                    wrResp.WorkOrder.ServiceAppointment = null;
                }
                XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
                lw.workOrderID = wrResp.WorkOrder.WorkOrderID;
                intLog.setAdditionalInformations(lw);
            } 

            intLog.insertIntegRespInboundLog('200', true, JSON.serialize(wrResp, true), logError);
        }

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = JSON.serialize(wrResp, true);
        restContextResponseWrapper.mapHeader = header;
        restContextResponseWrapper.errorCode = (wrResp.Result.ErrorCode == '0') ? '200' : wrResp.Result.ErrorCode; 
        XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        RestContext.response = restContextResponseWrapper.res;
        return; 
    } 


}