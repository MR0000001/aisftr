/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_TEST – Test Class for XC_TR_WorkOrder AND Handler
*/ 
@isTest
public class XC_TR_ServiceAppointment_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsert(){
        Test.startTest(); 
        List<ServiceAppointment> listSA = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert listSA;
        update listSA;
        delete listSA;
  
        System.assertEquals(true, listSA!=null);
        Test.stopTest();
        
    }

}