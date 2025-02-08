@istest
public class XC_TR_CheckApprovalPartner_Test {
static testmethod void checkDocumentType(){
       	insert XC_DF_OneOrg.createOneOrg('Spain');
    	test.startTest();
    	User u = XC_DF_User.createUserAdmin();
    	insert u;
    	system.runAs(u){
    	WorkType work= XC_DF_WorkType.createWorkType('Organizer');
    	insert work;
   		List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Organizer');
        wo[0].XC_Segment__c = 'B2B';
        wo[0].XC_LegalEntity__c = 'EnelSole';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
    	wo[0].XC_Country__c = 'Italy';        
        insert wo;

        /*WorkOrderLineItem woli1 = new WorkOrderLineItem();   		  	
        woli1.WorkOrderId= wo[0].Id;
        woli1.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
        woli1.XC_WOLIType__c='Material Supply';
    	insert woli1;*/

        List<WorkOrder> wo2 = XC_DF_WorkOrder.createWorkOrders(1,'Installation');
        wo2[0].XC_Segment__c = 'B2B';
        wo2[0].XC_LegalEntity__c = 'EnelSole';
        wo2[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo2[0].AccountId = acc[0].id;
    	wo2[0].XC_Country__c = 'Italy';     
    	wo2[0].ParentWorkOrderId=wo[0].id;
        insert wo2; 

        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo2[0].Id;
        woli.XC_WOLIType__c='Partner Payment';
        
    	insert woli;

    	test.stopTest();
        }
}
    static testmethod void checkDocumentType2(){
       	insert XC_DF_OneOrg.createOneOrg('Spain');
    	test.startTest();
    	User u = XC_DF_User.createUserAdmin();
        insert u;
    	system.runAs(u){
    	WorkType wor= XC_DF_WorkType.createWorkType('Organizer');
        insert wor;
            List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
         List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
      	 List<WorkOrder> wo2 = XC_DF_WorkOrder.createWorkOrders(1,'Organizer');
        wo2[0].XC_Segment__c = 'B2B';
        wo2[0].XC_LegalEntity__c = 'EnelSole';
        wo2[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo2[0].AccountId = acc[0].id;
    	wo2[0].XC_Country__c = 'Italy';     
        insert wo2;  
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo2[0].Id;
        woli.XC_WOLIType__c='Good Issue';
        woli.Status = 'In Progress';
    	insert woli;
        woli.Status = 'Completed';
    	update woli;
    	test.stopTest();
        }
}
     static testmethod void checkDocumentType3(){
       	insert XC_DF_OneOrg.createOneOrg('Spain');
    	test.startTest();
        User u = XC_DF_User.createUserAdmin();
    	insert u;
    	system.runAs(u){
    	WorkType work= XC_DF_WorkType.createWorkType('Planned Maintenance');
    	insert work;
   		List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Planned Maintenance');
        wo[0].XC_Segment__c = 'B2B';
        wo[0].XC_LegalEntity__c = 'EnelSole';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
    	wo[0].XC_Country__c = 'Italy';        
        insert wo;         
        List<WorkOrder> wo2 = XC_DF_WorkOrder.createWorkOrders(1,'Planned Maintenance');
        wo2[0].XC_Segment__c = 'B2B';
        wo2[0].XC_LegalEntity__c = 'EnelSole';
        wo2[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo2[0].AccountId = acc[0].id;
    	wo2[0].XC_Country__c = 'Italy';     
    	wo2[0].ParentWorkOrderId=wo[0].id;
        insert wo2; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo2[0].Id;
        woli.Status = 'In Progress';
        woli.XC_WOLIType__c='Good Issue';
        woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';
    	insert woli;
        woli.Status = 'Completed';
    	update woli;
        
    	test.stopTest();
        }
}
      static testmethod void checkDocumentType4(){
       	insert XC_DF_OneOrg.createOneOrg('Spain');
    	test.startTest();
        User u = XC_DF_User.createUserAdmin();
    	insert u;
    	system.runAs(u){
    	WorkType work= XC_DF_WorkType.createWorkType('Planned Maintenance');
    	insert work;
   		List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, 'Planned Maintenance');
        wo[0].XC_Segment__c = 'B2B';
        wo[0].XC_LegalEntity__c = 'EnelSole';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
    	wo[0].XC_Country__c = 'Italy';        
        insert wo;         
        List<WorkOrder> wo2 = XC_DF_WorkOrder.createWorkOrders(1,'Planned Maintenance');
        wo2[0].XC_Segment__c = 'B2B';
        wo2[0].XC_LegalEntity__c = 'EnelSole';
        wo2[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo2[0].AccountId = acc[0].id;
    	wo2[0].XC_Country__c = 'Italy';     
    	wo2[0].ParentWorkOrderId=wo[0].id;
        insert wo2; 
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo2[0].Id;
        woli.Status = 'In Progress';
        woli.XC_WOLIType__c='Partner Payment';
        woli.XC_ApprovalProcessCheckGoodIssue__c='Non Esiste alcuna Good Issue associata';
    	insert woli;
        //woli.Status = 'Completed';
    	//update woli;
        
    	test.stopTest();
        }
}
}