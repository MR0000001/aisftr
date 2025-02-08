/**
  @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @date 26/03/2021
  @description XC_AMP_LCC020_SimplifiedSales_TEST - Test Class for XC_AMP_LCC020_SimplifiedSales
*/

@isTest
private class XC_AMP_LCC020_SimplifiedSales_TEST {

    @testSetup
    public static void testSetup(){
        Account testAccount = new Account(Name='Account_Name_Test',XC_Country__c='Italy',PrimaryEmail__c='accbp@gmail.com');
        insert testAccount;
        Account accBillTo = new Account(Name='BillTo',PrimaryEmail__c='accBillTobp@gmail.com');
        insert accBillTo;
        Account accSoldTo = new Account(Name='SoldTo',PrimaryEmail__c='accSoldTobp@gmail.com');
        insert accSoldTo;
        Contact contbilTo = new Contact(FirstName = 'contbilToName' , LastName = 'contbilToName', AccountId = accBillTo.Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contbilTo@test.it');
        insert contbilTo;
        Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accSoldTo.Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Italy', XC_MainLegalEntity__c = 'EnelXItalia', Email = 'contsoldTo@test.it');
        insert contsoldTo;
        XC_PersonalDocument__c docs = new XC_PersonalDocument__c(XC_Account__c = testAccount.Id);
        insert docs;
        
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        bpList[0].Name = 'Zuora_Account_Name_Test';
        update bpList;
          
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = testAccount.Id;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Roma';
        addressToInsert.XC_AddressCountry__c = 'Italy';
        addressToInsert.XC_PostalCode__c = '28080';
        addressToInsert.XC_AddressProvince__c = 'Roma';
        addressToInsert.XC_StreetNumber__c = '11' + Math.random();
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
        addressToInsert.XC_InstallationAddress__c = TRUE;
        addressToInsert.XC_DeliveryAddress__c = TRUE;
        addressToInsert.XC_BillingAddress__c = TRUE;
        addressToInsert.XC_PickUpPoint__c = TRUE;
        addressToInsert.XC_PointOfSales__c = TRUE;
        addressToInsert.XC_WareHouse__c = TRUE;
        //addressToInsert.XC_ElectricCUPS__c = 'Contract';
        addressToInsert.XC_GasCUPS__c = 'Contract';
        insert addressToInsert;
        
        NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=testAccount.Id, XC_LegalEntity__c = 'EnelXItalia');
        insert billingToInsert;
        
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_LegalEntity__c = 'EnelXItalia',XC_BillingProfile__c=billingToInsert.id,XC_SoldToAddress__c=addressToInsert.ID,XC_BillToAddress__c=addressToInsert.ID, XC_Account__c=testAccount.Id);
        bpli.XC_ExternalKey__c = '1235';
        //insert bpli;
        
        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(
                XC_BillingProfile__c = billingToInsert.Id, XC_BillingProfileCopy__c = billingToInsert.Id,
                XC_BillToAddress__c = addressToInsert.ID, XC_SoldToAddress__c = addressToInsert.ID,
                XC_BillToContactId__c = contbilTo.Id, XC_SoldToContactId__c = contsoldTo.Id,
                XC_LegalEntity__c = 'EnelXItalia'
        );
        //insert billingProfileLineItem;
        XC_UTIL_ResultWrapper wrNew = new XC_UTIL_ResultWrapper(XC_UTIL_Sobject.insertRecord(billingProfileLineItem));
        
     	Zuora_OAuth__c zoa = new  Zuora_OAuth__c();
        zoa.EntityName__c = 'Spain B2C';
        zoa.Client_Id__c = '123456'; 
        zoa.Client_Secret__c = '78910'; 
        zoa.EntityId__c = '1234567890764332';
        zoa.Host__c = 'rest.sandbox.eu.zuora.com';
        zoa.apiToken__c = '171173687168716368713718736183';
        insert zoa;
        zqu__BillingEntity__c billEntity = new zqu__BillingEntity__c(zqu__EntityName__c= 'Spain',zqu__EntityID__c='222222');
        insert billEntity;
        
        zqu__HostedPageLiteSetting__c zquTest = new zqu__HostedPageLiteSetting__c(zqu__BillingEntity__c=billEntity.Id, Name = 'z_SEPA_Zuora',zqu__ComponentName__c='111111', zqu__PageId__c='111111', zqu__PaymentMethodType__c='111111');
        insert zquTest;

        //test on SOHO Account
        List<Account> sohoAccounts = XC_DF_Account.createSohoAccounts(1);
        sohoAccounts[0].PrimaryEmail__c = 'test_soho_acc@gmail.com';
        insert sohoAccounts;
        
