/**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 02/04/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_WorkOrder_U_ManageMilestone_TEST - Test Class of XC_TR_WorkOrder_U_ManageMilestone
 */
@isTest
public class XC_TR_WorkOrder_U_ManageMilestone_TEST {
    
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
    
        
	static testMethod void urgentRepairTest(){
             
		List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        Test.startTest();   
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_AssignmentDate__c = System.now().addHours(-3);  
        woList[0].Status = 'Assigned';
        woList[0].XC_WorkTypeCategory__c = 'Repair';
        woList[0].XC_Urgent_Repair__c = true;
        Entitlement ent = [SELECT Id from Entitlement where SlaProcess.Name =: 'XC_UrgentWorkOrder' LIMIT 1];
        woList[0].EntitlementId = ent.Id;
        insert woList;
        woList[0].XC_StatusReason__c = Label.XC_CL_StatusReason_ConfirmedByTechnician;
        update woList;
        Test.stopTest();
    }
    
            
	static testMethod void nonUrgentTest(){
             
		List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        Test.startTest();   
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_AssignmentDate__c = System.now().addHours(-3);  
        woList[0].Status = 'Assigned';
        woList[0].XC_WorkTypeCategory__c = 'Commercial Visit';
        woList[0].XC_Urgent_Repair__c = true;
        Entitlement ent = [SELECT Id from Entitlement where SlaProcess.Name =: 'XC_WorkOrderInOneHour' LIMIT 1];
        woList[0].EntitlementId = ent.Id;
        insert woList;
        woList[0].XC_ScheduledStart__c = System.now().addMinutes(5);
        update woList;
        Test.stopTest();
    }

}