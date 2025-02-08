/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 23/04/2019 
* @description REST Utility Class for WorkOrder Interface - contain all the validation methods
*/    

public class XC_REST_WorkOrder_VV { 

    /**
     * @description Check read params.
     *
     * @param params the params
     * @param header the header
     * @return the wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult validateReadRequest(Map<string, string> params, Map<String, String> header){

        XC_UTIL_Integration.WrapperResult result = XC_UTIL_RESTInbound.checkObjectPermission('WorkOrder', 'read');
        if(result.errorFlag){
            result.errorMessage = result.errorMessage; 
            result.errorFlag = true;
            return result; 
        } 

        result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag){
            result.errorMessage = result.errorMessage; 
            result.errorFlag = true;
            return result;
        }
        
        if (Header.get('Operation') == XC_REST_WorkOrder.GET_WO_OPERATION_LABEL){ 
            result = checkReadParamsWorkOrder(params);

        } else if (Header.get('Operation') == XC_REST_WorkOrder.GET_APP_OPERATION_LABEL){       
            result = checkReadParamsAppointment(params);
 
        } else {
            result.errorMessage = 'ERROR. Invalid value for field: Header.Operation'; 
            result.errorFlag = true;
            return result;
        }
        
        return result;   
    }

    private static XC_UTIL_Integration.WrapperResult checkReadParamsAppointment(Map<string, string> params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult(); 

        List<String> oneOfTheseFields = new List<String>{  
                'LeadID',    
                'WorkOrderNumber', 
                'WorkOrderID', 
                'OpportunityID', 
                'ServiceAppointmentID' 
                };
                    
        integer ck = 0;
        for(String field : oneOfTheseFields) {
            if(!string.isBlank(params.get(field))) {
                ck ++; 
            }
        }
        if (ck==0) { 
            result.errorMessage = 'ERROR. Missing one of these fields: LeadID, WorkOrderID, WorkOrderNumber, OpportunityID, ServiceAppointmentID';
            result.errorFlag = true;
            return result;
        }
        if (ck>1) { 
            result.errorMessage = 'ERROR. You can only search slots by ONE of these fields: LeadID, WorkOrderID, WorkOrderNumber, OpportunityID, ServiceAppointmentID';
            result.errorFlag = true;
            return result;
        }
            
        if(string.isBlank(params.get('AppointmentSlotDate'))) {
            result.errorMessage = 'ERROR. Missing mandatory field: AppointmentSlotDate';
            result.errorFlag = true;
            return result;
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkDateFields(Map<string, string> params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if (!string.isBlank(params.get('StartDate')) && !string.isBlank(params.get('EndDate'))
            && (!XC_UTIL_RESTInbound.isDateValid(params.get('StartDate')) || !XC_UTIL_RESTInbound.isDateValid(params.get('EndDate')))) {

            result.errorMessage = 'ERROR. Invalid value for fields: StartDate, EndDate';
            result.errorFlag = true;
            return result;
        }

        if (!string.isBlank(params.get('StartDate')) && !string.isBlank(params.get('EndDate'))
            && (date.valueOf(params.get('StartDate')) > date.valueOf(params.get('EndDate')))) { 

            result.errorMessage = 'ERROR. Invalid value for fields: StartDate, EndDate';
            result.errorFlag = true;
            return result;
        }

        return result;
    }

    private static XC_UTIL_Integration.WrapperResult checkReadParamsWorkOrder(Map<string, string> params){
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if (missingWoNumberOrId(params)
            &&
            string.isBlank(params.get('AssetID'))
            &&
            (string.isBlank(params.get('ServiceResourceID')) || string.isBlank(params.get('StartDate')) || string.isBlank(params.get('EndDate')))
            &&
            (string.isBlank(params.get('AccountID')))
            &&
            (string.isBlank(params.get('Email')))
            &&
            (string.isBlank(params.get('OrderId')))) {

            result.errorMessage = 'ERROR. Missing one of these fields: WorkOrderNumber, WorkOrderID, AssetID, ServiceResourceID, AccountID, StartDate, EndDate, OrderId';
            result.errorFlag = true;
            return result;
        }

        result = checkDateFields(params);

        return result;
    }

    private static Boolean missingWoNumberOrId(Map<string, string> params){
        return (string.isBlank(params.get('WorkOrderNumber')) && string.isBlank(params.get('WorkOrderID')));
    }

}