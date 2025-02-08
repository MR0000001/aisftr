@isTest
public class XC_TR_Case_U_CongaCase_TEST {
    
    
    @TestSetup
    static void setup(){
        XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
		template.XC_LegalEntity__c = 'EnelSole';
        template.XC_AccountType__c = 'B2C';
        template.Name = 'LCL Case enelsole sospensione';
        template.XC_Country__c = 'Italy';
        template.XC_CaseTypeDocument__c='LCL Suspended';
        template.XC_IsCase__c = true;
        insert template;
                XC_CongaTemplateMapping__c template2 = new XC_CongaTemplateMapping__c ();
		template2.XC_LegalEntity__c = 'EnelSole';
        template2.XC_AccountType__c = 'B2C';
        template2.Name = 'LCL Case enelsole sospensione';
        template2.XC_Country__c = 'Italy';
        template2.XC_CaseTypeDocument__c='LCL Reactivated';
        template2.XC_IsCase__c = true;
        insert template2;
                XC_CongaTemplateMapping__c template3 = new XC_CongaTemplateMapping__c ();
		template3.XC_LegalEntity__c = 'EnelSole';
        template3.XC_AccountType__c = 'B2C';
        template3.Name = 'LCL Case enelsole sospensione';
        template3.XC_Country__c = 'Italy';
        template3.XC_CaseTypeDocument__c='LCL Extended';
        template3.XC_IsCase__c = true;
        insert template3;
    }
    
	@isTest
    static void test1() {
	  User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
                XC_CongaTemplateMapping__c template = new XC_CongaTemplateMapping__c ();
		template.XC_LegalEntity__c = 'EnelSole';
        template.XC_AccountType__c = 'B2B';
        template.Name = 'LCL Case enelsole sospensione';
        template.XC_Country__c = 'Italy';
        template.XC_CaseTypeDocument__c='LCL Suspended';
        template.XC_IsCase__c = true;
        insert template;
                XC_CongaTemplateMapping__c template2 = new XC_CongaTemplateMapping__c ();
		template2.XC_LegalEntity__c = 'EnelSole';
        template2.XC_AccountType__c = 'B2B';
        template2.Name = 'LCL Case enelsole sospensione';
        template2.XC_Country__c = 'Italy';
        template2.XC_CaseTypeDocument__c='LCL Reactivated';
        template2.XC_IsCase__c = true;
        insert template2;
                XC_CongaTemplateMapping__c template3 = new XC_CongaTemplateMapping__c ();
		template3.XC_LegalEntity__c = 'EnelSole';
        template3.XC_AccountType__c = 'B2B';
        template3.Name = 'LCL Case enelsole sospensione';
        template3.XC_Country__c = 'Italy';
        template3.XC_CaseTypeDocument__c='LCL Extended';
        template3.XC_IsCase__c = true;
        insert template3;
       	List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelSole';
        c.XC_segment__c = 'B2B';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();

		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelSole';
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
        c.SubCause__c = 'ATCL116';
        c.XC_LcLsuspended__c =true;
        c.XC_Generate_Case_Document__c=true;
        c.Country__c = 'Italy';
        List<Case> listCase = new List<Case>();

        system.runAs(u){
        Test.startTest();
        insert c;
        listCase.add(c);
        XC_TR_Case_U_CongaCase.checkDocumentType(listCase);
        Test.stoptest();
		}
    }
    
    	@isTest
    static void test2() {
	  User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
       	List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelSole';
        c.XC_segment__c = 'B2B';
        c.Country__c = 'Italy';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();

		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelSole';
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
        c.SubCause__c = 'ATCL115';
        c.XC_LcLsuspended__c =true;
        c.XC_Generate_Case_Document__c=true;
        List<Case> listCase = new List<Case>();
        system.runAs(u){
        Test.startTest();
        insert c;
                listCase.add(c);
        XC_TR_Case_U_CongaCase.checkDocumentType(listCase);
        Test.stoptest();
		}
    }
    
        	@isTest
    static void test3() {
	  User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
       	List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
		Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelSole';
        c.XC_segment__c = 'B2B';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();

		List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelSole';
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
        c.Country__c = 'Italy';
        c.AccountId = acc[0].id;
        c.ContactId = contact[0].id;
        c.XC_WorkOrderLineItem__c = woli.id;
        c.SubCause__c = 'ATCL117';
        c.XC_LcLsuspended__c =true;
        c.XC_Generate_Case_Document__c=true;
        List<Case> listCase = new List<Case>();
        system.runAs(u){
        Test.startTest();
        insert c;
                listCase.add(c);
        XC_TR_Case_U_CongaCase.checkDocumentType(listCase);
        Test.stoptest();
		}
    }
}