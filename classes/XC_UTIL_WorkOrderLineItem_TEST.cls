/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  23/05/2019 
* @description XC_UTIL_WorkOrderLineItem_TEST – Test class for XC_UTIL_WorkOrderLineItem 
*/
@istest
public class XC_UTIL_WorkOrderLineItem_TEST{
    
    //Test Method createWorkOrderLineItemByWrapper
    static testMethod void createWorkOrderLineItemByWrapper(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();        
        
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wr = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        list <WorkOrder> lwo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        string woId = lwo[0].Id;
        WorkOrderLineItem wlOut = new WorkOrderLineItem();
        WorkOrderLineItem wli =  XC_UTIL_WorkOrderLineItem.createWorkOrderLineItemByWrapper(wr , woId, wlOut);
        
        System.assertEquals(true, wli!=null);
        Test.stopTest();
        
    }
    
   
}