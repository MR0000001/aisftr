/**
* @author Salvatore Scarpato
* @date Creation 10/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_Configuration_U_FillFields_TEST - Test class for XC_TR_Configuration_U_FillFields
*/ 
@isTest
public class XC_TR_Configuration_U_FillFields_TEST {
    @TestSetup
    static void insertRecords(){
        Integer n = 1;
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        /*Ne__Product__c product = new Ne__Product__c();
        product.Name = Label.XC_CL_Configuration_InstallationRequired;
        product.XC_Product_Subtype__c = 'Bundle';
        product.XC_Product_Type__c = 'Bundle';
        insert product; */
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(n, 'InOrder');
        insert orderList;
        
        /*List<NE__OrderItem__c> ordItems = XC_DF_OrderItem.createOrderItems(n);
        for(NE__OrderItem__c orderItem: ordItems){
            orderItem.NE__ProdId__c = product.Id;
        }
        insert ordItems;*/
    }
    
    @isTest
    static void onInsert(){
        XC_CTI_Interaction__c ctiInt = new XC_CTI_Interaction__c(XC_Communication_Type__c = 'Outbound Call');
        insert ctiInt;
    
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;

        List<XC_Address__c>  listOfAddress = XC_DF_Address.createAddress(accs);
        listOfAddress[0].XC_BillingAddress__c = true;
        listOfAddress[0].XC_DeliveryAddress__c = true;
        listOfAddress[0].XC_InstallationAddress__c = true;
        insert listOfAddress;

        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);
        opps[0].AccountId = accs[0].id;
        opps[0].XC_CTI_Interaction__c = ctiInt.Id;
        insert opps;

        Test.startTest();
        NE__Order__c o = XC_DF_Order.createOrderWithAddress('InOrder', listOfAddress[0].Id, accs[0].Id, opps[0].Id);         
        Test.stopTest();

        //System.assertEquals('Outbound Call',o.XC_CallType__c, 'Wrong assert result');

    }


    @isTest
    static void onUpdate() {
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        
        for(NE__Order__c order : orderList){
            order.NE__OrderStatus__c = 'Active';
            order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft;
        }
        update orderList;
            
        for(NE__Order__c order : orderList){
            order.XC_Status__c = 'In Progress';
       		order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
            order.XC_In_Provisioning__c = true; 
        }
        update orderList;
    }
    
     @isTest
     static void onUpdate2() {
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c];
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        Test.startTest();
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);
        opps[0].XC_CostCenter__c = 'OR-1111111';
        insert opps;
        for(NE__Order__c order : orderList){
            order.NE__AccountId__c = accs[0].Id;
            order.NE__BillAccId__c = accs[0].Id;
            order.NE__OrderStatus__c = 'Active';
            order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft;
            order.NE__OptyId__c = opps[0].Id;
        }
        update orderList;
            
        for(NE__Order__c order : orderList){
            order.XC_Status__c = 'In Progress';
       		order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
            order.XC_In_Provisioning__c = true; 
        }
        update orderList;
        Test.stopTest();
        delete orderList;
    }

    @isTest
    static void openCart(){
        NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = 'Test', Name = 'Test');
        insert catalog;
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        List<XC_Address__c>  listOfAddress = XC_DF_Address.createAddress(accs);
        insert listOfAddress;
        Test.startTest();
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);
        opps[0].AccountId = accs[0].id;
        insert opps;
        NE__Order__c order = new NE__Order__c();
        order.NE__AccountId__c = accs[0].Id;
        order.NE__OptyId__c = opps[0].Id;
        order.XC_DeliveryAddress__c = listOfAddress[0].Id;
        order.XC_InstallationAddress__c = listOfAddress[0].Id;
        insert order;
        order.NE__OrderStatus__c = 'Active';
        order.XC_Status__c = Label.XC_CL_Configuration_QuoteDraft;



        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote;
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Spain';
        update order;
        Test.stopTest();
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);


        item.NE__Account__c = accs[0].Id;

        item.XC_Installation_Address__c = listOfAddress[0].Id;
        item.NE__Catalog__c = catalog.Id;
        insert item;
        Id orderRT = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.RecordTypeId = orderRT;
        order.XC_Status__c = 'In Progress';
        order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
        order.XC_In_Provisioning__c = true;
        update order;
    }



    @isTest 
    static void checkProvisioningAcceptance(){
        List<NE__Order__c> orderList = [SELECT Id FROM NE__Order__c LIMIT 1];
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(orderList[0]);
        insert item;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = item.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        provisioningStep.XC_Step_Order__c = 1;
        provisioningStep.XC_StepLabel__c = Label.XC_CL_ProvStep_CheckCustomerAcceptance;
        insert provisioningStep;

        Test.startTest();
        orderList[0].XC_EnhancedAcceptanaceResponse__c = Label.XC_CL_CTIAcceptedResponse;
        update orderList;
        Test.stopTest();
        //System.assertEquals(Label.XC_CL_Completed_Ok, provisioningStep.XC_Status__c, 'Wrong assert result');

    }


    
}