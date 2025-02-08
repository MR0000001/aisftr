/**
 * The Class XC_TR_Config_U_CustomInter_TEST.
 * @author            : Salvatore Scarpato - salvatore.scarpato@nttdata.com / Anna Maria Rosanova annamaria.rosanova@nttdata.com
 * @date Creation     : 16/07/2019
 * @description       : TEST Class for XC_TR_Configuration_U_WaitForCommodity
 **/ 


@isTest
public class XC_TR_Configuration_U_WaitForComm_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<NE__Order__c> orderList = XC_DF_Order.createOrders(2, 'Order');
        NE__Order__c order = orderList[0];
        insert order;

        NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
        insert orItem;

        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        step.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        step.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_WaitForCommodity1;
        step.XC_Configuration_Item__c = orItem.Id;
        insert step;
        
        XC_Provisioning_Step__c step1 = new XC_Provisioning_Step__c();
        step1.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        step1.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_WaitForCommodity2;
        step1.XC_Configuration_Item__c = orItem.Id;
        insert step1;

    }
 
    static testmethod void testWaitForCommodityCaseKo() {
        List<NE__Order__c> orderListQueried = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__Order__c order = orderListQueried[0];

        order.XC_WaitForCommodity__c = 'Ok';
        order.XC_WaitforCommodityStep__c = '1';
        update order;
        System.assertEquals(1, orderListQueried.size());
    }

    static testmethod void testWaitForCommodityCaseOk() {
        List<NE__Order__c> orderListQueried = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__Order__c order = orderListQueried[0];

        order.XC_WaitForCommodity__c = 'Ko';
        order.XC_WaitforCommodityStep__c = '1';
        update order;
        System.assertEquals(1, orderListQueried.size());
    }
    
    static testmethod void testwaitForCommodity2Ok() {
        List<NE__Order__c> orderListQueried = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__Order__c order = orderListQueried[0];

        order.XC_WaitForCommodity__c = 'Ok';
        order.XC_WaitforCommodityStep__c = '2';
        update order;
        System.assertEquals(1, orderListQueried.size());
    }
    
    static testmethod void testwaitForCommodity2KO() {
        List<NE__Order__c> orderListQueried = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__Order__c order = orderListQueried[0];

        order.XC_WaitForCommodity__c = 'Ko';
        order.XC_WaitforCommodityStep__c = '2';
        update order;
        System.assertEquals(1, orderListQueried.size());
    }  
}