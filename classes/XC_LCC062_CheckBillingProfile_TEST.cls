/**
 * The Class XC_LCC062_CheckBillingProfile_TEST.
 *
 * @author Sara Miozza - sara.miozza@nttdata.com
 * @date Creation 15/05/2019
 * @description XC_LCC062_CheckBillingProfile_TEST – Test class for  XC_LCC062_CheckBillingProfile 
 */

@isTest
public class XC_LCC062_CheckBillingProfile_TEST {

    @isTest
    static void checkBillingProfileTest1(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(NE__Account__c = accList[0].Id, NE__Payment__c = 'Credit Card');
        insert billingProf;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingProf.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
        insert bpli;
        
        Test.startTest();
        
        NE__Order__c config = new NE__Order__c(); 
        insert config; 
        NE__OrderItem__c ordItem = new NE__OrderItem__c();
        ordItem.NE__OrderId__c = config.Id;
        ordItem.NE__Qty__c = 1;
        ordItem.XC_BillingProfileLineItem__c = bpli.Id;
        ordItem.XC_BillingModel__c = 'One Shot';
        ordItem.XC_PaymentMethod__c = 'Credit Card'; 
    
        insert ordItem;
        
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep.XC_Configuration_Item__c = ordItem.Id;
        insert provStep;
        Id recordId = provStep.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId);
        System.assert(rw.success);
        Test.stopTest();
    }

    @isTest
    static void checkBillingProfileTest2(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(NE__Account__c = accList[0].Id, NE__Payment__c = 'Credit Card');
        insert billingProf;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingProf.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
        insert bpli;
        
        Test.startTest();
        
        NE__Order__c config = new NE__Order__c(); 
        insert config;
        
        NE__OrderItem__c ordItem2 = new NE__OrderItem__c();
        ordItem2.NE__OrderId__c = config.Id;
        ordItem2.NE__Qty__c = 1;
        ordItem2.NE__BillingProfId__c = billingProf.Id;
        ordItem2.XC_BillingProfileLineItem__c = bpli.Id;
        ordItem2.XC_BillingModel__c = 'One Shot';
        ordItem2.XC_PaymentMethod__c = 'Credit Card';
        insert ordItem2;
        XC_Provisioning_Step__c provStep2 = new XC_Provisioning_Step__c();
        provStep2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep2.XC_Configuration_Item__c = ordItem2.Id;
        insert provStep2;
        Id recordId2 = provStep2.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw2 = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId2);
        System.assert(rw2.success);

        Test.stopTest();
    }

    @isTest
    static void checkBillingProfileTest3(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(NE__Account__c = accList[0].Id, NE__Payment__c = 'Credit Card');
        insert billingProf;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingProf.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
        insert bpli;
        
        Test.startTest();
        NE__Order__c config = new NE__Order__c(); 
        insert config;
        
        NE__OrderItem__c ordItem3 = new NE__OrderItem__c();
        ordItem3.NE__OrderId__c = config.Id;
        ordItem3.NE__Qty__c = 1;
        ordItem3.NE__BillingProfId__c = billingProf.Id;
        ordItem3.XC_BillingProfileLineItem__c = bpli.Id;
        ordItem3.XC_BillingModel__c = 'One Shot';
        ordItem3.XC_PaymentMethod__c = 'Credit Card';
        insert ordItem3;
        XC_Provisioning_Step__c provStep3 = new XC_Provisioning_Step__c();
        //provStep2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep3.XC_Configuration_Item__c = ordItem3.Id;
        insert provStep3;
        Id recordId3 = provStep3.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw3 = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId3);
        System.assert(!rw3.success);

        Test.stopTest();
    }

    /*@isTest
    static void checkBillingProfileTest2(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(NE__Account__c = accList[0].Id);
        insert billingProf;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=billingProf.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c);
        insert bpli;
        
        Test.startTest();
        
        NE__Order__c config = new NE__Order__c(); 
        insert config; 
        NE__OrderItem__c ordItem = new NE__OrderItem__c();
        ordItem.NE__OrderId__c = config.Id;
        ordItem.NE__Qty__c = 1;
        ordItem.XC_BillingProfileLineItem__c = bpli.Id;
        insert ordItem;
        
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep.XC_Configuration_Item__c = ordItem.Id;
        insert provStep;
        Id recordId = provStep.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId);
        System.assert(!rw.success);
        
        NE__OrderItem__c ordItem2 = new NE__OrderItem__c();
        ordItem2.NE__OrderId__c = config.Id;
        ordItem2.NE__Qty__c = 1;
        ordItem2.NE__BillingProfId__c = billingProf.Id;
        ordItem2.XC_BillingProfileLineItem__c = bpli.Id;
        insert ordItem2;
        XC_Provisioning_Step__c provStep2 = new XC_Provisioning_Step__c();
        provStep2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep2.XC_Configuration_Item__c = ordItem2.Id;
        insert provStep2;
        Id recordId2 = provStep2.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw2 = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId2);
        System.assert(rw2.success);

        NE__OrderItem__c ordItem3 = new NE__OrderItem__c();
        ordItem3.NE__OrderId__c = config.Id;
        ordItem3.NE__Qty__c = 1;
        ordItem3.NE__BillingProfId__c = billingProf.Id;
        ordItem3.XC_BillingProfileLineItem__c = bpli.Id;
        insert ordItem3;
        XC_Provisioning_Step__c provStep3 = new XC_Provisioning_Step__c();
        //provStep2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep3.XC_Configuration_Item__c = ordItem3.Id;
        insert provStep3;
        Id recordId3 = provStep3.Id;
        XC_LCC062_CheckBillingProfile.resultWrapper rw3 = XC_LCC062_CheckBillingProfile.checkBillingProfile(recordId3);
        System.assert(!rw3.success);

        Test.stopTest();
    }*/
}