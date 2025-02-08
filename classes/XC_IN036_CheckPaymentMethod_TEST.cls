@isTest
public class XC_IN036_CheckPaymentMethod_TEST {
    @TestSetup
    static void setup(){
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(oiList[0].Id);
        step.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        step.XC_Status__c = 'In Progress';
        insert step;
        Test.stopTest();
    }

    @IsTest
    static void isPaymentBarcodeInserted(){
        Test.startTest();
        XC_IN036_CheckPaymentMethod.CheckPaymentWrapper wrapper = new XC_IN036_CheckPaymentMethod.CheckPaymentWrapper();
        wrapper.stepId = [SELECT ID FROM XC_Provisioning_Step__c][0].Id;
        wrapper.isPaymentBarcodeInserted = true;
        XC_IN036_CheckPaymentMethod.checkPaymentMethods(new List<XC_IN036_CheckPaymentMethod.CheckPaymentWrapper>{wrapper});

        List<Case> caseList = [SELECT ID FROM CASE];
        System.assert(!caseList.isEmpty());
        Test.stopTest();
    }
    
    
    @IsTest
    static void isNotPaymentBarcodeInserted(){
        Test.startTest();
        XC_IN036_CheckPaymentMethod.CheckPaymentWrapper wrapper = new XC_IN036_CheckPaymentMethod.CheckPaymentWrapper();
        wrapper.stepId = [SELECT ID FROM XC_Provisioning_Step__c][0].Id;
        wrapper.isPaymentBarcodeInserted = false;
        XC_IN036_CheckPaymentMethod.checkPaymentMethods(new List<XC_IN036_CheckPaymentMethod.CheckPaymentWrapper>{wrapper});

        List<Case> caseList = [SELECT ID FROM CASE];
        System.assert(!caseList.isEmpty());
        Test.stopTest();
    }
}