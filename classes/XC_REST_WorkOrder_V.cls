/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 23/04/2019 
* @description REST Utility Class for WorkOrder Interface - contain all the validation methods
*/   
public with sharing class XC_REST_WorkOrder_V {    

    /**
     * @description Check update params.
     *
     * @param params the params
     * @param header the header
     * @return the wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validateUpdateRequest(XC_REST_WorkOrder_W.Wrapper params, Map<String, String> header){

        XC_UTIL_Integration.WrapperResult result = XC_UTIL_RESTInbound.checkObjectPermission('WorkOrder', 'update');
        if(result.errorFlag){
            result.errorMessage = result.errorMessage; 
            result.errorFlag = true;
            return result; 
        } 
                
        result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result;
        }
        
        if (Header.get('Operation') == XC_REST_WorkOrder.PUT_APP_OPERATION_LABEL) {
            result = checkUpdateParamsBookAppointment(params.BookAppointment);
             
        } else if (Header.get('Operation') == XC_REST_WorkOrder.PUT_WO_OPERATION_LABEL) {
            if(params.WorkOrder == null) {
                result.errorMessage = 'ERROR. Missing mandatory field: WorkOrder';
                result.errorFlag = true;
                return result;
            }
            result = checkUpdateParamsWorkOrder(params.WorkOrder);
            
        } else {
            result.errorMessage = 'ERROR. Invalid value for field: Header.Operation'; 
            result.errorFlag = true;
            return result;
        }
         
        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkUpdateParamsWorkOrderWOLI(XC_UTIL_WorkOrder.WorkOrderWrapper wo, WorkOrder wores) {
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if (wo.WorkOrderLineItem == null) {
            return result;
        }

        Set<String> numbFounds = new Set<String>();

        for (WorkOrderLineItem w : woRes.WorkOrderLineItems) {
            numbFounds.add(w.LineItemNumber);
        }
            
        for (XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wli : wo.WorkOrderLineItem) {
            //woli must be related to the given workorder
            if(!String.isBlank(wli.WorkOrderLineItemNumber) && !numbFounds.contains(wli.WorkOrderLineItemNumber)) {
                result.errorMessage = 'ERROR. WorkOrderLineItem not found';
                result.errorFlag = true;
                return result;  
            } 
        }

        return result;
    }
    
    private static XC_UTIL_Integration.WrapperResult checkUpdateParamsWorkOrderSA(XC_UTIL_WorkOrder.WorkOrderWrapper wo, WorkOrder wores) {
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if (wo.serviceappointment == null) {
            return result;
        }

        Set<String> numbFounds = new Set<String>();
        Set<String> idFounds = new Set<String>();

        for (serviceAppointment sa : woRes.ServiceAppointments) {
            numbFounds.add(sa.AppointmentNumber);
            idFounds.add(sa.id);
        }

        for (XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa : wo.serviceappointment) {
            //sa must be related to the given workorder
            if(String.isNotBlank(sa.AppointmentNumber) && !numbFounds.contains(sa.AppointmentNumber)) {                   
                result.errorMessage = 'ERROR. ServiceAppointment not found';
                result.errorFlag = true;
                return result;
            }
            if(String.isNotBlank(sa.ServiceAppointmentID) && !idFounds.contains(sa.ServiceAppointmentID)) {                   
                result.errorMessage = 'ERROR. ServiceAppointment not found';
                result.errorFlag = true;
                return result;
            }
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkUpdateParamsWorkOrder(XC_UTIL_WorkOrder.WorkOrderWrapper wo) {
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        result = XC_REST_WorkOrder_VVV.validateWorkType(wo);
        
        if (String.isBlank(wo.WorkOrderNumber) && String.isBlank(wo.WorkOrderID)) {
            result.errorMessage = 'ERROR. Missing one of these fields: WorkOrder.WorkOrderNumber, WorkOrder.WorkOrderID';
            result.errorFlag = true;
            return result;
        }
        
        List<WorkOrder> woList = String.isBlank(wo.WorkOrderNumber) ? XC_REST_WorkOrder_U_D.getWorkOrderById(wo.WorkOrderID) : XC_REST_WorkOrder_U_D.getWorkOrderByNumber(wo.WorkOrderNumber);
        if(woList.size()==0) {
            result.errorMessage = 'ERROR. WorkOrder not found';  
            result.errorFlag = true;
            return result;
        }
        
        WorkOrder woRes = woList[0];
        if( !String.isBlank(wo.ParentWorkOrderNumber) && [SELECT id FROM WorkOrder WHERE WorkOrderNumber =: wo.ParentWorkOrderNumber].size()==0) {
            result.errorMessage = 'ERROR. ParentWorkOrder not found';
            result.errorFlag = true;
            return result; 
        }   

        result = checkUpdateParamsWorkOrderSA(wo, wores);
        if (result.errorFlag) {
            return result;
        }
        
        result = checkUpdateParamsWorkOrderWOLI(wo, wores);
        if (result.errorFlag) {
            return result;
        }
        
        return result; 
    }
    
    private static XC_UTIL_Integration.WrapperResult checkUpdateParamsBookAppointment(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bookAppointment) {
        
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();
        
        if(bookAppointment == null) {
            result.errorMessage = 'ERROR. Missing mandatory field: BookAppointment'; 
            result.errorFlag = true;
            return result;
        }
        
        Map<String, Object> fields = new Map<String, Object>{ 
                'ServiceAppointmentID' => BookAppointment.ServiceAppointmentID, 
                'StartDate' => BookAppointment.StartDate, 
                'TimeSlotBegin' => BookAppointment.TimeSlotBegin, 
                'TimeSlotFinish' => BookAppointment.TimeSlotFinish };

        for(String field : fields.KeySet()) {
            if( fields.get(field) == null || (fields.get(field)+'') == '') {
                result.errorMessage = 'ERROR. Missing mandatory field: BookAppointment.'+field;
                result.errorFlag = true;
                return result;
            } 
        }
        
        return result;   
    }

}