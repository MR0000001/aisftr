/**
 * @description       : Test class for ZuoraBillingProfileCreationController.cls
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 21-12-2021
 * @last modified by  : Denise Avolio - denise.avolio@accenture.com
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   09-21-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
 * 2.0   12-21-2021   Denise Avolio - denise.avolio@accenture.com    TPB: Added for code coverage
**/
@isTest
public class ZuoraBillingProfileCreationCC_TEST {
    
    @testSetup
    public static void testSetup(){
        Account testAccount = new Account(Name='Account_Name_Test',XC_Country__c='Spain',PrimaryEmail__c='accbp@gmail.com');
        insert testAccount;
        Account accBillTo = new Account(Name='BillTo',PrimaryEmail__c='accBillTobp@gmail.com');
        insert accBillTo;
        Account accSoldTo = new Account(Name='SoldTo',PrimaryEmail__c='accSoldTobp@gmail.com');
        insert accSoldTo;
        Contact contbilTo = new Contact(FirstName = 'contbilToName' , LastName = 'contbilToName', AccountId = accBillTo.Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Spain', XC_MainLegalEntity__c = 'EndesaX', Email = 'contbilTo@test.it');
        insert contbilTo;
        Contact contsoldTo = new Contact(FirstName = 'contsoldToName' ,LastName = 'contsoldToName', AccountId = accSoldTo.Id, XC_GiveDataToNew__c = 'Yes', XC_CountryLegalEntity__c = 'Spain', XC_MainLegalEntity__c = 'EndesaX', Email = 'contsoldTo@test.it');
        insert contsoldTo;
        XC_PersonalDocument__c docs = new XC_PersonalDocument__c(XC_Account__c = testAccount.Id);
        insert docs;
        /*NE__Billing_Profile__c testBillingProfileZuora = new NE__Billing_Profile__c(Name='Zuora_Account_Name_Test',NE__Account__c=testAccount.Id);
        insert testBillingProfileZuora;*/
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        bpList[0].Name = 'Zuora_Account_Name_Test';
        bpList[0].NE__Card_Type__c = 'Visa'; //[DeAv 21/12/2021 TPB: Added for code coverage]
        update bpList;

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1];
        bpliList[0].XC_LegalEntity__c = 'EndesaX';
        update bpliList;
        
            
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = testAccount.Id;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Madrid';
        addressToInsert.XC_AddressCountry__c = 'Spain';
        addressToInsert.XC_PostalCode__c = '28080';
        addressToInsert.XC_AddressProvince__c = 'Madrid';
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
        //XC_PersonalDocument__c doc = new XC_PersonalDocument__c(XC_DocumentType__c = 'NIE', XC_DocumentNumber__c = 'Test');
        //insert doc;
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

        //test on B2B Account
        Account accountToInsert = new Account();
        accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accountToInsert.Name = 'Test Account n ' + (Math.random()*Math.random());
        accountToInsert.Company__c = 'Test Account Company n ' + (Math.random()*Math.random());
        accountToInsert.XC_DocumentCountry__c = 'Argentina';
        accountToInsert.XC_DocumentCountry__c = 'Spain';
        accountToInsert.IdentityType__c = 'NIF';
        accountToInsert.XC_Status__c = 'Active'; 
        accountToInsert.IdentityNumber__c = 'M1234567A'; //'11400283B';
        accountToInsert.PrimaryEmail__c = 'test_b2b_acc@gmail.com';
        insert accountToInsert;

    }

    @isTest
    public static void utilfiedlSet() {
        String fieldSetKey = 'XC_ESP_Account_New_Consents';
        Test.startTest();
        XC_Util_FieldSet.getFieldSetFields(fieldSetKey,'Account');
        //ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper addWr = ZuoraBillingProfileCreationController.getContractByPOSAndAccountDoc('ES1283818238', [SELECT Id FROM XC_Address__c LIMIT 1].Id );
        Test.stopTest();
    }
    
