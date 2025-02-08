/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  05/06/2019 
* @description XC_TR_BillProfLineItem_U_ComplStep_TEST – Test class for XC_TR_BillProfLineItem_U_CompleteStep
*/ 
@isTest
public class XC_TR_BillProfLineItem_U_ComplStep_TEST {
    
    @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfList[0];
        List<XC_BillingProfileLineItem__c> bpli = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1];
        
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(10);
        for(NE__OrderItem__c ordItem : orderItems){
            ordItem.XC_BillingProfileLineItem__c = bpli[0].Id;
            ordItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
            ordItem.XC_StartCongaProcess__c = false;
            ordItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        
        List<NE__Product__c> prodList = [SELECT Id FROM NE__Product__c];
        for(NE__Product__c prod : prodList) {
            prod.Name = 'Product';
        }
        update prodList;
        
        XC_Provisioning_Step__c  provStep = new XC_Provisioning_Step__c();
        provStep.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCheckPaymentMethod_Flow;
        provStep.XC_Configuration_Item__c = orderItems[0].Id;
		provStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        insert provStep;
    }
    
	static testMethod void onUpdate() {
        
        List<XC_BillingProfileLineItem__c> bplis = [SELECT Id FROM XC_BillingProfileLineItem__c];
        XC_BillingProfileLineItem__c bpli = bplis[0];
        bpli.XC_Status__c=Label.XC_CL_AccountActive;
        update bpli;
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account accnt = accountList[0];
        insert accnt;
        
		Zuora__CustomerAccount__c customerAccount = new Zuora__CustomerAccount__c();
        customerAccount.Zuora__Account__c = accnt.Id;
        insert customerAccount;
        
        bpli.XC_CustomerAccount__c = customerAccount.Id;
        update bpli;
        System.assertEquals(1, bplis.size());
    }
    
    static testMethod void onUpdate2() {
        
        List<XC_BillingProfileLineItem__c> bplis = [SELECT Id FROM XC_BillingProfileLineItem__c];
        XC_BillingProfileLineItem__c bpli = bplis[0];
        bpli.XC_Status__c='Refused';
        update bpli;
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        Account accnt = accountList[0];
        insert accnt;
        
		Zuora__CustomerAccount__c customerAccount = new Zuora__CustomerAccount__c();
        customerAccount.Zuora__Account__c = accnt.Id;
        insert customerAccount;
        
        bpli.XC_CustomerAccount__c = customerAccount.Id;
        update bpli;
        System.assertEquals(1, bplis.size());
    }
}