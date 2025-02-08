/**
* @author: Donato Lombardi
* @date Creation Date: 09/09/2019
* @description calculate WBS class TEST
*/
@isTest
public class XC_LCC_056_CalculateWBS_UU_Test {
     static testMethod void submitTest(){
          NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_LegalEntity__c='EnelX';
        update o;
        List<NE__OrderItem__c> itemList = [SELECT NE__RecurringChargeOv__c, id,XC_TotalPrice__c, NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        List<NE__Catalog_Item__c> catolList = [SELECT id,XC_ProductServiceType__c,XC_ProductLine__c FROM NE__Catalog_Item__c where id = :itemList[0].NE__CatalogItem__c];
        catolList[0].XC_ProductServiceType__c='014';
        catolList[0].XC_ProductLine__c = 'E600';  
        update catolList;
         /*
        Opportunity op = [select id, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
        op.XC_SalesChannel__c = 'Enel X KAM';
        op.XC_LegalEntity__c= 'EnelX';
        op.XC_BillingModel__c = 'One Shot';
        op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();
        update op; 
*/
          Opportunity op = [select id,XC_RevenueFullLife__c,XC_GrossMarginFullLife__c, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
         op.XC_SalesChannel__c = 'Enel X KAM';
         op.XC_ProductCategoryOfInterest__c = 'Demand Response';
         op.XC_ProductCategory__c = 'DR';
         op.XC_BusinessLine__c = 'eIndustry';
         op.XC_LegalEntity__c= 'EnelXItalia';
         op.XC_BillingModel__c = 'One Shot';
         op.XC_Segment__c = 'B2B';
         op.XC_RevenueFullLife__c=50.1;
         op.XC_GrossMarginFullLife__c=30.1;
         op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
         update op;
        itemList[0].XC_Wbe__c ='CL25E60019YS01410G009s';
        itemList[0].NE__RecurringChargeOv__c=300;
        update itemList;
        NE__OrderItem__c penality = itemList[0].clone(false,false,false,false);
        penality.XC_Product_Subtype__c ='Penalty';
       // penality.NE__OneTimeFeeOv__c = 104;
        penality.NE__RecurringChargeOv__c=300.00;
        penality.NE__Parent_Order_Item__c = itemList[0].id;
        penality.NE__Qty__c = 1;
        penality.NE__OrderId__c = o.id;
        
        insert penality;  
        List<NE__OrderItem__c> listOrderItems = new List<NE__OrderItem__c>();
         listOrderItems.add(itemList[0]);
         listOrderItems.add(penality);
        // XC_LCC_056_CalculateWBS_UU.wbeTOCol(listOrderItems);

         XC_LCC_056_CalculateWBS_UU.checkSalesChannel(listOrderItems);
     }

}