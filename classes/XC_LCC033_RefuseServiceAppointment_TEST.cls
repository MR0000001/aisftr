/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  28/05/2019 
* @description XC_LCC033_RefuseServiceAppointment_TEST – Test class for XC_LCC033_RefuseServiceAppointment
*/
@isTest
public class XC_LCC033_RefuseServiceAppointment_TEST {
    
    //Test Method changesSerAppointment
    @isTest
    static void changesSerAppointment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<ServiceAppointment> listsapp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert listsapp;
        
        
        XC_LCC033_RefuseServiceAppointment.ResultWrapper rw = XC_LCC033_RefuseServiceAppointment.changesSerAppointment(listsapp[0].Id,'test');   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method changesSerAppointment2
    @isTest
    static void changesSerAppointment2(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        List<ServiceAppointment> listsapp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        for(ServiceAppointment sa : listsapp){
            sa.Status = 'Scheduled';
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2);
        }
        insert listsapp;
        
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(2);
        for(ServiceResource sr : srList){
            sr.XC_IsManager__c = true;
        }
        update srList;
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: srList[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        for (ServiceResource sr: srList) {
            ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
            srtmemb.ServiceTerritoryId = srt[0].Id;
            srtmemb.ServiceResourceId = sr.Id;
            srtmemb.EffectiveStartDate = DateTime.now().addDays(-7);
            srtmemb.OperatingHoursId = opH.Id;
            stmList.add(srtmemb);
        }
        
        insert stmList;
        Test.startTest(); 
        AssignedResource assResToSerApp = new AssignedResource();
        assResToSerApp.ServiceAppointmentId = listsapp[0].Id;
        assResToSerApp.ServiceResourceId = srList[0].Id;
        insert assResToSerApp;
        User u3 = [ select id, (select id, ResourceType from ServiceResources) from user where id in (select RelatedRecordId from ServiceResource) ][0];
        
        XC_LCC033_RefuseServiceAppointment.ResultWrapper rw;
        
        System.runAs(u3) {
            rw = XC_LCC033_RefuseServiceAppointment.changesSerAppointment(listsapp[0].Id,'Currently not Available');   
        }
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }

     //Test Method changesSerAppointment3
    @isTest
    static void changesSerAppointment3(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Group dispatcherQueue = new Group (Name = 'XC_ESP_DispatcherQueue');
        insert dispatcherQueue;
        
        List<ServiceAppointment> listsapp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        for(ServiceAppointment sa : listsapp){
            sa.Status = 'None';
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2);
            sa.XC_LegalEntity__c = 'EndesaX';
        }
        insert listsapp;
        
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(3);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: srList[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        for (ServiceResource sr: srList) {
            ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
            srtmemb.ServiceTerritoryId = srt[0].Id;
            srtmemb.ServiceResourceId = sr.Id;
            srtmemb.EffectiveStartDate = DateTime.now().addDays(-15);
            srtmemb.OperatingHoursId = opH.Id;
            stmList.add(srtmemb);
        }
        
        insert stmList;
        Test.startTest(); 
        List<ServiceResource> srToUpdate = new List<ServiceResource>();
        List<ServiceResource> srToChange = [SELECT Id, IsCapacityBased, ResourceType from ServiceResource where id != :srList[0].Id];

        for (ServiceResource sr : srToChange) {
            sr.IsCapacityBased = false;
            srToUpdate.add(sr);
        }
        update srToUpdate;
        
        AssignedResource assResToSerApp = new AssignedResource();
        assResToSerApp.ServiceAppointmentId = listsapp[0].Id;
        assResToSerApp.ServiceResourceId = srList[1].Id;
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(assResToSerApp);
        User u3 = [ select id, (select id, ResourceType from ServiceResources) from user where id in (select RelatedRecordId from ServiceResource where id != :srList[1].Id) ][0];
        
        XC_LCC033_RefuseServiceAppointment.ResultWrapper rw;
        // todo creare un tecnico, il DF fa solo partner
        System.runAs(u3) {
            rw = XC_LCC033_RefuseServiceAppointment.changesSerAppointment(listsapp[0].Id,'Currently not Available');   
        }
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }

    
     //Test Method changesSerAppointment3
    /*@isTest
    static void changesSerAppointment4(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<ServiceAppointment> listsapp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        for(ServiceAppointment sa : listsapp){
            sa.Status = 'None';
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2);
        }
        insert listsapp;
        
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(3);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: srList[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        for (ServiceResource sr: srList) {
            ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
            srtmemb.ServiceTerritoryId = srt[0].Id;
            srtmemb.ServiceResourceId = sr.Id;
            srtmemb.EffectiveStartDate = DateTime.now().addDays(-15);
            srtmemb.OperatingHoursId = opH.Id;
            stmList.add(srtmemb);
        }
        
        insert stmList;
        List<ServiceResource> srToUpdate = new List<ServiceResource>();
        List<ServiceResource> srToChange = [SELECT Id, IsCapacityBased, ResourceType from ServiceResource where id != :srList[0].Id];
        srList[0].XC_IsManager__c = true;
        srToUpdate.add(srList[0]);
        for (ServiceResource sr : srToChange) {
            sr.IsCapacityBased = false;
            srToUpdate.add(sr);
        }
        update srToUpdate;
        
        AssignedResource assResToSerApp = new AssignedResource();
        assResToSerApp.ServiceAppointmentId = listsapp[0].Id;
        assResToSerApp.ServiceResourceId = srList[1].Id;
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(assResToSerApp);
        User u3 = [ select id, (select id, ResourceType from ServiceResources) from user where id in (select RelatedRecordId from ServiceResource where id != :srList[0].Id) ][0];
        
        XC_LCC033_RefuseServiceAppointment.ResultWrapper rw;
        // todo creare un tecnico, il DF fa solo partner
        System.runAs(u3) {
            rw = XC_LCC033_RefuseServiceAppointment.changesSerAppointment(listsapp[0].Id,'Currently not Available');   
        }
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }*/
    
