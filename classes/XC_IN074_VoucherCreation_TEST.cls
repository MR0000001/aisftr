/**
*@author Marina Ciavarra - mciavarra@deloitte.it
*@date Creation 02/04/2021
*@description XC_IN074_VoucherCreation_TEST – test class for XC_IN074_VoucherCreation
*/

@isTest
public class XC_IN074_VoucherCreation_TEST {
    @TestSetup
    static void setup(){
        //create order linked to product and oppty
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfileBankTrans(1);
        List<XC_BillingProfileLineItem__c> bpli = [SELECT Id,XC_Account__c, XC_BillToContactId__c, XC_BillToAddress__c, XC_BillingProfile__r.NE__Payment__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :bpList[0].id];
        List<Account> accList = [SELECT id FROM Account Where id=:bpli[0].XC_Account__c];
        accList[0].Account_Type__c = 'B2C';
        update accList;
        List<XC_Address__c> addressList = [SELECT id FROM XC_Address__c WHERE id=:bpli[0].XC_BillToAddress__c];
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[0].XC_Preferredlanguageofcontact__c = 'English';
        insert contactList;
        Contact cnt = [SELECT id FROM Contact LIMIT 1];

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithoutVisit(contactList, addressList[0]);
        oppList[0].XC_CommodityBillBPLI__c = bpli[0].ID;
        insert oppList;
        Opportunity opp =[SELECT id FROM Opportunity LIMIT 1];
        NE__Order__c order =  XC_DF_Order.createOrderWithAddress('In Order', addressList[0].ID, accList[0].ID, opp.ID);
        order.XC_TimeSlotDate__c =  Date.Today();
        order.XC_TimeSlot__c='10-12';
        update order;
        NE__OrderItem__c configItem = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        configItem.XC_BillingProfileLineItem__c = bpli[0].ID;
        configItem.XC_PaymentMethod__c = bpli[0].XC_BillingProfile__r.NE__Payment__c;
        configItem.XC_ForcePaymentMethodEdit__c = true;
        update configItem;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_SiteInspection);
        woList[0].XC_Result__c = 'OK';
        woList[0].XC_MaxWallboxPower__c = '22 KWh';
        woList[0].ContactId = cnt.id;
        woList[0].XC_Configuration_Item__c =configItem.ID;
        System.debug('woList ' + woList);
        insert woList;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = configItem.ID;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }

    @isTest
    static void callVoucherCreation(){        
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        
        XC_IN074_VoucherCreation.InputWrapper inw = new XC_IN074_VoucherCreation.InputWrapper();
        List<XC_IN074_VoucherCreation.InputWrapper> inputWrapperList = new List<XC_IN074_VoucherCreation.InputWrapper>();
        inw.stepId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN074_VoucherCreation.voucherCreation(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
}