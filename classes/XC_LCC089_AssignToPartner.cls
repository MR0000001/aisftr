/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 09/02/2021
* @description XC_LCC089_AssignToTechnicians - Apex Controller for XC_LCP089_AssignToTechnicians Component
*/

public without sharing class XC_LCC089_AssignToPartner {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC089_AssignToPartner');
    
    /** @description ResultWrapper */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String result = '';
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 09/02/2021
     * @description Method to assign WO to Partner
     * @param recordId - String
     * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper assignToPartner(Id recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ In assignToPartner method of Apex Controller LCC089');
        ResultWrapper rw = new ResultWrapper();
        rw.result = Label.XC_CL_WorkOrder_Assigned;
        rw.success = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Initial result wrapper: ' + rw);

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([
            SELECT Id, XC_WorkTypelabel__c, XC_Country__c, XC_WorkTypeCategory__c,
                (SELECT Id, Status 
                FROM ServiceAppointments
                WHERE Status = :Label.XC_CL_ServiceAppointment_None)
            FROM WorkOrder 
            WHERE Id =: recordId
        ]);
        WorkOrder wo = woMap.values();      
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ WorkOrder to re-assign -> ' + wo);

        XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        if(XC_UTIL_WorkType.isRepair(wo.XC_WorkTypeCategory__c)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for Repair');
            if(wo.ServiceAppointments.size() > 0) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ There are Service Appointments for this WorkOrder');
                wo.ServiceAppointments[0].XC_AssignToPartner__c = true;
                wrapperResult = XC_UTIL_Sobject.updateRecord(wo.ServiceAppointments[0]); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WrapperResult -> ' + wrapperResult);
                if(!wrapperResult.success) {
                    rw.success = wrapperResult.success;
                    rw.result = wrapperResult.errorMessage;
                    return rw;
                }
            } else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ There are not Service Appointments for this WorkOrder');
                ServiceAppointment sa = new ServiceAppointment();
                sa.ParentRecordId = wo.Id;
                sa.XC_Country__c = wo.XC_Country__c;
                wrapperResult = XC_UTIL_Sobject.insertRecord(sa);
                sa.XC_AssignToPartner__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Service Appointment to create -> ' + sa);
                wrapperResult = XC_UTIL_Sobject.updateRecord(sa);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WrapperResult -> ' + wrapperResult);
                if(!wrapperResult.success) {
                    rw.success = wrapperResult.success;
                    rw.result = wrapperResult.errorMessage;
                    return rw;
                }
            }     
            wo.XC_StatusReason__c = Label.XC_CL_PendingAssignToPartner;
            wrapperResult = XC_UTIL_Sobject.updateRecord(wo);  
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WrapperResult -> ' + wrapperResult);
            if(!wrapperResult.success) {
                rw.success = wrapperResult.success;
                rw.result = wrapperResult.errorMessage;
                return rw;
            }
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check for notRepair');
            if(wo.ServiceAppointments.size() > 0) {
               XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ There are Service Appointments for this WorkOrder');
               wo.ServiceAppointments[0].XC_AssignToPartner__c = true;
               wrapperResult = XC_UTIL_Sobject.updateRecord(wo.ServiceAppointments[0]);  
               XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WrapperResult -> ' + wrapperResult);
               if(!wrapperResult.success) {
                    rw.success = wrapperResult.success;
                    rw.result = wrapperResult.errorMessage;
                    return rw;
                }
            } else{
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ There are not Service Appointments for this WorkOrder');
                ServiceAppointment sa = new ServiceAppointment();
                sa.ParentRecordId = wo.Id;
                sa.XC_Country__c = wo.XC_Country__c;
                wrapperResult = XC_UTIL_Sobject.insertRecord(sa);
                sa.XC_AssignToPartner__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Service Appointment to create -> ' + sa);
                wrapperResult = XC_UTIL_Sobject.updateRecord(sa);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WrapperResult -> ' + wrapperResult);
                if(!wrapperResult.success) {
                    rw.success = wrapperResult.success;
                    rw.result = wrapperResult.errorMessage;
                    return rw;
                }
            } 
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ Exit (Apex Controller LCC089)');
        return rw; 
    }
    
}