    @isTest
    public static void updateSalesforceAccount(){
        Test.startTest();
        NE__Billing_Profile__c element = [SELECT ID FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        ZuoraBillingProfileCreationController.updateSalesforceAccount(element.id,'{"PreferredLanguage__c":"CA"}');
    	Test.stopTest();
    }
    
    @isTest
    public static void updateAccountDoxeeLanguageTest(){
        Account acc = [SELECT Id FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        ZuoraBillingProfileCreationController.updateAccountDoxeeLanguage(acc.id,'EN');
    }
    
    @future(callout = true)
    public static void retrieveCupsF1(String addressId){
        ZuoraBillingProfileCreationController.retrieveCups(addressId, '3333333', 'Spain B2B');
	}
    
    @future(callout = true)
    public static void callContractByPOS(String addressId){
        ZuoraBillingProfileCreationController.getContractByPOS( 'ES1283818238', addressId, 'Spain B2B');
	}

    //[DeAv 21/12/2021 TPB: Added for code coverage START]
    @future(callout = true)
    public static void callContractByPOSAndAccountDoc(String addressId){
        ZuoraBillingProfileCreationController.getContractByPOSAndAccountDoc( 'ES1283818238', addressId);
	}

    @future(callout = true)
    public static void callRetrieveCupsByDocAccountAndPOD(String addressId){
        ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper wr1 = ZuoraBillingProfileCreationController.retrieveCupsByDocAccountAndPOD(addressId, 'test');
	}
    //[DeAv 21/12/2021 TPB: Added for code coverage END]
    
    @isTest
    public static void retrieveCupsTest(){             
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        System.debug('add: '+add.Id);
        retrieveCupsF1(add.Id);
    }
    
    @isTest
    public static void retrieveCupsTest2(){
               
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        csInt.XC_ServerSystem__c = 'CommoditySpainB2B';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c=null;
        add.XC_AddressCountry__c='Spain';
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
        csInt.XC_Country__c = 'Spain';
        csInt.XC_ServerSystem__c = 'CommoditySpainB2B';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = null;
        add.XC_GasCUPS__c='ES1283818238';
        add.XC_AddressCountry__c='Spain';
        update add;
        retrieveCupsF1(add.Id);
    }
    
    @isTest
    public static void getContractByPOS(){             
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        csInt.XC_ServerSystem__c = 'CommoditySpainB2B';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c=null;
        add.XC_AddressCountry__c='Spain';
        update add;
        callContractByPOS(add.Id);
    }

    //[DeAv 21/12/2021 TPB: Added for code coverage START]
    @isTest
    public static void getContractByPOSAndAccountDoc(){             
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c=null;
        add.XC_AddressCountry__c='Spain';
        update add;
        callContractByPOSAndAccountDoc(add.Id);
    }

    /*@isTest
    public static void getContractByPOS_Two(){             
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Chile';
        insert csInt;        
        XC_CS001_InterfaceConfiguration__c interfaceConf = new XC_CS001_InterfaceConfiguration__c();
        interfaceConf.XC_activeInterface__c = true;
        interfaceConf.XC_URL_Required__c = 'test';
        interfaceConf.Name = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_interfaceName__c = Label.XC_CL_ContractAccountValidation;
        interfaceConf.XC_ServerSystem__c = 'CommodityChile';
        interfaceConf.XC_Country__c = 'Chile';
        insert interfaceConf;
        XC_CS001_InterfaceConfiguration__c csInt2 = new XC_CS001_InterfaceConfiguration__c();
        csInt2.Name = Label.XC_CL_ContractOutbound;
        csInt2.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt2.XC_activeInterface__c = true;
        csInt2.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt2.XC_Country__c = 'Spain';
        csInt2.XC_ServerSystem__c = 'CommoditySpainB2B';
        insert csInt2;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c=null;
        add.XC_AddressCountry__c='Chile';
        update add;
        callContractByPOS(add.Id);
    }*/

    @isTest
    public static void updateSalesforceAccount_Two(){
        User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c = 'EnelXItalia';
        insert u;
        System.runAs(u){
            Test.startTest();    
            Account acc = [SELECT Id,Name, XC_Segment__c, XC_PEC_Email__c FROM Account WHERE PrimaryEmail__c='test_soho_acc@gmail.com' LIMIT 1][0];
            acc.XC_PEC_Email__c = true;
            update acc;
            NE__Order__c ord = new NE__Order__c(NE__AccountId__c = acc.Id, XC_Segment__c = 'B2B');
            insert ord;
            ZuoraBillingProfileCreationController.updateSalesforceAccount(ord.id,'{"PreferredLanguage__c":"CA"}');
            Test.stopTest();
        }
    }

    @isTest
    public static void retrieveCupsTest4(){
               
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        csInt.XC_ServerSystem__c = 'Test';
        insert csInt;
      	Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock()); 
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c,XC_AddressCountry__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        add.XC_ElectricCUPS__c = 'ES1283818238';
        add.XC_GasCUPS__c='ES1283818238';
        add.XC_AddressCountry__c='Spain';
        update add;
        retrieveCupsF1(add.Id);
    }
    //[DeAv 21/12/2021 TPB: Added for code coverage END]
    
    @isTest
    public static void initPaymentPageTest(){
        Test.startTest();
        //XC_PersonalDocument__c docs = [SELECT Id,XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentType__c = 'NIE' AND XC_DocumentNumber__c = 'Test' LIMIT 1][0];
        Account acc = [SELECT id, XC_RecordTypeDeveloperName__c, (SELECT id,XC_Account__c, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c ='Test') FROM Account WHERE XC_RecordTypeDeveloperName__c = 'XC_GLO_Account_Residential' limit 1][0];
        Account sohoAccount = [SELECT ID,XC_RecordTypeDeveloperName__c FROM Account WHERE PrimaryEmail__c='test_soho_acc@gmail.com' LIMIT 1][0];
        NE__Billing_Profile__c element = [SELECT ID FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        element.NE__Payment__c = 'Bank Transfer';
        update element;
        ZuoraBillingProfileCreationController.initPaymentPage(acc.Id, 'Account');
        ZuoraBillingProfileCreationController.initPaymentPage(element.Id, 'NE__Billing_Profile__c');
        ZuoraBillingProfileCreationController.initPaymentPage(sohoAccount.Id, 'Account');
        
        NE__Order__c order = XC_DF_Order.createOrder('inOrder');
        ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'Account', order.id, element.Id);
        Test.stopTest();
    }
    
    /*@isTest
    public static void retrievePersonalDocumentTest(){
        List<XC_PersonalDocument__c> docs = [SELECT Id FROM XC_PersonalDocument__c WHERE XC_DocumentType__c = 'NIE' AND XC_DocumentNumber__c = 'Test'];
        insert docs;
        ZuoraBillingProfileCreationController.retrievePersonalDocument(docs);
    }*/
    
    @future(callout = true)
    public static void linkPaymentMethodToAccountF1(String zuoraAccountId, String paymentMethodId, String entityName){
        ZuoraBillingProfileCreationController.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId, entityName);
	}
    
