/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 14/05/2019
* @description XC_LCC106_MassiveAssignmentWorkOrder_U – Util class for XC_LCC106_MassiveAssignmentWorkOrder_U
*/

public without sharing class XC_LCC106_MassiveAssignmentWorkOrder_U {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC106_MassiveAssignmentWorkOrder');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 11/04/2019
     * @description Method to split work order in order to Boolean "AssignPartner"
     * @param listWorkOrder - List Work Order
     * @return wr - SplitWorkOrderWrapper
    */
    public static XC_LCC106_MassiveAssignmentWorkOrder.SplitWorkOrderWrapper splitWorkOrders(List<WorkOrder> listWorkOrder) {
        XC_LCC106_MassiveAssignmentWorkOrder.SplitWorkOrderWrapper wr = new XC_LCC106_MassiveAssignmentWorkOrder.SplitWorkOrderWrapper();
        List<String> listNameWorkType = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_WorkTypeLabel__c');
        //Map<String, Boolean> mapNameIsAssignPartnerWorkType =  XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeName(listNameWorkType);
        List<WorkType> listWorkType = [SELECT Name, XC_AssignToPartner__c FROM WorkType WHERE Name IN :listNameWorkType];
        Map<String,Boolean> mapNameIsAssignPartnerWorkType = new Map<String,Boolean>();
        for(WorkType wt: listWorkType) {
            mapNameIsAssignPartnerWorkType.put(wt.Name, wt.XC_AssignToPartner__c);
        }
        for(WorkOrder workOrder : listWorkOrder) {
            if(mapNameIsAssignPartnerWorkType.get(workOrder.XC_WorkTypeLabel__c)) {
                wr.listIdWorkOrderWithAssignPartner.add(workOrder.Id);
            } else {
                wr.listIdWorkOrderWithouthAssignPartner.add(workOrder.Id);
            }
        }
        return wr;
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 14/05/2019
     * @description Method to check Service Appointment to update DueDate
     * @param listIdWorkOrderFiltered- List<String>
     * @param listServiceAppointment - List<ServiceAppointment>
     * @return List<String>
    */
    public static List<String> populateServiceAppointmentToUpdate(List<String> listIdWorkOrderFiltered, List<ServiceAppointment> listServiceAppointment) {
        List<String> listServiceAppointmentToUpdate = new List<String>();
        for(ServiceAppointment sa : listServiceAppointment) {
            if(listIdWorkOrderFiltered.contains(sa.ParentRecordId)) {
                listServiceAppointmentToUpdate.add(sa.Id);
            }
        }
        return listServiceAppointmentToUpdate;
    }

}