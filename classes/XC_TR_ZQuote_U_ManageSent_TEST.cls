/**
* @author Emanuela Cacace  ecacace@deloitte.it 
* @date Creation  27/05/2019 
* @description XC_TR_ZQuote_U_ManageSent_TEST – Test class for XC_TR_ZQuote_U_ManageSent
*/

@isTest
public with sharing class XC_TR_ZQuote_U_ManageSent_TEST {
    
    
   static testMethod void testNoChangeStatus(){ 
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest(); 
      zqu__Quote__c zqu = new zqu__Quote__c();
      insert zqu;
      update zqu;
      zqu.zqu__Status__c = 'Sent to Z-Billing';
      update zqu;
      System.assert(zqu!=null);
      Test.stopTest();
   }


   static testMethod void testWithWaitForSubscriptionStep(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest();
      zqu__Quote__c zqu = new zqu__Quote__c();
      insert zqu;
      List<NE__OrderItem__c> ci = XC_DF_OrderItem.createOrderItems(1);
      ci[0].XC_ZQuoteId__c = zqu.Id;
      insert ci;

      XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(ci[0].Id);
      ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
      ps.XC_Configuration_Item__c = ci[0].Id; 
      insert ps;
      
      NE__OrderItem__c item = new NE__OrderItem__c(XC_Product_Type__c = 'Bundle',              
                                                   XC_Product_Subtype__c = 'Bundle',           
                                                   NE__Status__c = 'Pending',                  
                                                   NE__Qty__c = 1,                           
                                                   NE__BaseRecurringCharge__c = 0,             
                                                   NE__OrderId__c = ci[0].NE__OrderId__c,                  
                                                   NE__RecurringChargeOv__c = 0,               
                                                   NE__CatalogItem__c = ci[0].NE__CatalogItem__c,                
                                                   XC_BillingModel__c = 'Usage');
      insert item;
      
      XC_Provisioning_Step__c ps2 = XC_DF_ProvisioningStep.createProvisioningStep(item.Id);
      ps2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningFlow_WaitForTemporaryOffer;
      ps2.XC_Configuration_Item__c = item.Id; 
      insert ps2;
      
      zqu.zqu__Status__c = 'Sent to Z-Billing';
      zqu.XC_ProvisioningStep__c = ps.Id; 
      zqu.zqu__ZuoraSubscriptionID__c ='89213Test';
      update zqu; 
      System.assert(zqu!=null);
      Test.stopTest();
   }
    
   
   static testMethod void testWithParentOrderItem(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
      Test.startTest();
      zqu__Quote__c zqu = new zqu__Quote__c();
      insert zqu;
      List<NE__OrderItem__c> ci = XC_DF_OrderItem.createOrderItems(1);
      insert ci;
      
      NE__OrderItem__c item = new NE__OrderItem__c(XC_Product_Type__c = 'Bundle',              
                                                   XC_Product_Subtype__c = 'Bundle',           
                                                   NE__Status__c = 'Pending',                  
                                                   NE__Qty__c = 1,                           
                                                   NE__BaseRecurringCharge__c = 0,             
                                                   NE__OrderId__c = ci[0].NE__OrderId__c,                  
                                                   NE__RecurringChargeOv__c = 0,               
                                                   NE__CatalogItem__c = ci[0].NE__CatalogItem__c,                
                                                   XC_BillingModel__c = 'Usage',
                                                   NE__Parent_Order_Item__c = ci[0].Id,
                                                   XC_ZQuoteId__c = zqu.Id);
      insert item;

      XC_Provisioning_Step__c ps1 = XC_DF_ProvisioningStep.createProvisioningStep(ci[0].Id);
      ps1.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
      ps1.XC_Configuration_Item__c = ci[0].Id;
      insert ps1;

      XC_Provisioning_Step__c ps2 = XC_DF_ProvisioningStep.createProvisioningStep(ci[0].Id);
      ps2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningPaymentCheck_Flow;
      ps2.XC_Configuration_Item__c = ci[0].Id;
      insert ps2;

      XC_Provisioning_Step__c ps3 = XC_DF_ProvisioningStep.createProvisioningStep(ci[0].Id);
      ps3.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningTriggerInvoice_Flow;
      ps3.XC_Configuration_Item__c = ci[0].Id;
      ps3.XC_Status__c = 'In Progress';
      insert ps3;
      
      zqu.zqu__Status__c = 'Sent to Z-Billing';
      zqu.XC_ProvisioningStep__c = ps1.Id; 
      zqu.zqu__ZuoraSubscriptionID__c ='89213Test';
      update zqu; 
      System.assert(zqu!=null);
      Test.stopTest();
   }

}