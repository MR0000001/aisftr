/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Valeria Martino
* @date Creation 19/06/2019
* @description XC_UTIL_Schedule_TEST – Test Class for XC_UTIL_Schedule 
*/ 

@isTest
private class XC_UTIL_Schedule_TEST {

    @isTest
    static void onScheduleWithSpain(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;              
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, false);
        listOpportunity[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        insert listOpportunity;

        XC_UTIL_Schedule_W.ScheduleRequestWrapper scheduleRequestWrapper = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        scheduleRequestWrapper.country = 'SPAIN';
        scheduleRequestWrapper.startDate = System.now();
        scheduleRequestWrapper.existingServiceAppointmentId = listServiceAppointment[0].Id;
        scheduleRequestWrapper.workType = Label.XC_CL_WorkType_DeliveryInstallation;
        scheduleRequestWrapper.existingWorkOrderId = listWorkOrder[0].Id;
        scheduleRequestWrapper.existingWorkOrderNumber = '1';
        scheduleRequestWrapper.action = 'New';
        scheduleRequestWrapper.timeslotBegin = System.now();
        scheduleRequestWrapper.timeslotFinish = System.now().addDays(5);
        scheduleRequestWrapper.operation = 'getSlots';
        scheduleRequestWrapper.leadId = listLead[0].Id;
        scheduleRequestWrapper.opportunityId = listOpportunity[0].Id;

        XC_UTIL_Schedule_W.AddressWrapper addressWrapper =  new XC_UTIL_Schedule_W.AddressWrapper();
        addressWrapper.city = 'Madrid';
        addressWrapper.country = 'Spain';
        addressWrapper.postalCode = '20300';
        addressWrapper.street = 'Via de Castello';
        addressWrapper.state = 'Madrid';
        scheduleRequestWrapper.addressWr = addressWrapper;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        List<FSL__Scheduling_Policy__c> policy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c];
        System.debug('@@@@@@ aaaa -> '+policy);
        System.assertNotEquals(scheduleRequestWrapper, null);
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
                    
                                                               
        Test.startTest();
        
        XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
        scheduleRequestWrapper.action = 'Edit';
        XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
        scheduleRequestWrapper.operation = 'scheduleAppointment';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
        scheduleRequestWrapper.action = 'New';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
        //XC_UTIL_Schedule.manageSlotsFSL(List<FSL.AppointmentBookingSlot> slotList);
		Test.stopTest();    
    }

    @isTest
    static void onScheduleForEditAppointment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Delivery;
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;              
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, false);
        listOpportunity[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        insert listOpportunity;

        XC_UTIL_Schedule_W.ScheduleRequestWrapper scheduleRequestWrapper = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        scheduleRequestWrapper.country = 'SPAIN';
        scheduleRequestWrapper.startDate = System.now();
        scheduleRequestWrapper.existingServiceAppointmentId = listServiceAppointment[0].Id;
        scheduleRequestWrapper.workType = Label.XC_CL_WorkType_DeliveryInstallation;
        scheduleRequestWrapper.existingWorkOrderId = listWorkOrder[0].Id;
        scheduleRequestWrapper.existingWorkOrderNumber = '1';
        scheduleRequestWrapper.action = 'Edit';
        scheduleRequestWrapper.timeslotBegin = System.now();
        scheduleRequestWrapper.timeslotFinish = System.now().addDays(5);
        scheduleRequestWrapper.operation = 'getSlots';
        scheduleRequestWrapper.leadId = listLead[0].Id;
        scheduleRequestWrapper.opportunityId = listOpportunity[0].Id;

        XC_UTIL_Schedule_W.AddressWrapper addressWrapper =  new XC_UTIL_Schedule_W.AddressWrapper();
        addressWrapper.city = 'Madrid';
        addressWrapper.country = 'Spain';
        addressWrapper.postalCode = '20300';
        addressWrapper.street = 'Via de Castello';
        addressWrapper.state = 'Madrid';
        scheduleRequestWrapper.addressWr = addressWrapper;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        List<FSL__Scheduling_Policy__c> policy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c];
        System.debug('@@@@@@ aaaa -> '+policy);
        System.assertNotEquals(scheduleRequestWrapper, null);
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
                                                               
        Test.startTest();
        XC_UTIL_Schedule_U.getEarliestStartDate(listWorkOrder[0], scheduleRequestWrapper);
        XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
        scheduleRequestWrapper.action = 'New';
        XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
        scheduleRequestWrapper.operation = 'scheduleAppointment';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
        scheduleRequestWrapper.action = 'Edit';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
		Test.stopTest();    
    }

    @isTest
    static void onSchedule(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, false);
        listOpportunity[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        insert listOpportunity;

        XC_UTIL_Schedule_W.ScheduleRequestWrapper scheduleRequestWrapper = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        scheduleRequestWrapper.country = 'SPAIN';
        scheduleRequestWrapper.startDate = System.now();
        scheduleRequestWrapper.existingServiceAppointmentId = listServiceAppointment[0].Id;
        scheduleRequestWrapper.workType = Label.XC_CL_CommercialVisit;
        scheduleRequestWrapper.existingWorkOrderId = listWorkOrder[0].Id;
        scheduleRequestWrapper.existingWorkOrderNumber = '1';
        scheduleRequestWrapper.action = 'new';
        scheduleRequestWrapper.timeslotBegin = System.now();
        scheduleRequestWrapper.timeslotFinish = System.now().addDays(5);
        scheduleRequestWrapper.operation = 'getSlots';
        scheduleRequestWrapper.leadId = listLead[0].Id;
        scheduleRequestWrapper.opportunityId = listOpportunity[0].Id;
        XC_UTIL_Schedule_W.AddressWrapper addressWrapper =  new XC_UTIL_Schedule_W.AddressWrapper();
        addressWrapper.city = 'Madrid';
        addressWrapper.country = 'Spain';
        addressWrapper.postalCode = '20300';
        addressWrapper.street = 'Via de Castello';
        addressWrapper.state = 'Madrid';
        scheduleRequestWrapper.addressWr = addressWrapper;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        List<FSL__Scheduling_Policy__c> policy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c];
        System.debug('@@@@@@ aaaa -> '+policy);
        System.assertNotEquals(scheduleRequestWrapper, null);

        Test.startTest();
        XC_UTIL_Schedule.BookingResult bookingResult = XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
		Test.stopTest();    
    }

    @isTest
    static void onScheduleWithSpainWithoutExistingWorkOrderId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, false);
        listOpportunity[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        insert listOpportunity;

        XC_UTIL_Schedule_W.ScheduleRequestWrapper scheduleRequestWrapper = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        scheduleRequestWrapper.country = 'SPAIN';
        scheduleRequestWrapper.startDate = System.now();
        scheduleRequestWrapper.existingServiceAppointmentId = listServiceAppointment[0].Id;
        scheduleRequestWrapper.workType = Label.XC_CL_CommercialVisit;
        //scheduleRequestWrapper.existingWorkOrderId = listWorkOrder[0].Id;
        scheduleRequestWrapper.existingWorkOrderNumber = '1';
        scheduleRequestWrapper.action = 'New';
        scheduleRequestWrapper.timeslotBegin = System.now();
        scheduleRequestWrapper.timeslotFinish = System.now().addDays(5);
        scheduleRequestWrapper.operation = 'getSlots';
        scheduleRequestWrapper.leadId = listLead[0].Id;
        scheduleRequestWrapper.opportunityId = listOpportunity[0].Id;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        XC_UTIL_Schedule_W.AddressWrapper aw = new XC_UTIL_Schedule_W.AddressWrapper();
        aw.addressId = listAddress[0].Id;
        aw.city = listAddress[0].XC_City__c;
        aw.country = listAddress[0].XC_AddressCountry__c;
        aw.postalCode = listAddress[0].XC_PostalCode__c;
        aw.street = listAddress[0].XC_StreetType__c+listAddress[0].XC_Address__c+listAddress[0].XC_StreetNumber__c;
        aw.state = listAddress[0].XC_AddressProvince__c;
        scheduleRequestWrapper.addressWr = aw;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        List<FSL__Scheduling_Policy__c> policy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c];
        System.debug('@@@@@@ aaaa -> '+policy);
        System.assertNotEquals(scheduleRequestWrapper, null);
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
                    
                                                               
        Test.startTest();
        scheduleRequestWrapper.action = 'New';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
        scheduleRequestWrapper.leadId = null;
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);

		Test.stopTest();    
    }
    
    @isTest
    static void onScheduleWithSpainWithoutCountryAndWorkOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead;
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunity(1, false);
        listOpportunity[0].XC_ProductCategoryOfInterest__c = 'Smart Home';
        insert listOpportunity;

        XC_UTIL_Schedule_W.ScheduleRequestWrapper scheduleRequestWrapper = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        //scheduleRequestWrapper.country = 'SPAIN';
        scheduleRequestWrapper.startDate = System.now();
        scheduleRequestWrapper.existingServiceAppointmentId = listServiceAppointment[0].Id;
        scheduleRequestWrapper.workType = Label.XC_CL_CommercialVisit;
        //scheduleRequestWrapper.existingWorkOrderId = listWorkOrder[0].Id;
        scheduleRequestWrapper.existingWorkOrderNumber = '1';
        scheduleRequestWrapper.action = 'New';
        scheduleRequestWrapper.timeslotBegin = System.now();
        scheduleRequestWrapper.timeslotFinish = System.now().addDays(5);
        scheduleRequestWrapper.operation = 'getSlots';
        scheduleRequestWrapper.leadId = listLead[0].Id;
        scheduleRequestWrapper.opportunityId = listOpportunity[0].Id;

        XC_UTIL_Schedule_W.AddressWrapper addressWrapper =  new XC_UTIL_Schedule_W.AddressWrapper();
        addressWrapper.city = 'Madrid';
        addressWrapper.country = 'Spain';
        addressWrapper.postalCode = '20300';
        addressWrapper.street = 'Via de Castello';
        addressWrapper.state = 'Madrid';
        scheduleRequestWrapper.addressWr = addressWrapper;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        List<FSL__Scheduling_Policy__c> policy = [SELECT Id, Name FROM FSL__Scheduling_Policy__c];
        System.debug('@@@@@@ policy -> '+policy);
        System.assertNotEquals(scheduleRequestWrapper, null);
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
        TimeSlot timeSlot= new TimeSlot();
        timeSlot.OperatingHoursId=operatingHours.id;
        timeSlot.StartTime = System.now().Time();
        timeSlot.EndTime = System.now().Time() + 3;
        insert timeSlot;
        Timezone tz = UserInfo.getTimeZone();		
        List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(listServiceAppointment[0].id, policy[0].id, operatingHours.id, tz, false);

        Test.startTest();
        XC_UTIL_Schedule.getSlots(scheduleRequestWrapper);
        scheduleRequestWrapper.action = 'New';
        XC_UTIL_Schedule.scheduleAppointment(scheduleRequestWrapper);
        XC_UTIL_Schedule.manageSlotsFSL(slots);
		Test.stopTest();    
    }

    @isTest
    static void onScheduleD() {
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
        Test.startTest();
        XC_UTIL_Schedule_D.getOperatingHoursByName('Gold Appointments Calendar');
        XC_UTIL_Schedule_D.getOperatingHours(operatingHours.id, 'Gold Appointments Calendar');
        Test.stopTest(); 
        System.assertNotEquals(operatingHours, null); 
    }

    @isTest
    static void manageBookingOptions (){
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
        XC_Account__c = accList[0].Id, 
        isCapacityBased = true,
        RelatedRecordId = UserInfo.getUserId(), 
        isActive = true );
        insert servRes;
        XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        reqWr.assignToMe = true;
        reqWr.bookNow = true;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        XC_UTIL_Schedule_W.AddressWrapper aw = new XC_UTIL_Schedule_W.AddressWrapper();
        aw.addressId = listAddress[0].Id;
        aw.city = listAddress[0].XC_City__c;
        aw.country = listAddress[0].XC_AddressCountry__c;
        aw.postalCode = listAddress[0].XC_PostalCode__c;
        aw.street = listAddress[0].XC_StreetType__c+listAddress[0].XC_Address__c+listAddress[0].XC_StreetNumber__c;
        aw.state = listAddress[0].XC_AddressProvince__c;
        reqWr.addressWr = aw;
        XC_UTIL_Schedule_U.manageBookingOptions(reqWr, listWorkOrder[0], listServiceAppointment[0], 1);
        System.assertEquals(listServiceAppointment.isEmpty(), false);
    }

    @isTest
    static void manageBookingOptionsNoServiceResource (){
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listServiceAppointment;
        XC_UTIL_Schedule_W.ScheduleRequestWrapper reqWr = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        reqWr.assignToMe = true;
        reqWr.bookNow = true;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        XC_UTIL_Schedule_W.AddressWrapper aw = new XC_UTIL_Schedule_W.AddressWrapper();
        aw.addressId = listAddress[0].Id;
        aw.city = listAddress[0].XC_City__c;
        aw.country = listAddress[0].XC_AddressCountry__c;
        aw.postalCode = listAddress[0].XC_PostalCode__c;
        aw.street = listAddress[0].XC_StreetType__c+listAddress[0].XC_Address__c+listAddress[0].XC_StreetNumber__c;
        aw.state = listAddress[0].XC_AddressProvince__c;
        reqWr.addressWr = aw;
        XC_UTIL_Schedule_U.manageBookingOptions(reqWr, listWorkOrder[0], listServiceAppointment[0], 1);
        System.assertEquals(listServiceAppointment.isEmpty(), false);
    }
    
}