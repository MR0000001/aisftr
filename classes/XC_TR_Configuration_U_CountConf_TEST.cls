/**
* @author 
* @date Creation  
* @description XC_TR_Configuration_U_CountConf_TEST – Test class for XC_TR_Configuration_U_CountConf and XC_TR_Configuration_U_CountConf_D and XC_TR_Configuration_U_CountConf
*/ 
@isTest
private class XC_TR_Configuration_U_CountConf_TEST {

    @TestSetup 
    static void methodName() {

        
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.XC_Status__c = Label.XC_CL_Configuration_Rejected;
        update order;
        
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        insert contList;
        Test.startTest();
        List<XC_Address__c> address =  XC_DF_Address.createAddress(1);
        insert address;
        List<XC_Address__c> listAddress = [SELECT Id, XC_Account__c  FROM XC_Address__c WHERE Id = :address[0].Id];
        List<Opportunity> listOpportunity = XC_DF_Opportunity.createOpportunityWithoutVisit(contList, address[0]);
        listOpportunity[0].AccountId = listAddress[0].XC_Account__c;
        insert listOpportunity;
        System.debug('@@@@@Order record:' + order.RecordTypeId);
        Test.stopTest();
 
    }
 
	@isTest
    static void onOrder() {
        
        Test.startTest();
        NE__Order__c order = [SELECT Id, NE__OptyId__c   FROM NE__Order__c WHERE RecordTypeId =  :Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId() AND XC_Status__c = :Label.XC_CL_Configuration_Rejected LIMIT 1];
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        listWorkOrder[0].XC_Opportunity__c = order.NE__OptyId__c;
        listWorkOrder[0].Status = Label.XC_CL_WorkOrder_InProgress;
        insert listWorkOrder;
        
        update order;
      
        
        NE__Order__c orderProva = new NE__Order__c();
        List<Opportunity> listOpportunity= [SELECT id, AccountId FROM opportunity WHERE Stagename!= 'Closed Won' AND Stagename!= 'Closed Lost'];
        
        //CHECK IF STATUS NEW -> DRAFT
        orderProva.NE__Type__c = 'InOrder';
        orderProva.NE__OptyId__c = listOpportunity[0].Id;
        orderProva.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        orderProva.NE__AccountId__c = listOpportunity[0].AccountId;
        orderProva.XC_Status__c=Label.XC_CL_Configuration_Draft;
        insert orderProva;
        
        orderProva.XC_Status__c=Label.XC_CL_Configuration_Draft;
        update orderProva;
        //CHECK IF STATUS NEW->ACCEPTED
        //orderProva.XC_Status__c=Label.XC_CL_Configuration_QuoteAccepted;
        //update orderProva;
        Test.stopTest();
        System.assert(orderProva!=null);
        
    }
    //Metodo testato:XC_TR_Configuration_U_CountConf.setQuoteConfToRejected
    @isTest
    static void setQuoteConfToRejected() {
        Test.startTest();
		NE__Order__c order = [SELECT Id, NE__OptyId__c   FROM NE__Order__c WHERE RecordTypeId =  :Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId() AND XC_Status__c = :Label.XC_CL_Configuration_Rejected LIMIT 1];
        NE__Order__c order2 = XC_DF_Order.createOrder('InOrder');
        order2.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();    
        
        update order2;
        
        List<Opportunity> opps= [SELECT id, (SELECT id, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM NE__Orders__r ) FROM opportunity WHERE id=:order.NE__OptyId__c];
        
        XC_TR_Configuration_U_CountConf.setQuoteConfToRejected(opps[0], order2);
        Test.stopTest();
        System.assert(opps!=null);
    }
    
    //Metodo testato:XC_TR_Configuration_U_CountConf_D.getWorkOrderFromOpportunity
    @isTest
    static void onWorkOrder() {
        Test.startTest();
        NE__Order__c order = [SELECT Id, NE__OptyId__c   FROM NE__Order__c WHERE RecordTypeId =  :Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId() AND XC_Status__c = :Label.XC_CL_Configuration_Rejected LIMIT 1];
        List<Opportunity> opps= [SELECT id, (SELECT id, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM NE__Orders__r ) FROM opportunity WHERE id=:order.NE__OptyId__c];
        Set<Id> oppsId=new Set<Id>();
        for(Opportunity op: opps) {
            oppsId.add(op.id);       
        }
        
        
        List<workOrder> workO= XC_TR_Configuration_U_CountConf_D.getWorkOrderFromOpportunity(oppsId);
        Test.stopTest();
        System.assert(workO!=null);
        
    }
    @isTest
    static void onUpdateOrderOpty() {
        
         NE__Order__c orderProva = new NE__Order__c();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        Test.startTest();
        List<Opportunity> listOpportunity= [SELECT id, AccountId FROM opportunity WHERE Stagename!= 'Closed Won' AND Stagename!= 'Closed Lost'];
        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
        orderProva.NE__Type__c = 'InOrder';
        orderProva.NE__OptyId__c = listOpportunity[0].Id;
        orderProva.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        orderProva.NE__AccountId__c = acc[0].Id;
        orderProva.XC_Status__c=Label.XC_CL_Configuration_Draft;
        orderProva.XC_DeliveryAddress__c = addr[0].Id;
		orderProva.XC_InstallationAddress__c = addr[0].Id;
        insert orderProva;
        orderProva.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOrder).getRecordTypeId();
        orderProva.XC_Status__c = Label.XC_CL_Configuration_Draft;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        insert catalogItem;
        List<NE__Catalog__c> listOfCatalog = new List<NE__Catalog__c>([SELECT Id FROM NE__Catalog__c WHERE Id =: catalogItem.NE__Catalog_Id__c]);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].NE__OrderId__c = orderProva.Id;
        listOrderItem[0].NE__Catalog__c = listOfCatalog[0].Id;
        listOrderItem[0].NE__CatalogItem__c = catalogItem.Id;
        //listOrderItem[0].XC_DeliveryAddress__c = addr[0].Id;
        listOrderItem[0].NE__Account__c = acc[0].Id;
        listOrderItem[0].XC_Installation_Address__c = addr[0].Id;
        insert listOrderItem;
        
        update orderProva;
      	Test.stopTest();
        System.assert(orderProva!=null); 
        
    }

    
    
}