        Opportunity opportunityToInsert = new Opportunity();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_ITA').getRecordTypeId();
        opportunityToInsert.recordTypeId = recordTypeId;
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.AccountId = testAccount.Id;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Boiler';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_LegalEntity__c = 'EnelXItalia';
        opportunityToInsert.XC_Address__c = addressToInsert.ID;
        insert opportunityToInsert;
        
        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = addressToInsert.ID;
        //order.XC_InstallationAddress__c = addressToInsert.ID;
        order.NE__AccountId__c = testAccount.Id;
        order.NE__OptyId__c = opportunityToInsert.Id;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'In Progress';
        order.NE__Type__c = 'InOrder';
        order.XC_Country__c = 'Italy';
        insert order;

        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        orderItem.NE__Account__c = testAccount.ID;
        orderItem.NE__Root_Order_Item__c = null;
        orderItem.NE__Bundle_Configuration__c = null;
        insert orderItem;
		
        opportunityToInsert.XC_AMP_Order__c = order.Id;
        update opportunityToInsert;

    }
    
      @isTest
      public static void onUtils() {
        Test.startTest(); 
        Opportunity opp = XC_DF_Opportunity.createOpportunity(1, false)[0];
        insert opp;
        XC_AMP_LCC020_SimplifiedSales.ResultWrapper resWr = XC_AMP_LCC020_SimplifiedSales.getTemplate(opp.Id);
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.XC_Status__c = 'In Progress';
        update order;
        XC_AMP_LCC020_SimplifiedSales.ResultWrapper resWr2 = XC_AMP_LCC020_SimplifiedSales.getTemplate(order.NE__OptyId__c);
        Schema.DescribeFieldResult fieldResult = NE__Order__c.XC_CheckpointSimplifiedSales__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        XC_AMP_LCC020_SimplifiedSales.ResultWrapper resCheckPoint =  XC_AMP_LCC020_SimplifiedSales.updateCheckPoint(order.Id, ple[0].getLabel());
        resCheckPoint =  XC_AMP_LCC020_SimplifiedSales.updateCheckPoint(order.Id, 'TestError');
        XC_AMP_LCC020_SimplifiedSales.ResultWrapper resProv = XC_AMP_LCC020_SimplifiedSales.startProvisioning(order.Id, 1);
        resProv = XC_AMP_LCC020_SimplifiedSales.startProvisioning(order.Id, 2);
        resProv = XC_AMP_LCC020_SimplifiedSales.startProvisioning(order.Id, 3);
        resProv = XC_AMP_LCC020_SimplifiedSales.startProvisioning(order.Id, 4);
        Test.stopTest();
      }
    
      @future(callout = true)
    public static void linkPaymentMethodToAccountF1(String zuoraAccountId, String paymentMethodId, String entityName){
        XC_AMP_LCC020_SimplifiedSales.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId, entityName);
	}
    
	  
    @isTest
    public static void  linkPaymentMethodToAccountTest(){    
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
        String entityName = 'Spain';
        //XC_AMP_LCC020_SimplifiedSales.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId, entityName);
    	linkPaymentMethodToAccountF1(zuoraAccountId,paymentMethodId,entityName); 
    }
   
    
    @future(callout = true)
	public static void linkAccountToExternalPaymentMethodF1(String accountId, String externalPaymentMethodType, String entityName){
        XC_AMP_LCC020_SimplifiedSales.linkAccountToExternalPaymentMethod(accountId, externalPaymentMethodType, entityName);
	}
    
    @isTest
    public static void  linkAccountToExternalPaymentMethodTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String accountId = '12131341';
        String externalPaymentMethodType = 'SEPA'; 
        String entityName = 'Spain B2C';
    	linkAccountToExternalPaymentMethodF1(accountId, externalPaymentMethodType, entityName);
    }
    
    @isTest
    public static void saveIntegrationLog(){
        String listLogString = '';
        XC_Integration_Log__c intLog = new XC_Integration_Log__c();
        List<XC_Integration_Log__c> listLog = new List<XC_Integration_Log__c>();
        listLog.add(intLog);
        listLogString = JSON.serialize(listLog);
        Test.startTest();
        XC_AMP_LCC020_SimplifiedSales.saveIntegrationLog(listLogString);
        Test.stopTest();
    }
    
    @isTest
    public static void callSIASEPATest(){
        String contactId = [SELECT Id FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0].Id;
        NE__Billing_Profile__c billProf = [SELECT Id, XC_MandateType__c FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        Test.startTest();
        XC_AMP_LCC020_SimplifiedSales.manageOperationBeforeCallSia(contactId, 'English', 'Direct Debt', billProf.Id);
        XC_AMP_LCC020_SimplifiedSales.manageOperationBeforeCallSia(contactId, 'English', 'Credit Card', billProf.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createOrSelectBillingProfileTest(){
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        Opportunity opp = [SELECT Id,Name FROM Opportunity LIMIT 1][0];
        XC_Address__c address = [SELECT Id,Name FROM XC_Address__c LIMIT 1][0];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];
        Test.startTest(); 
        XC_AMP_LCC020_SimplifiedSales.createOrSelectBillingProfile(acc.Id, '{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + contact.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "Credit Card"}');
        XC_AMP_LCC020_SimplifiedSales.createOrSelectBillingProfile(acc.Id, '{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + contact.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "Commodity Bill"}');
        XC_AMP_LCC020_SimplifiedSales.createOrSelectBillingProfile(acc.Id, '{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + contact.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "Bank Transfer"}');
		XC_AMP_LCC020_SimplifiedSales.createOrSelectBillingProfile(acc.Id, '{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + contact.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "Direct Debt"}');
        XC_AMP_LCC020_SimplifiedSales.createOrSelectBillingProfile(acc.Id, '{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + contact.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "External Financing"}');
        Test.stopTest();
    }
    
    
    @isTest
    public static void prepareForCreateUnlinkedZuoraAccount(){
        Test.startTest();
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        Opportunity opp = [SELECT Id,Name FROM Opportunity LIMIT 1][0];
        XC_Address__c address = [SELECT Id,Name FROM XC_Address__c LIMIT 1][0];
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        Contact cc2 = [SELECT Id,Name FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];
        XC_BillingProfileLineItem__c bl = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1][0];
        String accountJSON = JSON.serialize(acc);
        String billingProfileId = bl.Id;
        String cc1JSON = '{"Name": "contbilToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EnelXItalia"}';
        String cc2JSON = '{"Name": "contsoldToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "yes", "XC_MainLegalEntity__c": "EnelXItalia"}';
        XC_AMP_LCC020_SimplifiedSales.prepareForCreateUnlinkedZuoraAccount('{"opportunityId": "' + opp.Id + '", "legalEntity": "EnelXItalia", "billingAddress":"' + address.Id + '", "contactId":"' + cc2.Id + '","soldAddress":"' + address.Id + '", "doxeeLanguage": "ITA", "contractId": "11", "cupsId": "11", "contractType": "ELECTRIC",  "cardNumber": "11111111111111", "payment": "Commodity Bill", "contractBatch":"true", "getContractBy":"IdentityDoc", "invoiceDel": "Email", "entityName":"Italy B2C", "docCountry": "Italy"}',accountJSON, cc1JSON, cc2JSON, billingProfileId);
        Test.stopTest();
    }
    
    
    @future(callout = true)
    public static void createPaymentMethodF1(String paymentMethod, String entityName, String billingProfLineItemId){
        XC_AMP_LCC020_SimplifiedSales.createPaymentMethod(paymentMethod,entityName, billingProfLineItemId);
    }
    
    @isTest
    public static void createPaymentMethodTest(){
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createPaymentMethodF1('', 'Spain B2C', String.valueOf(bpliList[0].Id));
    }
    
    @isTest
    public static void createValueMapTest(){
        XC_BillingProfileLineItem__c bl = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1][0];
        Contact cc1 = [SELECT Id,Name, Email, XC_MainLegalEntity__c, AccountId, XC_Preferredlanguageofcontact__c FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        Test.startTest();
        XC_AMP_UTIL_BillingProfileManagement.createValueMap(cc1,'testUrl',bl.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void associateBillingProfileTest(){
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        Opportunity opp = [SELECT Id,Name FROM Opportunity LIMIT 1][0];
        XC_BillingProfileLineItem__c bl = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 1][0];
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1];
        Test.startTest();
        XC_AMP_LCC020_SimplifiedSales.associateBillingProfile(acc.Id, bl.Id, opp.Id, 'Bank Transfer');
        Test.stopTest();
    }
    
    @isTest
    public static void rollbackForErrorTest(){
        String billingProfLineItemId = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1][0].Id;
        Test.startTest();
        XC_AMP_UTIL_BillingProfileManagement.rollbackForError(billingProfLineItemId, 'Test');
        Test.stopTest();
    }

}