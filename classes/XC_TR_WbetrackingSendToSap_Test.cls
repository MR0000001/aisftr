/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@isTest
public with sharing class XC_TR_WbetrackingSendToSap_Test {
    static testMethod void submitTest(){

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CreateWBE';
        ic.XC_interfaceName__c = 'CreateWBE';
        insert ic;
 /*
        XC_WbeTracking__c tw = new XC_WbeTracking__c();
        tw.XC_ConfigurationItemId__c = 'DL';
        tw.XC_ConfigurationId__c = 'DL';
        tw.XC_OrderNumber__c = 'DL';
        tw.XC_SalesOrder__c = 'DL';
        tw.XC_Wbe__c = 'CL25E60019YS01420900OR';
        tw.XC_CompanyCode__c = 'CL25';
        tw.XC_ProductLine__c = 'E600';
        tw.XC_ProductService__c = '19';
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

  */
        NE__Order__c o = XC_DF_Order.createOrder('test');
        //o.XC_LegalEntity__c='EnelX';
        //update o;
        List<NE__OrderItem__c> itemList = [SELECT NE__RecurringChargeOv__c, id,XC_TotalPrice__c, NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Wbe__c = 'IT2KE600W0YS';
        update itemList;
        XC_WbeTracking__c tw = new XC_WbeTracking__c();
        tw.XC_ConfigurationItemId__c = itemList[0].id;
        tw.XC_ConfigurationId__c = o.Id;
        tw.XC_OrderNumber__c = 'DL1';
        tw.XC_SalesOrder__c = 'DL2';
        tw.XC_Wbe__c = 'IT2KE600W0YS';
        tw.XC_CompanyCode__c = 'CL25';
        tw.XC_ProductLine__c = 'E600';
        tw.XC_ProductService__c = 'DL3';
        tw.XC_WBS__c = 'DL4';
        tw.XC_WbeI__c = 'DL5';
        tw.XC_WbeII__c = 'DL6';
        tw.XC_WbeIII__c = 'DL7';
        tw.XC_BusinessModelCode__c = '2';
        tw.XC_Market__c = '002';
        tw.XC_CostCenterResponsible__c = 'DL11';
        tw.XC_CostCenter__c = 'DL8';
        tw.XC_ProfitCenter__c = 'DL9';
        tw.XC_SapPillar__c = 'S4P';
        tw.XC_Scope__c = 'B2B/G';
        tw.XC_TypeOfSending__c = 'Order Submit';
        tw.XC_Status__c = 'Sent';
        Insert tw;

       Map<Id,XC_WbeTracking__c> mapNews = new Map<id,XC_WbeTracking__c>([select Id, XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Status__c, XC_Result__c, XC_Counter__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c, XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c, XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c, XC_SapPillar__c, XC_Scope__c, XC_SentDate__c, XC_TypeOfSending__c, XC_Activity__c, XC_Applicant__c, XC_Channel__c, XC_CompanyCode__c, XC_Contract__c, XC_CostCenterApplicant__c, XC_CostCenterResponsible__c, XC_CustomerGeography__c, XC_CustomerRelevance__c, XC_CustomerSegment__c, XC_CustomerSize__c, XC_KitLogistic__c, XC_LegalEntityGeography__c, XC_Market__c, XC_OdvIntercompany__c, XC_ProductLine__c, XC_Responsible__c, XC_ReturnErrorcode__c, XC_SalesOrder__c, XC_TypeOfCustomer__c, XC_TypeOfLocation__c, XC_WBS__c, XC_WbeIDescription__c, XC_WbeIIDescription__c, XC_WbeIIIDescription__c, XC_WbeIII__c, XC_WbeII__c, XC_WbeI__c, XC_WbsDescription__c from XC_WbeTracking__c  ]);

        XC_TR_WbetrackingSendToSap.sentToSap(mapNews.keySet());
        //tw.XC_Wbe__c = 'CL25E60019WS01420900OR';
        //update tw;
        //Map<Id,XC_WbeTracking__c> mapNew = new Map<id,XC_WbeTracking__c>([select Id, XC_Wbe__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Status__c, XC_Result__c, XC_Counter__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c, XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c, XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c, XC_SapPillar__c, XC_Scope__c, XC_SentDate__c, XC_TypeOfSending__c, XC_Activity__c, XC_Applicant__c, XC_Channel__c, XC_CompanyCode__c, XC_Contract__c, XC_CostCenterApplicant__c, XC_CostCenterResponsible__c, XC_CustomerGeography__c, XC_CustomerRelevance__c, XC_CustomerSegment__c, XC_CustomerSize__c, XC_KitLogistic__c, XC_LegalEntityGeography__c, XC_Market__c, XC_OdvIntercompany__c, XC_ProductLine__c, XC_Responsible__c, XC_ReturnErrorcode__c, XC_SalesOrder__c, XC_TypeOfCustomer__c, XC_TypeOfLocation__c, XC_WBS__c, XC_WbeIDescription__c, XC_WbeIIDescription__c, XC_WbeIIIDescription__c, XC_WbeIII__c, XC_WbeII__c, XC_WbeI__c, XC_WbsDescription__c from XC_WbeTracking__c  ]);
        //XC_TR_WbetrackingSendToSap.sentToSap(mapNew.keySet());
        //XC_TR_WbetrackingSendToSap.sentToSapCapex(mapNew.keySet());



    }
    static testMethod void submitTestCapex(){

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CreateWBE';
        ic.XC_interfaceName__c = 'CreateWBE';
        insert ic;

        NE__Order__c o = XC_DF_Order.createOrder('test');
        //o.XC_LegalEntity__c='EnelX';
        //update o;
        List<NE__OrderItem__c> itemList = [SELECT NE__RecurringChargeOv__c, id,XC_TotalPrice__c, NE__CatalogItem__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Wbe__c = 'IT2KE600W0WS';
        update itemList;
        XC_WbeTracking__c tw = new XC_WbeTracking__c();
        tw.XC_ConfigurationItemId__c = itemList[0].id;
        tw.XC_ConfigurationId__c = o.Id;
        tw.XC_OrderNumber__c = 'DL';
        tw.XC_SalesOrder__c = 'DL';
        tw.XC_Wbe__c = 'IT2KE600W0WS01420900OR';
        tw.XC_CompanyCode__c = 'CL25';
        tw.XC_ProductLine__c = 'E600';
        tw.XC_ProductService__c = '19';
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

        Map<Id,XC_WbeTracking__c> mapNews = new Map<id,XC_WbeTracking__c>([select Id, XC_Wbe__c, XC_WBEcapexUpdate__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Status__c, XC_Result__c, XC_Counter__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c, XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c, XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c, XC_SapPillar__c, XC_Scope__c, XC_SentDate__c, XC_TypeOfSending__c, XC_Activity__c, XC_Applicant__c, XC_Channel__c, XC_CompanyCode__c, XC_Contract__c, XC_CostCenterApplicant__c, XC_CostCenterResponsible__c, XC_CustomerGeography__c, XC_CustomerRelevance__c, XC_CustomerSegment__c, XC_CustomerSize__c, XC_KitLogistic__c, XC_LegalEntityGeography__c, XC_Market__c, XC_OdvIntercompany__c, XC_ProductLine__c, XC_Responsible__c, XC_ReturnErrorcode__c, XC_SalesOrder__c, XC_TypeOfCustomer__c, XC_TypeOfLocation__c, XC_WBS__c, XC_WbeIDescription__c, XC_WbeIIDescription__c, XC_WbeIIIDescription__c, XC_WbeIII__c, XC_WbeII__c, XC_WbeI__c, XC_WbsDescription__c from XC_WbeTracking__c  ]);
        XC_TR_WbetrackingSendToSap.sentToSapCapex(mapNews.keySet());
        XC_TR_WbetrackingSendToSap.sendUpdateCapexSAP(mapNews,mapNews);



    }




}