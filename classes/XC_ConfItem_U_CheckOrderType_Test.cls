@Istest
public class XC_ConfItem_U_CheckOrderType_Test {
    static testmethod void retrieveOrderType(){
       OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
        insert org;
        test.startTest();
        List<NE__Order__c> orderList=XC_DF_Order.createOrders(1,'InOrder');
       insert orderList; 
        NE__OrderItem__c orderItem=XC_DF_OrderItem.createOrderItem(orderList[0]);
        insert orderItem;
       orderList[0].NE__Type__c='Asset';
        orderList[0].XC_Segment__c='B2B'; 
        update orderList;
        test.stopTest();
    }
}