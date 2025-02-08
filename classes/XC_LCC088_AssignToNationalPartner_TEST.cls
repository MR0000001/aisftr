/**
* @author 
* @date Creation  15/05/2019 
* @description XC_LCC088_AssignToNationalPartner_TEST – Test class for XC_LCC088_AssignToNationalPartner
*/ 
@isTest
public with sharing class XC_LCC088_AssignToNationalPartner_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
        
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(1);
        User usersList = XC_DF_User.createUserAdmin();
        insert usersList;
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        Account nationalPartner = accountList[0];
        nationalPartner.XC_NationalPartner__c = true;
        update nationalPartner;
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = Label.XC_CL_ServiceResource_NationalPartner;
        serviceRes.XC_Account__c = nationalPartner.Id;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true;
        serviceRes.XC_IsManager__c = true;
        serviceRes.XC_AutomaticDeactivation__c = true;
        serviceRes.XC_LegalEntity__c = 'EndesaX';
        serviceRes.RelatedRecordId = usersList.Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
        serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c(Name = 'X-Customer');
        insert policy;
        //insert XC_DF_OperatingHours.createOperatingHours('Gold Appointments Calendar');
        List<ServiceTerritory> serTerList = XC_DF_ServiceTerritory.createServiceTerritories(new List<Account>{nationalPartner});
        insert serTerList;
        ServiceTerritoryMember serviceTerMember = new ServiceTerritoryMember();
        serviceTerMember.ServiceTerritoryId = serTerList[0].Id;
        serviceTerMember.ServiceResourceId = serviceRes.Id;
        serviceTerMember.EffectiveStartDate = System.today();
        insert serviceTerMember;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        wo[0].XC_Country__c = 'SPAIN';
        wo[0].XC_LegalEntity__c = 'EndesaX';
        wo[0].Status = 'New';
        insert wo[0];
        /*ServiceAppointment serviceAppointmentToInsert = new ServiceAppointment();
serviceAppointmentToInsert.Status = 'None';
serviceAppointmentToInsert.EarliestStartTime = (System.now()).addHours(2);
serviceAppointmentToInsert.DueDate = (System.now()).addHours(4);
serviceAppointmentToInsert.ParentRecordId = woList[0].Id;
serviceAppointmentToInsert.XC_Country__c = 'SPAIN';
insert serviceAppointmentToInsert;*/
        
    }
    
    //Test Method assignToNationalPartner
    static testMethod void retrieveNationalPartner1(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        List<String> nationalPartnerList = XC_LCC088_AssignToNationalPartner.retrieveNationalPartner( woList[0].Id);
        System.assertEquals(true, !nationalPartnerList.isEmpty());
        Test.stopTest();
    }
    
    static testMethod void retrieveNationalPartnerNoNationalPartner(){
        List<Account> accList = [SELECT Id FROM Account WHERE XC_NationalPartner__c=true LIMIT 1];
        Account nationalPartner = accList[0];
        nationalPartner.XC_NationalPartner__c = false;
        update nationalPartner;        
        Test.startTest();
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        List<String> nationalPartnerList = XC_LCC088_AssignToNationalPartner.retrieveNationalPartner( woList[0].Id);
        System.assertEquals(false, !nationalPartnerList.isEmpty());
        Test.stopTest();
    }    
    
    static testMethod void assignToNationalPartner(){
        XC_LCC088_AssignToNationalPartner.ResultWrapper resultWr= new XC_LCC088_AssignToNationalPartner.ResultWrapper();
        List<Account> accList = [SELECT Id, Name FROM Account WHERE XC_NationalPartner__c=true LIMIT 1];
        Account nationalPartner = accList[0];     
        Test.startTest();
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        resultWr = XC_LCC088_AssignToNationalPartner.assignToNationalPartner(nationalPartner.Name, woList[0].Id);
        System.assertEquals(true, resultWr.success);
        Test.stopTest();
    }    
    
    static testMethod void assignToNationalPartnerWithSA(){
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        XC_LCC088_AssignToNationalPartner.ResultWrapper resultWr= new XC_LCC088_AssignToNationalPartner.ResultWrapper();
        List<Account> accList = [SELECT Id, Name FROM Account WHERE XC_NationalPartner__c=true LIMIT 1];
        Account nationalPartner = accList[0];     
        ServiceAppointment serviceAppointmentToInsert = new ServiceAppointment();
        serviceAppointmentToInsert.Status = 'None';
        serviceAppointmentToInsert.EarliestStartTime = (System.now()).addHours(2);
        serviceAppointmentToInsert.DueDate = (System.now()).addHours(4);
        serviceAppointmentToInsert.ParentRecordId = woList[0].Id;
        serviceAppointmentToInsert.XC_Country__c = 'SPAIN';
        insert serviceAppointmentToInsert;
        Test.startTest();
        resultWr = XC_LCC088_AssignToNationalPartner.assignToNationalPartner(nationalPartner.Name, woList[0].Id);
        System.assertEquals(true, resultWr.success);
        Test.stopTest();
    }    
    static testMethod void assignToNationalPartnerStatusNotNew(){
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        WorkOrder wo = woList[0];
        wo.Status = Label.XC_CL_WorkOrder_Assigned;
        update wo;
        XC_LCC088_AssignToNationalPartner.ResultWrapper resultWr= new XC_LCC088_AssignToNationalPartner.ResultWrapper();
        List<Account> accList = [SELECT Id, Name FROM Account WHERE XC_NationalPartner__c=true LIMIT 1];
        Account nationalPartner = accList[0];     
        Test.startTest();
        
        resultWr = XC_LCC088_AssignToNationalPartner.assignToNationalPartner(nationalPartner.Name, wo.Id);
        System.assertEquals(false, resultWr.success);
        Test.stopTest();
    }  
}