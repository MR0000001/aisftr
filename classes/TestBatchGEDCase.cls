/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestBatchGEDCase {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void batchGEDCase() {
        TestDataFactory.createGedCaseBatchSettings();

        List<String> caseIds = new List<String>();
        List<Case> cases = [SELECT CaseNumber, ToBeSentGED__c, Protocol_Number__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time_GED__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Case_Business_Account__c, Account.Gender__pc, Account.Account_Fiscal_Code__c, Account.Partita_IVA__c, Account.Email_Account__c, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.BillingState, Account.FirstName, Account.LastName, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Persona_Fisica__r.PersonBirthdate, Subject, ID_Protocollo__c, YearProtocol__c FROM Case];
        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGEDCase(caseIds));
        BatchGEDCase batch = new BatchGEDCase();
        Database.executeBatch(batch, 200);
        batch.execute(null, cases);

        System.schedule('TestBatchGEDCase', '0 17 * ? * * *', batch);
        Test.stopTest();
    }

    @IsTest
    public static void batchGEDCaseException() {

        List<String> caseIds = new List<String>();
        List<Case> cases = [SELECT CaseNumber FROM Case];
        for(Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGEDCase(caseIds));
        BatchGEDCase batch = new BatchGEDCase();
        Database.executeBatch(batch, 200);
        batch.execute(null, cases);

        System.schedule('TestBatchGEDCase', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}