@isTest
public class XC_TR_ConfItemAttr_U_ChildBM_TEST {
    @TestSetup
    static void insertRecords(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(2);
        orderItems[0].XC_LegalEntity__c = 'EnelXItalia'; 
        orderItems[0].XC_LegalEntity__c = 'EnelXItalia'; 
        orderItems[1].XC_LegalEntity__c = 'EnelXItalia'; 
        orderItems[1].XC_LegalEntity__c = 'EnelXItalia'; 
		insert orderItems;
        
        List<NE__Order__c> order = [SELECT Id FROM NE__Order__c where id = :orderItems[0].NE__ORderId__c];
        order[0].XC_Segment__c = 'B2B';
        order[0].XC_LegalEntity__c = 'EnelXItalia'; 
        update order[0];
        
        orderItems[1].NE__Root_order_item__c = orderItems[0].Id;
        orderItems[1].NE__Parent_order_item__c = orderItems[0].Id;
        
        orderItems[1].NE__OrderId__c = order[0].Id;
        orderItems[0].NE__OrderId__c = order[0].Id;
        update orderItems;
    }
                                
	static testMethod void onInsert() {
        List<NE__Order_Item_Attribute__c> orderItemAttributes = new List<NE__Order_Item_Attribute__c>();
        List<NE__OrderItem__c> orderItems = [SELECT Id FROM NE__OrderItem__c];
        NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
        orderItemAttribute.name = 'Payment Method';
        orderItemAttribute.NE__Order_Item__c = orderItems[0].Id;
        orderItemAttributes.add(orderItemAttribute);
      
        Test.startTest();
        insert orderItemAttributes;
        Test.stopTest();
  
    }
}