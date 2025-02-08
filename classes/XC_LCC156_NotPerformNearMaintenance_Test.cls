/**
 * The Class XC_LCC156_NotPerformNearMaintenance_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 24/09/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_LCC156_NotPerformNearMaintenance_Test – Test class for XC_LCP156_NotPerformNearMaintenance Component
 */
 @isTest
public without sharing class XC_LCC156_NotPerformNearMaintenance_Test {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @isTest
    static void succededTest(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Repair');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'None';
        serApp[0].ActualDuration = 1.0;
        insert serApp;
        List<ServiceAppointment> listOfWoOfSa = new List <ServiceAppointment> ([SELECT Id, ParentRecordId
                                                                                FROM ServiceAppointment
                                                                                WHERE Id =: serApp[0].id]);
        WorkOrder wo= new WorkOrder(Id = listOfWoOfSa[0].ParentRecordId);
        wo.XC_MaintenanceIsNear__c = true;
        update wo;
        Test.startTest(); 
        XC_LCC156_NotPerformNearMaintenance.ResultWrapper wr = XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance(wo.Id);
        Test.stopTest();
        System.assertEquals(wr.success, true);
    }

    @isTest
    static void workorderNotRepair(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Planned Maintenance');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'None';
        serApp[0].ActualDuration = 1.0;
        insert serApp;
        List<ServiceAppointment> listOfWoOfSa = new List <ServiceAppointment> ([SELECT Id, ParentRecordId
                                                                                FROM ServiceAppointment
                                                                                WHERE Id =: serApp[0].id]);
        Test.startTest();
        WorkOrder wo= new WorkOrder(Id = listOfWoOfSa[0].ParentRecordId);
        wo.XC_MaintenanceIsNear__c = true;
        update wo;
        XC_LCC156_NotPerformNearMaintenance.ResultWrapper wr = XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance(wo.Id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

    @isTest
    static void noSAforWorkOrder(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        listOfWo[0].XC_MaintenanceIsNear__c = true;
        insert listOfWo;
        Test.startTest(); 
        XC_LCC156_NotPerformNearMaintenance.ResultWrapper wr = XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance(listOfWo[0].Id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }
    
    @isTest
    static void maintenanceIsNearFalse(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        listOfWo[0].XC_MaintenanceIsNear__c = false;
        insert listOfWo;
        Test.startTest(); 
        XC_LCC156_NotPerformNearMaintenance.ResultWrapper wr = XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance(listOfWo[0].Id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

    @isTest
    static void populateWrapperError (){
        XC_LCC156_NotPerformNearMaintenance.ResultWrapper rw = new XC_LCC156_NotPerformNearMaintenance.ResultWrapper();
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult ();
        List<XC_UTIL_Sobject.WrapperResult> listOfWrap = new List<XC_UTIL_Sobject.WrapperResult>();
        listOfWrap.add(dmlResult);
        XC_LCC156_NotPerformNearMaintenance.populateWrapperError(listOfWrap, rw);
        System.assertEquals(listOfWrap.isEmpty(), false);
    }
}