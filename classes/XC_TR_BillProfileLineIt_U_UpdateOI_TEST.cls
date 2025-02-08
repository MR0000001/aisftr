/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 02/11/2020
* @date Modification dd/mm/yyyy
* @description  – XC_TR_BillProfileLineIt_U_UpdateOI_TEST  - Test class for XC_TR_BillingProfileLineItem_U_UpdateOI
*/ 
@isTest
private class XC_TR_BillProfileLineIt_U_UpdateOI_TEST {
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
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c ordItem : orderItems){
            ordItem.XC_BillingProfileLineItem__c = bpli[0].Id;
            ordItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            ordItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        
        NE__Order__c order = [SELECT Id FROM NE__Order__c LIMIT 1];
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
        update order; 
    }
    
    static testMethod void onUpdate() {
        XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1];
        bpli.XC_Status__c = Label.XC_CL_Asset_StatusActive;
        update bpli;
    }
    
  	static testMethod void onUpdateWithMoreOrder() {
        XC_BillingProfileLineItem__c bpli = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1];
        NE__Product__c product = [SELECT Id FROM NE__Product__c LIMIT 1];
		List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(2);
        for(NE__OrderItem__c ordItem : orderItems){
            ordItem.XC_BillingProfileLineItem__c = bpli.Id;
            ordItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            ordItem.NE__ProdId__c = product.Id;
        }
        insert orderItems;
        bpli.XC_Status__c = Label.XC_CL_Asset_StatusActive;
        Test.startTest();
        update bpli;
        Test.stopTest();
    }
}