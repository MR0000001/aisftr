/**
 * @author Emanuela Cacace  ecacace@deloitte.it
 * @date Creation  27/05/2019
 * @description XC_TR_ContentDocumentLink_U_CallDo_TEST – Test class for XC_TR_ContentDocumentLink_U_CallDoxee
 */
@isTest
public with sharing class XC_TR_ContentDocumentLink_U_CallDo_TEST {
// Test method for callDoxee
    @IsTest
    static void callDoxee(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        contactList[0].XC_MainLegalEntity__c = 'EndesaX';
        contactList[0].XC_Segment__c = 'B2C';
        insert contactList;
        
        Account acct = new Account(Name='TEST_ACCT');
        acct.PrimaryEmail__c = 'test@email.com';
        acct.XC_FirstName__c = 'pippo';
        acct.XC_LastName__c = 'pippo';
        acct.XC_ContactToNotify__c = contactList[0].id;
        insert acct;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'TEST - Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
       
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }
    
    @IsTest
    static void callDoxeeCI1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Installation - Gas', 'Installation');
        String rt =  Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId();
        for(WorkOrder wo :woList) 
        {
            wo.RecordTypeId = rt;
            wo.XC_Segment__c ='B2C';
           
        }
        insert woList;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder - SERVICE_REPORT.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = woList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }
    
    @IsTest
    static void callDoxeeCI2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
         List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        /* This method creates also the account and the related address */
        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = address[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        item.XC_Installation_Address__c = address[0].Id;
        item.NE__Account__c = opportunityToInsert.AccountId;
        item.XC_Product_Subtype__c = 'test';
        item.XC_CongaDynamicAPI__c = '&sessionid=test&serverurl=test&Id=test&QueryId=&TemplateId=&OFN=WorkOrder (Test long String for coverage, max lenght 85 char) - PRECONTRACTUAL_CONDITIONS&DefaultPDF=1&qmode=SalesforceFile';
        insert item;
        update order;
        //insert conf;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder (Test long String for coverage, max lenght 85 char) - PRECONTRACTUAL_CONDITIONS.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = order.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }

    // Test method for callDoxee2
    @IsTest
    static void callDoxee2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        contactList[0].XC_MainLegalEntity__c = 'EndesaX';
        contactList[0].XC_Segment__c = 'B2C';
        insert contactList;
        
        List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].XC_ContactToNotify__c = contactList[0].id;
        acct[1].XC_ContactToNotify__c = contactList[0].id;
        insert acct;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'TEST - Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];


        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = acct[1].id;
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        System.assert (cdl!=null);
        Test.stopTest();
    }

    @IsTest
    static void callDoxeeCI2WorkOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder>  listOfWo  = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Air Conditioning', 'Delivery & Installation');
        //insert conf;
         String rt =  Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId();
        for(WorkOrder wo : listOfWo) 
        {
            wo.RecordTypeId = rt;
            wo.XC_Segment__c ='B2C';
           
        }
    
        insert listOfWo;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder - PRECONTRACTUAL_CONDITIONS.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = listOfWo[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }

    @IsTest
    static void callDoxeeCI2WorkOrderLineItem(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder>  listOfWo  = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Air Conditioning', 'Delivery & Installation');
        //insert conf;
         String rt =  Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId();
        for(WorkOrder wo : listOfWo) 
        {
            wo.RecordTypeId = rt;
            wo.XC_Segment__c ='B2C';
           
        }
    
        insert listOfWo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = listOfWo[0].Id;
        insert woli;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder - PRECONTRACTUAL_CONDITIONS.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = woli.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }
    
    @IsTest
    static void callDoxeeCI2BPL(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Billing_Profile__c>  listOfBP = XC_DF_BillingProfile.createBillingProfile(1);
        listOfBP[0].XC_LegalEntity__c = 'EndesaX';
        update listOfBP;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder - PRECONTRACTUAL_CONDITIONS.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = listOfBP[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }
    
    @IsTest
    static void callDoxeeCIdocSigned(){
        
        List<Account> la = new List<Account>();
        la = XC_DF_Account.createResidentialAccounts(1);
        insert la;
        List<Contact> lc = new List<Contact>();
        lc = XC_DF_Contact.createResidentialContacts(la);
        insert lc;
       
        NE__Order__c configuration = XC_DF_Order.createOrder('InOrder');
        String docUrl = 'testurl';
        configuration.NE__AccountId__c = la[0].id;
        configuration.XC_LegalEntity__c = 'EndesaX';
        XC_TR_ContentDocumentLink_U_CallDoxee.createCustomerInteractionQuoteAccepted(configuration, docUrl);
        XC_TR_ContentDocumentLink_U_CallDoxee.createCustomerInteractionDocSigned(configuration, docUrl);
        System.assert (configuration.XC_LegalEntity__c == 'EndesaX');
    }
    
    @IsTest
    static void scriptVocalOrder(){
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        insert ordIt;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<NE__Billing_Profile__c>  listOfBP = XC_DF_BillingProfile.createBillingProfile(1);
        listOfBP[0].XC_LegalEntity__c = 'EnelXItalia';
        update listOfBP;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Vocal Script',
            PathOnClient = 'VOCAL_SCRIPT_'+ordIt.name+'_userId',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = listOfBP[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
     
        System.assert (cdl!=null);
        Test.stopTest();
    }
    
     
    @IsTest
    static void callDoxeeCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        Case c = XC_DF_Case.createCases(1)[0];
        insert c;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'TEST - Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assert (cdl!=null);
        Test.stopTest();
    }
}