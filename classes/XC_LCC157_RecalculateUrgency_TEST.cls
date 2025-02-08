/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 09/09/2019
* @date Modification:
* @description XC_LCC157_RecalculateUrgency_TEST - Test class for XC_LCC157_RecalculateUrgency
*/
@isTest
public without sharing class XC_LCC157_RecalculateUrgency_TEST {
    @isTest   
    static  void recalculateUrgency() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_Repair);
        insert listCase;
        insert listWorkOrder;
        listWorkOrder[0].caseId = listCase[0].Id;
        update(listWorkOrder[0]);
        Test.startTest();
        XC_LCC157_RecalculateUrgency.createNewWoRepair(listCase[0].Id);
        XC_LCC157_RecalculateUrgency.ResultWrapper wrapper = XC_LCC157_RecalculateUrgency.cancelWo(listWorkOrder[0].Id);  
        Test.stopTest();        
    }
    
    @isTest
    static void recalculate() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_CommercialVisit);
        insert listCase;
        insert listWorkOrder;
        listWorkOrder[0].caseId = listCase[0].Id;
        update(listWorkOrder[0]);
        Test.startTest();
        XC_LCC157_RecalculateUrgency.createNewWoRepair(listCase[0].Id);
        XC_LCC157_RecalculateUrgency.ResultWrapper wrapper = XC_LCC157_RecalculateUrgency.cancelWO(listWorkOrder[0].Id); 
        Test.stopTest();        
    }
    
     @isTest
     static  void recalculateUrg() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_Repair);
        insert listCase;
        insert listWorkOrder;
        
        update(listWorkOrder[0]);
        Test.startTest(); 
        XC_LCC157_RecalculateUrgency.createNewWoRepair(listCase[0].Id);
        Test.stopTest();        
    }
}