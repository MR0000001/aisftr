/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-17-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-17-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_IN061_ManageVirtualIBAN_TEST {

    @TestSetup
    static void setup(){

        NE__Billing_Profile__c bp = XC_DF_BillingProfile.createBillingProfileBankTrans(1)[0];
        XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = : bp.Id LIMIT 1];

        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');

        NE__OrderItem__c oiItemBundle = XC_DF_OrderItem.createOrderItem(ord);
        oiItemBundle.XC_BillingProfileLineItem__c = bpli.Id;
        oiItemBundle.XC_PaymentMethod__c = 'Bank Transfer';
        oiItemBundle.XC_BillingModel__c = 'One Shot';
        insert oiItemBundle;

        NE__OrderItem__c oiItem = XC_DF_OrderItem.createOrderItem(ord);
        oiItem.XC_BillingProfileLineItem__c = bpli.Id;
        oiItem.XC_PaymentMethod__c = 'Bank Transfer';
        oiItem.XC_BillingModel__c = 'One Shot';
        oiItem.NE__Bundle_Configuration__c = oiItemBundle.Id;
        insert oiItem;

        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(oiItem.Id);
        insert step;
        
        
    }

    @isTest
    static void manageVirtualIBAN_TEST(){

        XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
        XC_IN061_ManageVirtualIBAN.InputWrapper iw = new XC_IN061_ManageVirtualIBAN.InputWrapper();
        iw.stepId = step.Id;
        List<XC_IN061_ManageVirtualIBAN.InputWrapper> inputs = new List<XC_IN061_ManageVirtualIBAN.InputWrapper>{iw};

        Test.startTest();
            XC_IN061_ManageVirtualIBAN.manageVirtualIBAN(inputs);
        Test.stopTest();

    }



}