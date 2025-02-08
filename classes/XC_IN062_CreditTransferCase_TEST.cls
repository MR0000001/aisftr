/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 10-08-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-08-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public without sharing class XC_IN062_CreditTransferCase_TEST {


    @TestSetup
    static void setup(){

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
       	List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        opp[0].AccountId = acc[0].Id;
        opp[0].XC_Contact__c = cont[0].Id;
        opp[0].XC_Address__c = addr[0].Id;
        insert opp;


        List<NE__Order__c> ords = XC_DF_Order.createOrders(1,'InOrder');
        NE__Order__c ord = ords[0];
        ord.NE__AccountId__c = opp[0].AccountId;
        ord.NE__OptyId__c = opp[0].Id;
		ord.XC_DeliveryAddress__c = opp[0].XC_Address__c;
        ord.XC_InstallationAddress__c = opp[0].XC_Address__c;
        insert ord;

        NE__OrderItem__c oiItemBundle = XC_DF_OrderItem.createOrderItem(ord);
        oiItemBundle.XC_CreditAssignmentAvailable__c = true;
        oiItemBundle.NE__Account__c = acc[0].Id;

        insert oiItemBundle;

        NE__OrderItem__c oiItem = XC_DF_OrderItem.createOrderItem(ord);
        oiItem.NE__Bundle_Configuration__c = oiItemBundle.Id;
        oiItem.NE__Account__c = acc[0].Id;

        insert oiItem;

        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(oiItem.Id);
        step.XC_Step_Order__c = 0;
        insert step;
    }

    @isTest
    static void createCreditTransferCase_TEST(){

        XC_Provisioning_Step__c step = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1];
        XC_IN062_CreditTransferCase.InputWrapper iw = new XC_IN062_CreditTransferCase.InputWrapper();
        iw.stepId = step.Id;
        List<XC_IN062_CreditTransferCase.InputWrapper> inputs = new List<XC_IN062_CreditTransferCase.InputWrapper>{iw};

        Test.startTest();
            XC_IN062_CreditTransferCase.createCreditTransferCase(inputs);
        Test.stopTest();

    }

}