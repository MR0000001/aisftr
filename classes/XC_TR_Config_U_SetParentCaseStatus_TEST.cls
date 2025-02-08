/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 23/10/2019
* @date Modification dd/mm/yyyy
* @description
**/

@isTest
public without sharing class XC_TR_Config_U_SetParentCaseStatus_TEST {


    @testSetup
    private static void setup() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        insert caseList;
        caseList[0].Status=Label.XC_CL_Case_InProgress;
        update caseList;
    }
	@isTest
    static void createConfiguration(){ 
        List<Case> caseList = [SELECT Id FROM Case where Status=: Label.XC_CL_Case_InProgress LIMIT 1];
        List<NE__Order__c> conf = XC_DF_Order.createOrders(1,'ChangeOrder');
        conf[0].XC_Status__c = null;
        insert conf;
        conf[0].XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        conf[0].XC_CaseId__c = caseList[0].Id;
        Test.startTest(); 
        update conf;
        Test.stopTest();
        System.assertEquals(true, conf!=null);
        
    }
}