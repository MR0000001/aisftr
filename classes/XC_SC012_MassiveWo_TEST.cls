/** 
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 20/05/2019
* @description XC_SC012_MassiveWo_TEST – Test class for XC_SC012_MassiveWoPartner, XC_SC012_MassiveWoTech and XC_SC012_UTIL_MassiveWo
*/ 

@isTest
public class XC_SC012_MassiveWo_TEST {
    @isTest
    private static void massiveWOPartnerTest1(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; 
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_Dispatched;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
        }
        insert listServiceAppointmentPartner;
        Test.startTest();
        XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getIds(listWoToPartner);
        autoscheduleWrapper.destinationPartner = destinationPartnerAcc.Id;
        autoscheduleWrapper.originPartner = originPartnerAcc.Id;
        autoscheduleWrapper.updateDueDate = false;
        autoscheduleWrapper.outOfDate = false;
        autoscheduleWrapper.skipCheckCoverage = false;
        Database.executeBatch(new XC_SC012_MassiveWoPartner(autoscheduleWrapper), 100);
        Database.executeBatch(new XC_SC012_MassiveWoPartner(), 100);
        Test.stopTest();
    }
    
        @isTest
    private static void massiveWOPartnerTest2(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        /*List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; */
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            //sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_Dispatched;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
        }
        insert listServiceAppointmentPartner;
        Test.startTest();
        XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getIds(listWoToPartner);
        autoscheduleWrapper.destinationPartner = destinationPartnerAcc.Id;
        autoscheduleWrapper.originPartner = originPartnerAcc.Id;
        autoscheduleWrapper.updateDueDate = false;
        autoscheduleWrapper.outOfDate = false;
        autoscheduleWrapper.skipCheckCoverage = false;
        Database.executeBatch(new XC_SC012_MassiveWoPartner(autoscheduleWrapper), 100);
        Database.executeBatch(new XC_SC012_MassiveWoPartner(), 100);
        Test.stopTest();
    }
    
    @isTest
    private static void massiveWOTechTest1(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; 
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = 'None';
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
            sa.XC_Country__c = 'Spain';
            mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
        }
        insert listServiceAppointmentPartner;
        List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata(listServiceAppointmentPartner[0].XC_Country__c);
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c(Name = metaD[0].XC_Policy_Name__c);
        insert policy;
        Test.startTest();
        XC_SC012_MassiveWoTech.AutoScheduleTechWrapper autoscheduleWrapper = new XC_SC012_MassiveWoTech.AutoScheduleTechWrapper();
        XC_SC012_MassiveWoTech.CheckSuccessWrapper successWrapper = new XC_SC012_MassiveWoTech.CheckSuccessWrapper();
        successWrapper.mapWorkOrderServiceAppointment =mapWorkOrderServiceAppointment; 
        Map<String, String> mapWorkOrderPartner = new Map<String, String>();
        autoscheduleWrapper.destinationPartner = destinationPartnerAcc.Id;
        autoscheduleWrapper.originPartner = originPartnerAcc.Id;
        autoscheduleWrapper.updateDueDate = true;
        autoscheduleWrapper.outOfDate = true;
        autoscheduleWrapper.skipCheckCoverage = true;
        autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>{listWoToPartner[0].Id};
        Database.executeBatch(new XC_SC012_MassiveWoTech(autoscheduleWrapper), 100);
        //List<XC_MassiveAssignmentWorkOrderLog__c> msList = XC_SC012_MassiveWoTech.autoscheduleTech(successWrapper,mapWorkOrderPartner );
        Database.executeBatch(new XC_SC012_MassiveWoTech(), 100);
        Test.stopTest();
    }
    
    @isTest
    private static void utilMassiveTest1(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; 
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
        }
        insert listServiceAppointmentPartner;
        Test.startTest();
        XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getIds(listWoToPartner);
        autoscheduleWrapper.destinationPartner = destinationPartnerAcc.Id;
        autoscheduleWrapper.originPartner = originPartnerAcc.Id;
        autoscheduleWrapper.updateDueDate = false;
        autoscheduleWrapper.outOfDate = false;
        autoscheduleWrapper.skipCheckCoverage = false;
        Database.executeBatch(new XC_SC012_MassiveWoPartner(autoscheduleWrapper), 100);
        Database.executeBatch(new XC_SC012_MassiveWoPartner(), 100);
        Test.stopTest();
    }
    
    @isTest
    private static void utilMassiveTest2(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; 
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
            mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa);
        }
        insert listServiceAppointmentPartner;
        Test.startTest();
        XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getIds(listWoToPartner);
        autoscheduleWrapper.destinationPartner = destinationPartnerAcc.Id;
        autoscheduleWrapper.originPartner = originPartnerAcc.Id;
        autoscheduleWrapper.updateDueDate = false;
        autoscheduleWrapper.outOfDate = false;
        autoscheduleWrapper.skipCheckCoverage = false;
        XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
        UtilClass.scheduleServiceAppointment(true, new Map<String, Datetime>(),new Map<String, String>(), XC_UTIL_Sobject.getIds(listWoToPartner), mapWorkOrderServiceAppointment, listServiceResource, new List<XC_MassiveAssignmentWorkOrderLog__c>(), new List<XC_MassiveAssignmentWorkOrderLog__c>(),  originPartnerAcc.Id, destinationPartnerAcc.Id, 'TEST');
        Test.stopTest();
    }
    
    @isTest
    private static void utilMassiveTest3(){ 
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        Account destinationPartnerAcc = listPartner[0];
        Account originPartnerAcc = listPartner[1];
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listPartner, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listPartner[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource; 
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        List<Id> woIds = new List<Id>();
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
            woIds.add(sa.ParentRecordId); 
            mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa); 
        }
        insert listServiceAppointmentPartner;
        Test.startTest();
        XC_SC012_UTIL_MassiveWo.LogWrapper logWrapper = new XC_SC012_UTIL_MassiveWo.LogWrapper();
        logWrapper.workOrderIds = woIds; 
        logWrapper.mapWorkOrderServiceAppointment = mapWorkOrderServiceAppointment;
        logWrapper.originPartner = originPartnerAcc.ID;
        logWrapper.destinationPartner = destinationPartnerAcc.ID;
        logWrapper.errorMessage = Label.XC_CL_MassiveAssignmentWorkOrderErrorSkill;
        //logWrapper.mapWorkOrderOriginPartner = wrapper.mapWorkOrderOriginPartner;
        logWrapper.comments = 'TEST';
        XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
        UtilClass.insertErrorLog(logWrapper);
        UtilClass.insertSuccessLogs(logWrapper);
        UtilClass.populateSuccessLogs(logWrapper);
        Test.stopTest();
    }
    
    @isTest
    private static void utilMassiveTest4(){ 
        Map<String, ServiceAppointment> mapWorkOrderServiceAppointment = new Map<String, ServiceAppointment>();
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        insert serApp;
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now().addDays(-100);
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = serApp[0].Id;
        ar.ServiceResourceId = sr[0].Id;
        insert ar; 
        List<String> woIds = new List<String>(); 
      	for(ServiceAppointment sa : serApp) {
            woIds.add(sa.ParentRecordId); 
            mapWorkOrderServiceAppointment.put(sa.ParentRecordId, sa); 
        }
        Test.startTest();
        XC_SC012_UTIL_MassiveWo UtilClass = new XC_SC012_UTIL_MassiveWo();
        UtilClass.scheduleServiceAppointment(true, new Map<String, Datetime>(),new Map<String, String>(), woIds, mapWorkOrderServiceAppointment, sr, new List<XC_MassiveAssignmentWorkOrderLog__c>(), new List<XC_MassiveAssignmentWorkOrderLog__c>(),  sr[0].XC_Account__c,sr[0].XC_Account__c, 'TEST');

        Test.stopTest();
    }
}