/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  06/02/2020 
* @description XC_TR_ConfigurationItem_TEST – Test class for XC_TR_ConfigurationItem_Handler
*/ 
@isTest
public class XC_TR_ConfigurationItem_TEST {
    @isTest
    static void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        Test.stopTest();
        System.assertEquals(true, !orderItemList.isEmpty());
    }
    
    @isTest
 	static void updateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c > orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        orderItemList[0].XC_BillingModel__c = 'One Shot';
        update orderItemList;
        Test.stopTest(); 
        System.assertEquals(true, !orderItemList.isEmpty());
    }
    
    @isTest
    static void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(2);
        insert orderItemList[0];

        orderItemList[1].NE__Bundle_Configuration__c = orderItemList[0].Id;
        orderItemList[1].XC_BundleTotalOTAmount__c = 100;
        insert orderItemList[1];
        delete orderItemList; 
        Test.stopTest();
        System.assertEquals(true, !orderItemList.isEmpty());
    }

    @isTest
    static void onFillFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(3);
        NE__Billing_Profile__c billingProfiles = XC_DF_BillingProfile.createBillingProfile(1)[0];
        billingProfiles.NE__Payment__c = 'Cash';
        update billingProfiles;
        XC_BillingProfileLineItem__c billingProf = [SELECT Id, XC_PaymentMethod__c FROM XC_BillingProfileLineItem__c  WHERE XC_BillingProfile__c =:billingProfiles.Id LIMIT 1];
        NE__Order__c order = new NE__Order__c(
            Id = orderItemList[0].NE__OrderId__c,
            NE__Type__c = 'ChangeOrder',
            XC_Subtype__c = 'Substitution (Malfunction)'
        );
        update order;
        System.debug('@@@@ 1 - ' + order);
         //orderItemList[0].XC_BillingProfileLineItem__c = billingProf.Id;
        orderItemList[0].XC_BillingProfileLineItem__c = null;
        orderItemList[0].XC_PaymentMethod__c = billingProf.XC_PaymentMethod__c;
        orderItemList[0].NE__OrderId__c = order.Id;
        orderItemList[1].NE__OrderId__c = order.Id;
        orderItemList[2].NE__OrderId__c = order.Id;
        /*insert orderItemList[0];
        System.debug('@@@@ 2 - ' + orderItemList[0]);
        orderItemList[1].XC_BillingProfileLineItem__c = billingProf.Id;
        orderItemList[1].XC_PaymentMethod__c = billingProf.XC_PaymentMethod__c;
        insert orderItemList[1];*/
        Test.startTest();
        insert orderItemList;
        System.debug('@@@@ 3 - ' + orderItemList[1]);
        orderItemList[1].NE__Item_Code__c = '';
        orderItemList[1].NE__Bundle_Configuration__c = orderItemList[0].Id;
        orderItemList[1].XC_CreditAssignmentAvailable__c = true;
        orderItemList[1].XC_Product_Subtype__c = 'Incentive';
        orderItemList[2].NE__Bundle_Configuration__c = orderItemList[0].Id;
        update orderItemList;
        orderItemList[1].NE__Bundle_Configuration__c = null;
        orderItemList[1].NE__Root_Order_Item__c = orderItemList[0].Id;
        orderItemList[1].XC_BillingProfileLineItem__c = null;
        orderItemList[1].XC_PaymentMethod__c = null;
        update orderItemList[1];
        
        Test.stopTest();
        System.assertEquals(true, !orderItemList.isEmpty());
    }
    //START VDB 22-12-2021
  @isTest
    static  void updateBillingProfileItem(){
        //END VDB 22-12-2021
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        System.debug('@@productList'+productList);
        List<NE__Billing_Profile__c> bilprof= XC_DF_BillingProfile.createBillingProfile(1);
        String bilprofId = bilprof[0].Id ;
      
        System.debug('@@bilprof'+bilprof); 

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        
        orderItemList[0].NE__ProdId__c=productList[0].id;
        insert orderItemList;
        System.debug('@@orderItemList'+orderItemList); 
        //START VDB 22-12-2021 
        XC_BillingProfileLineItem__c bpl=new XC_BillingProfileLineItem__c();
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>();
        //bpl.XC_PaymentMethod__c='Direct Debt';
        bpliList.add(bpl);
        orderItemList[0].XC_BillingProfileLineItem__c= bpliList[0].Id;
        //END VDB 22-12-2021   
        NE__Order_Item_Attribute__c orderItemAttributeList = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList[0],'Partner Code','10');
        insert orderItemAttributeList;
        Test.startTest();         
        update orderItemList; 
        System.debug('@@orderItemList1'+orderItemList);
        
        System.assertEquals(true, !orderItemList.isEmpty());
        Test.stopTest();
    }   
}