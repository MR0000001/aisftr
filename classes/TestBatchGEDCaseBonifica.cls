/**
 * Created by snekkanti002 on 13/06/2022.
 */

@IsTest
public with sharing class TestBatchGEDCaseBonifica {
    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void execute() {
        TestDataFactory.createGedCaseBatchSettings();

        List<Case> cases = [SELECT ToBeSentGED__c, Protocol_Number__c, YearProtocol__c, ID_Protocollo__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Account.Gender__pc, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Subject FROM Case];

        Test.startTest();
        try {
            BatchGEDCaseBonifica batch = new BatchGEDCaseBonifica();
            Database.executeBatch(batch, 200);
            batch.execute(null, cases);

            System.schedule('BatchGEDCaseBonifica', '0 00 * ? * *', new BatchGEDCaseBonifica());
        } catch(Exception e) {
            System.debug('Exception : ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void executeException() {
        List<Case> cases = [SELECT ToBeSentGED__c, Protocol_Number__c, YearProtocol__c, ID_Protocollo__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Account.Gender__pc, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Subject FROM Case];

        Test.startTest();
        try {
            BatchGEDCaseBonifica batch = new BatchGEDCaseBonifica();
            Database.executeBatch(batch, 200);
            batch.execute(null, cases);

            System.schedule('BatchGEDCaseBonifica', '0 00 * ? * *', new BatchGEDCaseBonifica());
        } catch(Exception e) {
            System.debug('Exception : ' + e.getMessage());
        }
        Test.stopTest();
    }
}