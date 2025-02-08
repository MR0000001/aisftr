/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  20/05/2019 
* @description XC_TR_ConfigItem_U_BillingModel_TEST – Test class for XC_TR_ConfigItem_U_BillingModel
*/ 
@isTest
public with sharing class XC_TR_ConfigItem_U_BillingModel_TEST {
    
    //Test method onInsert
    static testMethod void onInsert(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        System.assertEquals(1, oi.size());
        Test.stopTest();
    }
    //Test method onUpdate
    static testMethod void onUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 1619;
        oi[0].NE__BaseRecurringCharge__c=59.99;
        update oi; 
        System.assertEquals(1, oi.size());
        Test.stopTest();
    }
    
    //Test method onUpdate1
    static testMethod void onUpdate1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 1619;
        oi[0].NE__BaseRecurringCharge__c=0;
        update oi; 
        System.assertEquals(1, oi.size());
        Test.stopTest();
    }
    
    //Test method onUpdate2
    static testMethod void onUpdate2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=59.99;
        update oi; 
        System.assertEquals(1, oi.size());
        Test.stopTest();
    }
    
    
    //Test method onUpdate3
    static testMethod void onUpdate3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=0;
        update oi; 
        System.assertEquals(1, oi.size());
        Test.stopTest();
    }
    
      //Test method onUpdate4
    static testMethod void onUpdate4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(2);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=0;
        oi[0].NE__OneTimeFeeOv__c = 0;
        oi[0].NE__RecurringChargeOv__c = 10;
        oi[0].NE__Bundle_Configuration__c = oi[1].Id;
        oi[0].XC_Product_Subtype__c = 'Parameter';
        update oi; 
        System.assertEquals(2, oi.size());
        Test.stopTest();
    }  
    
      //Test method onUpdate4
    static testMethod void onUpdate5(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(2);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=0;
        oi[0].NE__OneTimeFeeOv__c = 10;
        oi[0].NE__RecurringChargeOv__c = 10;
        oi[0].NE__Bundle_Configuration__c = oi[1].Id;
        oi[0].XC_Product_Subtype__c = 'Parameter';
        update oi; 
        System.assertEquals(2, oi.size());
        Test.stopTest();
    }  
       //Test method onUpdate4
    static testMethod void onUpdate6(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(2);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=0;
        oi[0].NE__OneTimeFeeOv__c = 10;
        oi[0].NE__RecurringChargeOv__c = 0;
        oi[0].NE__Bundle_Configuration__c = oi[1].Id;
        oi[0].XC_Product_Subtype__c = 'Parameter';
        update oi; 
        System.assertEquals(2, oi.size());
        Test.stopTest();
    } 
    
         //Test method onUpdate4
    static testMethod void onUpdate7(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(2);
        insert oi;
        oi[0].NE__BaseOneTimeFee__c = 0;
        oi[0].NE__BaseRecurringCharge__c=0;
        oi[0].NE__OneTimeFeeOv__c = 0;
        oi[0].NE__RecurringChargeOv__c = 0;
        oi[0].NE__Bundle_Configuration__c = oi[1].Id;
        oi[0].XC_Product_Subtype__c = 'Parameter';
        update oi; 
        System.assertEquals(2, oi.size());
        Test.stopTest();
    }   
    
          //Test method onUpdate5
    static testMethod void onUpdate8(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(2);
        insert oi;
        oi[0].XC_PaymentMethod__c = 'External Financing';
        update oi; 
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        mapNew.put(oi[0].id, oi[0]);
        XC_TR_ConfigurationItem_U_BillingModel.checkPaymentMethodOfIncentiveBundle(mapNew);
        XC_TR_ConfigurationItem_U_BillingModel.checkBillingModel(oi);
        System.assertEquals(2, oi.size());
        Test.stopTest();
    }
    
           //Test method onUpdate5
    static testMethod void onUpdate9(){
        insert XC_DF_OneOrg.createOneOrg('Spain');    
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi;
        oi[0].XC_PaymentMethod__c = 'External Financing';
        update oi;
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        oiList[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        oiList[0].NE__Bundle_Configuration__c = oi[0].Id;
        insert oiList;
        Test.startTest();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        mapNew.put(oi[0].id, oi[0]);
        XC_TR_ConfigurationItem_U_BillingModel.checkPaymentMethodOfIncentiveBundle(mapNew);
        Test.stopTest();
    }
    
    
}