/************************************************************************************************************************
 * @author Lorenzo Orlanducci - lorenzoorlanducci@nttdata.com
 * @date Creation 24/04/2019
 * @date Modification 24/04/2019
 * @description XC_UTIL_ServiceApp_CustomInterCondition – Util to check Customer Interaction conditions
 *************************************************************************************************************************/
public without sharing class XC_UTIL_ServiceApp_CustomInterCondition {

    private final static String COMMERCIAL_VISIT = Label.XC_CL_WorkType_CommercialVisit;
    private final static String PLANNED_MAINTENANCE = Label.XC_CL_WorkType_PlannedMaintenance;
    private final static String DELIVERY_INSTALLATION = Label.XC_CL_WorkType_DeliveryInstallation;
    private final static String REPAIR = Label.XC_CL_WorkType_Repair;
    private final static String COMPLETED = Label.XC_CL_ServiceAppointment_Completed;
    private final static String APPOINTMENT_RESCHEDULED_BY_CLIENT = Label.XC_CL_StatusReason_Appointmentrescheduledbyclient;
    private final static String ON_HOLD = Label.XC_CL_ServiceAppointment_OnHold;
    private final static String CANNOT_COMPLETE = Label.XC_CL_ServiceAppointment_CannotComplete;
    private final static String ASSIGNED = Label.XC_CL_CustomerInteraction_Assigned;
    private final static String ASSIGNED_TO_THE_TECHNICIAN = Label.XC_CL_StatusReason_Assignedtothetechnician;
    private final static String BUDGET_ACCEPTED_FOR_PARTS = Label.XC_CL_StatusReason_Budgetacceptedforparts;
    private final static String BUDGET_DELIVERED = Label.XC_CL_StatusReason_Budgetdelivered;
    private final static String BUDGET_NOT_DELIVERED = Label.XC_CL_StatusReason_Budgetnotdelivered;
    private final static String CUSTOMER_NOT_LOCATED = Label.XC_CL_StatusReason_Customernotlocated;
    private final static String CUSTOMER_REFUSES_THE_VISIT = Label.XC_CL_StatusReason_Customerrefusesthevisit;
    private final static String CUSTOMER_REJECT_SS = Label.XC_CL_StatusReason_CustomerRejectSS;
    private final static String CUSTOMER_REQUESTS_UNSUBSCRIBE = Label.XC_CL_StatusReason_Customerrequestsunsubscribe;
    private final static String CUSTOMER_RETAINED = Label.XC_CL_StatusReason_CustomerRetained;
    private final static String FAILED_VISIT = Label.XC_CL_StatusReason_Failedvisit;
    private final static String LOW_CONTRACT = Label.XC_CL_StatusReason_LowContract;
    private final static String PTE_BUDGET_CREATION = Label.XC_CL_StatusReason_Ptebudgetcreation;
    private final static String PTE_CONTACT = Label.XC_CL_StatusReason_PendingContact;
    private final static String PTE_CONTACT_SERVICE_NOT_FINISHED = Label.XC_CL_StatusReason_PteContactServicenotfinished;
    private final static String PTE_PARTS = Label.XC_CL_StatusReason_PteParts;
    private final static String REASSIGNED_TECHNICIAN = Label.XC_CL_StatusReason_ReassignedTechnician;
    private final static String REJECT_INSTALLATION = Label.XC_CL_StatusReason_RejectInstallation;
    private final static String SERVICE_NOT_FINISHED = Label.XC_CL_StatusReason_Servicenotfinished;
    private final static String TECHNICIAN_REJECTS_ASSIGNMENT = Label.XC_CL_StatusReason_Technicianrejectsassignment;
    private final static String THE_CUSTOMER_CANNOT_FINISH_THE_VISIT = Label.XC_CL_StatusReason_Thecustomercannotfinishthevisit;
    private final static String THE_CUSTOMER_REQUESTS_TO_RESCHEDULED_THE_VISIT = Label.XC_CL_StatusReason_Thecustomerrequeststorescheduledthevisit;
    private final static String THE_JOB_CANNOT_BE_COMPLETED = Label.XC_CL_StatusReason_Thejobcannotbecompleted;
    private final static String WORKABLE = Label.XC_CL_StatusReason_Workable;
    private final static String CANCELLED = Label.XC_CL_Cancelled;
    private final static String ASSIGNED_TO_THE_TECHNICIAN_RESCHEDULED = Label.XC_CL_AssignedToTheTechnicianRescheduled;
    private final static String DIAGNOSTIC = Label.XC_CL_WorkType_Diagnostic;
    private final static String SITE_INSPECTION = Label.XC_CL_WorkType_SiteInspection;
    private final static String QUALITY_CHECK_INSPECTION = Label.XC_CL_WorkType_QualityCheckInspection;
    private final static String WT_RETURN = Label.XC_CL_WorkType_Return;



    /**
    * @description After service appointment update.
    * @param wo a Workorder
    * @return
    */
    public static boolean checkCond1(Workorder wo){
        if(!String.isBlank(wo.XC_Opportunity__c) || !String.isBlank(wo.ContactId)) {
            return true;
        }
        return false;
    }
    /**
    * @description After service appointment update.
    * @param serApp a ServiceAppointment object
    * @return
    */
    public static boolean checkCond2(ServiceAppointment serApp){
        if(serApp.Status == Label.XC_CL_ServiceAppointment_Scheduled && (serApp.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation || serApp.XC_WorkTypeCategory__c == DELIVERY_INSTALLATION)) {
            return true;
        }
        return false;
    }
    /**
    * @description After service appointment update.
    * @param serApp a ServiceAppointment object
    * @return
    */
    public static boolean checkCond3(ServiceAppointment serApp){
        if(serApp.Status == CANNOT_COMPLETE && serApp.XC_Check_Final_Status__c == false) {
            return true;
        }
        return false;
    }
    /**
    * @description After service appointment update.
    * @param serApp a ServiceAppointment object
    * @return
    */
    public static boolean checkCond4(ServiceAppointment serApp){
        if(serApp.Status == CANNOT_COMPLETE && serApp.XC_Check_Final_Status__c == true) {
            return true;
        }
        return false;
    }
    /**
    * @description After service appointment update.
    * @param serApp a ServiceAppointment object
    * @return
    */
    public static boolean checkInitial(ServiceAppointment serApp){
        if(serApp.Status == Label.XC_CL_ServiceAppointment_Scheduled && serApp.XC_WorkTypeCategory__c == COMMERCIAL_VISIT) {
            return true;
        }
        return false;
    }

    /**
    * @description After service appointment update.
    * @param serApp a ServiceAppointment object
    * @return
    */
    public static boolean checkParent(ServiceAppointment serApp){
        if(serApp.ParentRecord.Type == 'WorkOrder') {
            return true;
        }
        return false;
    }

    /**
    * ******************************************************************************.
    *
    * @param serAppList the ser app list
    * @return the work order ids
    * @description : Method to get WorkOrder Ids from a Service Appointment List
    * ******************************************************************************
    */
    public static List<Id> getWorkOrderIds(List<ServiceAppointment> serAppList) {
        List<Id> workOrderIdList = new List<Id>();

        for(ServiceAppointment serApp : serAppList) {
            if(serApp.ParentRecord.Type == 'WorkOrder') {
                workOrderIdList.add(serApp.ParentRecordId);
            }
        }

        return workOrderIdList;
    }

    /**
    *   Service Appointment Scheduled
    *
    *    -----------------------------------------------------------------------------------------------------------
    *   | Worktype  				   | WO Status | WO Status Reason    | SA Status | SA Status Reason             |
    *   | -----------------------------|-----------|---------------------|-----------|----------------------------- |
    *   | Commercial Visit			   | Assigned  | Asignada al técnico | Scheduled | Asignada al técnico          |
    *   | 							   | Assigned  | 				     | Scheduled | Cita reagendada por cliente  |
    *   | 							   | Assigned  | 				     | Scheduled | Técnico rechaza asignación   |
    *   | -----------------------------|-----------|---------------------|-----------|----------------------------- |
    *   | Delivery & Installation 	   | Assigned  | Asignada al técnico | Scheduled | Asignada al técnico          |
    *   | 							   | Assigned  | 				     | Scheduled | Técnico reasignado           |
    *   | 							   | Assigned  | 				     | Scheduled | Cita reagendada por cliente  |
    *   | -----------------------------|-----------|---------------------|-----------|----------------------------- |
    *   | Planned Maintenance		   | Assigned  | Workable		     | Scheduled | Cliente retenido             |
    *   | 							   | Assigned  | Workable            | Scheduled | Asignada al técnico          |
    *   | -----------------------------|-----------|---------------------|-----------|----------------------------- |
    *   | Repair					   | Assigned  | Asignada al técnico | Scheduled | Asignada al técnico          |
    *   |------------------------------|----------------------------------------------------------------------------|
    *   | Diagnostic /                 | Assigned  | Asignada al técnico | Scheduled | Asignada al técnico          |
    *   | Site Inspection /            |           |                     |           |                              |
    *   | Quality Check Inspection /   |           |                     |           |                              |
    *   | Return                       |           |                     |           |                              |
    *    -----------------------------------------------------------------------------------------------------------
    *
    *
    * @description check the table above
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 27/8/2019
    * @param wo Workorder
    * @param serApp ServiceAppointment
    * @return Boolean
    */
    public static Boolean checkSaScheduled(Workorder wo, ServiceAppointment serApp){
        if(checkSaScheduledCond4(wo, serApp)) {
            return false;
        }

        List<String> acceptedWT = new List<String>{COMMERCIAL_VISIT, DELIVERY_INSTALLATION, DIAGNOSTIC, SITE_INSPECTION, QUALITY_CHECK_INSPECTION, WT_RETURN};
        
        if (acceptedWT.contains(serApp.XC_WorkTypeCategory__c)) {
            if(wo.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN && (serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN || serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN_RESCHEDULED)) {
                return true;
            }else if(checkSaScheduledCond1(wo, serApp) && (serApp.XC_WorkTypeCategory__c == COMMERCIAL_VISIT || serApp.XC_WorkTypeCategory__c == DELIVERY_INSTALLATION)) {
                return true;
            }
        }else if(checkSaScheduledCond2(wo, serApp)) {
            return true;
        }else if(checkSaScheduledCond3(wo, serApp)) {
            return true;
        }
        return false;
    }

    private static Boolean checkSaScheduledCond1(Workorder wo, ServiceAppointment serApp){
        return (wo.XC_StatusReason__c == null || wo.XC_StatusReason__c == '') &&
                    (serApp.XC_StatusReason__c == APPOINTMENT_RESCHEDULED_BY_CLIENT 
                    || (serApp.XC_StatusReason__c == TECHNICIAN_REJECTS_ASSIGNMENT && serApp.XC_WorkTypeCategory__c == COMMERCIAL_VISIT) 
                    || (serApp.XC_WorkTypeCategory__c == DELIVERY_INSTALLATION && serApp.XC_StatusReason__c == REASSIGNED_TECHNICIAN ));
    }
    
    private static Boolean checkSaScheduledCond2(Workorder wo, ServiceAppointment serApp){
        return serApp.XC_WorkTypeCategory__c == PLANNED_MAINTENANCE && wo.XC_StatusReason__c == WORKABLE &&
                (serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN || serApp.XC_StatusReason__c == CUSTOMER_RETAINED  || serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN_RESCHEDULED);
    }
    
    private static Boolean checkSaScheduledCond3(Workorder wo, ServiceAppointment serApp){
        return serApp.XC_WorkTypeCategory__c == REPAIR && wo.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN &&
                (serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN || serApp.XC_StatusReason__c == ASSIGNED_TO_THE_TECHNICIAN_RESCHEDULED);
    }
    
    private static Boolean checkSaScheduledCond4(Workorder wo, ServiceAppointment serApp){
        return !(serApp.XC_WorkTypeCategory__c != null && wo.Status == ASSIGNED && serApp.Status == Label.XC_CL_ServiceAppointment_Scheduled);
    }

    /**
    *    Service Appointment Not Completed
    *
    *    ----------------------------------------------------------------------------------------------------------------------------------------
    *   | Worktype                   | WO Status | WO Status Reason                        | SA Status       | SA Status Reason                     |
    *   | ---------------------------|-----------|-----------------------------------------|-----------------|--------------------------------------|
    *   | Commercial visit           | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente rechaza visita               |
    *   |                            | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente no puede terminar la visita  |
    *   |                            | On Hold   | Pte Contactar                           | Cannot Complete | Visita fallida                       |
    *   |                            | On Hold   | Cliente no localizado                   | Cannot Complete | Visita fallida                       |
    *   | ---------------------------|-----------|-----------------------------------------|-----------------|--------------------------------------|
    *   | Delivery & Installation    | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente rechaza la visita            |
    *   |                            | On Hold   | Pte contactar                           | Cannot Complete | Visita Fallida                       |
    *   |                            | On Hold   | Pte contactar – Servicio no finalizado  | Cannot Complete | Servicio no finalizado               |
    *   |                            | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente no puede terminar la visita  |
    *   | ---------------------------|-----------|-----------------------------------------|-----------------|--------------------------------------|
    *   | Planned Maintenance        | On Hold   | Pte Contactar                           | Cannot Complete | Visita Fallida                       |
    *   |                            | On Hold   | Pte Contactar                           | Cannot Complete | Cliente rechaza visita               |
    *   |                            | On Hold   | Pte Contactar                           | Cannot Complete | No se puede completer el trabajo     |
    *   | ---------------------------|-----------|-----------------------------------------|-----------------|--------------------------------------|
    *   | Repair                     | On Hold   | Pte creación presupuesto                | Cannot Complete | No se entrega presupuesto            |
    *   |                            | On Hold   | Pte creación presupuesto                | Cannot Complete | Presupuesto entregado                |
    *   |                            | On Hold   | Pte Piezas                              | Cannot Complete | Presupuesto aceptado pte piezas      |
    *   | ---------------------------|--------------------------------------------------------------------------------------------------------------|
    *   | Diagnostic /               | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente rechaza visita               |
    *   | Site Inspection /          | On Hold   | El cliente solicita reagendar la visita | Cannot Complete | Cliente no puede terminar la visita  |
    *   | Quality Check Inspection / | On Hold   | Pte Contactar                           | Cannot Complete | Visita fallida                       |
    *   | Return                     |           |                                         |                 |                                      |
    *    -------------------------------------------------------------------------------------------------------------------------------------------
    *
    * @description check the table above
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 27/8/2019
    * @param wo Workorder
    * @param serApp ServiceAppointment
    * @return Boolean
    */
    public static Boolean checkSaNotCompleted(Workorder wo, ServiceAppointment serApp){
        if(checkSaNotCompletedCond1(wo, serApp)) {
            return false;
        }

        if (checkSaNotCompletedCondCV(wo, serApp)) {
            return true;
        }else if (checkSaNotCompletedCondDI(wo, serApp)) {
            return true;
        } else if(checkSaNotCompletedCondPM(wo, serApp)) {
            return true;
        }else if(checkSaNotCompletedCondR(wo, serApp)) {
            return true;
        }
        return false;
    }

    private static Boolean checkSaNotCompletedCond1(Workorder wo, ServiceAppointment serApp){
        return !(serApp.XC_WorkTypeCategory__c != null && wo.Status == ON_HOLD && (serApp.Status == CANNOT_COMPLETE || serApp.Status == COMPLETED));
    }

    private static Boolean checkSaNotCompletedCond2(Workorder wo, ServiceAppointment serApp){
        return wo.XC_StatusReason__c == THE_CUSTOMER_REQUESTS_TO_RESCHEDULED_THE_VISIT &&
            (serApp.XC_StatusReason__c == THE_CUSTOMER_CANNOT_FINISH_THE_VISIT || serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT);
    }

    private static Boolean checkSaNotCompletedCond3(Workorder wo, ServiceAppointment serApp){
        return serApp.XC_StatusReason__c == FAILED_VISIT &&
                    (wo.XC_StatusReason__c == PTE_CONTACT || (wo.XC_StatusReason__c == CUSTOMER_NOT_LOCATED && serApp.XC_WorkTypeCategory__c == COMMERCIAL_VISIT));
    }

    private static Boolean checkSaNotCompletedCond4(Workorder wo, ServiceAppointment serApp){
        return serApp.Status == CANNOT_COMPLETE && wo.XC_StatusReason__c == THE_CUSTOMER_REQUESTS_TO_RESCHEDULED_THE_VISIT &&
            (serApp.XC_StatusReason__c == THE_CUSTOMER_CANNOT_FINISH_THE_VISIT || serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT);
    }

    private static Boolean checkSaNotCompletedCondPM(Workorder wo, ServiceAppointment serApp){
        return (serApp.Status == CANNOT_COMPLETE && serApp.XC_WorkTypeCategory__c == PLANNED_MAINTENANCE && wo.XC_StatusReason__c == PTE_CONTACT) &&
                 (serApp.XC_StatusReason__c == FAILED_VISIT || serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT || serApp.XC_StatusReason__c == THE_JOB_CANNOT_BE_COMPLETED);
    }

    private static Boolean checkSaNotCompletedCond6(Workorder wo, ServiceAppointment serApp){
        return wo.XC_StatusReason__c == PTE_BUDGET_CREATION &&
            (serApp.XC_StatusReason__c == BUDGET_DELIVERED || serApp.XC_StatusReason__c == BUDGET_NOT_DELIVERED);
    }

    private static Boolean checkSaNotCompletedCond7(Workorder wo, ServiceAppointment serApp){
        return serApp.Status == CANNOT_COMPLETE && wo.XC_StatusReason__c == PTE_CONTACT_SERVICE_NOT_FINISHED && serApp.XC_StatusReason__c == SERVICE_NOT_FINISHED;
    }

    private static Boolean checkSaNotCompletedCond8(Workorder wo, ServiceAppointment serApp){
        return serApp.Status == CANNOT_COMPLETE && wo.XC_StatusReason__c == PTE_CONTACT && serApp.XC_StatusReason__c == FAILED_VISIT;
    }

    private static Boolean checkSaNotCompletedCond9(Workorder wo, ServiceAppointment serApp){
        return serApp.Status == CANNOT_COMPLETE && serApp.XC_WorkTypeCategory__c == REPAIR;
    }

    private static Boolean checkSaNotCompletedCondDI(Workorder wo, ServiceAppointment serApp){
        if (serApp.XC_WorkTypeCategory__c == DELIVERY_INSTALLATION) {
            if(checkSaNotCompletedCond4(wo, serApp)) {
                return true;
            }else if(checkSaNotCompletedCond8(wo, serApp)) {
                return true;
            }else if(checkSaNotCompletedCond7(wo, serApp)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkSaNotCompletedCondCV(Workorder wo, ServiceAppointment serApp){
        List<String> acceptedWT = new List<String>{COMMERCIAL_VISIT, DIAGNOSTIC, SITE_INSPECTION, QUALITY_CHECK_INSPECTION, WT_RETURN};
        if (serApp.Status == CANNOT_COMPLETE && acceptedWT.contains(serApp.XC_WorkTypeCategory__c)) {
            if(checkSaNotCompletedCond2(wo, serApp)) {
                return true;
            }else if(checkSaNotCompletedCond3(wo, serApp)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkSaNotCompletedCondR(Workorder wo, ServiceAppointment serApp){
        if(checkSaNotCompletedCond9(wo, serApp)) {
            if(checkSaNotCompletedCond6(wo, serApp)) {
                return true;
            }else if(wo.XC_StatusReason__c == PTE_PARTS && serApp.XC_StatusReason__c == BUDGET_ACCEPTED_FOR_PARTS) {
                return true;
            }
        }
        return false;
    }


    /**
    *   Service Appointment Canceled
    *
    *   -----------------------------------------------------------------------------------------------------------------------------
    *  | Worktype                   | WO Status       | WO Status Reason              | SA Status       | SA Status Reason		     |
    *  |----------------------------|-----------------|-------------------------------|-----------------|----------------------------|
    *  | Commercial Visit           | Cannot Complete | Cliente no localizado         | Cannot Complete | Visita fallida             |
    *  |                            | Cannot Complete | Cliente Rechaza S/S           | Cannot Complete | Visita fallida             |
    *  |                            | Cannot Complete | Cliente Rechaza S/S           | Cannot Complete | Cliente rechaza la visita  |
    *  |----------------------------|-----------------|-------------------------------|-----------------|--------------------------- |
    *  | Delivery & Installation    | On Hold         | Rechaza Instalación           | Cannot Complete | Cliente rechaza la visita  |
    *  |                            | Cannot Complete | Cliente rechaza S/S           | Cannot Complete |                            |
    *  |----------------------------|-----------------|-------------------------------|-----------------|----------------------------|
    *  | Planned Maintenance        | On Hold         | Cliente solicita baja         | Cannot Complete | Cliente rechaza la Visita  |
    *  |                            | Canceled        | Cliente solicita baja         | Cancelled       | Cliente rechaza la Visita  |
    *  |                            | Cannot Complete | Cliente rechaza S/S           | Cannot Complete | Cliente rechaza la Visita  |
    *  |                            | Cancelled       | Cliente rechaza S/S           | Cancelled       |                            |
    *  |                            | Cancelled       | Baja Contrato                 | Cancelled       |                            |
    *  |----------------------------|-----------------|-------------------------------|-----------------|----------------------------|
    *  | Repair                     | Cancelled       | Baja Contrato                 | Cancelled       |                            |
    *  |                            | Cancelled       | Cliente Rechaza S/S           | Cancelled       |                            |
    *  |----------------------------|-----------------|-------------------------------|-----------------|----------------------------|
    *  | Diagnostic /               | Cannot Complete | Customer not located	      | Cannot Complete	| Failed visit               |
    *  | Site Inspection /          | Cannot Complete | Customer Rejects S/S	      | Cannot Complete	| Failed visit               |
    *  | Quality Check Inspection / | Cannot Complete | Customer Rejects S/S	      | Cannot Complete	| Customer refuses the visit |
    *  | Return                     | Canceled	      | Low Contract	              | Canceled	    |                            |
    *  |                            | On Hold	      | Customer requests unsubscribe | Cannot Complete	| Customer refuses the visit |
    *  |                            | Canceled	      | Customer requests unsubscribe | Canceled	    | Customer refuses the visit |
    *   -----------------------------------------------------------------------------------------------------------------------------
    *   
    * @description check the table above
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 27/8/2019
    * @param wo Workorder
    * @param serApp ServiceAppointment
    * @return Boolean
    */
    public static Boolean checkSaCanceled(Workorder wo, ServiceAppointment serApp){
        if(serApp.XC_WorkTypeCategory__c == null) {
            return false;
        }

        if (checkSaCanceledCondCV(wo, serApp)) {
            return true;
        }else if (checkSaCanceledCondDI(wo, serApp)) {
            return true;
        }else if(checkSaCanceledCondPM(wo, serApp)) {
            return true;
        }else if(checkSaCanceledCondR(wo, serApp)) {
            return true;    
        }

        return false;
    }

    private static Boolean checkSaCanceledCond1(Workorder wo, ServiceAppointment serApp){
        return wo.XC_StatusReason__c == CUSTOMER_NOT_LOCATED && serApp.XC_StatusReason__c == FAILED_VISIT;
    }

    private static Boolean checkSaCanceledCond2(Workorder wo, ServiceAppointment serApp){
        return wo.XC_StatusReason__c == CUSTOMER_REJECT_SS && (serApp.XC_StatusReason__c == FAILED_VISIT || serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT);
    }

    private static Boolean checkSaCanceledCond3(Workorder wo, ServiceAppointment serApp){
        return wo.Status == ON_HOLD && wo.XC_StatusReason__c == REJECT_INSTALLATION && serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT;
    }

    private static Boolean checkSaCanceledCond4(Workorder wo, ServiceAppointment serApp){
        return wo.Status == CANNOT_COMPLETE && wo.XC_StatusReason__c == CUSTOMER_REJECT_SS && (serApp.XC_StatusReason__c == null || serApp.XC_StatusReason__c == '');
    }

    private static Boolean checkSaCanceledCond5(Workorder wo, ServiceAppointment serApp){
        return serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT && wo.XC_StatusReason__c == CUSTOMER_REQUESTS_UNSUBSCRIBE 
                                        && ((serApp.Status == CANNOT_COMPLETE && wo.Status == ON_HOLD) || (serApp.Status == CANCELLED && wo.Status == CANCELLED));
    }

    private static Boolean checkSaCanceledCond6(Workorder wo, ServiceAppointment serApp){
        return wo.Status == CANNOT_COMPLETE && wo.XC_StatusReason__c == CUSTOMER_REJECT_SS && serApp.Status == CANNOT_COMPLETE && serApp.XC_StatusReason__c == CUSTOMER_REFUSES_THE_VISIT;
    }

    private static Boolean checkSaCanceledCond7(Workorder wo, ServiceAppointment serApp){
        return wo.Status == CANCELLED && serApp.Status == CANCELLED && (serApp.XC_StatusReason__c == null || serApp.XC_StatusReason__c == '') && ((wo.XC_StatusReason__c == CUSTOMER_REJECT_SS && serApp.XC_WorkTypeCategory__c == PLANNED_MAINTENANCE) || wo.XC_StatusReason__c == LOW_CONTRACT);
    }

    private static Boolean checkSaCanceledCond8(Workorder wo, ServiceAppointment serApp){
        return wo.XC_StatusReason__c == LOW_CONTRACT || wo.XC_StatusReason__c == CUSTOMER_REJECT_SS;
    }

    private static Boolean checkSaCanceledCondCV(Workorder wo, ServiceAppointment serApp){
        List<String> acceptedWT = new List<String>{COMMERCIAL_VISIT, DIAGNOSTIC, SITE_INSPECTION, QUALITY_CHECK_INSPECTION, WT_RETURN};
        if (acceptedWT.contains(serApp.XC_WorkTypeCategory__c) && serApp.Status == CANNOT_COMPLETE && wo.Status == CANNOT_COMPLETE) {
            if (checkSaCanceledCond1(wo, serApp)) {
                return true;
            }else if(checkSaCanceledCond2(wo, serApp)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkSaCanceledCondDI(Workorder wo, ServiceAppointment serApp){
        if (serApp.XC_WorkTypeCategory__c == DELIVERY_INSTALLATION && serApp.Status == CANNOT_COMPLETE) {
            if (checkSaCanceledCond3(wo, serApp)) {
                return true;
            }else if(checkSaCanceledCond4(wo, serApp)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkSaCanceledCondPM(Workorder wo, ServiceAppointment serApp){
        List<String> acceptedWT = new List<String>{PLANNED_MAINTENANCE, DIAGNOSTIC, SITE_INSPECTION, QUALITY_CHECK_INSPECTION, WT_RETURN};
        if(acceptedWT.contains(serApp.XC_WorkTypeCategory__c)) {
            if(checkSaCanceledCond5(wo, serApp)) {
                return true;
            }else if(checkSaCanceledCond6(wo, serApp) && serApp.XC_WorkTypeCategory__c == PLANNED_MAINTENANCE) {
                return true;
            }else if(checkSaCanceledCond7(wo, serApp)) {
                return true;
            }
        }
        return false;
    }

    private static Boolean checkSaCanceledCondR(Workorder wo, ServiceAppointment serApp){
        if(serApp.XC_WorkTypeCategory__c == REPAIR && wo.Status == CANCELLED && serApp.Status == CANCELLED && 
            (serApp.XC_StatusReason__c == null || serApp.XC_StatusReason__c == '')) {
            
            if (checkSaCanceledCond8(wo, serApp)) {
                return true;
            }
        }
        return false;
    }
}