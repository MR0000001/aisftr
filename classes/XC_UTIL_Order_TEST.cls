/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_Order_TEST – Test class for XC_UTIL_Order
*/
@istest
public class XC_UTIL_Order_TEST {
    
    //Test Method getOrderById
    
    static testMethod void getOrderById(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        NE__Order__c ord = XC_DF_Order.createOrder('Closed');
        
        XC_UTIL_Order.getOrderById(ord.Id);
        
        System.assertEquals(true,ord!=null);
        Test.stopTest();
        
    }
    
    //Test Method createOrder
    static testMethod void createOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        
        NE__Order__c ord = XC_UTIL_Order.createOrder(new XC_UTIL_Order.OrderIFWrapper());
        
        System.assertEquals(true,ord!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method createOrderItemFromOrder
    static testMethod void createOrderItemFromOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        NE__Order__c ord = XC_DF_Order.createOrder('Closed');
        list <account> lsta = XC_DF_Account.createCondominiumAccounts(3);
        
        NE__OrderItem__c orditem = XC_UTIL_Order.createOrderItemFromOrder( lsta[0].Id ,ord.Id, new XC_UTIL_Order.OrderItemWrapper());
        
        System.assertEquals(true,orditem!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method createOrdItemAttrFromWrapper
    static testMethod void createOrdItemAttrFromWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        
        list <NE__OrderItem__c> lstordit = XC_DF_OrderItem.createOrderItems(1);
        
        NE__Order_Item_Attribute__c orditemattr = XC_UTIL_Order.createOrdItemAttrFromWrapper( new XC_UTIL_Order.WrapperAttribute(), lstordit[0].Id);
        
        System.assertEquals(true,orditemattr!=null);
        Test.stopTest();
        
    }


}