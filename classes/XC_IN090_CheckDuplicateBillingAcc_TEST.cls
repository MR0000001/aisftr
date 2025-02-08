/**
 * @author              Gaurav Tejpal gaurav.tejpal@accenture.com
 * @date Creation       20/06/2022
 * @date Modification   
 * @description         test class for XC_IN090_CheckDuplicateBillingAccount
*/
@isTest
public without sharing class XC_IN090_CheckDuplicateBillingAcc_TEST {
   @testSetup 
   static void setup() {
      // Init Custom Setting
       Zuora_OAuth__c zoa = new  Zuora_OAuth__c();
      zoa.EntityName__c = 'Enel Spain B2C';
      zoa.Client_Id__c = '123456'; 
      zoa.Client_Secret__c = '78910'; 
      zoa.EntityId__c = '1234567890764332';
      zoa.Host__c = 'rest.sandbox.eu.zuora.com';
      zoa.apiToken__c = '171173687168716368713718736183';
      insert zoa;
   }
        @isTest
        static void checkDuplicateBillingAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Account acc = new Account();
        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        acc.XC_FirstName__c = 'TestAccountN' + (Math.random()*Math.random());
        acc.XC_LastName__c = 'TestAccountN' + (Math.random()*Math.random());
        acc.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
        acc.XC_DocumentCountry__c = 'Spain';
        acc.IdentityType__c='Passport';
        acc.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        acc.name = 'Test Account n ' + (Math.random()*Math.random());
        insert acc;

        XC_Address__c add= New XC_Address__c();
        add.XC_Account__c = acc.id;
        insert add;
     
        NE__Billing_Profile__c billingToInsert = New NE__Billing_Profile__c();
        billingToInsert.NE__Account__c = acc.id;
        billingToInsert.NE__Payment__c = 'Commodity Bill';
        billingToInsert.XC_Segment__c='B2C';
        insert billingToInsert;

        NE__Billing_Profile__c billingToInsert1 = New NE__Billing_Profile__c();
        billingToInsert1.NE__Account__c = acc.id;
        billingToInsert1.NE__Payment__c = 'Credit Card';
        billingToInsert1.XC_Segment__c='B2C';
        insert billingToInsert1;

        XC_BillingProfileLineItem__c bpli = New XC_BillingProfileLineItem__c();
        bpli.XC_BillingProfile__c=billingToInsert.id;
        bpli.XC_LegalEntity__c = 'EnelXMSP';
        bpli.XC_DocumentType__c = 'NIF';
        bpli.XC_DocumentNumber__c = '53672895A';
        bpli.XC_SoldToAddress__c=add.id;
        bpli.XC_BillToAddress__c=add.id;
        bpli.XC_DocumentCountry__c = 'Spain';
        bpli.XC_Account__c=acc.id; 
        insert bpli; 

  
        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
        insert prod;

        
        
       // List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        //insert(oi);

        NE__Catalog_Item__c catItemOC = XC_DF_CatalogItem.createCatalogItem();
        catItemOC.NE__Engine_Code__c = 'OpenCharge';
        catItemOC.NE__UsageCode__c = 'OpenCharge';
        catItemOC.NE__ProductId__c = prod.id;
        insert catItemOC;
        

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXMSP';
        insert order;

        NE__OrderItem__c item = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',   
           NE__ProdId__c =  prod.id,
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = order.Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = catItemOC.Id,                
           XC_BillingModel__c = 'Installment plan',
           XC_BillingProfileLineItem__c=bpli.id,
           XC_PaymentMethod__c='Commodity Bill',
           NE__BillingProfId__c=billingToInsert.id
        );

        insert item;

        
        Asset ass = new Asset();
        ass.XC_BillingProfileLineItem__c = bpli.Id;
        ass.NE__ProdId__c = prod.id;
        ass.Name='Test';
        ass.XC_ContractStartDate__c = Date.newInstance(2019,04,01); 
        ass.XC_ContractEndDate__c = Date.newInstance(3000,04,01); 
        ass.XC_BillingModel__c = 'Recurring';
        ass.XC_LegalEntity__c = 'EnelXMSP';
        ass.XC_Segment__c  = 'B2C';
        ass.XC_Configuration_Item__c=item.id;
        insert ass; 

        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(item.id);
        insert(ps);

           List<XC_IN090_CheckDuplicateBillingAccount.InputWrapper> inputs=new List<XC_IN090_CheckDuplicateBillingAccount.InputWrapper>();
            XC_IN090_CheckDuplicateBillingAccount.InputWrapper input = new XC_IN090_CheckDuplicateBillingAccount.InputWrapper();
            input.orderId = item.id;
            input.bplId = bpli.id;   
            input.stepId = ps.id;  
            inputs.add(input);      
            test.startTest();
            XC_IN090_CheckDuplicateBillingAccount.manageCheckDuplicateRequest(inputs);
            test.stopTest();
    
        }


        @isTest
        static void RollbackError(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Account acc = new Account();
        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        acc.XC_FirstName__c = 'TestAccountN' + (Math.random()*Math.random());
        acc.XC_LastName__c = 'TestAccountN' + (Math.random()*Math.random());
        acc.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
        acc.XC_DocumentCountry__c = 'Spain';
        acc.IdentityType__c='Passport';
        acc.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        acc.XC_CommercialCode__c='AAA123';
        acc.XC_InternalCommercialCode__c='BBB123';
        acc.name = 'Test Account n ' + (Math.random()*Math.random());
        insert acc;

        XC_Address__c add= New XC_Address__c();
        add.XC_Account__c = acc.id;
        insert add;
     
        NE__Billing_Profile__c billingToInsert = New NE__Billing_Profile__c();
        billingToInsert.NE__Account__c = acc.id;
        billingToInsert.NE__Payment__c = 'Commodity Bill';
        billingToInsert.XC_Segment__c='B2C';
        insert billingToInsert;

        NE__Billing_Profile__c billingToInsert1 = New NE__Billing_Profile__c();
        billingToInsert1.NE__Account__c = acc.id;
        billingToInsert1.NE__Payment__c = 'Credit Card';
        billingToInsert1.XC_Segment__c='B2C';
        insert billingToInsert1;

        XC_BillingProfileLineItem__c bpli = New XC_BillingProfileLineItem__c();
        bpli.XC_BillingProfile__c=billingToInsert.id;
        bpli.XC_LegalEntity__c = 'EnelXMSP';
        bpli.XC_DocumentType__c = 'NIF';
        bpli.XC_DocumentNumber__c = '53672895A';
        bpli.XC_SoldToAddress__c=add.id;
        bpli.XC_BillToAddress__c=add.id;
        bpli.XC_DocumentCountry__c = 'Spain';
        bpli.XC_Account__c=acc.id; 
        insert bpli; 

        XC_BillingProfileLineItem__c bpli2=bpli.clone(false,false,false);
        bpli2.XC_BillingProfile__c=billingToInsert1.id;
        bpli2.XC_LegalEntity__c='EXBRA_SA_Goncalo_RJ';
       
        insert bpli2;
        List<XC_BillingProfileLineItem__c> billingProfieLineItemRecords=[select XC_BillingProfile__c,id, XC_Account__c,XC_LegalEntity__c, XC_PaymentMethod__c,XC_PaymentTerm__c from XC_BillingProfileLineItem__c];

        system.debug('billingProfieLineItemRecords '+ billingProfieLineItemRecords);

        NE__Product__c prod = new NE__Product__c();
        prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
        insert prod;

        
        
       // List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        //insert(oi);

        NE__Catalog_Item__c catItemOC = XC_DF_CatalogItem.createCatalogItem();
        catItemOC.NE__Engine_Code__c = 'OpenCharge';
        catItemOC.NE__UsageCode__c = 'OpenCharge';
        catItemOC.NE__ProductId__c = prod.id;
        insert catItemOC;
        

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXMSP';
        insert order;

        NE__OrderItem__c item = new NE__OrderItem__c(
           XC_Product_Type__c = 'Bundle',              
           XC_Product_Subtype__c = 'Bundle',           
           NE__Status__c = 'Pending',   
           NE__ProdId__c =  prod.id,
           NE__Qty__c = 1,                           
           NE__BaseRecurringCharge__c = 0,             
           NE__OrderId__c = order.Id,                  
           NE__RecurringChargeOv__c = 0,               
           NE__CatalogItem__c = catItemOC.Id,                
           XC_BillingModel__c = 'Installment plan',
           XC_BillingProfileLineItem__c=bpli.id,
           XC_PaymentMethod__c='Commodity Bill',
           NE__BillingProfId__c=billingToInsert.id
        );

        insert item;

        
        Asset ass = new Asset();
        ass.XC_BillingProfileLineItem__c = bpli.Id;
        ass.NE__ProdId__c = prod.id;
        ass.Name='Test';
        ass.XC_ContractStartDate__c = Date.newInstance(2019,04,01); 
        ass.XC_ContractEndDate__c = Date.newInstance(3000,04,01); 
        ass.XC_BillingModel__c = 'Recurring';
        ass.XC_LegalEntity__c = 'EnelXMSP';
        ass.XC_Segment__c  = 'B2C';
        ass.XC_Configuration_Item__c=item.id;
        insert ass; 

        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(item.id);
        insert(ps);
            test.startTest();
            XC_IN090_CheckDuplicateBillingAccount.rollbackForError(bpli.id, 'Test', true);
            test.stopTest();
    
        }


        @isTest
        static void BillingProfileExists(){
         insert XC_DF_OneOrg.createOneOrg('Spain');
         Account acc = new Account();
         acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
         acc.XC_FirstName__c = 'TestAccountN' + (Math.random()*Math.random());
         acc.XC_LastName__c = 'TestAccountN' + (Math.random()*Math.random());
         acc.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
         acc.XC_DocumentCountry__c = 'Spain';
         acc.IdentityType__c='Passport';
         acc.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
         acc.XC_CommercialCode__c='AAA123';
         acc.XC_InternalCommercialCode__c='BBB123';
         acc.name = 'Test Account n ' + (Math.random()*Math.random());
         insert acc;
 
         XC_Address__c add= New XC_Address__c();
         add.XC_Account__c = acc.id;
         insert add;
      
         NE__Billing_Profile__c billingToInsert = New NE__Billing_Profile__c();
         billingToInsert.NE__Account__c = acc.id;
         billingToInsert.NE__Payment__c = 'Commodity Bill';
         billingToInsert.XC_Segment__c='B2C';
         insert billingToInsert;
 
         NE__Billing_Profile__c billingToInsert1 = New NE__Billing_Profile__c();
         billingToInsert1.NE__Account__c = acc.id;
         billingToInsert1.NE__Payment__c = 'Credit Card';
         billingToInsert1.XC_Segment__c='B2C';
         insert billingToInsert1;
 
         XC_BillingProfileLineItem__c bpli = New XC_BillingProfileLineItem__c();
         bpli.XC_BillingProfile__c=billingToInsert.id;
         bpli.XC_LegalEntity__c = 'EXBRA_SA_Goncalo_RJ';
         bpli.XC_DocumentType__c = 'NIF';
         bpli.XC_DocumentNumber__c = '53672895A';
         bpli.XC_SoldToAddress__c=add.id;
         bpli.XC_BillToAddress__c=add.id;
         bpli.XC_DocumentCountry__c = 'Spain';
         bpli.XC_Account__c=acc.id; 
         insert bpli; 
        XC_BillingProfileLineItem__c bpli2=bpli.clone(false,true,false);
        bpli2.XC_BillingProfile__c=billingToInsert1.id;
        bpli2.XC_LegalEntity__c='EXBRA_SA_Goncalo_RJ';
        insert bpli2;
   
         NE__Product__c prod = new NE__Product__c();
         prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
         insert prod;
 
         
         
        // List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
         //insert(oi);
 
         NE__Catalog_Item__c catItemOC = XC_DF_CatalogItem.createCatalogItem();
         catItemOC.NE__Engine_Code__c = 'OpenCharge';
         catItemOC.NE__UsageCode__c = 'OpenCharge';
         catItemOC.NE__ProductId__c = prod.id;
         insert catItemOC;
         
 
         NE__Order__c order = new NE__Order__c();
         order.NE__Type__c = 'Order';
         order.XC_Country__c = 'Spain';
         order.XC_Segment__c = 'B2C';
         order.XC_LegalEntity__c = 'EnelXMSP';
         insert order;
 
         NE__OrderItem__c item = new NE__OrderItem__c(
            XC_Product_Type__c = 'Bundle',              
            XC_Product_Subtype__c = 'Bundle',           
            NE__Status__c = 'Pending',   
            NE__ProdId__c =  prod.id,
            NE__Qty__c = 1,                           
            NE__BaseRecurringCharge__c = 0,             
            NE__OrderId__c = order.Id,                  
            NE__RecurringChargeOv__c = 0,               
            NE__CatalogItem__c = catItemOC.Id,                
            XC_BillingModel__c = 'Installment plan',
            XC_BillingProfileLineItem__c=bpli.id,
            XC_PaymentMethod__c='Commodity Bill',
            NE__BillingProfId__c=billingToInsert.id
         );
 
         insert item;
 
         
         Asset ass = new Asset();
         ass.XC_BillingProfileLineItem__c = bpli.Id;
         ass.NE__ProdId__c = prod.id;
         ass.Name='Test';
         ass.XC_ContractStartDate__c = Date.newInstance(2019,04,01); 
         ass.XC_ContractEndDate__c = Date.newInstance(3000,04,01); 
         ass.XC_BillingModel__c = 'Recurring';
         ass.XC_LegalEntity__c = 'EnelXMSP';
         ass.XC_Segment__c  = 'B2C';
         ass.XC_Configuration_Item__c=item.id;
         insert ass; 
 
         
         XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(item.id);
         insert(ps);
 
            List<XC_IN090_CheckDuplicateBillingAccount.InputWrapper> inputs=new List<XC_IN090_CheckDuplicateBillingAccount.InputWrapper>();
             XC_IN090_CheckDuplicateBillingAccount.InputWrapper input = new XC_IN090_CheckDuplicateBillingAccount.InputWrapper();
             input.orderId = item.id;
             input.bplId = bpli.id;   
             input.stepId = ps.id;  
             inputs.add(input);      
             test.startTest();
             XC_IN090_CheckDuplicateBillingAccount.manageCheckDuplicateRequest(inputs);
             test.stopTest();
    
        }

        @isTest
        public static void zuoraBillingAccountCreationTest()
        {
         Test.setMock(HttpCalloutMock.class, new DummyResponse());
         insert XC_DF_OneOrg.createOneOrg('Spain');
         Account acc = new Account();
         acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
         acc.XC_FirstName__c = 'TestAccountN' + (Math.random()*Math.random());
         acc.XC_LastName__c = 'TestAccountN' + (Math.random()*Math.random());
         acc.PrimaryEmail__c = 'test_res' + (Math.random()*Math.random()) + '@email.com';
         acc.XC_DocumentCountry__c = 'Spain';
         acc.IdentityType__c='Passport';
         acc.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
         acc.XC_CommercialCode__c='AAA123';
         acc.XC_InternalCommercialCode__c='BBB123';
         acc.name = 'Test Account n ' + (Math.random()*Math.random());
         insert acc;
 
         XC_Address__c add= New XC_Address__c();
         add.XC_Account__c = acc.id;
         insert add;
      
         NE__Billing_Profile__c billingToInsert = New NE__Billing_Profile__c();
         billingToInsert.NE__Account__c = acc.id;
         billingToInsert.NE__Payment__c = 'Commodity Bill';
         billingToInsert.XC_Segment__c='B2C';
         insert billingToInsert;
 
         NE__Billing_Profile__c billingToInsert1 = New NE__Billing_Profile__c();
         billingToInsert1.NE__Account__c = acc.id;
         billingToInsert1.NE__Payment__c = 'Credit Card';
         billingToInsert1.XC_Segment__c='B2C';
         insert billingToInsert1;
 
         XC_BillingProfileLineItem__c bpli = New XC_BillingProfileLineItem__c();
         bpli.XC_BillingProfile__c=billingToInsert.id;
         bpli.XC_LegalEntity__c = 'EXBRA_SA_Goncalo_RJ';
         bpli.XC_DocumentType__c = 'NIF';
         bpli.XC_DocumentNumber__c = '53672895A';
         bpli.XC_SoldToAddress__c=add.id;
         bpli.XC_BillToAddress__c=add.id;
         bpli.XC_DocumentCountry__c = 'Spain';
         bpli.XC_Account__c=acc.id; 
         insert bpli; 
   
         NE__Product__c prod = new NE__Product__c();
         prod.XC_LIC_Product_Name__c = 'OK Gas Basic';
         insert prod;
 
         
         
        // List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
         //insert(oi);
 
         NE__Catalog_Item__c catItemOC = XC_DF_CatalogItem.createCatalogItem();
         catItemOC.NE__Engine_Code__c = 'OpenCharge';
         catItemOC.NE__UsageCode__c = 'OpenCharge';
         catItemOC.NE__ProductId__c = prod.id;
         insert catItemOC;
         
 
         NE__Order__c order = new NE__Order__c();
         order.NE__Type__c = 'Order';
         order.XC_Country__c = 'Spain';
         order.XC_Segment__c = 'B2C';
         order.XC_LegalEntity__c = 'EnelXMSP';
         insert order;
 
         NE__OrderItem__c item = new NE__OrderItem__c(
            XC_Product_Type__c = 'Bundle',              
            XC_Product_Subtype__c = 'Bundle',           
            NE__Status__c = 'Pending',   
            NE__ProdId__c =  prod.id,
            NE__Qty__c = 1,                           
            NE__BaseRecurringCharge__c = 0,             
            NE__OrderId__c = order.Id,                  
            NE__RecurringChargeOv__c = 0,               
            NE__CatalogItem__c = catItemOC.Id,                
            XC_BillingModel__c = 'Installment plan',
            XC_BillingProfileLineItem__c=bpli.id,
            XC_PaymentMethod__c='Commodity Bill',
            NE__BillingProfId__c=billingToInsert.id
         );
 
         insert item;
 
         
         Asset ass = new Asset();
         ass.XC_BillingProfileLineItem__c = bpli.Id;
         ass.NE__ProdId__c = prod.id;
         ass.Name='Test';
         ass.XC_ContractStartDate__c = Date.newInstance(2019,04,01); 
         ass.XC_ContractEndDate__c = Date.newInstance(3000,04,01); 
         ass.XC_BillingModel__c = 'Recurring';
         ass.XC_LegalEntity__c = 'EnelXMSP';
         ass.XC_Segment__c  = 'B2C';
         ass.XC_Configuration_Item__c=item.id;
         insert ass; 
      
              String zuoraPayment = '{"zuoraPayment": "12313131", "docNif" : "Passport", "docNumber": "PS098226", "personTypeCode": "F", "legalE": "EndesaX", "sequenceSetId": "9988", "countryCode":"ES", "contractId": "9874647"}';
              ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper billTo = new ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper();
              ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper soldTo = new ZuoraBillingProfileCreationController.XC_ContactAddress_Wrapper();
              String options = '{"mmm": "12"}';
              String billingProfLineItemId = bpli.id;

              
              XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(item.id);
              insert(ps);
         zuoraBillingAccountCreation(JSON.serialize(acc),JSON.serialize(billTo),JSON.serialize(soldTo),JSON.serialize(options),bpli.id,JSON.serialize(zuoraPayment),ps.id);
        }


       
        public static void zuoraBillingAccountCreation(string acc,string billTo,string soldTo,string options,string billingProfLineItemId,string zuoraPayment,string stepId){
              XC_IN090_CheckDuplicateBillingAccount.zuoraBillingAccountCreation('Spain',acc,billTo,soldTo,options, billingProfLineItemId,zuoraPayment,stepId);
          }

          public without sharing class DummyResponse implements HttpCalloutMock {
            public HttpResponse respond (HTTPRequest req){
                HttpResponse response = new HttpResponse();
    
                if(req.getEndpoint().endsWith('/v1/accounts')) {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"accountId":"a0001", "accountNumber":"A01807438", "paymentMethodId":null, "processId":null, "reasons":null, "success":true}');
                    response.setStatusCode(200); 
    
                } 
                
                return response;
            }
        }
}