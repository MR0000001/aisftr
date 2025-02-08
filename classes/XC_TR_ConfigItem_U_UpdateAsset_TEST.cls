/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_ConfigItem_U_UpdateAsset_TEST – Test class for XC_TR_ConfigurationItem_U_UpdateAsset
    */ 
    @isTest
public with sharing class XC_TR_ConfigItem_U_UpdateAsset_TEST {
     // Test method for updateOnStatusCompleted 
     static testMethod void updateOnStatusCompleted(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
                confitem[0].NE__Status__c ='Pending';
                insert confitem;
                confitem[0].NE__Status__c ='Completed';
                update confitem; 

            //System.assertEquals(expected, actual);
            Test.stopTest();
     }


    // Test method for updateOriginalBillingProfile 
     static testMethod void updateOriginalBillingProfile(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<NE__Billing_Profile__c> bilprof= XC_DF_BillingProfile.createBillingProfile(1);
                String bilprofId = bilprof[0].Id ; 
                List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
                confitem[0].NE__Status__c ='Pending';
                insert confitem;
                confitem[0].NE__BillingProfId__c= bilprofId; 
                
                List<Asset> asset= XC_DF_Asset.createAssets(1);
                asset[0].XC_Configuration_Item__c = confitem[0].Id; 
                //asset[0].XC_Configuration_Item__r.NE__Status__c=Label.XC_CL_Configuration_Item_Completed;
                insert asset; 
                
                confitem[0].NE__Status__c ='Completed';
                update confitem; 

            System.assertEquals(1, confitem.size());
            Test.stopTest();
     }
    
        // Test method for updateOriginalBillingProfile 
     static testMethod void updateBillingProfileLineItem(){
         insert XC_DF_OneOrg.createOneOrg('Spain');
         Test.startTest();
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
         insert productList;
         List<NE__Billing_Profile__c> bilprof= XC_DF_BillingProfile.createBillingProfile(1);
         String bilprofId = bilprof[0].Id ; 
         NE__Billing_Profile__c bp = new NE__Billing_Profile__c(id=bilprofId, NE__Payment__c = 'Bank Transfer');
         update bp;
         List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
         confitem[0].NE__Status__c ='Pending';
         confitem[0].NE__ProdId__c = productList[0].Id;
         confitem[0].XC_PaymentMethod__c = 'Bank Transfer';
         insert confitem;
         List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id, XC_BillingProfile__r.NE__Payment__c FROM XC_BillingProfileLineItem__c LIMIT 1]);
         List<Asset> asset= XC_DF_Asset.createAssets(1);
         System.debug('@@@ bpliList-->' + bpliList);
         asset[0].XC_Configuration_Item__c = confitem[0].Id; 
         //asset[0].XC_Configuration_Item__r.NE__Status__c=Label.XC_CL_Configuration_Item_Completed;
         insert asset; 
         confitem[0].XC_BillingProfileLineItem__c= bpliList[0].Id; 
         confitem[0].NE__Status__c ='Completed';
         confitem[0].XC_PaymentMethod__c = bpliList[0].XC_BillingProfile__r.NE__Payment__c;
         update confitem; 
         System.assertEquals(1, confitem.size());
         Test.stopTest();
     }
}