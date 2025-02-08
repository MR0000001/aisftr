/**
* @author: Vaibhav Anand
* @date Creation Date: 29/11/2021
* @description Test class for XC_LCC_ChangeOwnerWOLI
*/
@isTest
public class XC_LCC_ChangeOwnerWOLI_Test {
    
    @TestSetup
    public static void setup() {
      //  XC_DF_WorkType.createWorkTypeWithName('Installation', 'Installation');

        List<WorkOrder> WOs = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');

        insert WOs;
        List<WorkOrderLineItem> WOLIs = new List<WorkOrderLineItem>{
                new WorkOrderLineItem(
                        RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('B2B EnelXItalia Technical Asset').getRecordTypeId(),
                        WorkOrderId = WOs[0].Id,
                        XC_WOLIType__c = 'Technical Asset'
                )
        };
        insert WOLIs;   
    }     

     @isTest
    private static void validateOrderItem1(){
        WorkOrder WOLI = [SELECT Id FROM WorkOrder];
        Test.startTest();
        XC_LCC_ChangeOwnerWOLI.changeOwner(WOLI.Id,Userinfo.getUserId());
        Test.stopTest();
    }
}