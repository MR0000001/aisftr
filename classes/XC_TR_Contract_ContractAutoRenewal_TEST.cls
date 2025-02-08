@isTest
public with sharing class XC_TR_Contract_ContractAutoRenewal_TEST {
    @isTest
    static void test1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        cnt.XC_PrimaryContact__c = true;
        Account acc = new Account(
            Id = cnt.AccountId
        );
        update acc;

        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;

        NE__Order__c order2 = new NE__Order__c();
        order2.NE__Type__c = 'InOrder';
        order2.NE__OptyId__c = o[0].Id;
        order2.XC_DeliveryAddress__c = o[0].XC_Address__c;
        //order2.NE__AccountId__c = acc.Id;
        order2.XC_Country__c = 'Italy';
        order2.XC_LegalEntity__c = 'EnelXItalia';
        order2.XC_Segment__c = 'B2G';
        insert order2;

        NE__Catalog__c n = new NE__Catalog__c();
        insert n;
        
        NE__Catalog_Category__c catName = new NE__Catalog_Category__c();
        catName.XC_LIC_Category_Name__c = 'Software';
        catName.NE__CatalogId__c = n.Id;
        insert catName;

        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.NE__Catalog_Category_Name__c = catName.Id;
        cat.NE__Catalog_Id__c = n.Id;
        insert cat;


        List<NE__Product__c> productList = XC_DF_Product.createProducts(2);
        productList[1].NE__Engine_Code__c= '22123';
        productList[1].Name = 'prodName2223';
        insert productList;
        
        NE__OrderItem__c item2 = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',   
           //NE__ProdId__c = productList[1].Id,
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = order2.Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = cat.Id,                
           XC_BillingModel__c = 'Usage',
           NE__OneTimeFeeOv__c = 1
        );
        item2.NE__Account__c = o[0].AccountId;
        insert item2;

        Contract cntr = XC_DF_Contract.createCondominiumContract(new List<Account>{acc})[0];
        cntr.EndDate = Date.today().addDays(10);
        cntr.XC_LegalEntity__c = 'EnelXMobilityItalia';
        cntr.XC_Configurations__c = order2.Id;
        cntr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();

        Test.startTest();
        insert cntr;
        Test.stopTest();

        //List<XC_Customer_Interaction__c> result = [SELECT Id from  XC_Customer_Interaction__c WHERE XC_Communication_Type__c = 'Contract_Auto_Renewal'];
        //system.assertEquals(1,result.size());
    }
}