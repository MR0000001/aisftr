/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 30/01/2020
 * @description  – XC_LCC146_BookAppointmentCustom_TEST - Class test for XC_LCC146_BookAppointmentCustom
 */

@isTest

public without sharing class XC_LCC146_BookAppointmentCustom_TEST {

    /*@isTest
    private static void onCheckAvailabilityDI() {
        Test.startTest();
        XC_LCC146_BookAppointmentCustom.CheckAvailabilityWrapper outputWrapperDI = XC_LCC146_BookAppointmentCustom.checkAvailability('');
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert listWo;
        outputWrapperDI = XC_LCC146_BookAppointmentCustom.checkAvailability(listWo[0].Id);
        System.assertNotEquals(outputWrapperDI, null);
        Test.stopTest();
    }*/

    @isTest
    private static void onCheckAvailabilitySubstitution() {
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution);
        insert listWo;
        List<WorkOrder> listWoChild = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWoChild[0].ParentWorkOrderId = listWo[0].Id;
        insert listWoChild;

        Test.startTest();
        XC_LCC146_BookAppointmentCustom.CheckAvailabilityWrapper outputWrapper = XC_LCC146_BookAppointmentCustom.checkAvailability(listWo[0].Id);
        System.assertNotEquals(outputWrapper, null);
        Test.stopTest();
    }

    @isTest
    private static void onCheckAvailabilityDeliveryInstallation() {
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWo[0].XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        insert listWo;
        List<WorkOrder> listWoChild = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listWoChild[0].ParentWorkOrderId = listWo[0].Id;
        listWoChild[0].XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        insert listWoChild;

        Test.startTest();
        XC_LCC146_BookAppointmentCustom.CheckAvailabilityWrapper outputWrapper = XC_LCC146_BookAppointmentCustom.checkAvailability(listWo[0].Id);
        Test.stopTest();
    }

    @isTest
    private static void onCheckAvailabilitySubstitutionWithError() {
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Substitution);
        insert listWo;

        Test.startTest();
        XC_LCC146_BookAppointmentCustom.CheckAvailabilityWrapper outputWrapper = XC_LCC146_BookAppointmentCustom.checkAvailability(listWo[0].Id);
        System.assertNotEquals(outputWrapper, null);
        Test.stopTest();
    }

}