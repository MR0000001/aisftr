@isTest
public with sharing class XC_TR_IN075CheckApprovalPartner_Test {
    @testSetup
    private static void setup(){
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
        WorkOrderLineItem woli1 = new WorkOrderLineItem();   		  	
        woli1.WorkOrderId= wo[0].Id;
        woli1.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
        woli1.XC_WOLIType__c='Material Supply';
    	insert woli1;
        List<WorkOrder> wo2 = XC_DF_WorkOrder.createWorkOrders(1,'Installation');
        wo2[0].XC_Segment__c = 'B2B';
        wo2[0].XC_LegalEntity__c = 'EnelSole';
        wo2[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo2[0].AccountId = acc[0].id;
    	wo2[0].XC_Country__c = 'Italy';     
    	wo2[0].ParentWorkOrderId=wo[0].id;
        insert wo2; 
        List<WorkOrderLineItem> woliToInsert=new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        woli.WorkOrderId= wo2[0].Id;
        woli.XC_WOLIType__c='Partner Payment';       
    	insert woli;
        woliToInsert.add(woli);
    }
 }
 @isTest
    static void methodTestInsertPartnerPayment(){
        List<WorkOrderLineItem> woliToInsert=[select id,XC_WOLIType__c from WorkOrderLineitem where 
                                               XC_WOLIType__c='Partner Payment' order by createddate desc ];
        User u=[select id from user order by createddate desc limit 1];
        system.runAs(u){
            List<XC_IN075_CheckApprovalPartnerPayment.InputWrapper> inputWrapperList = new List<XC_IN075_CheckApprovalPartnerPayment.InputWrapper>();
            XC_IN075_CheckApprovalPartnerPayment.InputWrapper inputWrapper=new XC_IN075_CheckApprovalPartnerPayment.InputWrapper();
            inputWrapper.woliId= woliToInsert[0].id;
            inputWrapper.woliType=woliToInsert[0].XC_WOLIType__c;
            inputWrapperList.add(inputWrapper);
            try{
                XC_IN075_CheckApprovalPartnerPayment.checkInsertPartnerPayment(inputWrapperList);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
         }
        }                                      
    }