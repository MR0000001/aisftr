@isTest
public without sharing class TA_LCC252_AppointmentToBeConfirmed_Test {

    @testSetup
    static void setup() {
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);

        ServiceResource sr = new ServiceResource();
        sr.Name = accountList[0].Name;
        sr.XC_Account__c = accountList[0].Id;
        sr.IsActive = true;
        sr.IsCapacityBased = true;
        sr.XC_AutomaticDeactivation__c = false;
        sr.RelatedRecordId = UserInfo.getUserId();
        insert sr;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,'Delivery & Installation');
        insert woList;

        ServiceAppointment sa = new ServiceAppointment();
        sa.SchedStartTime = system.now();
        sa.SchedEndTime = system.now() + 1;
        sa.XC_AssignedResource__c = sr.id;
        sa.XC_StatusReason__c = 'To be scheduled';
        sa.ParentRecordId = woList[0].id;
        insert sa;

        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr.XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];

        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr.Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar').Id;
        stmList.add(srtmemb);
        insert stmList;

        AssignedResource ar = new AssignedResource();
        ar.ServiceResourceId = sr.Id;
        ar.ServiceAppointmentId = sa.Id;
        insert ar;
    }

    @isTest
    public static void initialize_Test() {
        Test.startTest();
        TA_LCC252_AppointmentToBeConfirmed.initialize();
        Test.stopTest();
    }
}