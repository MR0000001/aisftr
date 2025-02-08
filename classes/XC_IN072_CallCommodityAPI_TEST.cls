/**
*@author Marina Ciavarra - mciavarra@deloitte.it
*@date Creation 25/03/2021
*@description XC_IN072_CallCommodityAPI_TEST – test class for XC_IN072_CallCommodityAPI
*/

@isTest
public class XC_IN072_CallCommodityAPI_TEST {

    @TestSetup
    static void setup(){
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfileBankTrans(1);
        List<Account> accList = [SELECT Id, (SELECT Id FROM Addresses__r) FROM Account Where id=:bpList[0].NE__Account__c];
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=bpList[0].id, XC_SoldToAddress__c=accList[0].Addresses__r[0].Id,XC_BillToAddress__c=accList[0].Addresses__r[0].Id, XC_Account__c=accList[0].Id);
        insert bpli;
        accList[0].Account_Type__c = 'B2C';
        update accList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[0].Phone = '3596571959';
        contactList[0].XC_ContactPhone__c = '3596571959';
        contactList[0].XC_PhonePrefix__c= '+39';
        insert contactList;
        Contact cnt = [SELECT id FROM Contact LIMIT 1];
        bpli.XC_BillToContactId__c = cnt.ID;
        update bpli;

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithoutVisit(contactList, accList[0].Addresses__r[0]);
        oppList[0].XC_CommodityBillBPLI__c = bpli.ID;
        insert oppList;
        Opportunity opp =[SELECT id FROM Opportunity LIMIT 1];
        NE__Order__c order =  XC_DF_Order.createOrderWithAddress('In Order', accList[0].Addresses__r[0].ID, accList[0].ID, opp.ID);
        order.XC_TimeSlotDate__c =  Date.Today();
        order.XC_TimeSlot__c='10-12';
        update order;
        NE__OrderItem__c configItem = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        configItem.XC_BillingProfileLineItem__c = bpli.ID;
        configItem.XC_PaymentMethod__c = 'Bank Transfer';
        configItem.XC_ForcePaymentMethodEdit__c = true;
        update configItem;

        XC_PointOfService__c pos = new XC_PointOfService__c(XC_Account__c=accList[0].ID, Name='Test POS', XC_Type__c='Gas', XC_Address__c=accList[0].Addresses__r[0].ID);
        insert pos;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = configItem.ID;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }

    @isTest
    static void callCommodityAPITEST(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN072_CallCommodityAPI.InputWrapper inw = new XC_IN072_CallCommodityAPI.InputWrapper();
        List<XC_IN072_CallCommodityAPI.InputWrapper> inputWrapperList = new List<XC_IN072_CallCommodityAPI.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN072_CallCommodityAPI.callCommodityAPI(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}