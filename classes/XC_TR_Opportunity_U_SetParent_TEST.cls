/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 23/10/2019
* @date Modification dd/mm/yyyy
* @description
**/

@isTest
public with sharing class XC_TR_Opportunity_U_SetParent_TEST {

    @testSetup
    private static void setup() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        insert caseList;
        caseList[0].Status=Label.XC_CL_Case_InProgress;
        update caseList;
    }

    static testMethod void createOpportunity(){ 
        //List<Case> caseList = [SELECT Id FROM Case where Status=: Label.XC_CL_Case_InProgress];
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Status=Label.XC_CL_Case_InProgress;
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1,false);
        opp[0].XC_CaseId__c = caseList[0].Id;
        Test.startTest(); 
        insert opp;
        Test.stopTest();
        System.assertEquals(true, opp!=null);
        
    }
}