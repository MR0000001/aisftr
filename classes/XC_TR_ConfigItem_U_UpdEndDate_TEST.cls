@isTest
public class XC_TR_ConfigItem_U_UpdEndDate_TEST {
    @testSetup static void setup() {
        NE__Order__c order = XC_DF_Order.createOrder('test');
        order.XC_Segment__c='B2B';
        update order; 
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
           XC_BillingModel__c = 'Usage',
           NE__OneTimeFeeOv__c = 1,
           XC_RecurringDuration__c = 4
          
        );
        insert item;
        insert XC_DF_OneOrg.createOneOrg('Spain');
    }
    
        @isTest
    private static void updateDateTEST() {
        Test.startTest();
        NE__OrderItem__c it = [select id, XC_RecurringDuration__c, NE__StartDate__c, XC_NE_Type__c,XC_Effective_Start_Date_Recurring__c from NE__OrderItem__c LIMIT 1];
        it.XC_RecurringDuration__c = 8;
      
        update it;
            List<NE__OrderItem__c> lister = new List<NE__OrderItem__c>{it};
            XC_TR_ConfigurationItem_U_UpdateEndDate.addRecurringPeriod(lister);
        Test.stopTest();
}
        @isTest
            private static void getRecurringNumberOfMonthsTEST() {
                Test.startTest();
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Monthly');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Annual');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Bi-Monthly');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Four-Monthly');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biennial');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biannual');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Quarter');
                XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Other');
                Test.stopTest();
}
}