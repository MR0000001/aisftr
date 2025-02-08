@isTest
public without sharing class XC_TR_ConfiItem_U_CheckInstalAdd_TEST {
	@isTest
    static void onUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        list<NE__Order__c> ord = [Select id, XC_Segment__c FROM NE__Order__c limit 2];
        ord[0].XC_Segment__c = 'B2B';
         ord[0].XC_Segment__c = 'B2B';
        update ord;
        insert orderItemList;
       
        
        // update orderItemList[0];
        orderItemList = [select id, XC_Installation_Address__c, XC_Segment__c FROM NE__OrderItem__c];
        List<Account> acc = [SELECT id from Account LIMIT 1];
        List<XC_Address__c> addList = XC_DF_Address.createAddress(acc);
        insert addList;
        orderItemList[0].XC_Installation_Address__c =addList[0].id;
        orderItemList[0].NE__Account__c = acc[0].id;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1, acc);
        bp[0].NE__Payment__c='Bank Transfer';
        update bp;
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c();
        bpli.XC_BillingProfile__c = bp[0].id;
        bpli.XC_SoldToAddress__c =addList[0].id;
        insert bpli;
        orderItemList[0].XC_BillingProfileLineItem__c = bpli.id;
         orderItemList[0].XC_BillingModel__c = 'One Shot';
        orderItemList[0].XC_PaymentMethod__c = 'Bank Transfer';
        update orderItemList[0];
        /*orderItemList[1].XC_Installation_Address__c =addList[1].id;
		mapOld.put(orderItemList[0].id, orderItemList[0]);
        mapNew.put(orderItemList[0].id, orderItemList[1]);
       
        XC_TR_ConfiItem_U_CheckInstalAddress.onUpdate(mapOld, mapNew);
        
        XC_TR_ConfiItem_U_CheckInstalAddress.checkBillingProfileAd(mapNew);*/
    }
}