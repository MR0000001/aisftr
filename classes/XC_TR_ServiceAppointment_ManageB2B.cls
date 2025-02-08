/**
* @author Nicola Arrigo
* @date Creation 19/08/2020
* @date Modification 21/08/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServiceAppointment_ManageB2B – Util class to manage SA for B2B/B2G
*/ 

public without sharing class XC_TR_ServiceAppointment_ManageB2B {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_ManageB2B');

    /**
    * @author Nicola Arrigo
    * @date Creation 19/08/2020
    * @description Method to manage Autoschedule SA and Malfunctioning WO
    * @param listNew - List<ServiceAppointment>
    */ 
    public static void manageForAutoschedule(List<ServiceAppointment> listNew) {
        List<String> listParentWorkOrderIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'ParentRecordId');
        List<WorkOrder> listParentWorkOrderWithSa = new List<WorkOrder>([
            SELECT Id, XC_Segment__c, XC_LegalEntity__c, XC_WorkTypeCategory__c, DurationInMinutes
            FROM WorkOrder
            WHERE Id IN :listParentWorkOrderIds AND XC_WorkTypeCategory__c = 'Malfunctioning' AND (XC_Segment__c = 'B2B' OR XC_Segment__c = 'B2G') 
        ]);

        for(WorkOrder wo : listParentWorkOrderWithSa) {
            for(ServiceAppointment sa : listNew) {
                if(sa.ParentRecordId == wo.Id) {
                    sa.FSL__Auto_Schedule__c = true;
                    sa.EarliestStartTime = Datetime.now().addMinutes(10);
                    sa.DueDate = wo.DurationInMinutes != null ? Datetime.now().addMinutes(Integer.valueOf(wo.DurationInMinutes)+10) : XC_UTIL_Schedule_D.getDueDate(Datetime.now(), 10);
                }
            }
        }     
    }

}