@isTest
public class XC_SC023_UpdateWoAndCreateCase_TEST {

    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saList[0].Status = Label.XC_CL_ServiceAppointment_Scheduled;
        insert saList;
        Test.stopTest();
    }

    @IsTest
    static void testFail(){
        Test.startTest();
        String batchId = Database.executeBatch(new XC_SC023_UpdateWoAndCreateCase(), 50);
        System.assert(!String.isBlank(batchId));
        Test.stopTest();
    }
    
    @IsTest
    static void test(){
        //WorkOrder wo = [SELECT Id, XC_forSATO__c FROM WorkOrder LIMIT 1];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        WorkOrder wo = woList[0];
        wo.XC_forSATO__c = true;
        insert wo;

        Test.startTest();
        String batchId = Database.executeBatch(new XC_SC023_UpdateWoAndCreateCase(), 50);
        System.assert(!String.isBlank(batchId));
        Test.stopTest();
    }
}