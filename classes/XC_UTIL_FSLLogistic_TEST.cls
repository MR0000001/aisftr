/** 
* @Author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @Date Creation 12/06/2020
* @Description XC_UTIL_FSLLogistic_TEST - TEST Class for XC_UTIL_FSLLogistic
*/

@isTest
private class XC_UTIL_FSLLogistic_TEST {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_FSLLogistic');  

    @TestSetup
	static void setup() { 
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
        insert org;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        orderList[0].XC_EmobilityWebAppType__c  = Label.XC_CL_EmobilityWebAppType_Recharge;
        orderList[0].XC_Company_Code__c = 'C001';
        insert orderList;
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert listWorkOrder;
    }

    @isTest
    static void onUtility () {
        List<NE__Order__c> orderList = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1]);
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([SELECT Id, XC_Address__r.XC_PostalCode__c, WorkTypeId, XC_ApplyCoverageFilterInBooking__c FROM WorkOrder]);
        Test.startTest();
        XC_UTIL_FSLLogistic.createSalesOrderFromConfig(orderList[0].Id);
        XC_UTIL_FSLLogistic.createSalesOrder(listWorkOrder);
        XC_UTIL_FSLLogistic.createSalesOrderDelivery(listWorkOrder[0].Id);
        XC_UTIL_FSLLogistic.checkAvailability(listWorkOrder[0].Id, listWorkOrder[0].XC_Address__r.XC_PostalCode__c, listWorkOrder[0].WorkTypeId);
        XC_UTIL_FSLLogistic.checkAvailability(listWorkOrder[0], listWorkOrder[0].XC_Address__r.XC_PostalCode__c, listWorkOrder[0].WorkTypeId, '');
        XC_UTIL_FSLLogistic.OutputSelfCallout ow = XC_UTIL_FSLLogistic.calloutGlovia(new XC_UTIL_FSLLogistic.InputSelfCallout());
        XC_UTIL_FSLLogistic.OutputSelfCallout owSelf = XC_UTIL_FSLLogistic.selfCalloutGlovia(new XC_UTIL_FSLLogistic.InputSelfCallout());
        Test.stopTest();
    }

}