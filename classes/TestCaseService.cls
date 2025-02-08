/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@IsTest
public with sharing class TestCaseService {
    @TestSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
        List<Case> brogliaccioCases = TestDataFactory.createCasesBrogliaccioPull();
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createGroups();
        TestDataFactory.createBatchPullSettings();
        TestDataFactory.createBrogliaccioBatchSettings();
        TestDataFactory.createContentVersions(brogliaccioCases);
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
        TestDataFactory.createOrgManagementSettings();
    }

    @IsTest
    public static void caseSeriveTest() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<Case> casesOld = TestDataFactory.createCasesWithoutCities();
        List<User> users = TestDataFactory.createWSOUsers();

        Map<Id, Case> oldCases = new Map<Id, Case>();
        oldCases.put(cases[0].Id, casesOld[0]);
        oldCases.put(cases[1].Id, casesOld[1]);
        oldCases.put(cases[2].Id, casesOld[2]);
        cases[0].Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2014, 11, 12), Time.newInstance(3, 3, 3, 0));
        cases[0].Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2016, 11, 12), Time.newInstance(3, 3, 3, 0));
        update cases;

        Test.startTest();
        CaseService.TriggerHandler(cases, null);
        CaseService.TriggerHandler(cases, oldCases);
        System.runAs(users[0]) {
            CaseService.splitAddress(cases);
        }
        CaseService.updateCases(cases, false);
        CaseService.deleteCases(cases, false);
        Test.stopTest();
    }

    @IsTest
    public static void updateCasesForEmailExternal() {
        List<String> caseIds = new List<String>();
        for(Case c : [SELECT Id FROM Case]) caseIds.add(c.Id);

        Test.startTest();
        CaseService.updateCasesForEmailExternal(caseIds, false);
        Test.stopTest();
    }

    @IsTest
    public static void processBrogliaccioPullTest1() {
        List<Case> cases = [SELECT ExternalSystemId_Brogliaccio__c, Last_Batch_Date_Time__c FROM Case WHERE ExternalSystemId_Brogliaccio__c != NULL];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioPull('2'));
        CaseService.processBrogliaccioPull(cases);
        Test.stopTest();
    }

    @IsTest
    public static void processBrogliaccioPullTest2() {
        List<Case> cases = [SELECT ExternalSystemId_Brogliaccio__c, Last_Batch_Date_Time__c FROM Case WHERE ExternalSystemId_Brogliaccio__c != NULL];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioPull('6'));
        CaseService.processBrogliaccioPull(cases);
        Test.stopTest();
    }

    @IsTest
    public static void processBrogliaccioPullTest3() {
        List<Case> cases = [SELECT ExternalSystemId_Brogliaccio__c, Last_Batch_Date_Time__c FROM Case WHERE ExternalSystemId_Brogliaccio__c != NULL];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioPull('5'));
        CaseService.processBrogliaccioPull(cases);
        Test.stopTest();
    }

    @IsTest
    public static void getBrogliaccioCustomSettingsAndQueue() {
        Test.startTest();
        CaseService.getBrogliaccioCustomSettingsAndQueue();
        Test.stopTest();
    }

    @IsTest
    public static void setCaseFieldsForBrogliaccioNew() {
        List<Case> cases = [SELECT Status, ExternalSystemId_Brogliaccio__c, Sent_to_External__c, Current_Queue__c, Comment_User__c, Last_Batch_Date_Time__c FROM Case WHERE ExternalSystemId_Brogliaccio__c != NULL];
        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper = new BrogliaccioCaseListWrapperNew(false, cases);
        brogliaccioCaseListWrapper.caseIdExternalStatusOldMap = new Map<String, String>();
        brogliaccioCaseListWrapper.caseIdCvCount = new Map<String, Integer>();

        Test.startTest();
        CaseService.setCaseFieldsForBrogliaccioNew(brogliaccioCaseListWrapper);
        Test.stopTest();
    }

    @IsTest
    public static void processBrogliaccioUpdateAttachment() {
        List<String> cvIds = new List<String>();

        for(ContentVersion cv : [SELECT Id FROM ContentVersion]) {
            cvIds.add(cv.Id);
        }

        Test.startTest();
        CaseService.processBrogliaccioUpdateAttachment(cvIds);
        Test.stopTest();
    }

    @IsTest
    public static void processGEDDeleteAttachments() {
        List<String> caseIds = new List<String>();

        for(Case c : [SELECT ExternalSystemId_Brogliaccio__c, Brogliaccio_DescriptioError__c, Sent_to_External__c, Current_Queue__c, Comment_User__c, Last_Batch_Date_Time__c FROM Case WHERE ExternalSystemId_Brogliaccio__c != NULL]) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        CaseService.processGEDDeleteAttachments(caseIds);
        Test.stopTest();
    }

    @IsTest
    public static void updateCaseFieldsOnNewContentVersions() {
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

        List<Case> cases = [SELECT Id, All_Content_Versions_Integrated_GED__c, ProtocolCFUser__c FROM Case];

        List<ContentVersion> contentVersions = [SELECT Id, CreatedDate, ContentSize FROM ContentVersion];

        for(Case c : cases) {
            caseIdCvsMap.put(c.Id, contentVersions);
        }

        Test.startTest();
        CaseService.updateCaseFieldsOnNewContentVersions(caseIdCvsMap);
        Test.stopTest();
    }

    @IsTest
    public static void updateCaseFieldsOnDeleteContentVersions() {
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();

        List<Case> cases = [SELECT Id, All_Content_Versions_Integrated_GED__c, ProtocolCFUser__c FROM Case];

        List<ContentVersion> contentVersions = [SELECT Id, CreatedDate, ContentSize FROM ContentVersion];

        for(Case c : cases) {
            caseIdCvsMap.put(c.Id, contentVersions);
        }

        Test.startTest();
        CaseService.updateCaseFieldsOnDeleteContentVersions(caseIdCvsMap, contentVersions);
        Test.stopTest();
    }

    @IsTest
    public static void setCaseFieldsGEDCase() {
        Map<String, Case> caseIdCaseMap = new Map<String, Case>();

        List<Case> cases = [SELECT Id, Last_Batch_Date_Time_GED__c, Status, All_Content_Versions_Integrated_GED__c, ProtocolCFUser__c FROM Case];

        for(Case c : cases) {
            caseIdCaseMap.put(c.Id, c);
        }

        List<ResponseGEDCase.ListaNumeroProtollo> listaNumeroProtollos = new List<ResponseGEDCase.ListaNumeroProtollo>();
        ResponseGEDCase.ListaNumeroProtollo listaNumeroProtollo = new ResponseGEDCase.ListaNumeroProtollo();

        listaNumeroProtollo.id = cases[0].Id;
        listaNumeroProtollo.error = new ResponseGEDCase.Error();
        listaNumeroProtollo.error.errorCode = '000';
        listaNumeroProtollo.tipoProtocollo = '1234';
        listaNumeroProtollo.annoProtocollo = 2000;
        listaNumeroProtollo.progressivoProtocollo = 2000;
        listaNumeroProtollo.codiceMittente = 'Random';
        listaNumeroProtollo.dataProtocollo = 1632700900000L;
        listaNumeroProtollo.oraProtocollo = 591221L;

        listaNumeroProtollos.add(listaNumeroProtollo);

        Test.startTest();
        CaseService.setCaseFieldsGEDCase(listaNumeroProtollos,caseIdCaseMap);
        Test.stopTest();
    }

    @IsTest
    public static void getCaseIdCaseMap() {
        List<Case> cases = [SELECT Id, Last_Batch_Date_Time__c, Status, All_Content_Versions_Integrated_GED__c, ProtocolCFUser__c FROM Case];

        Test.startTest();
        CaseService.getCaseIdCaseMap(cases);
        Test.stopTest();
    }

    @IsTest
    public static void processGEDCases() {
        List<Case> cases = [SELECT CaseNumber, Account.Gender__pc, Account.FirstName, Account.LastName, Account.Name, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.Fiscal_Code__pc, Account.PersonOtherPostalCode, Account.PersonOtherCity, Account.PersonOtherState, Last_Batch_Date_Time__c, Status, All_Content_Versions_Integrated_GED__c, ProtocolCFUser__c, Subject, DOC_LOGIC__c, COD_SIS__c, COD_DOC__c, Case_Business_Account__c, Persona_Fisica__c, Persona_Fisica__r.PersonBirthdate FROM Case];

        Test.startTest();
        CaseService.processGEDCases(cases);
        Test.stopTest();
    }

    @IsTest
    public static void processGEDUpdateAttachment() {
        List<String> contentVersionIds = new List<String>();

        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];

        for(ContentVersion cv : contentVersions) {
            contentVersionIds.add(cv.Id);
        }

        Test.startTest();
        CaseService.processGEDUpdateAttachment(contentVersionIds);
        Test.stopTest();
    }
}