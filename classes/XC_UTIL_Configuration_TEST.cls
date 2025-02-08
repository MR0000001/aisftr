/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 29/05/2019
* @description XC_UTIL_Configuration_TEST –Test Class 
*/

@isTest
private class XC_UTIL_Configuration_TEST {
    static testMethod void getConfigurationNew() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(100, 'InOrder');
        for(NE__Order__c order: orderList ){
            order.NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
        }
        insert orderList;
        
        Set<Id> orderIdSet = new Set<Id>{orderList[0].Id};
        List<NE__Order__c> newOrderList = XC_UTIL_Configuration.getConfigurationNew(orderList);
        XC_UTIL_ResultWrapper rw = XC_UTIL_Configuration.checkOpportunityStage(orderList[0].Id);
        XC_UTIL_Configuration.getAdditionalAmountFromAcceptedQuoteOrder(orderIdSet);
        System.assertEquals(newOrderList.size(), orderList.size());
        Test.stopTest();
    }
    
    static testMethod void getAllConfItemIds() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(100, 'InOrder');
        for(NE__Order__c order: orderList ){
            order.NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
        }
        insert orderList;
        Set<Id> newOrderList = XC_UTIL_Configuration.getAllConfItemIds(orderList);
        
        System.assertEquals(100, orderList.size());
        Test.stopTest();
    }
    
    static testMethod void areOrderItemsPaymentMethodsOk() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c orderList = XC_DF_Order.createOrder( 'InOrder');
        String orderID = orderList.id;
        Boolean newOrderList = XC_UTIL_Configuration.areOrderItemsPaymentMethodsOk(orderID);
        
        System.assertEquals(false, newOrderList );
        Test.stopTest();
    }
   
    static testMethod void getRatePlanByOrderId() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c orderList = XC_DF_Order.createOrder( 'InOrder');
        String orderID = orderList.id;
        List<B2WExtCat__Work_Order_Item__c> newOrderList =  XC_UTIL_Configuration.getRatePlanByOrderId(orderID) ;
        System.assertEquals(0, newOrderList.size() );
        Test.stopTest();
    }
    
    static testMethod void changeOrderStatusSent() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c orderList = XC_DF_Order.createOrder( 'InOrder');
        String orderID = orderList.id;
        XC_UTIL_Configuration.changeOrderStatusSent(orderID, false) ;
        System.assertEquals('InOrder', orderList.NE__Type__c);
        Test.stopTest();
    }
    
    static testMethod void getOrderItemFromConfiguration() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(10);
        insert orderItem;
        Set<Id> orderItemSet = new Set<Id>();
        List<ID> orderIdList = new List<ID> ();
        List<Id> listItemIds = new List<Id> ();
        for(NE__OrderItem__c ord : orderItem){
            orderIdList.add(ord.NE__OrderId__c);
            listItemIds.add(ord.Id);
            orderItemSet.add(ord.Id);
        } 
        XC_UTIL_Configuration.getOrderItemFromConfiguration( orderIdList,listItemIds) ;
        XC_UTIL_Configuration.getOrderItemAttributesByListCIId(orderItemSet);
        System.assertEquals(10, orderItem.size());
        Test.stopTest();
    }
    
     static testMethod void getOrderIdsFromOrderItems() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(10);
        insert orderItem;
        List<ID> orderIdList = new List<ID> ();
        List<Id> listItemIds = new List<Id> ();
        for(NE__OrderItem__c ord : orderItem){
            orderIdList.add(ord.NE__OrderId__c);
            listItemIds.add(ord.Id);
        } 
        XC_UTIL_Configuration.getOrderIdsFromOrderItems( orderItem) ;
        System.assertEquals(10, orderItem.size());
        Test.stopTest();
    }

    static testMethod void getgenerateWorkorders(){
      insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c orderList = XC_DF_Order.createOrder( 'InOrder');
        String orderID = orderList.id;
        Boolean newOrderList = XC_UTIL_Configuration.generateWorkorders(orderID,null,'test');      
        System.assertEquals(false, newOrderList );
        Test.stopTest();

}
   /* @IsTest
    static void checkRequiredSiteInspectionTEST(){
        
        Test.startTest();
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(100, 'InOrder');
        for(NE__Order__c order: orderList ){
            order.NE__Configuration_Type__c = Label.XC_CL_Configuration_TypeNew;
        }
        insert orderList;
        Map<Id, Boolean> checkReq = XC_UTIL_Configuration.checkRequiredSiteInspection(orderList);
        System.assert(!checkReq.get(orderList[0].Id));
        
        Test.stopTest();
        
        
    }*/
	
	//START-elisa.caldini@accenture.com-23.03.2022
	static testMethod void checkOpportunityStage() {
        Opportunity opp = new Opportunity();
        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        accountList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;
        opp.Name ='Opportunity di Test';
        opp.XC_Contact__c = contList[0].Id;
        opp.AccountId = contList[0].AccountId;
        opp.XC_Address__c = address[0].Id;
        opp.CloseDate = Date.newInstance(2030, 12, 31);
        opp.XC_Segment__c = 'B2B';
        opp.XC_LegalEntity__c = 'EnelSole';
        opp.XC_BusinessLine__c='eCity';
        opp.XC_IndustrialKPI__c ='Work Contract';
        opp.XC_ProductCategoryOfInterest__c ='Smart Lighting';
        opp.XC_ProductCategory__c='Optimize';
        opp.XC_BusinessModel__c = 'Spot Sale';
        opp.StageName ='Draft';
        opp.XC_Source__c ='Commodity';
        opp.XC_ReceivingChannel__c='KAM';
        opp.XC_CustomerRequestDate__c =Date.newInstance(2022, 12, 30);
        insert opp;
        opp.StageName='Qualified Potential Opportunity';
        update opp;
        opp.StageName='In Progress';
        update opp;
        NE__Order__c order =new NE__Order__c();
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2B';
        order.XC_LegalEntity__c='EnelSole';
        order.NE__OptyId__c = opp.Id;
        order.XC_DeliveryAddress__c = opp.XC_Address__c;
        order.NE__AccountId__c =opp.AccountId;
        insert order;
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
           NE__Root_Order_Item__c = null, 
           XC_ParentCommercialItem__c=null,
           NE__StartDate__c= null,
           NE__EndDate__c=null
        );
        insert item;
        Test.StartTest();
        XC_UTIL_ResultWrapper rw = XC_UTIL_Configuration.checkOpportunityStage(order.Id);
        Test.StopTest();
    }
    //END-elisa.caldini@accenture.com-23.03.2022

}