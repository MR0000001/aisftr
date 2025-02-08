/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com 
* @date Creation 11/09/2019
* @description XC_TR_WorkOrder_U_RequiredResMgmt_TEST – Test class 
*/
@isTest
private  class XC_TR_WorkOrder_U_RequiredResMgmt_TEST {
    static testMethod void manageRequiredResourcesOnInsert(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<ServiceResource> listServiceResourse = XC_DF_ServiceResource.createServiceResources(1);    
        List<Account> accList = new List<Account> ([SELECT Id
                                                    FROM Account limit 1
                                                   ]);
        List<Account> listAccounts = new List<Account>([
           SELECT Id, 
              (SELECT Id
               FROM Service_Resources__r)
           FROM Account
        ]);
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList){
            wo.accountId = accList[0].Id;
        }
        insert woList;

        XC_TR_WorkOrder_U_RequiredResMgmt.getRequiredResources(woList, accList[0].Id);
        
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(10, listInsertedWorkOrders.size());
        Test.stopTest();
    }
}