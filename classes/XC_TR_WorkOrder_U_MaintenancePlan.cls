/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
 * @date   16/11/2018
 * @description Class to manage Maintenance Work Orders
 */

public without sharing class XC_TR_WorkOrder_U_MaintenancePlan{
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_MaintenancePlan'); 

    /**
     * @description Creates the maintenance appointment.
     * @param listNew the list new
     */
    public static void createMaintenanceAppointment(List<WorkOrder> listNew){
        List<ServiceAppointment> listSAToInsert = new List<ServiceAppointment>();
        List<WorkOrder> listFirstMaintenanceWo = new List<WorkOrder>();
        List<WorkOrder> listNextMaintenanceWo = new List<WorkOrder>();
        
        for(WorkOrder wo : listNew){
            if(wo.XC_CreateMaintenanceServiceAppointment__c && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                if(wo.XC_PositionInMaintenancePlan__c == 1){
                    listFirstMaintenanceWo.add(wo); 
                } else if(wo.XC_PositionInMaintenancePlan__c > 1){
                    listNextMaintenanceWo.add(wo);
                }
            }
        }

        listSAToInsert.addAll(manageFirstMaintenance(listFirstMaintenanceWo)); 
        listSAToInsert.addAll(manageNextMaintenance(listNextMaintenanceWo)); 
        XC_UTIL_SObject.insertListRecords(listSAToInsert); 
    }

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description : Method to manage Service Appointment creation for First Maintenance
     * @param listFirstMaintenanceWo
     * @return the list of service appointments
     */
    public static List<ServiceAppointment> manageFirstMaintenance(List<WorkOrder> listFirstMaintenanceWo){
        List<ServiceAppointment> listSAToInsert = new List<ServiceAppointment>();
        if(listFirstMaintenanceWo.isEmpty()){ 
            return listSAToInsert;
        }        
        Map<Id, XC_UTIL_ServiceAppointment.WrapperMaintenanceDates> mapManteinanceDatesForProduct = XC_UTIL_ServiceAppointment.getManteinanceDatesForProduct(listFirstMaintenanceWo) ;  
        for(WorkOrder wo : listFirstMaintenanceWo){  
            if(!mapManteinanceDatesForProduct.containsKey(wo.Id)){
                continue;
            }
            ServiceAppointment newSa = createServiceAppointmentFirstMaintenance(wo, mapManteinanceDatesForProduct.get(wo.Id));
            if(newSa != null){
                listSAToInsert.add(newSa);
            } 
        } 
        return listSAToInsert;
    }

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description : Method to manage Service Appointment creation for Next Maintenance
     * @param listNextMaintenanceWo
     * @return the list of service appointments
     */
    public static List<ServiceAppointment> manageNextMaintenance(List<WorkOrder> listNextMaintenanceWo){
        List<ServiceAppointment> listSAToInsert = new List<ServiceAppointment>();
        if(listNextMaintenanceWo.isEmpty()){   
            return listSAToInsert;
        }
        List<String> listPreviousWOId = XC_UTIL_SObject.getListFieldValues(listNextMaintenanceWo, 'XC_PreviousMaintenanceWorkOrder__c');
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
            SELECT Id, XC_OriginalDueDate__c, XC_DueDate__c
            FROM WorkOrder 
            WHERE ID IN:listPreviousWOId
        ]); 
        Map<Id, XC_UTIL_ServiceAppointment.WrapperMaintenanceDates> mapManteinanceDatesForProduct = XC_UTIL_ServiceAppointment.getManteinanceDatesForProduct(listNextMaintenanceWo) ;
        for(WorkOrder wo : listNextMaintenanceWo){ 
            if(!mapWorkOrder.containsKey(wo.XC_PreviousMaintenanceWorkOrder__c)){
                continue;
            } 
            WorkOrder previousWO = mapWorkOrder.get(wo.XC_PreviousMaintenanceWorkOrder__c);
            ServiceAppointment newSa = createServiceAppointmentNextmaintenance(wo, previousWO, mapManteinanceDatesForProduct.get(wo.Id));
            if(newSa != null ){ 
                listSAToInsert.add(newSa);
            }   
        } 
        return listSAToInsert;
    }

    /**
     * @author Roberta Cossiga rcossiga@deloitte.it & Roberta Porrega roberta.porrega@nttdata.com & Chiara Turco cturco@deloitte.it
     * @param wo the wo
     * @param wrapperMaintenanceDates the wrapper maintenance dates
     * @return the service appointment
     * @description  Method to create a service appointment for first Maintenance Work Order
     */
    private static ServiceAppointment createServiceAppointmentFirstMaintenance(WorkOrder wo, XC_UTIL_ServiceAppointment.WrapperMaintenanceDates wrapperMaintenanceDates) {
        ServiceAppointment newSa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);      
        DateTime newEarliestStartTime;
        DateTime newDueDate;
        if((wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && wo.XC_Asset_InstallDate__c != null){
            newEarliestStartTime = wo.XC_Asset_InstallDate__c.addYears(1).addDays(wrapperMaintenanceDates.NumberDaysEarliestMaintenance);
            newDueDate = wo.XC_Asset_InstallDate__c.addYears(1).addDays(wrapperMaintenanceDates.NumberDaysDueDateMaintenance);
        }else if(wo.XC_Asset_ActivationDate__c != null){
            newEarliestStartTime = wo.XC_Asset_ActivationDate__c.addYears(1).addDays(wrapperMaintenanceDates.NumberDaysEarliestMaintenance);
            newDueDate = wo.XC_Asset_ActivationDate__c.addYears(1).addDays(wrapperMaintenanceDates.NumberDaysDueDateMaintenance);
        }else {
            return null;
        }

        //20220201 OTT_FLS12 - [DO] – start 
        Datetime todayDate = System.today();
        if ( (newEarliestStartTime < todayDate && newDueDate < todayDate)){
            newDueDate = todayDate.addDays(newEarliestStartTime.date().daysBetween(newDueDate.date()));
            newEarliestStartTime = todayDate;
        }
        //20220201 OTT_FLS12 - [DO] – end 
        newDueDate = newDueDate.addHours(12);
        
        newSa.EarliestStartTime = newEarliestStartTime;
        newSa.DueDate = newDueDate;  
        
        newSa.FSL__Auto_Schedule__c = true; 
        return newSa;        
    }

    /** 
     * @author Roberta Cossiga rcossiga@deloitte.it & Roberta Porrega roberta.porrega@nttdata.com & Chiara Turco cturco@deloitte.it
     * @param wo the wo
     * @param previousWO the previous WO
     * @param wrapperMaintenanceDates
     * @return the service appointment
     * @description : Method to create a service appointment for next Maintenance Work Order
     */
    private static ServiceAppointment createServiceAppointmentNextMaintenance(WorkOrder wo, WorkOrder previousWO, XC_UTIL_ServiceAppointment.WrapperMaintenanceDates wrapperMaintenanceDates){
        /*if(!previousWO.ServiceAppointments.isEmpty()){
            ServiceAppointment previousSA = previousWO.ServiceAppointments[0];*/
            ServiceAppointment newSa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
            Integer daysOrMonthForSecondMaintenance = wrapperMaintenanceDates.NumberMonthDueDateSecondPlannedMaintenance;
            String daysOrMonth = wrapperMaintenanceDates.DaysOrMonthForDueDate;
            Integer yearFrequency = Integer.valueOf(wo.XC_MaintenanceYearFrequency__c); 
            /*DateTime newEarliestStartTime = previousSA.EarliestStartTime.addYears(yearFrequency);
            DateTime newDueDate = DateTime.now();
            if(!String.isEmpty(daysOrMonth) && daysOrMonthForSecondMaintenance != null){
                if(daysOrMonth == Label.XC_CL_Month){
                     newDueDate = newEarliestStartTime.addMonths(daysOrMonthForSecondMaintenance); 
                }
                else{
                    newDueDate = newEarliestStartTime.addDays(daysOrMonthForSecondMaintenance); 
                }
            }
            else{
                 newDueDate = previousSA.DueDate.addYears(1);
            }*/
            Datetime newDueDate=null;

            if(previousWO.XC_OriginalDueDate__c==null){
                newDueDate=previousWO.XC_DueDate__c.addYears(yearFrequency);
            }else{
                newDueDate = previousWO.XC_OriginalDueDate__c.addYears(yearFrequency);
            }
            DateTime newEarliestStartTime = newDueDate;
            if(daysOrMonth == Label.XC_CL_Month){
                newEarliestStartTime = newDueDate.addMonths(-daysOrMonthForSecondMaintenance); 
            }
            else{
                newEarliestStartTime = newDueDate.addDays(-daysOrMonthForSecondMaintenance); 
            }
            newDueDate = newDueDate.addHours(12);
            newSa.EarliestStartTime = newEarliestStartTime;
            newSa.DueDate = newDueDate; 
            newSa.FSL__Auto_Schedule__c = true; 
            return newSa; 
        /*}
        return null;*/
    }     
    
}