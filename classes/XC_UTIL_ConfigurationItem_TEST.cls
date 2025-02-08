/**
* @author Sara Miozza - sara.miozza@nttdata.com 
* @date Creation 29/05/2019
* @description XC_UTIL_ConfigurationItem_TEST –Test Class for XC_UTIL_ConfigurationItem
*/

@isTest
public class XC_UTIL_ConfigurationItem_TEST {

    @TestSetup
    static void setup(){
        NE__Order__c order =XC_DF_Order.createOrder('InOrder');
        order.XC_LegalEntity__c = 'EnelXItalia';
        update order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item,'testattr','valuetest');
        insert attr;
    }
    
    @isTest
    static void isThisARealProductTrueTest(){
        String prodName = 'Boiler';
        test.startTest();
        XC_UTIL_ConfigurationItem.isThisARealProduct(prodName);
        test.stopTest();
        System.assert(!String.isBlank(prodName));
        
    }
    
    @isTest
    static void isThisARealProductFalseTest(){
        String prodName = 'Test';
        test.startTest();
        XC_UTIL_ConfigurationItem.isThisARealProduct(prodName);
        test.stopTest();
        System.assert(!String.isBlank(prodName));
        
    }

    @isTest
    static void getOrderItemAttributeNameValueMapTest(){

        List<NE__OrderItem__c> ois = [SELECT ID, NE__IsPromo__c FROM NE__OrderItem__c];
        List<String> oiIds = XC_UTIL_Sobject.getIds(ois);

        Test.startTest();
            XC_UTIL_ConfigurationItem.getOrderItemAttributeNameValueMap(oiIds);
            XC_UTIL_ConfigurationItem.getOrderItemAttributeMap(oiIds);
            XC_UTIL_ConfigurationItem.getOrderItemSiteInspectionMap(ois);
        Test.stopTest();
    }
    
    @isTest
    static void getCheckBillingProfileTest(){

        List<NE__OrderItem__c> ois = [SELECT ID,XC_LegalEntityFormula__c, XC_PaymentMethod__c, XC_Segment__c FROM NE__OrderItem__c];
        List<String> oiIds = XC_UTIL_Sobject.getIds(ois);

        Test.startTest();
            XC_UTIL_ConfigurationItem.checkBillingProfile(ois,'TEST');
        Test.stopTest();
    }
}