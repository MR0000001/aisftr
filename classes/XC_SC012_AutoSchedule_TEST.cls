/** 
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 20/05/2019
* @description XC_SC012_AutoSchedule_TEST – Test class for XC_SC012_AutoScheduleToPartner and XC_SC012_AutoScheduleToTechnician
*/ 

@isTest
private class XC_SC012_AutoSchedule_TEST {
    @isTest
    static  void extecuteBatchForPartner() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(2);
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount, false);
        for(Integer i=0; i<listServiceResource.size(); i++) {
            listServiceResource[i].XC_Account__c = listAccount[i].Id;
            listServiceResource[i].XC_IsManager__c = true;
        }
        update listServiceResource;
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_Dispatched;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.FSL__Pinned__c = false;
        }
        insert listServiceAppointmentPartner;

        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test';
        insert operatingHours;

        List<ServiceTerritory> listServiceTerritory = new List<ServiceTerritory>();
        for(Account account : listAccount) {
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Test'+String.valueOf(Math.random());
            st.Street = 'Via Test';
            st.City = 'Madrid';
            st.State = 'Spain';
            st.PostalCode = '20800';
            st.Country = 'Spain';
            st.IsActive = true;
            st.XC_AccountId__c = account.Id;
            st.XC_Country__c = 'SPAIN';
            st.FSL__Hide_Emergency_Map__c = false;
            st.FSL__TerritoryLevel__c = 0;
            st.OperatingHoursId = operatingHours.Id;
            listServiceTerritory.add(st);
        }
        insert listServiceTerritory;

        List<ServiceTerritoryMember> listServiceTerritoryMember = new List<ServiceTerritoryMember>();
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceTerritoryMember stm = new ServiceTerritoryMember();
            stm.ServiceTerritoryId = listServiceTerritory[i].Id;
            stm.ServiceResourceId = listServiceResource[i].Id;
            stm.TerritoryType = 'P';
            stm.EffectiveStartDate = Datetime.Now().addDays(-15);
            stm.EffectiveEndDate = Datetime.Now().addDays(15);
            stm.OperatingHoursId = operatingHours.Id;
            stm.XC_Country__c = 'SPAIN';
            listServiceTerritoryMember.add(stm);
        }
        insert listServiceTerritoryMember;

        List<AssignedResource> listAssignedResource = new List<AssignedResource>();
        for(Integer i=0; i<listServiceAppointmentPartner.size(); i++) {
            AssignedResource ar = new AssignedResource();
            ar.ServiceAppointmentId = listServiceAppointmentPartner[i].Id;
            ar.ServiceResourceId = listServiceResource[0].Id;
            ar.FSL__Last_Updated_Epoch__c = 1557765567384.0;
            ar.FSL__UpdatedByOptimization__c = false;
            ar.FSL__calculated_duration__c = 60;
            listAssignedResource.add(ar);
        }
        insert listAssignedResource;
 
        List<ServiceResourceSkill> listServiceResourceSkill = new List<ServiceResourceSkill>();
        Skill skillCommercialVisit = [SELECT Id FROM Skill WHERE DeveloperName = 'Commercial_Visit' LIMIT 1];
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceResourceSkill srs = new ServiceResourceSkill();
            srs.SkillLevel = 1;
            srs.SkillId = skillCommercialVisit.Id;
            srs.EffectiveStartDate = Datetime.Now().addDays(-10);
            srs.EffectiveEndDate = Datetime.Now().addDays(10);
            srs.ServiceResourceId = listServiceResource[i].Id;
            listServiceResourceSkill.add(srs);
        }
        insert listServiceResourceSkill;

        List<ServiceResourceSkill> listSr = new List<ServiceResourceSkill>([SELECT Id, EffectiveStartDate, EffectiveEndDate FROM ServiceResourceSkill WHERE Id =: listServiceResourceSkill]);
        System.debug('##### listSr----> ' +listSr);
        for(ServiceResourceSkill sr : listSr){
            sr.EffectiveEndDate = sr.EffectiveEndDate.addDays(11);    
        }
        update listSr;
        List<SkillRequirement> listSkillReq = new List<SkillRequirement>();
        for(WorkOrder wo : listWoToPartner) {
            SkillRequirement skillReq = new SkillRequirement();
            skillReq.XC_Country__c = 'SPAIN';
            skillReq.SkillLevel = 1;
            skillReq.SkillId = skillCommercialVisit.Id;
            skillReq.RelatedRecordId = wo.Id;
            listSkillReq.add(skillReq);
        } 
        insert listSkillReq;


        XC_SC012_AutoScheduleToPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_AutoScheduleToPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getListFieldValues(listWoToPartner, 'Id');
        autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();
        autoscheduleWrapper.destinationPartner = listAccount[1].Id;
        autoscheduleWrapper.originPartner = listAccount[0].Id;
        autoscheduleWrapper.updateDueDate = true;
        autoscheduleWrapper.outOfDate = true;            
        System.assertEquals(autoscheduleWrapper != null , true);       
        Test.startTest();
        XC_SC012_AutoScheduleToPartner autoschedulPartner = new XC_SC012_AutoScheduleToPartner();
        Database.executeBatch(new XC_SC012_AutoScheduleToPartner(autoscheduleWrapper));
        Test.stopTest();        
    }

    /*@isTest
    static void extecuteBatchForPartnerWithError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(2);
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResourcesFromAccount(listAccount, false);
        for(ServiceResource sr : listServiceResource) {
            sr.XC_IsManager__c = true;
        }
        update listServiceResource;
        List<WorkOrder> listWoToPartner = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToPartner;
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToPartner);
        Integer k=0;
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_Dispatched;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.PostalCode = listWoToPartner[k].PostalCode+k;
            k++;
        }
        insert listServiceAppointmentPartner;
        System.debug('@@@ listServiceAppointmentPartner ---> ' + listServiceAppointmentPartner);
 
        List<ServiceResourceSkill> listServiceResourceSkill = new List<ServiceResourceSkill>();
        Skill skillCommercialVisit = [SELECT Id FROM Skill WHERE DeveloperName = 'Commercial_Visit' LIMIT 1];
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceResourceSkill srs = new ServiceResourceSkill();
            srs.SkillLevel = 1;
            srs.SkillId = skillCommercialVisit.Id;
            srs.EffectiveStartDate = Datetime.Now().addDays(-10);
            srs.EffectiveEndDate = Datetime.Now().addDays(10);
            srs.ServiceResourceId = listServiceResource[i].Id;
            listServiceResourceSkill.add(srs);
        }
        insert listServiceResourceSkill;

        
        XC_SC012_AutoScheduleToPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_AutoScheduleToPartner.AutoSchedulePartnerWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getListFieldValues(listWoToPartner, 'Id');
        autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();
        autoscheduleWrapper.destinationPartner = listAccount[1].Id;
        autoscheduleWrapper.originPartner = listAccount[0].Id;
        autoscheduleWrapper.updateDueDate = true;
        autoscheduleWrapper.outOfDate = true;            
        System.assertEquals(autoscheduleWrapper != null , true);

        Test.startTest();
        XC_SC012_AutoScheduleToPartner autoschedulPartner = new XC_SC012_AutoScheduleToPartner();
        Database.executeBatch(new XC_SC012_AutoScheduleToPartner(autoscheduleWrapper));
        Test.stopTest();        
    }*/

    @isTest
    static void extecuteBatchForTech() {
        insert XC_DF_OneOrg.createOneOrg('Spain');

        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c();
        schedPolicy.Name = 'X-Customer';
        insert schedPolicy;

        List<Account> listAccount = XC_DF_Account.insertPartnerAccounts(2);
        
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true];
        List<ServiceResource> listServiceResource = new List<ServiceResource>();
        Integer j = 0;
        for(Account accnt : listAccount){
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = accnt.Name;
            serviceRes.XC_Account__c = accnt.Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = false;
            serviceRes.XC_AutomaticDeactivation__c = false;
            if(!usersList.isEmpty() && j<usersList.size()) {
                serviceRes.RelatedRecordId = usersList[j].Id; 
                listServiceResource.add(serviceRes);
            }
            j++;
        }
        insert listServiceResource;

        List<WorkOrder> listWoToTech = XC_DF_WorkOrder.createWorkOrders(2, 'Commercial Visit');
        insert listWoToTech;
        List<ServiceAppointment> listServiceAppointmentPartner = XC_DF_ServiceAppointment.createServiceAppointment(listWoToTech);
        for(ServiceAppointment sa : listServiceAppointmentPartner) {
            sa.XC_AssignedResource__c = listServiceResource[0].Id;
            sa.Status = Label.XC_CL_ServiceAppointment_Dispatched;
            sa.SchedStartTime = Datetime.Now().addDays(-7);
            sa.SchedEndTime = Datetime.Now().addDays(7);
            sa.XC_Country__c = 'SPAIN';
        }
        insert listServiceAppointmentPartner;

        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test';
        insert operatingHours;

        List<ServiceTerritory> listServiceTerritory = new List<ServiceTerritory>();
        for(Account account : listAccount) {
            ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Test'+String.valueOf(Math.random());
            st.Street = 'Via Test';
            st.City = 'Madrid';
            st.State = 'Spain';
            st.PostalCode = '20800';
            st.Country = 'Spain';
            st.IsActive = true;
            st.XC_AccountId__c = account.Id;
            st.XC_Country__c = 'SPAIN';
            st.FSL__Hide_Emergency_Map__c = false;
            st.FSL__TerritoryLevel__c = 0;
            st.OperatingHoursId = operatingHours.Id;
            listServiceTerritory.add(st);
        }
        insert listServiceTerritory;

        List<ServiceTerritoryMember> listServiceTerritoryMember = new List<ServiceTerritoryMember>();
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceTerritoryMember stm = new ServiceTerritoryMember();
            stm.ServiceTerritoryId = listServiceTerritory[i].Id;
            stm.ServiceResourceId = listServiceResource[i].Id;
            stm.TerritoryType = 'P';
            stm.EffectiveStartDate = Datetime.Now().addDays(-15);
            stm.EffectiveEndDate = Datetime.Now().addDays(15);
            stm.OperatingHoursId = operatingHours.Id;
            stm.XC_Country__c = 'SPAIN';
            listServiceTerritoryMember.add(stm);
        }
        insert listServiceTerritoryMember;

        List<AssignedResource> listAssignedResource = new List<AssignedResource>();
        for(Integer i=0; i<listServiceAppointmentPartner.size(); i++) {
            AssignedResource ar = new AssignedResource();
            ar.ServiceAppointmentId = listServiceAppointmentPartner[i].Id;
            ar.ServiceResourceId = listServiceResource[0].Id;
            ar.FSL__Last_Updated_Epoch__c = 1557765567384.0;
            ar.FSL__UpdatedByOptimization__c = false;
            ar.FSL__calculated_duration__c = 60;
            listAssignedResource.add(ar);
        }
        insert listAssignedResource;
 
        List<ServiceResourceSkill> listServiceResourceSkill = new List<ServiceResourceSkill>();
        Skill skillCommercialVisit = [SELECT Id FROM Skill WHERE DeveloperName = 'Commercial_Visit' LIMIT 1];
        for(Integer i=0; i<listServiceResource.size(); i++) {
            ServiceResourceSkill srs = new ServiceResourceSkill();
            srs.SkillLevel = 1;
            srs.SkillId = skillCommercialVisit.Id;
            srs.EffectiveStartDate = Datetime.Now().addDays(-10);
            srs.EffectiveEndDate = Datetime.Now().addDays(10);
            srs.ServiceResourceId = listServiceResource[i].Id;
            listServiceResourceSkill.add(srs);
        }
        insert listServiceResourceSkill;

        List<SkillRequirement> listSkillReq = new List<SkillRequirement>();
        for(WorkOrder wo : listWoToTech) {
            SkillRequirement skillReq = new SkillRequirement();
            skillReq.XC_Country__c = 'SPAIN';
            skillReq.SkillLevel = 1;
            skillReq.SkillId = skillCommercialVisit.Id;
            skillReq.RelatedRecordId = wo.Id;
            listSkillReq.add(skillReq);
        } 
        insert listSkillReq;

        
        XC_SC012_AutoScheduleToTechnician.AutoScheduleTechWrapper autoscheduleWrapper = new XC_SC012_AutoScheduleToTechnician.AutoScheduleTechWrapper();
        autoscheduleWrapper.listIdWorkOrderAssignToTechnician = XC_UTIL_Sobject.getListFieldValues(listWoToTech, 'Id');
        autoscheduleWrapper.destinationPartner = listAccount[1].Id;
        autoscheduleWrapper.originPartner = listAccount[0].Id;
        autoscheduleWrapper.updateDueDate = true;
        autoscheduleWrapper.outOfDate = true;   
        System.assertEquals(autoscheduleWrapper != null , true);

        Test.startTest();
        Database.executeBatch(new XC_SC012_AutoScheduleToTechnician(autoscheduleWrapper));
        
        
        XC_UTIL_AutoSchedule.AutoSchedulingResult res = new XC_UTIL_AutoSchedule.AutoSchedulingResult();
        res.success = false;
        XC_SC012_AutoScheduleToTechnician.CheckSuccessWrapper chWr = new XC_SC012_AutoScheduleToTechnician.CheckSuccessWrapper();
        chWr.sa = listServiceAppointmentPartner[0];
        chWr.mapIdServiceAppointmentWorkOrder = new Map<String,String>{listServiceAppointmentPartner[0].Id => listWoToTech[0].Id};
        chWr.mapWorkOrderServiceAppointment = new Map<String,ServiceAppointment >{listWoToTech[0].Id => listServiceAppointmentPartner[0]};
        new XC_SC012_AutoScheduleToTechnician(autoscheduleWrapper).insertLog(res, chWr);
        Test.stopTest();       
    }

    @isTest
    static void onUtilTest() {
       List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(2);
       insert listServiceAppointment;
       XC_SC012_AutoSchedule_U autoScheduleU = new XC_SC012_AutoSchedule_U();
       List<Account> listAccount = XC_DF_Account.createResidentialAccounts(2); 
       insert listAccount;
       Test.startTest();
       autoScheduleU.insertNoMathStatusLogError(listServiceAppointment, listAccount[0].id, listAccount[1].id );
       
       Test.stopTest();
       System.assertEquals(listAccount.isEmpty(), false); 
    }
}