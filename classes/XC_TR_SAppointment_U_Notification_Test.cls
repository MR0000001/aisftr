/**
* @author De Blasio Valentina - valentina.de.blasio@accenture.com
* @date Creation 28/04/2021
* @description  – XC_TR_ServiceAppointment_U_Notification class  
*/ 
@isTest
public class XC_TR_SAppointment_U_Notification_Test {

        static testMethod void sendNotification() {
      
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
        List<Contact> cont=XC_DF_Contact.createPartnerContacts(accList);
        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1,'Delivery')[0];
        workOrderTest.AccountId = accList[0].Id;
        workOrderTest.XC_LegalEntity__c='EnelXItalia';
        workOrderTest.RecordTypeID = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        insert workOrderTest;
        AccountTeamMember accmember = new AccountTeamMember(UserId = UserInfo.getUserId(), AccountId = accList[0].id , TeamMemberRole='Tecnico Gestionale'); 
        insert accmember ;
            
        List<ServiceAppointment> serviceAppointment =  XC_DF_ServiceAppointment.createServiceAppointment(1);
        serviceAppointment[0].ArrivalWindowEndTime = System.now().addDays(3);
        serviceAppointment[0].ArrivalWindowStartTime = System.now();
        serviceAppointment[0].XC_Country__c = 'SPAIN';
        serviceAppointment[0].EarliestStartTime = System.now().addDays(-1);
        serviceAppointment[0].DueDate = System.now().addHours(10);
        serviceAppointment[0].ParentRecordId = workOrderTest.Id ;
        serviceAppointment[0].Status='On Hold';  
        serviceAppointment[0].XC_ReasonforSuspension__c='Forza Maggiore';
    //    serviceAppointment[0].XC_Notesforsuspensionandresolution__c='test'; 
        insert serviceAppointment;
            
        Case cases=new Case(AccountId = accList[0].Id, XC_BusinessLine__c = 'eCity',XC_LegalEntity__c='EnelXItalia' );
        insert cases;    
            
        Test.startTest();        
        List<AccountTeamMember> ac=[Select id,AccountId,userId from AccountTeamMember where TeamMemberRole='Tecnico Gestionale' limit 1 ];   
        System.debug('@@accteammember '+ac);  
        List<ServiceAppointment> listSa=[Select id,ParentRecordId,Accountid,country,status,XC_Segment__c,XC_ReasonforSuspension__c,AppointmentNumber from ServiceAppointment where AccountId=:ac[0].AccountId and ParentRecordId!='' limit 1];
		System.debug('@@@@sabefore'+listSa[0]);
        Map<Id, ServiceAppointment> mapOld=new  Map<Id, ServiceAppointment>();
        mapOld.put(listSa[0].id,listSa[0]);
        System.debug('@@@@mapold'+mapOld);
        List<ServiceAppointment> listSa2=[Select id,ParentRecordId,Accountid,country,status,XC_Segment__c,XC_ReasonforSuspension__c,AppointmentNumber from ServiceAppointment where AccountId=:ac[0].AccountId and ParentRecordId!='' limit 1];
        listSa2[0].XC_ReasonforSuspension__c='Richiesta Preventivo';
        listSa2[0].XC_Notesforsuspensionandresolution__c='test';    
        update  listSa2[0];
        List<Case> caso=[Select id from case where XC_BusinessLine__c ='eCity'limit 1];
        List<WorkOrder> wo=[Select id,WorkOrderNumber,CaseId,XC_LegalEntity__c,Account.name,AccountId,XC_WorkTypeCategory__c,XC_Segment__c,Case.XC_BusinessLine__c from WorkOrder where id=:listSa[0].ParentRecordid limit 1];
        wo[0].caseId=caso[0].id;
        wo[0].XC_Segment__c='B2B';
        wo[0].XC_WorkTypeCategory__c='Malfunctioning';
        wo[0].XC_LegalEntity__c='EnelXItalia';
        update wo[0];
        System.debug('@@worder'+wo);
        System.debug('@@@@sa'+listSa[0]);
      
        
        Map<Id, ServiceAppointment> mapnew=new  Map<Id, ServiceAppointment>();
        mapnew.put(listSa2[0].id,listSa2[0]);        
        XC_TR_ServiceAppointment_U_Notification.sendNotificationServiceAppointment(mapOld,mapnew);
        Test.stopTest();
        }
         
        }