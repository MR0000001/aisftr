/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification 04/05/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_SerApp_U_Rescheduling_TEST – Test Class for XC_TR_SerApp_U_Rescheduling
*/ 

@isTest
private class XC_TR_SerApp_U_Rescheduling_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    } 

    @isTest
    static void onUpdate() {
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.SchedStartTime = System.now().addDays(2);
            sa.SchedEndTime = System.now().addDays(2).addHours(2);
            sa.XC_ReschedulingReason__c = 'Glovia';
            saToUpdate.add(sa);
        }
        update saToUpdate;

        List<ServiceAppointment> saToReUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            sa.SchedEndTime = System.now().addDays(3).addHours(2);
            saToReUpdate.add(sa);
        }
        update saToReUpdate;
        saToReUpdate[0].ActualStartTime = DateTime.now().addYears(+50);
        update saToReUpdate;
        saToReUpdate[0].ActualEndTime = DateTime.now().addYears(+60);
        update saToReUpdate;
        Test.stopTest();
    }  
    
    @isTest
    static void onUpdate2() {
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.EarliestStartTime = System.now().addDays(2); 
            sa.XC_AssignToPartner__c = false; 
            saToUpdate.add(sa);
        }
        update saToUpdate;
        Test.stopTest();
    }

    @isTest
    static void onUpdate3(){
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.EarliestStartTime = System.now().addDays(2);
            saToUpdate.add(sa);
        }
        update saToUpdate;
        Test.stopTest();
    }  

    @isTest
    static void onUpdate4(){
        System.debug('Start onUpdate4 test ');
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            //
            sa.SchedStartTime = System.now().addDays(2);
            sa.SchedEndTime = System.now().addDays(2).addHours(2);
            //
            saToUpdate.add(sa);
        }
        update saToUpdate;

        saToUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            
            sa.XC_LegalEntity__c = 'EndesaX';
            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
            sa.SchedStartTime = System.now().addDays(3);
            sa.SchedEndTime = System.now().addDays(3).addHours(2);
            
            saToUpdate.add(sa);
        }

        update saToUpdate;

        saToUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            
            sa.XC_LegalEntity__c = 'EnelXItalia';
            sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
            sa.SchedStartTime = System.now().addDays(4);
            sa.SchedEndTime = System.now().addDays(4).addHours(2);
            
            saToUpdate.add(sa);
        }

        update saToUpdate;
        Test.stopTest();
        System.debug('End onUpdate4 test ');
    }  

    @isTest
    static void onUpdateItaly(){
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        saList[0].XC_LegalEntity__c = 'EnelXItalia';
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.SchedStartTime = System.now().addDays(2);
            sa.SchedEndTime = System.now().addDays(2).addHours(2);
            sa.XC_AssignToPartner__c = false;
            sa.XC_NumberOfRescheduling__c = 2;
            saToUpdate.add(sa);
        }
        update saToUpdate;

        List<ServiceAppointment> saToReUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            sa.SchedEndTime = System.now().addDays(3).addHours(2);
            saToReUpdate.add(sa);
        }
        update saToReUpdate;
        Test.stopTest();
    } 

    @isTest
    static void onUpdateAssignedPartnerfalse(){
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.SchedStartTime = System.now().addDays(2);
            sa.SchedEndTime = System.now().addDays(2).addHours(2);
            sa.XC_AssignToPartner__c = false;
            sa.XC_NumberOfRescheduling__c = 2;
            saToUpdate.add(sa);
        }
        update saToUpdate;
        Test.stopTest();
    } 

    @isTest
    static void onUpdateSpain(){
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        saList[0].XC_LegalEntity__c = 'EnelXItalia';
        insert saList;
        Test.startTest();
        for(ServiceAppointment sa : saList){
            sa.SchedStartTime = System.now().addDays(2);
            sa.SchedEndTime = System.now().addDays(2).addHours(2);
            saToUpdate.add(sa);
        }
        update saToUpdate;

        List<ServiceAppointment> saToReUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saList){
            sa.SchedEndTime = System.now().addDays(3).addHours(2);
            saToReUpdate.add(sa);
        }
        update saToReUpdate;
        Test.stopTest();
    } 

}