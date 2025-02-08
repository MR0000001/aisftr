/**
* @description XC_TR_WorkOrderLineItem_U_upWOSUtil – utility class XC_TR_WorkOrderLineItem_U_upWOS
*/
public class XC_TR_WorkOrderLineItem_U_upWOSUtil {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrderLineItem_U_upWOSUtil');
    /**
    * @description utility wrapper
    */
    public class UtilityWrapper {
        public WorkOrderLineItem currentWoli;
        public Workorder father;
        public List<Opportunity> oppToUpdate = new List<Opportunity>();
        public List<WorkOrder> woliToNotify = new List<WorkOrder>();
    }
    /**
    * @description check On Woli
    * @return check
    * @param woli
    * @param oldMap
    */
    public static Boolean checkOnWoli(WorkOrderLineItem woli, Map<Id,WorkOrderLineItem> oldMap) {
        Boolean check = false;
        if(woli.XC_OrderOfActivity__c == 1 && (oldMap.get(woli.id) != null && oldMap.get(woli.id).Status != Label.XC_CL_WorkOrderLineItem_Closed)){
            check = true; 
        }
        return check;
    }

    /**
    * @description cycle On Woli
    * @param changed
    * @param workOrderMap
    * @param oldMap
    * @return wrapper
    */
    public static XC_TR_WorkOrderLineItem_U_upWOS.UtilWrapper cycleOnWoli(List<WorkOrderLineItem> changed, Map<Id,WorkOrder> workOrderMap,Map<Id,WorkOrderLineItem> oldMap ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### In cycleOnWoli con  ### ' + changed);
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        List<ServiceAppointment> serAppToUpdate = new List<ServiceAppointment>(); // LR - 13/02/2018  -- SOLO se commercial visit started
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<WorkOrder> woToNotify = new List<Workorder>();

        for(WorkOrderLineItem woli : changed){ 
            if(woli.Status == Label.XC_CL_WorkOrderLineItem_InProgressStatus){
                woli.XC_Action_Start__c = System.now();
            }
            if(woli.Status == Label.XC_CL_WorkOrderLineItem_Closed){  
                woli.XC_Action_End__c = System.now();
                if(woli.XC_Action_Start__c == null){
                    woli.XC_Action_Start__c =System.now();
                } 
                WorkOrder father = workOrderMap.get(woli.WorkOrderId);
                if(checkOnWoli(woli, oldMap)){ setServiceApointmentProgress(father,serAppToUpdate); }   //first time in closed
                if(father != null && !woToUpdate.contains(father)){ // to prevent multiple updates on the same father workorder
                    UtilityWrapper utilWrapper = new UtilityWrapper();
                    utilWrapper.currentWoli = woli;
                    utilWrapper.father = father;
                    utilWrapper.oppToUpdate = oppToUpdate;
                    utilWrapper.woliToNotify = woToNotify;
                    woToUpdate.add(XC_TR_WorkOrderLineItem_U_upWOS.manageWoliBrothers(utilWrapper));
                }
            }  
        }
        XC_TR_WorkOrderLineItem_U_upWOS.UtilWrapper wrapper = new XC_TR_WorkOrderLineItem_U_upWOS.UtilWrapper();
        wrapper.woToUpdate = woToUpdate;
        wrapper.serAppToUpdate = serAppToUpdate;
        wrapper.oppToUpdate = oppToUpdate;
        wrapper.woToNotify = woToNotify;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### cycleOnWoli wrapper result ### ' +wrapper);
        return wrapper;
    }

    /**
     * Sets the service apointment progress.
     *
     * @author Giulio Serra - giserra@deloitte.it
     * @param wo the wo
     * @param toUpdate the to update
     * @date Creation 4/12/2018 ESCEP-106
     * @date Modification dd/mm/yyyy
     * @description set a service appointment in progess if the first WOLI is closed
     */
    private static void setServiceApointmentProgress(WorkOrder wo,List<ServiceAppointment> toUpdate){
        for(ServiceAppointment serApp: wo.ServiceAppointments){
            if(serApp.Status == Label.XC_CL_ServiceAppointment_Dispatched || serApp.Status == Label.XC_CL_ServiceAppointment_Scheduled){
                serApp.Status = Label.XC_CL_ServiceAppointment_In_Progress;
                toUpdate.add(serApp);
            }
        }
    }
}