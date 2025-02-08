/**
 * The Class XC_AMP_UTIL_BillingProfileMngmt_TEST.
 *
 * @author            : 
 * @date Creation     : 13/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_AMP_UTIL_BillingProfileManagement 
 **/

@isTest
public without sharing class XC_AMP_UTIL_BillingProfileMngmt_TEST {

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

    }
    
     
    @isTest
    public static void createOrSelectBillingProfileTest(){
        Account acc = [SELECT id, XC_RecordTypeDeveloperName__c, (SELECT id,XC_Account__c, XC_DocumentType__c, XC_DocumentNumber__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c ='Test') FROM Account WHERE XC_RecordTypeDeveloperName__c = 'XC_GLO_Account_Residential' limit 1][0];
        //XC_BillingProfileLineItem__c bpLI = [SELECT Id FROM XC_BillingProfileLineItem__c  WHERE XC_Account__c =: acc.Id LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contacts = [SELECT ID FROM Contact];
        XC_Address__c address = [SELECT ID FROM XC_Address__c LIMIT 1];
        Test.startTest();
		String mapValues = '{"doxeeLanguage":"DEU","legalEntity":"EnelXItalia","opportunityId":"'+opp.Id+'","contactId":"'+ contacts[0].Id+'","billingAddress":"'+address.Id+'","soldAddress":"'+address.Id+'"}';
        //String mapValues = '{"billingProfileLineItem":"'+ bpLI.Id +'", "opportunityId":"'+opp.Id+'"}';
        XC_UTIL_ResultWrapper result = XC_AMP_UTIL_BillingProfileManagement.createOrSelectBillingProfile(acc.Id, mapValues);
        Test.stopTest();
        //System.assertEquals('Electronic', result);
    }
    
    @future(callout = true)
    public static void createUnlinkedZuoraAccountF1(String account, String billingContact, String soldContact, String entityName, String options, String billingProfLineItemId, String zuoraPayment){
        //ZuoraBillingProfileCreationController.createUnlinkedZuoraAccount(account,billingContact,soldContact,entityName,options,billingProfLineItemId,zuoraPayment);
        XC_AMP_UTIL_BillingProfileManagement.rollbackForError(billingProfLineItemId, 'Test');
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
        String cc1JSON = '{"Name": "contbilToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EnelXItalia"}';
        String cc2JSON = '{"Name": "contsoldToName", "AccountId": "0019E000010dHxtQAE", "XC_GiveDataToNew__c": "Yes", "XC_MainLegalEntity__c": "EnelXItalia"}';
        String entityName = 'Italy B2C';
        String options = 'test';
        String billingProfLineItemId = null;//[SELECT ID FROM XC_BillingProfileLineItem__c LIMIT 1][0].Id;
        String zuoraPayment = '{"Name": "SEPA"}';
        createUnlinkedZuoraAccountF1(accJSON,cc1JSON,cc2JSON,entityName,options,billingProfLineItemId,zuoraPayment);
        //Test.stopTest();
    }
	
}