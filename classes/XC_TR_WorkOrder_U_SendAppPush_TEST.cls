/**
 * @File Name          : XC_TR_WorkOrder_U_SendAppPush_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 21/4/2020, 19:19:46
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@IsTest
public class XC_TR_WorkOrder_U_SendAppPush_TEST {

    @TestSetup
    static void setup(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.XC_LegalEntity__c = 'EnelXItalia';
        update order;
        List<ServiceResource> srs = XC_DF_ServiceResource.createServiceResources(1);
        List<WorkOrder> wos = XC_DF_WorkOrder.createWorkOrders(1,'Delivery');
        wos[0].XC_Configuration__c = order.Id;
        // wos[0].XC_LegalEntity__c = 'EnelXItalia';
        insert wos;
    }

    @IsTest
    static void testMethod1(){
        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];
        ServiceResource sr = [SELECT ID FROM ServiceResource LIMIT 1];
        Test.startTest();
            wo.XC_StatusReason__c = 'To be scheduled';
            wo.XC_AssignedResource__c = sr.Id;
            update wo;
        Test.stopTest();
    }


}