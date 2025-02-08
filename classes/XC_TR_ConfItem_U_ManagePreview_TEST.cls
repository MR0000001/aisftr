/**
* @author dpalamides
* @date 16/06/2020
* @description classes.XC_TR_ConfItem_U_ManagePreview_TEST
*/

@IsTest
public without sharing class XC_TR_ConfItem_U_ManagePreview_TEST {
    @isTest
    static void onUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
        List<NE__Product__c> listProduct = XC_DF_Product.createProducts(1);

        insert listProduct;
        List<NE__OrderItem__c> listOrderItem= XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;
 
        listOrderItem[0].XC_Tax_AmountBillingPreviw__c = 100;
        listOrderItem[0].XC_Charge_Amount__c = 100;
        listOrderItem[0].XC_BillingModel__c = 'Milestone';
        update listOrderItem;
       
        listOrderItem[0].NE__OneTimeFeeOv__c = 100;        
        update listOrderItem;
        
        Test.stopTest();
        
    }
}