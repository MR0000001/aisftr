/**
* @author
* @date Creation 06/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ConfigurationItemAttr_U_Fill_TEST - Test class for XC_TR_ConfigurationItemAttr_U_FillFields
*/ 
@isTest
public class XC_TR_ConfigurationItemAttr_U_Fill_TEST {
    
    @TestSetup
    static void insertRecords(){
        Integer n = 10;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Ne__Product__c product = new Ne__Product__c();
        product.Name = 'OK Gas';
        product.XC_Product_Subtype__c = 'Bundle';
        product.XC_Product_Type__c = 'Bundle';
        
        insert product;
        List<NE__OrderItem__c> ordItems = XC_DF_OrderItem.createOrderItems(n);
        
        for(Integer i = 0; i<n; i++){
            ordItems[i].NE__ProdId__c = product.Id;
        }
          
        insert ordItems;
    }
     
    static testMethod void onInsert() {
        List<NE__Order_Item_Attribute__c> orderItemAttributes = new List<NE__Order_Item_Attribute__c>();
        List<NE__OrderItem__c> orderItems = [SELECT Id FROM NE__OrderItem__c];
        for(Integer i = 0; i<orderItems.size(); i++){
        	NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
            orderItemAttribute.NE__Order_Item__c = orderItems[i].Id;
            orderItemAttributes.add(orderItemAttribute);
        }
        
        insert orderItemAttributes;
        System.assertEquals(10, orderItems.size());
    }
}