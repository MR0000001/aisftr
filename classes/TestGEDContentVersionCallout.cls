/**
 * Created by snekkanti002 on 28/07/2021.
 */

@IsTest
public with sharing class TestGEDContentVersionCallout {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void gedContentVersionCallout() {
        List<Case> cases = [SELECT Id, ProtocolCFUser__c, ID_Protocollo__c, YearProtocol__c, Protocol_Number__c, COD_SIS__c, COD_DOC__c FROM Case];
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion];

        Map<Case, List<ContentVersion>> caseCvsMap = ContentVersionService.getCaseCvsMap(cases);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGEDContentVersionCallout());

        Test.startTest();
        GEDContentVersionCallout.gedContentVersionCallout(caseCvsMap);
        Test.stopTest();
    }
}