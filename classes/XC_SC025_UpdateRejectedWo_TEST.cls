@isTest
public class XC_SC025_UpdateRejectedWo_TEST {
    
    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].Status = Label.XC_CL_WorkOrder_New;
        woList[0].XC_StatusReason__c = Label.XC_CL_WorkOrder_AssignmentError;
        insert woList;
    }

    @IsTest
    static void testFail(){
        Test.startTest();
        List<XC_UTIL_Sobject.WrapperResult> resultList = new List<XC_UTIL_Sobject.WrapperResult>{new XC_UTIL_Sobject.WrapperResult(), new XC_UTIL_Sobject.WrapperResult()};
        Savepoint sp = Database.setSavepoint();
        XC_SC025_UpdateRejectedWo.createBatchErrorLog(resultList, sp);
        List<XC_BatchErrorLog__c> errorList = [SELECT ID FROM XC_BatchErrorLog__c];
        System.assert(errorList != NULL);
        Test.stopTest();
    }
    
    @IsTest
    static void test(){
        Test.startTest();
        String batchId = Database.executeBatch(new XC_SC025_UpdateRejectedWo(), 50);
        System.assert(!String.isBlank(batchId));
        Test.stopTest();
    }
}