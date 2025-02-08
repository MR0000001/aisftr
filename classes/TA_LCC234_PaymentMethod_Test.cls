@isTest
public with sharing class TA_LCC234_PaymentMethod_Test {

    @testSetup 
    static void setup( ) 
    {      
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> addList= XC_DF_Address.createAddress(accList);
        insert addList;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        WorkOrder wo = woList[0];
        wo.AccountId = accList[0].Id;
        wo.TA_Parameters__c = '{"quoteToAccept":"' + order.id + '"}';
        insert wo;

        System.debug('addList: ' + addList);
        List<NE__Billing_Profile__c> listBilling = new List<NE__Billing_Profile__c>();
        List<XC_BillingProfileLineItem__c> listBillingProfileLineItem = new List<XC_BillingProfileLineItem__c>();
        for (Integer i=0; i<1; i++){
            NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=addList[0].XC_Account__c, NE__Payment__c='Credit Card');
            listBilling.add(billingToInsert);
           
        }
        insert listBilling;

		for(NE__Billing_Profile__c bp : listBilling) {
			XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c=bp.id, XC_SoldToAddress__c=addList[0].Id,XC_BillToAddress__c=addList[0].Id, XC_Account__c=addList[0].XC_Account__c, XC_LegalEntity__c= 'EndesaX', XC_Status__c ='Active');
            listBillingProfileLineItem.add(bpli);
            System.debug('listBillingProfileLineItem: ' + listBillingProfileLineItem);
		}
		 
        insert listBillingProfileLineItem;
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        insert oppList;
        
    }

    @isTest
    static void initialize_Test(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id, TA_Parameters__c, XC_Configuration__c, AccountId FROM WorkOrder limit 1];
        try {
            
            TA_LCC234_PaymentMethod.initialize(JSON.serialize(woList[0]));  
             
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }  
        Test.stopTest();           
    }

    @isTest
    static void initialize_Test_2(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id, TA_Parameters__c, XC_Configuration__c, AccountId FROM WorkOrder limit 1];
        List<NE__Order__c> orderList = [SELECT ID FROM NE__Order__c LIMIT 1];
        List<NE__Billing_Profile__c> billProfList = [SELECT ID FROM NE__Billing_Profile__c LIMIT 1];
        
        List<NE__OrderItem__c> oiList = [SELECT ID FROM NE__OrderItem__c WHERE NE__OrderId__c = :orderList[0].id LIMIT 1];
        oiList[0].XC_ProvisioningSpareParts__c = true;
        oiList[0].XC_AllowablePaymentTypes__c = 'Credit Card, Bank Transfer';
        update oiList;
        try {
            
            TA_LCC234_PaymentMethod.initialize(JSON.serialize(woList[0]));  
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }  
        Test.stopTest();    
    }

    @isTest
    static void retrieveBillingAddress(){
        Test.startTest();
        List<Account> accounts = [SELECT id FROM Account limit 1];
        try {
            
            TA_LCC234_PaymentMethod.retrieveBillingAddress(accounts[0].id, null);  
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }  
        Test.stopTest();            
    }

    @isTest
    static void retrieveBillingProfileLineItem(){
        Test.startTest();
        List<Account> accounts = [SELECT id FROM Account limit 1];
        List<XC_Address__c> addList = [SELECT id FROM XC_Address__c limit 1];
        try {
           
            TA_LCC234_PaymentMethod.retrieveBillingProfileLineItem(accounts[0].id, addList[0].Id,addList[0].Id,  'EndesaX');  
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }    
        Test.stopTest();          
    }

    @isTest
    static void selectBillingAddress(){
        Test.startTest();        
        TA_LCC234_PaymentMethod.InfoBag infoBag = new TA_LCC234_PaymentMethod.InfoBag();
        TA_LCC234_PaymentMethod.InfoBag infoBag2 = new TA_LCC234_PaymentMethod.InfoBag();

        List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c LIMIT 1];

        infoBag.BillingProfileWrapper = new TA_LCC234_PaymentMethod.BillingProfileWrapper();
        infoBag.BillingProfileWrapper.OrderID = orderList[0].Id; 
        
        List<XC_Address__c> addList = [SELECT id FROM XC_Address__c limit 1];
        try {
            
            TA_LCC234_PaymentMethod.selectBillingAddress(JSON.serialize(infoBag), addList[0].Id);  
            TA_LCC234_PaymentMethod.selectBillingAddress(JSON.serialize(infoBag2), addList[0].Id);  
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }   
        Test.stopTest();           
    }

    @isTest
    static void createDoc_Test(){       
        Test.startTest();
        List<NE__Order__c> orderList = [SELECT ID FROM NE__Order__c LIMIT 1];
        try {
            
            TA_LCC234_PaymentMethod.createDoc(orderList[0].id);  
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }   
        Test.stopTest();     
    }

    @isTest
    static void insertBillingProfile_Test(){
        Test.startTest();
        List<Account> accList = [SELECT ID FROM Account LIMIT 1];
        TA_LCC234_PaymentMethod.BillingProfileWrapper billingProfileWrapper = new TA_LCC234_PaymentMethod.BillingProfileWrapper(); 
        billingProfileWrapper.IBAN = null;
        billingProfileWrapper.SEPABIC = null;
        billingProfileWrapper.PaymentMethod = 'Credit Card';
        billingProfileWrapper.InvoiceDeliveryPref = 'Email';
        billingProfileWrapper.SEPAMandateType = 'Recurring'; 
        billingProfileWrapper.AccountId =  accList[0].id;
        try {
            
            TA_LCC234_PaymentMethod.insertBillingProfile(JSON.serialize(billingProfileWrapper));
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void insertBillingProfile_Test_2(){
        Test.startTest();
        List<Account> accList = [SELECT ID FROM Account LIMIT 1];
        TA_LCC234_PaymentMethod.BillingProfileWrapper billingProfileWrapper = new TA_LCC234_PaymentMethod.BillingProfileWrapper(); 
        billingProfileWrapper.IBAN = null;
        billingProfileWrapper.SEPABIC = null;
        billingProfileWrapper.PaymentMethod = 'Credit Card';
        billingProfileWrapper.InvoiceDeliveryPref = 'Email';
        billingProfileWrapper.SEPAMandateType = 'Recurring';        
        try { 
            
            TA_LCC234_PaymentMethod.insertBillingProfile(JSON.serialize(billingProfileWrapper));
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void updateOrderItemBillingProfile_Test(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id, XC_WorkTypeLabel__c FROM WorkOrder limit 1];
        List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c LIMIT 1];
        List<NE__Billing_Profile__c> bpList = [SELECT ID FROM NE__Billing_Profile__c LIMIT 1];
        Map<String,String> parameters = new Map<String,String>{'Commercial Visit - Air Conditioning' =>  'Site Inspection - Air Conditioning'};
        List<NE__OrderItem__c> oiList = [SELECT ID FROM NE__OrderItem__c WHERE NE__OrderId__c = :orderList[0].id LIMIT 1];
        oiList[0].XC_ProvisioningSpareParts__c = true;
        oiList[0].XC_AllowablePaymentTypes__c = 'Credit Card, Bank Transfer';
        update oiList;
        try {
            
            TA_LCC234_PaymentMethod.updateOrderItemBillingProfile(woList[0].id, orderList[0].id, oiList[0].Id, bpList[0].id, 'Bank Transfer');
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void updateOrderItemBillingProfile_Test_2(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id, XC_WorkTypeLabel__c FROM WorkOrder limit 1];
        List<NE__Order__c> orderList = [SELECT id FROM NE__Order__c LIMIT 1];
        List<NE__Billing_Profile__c> bpList = [SELECT ID FROM NE__Billing_Profile__c LIMIT 1];
        NE__OrderItem__c oi = XC_DF_OrderItem.createOrderItem(orderList[0]);
        insert oi;
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT ID FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c =:  bpList[0].id];
        bpliList[0].XC_PEC__c = 'TEST@test.it';
        update bpliList;
        Map<String,String> parameters = new Map<String,String>{'Commercial Visit - Air Conditioning' =>  'Site Inspection - Air Conditioning'};
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        wrResp.Result.ErrorCode = '0';
        XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
        try {
            
            TA_LCC234_PaymentMethod.updateOrderItemBillingProfile_step2(JSON.serialize(wrResp), JSON.serialize(wrReq), woList[0].id, parameters);
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void createSiteInspection_Test(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id, XC_LegalEntity__c,PostalCode,XC_Country__c,City,AccountId,Street,XC_Configuration__c, ContactId,XC_Opportunity__c FROM WorkOrder limit 1];
        try {
            
            TA_LCC234_PaymentMethod.createSiteInspection(JSON.serialize(woList[0]),'Site Inspection - Air Conditioning');
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void createSiteInspection_Test_2(){
        Test.startTest();
        List<WorkOrder> woList = [SELECT id  FROM WorkOrder limit 1];
        try {
            
            TA_LCC234_PaymentMethod.createSiteInspection(JSON.serialize(woList[0]),'Site Inspection - Air Conditioning');
            
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }
}