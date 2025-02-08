/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation 12/06/2019
* @description XC_TR_Configuration_U_ManageVoucher – Test Class of XC_TR_Configuration_U_ManageVoucher
*/

@isTest
public with sharing class XC_TR_Configuration_U_ManageVou_TEST {
    // Test method for afterOrderUpdate 
   static testMethod void beforeOrderUpdate(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      
   
      List<Account> acc = XC_DF_Account.createResidentialAccounts(2);
      insert acc;  
   
      List<NE__Order__c> o= XC_DF_Order.createOrders(1, 'InOrder');
      o[0].NE__AccountId__c = acc[0].Id; 
      o[0].XC_Status__c=Label.XC_CL_Configuration_OrderInProgress;
      o[0].NE__OrderStatus__c= Label.XC_CL_Order_StatusActive; 
      o[0].NE__Configuration_Type__c= Label.XC_CL_Configuration_TypeNew; 
      o[0].RecordTypeId= Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_RtOrder).getRecordTypeId();
      insert o;
   
      List<NE__Product__c> pro = XC_DF_Product.createProducts(1);
      pro[0].XC_Product_Subtype__c ='Boiler';
      pro[0].XC_Product_Type__c ='Equipment';
      pro[0].XC_LIC_Product_Name__c = Label.XC_CL_CommercialProduct_Coupon;
      insert pro;
   
   
      Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.NE__OrderStatus__c, NE__OrderId__r.RecordTypeId, NE__ProdId__r.Name,
                                                                              (SELECT Id, Name, NE__Value__c, XC_DeveloperName__c 
                                                                              FROM NE__Order_Item_Attributes__r 
                                                                              WHERE Name =: Label.XC_CL_OrderItemAttribute_Coupon)
                                                                           FROM NE__OrderItem__c
                                                                           WHERE NE__ProdId__r.Name =: Label.XC_CL_CommercialProduct_Coupon
                                                                           AND NE__OrderId__r.NE__Configuration_Type__c =: Label.XC_CL_Configuration_TypeNew]);
                  

      
      XC_Voucher__c vou = new XC_Voucher__c();
      vou.XC_Unlimited__c = true;
      vou.XC_Account__c = acc[0].Id;  
      vou.RecordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Voucher_RtSingleUse).getRecordTypeId();
      vou.XC_Usage_Counter__c = 5; 
      vou.XC_Voucher_To_Be_Created__c=3;
      insert vou;
   
      XC_VoucherUtilization__c voutiliz = new XC_VoucherUtilization__c();
      voutiliz.XC_Voucher__c = vou.Id; 
      voutiliz.XC_Account__c = acc[0].Id; 
      insert voutiliz; 

      NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(o[0]);
      confitem.NE__ProdId__c= pro[0].Id;  
      insert confitem;
   
      NE__Order_Item_Attribute__c cIattribute = new NE__Order_Item_Attribute__c();
      cIattribute.Name = Label.XC_CL_OrderItemAttribute_Coupon;
      cIattribute.NE__Order_Item__c = confitem.Id ; 
      cIattribute.NE__Value__c= [SELECT XC_VoucherCode__c FROM XC_Voucher__c][0].XC_VoucherCode__c;
      insert cIattribute; 
   
      Test.startTest(); 
      o[0].NE__AccountId__c = acc[1].Id; 
      o[0].XC_Status__c=Label.XC_CL_Configuration_OrderInProvisioning;
      o[0].NE__Configuration_Type__c= Label.XC_CL_Configuration_TypeNew;
      o[0].XC_Status__c='In Provisioning';
      o[0].NE__OrderStatus__c= Label.XC_CL_Order_StatusSent;
      o[0].NE__Type__c = 'ChangeOrder';
      o[0].XC_Subtype__c = 'Promocode application';
      o[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
      update o;  
      Test.stopTest();

      System.assertEquals('In Provisioning',[SELECT XC_Status__c FROM NE__Order__c][0].XC_Status__c);
   }

}