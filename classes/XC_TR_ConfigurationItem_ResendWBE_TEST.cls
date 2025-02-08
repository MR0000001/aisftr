/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@isTest
public class XC_TR_ConfigurationItem_ResendWBE_TEST {
    
    static testMethod void submitTest(){
        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.XC_LegalEntity__c = 'EnelXItalia';
        o.XC_Segment__c = 'B2B';
        update o;
        
        List<NE__OrderItem__c> itemList = [SELECT id,XC_Segment__c,XC_LegalEntity__c, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Wbe__c = '123456786543';
        itemList[0].XC_WBE_Status__c = 'Rejected';
        itemList[0].XC_BlockWBE_User__c = true;
        update itemList;
        
        Map<Id,NE__OrderItem__c> mapOlds = new Map<Id,NE__OrderItem__c>(itemList);
        Map<Id,NE__OrderItem__c> mapNews = new Map<Id,NE__OrderItem__c>();
        for(NE__OrderItem__c oi : mapOlds.values()){
            NE__OrderItem__c cl = oi.clone(true,true,true,true);
            cl.XC_WBE_Status__c = 'Sent';
            mapNews.put(cl.id,cl);
        }
        try{
        XC_TR_ConfigurationItem_ResendWBE.resendKO(mapOlds, mapNews);
        }catch(Exception e){System.debug(e.getMessage());}
        
    }
    
}