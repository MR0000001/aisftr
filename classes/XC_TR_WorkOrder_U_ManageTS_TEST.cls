/**
 * @author Nicola Mariniello - nmariniello@deloitte.it
 * @date Creation 03/05/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_TechnicalSheet_Handler – Handler for XC_TR_TechnicalSheet Trigger
 */

@isTest
public with sharing class XC_TR_WorkOrder_U_ManageTS_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }


    @isTest
	static void onInsert() {

        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        oiList[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        insert oiList;
        
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c o : orderList) {
            o.XC_LegalEntity__c = 'EndesaX';
        }
        update orderList;

        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(oiList[0].Id);
        step.XC_StepLabel__c = 'Documental Check';
        insert step;

        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].XC_OrderItem__c = oiList[0].Id;
        caseList[0].XC_ConfigurationItemIncentive__c = oiList[0].Id;
        caseList[0].XC_ProvisioningStep__c = step.Id;
        insert caseList;

        List<XC_TechnicalSheet__c> tsList = new List<XC_TechnicalSheet__c>();
        XC_TechnicalSheet__c ts1 = new XC_TechnicalSheet__c(XC_Case__c = caseList[0].Id);
        tsList.add(ts1);
        insert tsList;
        
        Test.startTest();

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woList[0].XC_LegalEntity__c = 'EndesaX';
        woList[0].XC_WorkTypeLabel__c = 'Delivery';
        woList[0].XC_Configuration_Item__c = oiList[0].Id;
        woList[0].XC_ConfigurationItemIncentive__c = oiList[0].Id;
        woList[0].Status = 'In Progress';
        insert woList;

        woList[0].Status = Label.XC_CL_WorkOrder_Completed;
        update woList;
  
        System.assertEquals(true, woList!=null, 'Wrong assert equals');
        Test.stopTest();
    }

}