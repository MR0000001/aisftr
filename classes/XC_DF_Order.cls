/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the NE__Order__c object
*/
@isTest
public class XC_DF_Order {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @param type the type of the order. The possible values are the strings InOrder or ChangeOrder
    * @description creates the order
    * @return the order created
    */
    //NL-SM
    public static NE__Order__c createOrder(String type) {

        NE__Order__c order = new NE__Order__c();
        
        /* This method creates also the account and the related address */
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;

        order.NE__Type__c = type;
        order.NE__OptyId__c = o[0].Id;
        order.XC_DeliveryAddress__c = o[0].XC_Address__c;
        //order.XC_InstallationAddress__c = o[0].XC_Address__c;
       // order.XC_Subtype__c = 'End of supply';
        order.NE__AccountId__c = o[0].AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        System.debug(order);

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c = o[0].AccountId;
        insert item;
        System.debug(item);
        update order;
        System.debug([select id, (select id from NE__Order_Items__r) from NE__Order__c ][0].NE__Order_Items__r);
        

        return order;
    }

    /**
    * @description creates n orders
    * @param n the number of orders
    * @param type the type of the order
    * @return the order created
    */
    public static List<NE__Order__c> createOrders(Integer n, String type) {
        List<NE__Order__c> orderList = new List<NE__Order__c>();
        List<Opportunity> oppList  = XC_DF_Opportunity.createOpportunity(n, false);
        List<String> accountListId = new List<String>(); 
        for(Opportunity opp:oppList){
            accountListId.add(opp.AccountId);
        }
        for(Integer i = 0; i<n;i++){
            NE__Order__c order = new NE__Order__c();
            order.NE__Type__c = type;
            order.NE__AccountId__c = accountListId[i]; 
            order.NE__OptyId__c = oppList[i].Id;
            order.XC_Segment__c = 'B2C';
            orderList.add(order);
        }
        return orderList;
    }
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @param type the type of the order. The possible values are the strings InOrder or ChangeOrder
    * @description creates the order
    * @return the order created
    */
    public static NE__Order__c createOrderWithAddress(String type, Id addressId, Id accountId, Id oppId) {

        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = addressId;
        order.XC_InstallationAddress__c = addressId;
        order.NE__AccountId__c = accountId;
        order.NE__OptyId__c = oppId;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'Accepted';
       

        order.NE__Type__c = type;
     
       // order.XC_Subtype__c = 'End of supply';
       
        order.XC_Country__c = 'Spain';
        insert order;
        System.debug(order);

        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.NE__Account__c = accountId;
        item.XC_Installation_Address__c = addressId;
        insert item;
        System.debug(item);
        update order;
        System.debug([select id, (select id from NE__Order_Items__r) from NE__Order__c ][0].NE__Order_Items__r);
        

        return order;
    }
}