/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  07/02/2020 
* @description XC_TR_ConfigItem_U_FillFields_TEST – Test class for XC_TR_ConfigurationItem_U_FillFields
*/ 
@isTest
public class XC_TR_ConfigItem_U_FillFields_TEST {
    
    @isTest
    static void testFillFieldsConfigItem(){ 
        Integer n = 2;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'ChangeOrder');
        orderList[0].XC_Subtype__c = 'Substitution (Change of equipment)'; 
        orderList[1].XC_Subtype__c = 'Substitution (Change of equipment)'; 
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'Bank Transfer';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[i].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'Usage',
                XC_PaymentMethod__c = 'Bank Transfer',
                XC_BillingProfileLineItem__c = bpli[0].id);
            orderItemList.add(item);
            
        }
        insert orderItemList;
        //XC_TR_ConfigurationItem_U_FillFields.fillFieldsOnInsert(orderItemList);
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : orderItemList){
            mapNew.put(oi.id, oi);
        }
        Test.startTest();
        XC_TR_ConfigurationItem_U_FillFields.fillFieldsOnUpdate(mapOld, mapNew);
        Test.stopTest();
    }
    
    @isTest
    static void testFillTranslatedField(){ 
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> products = XC_DF_Product.createProducts(1);
        insert products;
        Test.startTest();
        NE__Translation__c translationRecord = new NE__Translation__c(
            NE__Commercial_Product__c = products[0].Id,
            NE__Language_user__c = 'es'
        );
        insert translationRecord;
        Integer n = 1;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EndesaX';
        }
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'Bank Transfer';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                NE__ProdId__c = products[0].Id,
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[0].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'Usage',
                XC_PaymentMethod__c = 'Bank Transfer',
                XC_BillingProfileLineItem__c = bpli[0].id);
            orderItemList.add(item);
            
        }
        insert orderItemList;
        Test.stopTest();
    }
    
    @isTest
    static void testFillWithBundle(){ 
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> products = XC_DF_Product.createProducts(1);
        insert products;
        Test.startTest();
        NE__Translation__c translationRecord = new NE__Translation__c(
            NE__Commercial_Product__c = products[0].Id,
            NE__Language_user__c = 'es'
        );
        insert translationRecord;
        Integer n = 1;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EndesaX';
        }
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'Bank Transfer';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                NE__ProdId__c = products[0].Id,
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[0].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'Usage',
                XC_PaymentMethod__c = 'Bank Transfer',
                XC_BillingProfileLineItem__c = bpli[0].id);
            orderItemList.add(item);
        }
        orderItemList[0].NE__Bundle_Configuration__c = oiList[0].Id; 
        insert orderItemList;
        test.stopTest();
    }

    @isTest
    static void populateExternalFinancingFieldsOnOrderTEST(){

        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> products = XC_DF_Product.createProducts(1);
        insert products;
        test.startTest();
        NE__Translation__c translationRecord = new NE__Translation__c(
            NE__Commercial_Product__c = products[0].Id,
            NE__Language_user__c = 'es'
        );
        insert translationRecord;
        Integer n = 1;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EndesaX';
        }
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'External Financing';
        bp[0].XC_FinancialInstitute__c = 'Other';
        bp[0].XC_LegalEntity__c = 'EndesaX';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                NE__ProdId__c = products[0].Id,
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[0].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'One Shot',
                XC_PaymentMethod__c = 'External Financing');
            orderItemList.add(item);
        }
        

        orderItemList[0].NE__Bundle_Configuration__c = oiList[0].Id; 
        insert orderItemList;
        
        for(NE__OrderItem__c oi : orderItemList){
            oi.XC_BillingProfileLineItem__c = bpli[0].id;
            oi.XC_CreditAssignmentAvailable__c = true;
        }
        
        update orderItemList;
        test.stopTest();

    }
    
  	@isTest
    static void populateExternalFinancingFieldsOnOrderTEST2(){

        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> products = XC_DF_Product.createProducts(1);
        insert products;
        test.startTest();
        NE__Translation__c translationRecord = new NE__Translation__c(
            NE__Commercial_Product__c = products[0].Id,
            NE__Language_user__c = 'es'
        );
        insert translationRecord;
        Integer n = 1;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EndesaX';
        }
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'External Financing';
        bp[0].XC_FinancialInstitute__c = 'Other';
        bp[0].XC_LegalEntity__c = 'EndesaX';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                NE__ProdId__c = products[0].Id,
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[0].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'One Shot',
                XC_PaymentMethod__c = 'External Financing');
            orderItemList.add(item);
        }
        

        orderItemList[0].NE__Bundle_Configuration__c = oiList[0].Id; 
        insert orderItemList;
        
        for(NE__OrderItem__c oi : orderItemList){
            oi.XC_BillingProfileLineItem__c = bpli[0].id;
            oi.XC_CreditAssignmentAvailable__c = true;
        }
        
        update orderItemList;
        test.stopTest();

    }
    
    @isTest
    static void testFillWithBundleChangeOrder(){ 
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__Product__c> products = XC_DF_Product.createProducts(1);
        insert products;
        test.startTest();
        NE__Translation__c translationRecord = new NE__Translation__c(
            NE__Commercial_Product__c = products[0].Id,
            NE__Language_user__c = 'es'
        );
        insert translationRecord;
        Integer n = 1;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EndesaX';
        }
        orderList[0].NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        orderList[0].XC_Subtype__c = 'Service Upgrade/Downgrade';
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        bp[0].NE__Payment__c = 'Bank Transfer';
        update bp;
        List<XC_BillingProfileLineItem__c> bpli = ([SELECT id FROM XC_BillingProfileLineItem__c]);
        for(Integer i = 0; i<n ; i++){
            NE__OrderItem__c item = new NE__OrderItem__c(
                NE__ProdId__c = products[0].Id,
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = orderList[0].Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,                
                XC_BillingModel__c = 'Usage',
                XC_PaymentMethod__c = 'Bank Transfer',
                XC_BillingProfileLineItem__c = bpli[0].id);
            orderItemList.add(item);
        }
        orderItemList[0].NE__Bundle_Configuration__c = oiList[0].Id; 
        insert orderItemList;
        test.stopTest();
    }
}