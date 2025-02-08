@isTest
public class XC_SC026_CheckWoRepairCreateCase_TEST {
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_WorkType_Repair);
        for (WorkOrder wo : woList) {
            wo.XC_DateVerificationOfRepairCase__c = Date.today();
            wo.XC_VerificationOfRepairRequested__c = true;
            wo.XC_LegalEntity__c = 'EndesaX';
        }
        insert woList;
    }

    @IsTest
    static void test(){
        
        Test.startTest();
        String batchId = Database.executeBatch(new XC_SC026_CheckWoRepairCreateCase(), 200);
        System.assert(batchId != NULL);
        Test.stopTest();
        
    }
}