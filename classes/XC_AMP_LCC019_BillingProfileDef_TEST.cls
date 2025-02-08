/**
 * The Class XC_AMP_LCC019_BillingProfileDef_TEST.
 *
 * @author            : 
 * @date Creation     : 13/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_AMP_LCC019_BillingProfileDefinition 
 **/

@isTest
public without sharing class XC_AMP_LCC019_BillingProfileDef_TEST {

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
        NE__Billing_Profile__c testBillingProfileZuora = new NE__Billing_Profile__c(Name='Zuora_Account_Name_Test',NE__Account__c=testAccount.Id);
        insert testBillingProfileZuora;
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(testAccount);
        
        //List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1, listAccounts);
        //bpList[0].Name = 'Zuora_Account_Name_Test';
        //update bpList;

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1];
        //bpliList[0].XC_LegalEntity__c = 'EnelXItalia';
        //update bpliList;
        
            
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

        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(
                XC_BillingProfile__c = testBillingProfileZuora.Id, XC_BillingProfileCopy__c = testBillingProfileZuora.Id, XC_DocumentType__c = 'CF',
                XC_BillToAddress__c = addressToInsert.Id, XC_SoldToAddress__c = addressToInsert.Id,
                XC_BillToContactId__c = contbilTo.Id, XC_SoldToContactId__c = contsoldTo.Id
        );
        //insert billingProfileLineItem;

        //XC_PersonalDocument__c doc = new XC_PersonalDocument__c(XC_DocumentType__c = 'NIE', XC_DocumentNumber__c = 'Test');
        //insert doc;
     	Zuora_OAuth__c zoa = new  Zuora_OAuth__c();
        zoa.EntityName__c = 'Italy B2C';
        zoa.Client_Id__c = '123456'; 
        zoa.Client_Secret__c = '78910'; 
        zoa.EntityId__c = '1234567890764332';
        zoa.Host__c = 'rest.sandbox.eu.zuora.com';
        zoa.apiToken__c = '171173687168716368713718736183';
        insert zoa;
        zqu__BillingEntity__c billEntity = new zqu__BillingEntity__c(zqu__EntityName__c= 'Italy',zqu__EntityID__c='222222');
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
        insert orderItem;
		
        opportunityToInsert.XC_AMP_Order__c = order.Id;
        update opportunityToInsert;
        
        NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=testAccount.Id);
        insert billingToInsert;
        
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(
            XC_BillingProfile__c=billingToInsert.id,
            XC_SoldToAddress__c=addressToInsert.ID,
            XC_BillToAddress__c=addressToInsert.ID,
            XC_Account__c=testAccount.Id,
        	XC_ExternalKey__c = '1235',
        	XC_BillToContactId__c = contbilTo.Id,
            XC_SoldToContactId__c = contsoldTo.Id);
        insert bpli;
    }
    
    @isTest
    public static void initPaymentPageTest(){
        Test.startTest();
        //XC_PersonalDocument__c docs = [SELECT Id,XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentType__c = 'NIE' AND XC_DocumentNumber__c = 'Test' LIMIT 1][0];
        Account acc = [SELECT id, XC_RecordTypeDeveloperName__c, (SELECT id,XC_Account__c, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c ='Test') FROM Account WHERE XC_RecordTypeDeveloperName__c = 'XC_GLO_Account_Residential' limit 1][0];
        Account sohoAccount = [SELECT ID,XC_RecordTypeDeveloperName__c FROM Account WHERE PrimaryEmail__c='test_soho_acc@gmail.com' LIMIT 1][0];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        XC_AMP_LCC019_BillingProfileDefinition.initPaymentPage(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getPaymentCategoryDependencyTest(){
        Test.startTest();
        String category = XC_AMP_LCC019_BillingProfileDefinition.getPaymentCategoryDependency('Credit Card');
        Test.stopTest();
        System.assertEquals('Electronic', category);
    }
    
    @isTest
    public static void retrieveCupsTest1(){
               
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Italy';
        csInt.XC_ServerSystem__c = 'Test';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Roma' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c='ES1283818238';
        add.XC_AddressCountry__c='Italy';
        update add;
        retrieveCupsF1(add.Id);
    }
    
    @isTest
    public static void retrieveCupsTest2(){
               
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Italy';
        csInt.XC_ServerSystem__c = 'Test';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Roma' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c=null;
        add.XC_AddressCountry__c='Italy';
        update add;
        retrieveCupsF1(add.Id);
    }
    
    @isTest
    public static void retrieveCupsTest3(){
               
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Italy';
        csInt.XC_ServerSystem__c = 'Test';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Roma' LIMIT 1][0];
        add.XC_ElectricCUPS__c = null;
        add.XC_GasCUPS__c='ES1283818238';
        add.XC_AddressCountry__c='Italy';
        update add;
        retrieveCupsF1(add.Id);
    }
    
    @future(callout = true)
    public static void retrieveCupsF1(String addressId){
        XC_AMP_LCC019_BillingProfileDefinition.retrieveCups(addressId, '3333333');
	}
    
    @isTest
    public static void retrieveActiveBPLI(){
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        insert account;
        List<Contact> contact = XC_DF_Contact.createResidentialContacts(account);
        insert contact;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(account);
        insert address;
        
        NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c=account[0].Id);
        insert bp;
        
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(
            XC_BillingProfile__c=bp.id,
            XC_SoldToAddress__c=address[0].Id,
            XC_BillToAddress__c=address[0].Id,
            XC_Account__c= account[0].Id,
        	XC_ExternalKey__c = '34570',
        	XC_BillToContactId__c = contact[0].Id,
            XC_SoldToContactId__c = contact[0].Id,
            XC_Status__c = 'Active');
        insert bpli;
        
        Test.startTest();
         Map<String,List<XC_BillingProfileLineItem__c>> data = XC_AMP_LCC019_BillingProfileDefinition_D.getAvailableBillingProfiles(account[0].Id, contact[0].Id, address[0].Id);
        Test.stopTest();
        System.assert(!data.isEmpty());
    }
    
    @isTest
    public static void notActiveBPLI(){
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        insert account;
        List<Contact> contact = XC_DF_Contact.createResidentialContacts(account);
        insert contact;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(account);
        insert address;
        
        NE__Billing_Profile__c bp = new NE__Billing_Profile__c(NE__Account__c=account[0].Id);
        insert bp;
        
        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(
            XC_BillingProfile__c=bp.id,
            XC_SoldToAddress__c=address[0].Id,
            XC_BillToAddress__c=address[0].Id,
            XC_Account__c= account[0].Id,
        	XC_ExternalKey__c = '64778',
        	XC_BillToContactId__c = contact[0].Id,
            XC_SoldToContactId__c = contact[0].Id);
        insert bpli;
        
        Test.startTest();
         Map<String,List<XC_BillingProfileLineItem__c>> data = XC_AMP_LCC019_BillingProfileDefinition_D.getAvailableBillingProfiles(account[0].Id, contact[0].Id, address[0].Id);
        Test.stopTest();
        System.assert(data.isEmpty());
    }
}