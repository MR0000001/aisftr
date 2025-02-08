/*
@CreatedBy      - Federico Ruggeri (Fabrizio.Fiorentini@webresults.it), 2020/11/02
@Description    - Test class for TA_LCC213_BookAppointment
*/

@isTest
public with sharing class TA_LCC213_BookAppointment_Test {
    @testSetup
    static void setup() 
    {
        //TA_UTIL_Test.loadSetup();

        /*Opportunity opp = new Opportunity();
        insert opp;*/

        WorkOrder workOrder = new WorkOrder(TA_Phase__c = 'checkIn', XC_WorkTypeCategory__c = 'Delivery & Installation', Status = 'New');
        insert workOrder;

        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(new List<WorkOrder>{workOrder});

        ServiceAppointment sa = saList[0];
        sa.schedStartTime = system.now();
        sa.schedEndTime = system.now() + 1;
        sa.ParentRecordId = workOrder.Id;
        insert sa;

        XC_CM_Scheduling_Default_Value__mdt metad = [SELECT id, XC_Policy_Name__c, XC_Operating_Hours_Name__c FROM XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;
    }

    @isTest
    static void getAvailableAppointments_Test() {
        Test.startTest();
        new TA_LCC213_BookAppointment();
        Map<String, String> response_a = TA_LCC213_BookAppointment.getAvailableAppointments([SELECT Id FROM WorkOrder LIMIT 1].Id, null, null, false);
        Map<String, String> response_b = TA_LCC213_BookAppointment.getAvailableAppointments([SELECT Id FROM WorkOrder LIMIT 1].Id, null, null, true);
        Test.stopTest();
    }

    @isTest
    static void getWorkOrderToSchedule_Test() {
        Test.startTest();
        String response = TA_LCC213_BookAppointment.getWorkOrderToSchedule([SELECT Id FROM WorkOrder LIMIT 1].Id);
        Test.stopTest();
    }

    @isTest
    static void scheduleAppointment_Test() {
        Lead lead = new Lead(Email = 'test@yopmail.it', LastName = 'Rossi', Company = 'Test');
        insert lead;
		Test.startTest();
        TA_LCC213_BookAppointment.WrapperSlot wrapperSlot = new TA_LCC213_BookAppointment.WrapperSlot(DateTime.now(),
                                                                                                      DateTime.now().addHours(2),
                                                                                                      DateTime.now().addHours(4),
                                                                                                      Date.today(),
                                                                                                      [SELECT Id FROM ServiceAppointment LIMIT 1].Id,
                                                                                                      [SELECT Id FROM WorkOrder LIMIT 1].Id);
        //Test.startTest();
        Map<String, String> response_a = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                        [SELECT Id FROM WorkOrder LIMIT 1].Id,
                                                                                        false, false);
        Map<String, String> response_a1 = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                        [SELECT Id FROM WorkOrder LIMIT 1].Id,
                                                                                        false, true);

        Map<String, String> response_b = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                           [SELECT Id FROM WorkOrder LIMIT 1].Id,
                                                                                           true, false);
        Map<String, String> response_b1 = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                           [SELECT Id FROM WorkOrder LIMIT 1].Id,
                                                                                           true, true);     
        Test.stopTest();                                                                       
    }

    @isTest
    static void scheduleAppointment_Test2() {
        Lead lead = new Lead(Email = 'test@yopmail.it', LastName = 'Rossi', Company = 'Test');
        insert lead;
		Test.startTest();
        TA_LCC213_BookAppointment.WrapperSlot wrapperSlot = new TA_LCC213_BookAppointment.WrapperSlot(DateTime.now(),
                                                                                                      DateTime.now().addHours(2),
                                                                                                      DateTime.now().addHours(4),
                                                                                                      Date.today(),
                                                                                                      [SELECT Id FROM ServiceAppointment LIMIT 1].Id,
                                                                                                      [SELECT Id FROM WorkOrder LIMIT 1].Id);

       // Test.startTest();
        Map<String, String> response_c = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                       [SELECT Id FROM ServiceAppointment LIMIT 1].Id,
                                                                                       true, false);
        Map<String, String> response_c1 = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                       [SELECT Id FROM ServiceAppointment LIMIT 1].Id,
                                                                                       true, true);

        Map<String, String> response_d = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                       lead.Id,
                                                                                       true, false);
        Map<String, String> response_d1 = TA_LCC213_BookAppointment.scheduleAppointment(JSON.serialize(wrapperSlot),
                                                                                       lead.Id,
                                                                                       true, true);  
        Test.stopTest();                                                                           
    }

    /*@isTest
    static void populateWorkOrderForCommercialVisit_Test() {
        Lead lead = new Lead(Email = 'test@yopmail.it', LastName = 'Rossi', Company = 'Test');
        insert lead;
        WorkOrder workOrder = new WorkOrder();
        insert workOrder;

        Test.startTest();
        TA_LCC213_BookAppointment.populateWorkOrderForCommercialVisit(null, lead.id, false);
        TA_LCC213_BookAppointment.populateWorkOrderForCommercialVisit(workOrder.Id, lead.id, false);
        TA_LCC213_BookAppointment.populateWorkOrderForCommercialVisit(workOrder.Id, workOrder.Id, false);
        Test.stopTest();
    }*/

    @isTest
    static void updateServiceAppointmentDurationTime_Test() {
        ServiceAppointment sa = [SELECT Id FROM ServiceAppointment LIMIT 1];
        Test.startTest();
        TA_LCC213_BookAppointment.updateServiceAppointmentDurationTime(sa.Id, 1, 'Hours');
        TA_LCC213_BookAppointment.updateServiceAppointmentDurationTime(null, 1, 'Hours');
        Test.stopTest();
    }
}