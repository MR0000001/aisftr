/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  05/06/2019 
* @description XC_TR_Configuration_U_StartCongaWF_TEST – Test class for XC_TR_Configuration_U_StartCongaWF
*/ 
@isTest
public class XC_TR_Configuration_U_StartCongaWF_TEST {
    
    @TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        APXTConga4__Conga_Template__c congaTrigger = new APXTConga4__Conga_Template__c();
        congaTrigger.APXTConga4__Template_Group__c = 'General Condition Esp';
        congaTrigger.Country__c = 'SPAIN';
        insert congaTrigger;
        APXTConga4__Conga_Merge_Query__c congaQuery = new APXTConga4__Conga_Merge_Query__c();
        congaQuery.APXTConga4__Name__c = 'OrderItemInfo';
        insert congaQuery;
		NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        NE__Catalog__c catalog = new NE__Catalog__c(Id = catalogItem.NE__Catalog_Id__c);
        catalog.XC_LIC_Name__c = 'eHome';
        update catalog;
        Id recTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeQuote).getRecordTypeId();
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EndesaX';
            ord.recordTypeId = recTypeQuote;
        }
        update orderList;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
            orItem.NE__Catalog__c = catalog.Id;
        }
        
        insert orderItems;
    }
    
    static testMethod void onUpdate() {
        List<NE__Order__c> orderlist = [SELECT Id FROM NE__order__c];
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        Id recTypeOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        
        for(NE__Order__c order : orderlist){
            order.recordTypeId = recTypeOrder;
            order.NE__OptyId__c =oppList[0].Id;
        }        
        update orderlist;
        
        System.assertEquals(1, orderlist.size());
    }
    
    static testMethod void differentLegalEntity() {
        Id recTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeQuote).getRecordTypeId();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        List<NE__Order__c> orderlist = [SELECT Id FROM NE__Order__c LIMIT 1];
        for(NE__Order__c ord : orderlist){
            ord.XC_LegalEntity__c = 'EnelX';
            ord.recordTypeId = recTypeQuote;
        }
        update orderlist;
        for(NE__OrderItem__c orItem : orderItems){
            orItem.XC_IsAProduct__c = true;
            orItem.XC_BillingModel__c = Label.XC_CL_BillingModel_OneShot; 
            orItem.XC_PaymentMethod__c  = Label.XC_CL_Credit_Card;
            orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
        }
        
        insert orderItems;
        Id recTypeOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        
        for(NE__Order__c order : orderlist){
            order.recordTypeId = recTypeOrder;
            order.NE__OptyId__c =oppList[0].Id;
        }
        Test.startTest();
        update orderlist;
        Test.stopTest();
        
        System.assertEquals(1, orderlist.size());
    }
    @isTest
    static void signedByExternalCongaConfiguration (){
        Test.startTest();
        List<NE__Product__c> productList = XC_DF_Product.createProducts(1);
        insert productList;
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        for(NE__OrderItem__c orItem: orderItems ){
            orItem.NE__ProdId__c = productList[0].Id;
        }
        insert orderItems;
        List<NE__Order__c> orderList = [SELECT Id, XC_SkipContractGeneration__c FROM NE__Order__c];
        List<NE__Billing_Profile__c> listOfBP = XC_DF_BillingProfile.createBillingProfile(1);
        List<NE__Catalog__c> listOfCatalog = new List<NE__Catalog__c>([SELECT Id FROM NE__Catalog__c]);
        List<XC_BillingProfileLineItem__c> listOfBpli = new List<XC_BillingProfileLineItem__c>([SELECT Id, XC_BillingProfile__r.NE__Payment__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c  =: listOfBP[0].Id]);
        for(NE__Billing_Profile__c bp : listOfBP){
            bp.NE__Payment__c = 'Credit Card';
        }
        update listOfBP;
        for(NE__OrderItem__c oi : orderItems){
            oi.XC_BillingProfileLineItem__c = listOfBpli[0].Id;
            oi.NE__Catalog__c = listOfCatalog[0].Id;
            oi.XC_PaymentMethod__c = 'Credit Card';
            oi.NE__OrderId__c = orderList[0].Id;
        }
        update orderItems;
        for(NE__Order__c ord : orderList){
            ord.XC_LegalEntity__c = 'EnelXItalia';
            ord.XC_Country__c = 'Italy';
            ord.XC_SignedByExternal__c = 'Web';
            ord.XC_ManualLogisticActivities__c = false;

        }
        update orderList;
        Test.stopTest();
    }


    @isTest
    static void forChile (){
        Test.startTest();
       
		XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forChile(new list<NE__OrderItem__c>());
        
        Test.stopTest();
    }

    static testmethod void updateToStartCongaTest(){
        NE__OrderItem__c ordItem = [SELECT Id, XC_CongaDynamicAPI__c, Name, NE__OrderId__c, XC_CongaStaticAPI__c FROM NE__OrderItem__c LIMIT 1];
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
        wrapper.templateId = '123';
        wrapper.congaQuery = 'testQuery';
        wrapper.orderItemToBeUpdated = ordItem;
        wrapperList.add(wrapper);

        Test.startTest();
            XC_TR_Configuration_U_StartCongaWorkflow.updateToStartConga(wrapperList);
        Test.stopTest();
    }
}