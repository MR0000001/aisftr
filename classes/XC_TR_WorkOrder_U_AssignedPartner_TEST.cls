/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  17/08/2021 
* @description XC_TR_WorkOrder_U_AssignedPartner_TEST – Test class for XC_TR_WorkOrder_U_AssignedPartner
*/ 
@isTest
public class XC_TR_WorkOrder_U_AssignedPartner_TEST {
    @TestSetup
    static void insertData(){
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EndesaX';
        insert order;
        List<Account> partnerAccountList = XC_DF_Account.insertPartnerAccounts(2);
    }
    
    static testMethod void updateAssignedPartnerField() {
        List<Account> partnerList = [SELECT Id FROM Account];
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        WorkOrder wo = woList[0];
        wo.XC_Configuration__c = orderList[0].Id;
        wo.XC_AssignedPartner__c = partnerList[0].Id;
        insert woList;
        Test.startTest();
        wo.XC_AssignedPartner__c = partnerList[1].Id;
        update wo;
        Test.stopTest();
    }
}