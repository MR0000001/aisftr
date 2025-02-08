/**
* @author Valeria Martino - valeria.martino@ntdata.com
* @date Creation  09/10/2019 
* @description XC_LCC160_CancelContract_TEST – Test class for XC_LCC160_CancelContract
*/
@isTest
public class XC_LCC160_CancelContract_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1 , Label.XC_CL_WorkType_PlannedMaintenance);
        insert listWorkOrder;
    }
    @isTest static void updateWorkOrder() {
        WorkOrder wo = [SELECT Id, XC_WorkTypeCategory__c FROM WorkOrder WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_PlannedMaintenance];
        Test.startTest();
        XC_LCC160_CancelContract.ResultWrapper result = XC_LCC160_CancelContract.cancelContract(wo.Id);
        Test.stopTest();
        System.assert(result.success);
        

    }

}