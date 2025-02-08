/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 1/10/2019
* @date Modification:
* @description XC_LCC159_CustomerNotReachable_TEST - Test class for XC_LCC159_CustomerNotReachable
*/
@isTest
public without sharing class XC_LCC159_CustomerNotReachable_TEST {
    @isTest
    static  void recalculateUrgency() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_Repair);
        insert listWorkOrder;
        update(listWorkOrder[0]); 
        Test.startTest();
        XC_UTIL_ResultWrapper wrapper = XC_LCC159_CustomerNotReachable.updateFLS(listWorkOrder[0].Id, 'Phone number incorrect');
        System.assertEquals(wrapper.success, true);
        Test.stopTest();        
    } 
}