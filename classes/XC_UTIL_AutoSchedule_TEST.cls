/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 24/06/2019
 * @description XC_UTIL_AutoSchedule_Test – Test Class XC_UTIL_AutoSchedule
**/

@isTest
public class XC_UTIL_AutoSchedule_TEST {

    @isTest
    static void autoScheduleAppointment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> serviceAppointmentWithoutPreferred =  XC_DF_ServiceAppointment.createServiceAppointment(1);
        serviceAppointmentWithoutPreferred[0].ArrivalWindowEndTime = System.now().addDays(3);
        serviceAppointmentWithoutPreferred[0].ArrivalWindowStartTime = System.now();
        serviceAppointmentWithoutPreferred[0].XC_Country__c = 'SPAIN';
        serviceAppointmentWithoutPreferred[0].EarliestStartTime = System.now().addDays(-1);
        serviceAppointmentWithoutPreferred[0].DueDate = System.now().addHours(10);  
        insert serviceAppointmentWithoutPreferred;
        System.assertNotEquals(serviceAppointmentWithoutPreferred, null);
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
        TimeSlot timeSlot= new TimeSlot();
        timeSlot.OperatingHoursId=operatingHours.id;
        timeSlot.StartTime = System.now().addHours(-1).Time();
        timeSlot.EndTime = System.now().addHours(1).Time();
        insert timeSlot;    

        Test.startTest(); 
        XC_UTIL_AutoSchedule.AutoSchedulingResult result = XC_UTIL_AutoSchedule.autoScheduleAppointment(serviceAppointmentWithoutPreferred[0]);
        Test.stopTest(); 
    }

    @isTest
    static void autoScheduleAppointmentWithPreference(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> serviceAppointment =  XC_DF_ServiceAppointment.createServiceAppointment(1);
        serviceAppointment[0].ArrivalWindowEndTime = System.now().addDays(3);
        serviceAppointment[0].ArrivalWindowStartTime = System.now();
        serviceAppointment[0].EarliestStartTime = System.now().addDays(-1);
        serviceAppointment[0].DueDate = System.now().addHours(10);  
        serviceAppointment[0].XC_Country__c = 'SPAIN';
        insert serviceAppointment;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
        TimeSlot timeSlot= new TimeSlot();
        timeSlot.OperatingHoursId=operatingHours.id;
        timeSlot.StartTime = System.now().addHours(-1).Time();
        timeSlot.EndTime = System.now().addHours(1).Time();
        insert timeSlot;    

        XC_UTIL_AutoSchedule.AutoScheduleInputWrapper autoScheduleWrapper = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
        autoScheduleWrapper.serviceAppointment = serviceAppointment[0]; 
        autoScheduleWrapper.preferredStart = System.now().addDays(1); 
        autoScheduleWrapper.preferredEnd = System.now().addDays(2); 
        autoScheduleWrapper.operatingHoursId = operatingHours.Id;
        System.assertNotEquals(serviceAppointment, null);

        Test.startTest(); 
        XC_UTIL_AutoSchedule.AutoSchedulingResult result = XC_UTIL_AutoSchedule.autoScheduleAppointment(autoScheduleWrapper);
        Test.stopTest(); 
    }

    @isTest
    static void autoScheduleAppointmentToFixedSlot(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> serviceAppointment =  XC_DF_ServiceAppointment.createServiceAppointment(1);
        serviceAppointment[0].ArrivalWindowEndTime = System.now().addDays(3);
        serviceAppointment[0].ArrivalWindowStartTime = System.now();
        serviceAppointment[0].EarliestStartTime = System.now().addDays(-1);
        serviceAppointment[0].DueDate = System.now().addHours(10);  
        serviceAppointment[0].XC_Country__c = 'SPAIN';
        insert serviceAppointment;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;
        TimeSlot timeSlot= new TimeSlot();
        timeSlot.OperatingHoursId=operatingHours.id;
        timeSlot.StartTime = System.now().addHours(-1).Time();
        timeSlot.EndTime = System.now().addHours(1).Time();
        insert timeSlot;        

        XC_UTIL_AutoSchedule.AutoScheduleInputWrapper autoScheduleWrapper = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
        autoScheduleWrapper.serviceAppointment = serviceAppointment[0]; 
        autoScheduleWrapper.preferredStart = System.now().addDays(1); 
        autoScheduleWrapper.preferredEnd = System.now().addDays(2); 
        autoScheduleWrapper.operatingHoursId = operatingHours.Id;
        System.assertNotEquals(serviceAppointment, null);

        Test.startTest(); 
        XC_UTIL_AutoSchedule.AutoSchedulingResult result = XC_UTIL_AutoSchedule.autoScheduleAppointmentToFixedSlot(autoScheduleWrapper);
        Test.stopTest(); 
    }

    @isTest
    static void autoScheduleAppointmentToFixedSlotWithoutSlot(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> partners = XC_DF_Account.insertPartnerAccounts(1, 'Active'); 
        List<ServiceAppointment> serviceAppointment =  XC_DF_ServiceAppointment.createServiceAppointment(1);
        serviceAppointment[0].ArrivalWindowEndTime = System.now().addDays(3);
        serviceAppointment[0].ArrivalWindowStartTime = System.now();
        serviceAppointment[0].XC_Country__c = 'SPAIN';
        serviceAppointment[0].EarliestStartTime = System.now().addDays(-1);
        serviceAppointment[0].DueDate = System.now().addHours(10);  
        insert serviceAppointment;
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        OperatingHours operatingHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        insert operatingHours;  
        TimeSlot timeSlot= new TimeSlot();
        timeSlot.OperatingHoursId=operatingHours.id;
        timeSlot.StartTime = System.now().addHours(-1).Time();
        timeSlot.EndTime = System.now().addHours(1).Time();
        insert timeSlot;        

        XC_UTIL_AutoSchedule.AutoScheduleInputWrapper autoScheduleWrapper = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
        autoScheduleWrapper.serviceAppointment = serviceAppointment[0]; 
        autoScheduleWrapper.preferredStart = System.now().addDays(1); 
        autoScheduleWrapper.preferredEnd = System.now().addDays(2); 
        autoScheduleWrapper.operatingHoursId = operatingHours.Id;
        autoScheduleWrapper.preferredPartnerId = partners[0].Id;
        System.assertNotEquals(serviceAppointment, null);

        Test.startTest(); 
        XC_UTIL_AutoSchedule.AutoSchedulingResult result = XC_UTIL_AutoSchedule.autoScheduleAppointmentToFixedSlot(autoScheduleWrapper);
        Test.stopTest(); 
    }

}