@isTest
public class XC_TR_ConItem_U_GenerateWbeB2B_Test {
    static testMethod void submitTest(){
     NE__Order__c o = XC_DF_Order.createOrder('ChangeOrder');
        o.XC_LegalEntity__c='EnelX';
        o.NE__Type__c='ChangeOrder';
        o.XC_Country__c='Chile';
        o.XC_Segment__c = 'B2B';
        update o;
        List<NE__OrderItem__c> itemList = [SELECT NE__OrderItem__c.NE__ProdName__c, NE__Parent_Order_Item__c, XC_BillingProfileLineItem__c, XC_PaymentMethod__c, XC_Segment__c, XC_Product_Type__c, NE__OrderId__r.XC_LegalEntity__c,NE__OrderId__r.XC_Country__c,NE__RecurringChargeOv__c, id,XC_TotalPrice__c, NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c, XC_NE_Type__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
    	// itemList[0].XC_Wbe__c ='CL25E60019YS01410G009s';    
      //  update itemList;
        NE__OrderItem__c penality = itemList[0].clone(false,false,false,false);
        itemList[0].XC_Wbe__c ='CL25E60019YS01410G009s';
        update itemList;
        penality.XC_Product_Subtype__c ='Penalty';
       // penality.NE__OneTimeFeeOv__c = 104;
        //penality.XC_NE_Type__c = 'ChangeOrder';
        penality.NE__Parent_Order_Item__c = itemList[0].id;
        penality.NE__Qty__c = 1;
        penality.NE__OrderId__c = o.id;
        
        insert penality;  
    List<NE__OrderItem__c> listToTest = new List<NE__OrderItem__c>();
    listToTest.add(penality);
    listToTest.add(itemList[0]);   
    
    XC_TR_ConfigurationItem_U_GenerateWbeB2B.wbeChangeOrder(listToTest);
        
  }  

}