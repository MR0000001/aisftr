@isTest
public class XC_LCC250_CreditCheckVerify_TEST {
    @testSetup
      static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        
        oppList[0].XC_Segment__c = 'B2G';        
        oppList[0].XC_LegalEntity__c = 'EnelXItalia';
        oppList[0].XC_Invited_Checkbox__c = false;
        oppList[0].StageName = 'Abandoned';
        oppList[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        oppList[0].XC_ProductCategoryOfInterest__c='eMobility Recharge Manager';
        oppList[0].XC_ProductCategory__c='eMobility';
        oppList[0].XC_BusinessLine__c = 'eMobility';
        oppList[0].XC_IndustrialKPI__c=null;
        Test.startTest();
        update oppList;

        List<Account> acc = [SELECT Id FROM Account];
        List<XC_Address__c> address = [SELECT Id FROM XC_Address__c];

        
        NE__Order__c o = XC_DF_Order.createOrderWithAddress('InOrder',address[0].Id,acc[0].Id,oppList[0].Id);

        NE__OrderItem__c item = [SELECT id FROM NE__OrderItem__c where NE__OrderId__c=: o.Id];
        delete item;

        o.RecordTypeId = Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        o.XC_Segment__c = 'B2G';
        o.XC_LegalEntity__c = 'EnelXItalia';
        o.NE__OptyId__c = oppList[0].Id;
        update o;

        Test.stopTest();
        List<NE__Order__c> order = new List<NE__Order__c>();
        order.add(o);

        NE__OrderItem__c configItem = XC_DF_OrderItem.createOrderItem(order[0]);
        configItem.RecordTypeId = Schema.getGlobalDescribe().get('NE__OrderItem__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        configItem.XC_Wbe__c = '';
        configItem.XC_BillingModel__c = 'One Shot';
        configItem.XC_PaymentMethod__c = 'Bank Transfer';
        configItem.NE__Account__c = acc[0].Id;
        configItem.XC_Installation_Address__c = address[0].Id;
        

        insert configItem;

        List<NE__Billing_Profile__c> bilProfile = XC_DF_BillingProfile.createBillingProfile(1,acc);
        bilProfile[0].NE__Payment__c='Bank Transfer';
        update bilProfile;

        List<XC_BillingProfileLineItem__c> bilProfileItem = [SELECT Id,XC_PaymentMethod__c from XC_BillingProfileLineItem__c where XC_BillingProfile__c =: bilProfile[0].Id];

        configItem.XC_BillingProfileLineItem__c = bilProfileItem[0].Id;

        update configItem;
    }

    @isTest
    static void submit(){
        List<NE__Order__c> configItem = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 
        
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__c);
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__r.XC_ProductCategoryOfInterest__c);

        Test.startTest();
        XC_LCC250_CreditCheckVerify.resultWrapper result = XC_LCC250_CreditCheckVerify.submit(configItem[0].Id);
        Test.stopTest();

