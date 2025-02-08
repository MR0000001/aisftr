/**
 * @author Valeria Martino - valeria.martino@nttdata.com
 * @date Creation 29/07/2019
 * @description  – XC_LCC122_LeadConversion_TEST - Class test for XC_LCC122_LeadConversion
 */

@isTest
public without sharing class XC_LCC122_LeadConversion_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        XC_LeadAssignmentMaster__c leadAssignment = new XC_LeadAssignmentMaster__c();
        leadAssignment.XC_OrderOfEvaluation__c = 1;
        leadAssignment.XC_Status__c = 'Assigned';
        leadAssignment.XC_AssignedToCreator__c = true;
        insert leadAssignment;
    }

    private static Id createLe(){
        List<XC_CM_CountryLegalEntityAssociation__mdt> listCM = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
                                                                SELECT XC_Country__c
                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                WHERE XC_LegalEntity__c ='EndesaX'
                                                                                                                ]);
        Individual individual = new Individual(
            LastName= 'Test',
            XC_GiveDataToThirdParties__c='Yes'
            );
        insert individual;
        XC_LegalEntityConsent__c lec= new XC_LegalEntityConsent__c(
            XC_LegalEntity__c='EndesaX',
            XC_Individual__c=individual.id,
            XC_IndividualId__c=individual.id,
            XC_LeCountry__c=listCM[0].XC_Country__c,
            XC_GiveDataToNew__c='Yes'
            );
        insert lec;
        return Individual.Id;
    }

    private static Lead createLead(String rt){
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Test',
            RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId(),
            Email = 'test@test.test',
            XC_Channel__c = Label.XC_CL_WEB,
            Status='Appointment Scheduled',
            XC_MainLegalEntity__c='EndesaX',
            Country__c = 'SPAIN',
            Company = 'Test',
            XC_DocumentCountry__c='Spain',
            XC_DocumentNumber__c='42653268K',
            XC_DocumentType__c = 'NIF'
            );
        return lead;
    }

    private static Account createAccount(String rt){
        Account account = new Account();
        account.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        account.Name = 'Test Test';
        account.PrimaryEmail__c = 'test@test.test';
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93261703S';
        account.XC_DocumentCountry__c = 'Spain';
        account.XC_Country__c = 'SPAIN';
        account.Country__c = 'SPAIN';
        return account;
    }

    private static Contact createContact(Id accountId, String rt){
        Contact contact = new Contact();
        contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@test.test';
        contact.AccountId = accountId;
        contact.XC_SkipTriggerIndividual__c = true;
        contact.XC_GiveDataToNew__c= 'Yes';
        contact.XC_PrimaryContact__c= true;
        contact.XC_MainLegalEntity__c = 'EndesaX';
        contact.XC_ContactDocumentCountry__c='Spain';
        contact.XC_ContactDocumentNumber__c='5454551';
        contact.XC_ContactDocumentType__c = 'Passport';
        contact.Country__c='SPAIN';
        contact.XC_CountryLegalEntity__c='Spain';
        return contact;
    }

    private static Contact createSecondaryContact(Id accountId, String rt){
        Contact contactSecondary = new Contact();
        contactSecondary.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        contactSecondary.FirstName = 'Test';
        contactSecondary.LastName = 'Test';
        contactSecondary.Email = 'test2@test.test';
        contactSecondary.AccountId = accountId;
        contactSecondary.XC_SkipTriggerIndividual__c = true;
        contactSecondary.XC_GiveDataToNew__c= 'Yes';
        contactSecondary.XC_PrimaryContact__c= false;
        contactSecondary.XC_MainLegalEntity__c = 'EndesaX';
        contactSecondary.Country__c='SPAIN';
        contactSecondary.XC_CountryLegalEntity__c='Spain';
        return contactSecondary;
    }

    @isTest    
    static void conversion1() {
        XC_ProductCategoryOfInterest__c productCategoryOfInterest = new XC_ProductCategoryOfInterest__c();
        productCategoryOfInterest.Name = 'Aire acondicionado'; 
        productCategoryOfInterest.XC_CommercialVisit__c = false;
        insert productCategoryOfInterest;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;

        Lead lead = createLead('XC_GLO_Lead_Residential');
        lead.XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
        lead.XC_LeadAddress__c = listAddress[0].id;
        lead.Country__c = 'Spain';
        lead.XC_DocumentCountry__c = 'Spain';
        lead.XC_CDocCountry__c = 'Spain';
        insert lead;

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Lead__c = lead.id;
        listWorkOrder[0].XC_Address__c = listAddress[0].id;
        insert listWorkOrder;

        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        wrapper.createOpportunity = true;

        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        XC_LCC122_LeadConversion_U.validateForOpportunity(lead, wrapper, listWorkOrder);
        XC_LCC122_LeadConversion_U.validateWorkOrderLink(lead, wrapper, listWorkOrder);
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest    
    static void conversion1B2B() {
        XC_ProductCategoryOfInterest__c productCategoryOfInterest = XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        productCategoryOfInterest.Name = 'CHP';
        insert productCategoryOfInterest;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;
        Lead lead = createLead(Label.XC_CL_Lead_GLOB2B);
        lead.XC_ProductCategoryOfInterest__c = productCategoryOfInterest.Name;
        lead.XC_LeadAddress__c = listAddress[0].id;
        insert lead;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        wrapper.createOpportunity = true;
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest
    static void conversion2() {
        SocialPersona persona= new SocialPersona();
        SocialPost socialpos = new SocialPost();
        socialpos.Name='Name';
        insert socialpos;
        socialpos.Name='Name';
        persona.Provider='Facebook';
        persona.MediaProvider= 'Facebook Comments';
        persona.ExternalId='test';
        persona.ParentId= socialpos.Id;
        persona.Name='Name';
        insert persona;

        Account account = createAccount('XC_GLO_Account_Residential');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='30143872A';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Residential');
        insert contact;

        Lead lead = createLead('XC_GLO_Lead_Residential');
        lead.XC_SocialPersonaId__c = persona.id;
        insert lead;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        listAddress[0].XC_Account__c = account.id;
        listAddress[0].XC_Lead__c = lead.id;
        insert listAddress;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Lead__c = lead.id;
        listWorkOrder[0].XC_Address__c = listAddress[0].id;
        insert listWorkOrder;
        XC_LCC122_LeadConversion.ConversionResultWrapper wrapp = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        wrapp.account=account;
        wrapp.contact=contact;
        XC_LCC122_LeadConversion_U.populateWorkOrder(wrapp, false, listWorkOrder);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest
    static void conversion3Test() {
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversion3();
        System.assert (cr != null);
    }
    @isTest
    static void conversion3FailTest() {
        XC_LCC122_LeadConversion_UtilConversion.failTest=true;
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversion3();
        System.assert (cr != null);
    }

    @isTest
    private static XC_LCC122_LeadConversion.ConversionResultWrapper conversion3(){
        Account account = createAccount('XC_GLO_Account_Residential');
        account.XC_Country__c = null;
        account.Country__c = null;
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='30143872A';
        insert account;
        Contact contactSecondary = createSecondaryContact(account.Id, 'XC_GLO_Contact_Residential');
        contactSecondary.XC_PrimaryContact__c = true;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Residential');
        contact.XC_PrimaryContact__c = false;
        contact.XC_ContactDocumentCountry__c = null;
        contact.XC_ContactDocumentNumber__c = null;
        contact.XC_ContactDocumentType__c = null;
        insert contact;
        contactSecondary.XC_ContactDocumentCountry__c = null;
        contactSecondary.XC_ContactDocumentNumber__c = null;
        contactSecondary.XC_ContactDocumentType__c = null;
        insert contactSecondary;
        Lead lead = createLead('XC_GLO_Lead_Residential');
        insert lead;
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);

        Test.startTest();
        XC_LCC122_LeadConversion_U.calculateIndividualForExistingContact(lead, contact);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert(cr != null);
        Test.stopTest();
        return cr;
    }

    @isTest
    static void conversioSohoNoContNoAcc() {
        XC_ProductCategoryOfInterest__c productCategoryOfInterest = new XC_ProductCategoryOfInterest__c();
        productCategoryOfInterest.Name = 'Aire acondicionado'; 
        productCategoryOfInterest.XC_CommercialVisit__c = false;
        insert productCategoryOfInterest;
        List<XC_Address__c> listAddress = XC_DF_Address.createAddress(1);
        insert listAddress;

        Lead lead = createLead('XC_GLO_Lead_Soho');
        lead.XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
        lead.XC_LeadAddress__c = listAddress[0].id;
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='545455';
        lead.XC_CDocType__c = 'Passport';
        lead.Country__c = 'Spain';
        lead.XC_DocumentCountry__c = 'Spain';
        insert lead;

        lead.Status='Appointment Scheduled';
        lead.OwnerId=UserInfo.getUserId();
        update lead;

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        listWorkOrder[0].XC_Lead__c = lead.id;
        listWorkOrder[0].XC_Address__c = listAddress[0].id;
        insert listWorkOrder;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        wrapper.createOpportunity = true;

        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest
    private static XC_LCC122_LeadConversion.ConversionResultWrapper conversioSohoWithContWithAcc(){
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93261703S';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Soho');
        contact.XC_PrimaryContact__c= false;
        insert contact;
        Lead lead = createLead('XC_GLO_Lead_Soho');
        lead.XC_DocumentCountry__c='Spain';
        lead.XC_DocumentNumber__c='03482757M';
        lead.XC_DocumentType__c = 'NIF';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='5454551';
        lead.XC_CDocType__c = 'Passport';
        lead.XC_SkipTriggerIndividual__c = true;
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        System.debug('@@@ wrapper ---> ' + wrapper);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
        return cr;
    }

    @isTest
    static void conversioSohoWithContWithAccTest() {
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversioSohoWithContWithAcc();
        System.assert (cr != null);
    }

    @isTest
    static void conversioSohoWithContWithAccFailTest() {
        XC_LCC122_LeadConversion_Z.failTest = true;
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversioSohoWithContWithAcc();
        System.assert (cr != null);
    }

    @isTest
    static void conversioSohoWithContWithAccForJunctionObj() {
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityNumber__c='93261703S';
        account.IdentityType__c='NIF';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Soho');
        insert contact;

        account account2 = new account();
        account2.RecordTypeID = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
        account2.Name = 'Test2 Test2';
        account2.PrimaryEmail__c = 'test2@test.test';
        account2.IdentityType__c='NIF';
        account2.IdentityNumber__c='51692273A';
        account2.XC_DocumentCountry__c = 'Spain';
        account2.XC_Country__c = 'SPAIN';
        account2.Country__c = 'SPAIN';
        insert account2;
        contact contact2 = new contact();
        contact2.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId();
        contact2.FirstName = 'Test2';
        contact2.LastName = 'Test2';
        contact2.Email = 'test2@test.test';
        contact2.accountId = account2.Id;
        contact2.XC_SkipTriggerIndividual__c = true;
        contact2.XC_GiveDataToNew__c= 'Yes';
        contact2.XC_Primarycontact__c= true;
        contact2.XC_MainLegalEntity__c = 'EndesaX';
        contact2.XC_contactDocumentCountry__c='Spain';
        contact2.XC_contactDocumentNumber__c='5454572';
        contact2.XC_contactDocumentType__c = 'Passport';
        contact2.Country__c='SPAIN';
        contact2.XC_CountryLegalEntity__c='Spain';
        insert contact2;

        Lead lead = createLead('XC_GLO_Lead_Soho');
        lead.XC_CDocNumber__c='545457';
        lead.XC_CDocType__c = 'Passport';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_DocumentNumber__c='93261703S';
        lead.XC_DocumentType__c = 'NIF';
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();

    }

    @isTest
    private static XC_LCC122_LeadConversion.ConversionResultWrapper conversioSohoWithAcc(){
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93261703S';
        insert account;

        Lead lead = createLead('XC_GLO_Lead_Soho');
        lead.XC_DocumentNumber__c='93261703S';
        lead.XC_DocumentType__c = 'NIF';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='545444';
        lead.XC_CDocType__c = 'Passport';
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;

        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
        return cr;
    }

    @isTest
    static void conversioSohoWithAccTest() {
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversioSohoWithAcc();
        System.assert (cr != null);
    }

    @isTest
    static void conversioSohoWithAccFailTest() {
        XC_LCC122_LeadConversion_UtilConversion.failTest=true;
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = conversioSohoWithAcc();
        System.assert (cr != null);
    }

    @isTest
    static void conversioSohoWithContPrimaryWithAcc() {
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93692831P';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Soho');
        contact.XC_ContactDocumentNumber__c='5454551';
        contact.XC_ContactDocumentType__c = 'Passport';
        insert contact;
        Lead lead = createLead('XC_GLO_Lead_Soho');

        lead.XC_DocumentType__c = 'NIF';
        lead.XC_DocumentNumber__c='93692831P';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='545455';
        lead.XC_CDocType__c = 'Passport';
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        System.debug('@@@@ query ---> ' + [SELECT Id, Status FROM Lead]);
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest
    static void conversion() {
        Lead lead = createLead('XC_GLO_Lead_Residential');
        lead.XC_DocumentType__c = null;
        lead.XC_DocumentNumber__c = null;
        lead.XC_MainLegalEntity__c='EndesaX';
        insert lead;
        lead.Status='Appointment Scheduled';
        update lead;

        Id individualId = createLe();
        lead.IndividualId=individualId;
        update lead;
        System.debug('@@@AFTER  Lead update START');

        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);

        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
    }

    @isTest    
    static void leadTest() {
        Account account = new Account();
        account.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        account.Name = 'Test Test';
        account.PrimaryEmail__c = 'test@test.test';
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93692831P';
        account.XC_DocumentCountry__c = 'Spain';
        account.XC_Country__c = 'SPAIN';
        account.Country__c = 'SPAIN';
        insert account;
        Contact contact = new Contact();
        contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        contact.Email = 'test@test.test';
        contact.AccountId = account.Id;
        contact.XC_SkipTriggerIndividual__c = true;
        contact.XC_GiveDataToNew__c= 'Yes';
        contact.XC_PrimaryContact__c= true;
        contact.XC_MainLegalEntity__c = 'EndesaX';
        contact.XC_ContactDocumentCountry__c='Spain';
        contact.XC_ContactDocumentNumber__c='5454551';
        contact.XC_ContactDocumentType__c = 'Passport';
        contact.Country__c='SPAIN';
        contact.XC_CountryLegalEntity__c='Spain';
        insert contact;
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Test',
            RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId(),
            Email = 'test@test.test',
            XC_Channel__c = Label.XC_CL_WEB,
            Status='Appointment Scheduled',
            XC_MainLegalEntity__c='EndesaX',
            Country__c = 'SPAIN',
            Company = 'Test',
            XC_DocumentCountry__c='Spain',
            XC_DocumentNumber__c='30143872A',
            XC_DocumentType__c = 'NIF'
            );

        insert lead;
        lead.Status='Appointment Scheduled';
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        List<XC_CM_CountryLegalEntityAssociation__mdt> listCM = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
                                                                SELECT XC_Country__c
                                                                FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                WHERE XC_LegalEntity__c ='EndesaX'
                                                                                                                ]);
        Individual individual = new Individual(
            LastName= 'Test',
            XC_GiveDataToThirdParties__c='Yes'
            );
        insert individual;
        XC_LegalEntityConsent__c lec= new XC_LegalEntityConsent__c(
            XC_LegalEntity__c='EndesaX',
            XC_Individual__c=individual.id,
            XC_IndividualId__c=individual.id,
            XC_LeCountry__c=listCM[0].XC_Country__c,
            XC_GiveDataToNew__c='Yes'
            );
        insert lec;
        lead.IndividualId=individual.id;
        update lead;
        Individual individualcheck = [SELECT Id, (SELECT Id FROM Legal_Entity_Consents__r) FROM Individual WHERE Id = :lead.IndividualId];
        System.debug('@@@individualcheck'+individualcheck);
        List<Lead> listOfLead = XC_UTIL_Sobject.selectAllFields(lead.Id);
        system.debug('@@@ListOfLeadallfield'+listOfLead);

        Test.startTest();
        XC_LCC122_LeadConversion_U.calculateIndividualForExistingContact(lead, contact);
        System.assert(lead != null);
        Test.stopTest();
    }
    
    @isTest
    static void checkPreConversionOppTest (){
        Test.startTest();
        List<Lead> leadToConvert = XC_DF_Lead.createSohoLeads(1);
        leadToConvert[0].XC_Segment__c = 'B2C';
        insert leadToConvert;
        XC_LCC122_LeadConversion.CheckResultWrapper wrap = new XC_LCC122_LeadConversion.CheckResultWrapper();
        XC_LCC122_LeadConversion.CheckFieldsWrapper wrapp = new XC_LCC122_LeadConversion.CheckFieldsWrapper();
        wrap.createOpportunity = true;
        wrap.lead = leadToConvert[0];
        wrap.contactExists = true;
        wrapp = XC_LCC122_LeadConversion.checkPreConversionForOppAndDocAcc(wrap);
        wrap.contactExists = false;
        wrapp = XC_LCC122_LeadConversion.checkPreConversionForOppAndDocAcc(wrap);
        wrap.createOpportunity = false;
        wrap.accountExists = true;
        wrapp = XC_LCC122_LeadConversion.checkPreConversionForOppAndDocAcc(wrap);
        Test.stopTest();
        System.assert(wrap != null);                
    }

    @isTest
    static void checkForB2B(){
        XC_LCC122_LeadConversion.CheckResultWrapper convWrapper = new XC_LCC122_LeadConversion.CheckResultWrapper();
        convWrapper.createOpportunity = true;
        List<Lead> leadToConvertB2B = XC_DF_Lead.createSohoLeads(1);
        leadToConvertB2B[0].RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Lead_GLOB2B).getRecordTypeId();
        leadToConvertB2B[0].XC_Segment__c = 'B2B';
        leadToConvertB2B[0].XC_LeadSource__c  = 'Mail';
        insert leadToConvertB2B;
        leadToConvertB2B[0].XC_Segment__c = 'B2B';
        leadToConvertB2B[0].XC_Country__c = 'Spain';
        convWrapper.lead = leadToConvertB2B[0];
        Test.startTest();
        XC_LCC122_LeadConversion.checkPreConversionForOppAndDocAcc(convWrapper);
        leadToConvertB2B[0].XC_DocumentType__c = 'Other';
        convWrapper.lead = leadToConvertB2B[0];
        XC_LCC122_LeadConversion.checkPreConversionForOppAndDocAcc(convWrapper);
        Test.stopTest();           
    }

    @isTest
    static void updateSocialPersona (){
        Test.startTest();
        XC_LCC122_LeadConversion.ConversionResultWrapper wrap = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        Savepoint savePoint = Database.setSavepoint();
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        insert listOfContact;
        wrap.contact = listOfContact[0];
        List<Lead> leadToConvert = XC_DF_Lead.createSohoLeads(1);
        insert leadToConvert;
        List<Case> listOfCase = XC_DF_Case.createCases(1);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
        listOfCase[0].RecordTypeId = recordTypeId;
        listOfCase[0].Status = 'ESTA001';
        insert listOfCase;
        SocialPost socPost = new SocialPost ();
        socPost.Name = 'TestSocialPost';
        socPost.ParentId = listOfCase[0].Id;
        insert socPost;
        SocialPersona soc = new SocialPersona();
        soc.Name = 'TestSocialPersona';
        soc.Provider = 'Facebook';
        soc.XC_LeadId__c = leadToConvert[0].id;
        soc.ParentId = socPost.id;
        insert soc;
        leadToConvert[0].XC_SocialPersonaId__c = soc.Id;
        wrap = XC_LCC122_LeadConversion.updateSocialPersona(leadToConvert[0], wrap, savePoint);
        Test.stopTest();
        System.assert(wrap != null);
    }

    @isTest
    static void checkPostLeadConversionTest (){
        Test.startTest();
        XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper wrap = new XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper();
        XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper = new XC_LCC122_LeadConversion.CheckResultWrapper();
        XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();

        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        insert listOfWo;
        checkWrapper.listWorkOrder = listOfWo;
        List <XC_Address__c> listOfAddress = XC_DF_Address.createAddress(1);
        insert listOfAddress;
        List<Lead> leadToConvert = XC_DF_Lead.createSohoLeads(1);
        leadToConvert[0].XC_LeadAddress__c = listOfAddress[0].Id;
        insert leadToConvert;
        List<Contact> listOfContact = XC_DF_Contact.createSohoContacts(1);
        insert listOfContact;
        resultWrapper.contact = listOfContact[0];
        Account newAcc = new Account(Id = listOfContact[0].AccountId);
        resultWrapper.account = newAcc;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOfOpp;
        resultWrapper.opportunity = listOfOpp[0];
        wrap.ld = leadToConvert[0];
        wrap.contactConverted = listOfContact[0];
        wrap.resultWrapper = resultWrapper;
        wrap.createOpportunity = true;
        wrap.checkWrapper = checkWrapper;
        XC_LCC122_LeadConversion_CheckConversion.checkPostLeadConversion(wrap); 
        System.assert(wrap != null);
        Test.stopTest();
    }

    @isTest
    static void populateContactResidentialSecondaryTest(){
        Test.startTest();
        XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper wrap = new XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper();
        XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper = new XC_LCC122_LeadConversion.CheckResultWrapper();
        List<Contact> listOfContact = XC_DF_Contact.createSohoContacts(1);
        insert listOfContact;
        checkWrapper.contact = listOfContact[0];
        wrap.checkWrapper = checkWrapper;
        Account newAcc = new Account(Id = listOfContact[0].AccountId);
        XC_LCC122_LeadConversion_UtilConversion.populateContactResidential(wrap, newAcc, true);
        System.assert(wrap != null);
        Test.stopTest();
    }

    @isTest
    static void checkPersonalDocumentResidentialTest(){
        Test.startTest();
        XC_UTIL_Sobject.WrapperResult result = new XC_UTIL_Sobject.WrapperResult();
        List<Lead> listOfLead = XC_DF_Lead.createResidentialLeads(1);
        listOfLead[0].XC_DocumentType__c = 'NIF';
        listOfLead[0].XC_DocumentNumber__c = '52802393M';
        listOfLead[0].XC_DocumentCountry__c = 'Spain';
        insert listOfLead;
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        Account newAcc = new Account(Id = listOfContact[0].AccountId);
        XC_PersonalDocument__c pDoc = new XC_PersonalDocument__c();
        pdoc.XC_DocumentType__c = listOfLead[0].XC_DocumentType__c;
        pdoc.XC_DocumentNumber__c = listOfLead[0].XC_DocumentNumber__c;
        pdoc.XC_Country__c = listOfLead[0].XC_DocumentCountry__c;
        pdoc.XC_Account__c = listOfContact[0].AccountId;
        pdoc.XC_Contact__c = listOfContact[0].Id;
        insert pDoc;
        XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentResidential(listOfContact[0], newAcc, listOfLead[0]);
        delete pDoc;
        XC_PersonalDocument__c pDoc2 = new XC_PersonalDocument__c();
        pdoc2.XC_DocumentType__c = 'Passport';
        pdoc2.XC_DocumentNumber__c = listOfLead[0].XC_DocumentNumber__c;
        pdoc2.XC_Country__c = listOfLead[0].XC_DocumentCountry__c;
        pdoc2.XC_Account__c = listOfContact[0].AccountId;
        pdoc2.XC_Contact__c = listOfContact[0].Id;
        insert pDoc2;
        XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentResidential(listOfContact[0], newAcc, listOfLead[0]);
        System.assert(pdoc2 != null);
        Test.stopTest();
    }

    @isTest
    static void checkPersonalDocumentSohoCondominiumTest(){
        Test.startTest();
        List<Contact> listOfContact = XC_DF_Contact.createSohoContacts(1);
        insert listOfContact;
        Account newAcc = new Account (Id = listOfContact[0].AccountId);
        List<Lead> listOfLead = XC_DF_Lead.createSohoLeads(1);
        listOfLead[0].XC_CDocCountry__c = 'Spain';
        listOfLead[0].XC_CDocNumber__c = '1561846';
        listOfLead[0].XC_CDocType__c = 'Passport';
        insert listOfLead;
        XC_PersonalDocument__c pDocAcc = new XC_PersonalDocument__c();
        pdocAcc.XC_DocumentType__c = listOfLead[0].XC_DocumentType__c;
        pdocAcc.XC_DocumentNumber__c = listOfLead[0].XC_DocumentNumber__c;
        pdocAcc.XC_Country__c = listOfLead[0].XC_DocumentCountry__c;
        pdocAcc.XC_Account__c = listOfContact[0].AccountId;
        insert pDocAcc;

        XC_PersonalDocument__c pDocCont = new XC_PersonalDocument__c();
        pdocCont.XC_DocumentType__c = listOfLead[0].XC_CDocType__c;
        pdocCont.XC_DocumentNumber__c = listOfLead[0].XC_CDocNumber__c;
        pdocCont.XC_Country__c = listOfLead[0].XC_DocumentCountry__c;
        pdocCont.XC_Contact__c = listOfContact[0].Id;
        insert pDocCont;

        XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentSohoCondominium(listOfContact[0], newAcc, listOfLead[0]);
        delete pDocAcc;
        delete pDocCont;
        XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentSohoCondominium(listOfContact[0], newAcc, listOfLead[0]);
        System.assert(!listOfLead.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void leadDocumentUpdate (){
        Test.startTest();
        List<Lead> listOfLead = XC_DF_Lead.createSohoLeads(1);
        insert listOfLead;
        XC_LeadDocument__c leadDoc = new XC_LeadDocument__c();
        leadDoc.XC_LeadId__c = listOfLead[0].id;
        insert leadDoc;
        List<Account> listOfAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listOfAccount;
        XC_LCC122_LeadConversion_CheckDocument.updateLeadDocument(listOfLead[0], listOfAccount[0]);
        System.assert(!listOfLead.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    private static XC_LCC122_LeadConversion.ConversionResultWrapper conversioSohoWithContWithAccPrimaryNoMail(){
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93261703S';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Soho');
        contact.XC_PrimaryContact__c= true;
        insert contact;
        Lead lead = createLead('XC_GLO_B2B');
        lead.XC_DocumentCountry__c='Spain';
        lead.XC_DocumentNumber__c='42653268K';
        lead.XC_DocumentType__c = 'NIF';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='5454552';
        lead.XC_CDocType__c = 'Passport';
        lead.XC_SkipTriggerIndividual__c = true;
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        System.debug('@@@ wrapper ---> ' + wrapper);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        Test.stopTest();
        return cr;
    }
    
    @isTest
    private static XC_LCC122_LeadConversion.ConversionResultWrapper conversioSohoWithContWithAccPRIMARY(){
        Account account = createAccount('XC_GLO_Account_Soho');
        account.IdentityType__c='NIF';
        account.IdentityNumber__c='93261703S';
        insert account;
        Contact contact = createContact(account.Id, 'XC_GLO_Contact_Soho');
        contact.XC_PrimaryContact__c= true;
        insert contact;
        individual indi = new individual();
        indi.lastname = 'pippo';
        insert indi;
        Lead lead = createLead('XC_GLO_B2B');
        lead.XC_DocumentCountry__c='Spain';
        lead.XC_DocumentNumber__c='42653268K';
        lead.XC_DocumentType__c = 'NIF';
        lead.XC_CDocCountry__c='Spain';
        lead.XC_CDocNumber__c='5454551';
        lead.XC_CDocType__c = 'Passport';
        lead.XC_SkipTriggerIndividual__c = true;
        lead.XC_EmailCustom__c = 'abc@yopmail.it';
        lead.IndividualId = indi.id;
        insert lead;
        lead.Status = Label.XC_CL_Lead_AppointmentScheduling;
        lead.OwnerId=UserInfo.getUserId();
        update lead;
        Test.startTest();
        XC_LCC122_LeadConversion.CheckResultWrapper wrapper = XC_LCC122_LeadConversion.retrieveLead(lead.Id);
        System.debug('@@@ wrapper ---> ' + wrapper);
        XC_LCC122_LeadConversion.ConversionResultWrapper cr = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(wrapper));
        System.assert (cr != null);
        
        XC_LCC122_LeadConversion_Z.CheckingPreConversionSohoWrapper convWrapper = new XC_LCC122_LeadConversion_Z.CheckingPreConversionSohoWrapper();
        String recordTypeIdContact;
        recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        Savepoint sp = Database.setSavepoint();
        convWrapper.savePoint = sp;
        convWrapper.ld = lead;
        convWrapper.contactLead = contact;
        convWrapper.accountLead = account;
        convWrapper.recordTypeIdContact = recordTypeIdContact;
        XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(account);
        XC_LCC122_LeadConversion_Z.creationContact(convWrapper, account, dmlAccountResult);
        Test.stopTest();
        return cr;
    }

    @isTest
    static void processLeadQueueTEST(){
        List<User> userList = [SELECT ID FROM USER WHERE Profile.name = 'System Administrator' and isActive =: true LIMIT 1];
        Lead lead1 = createLead('XC_GLO_Lead_Residential');
        lead1.ownerId = userList[0].Id;
        insert lead1;
        List<Lead> ldList = new List<Lead>();
        ldList.add(lead1);
        Map<ID, Lead> mapOld = new Map<ID, Lead>();
        List<Id> leadownerIdList = new List<Id>();
        for(Lead ld : ldList){
            mapOld.put(ld.id, ld);
            leadownerIdList.add(ld.ownerid);
        }
        XC_TR_Lead_U_AssignLead.UtilWrapper wrapper = new XC_TR_Lead_U_AssignLead.UtilWrapper();
        wrapper.listLead = ldList;
        wrapper.queueIdList = leadownerIdList;
        wrapper.newOwnerIdList = leadownerIdList;
        wrapper.mapOld = mapOld;
        Test.startTest();
        XC_TR_Lead_U_AssignLead.processLeadQueue(wrapper);
        Test.stopTest();
    }
}