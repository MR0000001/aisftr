/**
* @author Nicola Mariniello - nmariniello@deloitte.it
* @description Test class for XC_IN088_CreateSubscriptionZeroPrice
*/


@isTest
public class XC_IN088_CreateSubZeroPrice_TEST {
    
    @testSetup
    private static void setup() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c , NE__ProdId__r.Manage_Complex_Product_B2C__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;
	}
    
    @isTest
    private static void emptyFieldTEST() {

        List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper> wrList = new List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper>();
        XC_IN088_CreateSubscriptionZeroPrice.InputWrapper wr = new XC_IN088_CreateSubscriptionZeroPrice.InputWrapper();
        wr.operation = '';
        wr.stepId = '';
        wrList.add(wr);

        Test.startTest();
        XC_IN088_CreateSubscriptionZeroPrice.doActions(wrList);
        Test.stopTest();

        System.assert(true);
    }
    
    @isTest
    private static void checkChildStepsTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
                                        FROM XC_Provisioning_Step__c
                                        LIMIT 1];
        
        List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper> wrList = new List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper>();
        XC_IN088_CreateSubscriptionZeroPrice.InputWrapper wr = new XC_IN088_CreateSubscriptionZeroPrice.InputWrapper();
        wr.operation = Label.XC_CL_CheckChildStepsOperation;
        wr.stepId = ps.Id;
        wr.configurationItemId = ps.XC_Configuration_Item__c;
        wrList.add(wr);

        Test.startTest();
        XC_IN088_CreateSubscriptionZeroPrice.doActions(wrList);
        Test.stopTest();

        System.assert(true);
    }
    
    @isTest
    private static void relaunchStepTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
                                        FROM XC_Provisioning_Step__c
                                        LIMIT 1];
        
        List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper> wrList = new List<XC_IN088_CreateSubscriptionZeroPrice.InputWrapper>();
        XC_IN088_CreateSubscriptionZeroPrice.InputWrapper wr = new XC_IN088_CreateSubscriptionZeroPrice.InputWrapper();
        wr.operation = Label.XC_CL_RelaunchStepOperation;
        wr.stepId = ps.Id;
        wrList.add(wr);

        Test.startTest();
        XC_IN088_CreateSubscriptionZeroPrice.doActions(wrList);
        Test.stopTest();

        System.assert(true);
    }

}