/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/05/2019
* @description XC_SC012_AutoSchedule_U – Util for batch class XC_SC012_AutoScheduleToPartner and XC_SC012_AutoScheduleToTechnician
*/ 

public with sharing class XC_SC012_AutoSchedule_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC106_MassiveAssignmentWorkOrder');

    /** @description SplitListWrapper */ 
    public class SplitListWrapper {
        public List<ServiceAppointment> listServiceAppointmentErrorStatus = new List<ServiceAppointment>();
        public List<ServiceAppointment> listServiceAppointmentFiltred = new List<ServiceAppointment>();
    }

    /** @description LogWrapper */
    public class LogWrapper {
        public String errorMessage = '';
        public List<String> workOrderIds = new List<String>();
        public String workOrderId = '';
        public Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        public String originPartner = '';
        public String destinationPartner = '';
        public String comments = 'No comments';
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Split scope into two list
     * @param scope - List<ServiceAppointment> 
     * @return SplitListWrapper
    */
    public SplitListWrapper splitScope(List<ServiceAppointment> scope) {
        SplitListWrapper wr = new SplitListWrapper();
        for(ServiceAppointment sa : scope) {
            if(sa.Status == Label.XC_CL_ServiceAppointment_Scheduled  ||
                sa.Status == Label.XC_CL_ServiceAppointment_Dispatched ||
                sa.Status == Label.XC_CL_ServiceAppointment_OnHold) {
                    wr.listServiceAppointmentFiltred.add(sa);
            }
            else {
                    wr.listServiceAppointmentErrorStatus.add(sa);
            }
        }
        return wr;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Insert error log for Service Appoint with wrong status
     * @param listServiceAppointmentErrorStatus - List<ServiceAppointment>
     * @param originPartner - String 
     * @param destinationPartner - String
     * @param comments - String
    */
    public void insertNoMathStatusLogError(List<ServiceAppointment> listServiceAppointmentErrorStatus, String originPartner, String destinationPartner) {
        List<String> workOrderIdsError = XC_UTIL_Sobject.getListFieldValues(listServiceAppointmentErrorStatus, 'ParentRecordId');
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointmentError = new Map<String, ServiceAppointment>();
        for(ServiceAppointment sa : listServiceAppointmentErrorStatus) {
            mapWorkOrderServiceAppointmentError.put(sa.ParentRecordId, sa);
        }
        Set<String> setWorkOrderIds = new Set<String>();
        setWorkOrderIds.addAll(workOrderIdsError);
        if(!setWorkOrderIds.isEmpty()) {
            List<XC_MassiveAssignmentWorkOrderLog__c> listMassiveAssignmentLog = new List<XC_MassiveAssignmentWorkOrderLog__c>();
            for(String workOrderId : setWorkOrderIds) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for Massive Assignment Work Order. Insert to Log (Work Order \'' + workOrderId + '\')'); 
                XC_MassiveAssignmentWorkOrderLog__c massiveAssignmentLog = new XC_MassiveAssignmentWorkOrderLog__c();
                massiveAssignmentLog.XC_OriginPartner__c = originPartner;
                massiveAssignmentLog.XC_DestinationPartner__c = destinationPartner;
                massiveAssignmentLog.XC_ServiceAppointment__c = mapWorkOrderServiceAppointmentError.get(workOrderId).Id;
                massiveAssignmentLog.XC_WorkOrder__c = workOrderId;
                massiveAssignmentLog.XC_AssignmentMessage__c = Label.XC_CL_MassiveAssignmentWorkOrderImpossibleErrorStatus;
                massiveAssignmentLog.XC_AssignmentSuccess__c = false;
                listMassiveAssignmentLog.add(massiveAssignmentLog);
            }
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultListMassiveAssignmentLog = XC_UTIL_Sobject.insertListRecords(listMassiveAssignmentLog);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrapperResultListMassiveAssignmentLog ---> ' + wrapperResultListMassiveAssignmentLog);
        }
    }

}