@isTest
public class XC_SC034_CreateWBE_Batch_TEST {
    
    static testMethod void submitTestWBEComplex(){
        User u =createUser();
        System.runAs(u) {
            XC_WBE_Dimension__c wb = new XC_WBE_Dimension__c ();
            wb.name = 'WBS';
            wb.XC_Scope__c = 'B2B/G';
            wb.XC_SapPillar__c = 'D4P';
            wb.XC_WbeDimensionName__c = 'WBS';
            wb.XC_WbeDimensionCode__c = '00';
            wb.XC_WbeDimensionValue__c = 'IT2KE60000YS';
            wb.XC_ProfitCenter__c = 'CL25EBG520';
            wb.XC_CostCenter__c = 'CL25E5200A';
            wb.XC_Status__c = 'New';
            wb.XC_Country__c = 'Italy';
            Insert wb;

            NE__Order__c o = XC_DF_Order.createOrder('test');
            o.XC_Segment__c = 'B2B';
            o.XC_LegalEntity__c = 'Cogenio';
            update o;
            List<NE__OrderItem__c> itemList = [SELECT id,NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
            List<NE__Catalog_Item__c> catolList = [SELECT id,XC_ProductServiceType__c,XC_ProductLine__c FROM NE__Catalog_Item__c where id = :itemList[0].NE__CatalogItem__c];
            catolList[0].XC_ProductServiceType__c = '014';
            catolList[0].XC_ProductLine__c = 'E600';
            update catolList;
            Opportunity op = [select id,XC_RevenueFullLife__c,XC_GrossMarginFullLife__c, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
            op.XC_SalesChannel__c = 'Enel X KAM';
            op.XC_ProductCategoryOfInterest__c = 'Demand Response';
            op.XC_ProductCategory__c = 'DR';
            op.XC_BusinessLine__c = 'eIndustry';
            op.XC_LegalEntity__c = 'Cogenio';
            op.XC_BillingModel__c = 'One Shot';
            op.XC_Segment__c = 'B2B';
            op.XC_RevenueFullLife__c = 50.1;
            op.XC_GrossMarginFullLife__c = 30.1;
            op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();

            update op;
            Database.executeBatch(new XC_SC034_CreateWBE_Batch(), 1);
        }
    }
    private static User createUser(){ 
        List<String> l = new List<String>{'EndesaX','EnelX','Codensa','EnelDistribucion','EnelXItalia','EnelSole','EnelXMobility'};
        User user = new User();
        user.Username = 'Digrationitab2bg@exprod.com';
        user.FirstName ='TestUser';
        user.LastName ='testUserProva';
        user.Email = 'pablo@test.com';
        user.Alias = 'TestTry';
        user.ProfileId = [SELECT Id, UserLicenseId FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        user.LocaleSidKey = 'it_IT';
        user.TimeZoneSidKey = 'GMT';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.IsActive = true;
        user.Country__c = 'Italy';
        user.CompanyP__c = 'Italy';
        user.XC_LegalEntity__c = 'EnelXItalia';
        //user.XC_LegalEntities__c = l;
        return user;
    }

}