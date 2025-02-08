/**
 * @File Name          : XC_UTIL_ServiceApp_CustIntCond_TEST
 * @description        : Test class for XC_UTIL_ServiceApp_CustomInterCondition
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              : 
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 24/9/2019, 17:02:42
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    24/9/2019   Andrea Bravaccino - andrea.bravaccino@nttdata.com     Initial Version
**/
@isTest
public with sharing class XC_UTIL_ServiceApp_CustIntCond_TEST {

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
    private final static String PTE_CONTACT = Label.XC_CL_StatusReason_PteContact;
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

    @TestSetup
    static void setup(){
        Test.startTest(); 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, DELIVERY_INSTALLATION + ' - Air Conditioning', DELIVERY_INSTALLATION);
        woList.addAll(XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, COMMERCIAL_VISIT + ' - Air Conditioning', COMMERCIAL_VISIT));
        woList.addAll(XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, PLANNED_MAINTENANCE + ' - Gas', PLANNED_MAINTENANCE));
        woList.addAll(XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, REPAIR + ' - Gas', REPAIR));
        for(WorkOrder wo : woList){ 
            wo.XC_Address__c = addressList[0].id;
        }
        List<WorkType> workTypes = [SELECT Id FROM WorkType];
        List<XC_ZipCodeWorkType__c> zipCodesWorkType = new List<XC_ZipCodeWorkType__c>();
        for (WorkType wt : workTypes) {
            String zipCode = addressList[0].XC_PostalCode__c;
            String externalId = zipCode + '_' + wt.Id;
            zipCodesWorkType.add(new XC_ZipCodeWorkType__c(XC_ExternalId__c = externalId,
                                                            XC_WorkType__c = wt.Id,
                                                            XC_ZipCode__c = zipCode));
        }
        insert zipCodesWorkType;
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;

        XC_UTIL_ServiceApp_CustomInterCondition.checkCond1(woList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.checkCond2(saList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.checkCond3(saList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.checkCond4(saList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.checkInitial(saList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.checkParent(saList[0]);
        XC_UTIL_ServiceApp_CustomInterCondition.getWorkOrderIds(saList);
        Test.stopTest();
    }

    @IsTest
    static void checkSaScheduledTEST(){
        Test.startTest();
        WorkOrder woCV = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :COMMERCIAL_VISIT LIMIT 1];
        WorkOrder woDI = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :DELIVERY_INSTALLATION LIMIT 1];
        WorkOrder woPM = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :PLANNED_MAINTENANCE LIMIT 1];
        WorkOrder woR = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :REPAIR LIMIT 1];
        
        // Commercial Visit
        woCV.Status = ASSIGNED;
        for (ServiceAppointment sa : woCV.ServiceAppointments) {
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = APPOINTMENT_RESCHEDULED_BY_CLIENT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woCV, sa));
        }

        woCV.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
        for (ServiceAppointment sa : woCV.ServiceAppointments) {
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
            XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woCV, sa);
        }

        // Delivery & Installation
        woDI.Status = ASSIGNED;
        for (ServiceAppointment sa : woDI.ServiceAppointments) {
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = APPOINTMENT_RESCHEDULED_BY_CLIENT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woDI, sa));

            woDI.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
            sa.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woDI, sa));
        }

        
        
        // Planned Maintenance
        woPM.Status = ASSIGNED;
        woPM.XC_StatusReason__c = WORKABLE;
        for (ServiceAppointment sa : woPM.ServiceAppointments) {
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woPM, sa));

            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = CUSTOMER_RETAINED;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woPM, sa));
        }

        // Repair
        woR.Status = ASSIGNED;
        woR.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
        for (ServiceAppointment sa : woR.ServiceAppointments) {
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.XC_StatusReason__c = ASSIGNED_TO_THE_TECHNICIAN;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(woR, sa));
        }
        Test.stopTest();
    }
    
    
    @IsTest
    static void checkSaNotCompletedTEST(){
        Test.startTest();
        WorkOrder woCV = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :COMMERCIAL_VISIT LIMIT 1];
        WorkOrder woDI = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :DELIVERY_INSTALLATION LIMIT 1];
        WorkOrder woPM = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :PLANNED_MAINTENANCE LIMIT 1];
        WorkOrder woR = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :REPAIR LIMIT 1];
        
        // Commercial Visit
        woCV.Status = ON_HOLD;
        woCV.XC_StatusReason__c = THE_CUSTOMER_REQUESTS_TO_RESCHEDULED_THE_VISIT;
        for (ServiceAppointment sa : woCV.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = CUSTOMER_REFUSES_THE_VISIT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woCV, sa));

            woCV.XC_StatusReason__c = CUSTOMER_NOT_LOCATED;
            sa.XC_StatusReason__c = FAILED_VISIT;
             XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
        }

        // Delivery & Installation
        woDI.Status = ON_HOLD;
        
        for (ServiceAppointment sa : woDI.ServiceAppointments) {

            woDI.XC_StatusReason__c = PTE_CONTACT;
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = FAILED_VISIT;
             XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
            
            woDI.XC_StatusReason__c = THE_CUSTOMER_REQUESTS_TO_RESCHEDULED_THE_VISIT;
            sa.XC_StatusReason__c = CUSTOMER_REFUSES_THE_VISIT;
             XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
            
            woDI.XC_StatusReason__c = PTE_CONTACT_SERVICE_NOT_FINISHED;
            sa.XC_StatusReason__c = SERVICE_NOT_FINISHED;
            sa.Status = COMPLETED;
             XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
        }

        // Planned Maintenance
        woPM.Status = ON_HOLD;
        woPM.XC_StatusReason__c = PTE_CONTACT;
        for (ServiceAppointment sa : woPM.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = FAILED_VISIT;
            XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woPM, sa);
        }

        // Repair
        woR.Status = ON_HOLD;
        woR.XC_StatusReason__c = PTE_BUDGET_CREATION;
        for (ServiceAppointment sa : woR.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = BUDGET_DELIVERED;
            XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
            
            woR.XC_StatusReason__c = PTE_PARTS;
            sa.XC_StatusReason__c = BUDGET_ACCEPTED_FOR_PARTS;
            XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(woR, sa);
        }
        Test.stopTest();
    }

    @IsTest
    static void checkSaCanceledTEST(){
        Test.startTest();
        WorkOrder woCV = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :COMMERCIAL_VISIT LIMIT 1];
        WorkOrder woDI = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :DELIVERY_INSTALLATION LIMIT 1];
        WorkOrder woPM = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :PLANNED_MAINTENANCE LIMIT 1];
        WorkOrder woR = [SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c, (SELECT Id, XC_WorkTypeCategory__c, Status, XC_StatusReason__c FROM ServiceAppointments) FROM WorkOrder WHERE XC_WorkTypeCategory__c = :REPAIR LIMIT 1];
        
        // Commercial Visit
        woCV.Status = CANNOT_COMPLETE;
        woCV.XC_StatusReason__c = CUSTOMER_REJECT_SS;
        for (ServiceAppointment sa : woCV.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = FAILED_VISIT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woCV, sa));

            woCV.XC_StatusReason__c = CUSTOMER_NOT_LOCATED;
            sa.XC_StatusReason__c = FAILED_VISIT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woCV, sa));
        }

        // Delivery & Installation
        for (ServiceAppointment sa : woDI.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            woDI.XC_StatusReason__c = REJECT_INSTALLATION;
            woDI.Status = ON_HOLD;
            sa.XC_StatusReason__c = CUSTOMER_REFUSES_THE_VISIT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woDI, sa));
            
            woDI.Status = CANNOT_COMPLETE;
            woDI.XC_StatusReason__c = CUSTOMER_REJECT_SS;
            sa.XC_StatusReason__c = null;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woDI, sa));
        }

        // Planned Maintenance
        woPM.Status = ON_HOLD;
        woPM.XC_StatusReason__c = CUSTOMER_REQUESTS_UNSUBSCRIBE;
        for (ServiceAppointment sa : woPM.ServiceAppointments) {
            sa.Status = CANNOT_COMPLETE;
            sa.XC_StatusReason__c = CUSTOMER_REFUSES_THE_VISIT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woPM, sa));

            woPM.Status = CANNOT_COMPLETE;
            woPM.XC_StatusReason__c = CUSTOMER_REJECT_SS;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woPM, sa));
            
            woPM.Status = CANCELLED;
            woPM.XC_StatusReason__c = CUSTOMER_REJECT_SS;
            sa.Status = CANCELLED;
            sa.XC_StatusReason__c = null;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woPM, sa));
        }

        // Repair
        woR.Status = CANCELLED;
        for (ServiceAppointment sa : woR.ServiceAppointments) {
            sa.Status = CANCELLED;
            sa.XC_StatusReason__c = null;
            woR.XC_StatusReason__c = LOW_CONTRACT;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woR, sa));
            
            woR.XC_StatusReason__c = CUSTOMER_REJECT_SS;
            System.assert(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(woR, sa));
        }
        Test.stopTest();
    }
    
}