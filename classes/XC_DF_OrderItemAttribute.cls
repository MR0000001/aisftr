/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the ne__order_item_attribute__c object
*/
@isTest
public class XC_DF_OrderItemAttribute {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description it creates the order item to attach to the order passed as input
    * @param order the order
    * @return the item created
    */
    public static NE__Order_Item_Attribute__c createOrderItemAttribute(NE__OrderItem__c orderItem, String name, String value) {

        NE__Order_Item_Attribute__c item = new NE__Order_Item_Attribute__c(
            Name = name,
            NE__Value__c = value,
            NE__Order_Item__c = orderItem.Id          
        );
        return item;
    }

}