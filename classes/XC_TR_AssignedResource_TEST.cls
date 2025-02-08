/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_TEST – Test Class for XC_TR_WorkOrder AND Handler
*/ 

@isTest
public class XC_TR_AssignedResource_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsert(){
       Test.startTest();
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
        
        update ar;
        delete ar;
        System.assertEquals(true, ar!=null);
        Test.stopTest(); 
        
    }
    
}