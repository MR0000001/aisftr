/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestBatchGEDContentVersion {
    @TestSetup
    public static void setup() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void batchGEDContentVersion() {
        TestDataFactory.createGedCaseBatchSettings();

        List<Case> cases = [SELECT Id, DateTimeProtocol__c, ProtocolCFUser__c, ID_Protocollo__c, YearProtocol__c, Protocol_Number__c, COD_SIS__c, COD_DOC__c FROM Case];

        Test.startTest();
        BatchGEDContentVersion batch = new BatchGEDContentVersion();
        Database.executeBatch(batch, 200);
        batch.execute(null, cases);

        Test.stopTest();
    }

    @IsTest
    public static void batchGEDContentVersionException() {
        List<Case> cases = [SELECT Id, DateTimeProtocol__c, ProtocolCFUser__c, ID_Protocollo__c, YearProtocol__c, Protocol_Number__c, COD_SIS__c, COD_DOC__c FROM Case];

        Test.startTest();
        BatchGEDContentVersion batch = new BatchGEDContentVersion();
        Database.executeBatch(batch, 200);
        batch.execute(null, cases);

        Test.stopTest();
    }
}