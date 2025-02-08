@isTest
public class XC_TR_WorkOrder_U_SLAManagement_TEST {
    
    @TestSetup
	static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
		List<Account> accInit = XC_DF_Account.createResidentialAccounts(1);
        insert accInit;
		
        Map<Id,SlaProcess> sLAEntitlementProcessMap = new Map<Id,SlaProcess>([SELECT Id, Name FROM SlaProcess WHERE Name IN ('XC_WorkOrderInOneHour','XC_UrgentWorkOrder')]);
        List<Entitlement> entls = new List<Entitlement>();
        Entitlement ent;
        for(SlaProcess slaP : sLAEntitlementProcessMap.values()){
            ent = new Entitlement();
            ent.Name = slaP.Name;
            ent.AccountId = accInit[0].Id;
            ent.SlaProcessId = slaP.Id;
            entls.add(ent);
        }
        insert entls;
    }
    
	static testMethod void assignSLA_WorkOrderInOneHour(){
        
        Test.startTest();        
		List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        
        insert woList;
        
        WorkOrder createdWO = [SELECT Id, EntitlementId FROM WorkOrder WHERE Id =: woList[0].Id LIMIT 1];
        Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'XC_WorkOrderInOneHour' LIMIT 1];
        //System.assert(createdWO.EntitlementId == ent.Id);
        Test.stopTest();
    }
    
	static testMethod void assignSLA_UrgentWorkOrder(){
        
        Test.startTest();        
		List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Urgent_Repair__c = true;

        insert woList;
        
        WorkOrder createdWO = [SELECT Id, EntitlementId FROM WorkOrder WHERE Id =: woList[0].Id LIMIT 1];
        Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'XC_UrgentWorkOrder' LIMIT 1];
        //System.assert(createdWO.EntitlementId == ent.Id);
        Test.stopTest();
    }
    
	static testMethod void assignSLA_updateEntitlement(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        List<Asset> ass = XC_DF_Asset.createAssets(acc);
        ass[0].XC_LegalEntity__c = 'EndesaX';
        insert ass;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].AssetId = ass[0].Id;
        woList[0].XC_Urgent_Repair__c = true;

        insert woList;
        
        Test.startTest();
        	woList[0].Status = 'Assigned';
        	update woList[0];
        	woList[0].XC_StatusReason__c = 'Confirmed by technician';
        	update woList[0];
        
            WorkOrder createdWO = [SELECT Id, EntitlementId FROM WorkOrder WHERE Id =: woList[0].Id LIMIT 1];
            Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'XC_WorkOrderInOneHour' LIMIT 1];
            //System.assert(createdWO.EntitlementId == ent.Id);
		Test.stopTest();
    }
    
	static testMethod void checkForMilestonesViolations_caseUrgent(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Urgent_Repair__c = true;

        insert woList;
        
        Test.startTest();
        	woList[0].XC_CaseToCreateType__c = 'XC_UrgentWorkOrderViolation';
        	update woList[0];
        
            List<Case> caso = [SELECT Id FROM Case LIMIT 1];
            List<WorkOrder> editedWO = [SELECT Id, EntitlementId, XC_UrgentEntitlementCounter__c FROM WorkOrder WHERE Id =: woList[0].Id];
            //System.assert(caso.size() == 1);
            ////System.assert(editedWO[0].EntitlementId == null);
            //System.assert(editedWO[0].XC_UrgentEntitlementCounter__c == 1);
		Test.stopTest();
    }
    
	static testMethod void checkForMilestonesViolations_caseNonUrgent(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Urgent_Repair__c = true;

        insert woList;
        
        Test.startTest();
        	woList[0].XC_CaseToCreateType__c = 'XC_NonUrgentWorkOrderViolation';
        	update woList[0];
        
            List<Case> caso = [SELECT Id FROM Case LIMIT 1];
            List<WorkOrder> editedWO = [SELECT Id, EntitlementId FROM WorkOrder WHERE Id =: woList[0].Id];
            //System.assert(caso.size() == 1);
            ////System.assert(editedWO[0].EntitlementId == null);
		Test.stopTest();
    }
    
}