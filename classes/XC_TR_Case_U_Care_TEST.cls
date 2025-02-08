/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Description : TestClass for XC_TR_Case_U_Care
*@History: 2019-06-25 Creation
**/
@isTest
private class XC_TR_Case_U_Care_TEST {
	
	@TestSetup
	static void setup(){

		WorkType wt = XC_DF_WorkType.createWorkType('Delivery');
		insert wt;

		Case c = XC_DF_Case.createCases(1)[0];
		c.Reason = XC_AT_Constants.TRIGGER_REASON_MOT005;
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Complaint_Case').getRecordTypeId();

		WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
		wo.AccountId = c.AccountId;
		insert wo;

		c.XC_WorkOrder__c = wo.Id;
		insert c;
	  
	}

	@isTest static void createTasksFromCasesTest() {

		Case c = [SELECT Id,RecordTypeId,XC_WorkOrder__c,Reason FROM CASE WHERE XC_WorkOrder__c!=null  LIMIT 1];
		WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];


		System.Debug('CASE::::: ' + JSON.Serialize(c));


		Test.startTest();
			Map<Id,Case> mapWoCase = new Map<Id,Case>{
				wo.Id => c
			};
			XC_TR_Case_U_Care.createTasksFromCases(mapWoCase);
		Test.stopTest();


	}


	@isTest static void getWorkOrderByCaseIdsTest() {

		Case c = [SELECT Id,RecordTypeId FROM CASE LIMIT 1];
		Test.startTest();
			XC_TR_Case_U_Care.getWorkOrderByCaseIds(new Set<Id>{c.Id});
		Test.stopTest();


	}

	@isTest static void getWorkOrderInProvisioningByCaseIdsTest() {

		Case c = [SELECT Id,RecordTypeId FROM CASE LIMIT 1];
		Test.startTest();
			XC_TR_Case_U_Care.getWorkOrderInProvisioningByCaseIds(new Set<Id>{c.Id});
		Test.stopTest();


	}

	@isTest static void addOriginCaseTest() {

		Case c = [SELECT Id,RecordTypeId,Origin FROM CASE LIMIT 1];
		Test.startTest();
			XC_TR_Case_U_Care.addOriginCase(c);
		Test.stopTest();


	}
}