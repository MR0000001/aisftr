/**
 * The Class XC_LCC141_BookNearMaintenance_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 28/08/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_LCC141_BookNearMaintenance_Test – Test class for XC_LCP141_BookNearMaintenance Component
 */
@isTest
public without sharing class XC_LCC141_BookNearMaintenance_Test {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
        static Testmethod void succededTest(){
            insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
            List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Repair');
            serApp[0].SchedStartTime = DateTime.now();
            serApp[0].SchedEndTime = DateTime.now().addHours(2);
            serApp[0].Status = 'Scheduled';
            serApp[0].ActualDuration = 1.0;
            insert serApp;
            List<ServiceAppointment> listOfWoOfSa = new List <ServiceAppointment> ([SELECT Id, ParentRecordId
                                                                                    FROM ServiceAppointment
                                                                                    WHERE Id =: serApp[0].id]);
            listOfWoOfSa[0].XC_WorkTypeCategory__c ='Planned Maintenance';
            update listOfWoOfSa;
            OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
            List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
            List<ServiceResource> srQuerata = new List<ServiceResource>([SELECT Id
                                                                            FROM ServiceResource]);
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
            insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
            List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory]; 
            ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
            srtmemb.ServiceTerritoryId = srt[0].Id;
            srtmemb.ServiceResourceId = sr[0].Id;
            srtmemb.TerritoryType = 'P';
            srtmemb.EffectiveStartDate = DateTime.now().addDays(-15);
            srtmemb.OperatingHoursId = opH.Id;
            insert srtmemb; 
            AssignedResource assResource = new AssignedResource();
            assResource.ServiceAppointmentId = serApp[0].id;
            assResource.ServiceResourceId = sr[0].id;
            insert assResource;
            WorkOrder woTest = new WorkOrder(Id = listOfWoOfSa[0].ParentRecordId);
            woTest.XC_AssignedResource__c = sr[0].Id;
            woTest.XC_WorkTypeCategory__c = 'Repair';
            woTest.Status = 'Assigned';
            update woTest;
            Test.startTest(); 
            XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(woTest.id);
            Test.stopTest();
            System.assertEquals(wr.success, true);
        }

    static Testmethod void succededTestDurationNull(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Repair');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        serApp[0].ActualDuration = 1.0;
        insert serApp;
        List<ServiceAppointment> listOfWoOfSa = new List <ServiceAppointment> ([SELECT Id, ParentRecordId
                                                                                FROM ServiceAppointment
                                                                                WHERE Id =: serApp[0].id]);
        listOfWoOfSa[0].XC_WorkTypeCategory__c ='Planned Maintenance';
        update listOfWoOfSa;
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> srQuerata = new List<ServiceResource>([SELECT Id
                                                                        FROM ServiceResource]);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory]; 
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.TerritoryType = 'P';
        srtmemb.EffectiveStartDate = DateTime.now().addDays(-15);
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb; 
        AssignedResource assResource = new AssignedResource();
        assResource.ServiceAppointmentId = serApp[0].id;
        assResource.ServiceResourceId = sr[0].id;
        insert assResource;
        WorkOrder woTest = new WorkOrder(Id = listOfWoOfSa[0].ParentRecordId);
        woTest.XC_AssignedResource__c = sr[0].Id;
        woTest.XC_WorkTypeCategory__c = 'Repair';
        woTest.Status = 'Assigned';
        woTest.Duration = null;
        update woTest;
        Test.startTest(); 
        XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(woTest.id);
        Test.stopTest();
        System.assertEquals(wr.success, true);
    }

    static Testmethod void noServiceAppointment(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_Repair);
        listOfWo[0].XC_WorkTypeCategory__c = Label.XC_CL_Repair;
        insert listOfWo;
        Test.startTest();
        XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(listOfWo[0].id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

    static Testmethod void workOrderWithDifferentWorkTypeCat(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listOfWo[0].XC_WorkTypeCategory__c = 'Commercial Visit';
        insert listOfWo;
        Test.startTest();
        XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(listOfWo[0].id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

    static Testmethod void workOrderWithMaintenanceIsNearTrue(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        listOfWo[0].XC_MaintenanceIsNear__c = true;
        insert listOfWo;
        Test.startTest();
        XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(listOfWo[0].id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

    static Testmethod void workOrderWithNoAssignedResource(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Repair');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        serApp[0].ActualDuration = 1.0;
        insert serApp;
        List<ServiceAppointment> listOfWoOfSa = new List <ServiceAppointment> ([SELECT Id, ParentRecordId
                                                                                FROM ServiceAppointment
                                                                                WHERE Id =: serApp[0].id]);
        listOfWoOfSa[0].XC_WorkTypeCategory__c ='Planned Maintenance';
        update listOfWoOfSa;
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> srQuerata = new List<ServiceResource>([SELECT Id
                                                                        FROM ServiceResource]);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory]; 
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.TerritoryType = 'P';
        srtmemb.EffectiveStartDate = DateTime.now().addDays(-15);
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        WorkOrder woTest = new WorkOrder(Id = listOfWoOfSa[0].ParentRecordId);
        woTest.XC_AssignedResource__c = sr[0].Id;
        woTest.XC_WorkTypeCategory__c = 'Repair';
        woTest.Status = 'Assigned';
        update woTest;
        Test.startTest(); 
        XC_LCC141_BookNearMaintenance.ResultWrapper wr = XC_LCC141_BookNearMaintenance.bookNearMaintenance(woTest.id);
        Test.stopTest();
        System.assertEquals(wr.success, false);
    }

}