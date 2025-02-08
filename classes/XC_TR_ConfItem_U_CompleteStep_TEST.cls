/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  05/06/2019 
* @description XC_TR_ConfItem_U_CompleteStep_TEST – Test class for XC_TR_ConfItem_U_CompleteStep
*/ 
@isTest
public class XC_TR_ConfItem_U_CompleteStep_TEST {
    
    @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account accnt = accountList[0];
        insert accnt;
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(10);
        for(NE__OrderItem__c orItem : orderItems){
            orItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        Zuora__CustomerAccount__c customerAccount = new Zuora__CustomerAccount__c();
        customerAccount.Zuora__Account__c = accnt.Id;
        insert customerAccount;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c();
        bpli.XC_CustomerAccount__c = customerAccount.Id;
        bpli.XC_Status__c = 'Active';
        List<NE__Billing_Profile__c> billingProfiles = XC_DF_BillingProfile.createBillingProfile(1);
        bpli.XC_BillingProfile__c = billingProfiles[0].id;
        system.debug('@test@ billingProfilesLineItems->'+ bpli);
        insert bpli;
        billingProfiles[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfiles[0];
    }
    
    static testMethod void onUpdate() {
        
        List<NE__OrderItem__c> ordItems  = [SELECT Id FROM NE__OrderItem__c];
        List<XC_BillingProfileLineItem__c> billingProfilesLineItems = [SELECT Id, XC_CustomerAccount__c  FROM XC_BillingProfileLineItem__c  WHERE XC_CustomerAccount__c!=NULL ];
        system.debug('@test@ billingProfilesLineItems->'+ billingProfilesLineItems);
        XC_BillingProfileLineItem__c bpli = billingProfilesLineItems[0];
        for(NE__OrderItem__c ordItem : ordItems){
            ordItem.XC_BillingProfileLineItem__c = bpli.Id;
            ordItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
        }
        
        update ordItems;
        System.assertEquals(10, ordItems.size());
    }
}