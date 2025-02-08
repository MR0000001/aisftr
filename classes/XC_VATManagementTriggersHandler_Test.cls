@isTest
public with sharing class XC_VATManagementTriggersHandler_Test {

    @TestSetup
    static void setup(){
        NE__Order__c order = new NE__Order__c();
        NE__OrderItem__c oiOld = new NE__OrderItem__c();
        NE__OrderItem__c oiNew = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenOld = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenNew = new NE__OrderItem__c();
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        XC_BillingProfileLineItem__c bpli1 = new XC_BillingProfileLineItem__c();
        XC_BillingProfileLineItem__c bpli2 = new XC_BillingProfileLineItem__c();
        List<XC_Address__c> addresses;
        XC_Address__c address1 = new XC_Address__c();
        XC_Address__c address2 = new XC_Address__c();
        List<Account> accounts = new List<Account>();
        List<NE__Billing_Profile__c> bps;

        order = XC_DF_Order.createOrder('Asset');
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2B';
        update order;

        accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;

        addresses = XC_DF_Address.createAddress(accounts);
        insert addresses;

        bps = XC_DF_BillingProfile.createBillingProfile(1);
        bps[0].NE__Payment__c = 'Credit Card';
        update bps;

        //bpli1.XC_SoldToAddress__c = addresses[0].Id;
        bpli1.XC_BillingProfile__c = bps[0].Id;
        insert bpli1;

        oiOld = XC_DF_OrderItem.createOrderItem(order);
        oiOld.NE__OrderId__c = order.Id;
        //oiOld.XC_BillingProfileLineItem__c = bpli1.Id;
        oiOld.XC_Country__c='Spain';
        insert oiOld;
		
        oiNew = XC_DF_OrderItem.createOrderItem(order);
        oiNew.NE__OrderId__c = order.Id;
        //oiNew.XC_BillingProfileLineItem__c = bpli1.Id;
        oiNew.XC_ApplyNormalTaxByDefault__c = false;
        oiNew.XC_Country__c='Spain';
        insert oiNew;

        oiChildrenOld = XC_DF_OrderItem.createOrderItem(order);
        oiChildrenOld.NE__OrderId__c = order.Id;
        oiChildrenOld.NE__Parent_Order_Item__c = oiOld.Id;
        oiChildrenOld.XC_ApplyNormalTaxByDefault__c = false;
        oiChildrenOld.XC_Country__c='Spain';
        insert oiChildrenOld;

        oiChildrenNew = XC_DF_OrderItem.createOrderItem(order);
        oiChildrenNew.NE__OrderId__c = order.Id;
        oiChildrenNew.NE__Parent_Order_Item__c = oiNew.Id;
        oiChildrenNew.XC_ApplyNormalTaxByDefault__c = false;
        oiChildrenNew.XC_Country__c='Spain';
        insert oiChildrenNew;
    }

    @isTest
    public static void applyNormalTaxByDefaultTest(){
        NE__OrderItem__c oiOld = new NE__OrderItem__c();
        NE__OrderItem__c oiNew = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenOld = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenNew = new NE__OrderItem__c();
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        List<NE__OrderItem__c> ois = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c,XC_Country__c FROM NE__OrderItem__c];
        List<XC_BillingProfileLineItem__c> bplis = [SELECT Id, XC_PaymentMethod__c FROM XC_BillingProfileLineItem__c];

        oiOld = ois[0];

        oiNew = ois[1];
        oiNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        oiNew.XC_PaymentMethod__c = 'Credit Card';
        update oiNew;
        
        oiChildrenOld = ois[2];

        oiChildrenNew = ois[3];
        oiChildrenNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        oiChildrenNew.XC_PaymentMethod__c = 'Credit Card';
        update oiChildrenNew;

        mapOld.put(oiOld.Id, oiOld);
        mapOld.put(oiChildrenOld.Id, oiChildrenOld);
        mapNew.put(oiNew.Id, oiNew);
        mapNew.put(oiChildrenNew.Id, oiChildrenNew);

        for(Id key : mapNew.keyset()){
            System.debug('ALC mapNew.get(key).XC_Segment__c: '+mapNew.get(key).XC_Segment__c);
            System.debug('ALC mapNew.get(key).XC_LegalEntityFormula__c: '+mapNew.get(key).XC_LegalEntityFormula__c);
            System.debug('ALC mapNew.get(key).NE__Parent_Order_Item__c: '+mapNew.get(key).NE__Parent_Order_Item__c);
        }

        Test.startTest();
        XC_VATManagementTriggersHandler.applyNormalTaxByDefault(mapOld, mapNew);
        ois = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, XC_Tax_Type__c,XC_Country__c FROM NE__OrderItem__c];
        System.assert(!ois.isEmpty(), 'No se realizó el proceso correctamente');
        Test.stopTest();
    }

    @isTest
    public static void applyNormalTaxByDefaultTest2(){
        NE__OrderItem__c oiOld = new NE__OrderItem__c();
        NE__OrderItem__c oiNew = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenOld = new NE__OrderItem__c();
        NE__OrderItem__c oiChildrenNew = new NE__OrderItem__c();
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        List<NE__OrderItem__c> ois = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c,XC_Country__c FROM NE__OrderItem__c];
        List<XC_BillingProfileLineItem__c> bplis = [SELECT Id, XC_PaymentMethod__c FROM XC_BillingProfileLineItem__c];
        List<NE__Order__c> orders = [SELECT Id, XC_Segment__c, XC_LegalEntity__c FROM NE__Order__c];
        NE__Order__c order = orders[0];

        System.debug('ALC XC_LegalEntity__c: '+order.XC_LegalEntity__c);
        System.debug('ALC XC_Segment__c: '+order.XC_Segment__c);

        oiOld = XC_DF_OrderItem.createOrderItem(order);
        oiOld.NE__OrderId__c = order.Id;
        oiOld.XC_PaymentMethod__c = 'Credit Card';
        insert oiOld;
        oiOld.XC_BillingProfileLineItem__c = bplis[0].Id;
        update oiOld;

        //oiNew = ois[1];
        oiNew = XC_DF_OrderItem.createOrderItem(order);
        oiNew.NE__OrderId__c = order.Id;
        oiNew.XC_ApplyNormalTaxByDefault__c = false;
        //oiNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        oiNew.XC_PaymentMethod__c = 'Credit Card';
        insert oiNew;
        oiNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        update oiNew;
        
        //oiChildrenOld = ois[2];
        oiChildrenOld = XC_DF_OrderItem.createOrderItem(order);
        oiChildrenOld.NE__OrderId__c = order.Id;
        oiChildrenOld.NE__Parent_Order_Item__c = oiOld.Id;
        oiChildrenOld.XC_ApplyNormalTaxByDefault__c = false;
        oiChildrenOld.XC_BillingProfileLineItem__c = bplis[0].Id;
        oiChildrenOld.XC_PaymentMethod__c = 'Credit Card';
        insert oiChildrenOld;
        oiChildrenOld.XC_BillingProfileLineItem__c = bplis[0].Id;
        update oiChildrenOld;

        //oiChildrenNew = ois[3];
        oiChildrenNew = XC_DF_OrderItem.createOrderItem(order);
        oiChildrenNew.NE__OrderId__c = order.Id;
        oiChildrenNew.NE__Parent_Order_Item__c = oiNew.Id;
        oiChildrenNew.XC_ApplyNormalTaxByDefault__c = false;
        oiChildrenNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        oiChildrenNew.XC_PaymentMethod__c = 'Credit Card';
        insert oiChildrenNew;
        oiChildrenNew.XC_BillingProfileLineItem__c = bplis[0].Id;
        update oiChildrenNew;

        oiOld = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, NE__Qty__c, XC_Tax_Type__c, XC_Tax_SubType__c,XC_Country__c FROM NE__OrderItem__c WHERE Id=:oiOld.Id];
        oiNew = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, NE__Qty__c, XC_Tax_Type__c, XC_Tax_SubType__c,XC_Country__c FROM NE__OrderItem__c WHERE Id=:oiNew.Id];
        oiChildrenOld = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, NE__Qty__c, XC_Tax_Type__c, XC_Tax_SubType__c,XC_Country__c FROM NE__OrderItem__c WHERE Id=:oiChildrenOld.Id];
        oiChildrenNew = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, NE__Qty__c, XC_Tax_Type__c, XC_Tax_SubType__c,XC_Country__c FROM NE__OrderItem__c WHERE Id=:oiChildrenNew.Id];

        System.debug('ALC oiOld.XC_LegalEntityFormula__c: '+oiOld.XC_LegalEntityFormula__c);
        System.debug('ALC oiChildrenOld.XC_LegalEntityFormula__c: '+oiChildrenOld.XC_LegalEntityFormula__c);
        System.debug('ALC oiNew.XC_LegalEntityFormula__c: '+oiNew.XC_LegalEntityFormula__c);
        System.debug('ALC oiChildrenNew.XC_LegalEntityFormula__c: '+oiChildrenNew.XC_LegalEntityFormula__c);

        mapOld.put(oiOld.Id, oiOld);
        mapOld.put(oiChildrenOld.Id, oiChildrenOld);
        mapNew.put(oiNew.Id, oiNew);
        mapNew.put(oiChildrenNew.Id, oiChildrenNew);

        for(Id key : mapOld.keyset()){
            System.debug('ALC mapOld.get(key).XC_Segment__c: '+mapOld.get(key).XC_Segment__c);
            System.debug('ALC mapOld.get(key).XC_LegalEntityFormula__c: '+mapOld.get(key).XC_LegalEntityFormula__c);
            System.debug('ALC mapOld.get(key).NE__Parent_Order_Item__c: '+mapOld.get(key).NE__Parent_Order_Item__c);
            System.debug('ALC mapOld.get(key).XC_BillingProfileLineItem__c: '+mapOld.get(key).XC_BillingProfileLineItem__c);
        }

        for(Id key : mapNew.keyset()){
            System.debug('ALC mapNew.get(key).XC_Segment__c: '+mapNew.get(key).XC_Segment__c);
            System.debug('ALC mapNew.get(key).XC_LegalEntityFormula__c: '+mapNew.get(key).XC_LegalEntityFormula__c);
            System.debug('ALC mapNew.get(key).NE__Parent_Order_Item__c: '+mapNew.get(key).NE__Parent_Order_Item__c);
            System.debug('ALC mapNew.get(key).XC_BillingProfileLineItem__c: '+mapNew.get(key).XC_BillingProfileLineItem__c);
        }

        Test.startTest();
        XC_VATManagementTriggersHandler.applyNormalTaxByDefault(mapOld, mapNew);
        XC_VATManagementTriggersHandler.setTaxTypes(mapNew);
        XC_VATManagementTriggersHandler.taxes(mapOld, mapNew);
        XC_VATManagementTriggersHandler.applyNormalTaxByDefaultPropagation(mapOld, mapNew);
        ois = [SELECT Id, XC_Segment__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c, XC_ApplyNormalTaxByDefault__c, NE__Parent_Order_Item__c, XC_Tax_Type__c,XC_Country__c FROM NE__OrderItem__c];
        System.assert(!ois.isEmpty(), 'No se realizó el proceso correctamente');
        Test.stopTest();
    }
}