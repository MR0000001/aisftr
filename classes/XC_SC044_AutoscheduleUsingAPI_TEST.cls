/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 17/03/2021
* @description XC_SC044_AutoscheduleUsingAPI_TEST – Test class for XC_SC044_AutoscheduleUsingAPI
*/

@isTest
private class XC_SC044_AutoscheduleUsingAPI_TEST {

    @isTest
    static void onExecuteBatch() {
        insert new OneOrg__c(Name='OneOrg (User)', XC_Spain_Triggers__c=true);
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        
        WorkType wt = [SELECT Id, XC_AssignToPartner__c FROM WorkType];
        wt.XC_Segment__c = 'B2C';
        wt.XC_LegalEntity__c = 'EndesaX';
        update wt;
        
        WorkOrder wo = woList[0];
        wo.XC_Segment__c = 'B2C';
        wo.XC_LegalEntity__c = 'EndesaX';
        wo.PostalCode = '28080';
        wo.XC_FSLAssignmentKey__c = '28080';
        wo.WorkTypeId = wt.Id;
        insert wo; 

        XC_ZipCodeWorkType__c zcwt = new XC_ZipCodeWorkType__c(
            XC_ZipCode__c = '28080',
            XC_WorkType__c = wt.Id
        );
        insert zcwt;
        List<Account> listAcc = XC_DF_Account.insertPartnerAccounts(1);
        
        PermissionSetAssignment psa = [
            SELECT Id, AssigneeId, Assignee.name 
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name IN ('FSL_Resource_License') and Assignee.profile.name = 'System Administrator' and Assignee.IsActive =true
            LIMIT 1
        ];
        Id userId = psa.AssigneeId; 

        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = listAcc[0].Name;
        serviceRes.XC_Account__c = listAcc[0].Id;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true; 
        serviceRes.RelatedRecordId = userId; 
        serviceRes.XC_IsManager__c = true;
        serviceRes.isCapacityBased = true;
        serviceRes.ResourceType = 'T';
        serviceRes.XC_LegalEntity__c = 'EndesaX';
        insert serviceRes; 
        
        
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c(
            XC_Account__c = serviceRes.XC_Account__c,
            XC_WorkType__c = wt.Id,
            XC_ZipCode__c = '28080',
            XC_ZipCodeWorkType__c = zcwt.Id,
            XC_ExternalId__c = '28080_' + wt.Id
        );
        insert pc;
        
        FSL__Scheduling_Policy__c schedPolicy = new FSL__Scheduling_Policy__c(
            Name = 'X-Customer'
        );
        insert schedPolicy;
        
        List<ServiceTerritory> listST = XC_DF_ServiceTerritory.createServiceTerritories(listAcc);
        ServiceTerritory st = listST[0];
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            EffectiveStartDate = System.now(),
            ServiceResourceId = serviceRes.Id,
            ServiceTerritoryId = st.Id,
            XC_Country__c = 'Spain',
            TerritoryType = 'P'
        );
        insert stm;
        
        OperatingHours op = [SELECT Id FROM OperatingHours Limit 1];
        op.Name ='Gold Appointments Calendar';
        update op;
        Timeslot ts = new TimeSlot(
            EndTime = Time.newInstance(18, 30, 2, 20),
            StartTime = Time.newInstance(17, 30, 2, 20),
            OperatingHoursId = op.Id,
            Type = 'Normal',
            DayOfWeek = 'Sunday'
        );
        insert ts;
         
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        ServiceAppointment sa = listSa[0]; 
        sa.XC_ProcessedWithCustomAutoschedule__c = false;
        sa.XC_ProcessedWithStandardAutoschedule__c = true; 
        sa.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_PlannedMaintenance;
        sa.XC_Segment__c = 'B2C';
        sa.XC_LegalEntity__c = 'EndesaX';  
        sa.XC_AssignToPartner__c = wt.XC_AssignToPartner__c;
        sa.XC_ZipCedeWorkType__c = zcwt.Id;
        insert sa;     

        Test.startTest();          
        XC_SC044_AutoscheduleUsingAPI myClass = new XC_SC044_AutoscheduleUsingAPI();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }

}