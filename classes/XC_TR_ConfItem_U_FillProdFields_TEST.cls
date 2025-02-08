/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 25/09/2019 
* @description XC_TR_ConfItem_U_FillProdFields_TEST – Test class for XC_TR_ConfigurationItem_U_FillProdFields
*/
@isTest 
public without sharing class XC_TR_ConfItem_U_FillProdFields_TEST {

    @TestSetup
    static void setup(){
        
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

    }
    @isTest
    static void onInsert(){

        Test.startTest();
        List<NE__Product__c> listProduct = XC_DF_Product.createProducts(1);
        listProduct[0].XC_Product_Type__c = 'Bundle';           
        listProduct[0].XC_Product_Subtype__c = 'Bundle';
        insert listProduct;
        List<NE__OrderItem__c> listOrderItem= XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].XC_Product_Type__c = '';           
        listOrderItem[0].XC_Product_Subtype__c = '';
        listOrderItem[0].NE__ProdId__c = listProduct[0].id;
        insert listOrderItem;
        Test.stopTest();
        System.assertEquals(1, limits.getDmlStatements());

    }
    @isTest
    static void onUpdate(){
        Test.startTest();
        List<NE__Product__c> listProduct = XC_DF_Product.createProducts(1);
        listProduct[0].XC_Product_Type__c = 'Bundle';           
        listProduct[0].XC_Product_Subtype__c = 'Bundle';
        insert listProduct;
        List<NE__OrderItem__c> listOrderItem= XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;
        listOrderItem[0].XC_Product_Type__c = '';           
        listOrderItem[0].XC_Product_Subtype__c = '';
        update listOrderItem;
        listOrderItem[0].NE__ProdId__c = listProduct[0].id;
        update listOrderItem;
      
        Test.stopTest();
        System.assertEquals(1, limits.getDmlStatements());
    }
}