    //Test Method setResourceToExcluded
    @isTest
    static void setResourceToExcluded(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        listwo[0].XC_Segment__c = 'B2C';
        insert listwo;
        
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        
        User u = [ select id, (select id, ResourceType, XC_IsManager__c from ServiceResources) from user where id in (select RelatedRecordId from ServiceResource) ][0];
       
        system.debug('Chiara'+' '+u.ServiceResources);
        
        // crea sr e poi associa l'id dello user
        
        XC_UTIL_Sobject.WrapperResult rw = XC_LCC033_RefuseServiceAppointment.setResourceToExcluded(u,listwo[0]);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method setResourceToExcluded1
    @isTest
    static void setResourceToExcluded1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        listwo[0].XC_Segment__c = 'B2C';
        insert listwo;
        
        
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        User u = [ select id, (select id, ResourceType, XC_IsManager__c from ServiceResources) from user where id in (select RelatedRecordId from ServiceResource) ][0];
 
        ResourcePreference rp = new ResourcePreference();
        rp.RelatedRecordId = listwo[0].Id;
        rp.ServiceResourceId= sr[0].Id;
        insert rp;
        update listwo;
        
        WorkOrder wo = [select id, (select id,ServiceResourceId from ResourcePreferences) from workorder where id in (select relatedrecordid from ResourcePreference)][0];
        
        system.debug('Chiara'+' '+u.ServiceResources);
        
        // crea sr e poi associa l'id dello user
        
        XC_UTIL_Sobject.WrapperResult rw = XC_LCC033_RefuseServiceAppointment.setResourceToExcluded(u,wo);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method updateServiceAppointment
    @isTest
    static void updateServiceAppointment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<ServiceAppointment> listsapp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert listsapp;
        
        
        XC_UTIL_Sobject.WrapperResult rw = XC_LCC033_RefuseServiceAppointment.updateServiceAppointment(listsapp[0],'Currently not Available', true);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method updateWorkOrder
    @isTest
    static void updateWorkOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        listwo[0].XC_Segment__c = 'B2C';
        insert listwo;
        
        
        XC_UTIL_Sobject.WrapperResult rw = XC_LCC033_RefuseServiceAppointment.updateWorkOrder(listwo[0],'Currently not Available', true);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }

    @isTest
    static void insertAssignedResouceAndUpdateWoAndSA(){
        Test.startTest();
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation', 'Delivery & Installation');
        listOfWo[0].XC_Segment__c = 'B2C';
        insert listOfWo;
        List<ServiceAppointment> listOfSa = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        insert listOfSa;
        List<ServiceResource> listOfSR = XC_DF_ServiceResource.createServiceResources(1);
        String partnerId = listOfSR[0].Id;
        XC_LCC033_RefuseServiceAppointment.ParameterWrapper wrap = new XC_LCC033_RefuseServiceAppointment.ParameterWrapper();
        wrap.serAppToChange = listOfSa[0];
        wrap.workOrderToChange = listOfWo [0];
        XC_LCC033_RefuseServiceAppointment.insertAssignedResouce(wrap, partnerId);
        XC_LCC033_RefuseServiceAppointment.updateWoAndSA(wrap);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrderAndServiceAppointment(){
        List<ServiceResource> listOfSR = XC_DF_ServiceResource.createServiceResources(1);
        List<User> listOfUserSR = new List<User>([SELECT Id FROM User WHERE Id =:listOfSR[0].RelatedRecordId]);
        XC_LCC033_RefuseServiceAppointment.ParameterWrapper wrap = new XC_LCC033_RefuseServiceAppointment.ParameterWrapper();
        wrap.currentUser = listOfUserSR[0];
        XC_LCC033_RefuseServiceAppointment.updateWorkOrderAndServiceAppointment(wrap, Label.XC_CL_StatusReason_Pendingassigntechnician);
    }

}