    @isTest
    public static void  linkPaymentMethodToAccountTest(){    
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
        String entityName = 'Spain';
    	linkPaymentMethodToAccountF1(zuoraAccountId,paymentMethodId,entityName);
        
    }
    
    @isTest
    public static void  getSoldAddressofAccountPicklistTest(){
        Account acc = [SELECT Id FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        ZuoraBillingProfileCreationController.getSoldAddressofAccountPicklist(acc.id,true);
        ZuoraBillingProfileCreationController.getSoldAddressofAccountPicklist(acc.id,false);
    }
    
    @future(callout = true)
	public static void linkAccountToExternalPaymentMethodF1(String accountId, String externalPaymentMethodType, String entityName){
        ZuoraBillingProfileCreationController.linkAccountToExternalPaymentMethod(accountId, externalPaymentMethodType, entityName);
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
    public static void createBillingProfileTest(){
        Test.startTest();
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        Contact cc2 = [SELECT Id,Name FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];
        String cc1JSON = '{"Name": "contbilToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String cc2JSON = '{"Name": "contsoldToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String billAddress = 'test1';
        String soldAddress = 'test2'; 
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "1", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11",  "fromBillingProfile": "11", "paymentMethodType": "CreditCard"}');
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "2", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11", "fromBillingProfile": "11", "paymentMethodType": "CommodityBill"}');
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "3", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11",  "fromBillingProfile": "11", "paymentMethodType": "SEPA"}');
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "4", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11",  "fromBillingProfile": "11", "paymentMethodType": "Barcode"}');
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "5", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11",  "fromBillingProfile": "11", "paymentMethodType": "BankTransfer"}');
        ZuoraBillingProfileCreationController.createBillingProfile(cc1JSON,cc2JSON,billAddress,soldAddress,'{"cardNumber": "11111111111111", "month": "6", "year": "2000", "accountNumber": "11", "contractId": "11", "cupsId": "11", "interactionId": "11",  "fromBillingProfile": "11", "paymentMethodType": "CreditCardSIA"}');
        Test.stopTest();
    }
    
    
    @future(callout = true)
    public static void createUnlinkedZuoraAccountF1(String account, String billingContact, String soldContact, String entityName, String options, String billingProfLineItemId, String zuoraPayment){
        //ZuoraBillingProfileCreationController.createUnlinkedZuoraAccount(account,billingContact,soldContact,entityName,options,billingProfLineItemId,zuoraPayment, true);
        ZuoraBillingProfileCreationController.rollbackForError(billingProfLineItemId, 'Test', true);
    }
    
    @isTest
    public static void rollbackForErrorBPLITest(){
        String billingProfLineItemId = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1][0].Id;
        ZuoraBillingProfileCreationController.InputRollbackWrapper inputRollback =  new ZuoraBillingProfileCreationController.InputRollbackWrapper();
        inputRollback.billingProfileLineItemId = billingProfLineItemId;
        inputRollback.billingProfileId = null;
        inputRollback.errorMessage = 'Test';
        inputRollback.doRollback = false;
        Test.startTest();
        ZuoraBillingProfileCreationController.rollbackForErrorBPLI(inputRollback);
        Test.stopTest();
        XC_BillingProfileLineItem__c bpli = [SELECT ID, XC_ErrorLastCallout__c FROM XC_BillingProfileLineItem__c WHERE ID =:billingProfLineItemId LIMIT 1];
        System.assertEquals(inputRollback.errorMessage, bpli.XC_ErrorLastCallout__c);
    }

    @isTest
    public static void getExistingCommodityContractInfosTest(){
        NE__Billing_Profile__c bp = [SELECT ID FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        ZuoraBillingProfileCreationController.getExistingCommodityContractInfos(bp.Id);
    }
    
    @isTest
    public static void createUnlinkedZuoraAccountTest(){
        //Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        String accJSON = '{"Name": "TestAccount", "XC_Segment__c": "B2C"}';
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        Contact cc2 = [SELECT Id,Name FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];
        System.debug('acc.id: ' + acc.Id);
        System.debug('cc1.id: ' + cc1.id);
        System.debug('cc2.id: ' + cc2.id);
        String cc1JSON = '{"Name": "contbilToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String cc2JSON = '{"Name": "contsoldToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String entityName = 'Spain B2C';
        String options = 'test';
        String billingProfLineItemId = [SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1][0].Id;
        String zuoraPayment = '{"Name": "SEPA"}';
        createUnlinkedZuoraAccountF1(accJSON,cc1JSON,cc2JSON,entityName,options,billingProfLineItemId,zuoraPayment);
        //Test.stopTest();
    }
    
    @future(callout = true)
    public static void createZuoraAccountF1(String account, String paymentMethodId,String paymentMethodType, String billingContact, String soldContact, String entityName){
        ZuoraBillingProfileCreationController.createZuoraAccount(account,paymentMethodId,paymentMethodType, billingContact, soldContact, entityName);
    }
    
    @isTest
    public static void createZuoraAccountTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];
        String accJSON = '{"Name": "TestAccount"}';
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        Contact cc2 = [SELECT Id,Name FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];

        String cc1JSON = '{"Name": "contbilToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String cc2JSON = '{"Name": "contsoldToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EndesaX"}';
        String entityName = 'Spain B2C';
        String paymentMethodId = '23444444';
        String paymentMethodType = 'SEPA';
        createZuoraAccountF1(accJSON,paymentMethodId,paymentMethodType, cc1JSON, cc2JSON, entityName); 

    }
    
    @isTest
    public static void initPaymentPageForOrderTest(){
        Test.startTest();    
        /*NE__Billing_Profile__c billProf = [SELECT Id FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];*/
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0];        
        NE__Order__c ord = new NE__Order__c();
		insert ord;
        NE__Billing_Profile__c element = [SELECT ID FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        element.NE__Payment__c = 'Bank Transfer';
        update element;
        ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'Account', ord.Id);
        ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'Account', ord.Id, element.Id);
        Test.stopTest();
    }  
    
