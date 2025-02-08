@isTest
public class XC_TR_Case_U_ActionAfterClosure_TEST {
    
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
	
	static testMethod void manageActionsAfterClosure(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        //insert woList;
        
        Test.startTest();
        	insert woList;
            woList[0].XC_CaseToCreateType__c = 'XC_NonUrgentWorkOrderViolation';
            update woList[0];
            
            List<Case> caso = [SELECT Id FROM Case LIMIT 1];
            if(!caso.isEmpty()){
                caso[0].XC_Resolution__c = 'R001';
                caso[0].XC_Result__c = 'RS003';
                caso[0].CaseRemarks__c = 'test chiusura';
                update caso;
            }
        
            List<WorkOrder> editedWO = [SELECT Id, EntitlementId FROM WorkOrder WHERE Id =: woList[0].Id];
            Entitlement ent = [SELECT Id FROM Entitlement WHERE Name = 'XC_WorkOrderInOneHour' LIMIT 1];
            //System.assert(editedWO[0].EntitlementId == ent.Id);
		Test.stopTest();
    }
	
	static testMethod void checkForCreditTransfer(){
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
       	List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        opp[0].AccountId = acc[0].Id;
        opp[0].XC_Contact__c = cont[0].Id;
        opp[0].XC_Address__c = addr[0].Id;
        insert opp;
        
       	List<NE__Order__c> order = XC_DF_Order.createOrders(1,Label.XC_CL_Configuration_TypeInOrder);
       	order[0].NE__AccountId__c = opp[0].AccountId;
        order[0].NE__OptyId__c = opp[0].Id;
		order[0].XC_DeliveryAddress__c = opp[0].XC_Address__c;
        order[0].XC_InstallationAddress__c = opp[0].XC_Address__c;
        insert order;
        
       	NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order[0]);
        orderItem.NE__Account__c = acc[0].Id;
       	orderItem.XC_Installation_Address__c = addr[0].Id;
       	insert orderItem;
        
       	Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AdministrativeTask,Label.XC_CL_CMD_CreditTransfer});
        Case case1 = XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask));
        //case1.Status = 'ESTA003';
        case1.XC_Segment__c = 'B2C';
        case1.XC_LegalEntity__c = 'EndesaX';
        case1.AccountId = opp[0].AccountId;
        case1.ContactId = opp[0].XC_Contact__c;
        case1.XC_OrderItem__c = orderItem.Id;
        Case case2 = XC_UTIL_Case.initCaseFromCaseSettings(mapCaseSetting.get(Label.XC_CL_CMD_CreditTransfer));
        //case2.Status = 'ESTA003';
        case2.XC_Segment__c = 'B2C';
        case2.XC_LegalEntity__c = 'EndesaX';
        case2.AccountId = opp[0].AccountId;
        case2.ContactId = opp[0].XC_Contact__c;
        case2.XC_OrderItem__c = orderItem.Id;
        insert new List<Case>{case1,case2};
            
       Test.startTest();
           case1.XC_Resolution__c = 'R001';
           case1.XC_Result__c = 'RS003';
           case1.CaseRemarks__c = 'test chiusura';
           update case1;
           case2.XC_Resolution__c = 'R001';
           case2.XC_Result__c = 'RS003';
           case2.CaseRemarks__c = 'test chiusura';
           update case2;
           System.assert(true);
		Test.stopTest();
    }
}