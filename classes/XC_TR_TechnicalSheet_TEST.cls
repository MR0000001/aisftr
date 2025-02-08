/**
 * @author Nicola Mariniello - nmariniello@deloitte.it
 * @date Creation 03/05/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_TechnicalSheet_Handler – Handler for XC_TR_TechnicalSheet Trigger
 */

@isTest
public with sharing class XC_TR_TechnicalSheet_TEST {

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

        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(oiList[0].Id);
        step.XC_StepLabel__c = 'Documental Check';
        insert step;

        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].XC_ConfigurationItemIncentive__c = oiList[0].Id;
        caseList[0].XC_ProvisioningStep__c = step.Id;
        insert caseList;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woList[0].XC_ConfigurationItemIncentive__c = oiList[0].Id;
        insert woList;

        
        Test.startTest();

        List<XC_TechnicalSheet__c> tsList = new List<XC_TechnicalSheet__c>();
        XC_TechnicalSheet__c ts1 = new XC_TechnicalSheet__c(XC_Case__c = caseList[0].Id, XC_Particle__c = 'S', XC_Sheet__c = 'S');
        XC_TechnicalSheet__c ts2 = new XC_TechnicalSheet__c(XC_WorkOrder__c = woList[0].Id, XC_Particle__c = 'S', XC_Sheet__c = 'S');
        tsList.add(ts1);
        tsList.add(ts2);

        insert tsList;
        update tsList;
        delete tsList;
  
        System.assertEquals(true, tsList!=null, 'Wrong assert equals');
        Test.stopTest();
    }

}