/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 21/05/2019 
* @description XC_TR_ServiceApp_U_CaringManagement_TEST – Test class 
*/
@isTest
private  class XC_TR_ServiceApp_U_CaringManagement_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_Segment__c = 'B2C';
        listCase[0].Subcause__c = 'ATCL008';
        insert listCase;

        insert woList;
        woList[0].CaseId = listCase[0].Id;

        List<Case> woListCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :woList[0].CaseId];
        woList[0].ContactId = woListCase[0].ContactId;
        woList[0].AccountId = woListCase[0].AccountId;
        update woList;
		Test.stopTest();
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saListToIn = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saListToIn[0].XC_AssignedResource__c = srList[0].Id;
        saListToIn[0].Status=Label.XC_CL_ServiceAppointment_Scheduled; 
        saListToIn[0].SchedStartTime = DateTime.now().addHours(2);  
        saListToIn[0].SchedEndTime = DateTime.now().addHours(4); 
        insert saListToIn;
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        
    }
    static testMethod void checkInsertServiceAppointment() {
     	Test.startTest();
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment ];
        for(ServiceAppointment sa : servAppoInsert){
            sa.SchedStartTime = DateTime.now().addHours(2);  
            sa.SchedEndTime = DateTime.now().addHours(4); 
            //sa.XC_ReschedulingReason__c = Label.XC_CL_Rescheduling_Glovia; 
            //sa.Status =Label.XC_CL_ServiceAppointment_Canceled; 
            saListToUpdate.add(sa); 
        }

        update saListToUpdate;
        for(ServiceAppointment s : servAppoInsert){
            s.SchedStartTime = DateTime.now().addHours(1);  
            s.SchedEndTime = DateTime.now().addHours(3); 
            //s.XC_ReschedulingReason__c = Label.XC_CL_Rescheduling_Glovia; 
            s.Status =Label.XC_CL_ServiceAppointment_Canceled; 
            saListToUpdate.add(s); 
        }
     	map<id,ServiceAppointment> servmap = new map<id,ServiceAppointment>();
        servmap.putall(saListToUpdate);
        update servmap.values();

     
        //System.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
     
    }
    
    static testMethod void checkInsertServiceAppointment2() {

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList;
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saListToIn = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saListToIn[0].XC_AssignedResource__c = [SELECT Id FROM ServiceResource LIMIT 1].Id;
        insert saListToIn;

        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        for(ServiceAppointment sa : servAppoInsert){
            sa.SchedStartTime = DateTime.now().addHours(2);  
            sa.SchedEndTime = DateTime.now().addHours(4); 
            sa.XC_ReschedulingReason__c = Label.XC_CL_Rescheduling_Glovia;          
            saListToUpdate.add(sa);
        }
        Test.startTest();
        map<id,ServiceAppointment> servmap = new map<id,ServiceAppointment>();
        servmap.putall(saListToUpdate);
        try{
        update servmap.values();
        }
        catch(Exception e){
            System.debug('In Catch');
        }
        
        System.assertEquals(2, servAppoInsert.size());
        Test.stopTest();
    }
    
    static testMethod void checkInsertServiceAppointment3() {

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saListToIn = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saListToIn[0].Status = 'None';
        insert saListToIn;

        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment where Status = 'None'];
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Canceled';         
            saListToUpdate.add(sa);
        }
        Test.startTest();
        map<id,ServiceAppointment> servmap = new map<id,ServiceAppointment>();
        servmap.putall(saListToUpdate);
        try{
        update servmap.values();
        }
        catch(Exception e){
            System.debug('In Catch');
        }
        Test.stopTest();
    }
    
  /*  static testMethod void checkInsertServiceAppointment_Italia() {
        
        //SETUP
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_DocumentCountry__c = 'Italy';
        accList[0].XC_FirstName__c = 'Francesco';
        accList[0].XC_LastName__c = 'Russo  ';
        accList[0].IdentityType__c ='CF';
		accList[0].IdentityNumber__c ='RSSFNC80A01C352A';
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_CountryLegalEntity__c = 'ITALY';
        conList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert conList;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].XC_LegalEntity__c = 'EnelXItalia';
        woList[0].AccountId = accList[0].Id;
        woList[0].ContactId = conList[0].Id;
        
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_LegalEntity__c = 'EnelXItalia';
        listCase[0].AccountId = accList[0].Id;
        listCase[0].ContactId = conList[0].Id;
        listCase[0].Subcause__c = 'ATCL008';
        insert listCase;
        
        insert woList;
        woList[0].CaseId = listCase[0].Id;
        update woList;
        Test.startTest();
        List<ServiceResource> srList = [SELECT Id, XC_LegalEntity__c FROM ServiceResource];
        srList[0].XC_LegalEntity__c = 'EnelXItalia';
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saListToIn = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saListToIn[0].XC_AssignedResource__c = srList[0].Id;
        
        insert saListToIn;
        //////
        
        for(ServiceAppointment sa : saListToIn){
            sa.SchedStartTime = DateTime.now().addHours(2);  
            sa.SchedEndTime = DateTime.now().addHours(4); 
            sa.XC_ReschedulingReason__c = Label.XC_CL_Rescheduling_Glovia; 
            //sa.Status =Label.XC_CL_ServiceAppointment_Canceled; 
            saListToUpdate.add(sa); 
        }
        
        update saListToUpdate;
        for(ServiceAppointment s : saListToIn){
            s.SchedStartTime = DateTime.now().addHours(1);  
            s.SchedEndTime = DateTime.now().addHours(3); 
            s.XC_ReschedulingReason__c = Label.XC_CL_Rescheduling_Glovia; 
            //sa.Status =Label.XC_CL_ServiceAppointment_Canceled; 
            saListToUpdate.add(s); 
        }
        map<id,ServiceAppointment> servmap = new map<id,ServiceAppointment>();
        servmap.putall(saListToUpdate);
        update servmap.values();
        
        Test.stopTest();
    }*/

    static testMethod void checkInsertServiceAppointment5() {
		
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saListToIn = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saListToIn[0].Status = 'None';
        insert saListToIn;

        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment where Status = 'None'];
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Canceled';         
            saListToUpdate.add(sa);
        }
        
        update saListToUpdate;
        Test.stopTest();
    }
}