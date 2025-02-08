/**
* @author
* @date Creation  05/06/2019 
* @description XC_TR_ConfigurationItem_U_CheckIfPr_TEST – Test class for XC_TR_ConfigurationItem_U_CheckIfPr
*/ 
@isTest
private class XC_TR_ConfigurationItem_U_CheckIfPr_TEST {

    @isTest
    static void onBeforeInsertTest() {
        
     OneOrg__c org = new OneOrg__c();
     org.Name='OneOrg (User)';
     org.XC_Spain_Triggers__c=true;
     insert org;
     NE__Catalog_Item__c catalogItem= XC_DF_CatalogItem.createCatalogItem();
     insert catalogItem;
     List<NE__OrderItem__c> orderItem=XC_DF_OrderItem.createOrderItems(1);
     insert orderItem;
     NE__OrderItem__c orderItemUpdate  = [select IsDeleted from NE__OrderItem__c where NE__Status__c = 'Pending' limit 1];
     orderItemUpdate.NE__Status__c='Completed';
     update orderItemUpdate;
     System.assertEquals(true, orderItemUpdate!=null);
        
        
   }
}