        system.assertEquals(true,result.success);
    }

    @isTest
    static void submitSuccessWithCase1(){
        List<Opportunity> opp = [SELECT Id FROM Opportunity];
        opp[0].XC_RevenueFullLife__c = 50000;

        update opp;

        Test.startTest();
        List<NE__Order__c> configItem = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 
        
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__c);
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__r.XC_ProductCategoryOfInterest__c);
        
        XC_LCC250_CreditCheckVerify.resultWrapper result1 = XC_LCC250_CreditCheckVerify.submit(configItem[0].Id);
        Test.stopTest();

        system.assertEquals(true,result1.success);
    }

    @isTest
    static void submitSuccessWithCase2(){
        List<Opportunity> opp = [SELECT Id FROM Opportunity];
        opp[0].XC_RevenueFullLife__c = 150000;

        update opp;

        Test.startTest();
        List<NE__Order__c> configItem = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 
        
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__c);
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__r.XC_ProductCategoryOfInterest__c);
        
        XC_LCC250_CreditCheckVerify.resultWrapper result1 = XC_LCC250_CreditCheckVerify.submit(configItem[0].Id);
        Test.stopTest();

        system.assertEquals(true,result1.success);
    }

    @isTest
    static void submitErrorWithInstallment(){
        List<NE__Order__c> config = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 

        List<NE__OrderItem__c> configItem = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: config[0].Id];
        configItem[0].XC_BillingModel__c = 'Installment plan';

        update configItem;

        Test.startTest();
        
        XC_LCC250_CreditCheckVerify.resultWrapper result2 = XC_LCC250_CreditCheckVerify.submit(config[0].Id);
        Test.stopTest();

        system.assertEquals(false,result2.success);
    }

    @isTest
    static void checkGovernanceFirstLevel(){
        List<Opportunity> opp = [SELECT Id FROM Opportunity];
        opp[0].XC_BusinessModel__c = 'Capex Intensive';
        opp[0].XC_CapexFullLife__c = 150000;

        update opp;

        Test.startTest();
        List<NE__Order__c> configItem = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 
        
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__c);
        system.debug('DIM TEST ' + configItem[0].NE__OptyId__r.XC_ProductCategoryOfInterest__c);
        
        XC_LCC250_CreditCheckVerify.resultWrapper result1 = XC_LCC250_CreditCheckVerify.submit(configItem[0].Id);
        Test.stopTest();

        system.assertEquals(true,result1.success);
    }

    @isTest
    static void checkBillingModelofOrder(){
        List<Opportunity> opp = [SELECT Id,XC_BusinessLine__c FROM Opportunity];
        opp[0].XC_ProductCategoryOfInterest__c='eMobility Recharge Manager';
        opp[0].XC_ProductCategory__c='eMobility';
        opp[0].XC_BusinessLine__c = 'eMobility';
        opp[0].XC_IndustrialKPI__c = null;
        update opp;
        List<NE__Order__c> config = [SELECT Id,XC_Segment__c,XC_Country__c FROM NE__Order__c]; 
        List<NE__OrderItem__c> configItem = [SELECT XC_BillingModel__c,Id,XC_InstallmentsNumber__c,XC_InstallmentFrequency__c,XC_InstallmentPlanType__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: config[0].Id];
        config[0].XC_Segment__c = 'B2B';
        config[0].XC_Country__c='Italy';

        config[0].NE__OptyId__c=opp[0].id;
        update config;
        configItem[0].XC_BillingModel__c='Installment plan';
        configItem[0].XC_InstallmentsNumber__c='12';
        configItem[0].XC_InstallmentFrequency__c='monthly';
        configItem[0].XC_InstallmentPlanType__c='Variable'; 
        configItem[0].NE__OrderId__c=config[0].id;
        configItem[0].InstallmentDivisionTax__c='no';
        configItem[0].XC_InstallmentRate__c='1';
        update configItem; 
        
        Test.startTest();
        XC_LCC250_CreditCheckVerify.resultWrapper result2 = XC_LCC250_CreditCheckVerify.submit(config[0].Id);
        Test.stopTest();
    }
        
    @isTest
    static void checkUpdatePaymentMethod(){
        Test.startTest();
        List<NE__Product__c> prods = XC_DF_Product.createProducts(1);
        NE__Product__c prod=prods.get(0);
        prod.XC_LIC_Product_Name__c='OpenCharge B2B';
        insert prod;
        
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.NE__ProductId__c=prod.Id;
        insert cat;
        
        List<NE__OrderItem__c> configItems = XC_DF_OrderItem.createOrderItems(5);
        for(NE__OrderItem__c oi : configItems){
            oi.NE__CatalogItem__c =cat.Id;
            oi.XC_PaymentMethod__c='Online';
        }
        insert configItems;
        List<NE__OrderItem__c> confItems = [SELECT Id, XC_PaymentMethod__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c FROM NE__OrderItem__c WHERE NE__CatalogItem__c=:cat.Id];
        XC_LCC250_CreditCheckVerify.updatePaymentMethod(confItems);
        Test.stopTest();
        
        List<NE__OrderItem__c> retriveConfItems = [SELECT Id, XC_PaymentMethod__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c FROM NE__OrderItem__c WHERE NE__CatalogItem__c=:cat.Id];
        for(NE__OrderItem__c oi : retriveConfItems){
            System.assertEquals('Commodity Bill',oi.XC_PaymentMethod__c);
        }
    }

    /*
    @isTest
    static void checkContract(){
        List<NE__Order__c> configItem = [SELECT Id,RecordTypeId FROM NE__Order__c];
        configItem[0].RecordTypeId = Schema.getGlobalDescribe().get('NE__Order__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();

        update configItem;

        List<Account> accList = [SELECT Id FROM Account];

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];

        List <Contract> contr= XC_DF_Contract.createCondominiumContract(accList);
        contr[0].Opportunity__c = oppList[0].Id;
        contr[0].XC_Signed__c = false;
        contr[0].RecordTypeId = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Contract').getRecordTypeId();

        insert contr; 

        Test.startTest();
        //List<NE__Order__c> configItem = [SELECT Id,NE__OptyId__c,NE__OptyId__r.XC_ProductCategoryOfInterest__c FROM NE__Order__c]; 
        
        //system.debug('DIM TEST ' + configItem[0].NE__OptyId__c);
        //system.debug('DIM TEST ' + configItem[0].NE__OptyId__r.XC_ProductCategoryOfInterest__c);
        
        XC_LCC250_CreditCheckVerify.resultWrapper result1 = XC_LCC250_CreditCheckVerify.submit(configItem[0].Id);
        Test.stopTest();

        system.assertEquals(false,result1.success);
    }*/

}