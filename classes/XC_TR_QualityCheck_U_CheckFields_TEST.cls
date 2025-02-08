/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/12/2020
* @description XC_TR_QualityCheck_U_CheckFields_TEST – Test Class for XC_TR_QualityCheck_U_CheckFields
*/  

@isTest
private class XC_TR_QualityCheck_U_CheckFields_TEST {

    @isTest
    static void onCheckAnswers() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Quality Check Inspection');
        WorkType wt = XC_DF_WorkType.createWorkTypeWithName('Quality Check Inspection', 'Quality Check Inspection');
        insert wt;
        listWorkOrder[0].WorkTypeId = wt.Id;
        insert listWorkOrder;
        XC_B2BG_QualityCheck__c qc = XC_DF_QualityCheck.createQualityChecks(1)[0];
        qc.XC_BusinessLine__c = 'Business to Government (B2G)';
        qc.XC_Company__c = 'Enel X';
        qc.XC_AnswerA1__c = 'NC';
        qc.XC_NotCompliance_CommentsA1__c = 'test';
        qc.XC_WorkOrder__c = listWorkOrder[0].Id;
        Test.startTest();
        insert qc;
        qc.XC_AnswerA1__c = 'C';
        qc.XC_AnswerA2__c = 'NC';
        qc.XC_NotCompliance_CommentsA2__c = 'test';
        update qc;
        delete qc;
        Test.stopTest();
    }
    
    @isTest
    static void onCheckAnswersNA() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Quality Check Inspection');
        WorkType wt = XC_DF_WorkType.createWorkTypeWithName('Quality Check Inspection', 'Quality Check Inspection');
        insert wt;
        listWorkOrder[0].WorkTypeId = wt.Id;
        insert listWorkOrder;
        XC_B2BG_QualityCheck__c qc = XC_DF_QualityCheck.createQualityChecks(1)[0];
        qc.XC_BusinessLine__c = 'Business to Government (B2G)';
        qc.XC_Company__c = 'Enel X';
        qc.XC_AnswerA1__c = 'NC';
        qc.XC_NotCompliance_CommentsA1__c = 'test';
        qc.XC_WorkOrder__c = listWorkOrder[0].Id;
        qc.XC_NullAccess__c = true;
        Test.startTest();
        insert qc; 
    }

}