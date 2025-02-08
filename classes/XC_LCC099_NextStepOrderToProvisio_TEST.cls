/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  17/05/2019 
* @date Modification 05/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC099_NextStepOrderToProvisio_TEST – Test class for XC_LCC099_NextStepOrderToProvisioning
*/ 

@isTest
public with sharing class XC_LCC099_NextStepOrderToProvisio_TEST {

    @TestSetup
    static void setup(){ 
        XC_LCC099_NextStepOrderToProvisioning.forTestVar = true;
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(4);
        bp[0].NE__Payment__c = 'Bank Transfer';
        bp[1].NE__Payment__c = 'Credit Card';
        bp[2].NE__Payment__c = 'External Financing';
        bp[3].NE__Payment__c = 'Online';
        update bp;

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c];
        for(XC_BillingProfileLineItem__c bpli : bpliList){
            bpli.XC_LegalEntity__c = 'EndesaX';
            bpli.XC_Status__c = 'Active';
        }
       
        update bpliList; 

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        XC_CS_UtilityGlobalValues__c a = new XC_CS_UtilityGlobalValues__c();
        a.Name = 'InsertLogsGenerateWO';
        a.Value__c = 'true';
        insert a;
    }

    //Test Method implementFirstNextStep
    @isTest
    static void implementFirstNextStepWithoutSiteInspection(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1); 
        oi[0].XC_IsAProduct__c=true;
        oi[0].XC_PaymentMethod__c=Label.XC_CL_Online;
        oi[0].XC_Wbe__c = 'asdfsd';
        oi[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        oi[0].XC_CreditAssignmentAvailable__c = true;
        oi[0].XC_CityCode__c = '';  
        insert oi ; 
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        Test.startTest();
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        Map<Id, NE__Order__c> mapOrder = new Map<Id, NE__Order__c>();
        mapOrder.put(configurationId, new NE__Order__c(
            Id = configurationId,
            XC_FinancialPracticeStatus__c = 'In Progress',
            XC_FinancialPracticeNumber__c = 'Test',
            XC_FinancialInstitution__c = 'Test',
            XC_Segment__c = 'B2C',
            NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder,
            XC_Subtype__c = 'Change Billing Profile',
            XC_PaymentTransactionID__c = 'test'
        ));
        XC_LCC099_NextStepOrderToProvisioning.checkFieldsForExternalFinancing(configurationId, mapOrder);
        XC_LCC099_NextStepOrderToProvisioning.checkCurrentAndPreviousBpli(mapOrder, 'Provisioning');
        NE__Order_Item_Attribute__c oia = new NE__Order_Item_Attribute__c(
            Name = Label.XC_CL_Online,
            NE__Value__c = Label.XC_CL_DeliveryMethod_Shipping,
            NE__Order_Item__c = oi[0].Id
        );
        List<NE__Order_Item_Attribute__c> listOrderItemAttributes = new List<NE__Order_Item_Attribute__c>();
        listOrderItemAttributes.add(oia);
        insert listOrderItemAttributes;
        XC_LCC099_NextStepOrderToProvisioning.checkManualLogisticActivities(listOrderItemAttributes);
        Test.stopTest();
    }

    @isTest
    static void implementFirstNextStep(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1); 
        oi[0].XC_IsAProduct__c=true;
        oi[0].XC_PaymentMethod__c=null;
        oi[0].XC_Wbe__c = 'asdfsd';
        insert oi ; 
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        Test.startTest();
        String configurationId = oi[0].NE__OrderId__c;
        List<WorkOrder> woSiteInsp = XC_DF_WorkOrder.createWorkOrders(1, 'Site Inspection');
        woSiteInsp[0].XC_Configuration__c = configurationId;
        woSiteInsp[0].XC_Opportunity__c =  opps[0].Id;
        insert woSiteInsp;
        woSiteInsp[0].Status = 'Completed';
        woSiteInsp[0].XC_forSATO__c = true;
        /*woSiteInsp[0].Status = 'Assigned';
        update woSiteInsp;
        woSiteInsp[0].Status = 'In Progress';
        update woSiteInsp;
        woSiteInsp[0].Status = 'Completed';*/
        update woSiteInsp[0];
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest();
    }

    @isTest
    static void implementFirstNextStep4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest();  //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1); 
        oi[0].XC_IsAProduct__c=true;
        oi[0].XC_PaymentMethod__c='External Financing';
        oi[0].XC_Wbe__c = 'asdfsd';
        insert oi ; 
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = false;
        update itemCatalog;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        String configurationId = oi[0].NE__OrderId__c; 
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        NE__Order__c order = new NE__Order__c(Id = oi[0].NE__OrderId__c, XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning);
        update order;
        Test.stopTest(); //20211117_DD_PROV_22
        rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }

    /*@isTest
    static void implementFirstNextStep2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_PaymentMethod__c = 'Credit Card';
        oi[0].XC_BillingProfileLineItem__c = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Credit Card'][0].Id;
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        Test.startTest();
        NE__Order__c order = new NE__Order__c();
        order.Id = configurationId;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
        update order; 
        List<WorkOrder> woSiteInsp = XC_DF_WorkOrder.createWorkOrders(1, 'Site Inspection');
        woSiteInsp[0].XC_Configuration__c = configurationId;
        woSiteInsp[0].XC_Opportunity__c =  opps[0].Id;
        insert woSiteInsp;
        woSiteInsp[0].Status = 'Assigned';
        update woSiteInsp;
        Test.stopTest(); 
        woSiteInsp[0].Status = 'In Progress';
        update woSiteInsp;
        woSiteInsp[0].Status = 'Completed';
        update woSiteInsp;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        
    }*/
    
    /*@isTest
    static void implementFirstNextStep5(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        

        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        oi[0].XC_BillingProfileLineItem__c = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Bank Transfer'][0].Id;
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        NE__Order__c order = [SELECT Id from NE__Order__c WHERE Id =: configurationId];
        order.XC_FinancialPracticeStatus__c = 'OK';
        order.XC_FinancialInstitution__c = 'Test';
        order.XC_FinancialPracticeNumber__c = '23456';
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        update order;
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        Test.startTest();
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        List<WorkOrder> woSiteInsp = XC_DF_WorkOrder.createWorkOrders(1, 'Site Inspection');
        woSiteInsp[0].XC_Configuration__c = configurationId;
        woSiteInsp[0].XC_Opportunity__c =  opps[0].Id;
        insert woSiteInsp;
        woSiteInsp[0].Status = 'Assigned';
        update woSiteInsp;
        woSiteInsp[0].Status = 'In Progress';
        update woSiteInsp;
        woSiteInsp[0].Status = 'Completed';
        update woSiteInsp;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest(); 
    }*/
    
    @isTest
    static void implementFirstNextStep6(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        NE__Order__c order = [SELECT Id from NE__Order__c WHERE Id =: configurationId];
        order.XC_FinancialPracticeStatus__c = 'OK';
        order.XC_FinancialInstitution__c = 'Test';
        order.XC_FinancialPracticeNumber__c = '23456';
        update order;
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest(); 
    }
    
    @isTest
    static void implementFirstNextStepNew2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        Account acc = [SELECT Id from Account WHERE Id =:opps[0].AccountId];
        acc.XC_DocumentCountry__c = '';
        acc.IdentityType__c = '';
        acc.IdentityNumber__c = '';
        update acc;
        NE__Order__c order = [SELECT Id from NE__Order__c WHERE Id =: configurationId];
        order.NE__AccountId__c = acc.id;
        update order;
    
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest(); 
    }
    
    @isTest
    static void implementFirstNextStep7(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        oi[0].XC_BillingProfileLineItem__c = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Bank Transfer'][0].Id;
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        NE__Order__c order = new NE__Order__c();
        order.Id = configurationId;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        update order; 
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest(); 
    }

    @isTest
    static void implementSecondNextStep2withTwoOrderItems() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(2);
        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.XC_Site_Inspection_Required__c = true;
        insert catItem;
        for(NE__OrderItem__c orderItem : listOrderItem) {
            orderItem.XC_PaymentMethod__c = 'Credit Card'; 
            orderItem.NE__CatalogItem__c = catItem.Id;
        }
        String configurationId = listOrderItem[0].NE__OrderId__c;
        listOrderItem[1].NE__OrderId__c = configurationId;
        insert listOrderItem; 
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        for(Integer i=0; i<2; i++) {
            XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
            ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow;
            ps.XC_Configuration_Item__c = listOrderItem[i].Id;
            listSteps.add(ps);
        }
        insert listSteps;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_ReceivingChannel__c = 'PDS';
        insert listOfOpp;
        NE__Order__c order = new NE__Order__c();
        order.Id = configurationId;
        order.NE__OptyId__c = listOfOpp[0].Id;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        update order; 

        Test.startTest();
        XC_UTIL_ResultWrapper rwFirst = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        XC_UTIL_ResultWrapper rwSecond = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
        Test.stopTest();
        //System.assertEquals(true, rwSecond.success);
    }

    @isTest 
    static void implementFirstNextStep3 (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest(); //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        oi[0].XC_Wbe__c = 'dsvfewr32';
        update oi;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }
    
    @isTest
    static void implementFirstNextStep10 (){
                insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest(); //20211117_DD_PROV_22
        List<NE__Billing_Profile__c> bp = xc_df_billingprofile.createBillingProfileBankTrans(1);
        
            
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingProfileLineItem__c = [select id from XC_BillingProfileLineItem__c][0].id;
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        oi[0].XC_CongaDynamicAPI__c = Label.XC_CL_Yes;
        oi[0].XC_CreditAssignmentAvailable__c = true;
        insert oi ; 
        oi[0].XC_Wbe__c = 'dsvfewr32';
        update oi;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_LegalEntity__c = 'EnelXItalia';
    order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        // Test.stopTest(); //20211117_DD_PROV_22
        ////System.assertEquals(true, rw.success);
    }
    
    @isTest
    static void implementFirstNextStepNew(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_BillingModel__c = 'One Shot';
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        NE__Order__c order = new NE__Order__c();
        order.Id = configurationId;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        update order; 
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest();
    }

    @isTest
    static void implementSecondNextStep (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        Test.stopTest();
    }

    @isTest
    static void implementSecondNextStep2 (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest();  //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        List<XC_Address__c> add = XC_DF_Address.createAddress(1);
        Insert add;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, XC_InstallationAddress__r.XC_Address__c, XC_InstallationAddress__r.XC_PostalCode__c,
                            XC_InstallationAddress__r.XC_City__c, XC_InstallationAddress__r.XC_AddressCountry__c, NE__OptyId__r.AccountId, 
                            NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Address__r.XC_PostalCode__c, NE__OptyId__r.XC_Address__c
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];

        order.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        //order.XC_InstallationAddress__r.XC_PostalCode__c ='11';
        order.NE__OptyId__c = listOfOpp[0].id;
        order.NE__OptyId__r = listOfOpp[0];
        order.NE__OptyId__r.XC_Address__c= add[0].id;
        order.NE__OptyId__r.XC_Address__r= add[0];        
        order.NE__OptyId__r.XC_Address__r.XC_PostalCode__c= '33';
        order.XC_LegalEntity__c = 'EnelXItalia';
        order.XC_Segment__c= 'B2C';
        update order; 
Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        try{
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
        XC_LCC099_NextStepOrderToProvisioning.createWorkOrder(order, 2);
        }catch(Exception e){
            System.debug('test');
        }
        ////System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    } 


    
    @isTest
    static void implementThirdNextStep (){

        try{
            NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
            conf.XC_LegalEntity__c = 'EnelXItalia';
            conf.XC_Segment__c= 'B2B';
            conf.XC_ProvisioningType__c = 'Predefined';
            update conf;

            NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
            confItem.NE__Account__c = conf.NE__AccountId__c;
            confItem.XC_IsAProduct__c = true;
            confitem.XC_Wbe__c = '4849944';
            confitem.NE__RecurringChargeOv__c = 0;
            confitem.NE__OneTimeFeeOv__c = 0;
            confitem.RecordTypeId = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId();
            insert confItem;
            
            //List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
            XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
            ps.XC_Step_Order__c = 1;
            insert ps;
            
            String configurationId = confItem.NE__OrderId__c;
            System.debug('configurationId: ' + configurationId);
            Test.startTest();
            XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementThirdNextStep(configurationId);
            //System.assert(String.isNotBlank(configurationId));
            Test.stopTest();
        }catch(Exception e){
            System.debug('exception: ' + e);
        }
    }

    @isTest
    static void implementFirstNextStep3Italy (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        // Test.startTest(); //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        oi[0].XC_Wbe__c = 'dsvfewr32';
        update oi;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_LegalEntity__c = 'EnelXItalia';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        ////System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }

    @isTest
    static void implementFirstNextStep8 (){

        String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Credit Card'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest();  //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_Wbe__c = 'dsvfewr32';
        oi[0].XC_PreviousBillingProfileLineItem__c = bpliID;
        oi[0].XC_BillingProfileLineItem__c = bpliID;
        oi[0].XC_PaymentMethod__c = 'Credit Card';
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi; 
		Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = 'Change Billing Profile';
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }
    
    @isTest
    static void implementFirstNextStep9 (){

        String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Online'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest(); Test.startTest(); //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_Wbe__c = 'dsvfewr32';
        oi[0].XC_PreviousBillingProfileLineItem__c = bpliID;
        oi[0].XC_BillingProfileLineItem__c = bpliID;
        oi[0].XC_PaymentMethod__c = 'Online';
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi; 
		Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }


    
     //Test Method checkManualLogisticActivities 
    @isTest
    static void checkManualLogisticActivities (){
        
        String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Online'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');

        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_Wbe__c = 'dsvfewr32';
        oi[0].XC_PreviousBillingProfileLineItem__c = bpliID;
        oi[0].XC_BillingProfileLineItem__c = bpliID;
        oi[0].XC_PaymentMethod__c = 'Online';
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi;   
        
        NE__Order_Item_Attribute__c oia = XC_DF_OrderItemAttribute.createOrderItemAttribute(oi[0], Label.XC_CL_DeliveryMethod,Label.XC_CL_DeliveryMethod_Shipping);
        insert oia;
        Test.startTest();
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeDisconnection;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        Test.stopTest();
    }



    @isTest


    static void implementSecondNextStep2_Delivery (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Test.startTest(); //20211117_DD_PROV_22
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(2);
        oi[1].XC_Wbe__c = 'dsvfewr32';
        oi[0].XC_Wbe__c = 'dsvfewr32';
        insert oi ; 
        oi[0].NE__Bundle_Configuration__c=oi[1].Id;
        oi[0].NE__Parent_Order_Item__c = oi[1].Id;
        update oi;
        List<XC_Address__c> add = XC_DF_Address.createAddress(1);
        Insert add;
        Test.startTest(); //20211117_DD_PROV_22
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, XC_InstallationAddress__r.XC_Address__c, XC_InstallationAddress__r.XC_PostalCode__c,
                            XC_InstallationAddress__r.XC_City__c, XC_InstallationAddress__r.XC_AddressCountry__c, NE__OptyId__r.AccountId, 
                            NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Address__r.XC_PostalCode__c, NE__OptyId__r.XC_Address__c
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];

        order.NE__Type__c= Label.XC_CL_Configuration_TypeDisconnection;
        //order.XC_InstallationAddress__r.XC_PostalCode__c ='11';
        order.NE__OptyId__c = listOfOpp[0].id;
        order.NE__OptyId__r = listOfOpp[0];
        order.NE__OptyId__r.XC_Address__c= add[0].id;
        order.NE__OptyId__r.XC_Address__r= add[0];        
        order.NE__OptyId__r.XC_Address__r.XC_PostalCode__c= '33';
        order.XC_LegalEntity__c = 'EnelXItalia';

        order.XC_Segment__c= 'B2C';

        //update order; 
        Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>();
        mapConfiguration.put(order.id,order);
         Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM = new  Map<String,XC_CM_LegalEntity_Configuration__mdt>();
        Boolean b = XC_LCC099_NextStepOrderToProvisioning.checkCreditCheck(mapConfiguration, mapLeConfigurationCM);


        XC_Provisioning_Step__c ps1= XC_DF_ProvisioningStep.createProvisioningStep(oi[0].Id);
        ps1.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow ;
        insert ps1;
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(oi[0].Id);
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow ;
        insert ps;
        String configurationId = oi[0].NE__OrderId__c;
        Test.stopTest(); //20211117_DD_PROV_22
        try{
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(configurationId);
        XC_LCC099_NextStepOrderToProvisioning.createWorkOrder(order, 2);
        }catch(Exception e){
            System.debug('test');
        }
        ////System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    } 

    @isTest
    static void implementFirstNextStepInstallment (){

		String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Bank Transfer'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_Wbe__c = 'dsvfewr32';
        oi[0].XC_PreviousBillingProfileLineItem__c = bpliID;
        oi[0].XC_BillingProfileLineItem__c = bpliID;
        oi[0].XC_PaymentMethod__c = 'Bank Transfer';
        oi[0].XC_BillingModel__c = 'Installment Plan';
        oi[0].NE__ProdId__c = [SELECT Id FROM NE__Product__c][0].id;
        insert oi; 

        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
		Test.startTest();
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeInOrder;
        order.XC_LegalEntity__c = 'EnelSole';
        order.XC_Segment__c= 'B2B';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(true, rw.success);
        Test.stopTest();
    }

    @isTest
    static void manageProvisioningInsert (){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        Test.startTest();
        
        NE__Order__c o = XC_DF_Order.createOrder('test');
        
        List<NE__OrderItem__c> listorderItems = new List<NE__OrderItem__c>([
            SELECT Id, NE__Bundle_Configuration__c, XC_Product_Type__c, NE__Root_Order_Item__c,NE__OrderId__c,
                (SELECT Id, XC_Flow_API_Name__c  FROM Provisioning_Steps__r) 
            FROM NE__OrderItem__c 
            WHERE NE__OrderId__c = :o.Id
        ]);
    NE__OrderItem__c ordItem = XC_DF_OrderItem.createOrderItem(o);
        insert ordItem;
        listorderItems[0].NE__Bundle_Configuration__c = ordItem.Id;
        update listorderItems;
        XC_Provisioning_Step__c prov = XC_DF_ProvisioningStep.createProvisioningStep(listorderItems[0].Id);
        prov.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
        insert prov;
        
        XC_LCC099_NextStepOrderToProvisioning.manageChangeInProvisioning(o.Id, rw);
    }

      /**
    * @description Methods to cover B2B/G methods
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 31-08-2021
    **/
    @isTest
    static void coverB2Bmethods(){
        Set<string> setLegalEntity=new Set<String>{'EnelXItalia'};
        Set<String> setSegment = new Set<String>{'B2G'};
        Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM=XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(setLegalEntity,setSegment);
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1); 
        oi[0].XC_IsAProduct__c=true;
        oi[0].XC_PaymentMethod__c=Label.XC_CL_Online;
        oi[0].XC_Wbe__c = 'asdfsd';
        insert oi ; 
        NE__Catalog_Item__c itemCatalog = [SELECT Id,XC_Site_Inspection_Required__c FROM NE__Catalog_Item__c WHERE Id =: oi[0].NE__CatalogItem__c];
        itemCatalog.XC_Site_Inspection_Required__c = true;
        update itemCatalog;
        Test.startTest();
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        opps[0].XC_ProductCategoryOfInterest__c = 'Solar fotovoltaica';
        insert opps;
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        Map<Id, NE__Order__c> mapOrder = new Map<Id, NE__Order__c>();
        mapOrder.put(configurationId, new NE__Order__c(
            Id = configurationId,
            XC_FinancialPracticeStatus__c = 'In Progress',
            XC_FinancialPracticeNumber__c = 'Test',
            XC_FinancialInstitution__c = 'Test',
            XC_Segment__c = 'B2G',
            XC_LegalEntity__c = 'EnelX',
            NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder,
            XC_Subtype__c = 'Change Billing Profile',
            XC_PaymentTransactionID__c = 'test'
        ));
        XC_LCC099_NextStepOrderToProvisioning.checkCreditCheck(mapOrder, mapLeConfigurationCM);
        XC_LCC099_NextStepOrderToProvisioning.checkContractIsSigned(mapOrder, mapLeConfigurationCM);
        XC_LCC099_NextStepOrderToProvisioning.checkContractCigCugDetermina(mapOrder);
        XC_LCC099_NextStepOrderToProvisioning.checkProvisioningType(mapOrder);
        Test.stopTest();
    }
    
    @isTest
    static void checkPromocodeApplicationTest() {
        NE__Order__c ord = new NE__Order__c(
            XC_FinancialPracticeNumber__c = 'Test',
            XC_FinancialInstitution__c = 'Test',
            XC_Segment__c = 'B2C',
            NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder,
            XC_Subtype__c = 'Promocode application',
            XC_PaymentTransactionID__c = 'test'
        );
        insert ord;
        NE__Order__c ord2 = new NE__Order__c(
            XC_FinancialPracticeNumber__c = 'Test',
            XC_FinancialInstitution__c = 'Test',
            XC_Segment__c = 'B2C',
            NE__Type__c = 'InOrder',
            XC_PaymentTransactionID__c = 'test'
        );
        insert ord2;
        Test.startTest();
        XC_UTIL_ResultWrapper res = XC_LCC099_NextStepOrderToProvisioning.checkPromocodeApplication(ord.Id);
        XC_UTIL_ResultWrapper res2 = XC_LCC099_NextStepOrderToProvisioning.checkPromocodeApplication(ord2.Id);
        Test.stopTest();
        System.assertEquals(res.success, true);
        System.assertEquals(res2.success, false);

     }

    // [Denise Avolio - denise.avolio@accenture.com 13/10/2021 - CR NR1857 - START]
    @isTest
    static void implementFirstNextStepAffBenCheck(){
        List<NE__OrderItem__c> ordItemList = XC_DF_OrderItem.createOrderItems(1);
        insert ordItemList;
        Id odrItemId = ordItemList[0].Id;
        Id aBRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();
        XC_Affiliate_Beneficiary__c affBen = new XC_Affiliate_Beneficiary__c(XC_OrderItem__c = odrItemId,
                                                                            XC_FirstName__c = 'AB Name',
                                                                            XC_LastName__c = 'AB Surname',
                                                                            XC_Birthdate__c = Date.newInstance(2001, 3, 21),
                                                                            XC_Relationship__c = 'Holder',
                                                                            XC_Status__c = 'Not Validated',
                                                                            RecordTypeId = aBRecTypeId);
        insert affBen;
        Test.startTest();
        String configurationId = ordItemList[0].NE__OrderId__c;
        XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        Test.stopTest();
    }

    @isTest
    static void implementFirstNextStepAffBenCheck2(){
        List<NE__OrderItem__c> ordItemList = XC_DF_OrderItem.createOrderItems(1);
        insert ordItemList;

        List<NE__Order_Item_Attribute__c> ordItemAttrList = new List<NE__Order_Item_Attribute__c>();
        NE__Order_Item_Attribute__c oia = XC_DF_OrderItemAttribute.createOrderItemAttribute(ordItemList.get(0), XC_AffiliateBeneficiary_U.AFFBENCODE, 'CodeTest');
        NE__Order_Item_Attribute__c oia2 = XC_DF_OrderItemAttribute.createOrderItemAttribute(ordItemList.get(0), XC_AffiliateBeneficiary_U.PLAN, 'Basico');
    
        ordItemAttrList.add(oia);
        ordItemAttrList.add(oia2);
        insert ordItemAttrList;

        XC_AffiliateBeneficiaryConfiguration__c affBenConf = new XC_AffiliateBeneficiaryConfiguration__c(XC_ConfigurationCode__c = 'CodeTest',
                                                                                                         XC_ProductPlan__c = 'Basico',
                                                                                                         XC_ConfigurationType__c = 'Configuration Validation',
                                                                                                         XC_RecordType__c = 'XC_Affiliate');
        insert affBenConf;

        Test.startTest();
        String configurationId = ordItemList[0].NE__OrderId__c;
        XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        Test.stopTest();
    }
    // [Denise Avolio - denise.avolio@accenture.com 13/10/2021 - CR NR1857 - END]
	// * @ Mod CV CR.NR2044 @date 15/10/2021 @Description Add Test method to cover Adjustement implementation Start -->
 	@isTest
    static void implementFirstNextStep11(){
        Date d = Date.today();
        insert XC_DF_OneOrg.createOneOrg('Italy');
        Id prodId = [SELECT Id FROM NE__Product__c][0].id;
        Id bpliID =  [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Bank Transfer'][0].Id;

        NE__Product__c prodAdj = new NE__Product__c(Id= prodId, Name=Label.XC_CL_AdjustmentProdName);
        update prodAdj;

        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(3);
        for(Integer i = 0; i < oiList.size(); i++){

            oiList[i].XC_BillingModel__c = 'Recurring ';
            oiList[i].XC_PaymentMethod__c = 'Bank Transfer';
            oiList[i].XC_BillingProfileLineItem__c = bpliID;
            oiList[i].XC_Wbe__c = 'asdfsd';
            oiList[i].XC_WBE_Status__c = 'Approved';
            oiList[i].XC_Billing_Period_Recurring__c = 2;
            oiList[i].XC_Effective_Start_Date_Recurring__c = d.addYears(1);
            oiList[i].NE__Parent_Order_Item__c = oiList[1].Id;

            if(i == 1){
                oiList[i].XC_Billing_Period_Recurring__c = 1;
                oiList[i].XC_Effective_Start_Date_Recurring__c = d;

            }

            if(i == 2){
                oiList[i].XC_Effective_Start_Date_Recurring__c = null;

            }
            oiList[i].NE__OrderId__c =  oiList[0].NE__OrderId__c;
            oiList[i].NE__ProdId__c = prodId;
        }

        insert oiList;

        oiList[0].NE__Parent_Order_Item__c = oiList[1].Id;
        oiList[1].NE__Parent_Order_Item__c = oiList[0].Id;

        update oiList;

        String configurationId = oiList[0].NE__OrderId__c;
        NE__Order__c order = new NE__Order__c();
        order.Id = configurationId;
        order.XC_LegalEntity__c = 'EnelXItalia';
        order.XC_Segment__c= 'B2G';
        update order;
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        //System.assertEquals(false, rw.success);
        Test.stopTest();
    }
	//20211117_DD_PROV_22 - start
    @isTest
    static void implementFirstNextStepDDT(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Id Technical_ItemID = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Technical_Item').getRecordTypeId();

        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(2);
		oi[0].RecordTypeId = Technical_ItemID;
        insert oi ;
        
        
        update new NE__Order__c(Id = oi[0].NE__OrderId__c, XC_ProvisioningType__c = 'Predefined');
        
        Test.startTest();
        String configurationId = oi[1].NE__OrderId__c;
		XC_LCC099_NextStepOrderToProvisioning.forTestVar = True;
        XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
        XC_LCC099_NextStepOrderToProvisioning.implementThirdNextStep(configurationId);
        Test.stopTest();
    }
    //20211117_DD_PROV_22 - end
    @isTest
    static void checkPOD1(){
        Test.startTest();
        //NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        NE__Order__c order = new NE__Order__c();
        order.XC_POD__c='Test';
        order.XC_EmobilityWebAppType__c='JuiceNet Manager PRO';
        insert order;

        List<NE__Product__c> prods = XC_DF_Product.createProducts(1);
        NE__Product__c prod=prods.get(0);
        prod.XC_LIC_Product_Name__c='OpenCharge B2B';
        insert prod;
    
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.NE__ProductId__c=prod.Id;
        insert cat;
        
        List<NE__OrderItem__c> configItems = XC_DF_OrderItem.createOrderItems(5);
        for(NE__OrderItem__c oi : configItems){
            oi.NE__CatalogItem__c =cat.Id;
            oi.XC_PaymentMethod__c='Online';
        }
        insert configItems;
        List<NE__OrderItem__c> confItems = [SELECT Id, XC_PaymentMethod__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c FROM NE__OrderItem__c WHERE NE__CatalogItem__c=:cat.Id];
        for (NE__OrderItem__c oi : confItems){
            oi.NE__OrderId__c=order.id;
        }
        update confItems;
        update order;
        
        System.debug([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        //Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>();
        mapConfiguration.put(order.id,order);
        //Map<Id, NE__Order__c> mapConfigurations=[SELECT Id,XC_POD__c,]
        System.debug('@@@@@@@@ MAP CONFI');
        System.debug(mapConfiguration.values()[0].NE__Order_Items__r);
        Map<Id, NE__Order__c> retriveMapConfiguration = new Map<Id, NE__Order__c>([select id, (select id, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c, NE__Parent_Order_Item__c, NE__OrderId__r.XC_POD__c, NE__OrderId__c, NE__OrderId__r.XC_EmobilityWebAppType__c from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        boolean result=XC_LCC099_NextStepOrderToProvisioning.checkPOD(retriveMapConfiguration);
        Test.stopTest();
        System.assertEquals(false,result);

    }
    
    
    @isTest
    static void checkPOD2(){
        Test.startTest();
        //NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<XC_Address__c> addrs = XC_DF_Address.createAddress(1);
        XC_Address__c a =addrs.get(0);
        a.XC_ElectricCUPS__c='Test';
        insert a;

        NE__Order__c order = new NE__Order__c();
        order.NE__AccountId__c=a.XC_Account__c;
        order.XC_POD__c='Test';
        //order.XC_EmobilityWebAppType__c='';
        order.XC_InstallationAddress__c=a.id;
        insert order;

        List<NE__Product__c> prods = XC_DF_Product.createProducts(1);
        NE__Product__c prod=prods.get(0);
        prod.XC_LIC_Product_Name__c='OpenCharge B2B';
        insert prod;
    
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.NE__ProductId__c=prod.Id;
        insert cat;
        
        List<NE__OrderItem__c> configItems = XC_DF_OrderItem.createOrderItems(5);
        for(NE__OrderItem__c oi : configItems){
            oi.NE__CatalogItem__c =cat.Id;
            oi.XC_PaymentMethod__c='Online';
        }
        insert configItems;
        List<NE__OrderItem__c> confItems = [SELECT Id, XC_PaymentMethod__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c FROM NE__OrderItem__c WHERE NE__CatalogItem__c=:cat.Id];
        for (NE__OrderItem__c oi : confItems){
            oi.NE__OrderId__c=order.id;
        }
        update confItems;
        update order;
        
        System.debug([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        //Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>();
        mapConfiguration.put(order.id,order);
        //Map<Id, NE__Order__c> mapConfigurations=[SELECT Id,XC_POD__c,]
        System.debug('@@@@@@@@ MAP CONFI');
        System.debug(mapConfiguration.values()[0].NE__Order_Items__r);
        Map<Id, NE__Order__c> retriveMapConfiguration = new Map<Id, NE__Order__c>([select id, XC_InstallationAddress__r.XC_ElectricCUPS__c, XC_InstallationAddress__c, (select id, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c, NE__Parent_Order_Item__c, NE__OrderId__r.XC_POD__c, NE__OrderId__c, NE__OrderId__r.XC_EmobilityWebAppType__c from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        boolean result=XC_LCC099_NextStepOrderToProvisioning.checkPOD(retriveMapConfiguration);
        Test.stopTest();
        System.assertEquals(false,result);

    }
    
    @isTest
    static void checkPOD3(){
        Test.startTest();
        //NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<XC_Address__c> addrs = XC_DF_Address.createAddress(1);
        XC_Address__c a =addrs.get(0);
        a.XC_ElectricCUPS__c='Test';
        insert a;

        NE__Order__c order = new NE__Order__c();
        order.NE__AccountId__c=a.XC_Account__c;
        order.XC_POD__c='Test';
        //order.XC_EmobilityWebAppType__c='';
        //order.XC_InstallationAddress__c=a.id;
        insert order;

        List<NE__Product__c> prods = XC_DF_Product.createProducts(1);
        NE__Product__c prod=prods.get(0);
        prod.XC_LIC_Product_Name__c='OpenCharge B2B';
        insert prod;
    
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        cat.NE__ProductId__c=prod.Id;
        insert cat;
        
        List<NE__OrderItem__c> configItems = XC_DF_OrderItem.createOrderItems(5);
        for(NE__OrderItem__c oi : configItems){
            oi.NE__CatalogItem__c =cat.Id;
            oi.XC_PaymentMethod__c='Online';
        }
        insert configItems;
        List<NE__OrderItem__c> confItems = [SELECT Id, XC_PaymentMethod__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c FROM NE__OrderItem__c WHERE NE__CatalogItem__c=:cat.Id];
        for (NE__OrderItem__c oi : confItems){
            oi.NE__OrderId__c=order.id;
        }
        update confItems;
        update order;
        
        System.debug([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        //Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>([select id, (select id from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>();
        mapConfiguration.put(order.id,order);
        //Map<Id, NE__Order__c> mapConfigurations=[SELECT Id,XC_POD__c,]
        System.debug('@@@@@@@@ MAP CONFI');
        System.debug(mapConfiguration.values()[0].NE__Order_Items__r);
        Map<Id, NE__Order__c> retriveMapConfiguration = new Map<Id, NE__Order__c>([select id, XC_InstallationAddress__r.XC_ElectricCUPS__c, XC_InstallationAddress__c, (select id, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__CatalogItem__c, NE__Parent_Order_Item__c, NE__OrderId__r.XC_POD__c, NE__OrderId__c, NE__OrderId__r.XC_EmobilityWebAppType__c from NE__Order_Items__r) from NE__Order__c where id=:order.id]);
        boolean result=XC_LCC099_NextStepOrderToProvisioning.checkPOD(retriveMapConfiguration);
        Test.stopTest();
        System.assertEquals(true,result);

    }
//<-- End
//
//@isTest 
    static void getfRootProdTest (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        oi[0].XC_Wbe__c = 'dsvfewr324';
        update oi;
        Test.startTest();
        
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT Id,(SELECT id FROM NE__Order_Items__r)
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1]);
        Test.stopTest(); //20211117_DD_PROV_22
        String configurationId = oi[0].NE__OrderId__c;
        NE__OrderItem__c rootProd = XC_LCC099_NextStepOrderToProvisioning.getfRootProd(orderMap,configurationId);
        //System.assertEquals(true, rw.success);
        //Test.stopTest(); //20211117_DD_PROV_22
    }
    
     @isTest
    static void implementFirstNextStepPromoCode (){

        String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Credit Card'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi; 
		Test.startTest(); 
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_PromocodeApplication;
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c= 'B2C';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
    }
    
     @isTest
    static void implementFirstNextStepEnelSole (){

        String bpliID = [SELECT Id, XC_BillingProfile__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.NE__Payment__c =: 'Credit Card'][0].Id;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi; 
		Test.startTest();
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        order.XC_Subtype__c = Label.XC_CL_ConfigurationSubtype_PromocodeApplication;
        order.XC_LegalEntity__c = 'EnelSole';
        order.XC_Segment__c= 'B2B';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
    }
    
    @isTest 
    static void implementFirstNextStepDisconnectionB2B (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oi= XC_DF_OrderItem.createOrderItems(1);
        insert oi ; 
        oi[0].XC_Wbe__c = 'dsvfewr323';
        oi[0].XC_Need_approval_VAT_exempt__c = true;
        update oi;
        Test.startTest(); 
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        NE__Order__c order = [SELECT Id, NE__Type__c, NE__OptyId__c,XC_Segment__c 
                            FROM  NE__Order__c 
                            WHERE Id=: oi[0].NE__OrderId__c
                            LIMIT 1];
        order.NE__Configuration_Type__c = 'Disconnect';
        order.XC_LegalEntity__c = 'Codensa';
        order.XC_Segment__c= 'B2B';
        order.NE__OptyId__c = listOfOpp[0].Id;
        update order; 
        Test.stopTest(); 
        String configurationId = oi[0].NE__OrderId__c;
        XC_UTIL_ResultWrapper rw = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(configurationId);
    }
    
    @isTest 
    static void checkReccurringAdjustDateTest (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c orderNew = XC_DF_Order.createOrder('InOrder');
        
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
		insert addList;
		XC_Address__c add = [SELECT id, XC_Account__c FROM XC_Address__c WHERE id=: addList[0].id  LIMIT 1];
        orderNew.NE__AccountId__c = add.XC_Account__c;
        orderNew.XC_DeliveryAddress__c = addList[0].id;
        orderNew.XC_InstallationAddress__c = addList[0].id;
        update orderNew;
        
        NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
        insert cat;

        NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.Name = 'Balance';
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        insert prodToInsert;
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.XC_Product_Type__c = 'Bundle';              
        oi.XC_Product_Subtype__c = 'Bundle';              
        oi.NE__Status__c = 'Pending';              
        oi.NE__ProdId__c = prodToInsert.Id;              
        oi.NE__Qty__c = 1;              
        oi.NE__BaseRecurringCharge__c = 0;
        oi.NE__RecurringChargeOv__c = 0;              
        oi.NE__CatalogItem__c = cat.Id;              
        oi.XC_BillingModel__c = 'Usage';              
        oi.NE__OneTimeFeeOv__c = 1;
        oi.NE__OrderId__c = orderNew.id;
        oi.NE__Account__c = add.XC_Account__c;
        oi.XC_Installation_Address__c = addList[0].id;
        oi.XC_Billing_Period_Recurring__c = 2;
        oi.XC_Effective_Start_Date_Recurring__c = Date.today();
        insert oi ; 
        
        NE__OrderItem__c oi2 = new NE__OrderItem__c();
        oi2.XC_Product_Type__c = 'Electric';              
        oi2.XC_Product_Subtype__c = 'Service';              
        oi2.NE__Status__c = 'Pending';              
        oi2.NE__ProdId__c = prodToInsert.Id;              
        oi2.NE__Qty__c = 1;              
        oi2.NE__BaseRecurringCharge__c = 0;
        oi2.NE__RecurringChargeOv__c = 0;              
        oi2.NE__CatalogItem__c = cat.Id;              
        oi2.XC_BillingModel__c = 'Usage';              
        oi2.NE__OneTimeFeeOv__c = 1;
        oi2.NE__OrderId__c = orderNew.id;
        oi2.NE__Account__c = add.XC_Account__c;
        oi2.XC_Installation_Address__c = addList[0].id;
        insert oi2 ; 
        Test.startTest();
        
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT Id,(SELECT id, NE__ProdName__c, XC_Effective_Start_Date_Recurring__c, NE__Parent_Order_Item__c, XC_Billing_Period_Recurring__c, NE__EndDate__c FROM NE__Order_Items__r)
                            FROM  NE__Order__c 
                            WHERE Id=: oi.NE__OrderId__c
                            LIMIT 1]);
        Test.stopTest();
        String configurationId = oi.NE__OrderId__c;
        Map<String,Object> checkList  = XC_LCC099_NextStepOrderToProvisioning.checkReccurringAdjustDate(orderMap);
    }
    
}