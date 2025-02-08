/**
 * Created by SNEKKANTI00 on 28/04/2021.
 */

@isTest
public with sharing class TestServiceAppointmentSelector {

    // @TestSetup
    // public static void setup() {
        // TestDataFactory.createServiceAppointments();
    // }

    // @isTest
    // public static void getServiceAppointmentsByIds() {
        // List<String> serviceAppointmentIds = new List<String>();

        // for(ServiceAppointment s : [SELECT Id FROM ServiceAppointment]) {
        //     serviceAppointmentIds.add(s.Id);
        // }

        // Test.startTest();
        // ServiceAppointmentSelector.getServiceAppointmentsByIds(serviceAppointmentIds);
        // Test.stopTest();
    // }

    @isTest
    public static void postRemoveSchedulerTest() {
        ServiceAppointmentSelector s = new ServiceAppointmentSelector();
    }
}