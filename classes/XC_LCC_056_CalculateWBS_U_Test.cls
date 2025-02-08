/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@isTest
public with sharing class XC_LCC_056_CalculateWBS_U_Test {
    static testMethod void submitTest(){
        //XC_LCC_056_CalculateWBS_U.skipTestWBE();
        User u =createUser();
        System.runAs(u) {
            NE__Order__c o = XC_DF_Order.createOrder('test');
            List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
            List<NE__Catalog_Item__c> catolList = [SELECT id,XC_ProductServiceType__c,XC_ProductLine__c FROM NE__Catalog_Item__c where id = :itemList[0].NE__CatalogItem__c];
            catolList[0].XC_ProductServiceType__c = '018';
            catolList[0].XC_ProductLine__c = 'E600';
            update catolList;
            Opportunity op = [select id, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
            op.XC_SalesChannel__c = 'Enel X KAM';
            op.XC_LegalEntity__c = 'Codensa';
            //op.XC_BillingModel__c = 'One Shot';
            op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Colombia').getRecordTypeId();
            update op;


            XC_LCC_056_CalculateWBS_U.retriveConfItemforPenlty(o.id);
            XC_LCC_056_CalculateWBS_U.retriveConfItem(o.id);

            XC_WbeTracking__c tw = new XC_WbeTracking__c();
            tw.XC_ConfigurationItemId__c = itemList[0].id;
            tw.XC_ConfigurationId__c = o.id;
            tw.XC_OrderNumber__c = 'DL';
            tw.XC_SalesOrder__c = 'DL';
            tw.XC_Wbe__c = 'CL25E60019YS01410G009s';
            tw.XC_CompanyCode__c = 'CL25';
            tw.XC_ProductLine__c = 'E600';
            tw.XC_ProductService__c = 'DL';
            tw.XC_WBS__c = 'DL';
            tw.XC_WbeI__c = 'DL';
            tw.XC_WbeII__c = 'DL';
            tw.XC_WbeIII__c = 'DL';
            tw.XC_BusinessModelCode__c = '2';
            tw.XC_Market__c = '002';
            tw.XC_CostCenterResponsible__c = 'DL';
            tw.XC_CostCenter__c = 'DL';
            tw.XC_ProfitCenter__c = 'DL';
            tw.XC_SapPillar__c = 'S4P';
            tw.XC_Scope__c = 'B2B/G';
            tw.XC_TypeOfSending__c = 'Order Submit';
            tw.XC_Status__c = 'Sent';
            Insert tw;


            itemList[0].XC_Wbe__c = 'CL25E60019YS01410G009s';
            itemList[0].XC_Product_Subtype__c = 'Penalty';
            update itemList;

            NE__OrderItem__c er = itemList[0].clone(false, false, false, false);

            // er.NE__Parent_Order_Item__c = itemList[0].id;
            er.NE__OrderId__c = o.id;
            er.NE__Qty__c = 1;
            er.XC_Wbe__c = 'CL25E60019YS01410G009s';
            insert er;
            itemList[0].XC_Product_Subtype__c = 'Penalty';
            itemList[0].NE__Parent_Order_Item__c = er.id;
            update itemList;

            NE__OrderItem__c penality = er.clone(false, true, true, true);
            penality.XC_Product_Subtype__c = 'Penalty';
            penality.NE__Parent_Order_Item__c = er.id;
            penality.NE__OrderId__c = o.id;
            penality.NE__Qty__c = 1;
            // insert penality;


            // penality.NE__Parent_Order_Item__r.XC_Wbe__c = 'CL25E60019YS01410G009s';
            // update penality;
            List<NE__OrderItem__c> lli = new List<NE__OrderItem__c>();
            lli.add(itemList[0]);
            //lli.add(penality);
            lli.add(er);
            // update lli;
            //XC_LCC_056_CalculateWBS_U.wbsToPenalty(lli);
        }


    }
    static testMethod void submitTest1(){
        //XC_LCC_056_CalculateWBS_U.skipTestWBE();
        User u =createUser();
        System.runAs(u) {
            XC_WbeTracking__c tw = new XC_WbeTracking__c();
            //tw.XC_ConfigurationItemId__c = itemList[0].id;
            //tw.XC_ConfigurationId__c = o.id;
            tw.XC_OrderNumber__c = 'DL';
            tw.XC_SalesOrder__c = 'DL';
            tw.XC_Wbe__c = 'CL25E60019YS01410G009s';
            tw.XC_CompanyCode__c = 'CL25';
            tw.XC_ProductLine__c = 'E600';
            tw.XC_ProductService__c = 'DL';
            tw.XC_WBS__c = 'DL';
            tw.XC_WbeI__c = 'DL';
            tw.XC_WbeII__c = 'DL';
            tw.XC_WbeIII__c = 'DL';
            tw.XC_BusinessModelCode__c = '2';
            tw.XC_Market__c = '002';
            tw.XC_CostCenterResponsible__c = 'DL';
            tw.XC_CostCenter__c = 'DL';
            tw.XC_ProfitCenter__c = 'DL';
            tw.XC_SapPillar__c = 'S4P';
            tw.XC_Scope__c = 'B2B/G';
            tw.XC_TypeOfSending__c = 'Order Submit';
            tw.XC_Status__c = 'Sent';
            Insert tw;


            List<NE__OrderItem__c> lisne = XC_DF_OrderItem.createOrderItems(2);
            lisne[0].XC_Wbe__c = 'CL25E60019YS01410G009s';
            insert lisne[0];
            System.debug('DL--> wbetrToInsert' + lisne[0]);
            lisne[1].XC_Product_Subtype__c = 'Penalty';
            lisne[1].NE__Parent_Order_Item__c = lisne[0].id;
            lisne[1].NE__OrderId__c = lisne[0].NE__OrderId__c;

            insert lisne[1];

            List<NE__OrderItem__c> listNE = [
                    select id, NE__Parent_Order_Item__r.XC_Wbe__c, XC_TotalPrice__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,XC_Wbe__c,
                            NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c,
                            NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c
                    from NE__OrderItem__c
                    LIMIT 5
            ];
            System.debug('DL--> wbetrToInsert' + lisne[1]);


            XC_LCC_056_CalculateWBS_U.wbsToPenalty(listNE);
            Boolean b = XC_LCC_056_CalculateWBS_U.checkWBEForPenality(listNE[0].NE__OrderId__c);
            XC_LCC_056_CalculateWBS_UU.checkSalesChannel(listNE);

        }




    }
    private static User createUser(){
        List<String> l = new List<String>{'EndesaX','EnelX','Codensa','EnelDistribucion','EnelXItalia','EnelSole','EnelXMobility'};
        User user = new User();
        user.Username = 'test1111migrationitab2bg@exprod.com';
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