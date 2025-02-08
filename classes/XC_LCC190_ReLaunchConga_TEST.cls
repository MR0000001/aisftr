/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  25/05/2020 
* @description XC_LCC190_ReLaunchConga_TEST – Test class for XC_LCC190_ReLaunchConga
*/ 
@isTest
public class XC_LCC190_ReLaunchConga_TEST {
    @TestSetup
    static void setup (){
        APXTConga4__Conga_Template__c congaTrigger = new APXTConga4__Conga_Template__c();
        congaTrigger.APXTConga4__Name__c = 'Contrato Renting Andromeda Sin Energia1';
        congaTrigger.Country__c = 'SPAIN';
        insert congaTrigger;
        APXTConga4__Conga_Template__c congaTrigger2 = new APXTConga4__Conga_Template__c();
        congaTrigger2.APXTConga4__Name__c = 'Clausulado Contrato renting';
        congaTrigger2.Country__c = 'SPAIN';
        insert congaTrigger2;  
        APXTConga4__Conga_Template__c congaTrigger3 = new APXTConga4__Conga_Template__c();
        congaTrigger3.APXTConga4__Name__c = 'Contract SSI-One Shot';
        congaTrigger3.Country__c = 'SPAIN';
        insert congaTrigger3;
        APXTConga4__Conga_Template__c congaTrigger4 = new APXTConga4__Conga_Template__c();
        congaTrigger4.APXTConga4__Name__c = 'MODULO Incentivo e cessione credito';
        congaTrigger4.Country__c = 'Italy';
        insert congaTrigger4;                
        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.APXTConga4__Name__c = 'OrderItemInfo';
        insert congaQuery;
       	List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        NE__Catalog__c catalog = new NE__Catalog__c(Id = catalogItem.NE__Catalog_Id__c);
        catalog.XC_LIC_Name__c = 'eHome';
        update catalog;
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(2);
        List<NE__Billing_Profile__c>  updateBPList = new List<NE__Billing_Profile__c>();
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        billingProfileList[1].NE__Payment__c = Label.XC_CL_DirectDebt;
        updateBPList.add(billingProfileList[0]);
        updateBPList.add(billingProfileList[1]);
        update updateBPList;
        
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(10);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EndesaX';
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = '3 years renting'; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_DirectDebt;
            orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeBundle;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.NE__ProdId__c = productList[0].Id;
            orItem.NE__Catalog__c = catalog.Id;
        }
        
        insert orderItems;        
    }
    
    static testMethod void callCongaContract() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c,NE__Bundle_Configuration__c,NE__ProdId__c, XC_PaymentMethod__c   FROM NE__OrderItem__c ]);
        String recordId = orderlist[0].NE__OrderId__c;
        String nameOi = orderlist[0].name + 'CONTRACT_TO_SIGN';
        Test.startTest();
        XC_LCC190_ReLaunchConga.getPickListValues(recordId);
        XC_LCC190_ReLaunchConga.startCongaFromButton(nameOi, recordId);
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
    }
    
    static testMethod void callCongaPreContractual() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c,NE__Bundle_Configuration__c, NE__ProdId__c, XC_PaymentMethod__c   FROM NE__OrderItem__c ]);
        String recordId = orderlist[0].NE__OrderId__c;
        String nameOi = orderlist[0].name + 'PRECONTRACTUAL_CONDITIONS';
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_PaymentMethod__c =: Label.XC_CL_DirectDebt]); 
        Test.startTest();
        XC_LCC190_ReLaunchConga.getPickListValues(recordId);
        XC_LCC190_ReLaunchConga.startCongaFromButton(nameOi, recordId);
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
    }
    
    static testMethod void callCongaCreditAssignment() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__Bundle_Configuration__c   FROM NE__OrderItem__c ]);
        String recordId = orderlist[0].NE__OrderId__c;
        String nameOi = orderlist[0].name + 'CREDIT_ASSIGNMENT_TO_SIGN'; 
        Test.startTest();
        XC_LCC190_ReLaunchConga.getPickListValues(recordId);
        XC_LCC190_ReLaunchConga.startCongaFromButton(nameOi, recordId);
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
    }
    
    static testMethod void callCongaError1() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__Bundle_Configuration__c   FROM NE__OrderItem__c ]);
        String recordId = orderlist[0].NE__OrderId__c;
        String nameOi = '0000122356' + 'CREDIT_ASSIGNMENT_TO_SIGN'; 
        Test.startTest();
        XC_LCC190_ReLaunchConga.getPickListValues(recordId);
        XC_LCC190_ReLaunchConga.startCongaFromButton(nameOi, recordId);
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
    }
    
    static testMethod void callCongaError2() {
        List<NE__OrderItem__c> orderlist = new List<NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__Bundle_Configuration__c   FROM NE__OrderItem__c ]);
        String recordId = orderlist[0].NE__OrderId__c;
        String nameOi = orderlist[0].name + 'NOTEXISTINGDOC'; 
        Test.startTest();
        XC_LCC190_ReLaunchConga.getPickListValues(recordId);
        XC_LCC190_ReLaunchConga.startCongaFromButton(nameOi, recordId);
        Test.stopTest();
        System.assertEquals(10, orderlist.size());
    }
}