/**
* @author: Donato Lombardi
* @date Creation Date: 09/09/2019
* @description calculate WBS class TEST
*/
@isTest
public class XC_LCC_056_CalculateWBS_Test {
    static testMethod void submitTest(){
        
        XC_WBE_Dimension__c  wb = new XC_WBE_Dimension__c ();
        wb.name = 'WBS';
        wb.XC_Scope__c = 'B2B/G';
        wb.XC_SapPillar__c ='D4P';
        wb.XC_WbeDimensionName__c ='WBS';
        wb.XC_WbeDimensionCode__c='00';
        wb.XC_WbeDimensionValue__c= 'CO10E60060YS';
        wb.XC_ProfitCenter__c= 'CO10N43001';
        wb.XC_CostCenter__c= 'CO10NC4300';
        wb.XC_Status__c= 'New';
        wb.XC_Country__c= 'Colombia';
        Insert wb;
        
        
        NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id,NE__CatalogItem__c,XC_BlockWBE_User__c,XC_WBE_Status__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_WBE_Status__c= 'New';
        itemList[0].XC_BlockWBE_User__c=true;
        update itemList;
        List<NE__Catalog_Item__c> catolList = [SELECT id,XC_ProductServiceType__c,XC_ProductLine__c FROM NE__Catalog_Item__c where id = :itemList[0].NE__CatalogItem__c];
        catolList[0].XC_ProductServiceType__c='018';
        catolList[0].XC_ProductLine__c = 'E600';
        update catolList;
        Opportunity op = [select id, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
        op.XC_SalesChannel__c = 'Enel X KAM';
        op.XC_ProductCategoryOfInterest__c = 'Demand Response';
        op.XC_ProductCategory__c = 'DR';
        op.XC_BusinessLine__c = 'eIndustry';
        op.XC_LegalEntity__c= 'Codensa';
        op.XC_BillingModel__c = 'One Shot';
        op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Colombia').getRecordTypeId();
        op.XC_Segment__c = 'B2B';
        update op;
        Account acc=[Select id from account Limit 1];
        
        Contract c = new Contract();
        c.AccountId= acc.id;
        c.Status='Pending';
        c.Opportunity__c=o.NE__OptyId__c;
        c.XC_ContractType__c='Test';
        c.Contract_Type__c='Direct Contract';
        c.XC_Configurations__c=o.id;
        
        insert c;
        //donato test
        //List<XC_WBE_Order_Number__c> maxList = [select XC_AutonumberWBS__c from XC_WBE_Order_Number__c order by XC_AutonumberWBS__c desc limit 1];
        
        String mess = XC_LCC_056_CalculateWBS.submit(o.id);
        //System.assertEquals(Label.XC_WBE_Error_Address, mess);
    }
    static testMethod void submitTestWBEComplex(){
        XC_WBE_Dimension__c  wb = new XC_WBE_Dimension__c ();
        wb.name = 'WBS';
        wb.XC_Scope__c = 'B2B/G';
        wb.XC_SapPillar__c ='D4P';
        wb.XC_WbeDimensionName__c ='WBS';
        wb.XC_WbeDimensionCode__c='00';
        wb.XC_WbeDimensionValue__c= 'IT2KE600W0YS';
        wb.XC_ProfitCenter__c= 'CL25EBG520';
        wb.XC_CostCenter__c= 'CL25E5200A';
        wb.XC_Status__c= 'New';
        wb.XC_Country__c= 'Chile';
        Insert wb;
        
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        o.XC_Calculation_Channel_WBE_EC__c = 'Offerta Comunità Energetica';
        update o;
        
        Contract contract1 = new Contract();
        contract1.XC_Configurations__c=o.id;
        contract1.StartDate=Date.newInstance(2021, 6, 23);
        contract1.EndDate=Date.newInstance(2021, 6, 25);
        contract1.AccountId = o.NE__AccountId__c;
        insert contract1;
        
        List<NE__OrderItem__c> itemList = [SELECT id,NE__CatalogItem__c,NE__OrderId__r.name, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_BlockWBE_User__c=true;
        itemList[0].XC_WBE_Status__c= 'New';
        update itemList;
        List<NE__Catalog_Item__c> catolList = [SELECT id,XC_ProductServiceType__c,XC_ProductLine__c FROM NE__Catalog_Item__c where id = :itemList[0].NE__CatalogItem__c];
        catolList[0].XC_ProductServiceType__c='014';
        catolList[0].XC_ProductLine__c = 'E600';
        update catolList;
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
        Account acc = [SELECT Id FROM Account WHERE ID = :o.NE__AccountId__c];
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        acc.XC_DocumentCountry__c = 'Italy';
        acc.XC_Zone__c='B2G-B2G';
        acc.XC_Segment__c = 'B2B';
        update acc;
        
        update op;

        Contract c = new Contract();
        c.AccountId= acc.id;
        c.Status='Pending';
        c.Opportunity__c=o.NE__OptyId__c;
        c.XC_ContractType__c='Test';
        c.Contract_Type__c='Direct Contract';
        c.XC_Configurations__c=o.id;
        c.StartDate = Date.today();
        c.EndDate = Date.today();
        insert c;

        XC_WBEGeographicalData__c geographicalData = new XC_WBEGeographicalData__c();
        geographicalData.XC_Country__c= 'Italy';
        geographicalData.XC_LegalEntity__c='EnelXItalia';
        geographicalData.XC_Segment__c='B2B';
        geographicalData.XC_ObjectToQuery__c='Account';
        geographicalData.XC_FieldToQuery__c='XC_Zone__c';
        geographicalData.XC_ValueToCompare__c='B2G-B2G';
        geographicalData.XC_ValueToUse__c='W0';
        geographicalData.XC_OrderFieldReference__c='NE__OrderId__r.NE__AccountId__c';
        insert geographicalData;
        XC_WBE_Order_Number__c autNumber = new XC_WBE_Order_Number__c();
        autNumber.name= o.name;
        autNumber.XC_EnelXItalia_Number__c = 0001;
        insert autNumber;
        //donato test
        
        String mess = XC_LCC_056_CalculateWBS.submit(o.id);
        
        
    }
    
    static testMethod void wbeExsisting(){
        NE__Order__c o = XC_DF_Order.createOrder('test');
        Contract contract1 = new Contract();
        contract1.XC_Configurations__c=o.id;
        contract1.StartDate=Date.newInstance(2021, 6, 23);
        contract1.AccountId = o.NE__AccountId__c;
        insert contract1;
        List<NE__OrderItem__c> itemList = [
            SELECT 
            id,NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,
            NE__CatalogItem__r.XC_ProductServiceType__c,  
            NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, 
            NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , 
            XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,
            NE__OrderId__r.NE__OptyId__c,
            NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Wbe__c= 'Test';        
        update itemList;
        //donato test
        String mess = XC_LCC_056_CalculateWBS.submit(o.id);
    }
    
    
    
    
    
    
    
}