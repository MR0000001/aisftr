/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the NE__OrderItem__c object
*/
@isTest
public class XC_DF_OrderItem {

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description it creates the order item to attach to the order passed as input
    * @param order the order
    * @return the item created
    */
    public static NE__OrderItem__c createOrderItem(NE__Order__c order) {

        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;

        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;

        NE__OrderItem__c item = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',   
           NE__ProdId__c = productList[0].Id,
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = order.Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = cat.Id,                
           XC_BillingModel__c = 'Usage'
        );
        return item;
    }
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description it creates n order items
    * @param n number of order items to create
    * @return the item created
    */
    public static List<NE__OrderItem__c> createOrderItems(Integer n) {
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, Label.XC_CL_Configuration_TypeInOrder);
        insert orderList;
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;
        for(Integer i = 0; i<n ; i++){
           NE__OrderItem__c item = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',                  
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = orderList[i].Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = cat.Id,                
           XC_BillingModel__c = 'Usage');
           orderItemList.add(item);
        }
        return orderItemList; 
    }

}