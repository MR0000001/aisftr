/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  15/05/2019 
* @description XC_LCC079_RemovePreferences_TEST – Test class for XC_LCC079_RemovePreferences
*/ 
@isTest
public with sharing class XC_LCC079_RemovePreferences_TEST {

    @TestSetup
    static void makeData(){
       User contextUser= [SELECT Id FROM User WHERE isActive = true AND  UserRoleId != null AND Profile.Name ='System Administrator' LIMIT 1];
       
        System.runAs(contextUser) {
             test.startTest();
             List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
            List<Contact> contactP = XC_DF_Contact.createPartnerContacts(accountList);
            insert contactP;
                List<User> usersList = XC_DF_User.createCommunityUsers(contactP,false);
            	insert usersList;
            Test.stopTest();
        
        }
       
    }

    //Test Method removePreferences
    static testMethod void removePreferences(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
        insert wo;
        String workOrderId = wo[0].Id;
        XC_LCC079_RemovePreferences.ResultWrapper rw = XC_LCC079_RemovePreferences.removePreferences(workOrderId);
    //System.assertEquals(false, rw.success);
    
    Test.stopTest();
    }

    static testMethod void removePreferencesTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
            List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
            for(WorkOrder w : wo){
                w.XC_Refusing_Reason__c = Label.XC_CL_CurrentlyNotAvailable;
            }
            insert wo;
            String workOrderId = wo[0].Id;
            XC_LCC079_RemovePreferences.ResultWrapper rw = XC_LCC079_RemovePreferences.removePreferences(workOrderId);
        //System.assertEquals(false, rw.success);
        
        Test.stopTest();
        }

    static testMethod void removePreferencesTest1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
            List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
            for(WorkOrder w : wo){
                w.XC_StatusReason__c = Label.XC_CL_StatusReason_NoAvailability;
            }
            insert wo;
            String workOrderId = wo[0].Id;
            XC_LCC079_RemovePreferences.ResultWrapper rw = XC_LCC079_RemovePreferences.removePreferences(workOrderId);
        //System.assertEquals(false, rw.success);
        
        Test.stopTest();
        }

//Test Method removePreferences2
        static testMethod void removePreferences2(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        wo[0].PostalCode = '28080';
        insert wo; 
        String workOrderId = wo[0].Id;
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = [SELECT Id FROM Account];
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = false;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[0].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;
        ServiceResourceSkill servResSkill = new ServiceResourceSkill();
        List<Skill> skillList = [SELECT Id, MasterLabel, DeveloperName FROM Skill WHERE MasterLabel =: Label.XC_CL_CommercialVisit];
        servResSkill.SkillId = skillList[0].Id;
        servResSkill.ServiceResourceId = serviceResourcesToInsert[0].Id;
        servResSkill.SkillLevel = 1;
        servResSkill.XC_CertificationStartDate__c = System.today();
        servResSkill.XC_CertificationEndDate__c = System.today().addYears(5);
        servResSkill.EffectiveEndDate = System.today().addYears(5);
        servResSkill.EffectiveStartDate = System.today(); 
        List<ServiceResource> sr= XC_DF_ServiceResource.createServiceResources(1);
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: serviceResourcesToInsert[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = serviceResourcesToInsert[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;

        List<ResourcePreference> rplist = new List<ResourcePreference>();
        insert rplist;
        ResourcePreference rp = new ResourcePreference(PreferenceType ='Required',RelatedRecordId= wo[0].Id, ServiceResourceId = sr[0].Id);
        insert rp; 
        rplist.add(rp);
        update rplist; 

       Test.startTest();
       List<WorkOrder> woList =  [SELECT id, PostalCode, (SELECT Id from ResourcePreferences) FROM WorkOrder];  
       System.debug('@@@woList-->' +woList);
       XC_LCC079_RemovePreferences.ResultWrapper rw = XC_LCC079_RemovePreferences.removePreferences(workOrderId);
    //System.assertEquals(false, rw.success);
    Test.stopTest();
    }
    
    
    //Test Method removePreferences2
  		@isTest
        static  void removePreferences3(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        wo[0].PostalCode = '28080';
        wo[0].XC_StatusReason__c =Label.XC_CL_StatusReason_NoAvailability;
        insert wo; 
        String workOrderId = wo[0].Id;
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = [SELECT Id FROM Account];
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = false;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[0].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;
        ServiceResourceSkill servResSkill = new ServiceResourceSkill();
        List<Skill> skillList = [SELECT Id, MasterLabel, DeveloperName FROM Skill WHERE MasterLabel =: Label.XC_CL_CommercialVisit];
        servResSkill.SkillId = skillList[0].Id;
        servResSkill.ServiceResourceId = serviceResourcesToInsert[0].Id;
        servResSkill.SkillLevel = 1;
        servResSkill.XC_CertificationStartDate__c = System.today();
        servResSkill.XC_CertificationEndDate__c = System.today().addYears(5);
        servResSkill.EffectiveEndDate = System.today().addYears(5);
        servResSkill.EffectiveStartDate = System.today(); 
        List<ServiceResource> sr= XC_DF_ServiceResource.createServiceResources(1);
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: serviceResourcesToInsert[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = serviceResourcesToInsert[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;

        List<ResourcePreference> rplist = new List<ResourcePreference>();
        insert rplist;
        ResourcePreference rp = new ResourcePreference(PreferenceType ='Required',RelatedRecordId= wo[0].Id, ServiceResourceId = sr[0].Id);
        insert rp; 
        rplist.add(rp);
        update rplist; 

       Test.startTest();
       List<WorkOrder> woList =  [SELECT id, PostalCode, (SELECT Id from ResourcePreferences) FROM WorkOrder];  
       System.debug('@@@woList-->' +woList);
         XC_LCC079_RemovePreferences.ResultWrapper rw = XC_LCC079_RemovePreferences.removePreferences(workOrderId);
    //System.assertEquals(false, rw.success);
    Test.stopTest();
    }
  
}