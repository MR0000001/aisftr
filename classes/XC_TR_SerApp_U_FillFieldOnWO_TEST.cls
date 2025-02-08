/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceApp_U_CreateCI_TEST – Test Class for XC_TR_ServiceApp_U_CreateCustomInter
*/ 

@isTest
public class XC_TR_SerApp_U_FillFieldOnWO_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        //org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }

    static testMethod void onInsert(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, saList.size());
        Test.stopTest();
    }
}