    @isTest
    public static void initPaymentPageForOrderTest2(){
        User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c = 'EnelXItalia';
        insert u;
        System.runAs(u){
            Test.startTest();    
            Account acc = [SELECT Id,Name, XC_Segment__c, XC_PEC_Email__c FROM Account WHERE PrimaryEmail__c='test_soho_acc@gmail.com' LIMIT 1][0];
            acc.XC_PEC_Email__c = true;
            update acc;
            NE__Order__c ord = new NE__Order__c(NE__AccountId__c = acc.Id, XC_Segment__c = 'B2B');
            insert ord;
            ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'NE__Order__c', ord.Id);
            ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'Account',ord.Id);
            Test.stopTest();
        }
    }

    @isTest
    public static void initPaymentPageForOrderTest3(){
        Test.startTest();    
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='test_b2b_acc@gmail.com' LIMIT 1][0];
        NE__Order__c ord = new NE__Order__c(NE__AccountId__c = acc.Id);
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,false);
        oppList[0].XC_GasContract__c = '12039661873';
        oppList[0].XC_ElectricContract__c   = '12039661873';
        insert oppList;
        ord.NE__OptyId__c = oppList[0].Id;
		insert ord;
        ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'NE__Order__c', ord.Id);
        ZuoraBillingProfileCreationController.initPaymentPageForOrder(acc.Id, 'Account',ord.Id);
        Test.stopTest();
    }
    
    @future(callout = true)
    public static void createPaymentMethodF1(String paymentMethod, String entityName){
        ZuoraBillingProfileCreationController.createPaymentMethod(paymentMethod,entityName);
    }
    
    @isTest
    public static void createPaymentMethodTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createPaymentMethodF1('SEPA', 'Spain B2C');
    }

    @future(callout = true)
    public static void createPaymentMethod2(String paymentMethod, String entityName){
        //ZuoraBillingProfileCreationController.createPaymentMethod(paymentMethod, entityName, '', true);
    }
    
    @isTest
    public static void createPaymentMethodTest2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createPaymentMethod2('SEPA', 'Spain B2C');
    }
    
    @future(callout = true)
    public static void callSIAF1(String contactId , String language){
       // ZuoraBillingProfileCreationController.callSIA(contactId, language);       
    }
    
    @isTest
    public static void callSIATest(){
        Test.setMock(HttpCalloutMock.class, new XC_REST_PaymentMethodSIA_Mock());
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        callSIAF1(cc1.id , 'Spanish');        
    }
    
    @isTest
    public static void callSIATestWithEmail(){
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_PaymentMethodSIA;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        insert csInt;
        Test.setMock(HttpCalloutMock.class, new XC_REST_PaymentMethodSIA_Mock());
        Contact cc1 = [SELECT Id,Name,Email FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0];
        callSIAF1(cc1.id , 'Spanish');        
    }
    
    @future(callout = true)
    public static void generateParamsFromPaymentMethodTypeF1(String accountId, String paymentMethodType){
        ZuoraBillingProfileCreationController.generateParamsFromPaymentMethodType(accountId, paymentMethodType);
    }
    
    @isTest
    public static void generateParamsFromPaymentMethodTypeTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        Account acc = [SELECT Id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com' LIMIT 1][0]; 
        String paymentMethodType = 'SEPA';
        generateParamsFromPaymentMethodTypeF1(acc.id, paymentMethodType);
    }
    
    @isTest
    public static void prepareContactForZuoraTest(){
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        XC_Address__c add = [SELECT Id,XC_ElectricCUPS__c,XC_GasCUPS__c FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
		ZuoraBillingProfileCreationController.prepareContactForZuora(cc1.Id, add.Id, 'Spain');
    }
    
    @isTest
    public static void retriveContactsForZuoraTest(){
        Account acc = [SELECT id,Name FROM Account WHERE PrimaryEmail__c='accbp@gmail.com'];
        XC_Address__c address = [SELECT Id FROM XC_Address__c WHERE XC_City__c = 'Madrid' LIMIT 1][0];
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        NE__Billing_Profile__c billProf = [SELECT Id FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        String JSON = '{"soldContact": "' + cc1.id + '" , "billingAddress": "' + address.id + '", "soldAddress": "' + address.id + '"}';
        //ZuoraBillingProfileCreationController.retriveContactsForZuora(acc.Id, JSON);
        //ZuoraBillingProfileCreationController.retriveContactsForZuora(billProf.Id, JSON);
    }
    
    @isTest
    public static void callSIACreditCardTest(){
        Test.setMock(HttpCalloutMock.class, new XC_REST_PaymentMethodSIA_Mock());
        String contactId = [SELECT Id FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0].Id;
        NE__Billing_Profile__c billProf = [SELECT Id, XC_MandateType__c FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        ZuoraBillingProfileCreationController.manageOperationBeforeCallSia(contactId, 'English', 'Credit Card', billProf.Id);
        ZuoraBillingProfileCreationController.manageOperationBeforeCallSiaWithOption(contactId, 'English', 'Credit Card', billProf.Id,false);

    }

    @isTest
    public static void callSIASEPATest(){
        String contactId = [SELECT Id FROM Contact WHERE LastName = 'contsoldToName' LIMIT 1][0].Id;
        NE__Billing_Profile__c billProf = [SELECT Id, XC_MandateType__c FROM NE__Billing_Profile__c WHERE Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        ZuoraBillingProfileCreationController.manageOperationBeforeCallSia(contactId, 'English', 'Direct Debt', billProf.Id);
        ZuoraBillingProfileCreationController.manageOperationBeforeCallSiaWithOption(contactId, 'English', 'Direct Debt', billProf.Id,false);

    }
    
    @isTest
    public static void manageUpdateUnusedBPLISoldToTest(){
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_LegalEntity__c, XC_BillToAddress__c, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        Map<String,Object> paramsMap = new Map<String, Object>{'bdId' => bpli.XC_BillingProfile__c, 'soldToAddressId' => bpli.XC_SoldToAddress__c, 'billToAddressId' => bpli.XC_BillToAddress__c, 'legalEntity' => bpli.XC_LegalEntity__c};
        ZuoraBillingProfileCreationController.manageUpdateUnusedBPLISoldTo(paramsMap);
    }
    
    @isTest
    public static void manageUpdateUnusedBPLISoldToDuplTest(){
        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Account__c, XC_LegalEntity__c, (SELECT ID FROM Configuration_Items__r) FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__r.Name = 'Zuora_Account_Name_Test' LIMIT 1][0];
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c(Zuora__Account__c = bpli.XC_BillingProfile__r.NE__Account__c);
        ca.Zuora__DefaultPaymentMethod__c= 'Other'; 
      	ca.otherPaymentMethodType__c = 'Barcode';
        insert ca;
        bpli.XC_CustomerAccount__c = ca.Id;
        bpli.XC_Status__c = 'Active';
        bpli.XC_LegalEntity__c = 'EndesaX';
        update bpli;
        
        delete bpli.Configuration_Items__r;
        
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = bpli.XC_BillingProfile__r.NE__Account__c;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Madrid';
        addressToInsert.XC_AddressCountry__c = 'Spain';
        addressToInsert.XC_PostalCode__c = '28022';
        addressToInsert.XC_AddressProvince__c = 'Madrid';
        addressToInsert.XC_StreetNumber__c = '12' + Math.random();
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
        addressToInsert.XC_InstallationAddress__c = TRUE;
        addressToInsert.XC_DeliveryAddress__c = TRUE;
        addressToInsert.XC_BillingAddress__c = TRUE;
        addressToInsert.XC_PickUpPoint__c = TRUE;
        addressToInsert.XC_PointOfSales__c = TRUE;
        addressToInsert.XC_WareHouse__c = TRUE;
        insert addressToInsert;
        
        Map<String,Object> paramsMap = new Map<String, Object>{'bpId' => bpli.XC_BillingProfile__c, 'soldToAddressId' => addressToInsert.Id, 'billToAddressId' => addressToInsert.Id, 'legalEntity' => bpli.XC_LegalEntity__c};
        ZuoraBillingProfileCreationController.manageUpdateUnusedBPLISoldTo(paramsMap);
    }
    
    @isTest
    public static void getPaymentMethodsPicklistTest(){
        ZuoraBillingProfileCreationController.getPaymentMethodsPicklist('EndesaX', 'B2C');
    }
    
    @isTest
    public static void getPaymentMethodCategoryPickListTest(){
        ZuoraBillingProfileCreationController.getPaymentMethodCategoryPickList();
    }
    
    @isTest
    public static void getPaymentCategoryDependencyTest(){
        ZuoraBillingProfileCreationController.getPaymentCategoryDependency('Credit Card');
    }

    @isTest
    public static void checkContactEmailTest(){
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        ZuoraBillingProfileCreationController.checkContactEmail(cc1.Id);
    }
    
    @isTest
    public static void callSIAForSEPAAsynchronousTest(){
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        List<NE__Billing_Profile__c> bpList = [SELECT Id,NE__Iban__c FROM NE__Billing_Profile__c LIMIT 1];

        Test.startTest();
            ZuoraBillingProfileCreationController.callSIAForSEPAAsynchronous(cc1.Id,bpList[0]);
        Test.stopTest();

    }
    @isTest
    public static void callSIAForSEPAAsynchronousTest2(){
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        List<NE__Billing_Profile__c> bpList = [SELECT Id,NE__Iban__c FROM NE__Billing_Profile__c LIMIT 1];

        Test.startTest();
            ZuoraBillingProfileCreationController.callSIAForSEPAAsynchronous(cc1.Id,bpList[0],new Map<String,String>());
        Test.stopTest();

    }

    @isTest
    public static void callSIAForCCAsynchronousTest(){
        Contact cc1 = [SELECT Id,Name FROM Contact WHERE LastName = 'contbilToName' LIMIT 1][0];
        List<NE__Billing_Profile__c> bpList = [SELECT Id,NE__Iban__c,XC_MandateType__c FROM NE__Billing_Profile__c LIMIT 1];

        Test.startTest();
            ZuoraBillingProfileCreationController.callSIAForCreditCardAsynchronous(cc1.Id,bpList[0]);
        Test.stopTest();

    }
    
    @isTest
    public static void getExistingCommodityContractInfos(){
        List<NE__Billing_Profile__c> bpList = [SELECT Id,NE__Iban__c,XC_MandateType__c FROM NE__Billing_Profile__c LIMIT 1];
        Test.startTest();
			ZuoraBillingProfileCreationController.getExistingCommodityContractInfos(bpList[0].id);        	
        Test.stopTest();
    }
    
    @isTest
    public static void saveIntegrationLog(){
        String listLogString = '';
        XC_Integration_Log__c intLog = new XC_Integration_Log__c();
        List<XC_Integration_Log__c> listLog = new List<XC_Integration_Log__c>();
        listLog.add(intLog);
        listLogString = JSON.serialize(listLog);
        Test.startTest();
        	ZuoraBillingProfileCreationController.saveIntegrationLog(listLogString);
        Test.stopTest();
    }

    @isTest
    static void onRetrieveCupsByDocAccountAndPOD() {
        List<XC_Address__c> addr = XC_DF_Address.createAddress(3);
        addr[0].XC_GasCUPS__c = '';
        addr[0].XC_ElectricCUPS__c = 'Test';
        addr[1].XC_GasCUPS__c = 'Test';
        addr[1].XC_ElectricCUPS__c = '';
        addr[2].XC_GasCUPS__c = 'Test';
        addr[2].XC_ElectricCUPS__c = 'Test';
        insert addr;

        //[DeAv 21/12/2021 TPB: Added for code coverage START]
        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = Label.XC_CL_ContractOutbound;
        csInt.XC_interfaceName__c = Label.XC_CL_ContractOutbound;
        csInt.XC_activeInterface__c = true;
        csInt.XC_URL_Required__c ='https://api-qual-local.enelx.com/b2c/esb/services/Contract?api_key=etxfrn5spygkanhed78emgg5';
        csInt.XC_Country__c = 'Spain';
        insert csInt;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ContractOutbound_Mock());

        Test.startTest();
        callRetrieveCupsByDocAccountAndPOD(addr[0].id);
        callRetrieveCupsByDocAccountAndPOD(addr[1].id);
        callRetrieveCupsByDocAccountAndPOD(addr[2].id);
        //ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper wr1 = ZuoraBillingProfileCreationController.retrieveCupsByDocAccountAndPOD(addr[0].Id, 'test');
        //ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper wr2 = ZuoraBillingProfileCreationController.retrieveCupsByDocAccountAndPOD(addr[1].Id, 'test');
        //ZuoraBillingProfileCreationController.XC_CupsandContract_Wrapper wr3 = ZuoraBillingProfileCreationController.retrieveCupsByDocAccountAndPOD(addr[2].Id, 'test');
        Test.stopTest();
        //[DeAv 21/12/2021 TPB: Added for code coverage END]
    }
    
    @isTest
    static void isSEPAAlreadyInserted() {
        String zuoraAccountId = '54674722';
        String bankTransferAccountNumber = '22222222';
        String maskNumber = '1112';
		String creditCardType = 'VISA';
        Test.startTest();
		ZuoraBillingProfileCreationController.isSEPAAlreadyInserted(zuoraAccountId , bankTransferAccountNumber);
        ZuoraBillingProfileCreationController.isCreditCardAlreadyInserted(zuoraAccountId, creditCardType , maskNumber);
        Test.stopTest();
    }
    
}