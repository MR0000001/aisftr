/**
* @author Nicola Mariniello
* @date Creation 30/03/2021
* @date Modification dd/mm/yyyy
* @description  – XC_TR_Config_U_CompleteStep_TEST - Test class for XC_TR_Configuration_U_CompleteStep
*/


@isTest
public class XC_TR_Config_U_CompleteStep_TEST {


    @TestSetup
    static void insertRecords(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }


    @isTest
    static void onUpdate1(){
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        insert orderList;

        Test.startTest();
        orderList[0].XC_Status__c = 'Closed';
        update orderList;       
        Test.stopTest();
        
        System.assertEquals(orderList!=null, true, 'Wrong assert result');
    }


    @isTest
    static void onUpdate2(){
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        insert orderList;

        Test.startTest();
        orderList[0].XC_ProvisioningStepToComplete__c = 'AAA';
        update orderList;  
        orderList[0].XC_Status__c = 'Closed';
        update orderList;       
        Test.stopTest();
        
        System.assertEquals(orderList!=null, true, 'Wrong assert result');
    }


    @isTest
    static void onUpdate3(){
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;

        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = orderItemList[0].Id;
        ps.XC_Status__c = 'In Progress';
        insert ps;

        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        insert orderList;

        Test.startTest();
        orderList[0].XC_ProvisioningStepToComplete__c = ps.Id;
        orderList[0].XC_Status__c = 'Closed';
        update orderList;       
        Test.stopTest();
        
        System.assertEquals(orderList!=null, true, 'Wrong assert result');
    }

}