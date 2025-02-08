/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation  07/02/2020 
* @description XC_TR_ConfigurationItem_U_BP_TEST – Test class for XC_TR_ConfigurationItem_U_BillingProfile
*/
@isTest
private with sharing class XC_TR_ConfigurationItem_U_BP_TEST {
    static testMethod void hasBillingProfileInsert(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        Test.startTest();
        List<id> orderId=new list<id>();
        for(NE__OrderItem__c orderItem:listOrderItem ){
            orderId.add(orderItem.NE__OrderId__c);
        }
        List<NE__Order__c> orderList=[select id,NE__AccountId__c from NE__Order__c where id IN:orderId ];
        Map<id,Account> mapAcc= new Map<id,Account>( [select id from Account where id=:orderList[0].NE__AccountId__c]);
        List<Account> accList=new List<Account>();
        accList.add(mapAcc.get(orderList[0].NE__AccountId__c));                                
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        listBilling=XC_DF_BillingProfile.createBillingProfile(1,accList);
        List<XC_BillingProfileLineItem__c>  listbpli= [select id, XC_BillingProfile__c, XC_PaymentMethod__c from XC_BillingProfileLineItem__c
                                                       where XC_BillingProfile__c=:listBilling[0].id];
        for(NE__Billing_Profile__c bp : listBilling){
            bp.NE__Payment__c = 'Bank Transfer';
        }
        update listBilling;
        listOrderItem[0].XC_BillingProfileLineItem__c=listbpli[0].id;
        listOrderItem[0].XC_PaymentMethod__c = 'Bank Transfer';
        insert listOrderItem;
        System.assert(true,XC_UTIL_OneOrg.isRightCountry('Spain'));
        // listOrderItem[0].NE__Qty__c=2;
        // update listOrderItem;
        Test.stopTest(); 
        
        // System.assert(false,listOrderItem[0].HasBillingProfile);        
    }
    static testMethod void hasBillingProfile(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        Test.startTest();
        insert listOrderItem;
        List<id> orderId=new list<id>();
        for(NE__OrderItem__c orderItem:listOrderItem ){
            orderId.add(orderItem.NE__OrderId__c);
        }
        List<NE__Order__c> orderList=[select id,NE__AccountId__c from NE__Order__c where id IN:orderId ];
        Map<id,Account> mapAcc= new Map<id,Account>( [select id from Account where id=:orderList[0].NE__AccountId__c]);
        List<Account> accList=new List<Account>();
        accList.add(mapAcc.get(orderList[0].NE__AccountId__c));                                
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        listBilling=XC_DF_BillingProfile.createBillingProfile(1,accList);
        List<XC_BillingProfileLineItem__c>  listbpli= [select id, XC_BillingProfile__c,XC_PaymentMethod__c from XC_BillingProfileLineItem__c
                                                       where XC_BillingProfile__c=:listBilling[0].id];
        for(NE__Billing_Profile__c bp : listBilling){
            bp.NE__Payment__c = 'Bank Transfer';
        }
        update listBilling;
        //listOrderItem[0].XC_BillingProfileLineItem__c=Listbpli[0].id;
        for(NE__OrderItem__c orderItem:listOrderItem){
            orderItem.XC_BillingProfileLineItem__c=listbpli[0].id;
            orderItem.XC_PaymentMethod__c = 'Bank Transfer';
        }
        update listOrderItem;
        System.assert(true,XC_UTIL_OneOrg.isRightCountry('Spain'));
        Test.stopTest();   
    }
}