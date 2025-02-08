@isTest
public class XC_TR_ProvisioningStep_CustomIntera_TEST {
    @isTest
    static  void  customerInteractionEndOfProv(){
        NE__Catalog__c catalog = new NE__Catalog__c();
        catalog.XC_LIC_Name__c = 'Enel X Catalog B2B2G - Spain';
        insert catalog;
        NE__Catalog_Category__c parentCatalogCat = new NE__Catalog_Category__c();
        parentCatalogCat.Name = 'Customer Insights';
        parentCatalogCat.XC_LIC_Category_Name__c = 'Customer Insights';
        parentCatalogCat.NE__CatalogId__c = catalog.Id;
        insert parentCatalogCat;
        NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        catalogCat.Name = 'Customer Insights';
        catalogCat.XC_LIC_Category_Name__c = 'Customer Insights';
        catalogCat.NE__Parent_Category_Name__c = parentCatalogCat.Id;
        catalogCat.NE__CatalogId__c = catalog.Id;
        insert catalogCat;
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c();
        catItem.NE__Catalog_Category_Name__c = catalogCat.Id;
        catItem.NE__Catalog_Id__c = catalog.Id;
        catItem.NE__Type__c = 'Product';
        catItem.NE__Engine_Code__c = '134135';
        insert catItem;
        
        
        NE__Order__c ord = XC_DF_Order.createOrder('Order');
        ord.XC_Segment__c = 'B2B';
        update ord;
		NE__OrderItem__c orderItemList = XC_DF_OrderItem.createOrderItem(ord);
        orderItemList.NE__CatalogItem__c = catItem.Id;
        insert orderItemList;
        System.debug('@@' + [Select XC_Segment__c from NE__OrderItem__c ]);
        System.debug('@@' + orderItemList.XC_Segment__c);
        XC_Provisioning_Step__c step  = XC_DF_ProvisioningStep.createProvisioningStep(orderItemList.id);
        step.XC_Status__c = 'Completed OK';
        insert step;
        XC_Provisioning_Step__c step2  = XC_DF_ProvisioningStep.createProvisioningStep(orderItemList.id);
        step2.XC_Status__c = 'Not Started';
        insert step2;
        Map<Id, XC_Provisioning_Step__c> mapNew = new Map<Id, XC_Provisioning_Step__c>();
        step = [Select id, XC_Status__c, XC_Segment__c, XC_Configuration_Item__c from XC_Provisioning_Step__c where XC_Status__c = 'Completed OK'];
        mapNew.put(step.id, step);
        Map<Id, XC_Provisioning_Step__c> mapOld = new Map<Id, XC_Provisioning_Step__c>();
        mapOld.put(step.id, step2);
        Test.startTest();
        XC_TR_ProvisioningStep_CustomInteraction.customerInteractionEndOfProv(mapNew, mapOld);
        XC_TR_ProvisioningStep_CustomInteraction.populateCustomerInteraction(orderItemList);
        Test.stopTest();
    }
}