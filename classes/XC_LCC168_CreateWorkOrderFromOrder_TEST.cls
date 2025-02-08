/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 30/10/2019
* @description XC_LCC168_CreateWorkOrderFromOrder_TEST – Test class for XC_LCC168_CreateWorkOrderFromOrder
*/

@isTest
public without sharing class XC_LCC168_CreateWorkOrderFromOrder_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC168_CreateWorkOrderFromOrder_TEST');

    @isTest
    private static void createWorkOrderSuccess() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(new List<Account>{new Account(Id = listOrder[0].NE__AccountId__c)});
        insert listAddress;
        listOrder[0].XC_InstallationAddress__c = listAddress[0].Id;
        insert listOrder;

        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrder[0].Id);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrder[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);


        //System.assertEquals(true, wrapper.success);
        Test.stopTest();
    }
    
     @isTest
    private static void createWorkOrderSuccess_2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_Site_Inspection_Required__c = true;
        insert catalogItem;
       
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oItem : listOrderItem){
            oItem.NE__CatalogItem__c = catalogItem.Id;
            oItem.NE__ProdId__c = productList[0].Id;
        }
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c WHERE Id =: listOrderItem[0].NE__OrderId__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EnelXItalia';
            order.XC_Segment__c='B2C';
        }
        update orderList;

        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(orderList[0].Id);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :orderList[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);

        //System.assertEquals(true, wrapper.success);
        Test.stopTest();
    }
    
      @isTest
    private static void createWorkOrderSuccess_3() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_Site_Inspection_Required__c = true;
        insert catalogItem;
         List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfileList;
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c]);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oItem : listOrderItem){
             oItem.XC_CreditAssignmentAvailable__c = false;
            oItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
            oItem.NE__CatalogItem__c = catalogItem.Id;
            oItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            oItem.NE__ProdId__c = productList[0].Id;
        }
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c WHERE Id =: listOrderItem[0].NE__OrderId__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EnelXItalia';
            order.XC_Segment__c='B2C';
        }
        update orderList;

        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(orderList[0].Id);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :orderList[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);

        //System.assertEquals(true, wrapper.success);
        Test.stopTest();
    }
    
     @isTest
    private static void createWorkOrderSuccess_4() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_Site_Inspection_Required__c = true;
        insert catalogItem;
         List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfileList;
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c]);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oItem : listOrderItem){
             oItem.XC_CreditAssignmentAvailable__c = false;
            oItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
            oItem.NE__CatalogItem__c = catalogItem.Id;
            oItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            oItem.NE__ProdId__c = productList[0].Id;
        }
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c WHERE Id =: listOrderItem[0].NE__OrderId__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EnelXItalia';
            order.XC_Segment__c='B2C';
        }
        update orderList;

        Test.startTest();
        //XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(orderList[0].Id);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :orderList[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);


        //System.assertEquals(true, wrapper.success);
        Test.stopTest();
    }

    @isTest
    private static void existingWorkOrder() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(new List<Account>{new Account(Id = listOrder[0].NE__AccountId__c)});
        insert listAddress;
        listOrder[0].XC_InstallationAddress__c = listAddress[0].Id;
        insert listOrder;
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Site Inspection - Boiler', Label.XC_CL_WorkType_SiteInspection);
        listWo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ITA_WorkOrder').getRecordTypeId();
        listWo[0].XC_LegalEntity__c ='EnelXItalia';
        listWo[0].XC_Configuration__c = listOrder[0].Id;
        insert listWo;

        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrder[0].Id);
        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 
                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrder[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);
        //System.assertEquals(true, wrapper.success);

        Test.stopTest();
    }

    @isTest
    private static void createWorkOrderError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
        insert listOrder;

        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrder[0].Id);
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrder[0].Id);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrder[0].Id
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);
        System.assertEquals(false, wrapper.success);


        Test.stopTest();
    }

    @isTest
    private static void checkCompliance0(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C0';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        insert document;
        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderItem[0].NE__OrderId__c);

        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrderItem[0].NE__OrderId__c
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);

       // System.assertEquals(false, wrapper.success);



        Test.stopTest(); 
    }
    
    @isTest
    private static void checkItalian(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_Site_Inspection_Required__c = true;
        insert catalogItem;
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfileList;
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c]);
        system.debug('@@@@@@@@@@@@ bpliList  ----> '+ bpliList);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oItem : listOrderItem){
            oItem.XC_CreditAssignmentAvailable__c = false;
            oItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
            oItem.NE__CatalogItem__c = catalogItem.Id;
            oItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            oItem.NE__ProdId__c = productList[0].Id;
        }
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c WHERE Id =: listOrderItem[0].NE__OrderId__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EnelXItalia';
        }
        update orderList;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C0';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        insert document;
        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderItem[0].NE__OrderId__c);


        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),

                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 

                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrderItem[0].NE__OrderId__c
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);
        //System.assertEquals(true, wrapper.success);

        Test.stopTest(); 
    }
    
    @isTest
    private static void checkItalianCreditassignment(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        catalogItem.XC_Site_Inspection_Required__c = true;
        insert catalogItem;
        List<NE__Billing_Profile__c>  billingProfileList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfileList[0].NE__Payment__c  = Label.XC_CL_Credit_Card;
        update billingProfileList;
        List<XC_BillingProfileLineItem__c> bpliList = new List<XC_BillingProfileLineItem__c>([SELECT Id FROM XC_BillingProfileLineItem__c]);
        system.debug('@@@@@@@@@@@@ bpliList  ----> '+ bpliList);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c oItem : listOrderItem){
            oItem.XC_CreditAssignmentAvailable__c = true;
            oItem.XC_PaymentMethod__c = Label.XC_CL_Credit_Card;
            oItem.NE__CatalogItem__c = catalogItem.Id;
            oItem.XC_BillingProfileLineItem__c = bpliList[0].Id;
            oItem.NE__ProdId__c = productList[0].Id;
        }
        insert listOrderItem;
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c WHERE Id =: listOrderItem[0].NE__OrderId__c];
        for(NE__Order__c order : orderList){
            order.XC_LegalEntity__c = 'EnelXItalia';
        }
        update orderList;
        XC_DocumentComplianceMaster__c document = new XC_DocumentComplianceMaster__c();
        document.XC_ComplianceType__c = 'C0';
        document.XC_ProductCategory__c = 'Boiler';
        document.XC_DocumentType__c = 'DNI';
        document.XC_Country__c = 'SPAIN';
        insert document;
        Test.startTest();
        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper wrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderItem[0].NE__OrderId__c);


        List<NE__Order__c> listOrderInterted = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,XC_ReceivingChannelFormula__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c 
                FROM Work_Orders__r),
                (SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 
                FROM NE__Order_Items__r)
            FROM Ne__Order__c
            WHERE Id = :listOrderItem[0].NE__OrderId__c
        ]);

        XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(listOrderInterted);
        System.assertEquals(false, wrapper.success);


        Test.stopTest(); 
    }
}