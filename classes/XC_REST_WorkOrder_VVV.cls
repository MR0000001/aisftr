/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 23/04/2019 
* @description REST Utility Class for WorkOrder Interface - contain all the validation methods
*/   

public with sharing class XC_REST_WorkOrder_VVV {
    
    /**
     * @description Check create params.
     *
     * @param params the params
     * @param header the header
     * @return the wrapper result 
     */
    public static XC_UTIL_Integration.WrapperResult validateCreateRequest(XC_REST_WorkOrder_W.Wrapper params, Map<String, String> header){

        XC_UTIL_Integration.WrapperResult result = XC_UTIL_RESTInbound.checkObjectPermission('WorkOrder', 'create');
        if(result.errorFlag){
            result.errorMessage = result.errorMessage; 
            result.errorFlag = true;
            return result; 
        } 
                
        result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result;
        }
        
        if (header.get('Operation') == XC_REST_WorkOrder.POST_WO_OPERATION_LABEL){
            if(params.workorder == null){
                result.errorMessage = 'ERROR. Missing mandatory field: WorkOrder';
                result.errorFlag = true;
                return result; 
            }
            result = checkCreateParamsWorkOrder(params);

        } else if(header.get('Operation') == XC_REST_WorkOrder.POST_APP_OPERATION_LABEL) {
            if(params.BookAppointment == null){
                result.errorMessage = 'ERROR. Missing mandatory field: BookAppointment';
                result.errorFlag = true;
                return result; 
            }
            result = checkCreateParamsAppointment(params);

        } else {
            result.errorMessage = 'ERROR. Invalid value for field: Header.Operation';   
            result.errorFlag = true;
            return result;
        }
        
        return result;
    }

    /**
     * @description Check work type field.
     *
     * @param wo the params
     * @return the wrapper result 
     */
    public static XC_UTIL_Integration.WrapperResult validateWorkType(XC_UTIL_WorkOrder.WorkOrderWrapper wo){ 
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        String workTypeId = XC_UTIL_WorkType.getWorkTypeByName(wo.WorkType);
        if(workTypeId == '' && String.isNotBlank(wo.WorkType)) {
            result.errorMessage = 'ERROR. Invalid value for WorkOrder.WorkType';
            result.errorFlag = true;
            return result;
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkCreateParamsAppointment(XC_REST_WorkOrder_W.Wrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

            integer ck = 0;

            Map<String, Object> oneOfThisfields = new Map<String, Object>{ 
                'WorkOrderId' => params.BookAppointment.WorkOrderId, 
                'LeadID' => params.BookAppointment.LeadID, 
                'OpportunityID' => params.BookAppointment.OpportunityID };

            for(String field : oneOfThisfields.KeySet()) {
                if( oneOfThisfields.get(field) != null && oneOfThisfields.get(field)+'' != '') { 
                    ck++;
                } 
            }

            if (ck==0){
                result.errorMessage = 'ERROR. Missing one of these Fields: BookAppointment.LeadID, BookAppointment.WorkOrderId, BookAppointment.OpportunityID';
                result.errorFlag = true;
                return result;
            }

            if (ck>1) { 
                result.errorMessage = 'You can only book appointment by ONE of these fields: LeadID, WorkOrderNumber, OpportunityID';
                result.errorFlag = true;
                return result;
            }
            
            Map<String, Object> fields = new Map<String, Object>{ 
                'StartDate' => params.BookAppointment.StartDate, 
                'TimeSlotBegin' => params.BookAppointment.TimeSlotBegin, 
                'TimeSlotFinish' => params.BookAppointment.TimeSlotFinish };

            for(String field : fields.KeySet()) {
                if( fields.get(field) == null || fields.get(field)+'' == '') { 
                    result.errorMessage = 'ERROR. Missing mandatory field: BookAppointment.'+field;
                    result.errorFlag = true;
                    return result;
                }
            }

        return result;
    } 

    private static XC_UTIL_Integration.WrapperResult checkCreateParamsWorkorder(XC_REST_WorkOrder_W.Wrapper params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if (String.isBlank(params.workorder.WorkType)) {
            result.errorMessage = 'ERROR. Missing mandatory field: WorkOrder.WorkType'; 
            result.errorFlag = true;
            return result;
        } 

        result = validateWorkType(params.WorkOrder);

        if (String.isBlank(params.workorder.LegalEntity)) { 
            result.errorMessage = 'ERROR. Missing mandatory field: WorkOrder.LegalEntity'; 
            result.errorFlag = true;
            return result;
        } 
          
        if( !String.isBlank(params.workorder.ParentWorkOrderNumber) && [SELECT id FROM WorkOrder WHERE WorkOrderNumber =: params.workorder.ParentWorkOrderNumber].size()==0) { 
            result.errorMessage = 'ERROR. ParentWorkOrder not found';
            result.errorFlag = true;
            return result;   
        }

        if ( params.workorder.serviceappointment!=null ) {
            for (XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa : params.workorder.serviceappointment) {
                if (sa.EarliestStartPermitted==null) {
                    result.errorMessage = 'ERROR. Missing mandatory field: ServiceAppointment.EarliestStartPermitted';
                    result.errorFlag = true;
                    return result;
                }
                if (sa.DueDate==null) {
                    result.errorMessage = 'ERROR. Missing mandatory field: ServiceAppointment.DueDate';
                    result.errorFlag = true;
                    return result;
                }
            }
        }
        return result;
    } 

}