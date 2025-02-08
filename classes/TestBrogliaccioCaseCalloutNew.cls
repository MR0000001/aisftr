/**
 * Created by snekkanti002 on 27/09/2021.
 */
@isTest
public with sharing class TestBrogliaccioCaseCalloutNew {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createBrogliaccioBatchSettings();
        TestDataFactory.createGroups();

        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        List<ContentVersion> contentVersions = TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> contentDocumentLinks = TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @isTest
    public static void brogliaccioCaseCalloutTest() {
        List<Case> cases = [SELECT Id, Last_Batch_Date_Time__c, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, Street_Address__c, Number_Address__c, Account.Name, ContactMobile, To_be_sent_Brogliaccio__c, All_Content_Versions_Integrated__c, Geolocation__Latitude__s, Sent_to_External__c, Geolocation__Longitude__s, Subject, Current_Queue__c, Comment_User__c, Brogliaccio_N_Attachment__c, Brogliaccio_DescriptioError__c FROM Case];

        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper = new BrogliaccioCaseListWrapperNew(false, cases);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioCase(cases[2].Id, ''));
        BrogliaccioCaseCalloutNew.brogliaccioCaseCallout(brogliaccioCaseListWrapper);
        Test.stopTest();
    }
}