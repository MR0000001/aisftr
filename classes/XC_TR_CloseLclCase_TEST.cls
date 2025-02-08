@isTest
public class XC_TR_CloseLclCase_TEST {
	
    @TestSetup
	static void setup(){

		WorkType wt = XC_DF_WorkType.createWorkType('Delivery');
		insert wt;
		List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelXItalia';
        c.XC_segment__c = 'B2B';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();

		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelXItalia';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
        insert wo;         
        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;      
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        insert woli;

		c.XC_WorkOrder__c = wo[0].Id;
        c.AccountId = acc[0].id;
        c.ContactId = contact[0].id;
        c.XC_WorkOrderLineItem__c = woli.id;
		insert c;
	  	
		
	}
    
    
    @isTest static void test1() {
		Test.startTest();
		Case c = [SELECT Id,RecordTypeId,XC_WorkOrder__c,Reason, Status, XC_WorkOrderLineItem__c FROM Case LIMIT 1];
		WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        c.status = 'ESTA007';
		c.XC_Resolution__c ='R016';
		c.XC_Result__c='RS015';
		c.CaseRemarks__c ='Test';
		update c;		
		Test.stopTest();
	}
        @isTest static void test2() {
		Test.startTest();
		Case c = [SELECT Id,RecordTypeId,XC_WorkOrder__c,Reason, Status, XC_WorkOrderLineItem__c FROM Case LIMIT 1];
		WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        c.status = 'ESTA007';
        c.SubCause__c = 'ATCL116';
		c.XC_Resolution__c ='R016';
		c.XC_Result__c='RS015';
		c.CaseRemarks__c ='Test';
        update c;		
		Test.stopTest();
	}
    @isTest static void test3() {
		Test.startTest();
		Case c = [SELECT Id,RecordTypeId,XC_WorkOrder__c,Reason, Status, XC_WorkOrderLineItem__c FROM Case LIMIT 1];
		WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        c.status = 'ESTA007';
        c.SubCause__c = 'ATCL117';
		c.XC_Resolution__c ='R016';
		c.XC_Result__c='RS015';
		c.CaseRemarks__c ='Test';
        update c;		
		Test.stopTest();
	}
}