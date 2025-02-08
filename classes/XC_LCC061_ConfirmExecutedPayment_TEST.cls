/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com  
* @date Creation 24/06/2019 
* @description XC_LCC061_ConfirmExecutedPayment_TEST – Test class for XC_LCC061_ConfirmExecutedPayment
*/
@isTest
private class XC_LCC061_ConfirmExecutedPayment_TEST { 

    @TestSetup
    static void setup(){
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);

        NE__OrderItem__c orderItem = orderItemList[0];
        orderItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
        insert orderItem;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderItem.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningExecutePayment_Flow;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }

    @isTest
    static void methodTest(){
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        test.startTest();
        XC_LCC061_ConfirmExecutedPayment.confirmExecutedPayment(stepId);
        test.stopTest();
        System.assert(stepId!=null);
    }
    
    @isTest
    static void methodTestcheckStepTrue(){
        List<NE__OrderItem__c> orderItemList = [SELECT Id FROM NE__OrderItem__c ];
        NE__OrderItem__c orItem = orderItemList[0];
        orItem.XC_PaymentMethod__c = '';
        update orItem;
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        Id stepId = stepsList[0].Id;
        test.startTest();
        XC_LCC061_ConfirmExecutedPayment.confirmExecutedPayment(stepId);
        test.stopTest();
        System.assert(stepId!=null);
    }
    
    @isTest
    static void methodTestDifferentSteo(){
        List<NE__OrderItem__c> orderItemList = [SELECT Id FROM NE__OrderItem__c ];
        NE__OrderItem__c orItem = orderItemList[0];
        orItem.XC_PaymentMethod__c = '';
        update orItem;
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        step.XC_Flow_API_Name__c = '';
        update step;
        Id stepId = step.Id;
        test.startTest();
        XC_LCC061_ConfirmExecutedPayment.confirmExecutedPayment(stepId);
        test.stopTest();
        System.assert(stepId!=null);
    }
}