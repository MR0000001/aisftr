/**
* @author Nicola Arrigo
* @date Creation dd/mm/yyyy
* @description  
*/ 
@isTest
public with sharing class XC_TR_onHoldWOUpdates_Test {
    
    @testSetup 
    static void methodName(){
        User u = XC_DF_User.createUserAdmin();
        u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
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
            List<ServiceAppointment> listServiceAppointment=XC_DF_ServiceAppointment.createServiceAppointment(wo);
            listServiceAppointment[0].XC_Segment__c='B2B';
            listServiceAppointment[0].Status='Scheduled';
            listServiceAppointment[0].XC_LegalEntity__c = 'EnelSole';
            //   listServiceAppointment[0].StatusCategory='In Progress';
            insert listServiceAppointment;
        }
    }
    
    static testmethod void onHoldWOFillSuspencionReplanning(){
        
        user u=[select id from User where XC_LegalEntity__c='EnelXItalia' order by createddate desc limit 1 ];
        WorkOrder wo=[select id,Status,XC_ReasonforSuspension__c,XC_Notesforsuspensionandresolution__c 
                      from WorkOrder order by createddate desc limit 1];    
        List<ServiceAppointment> listServiceAppointment=[select id,XC_ReasonforSuspension__c,XC_Notesforsuspensionandresolution__c,ParentRecordId,Status,XC_NotesforResolution__c
                                                         from ServiceAppointment where ParentRecordId=:wo.id];     
        system.runAs(u){
            listServiceAppointment[0].XC_ReasonforSuspension__c='Richiesta Preventivo';
            listServiceAppointment[0].XC_Notesforsuspensionandresolution__c='Altro';
            listServiceAppointment[0].XC_NotesforResolution__c='Altro'; 
            update listServiceAppointment;
            wo.Status='Assigned';
            update wo;
            listServiceAppointment[0].Status = 'Dispatched';
            update listServiceAppointment;
            FSL.GlobalAPIS.addStatusTransition('Dispatched','On Hold');
            FSL.GlobalAPIS.addStatusTransition('On Hold','In Progress');
            /*	listServiceAppointment[0].Status='In Progress'; 
            update listServiceAppointment;*/    
            wo.Status='On Hold';
            update wo;
            wo.Status='In Progress';
            Update wo;  
            
            /*listServiceAppointment[0].ActualStartTime = System.now();
            listServiceAppointment[0].ActualEndTime = System.now();
            listServiceAppointment[0].Status='On Hold'; 
            update listServiceAppointment;*/
        }
    }
}