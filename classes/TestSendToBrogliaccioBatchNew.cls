/**
 * Created by snekkanti002 on 27/09/2021.
 */

@IsTest
public with sharing class TestSendToBrogliaccioBatchNew {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createGroups();

        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersions();
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        TestDataFactory.createContentDocumentLinks(contentDocuments, cases);
    }

    @IsTest
    public static void sendToBrogliaccioBatchTest() {
        TestDataFactory.createBrogliaccioBatchSettings();

        List<Case> cases = [SELECT Id, Last_Batch_Date_Time__c, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, Street_Address__c, Number_Address__c, Account.Name, ContactMobile, To_be_sent_Brogliaccio__c, All_Content_Versions_Integrated__c, Geolocation__Latitude__s, Sent_to_External__c, Geolocation__Longitude__s, Subject, Current_Queue__c, Comment_User__c, Brogliaccio_N_Attachment__c, Brogliaccio_DescriptioError__c FROM Case];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioCase(cases[2].Id, ''));
        Database.executeBatch(new SendToBrogliaccioBatchNew(), 50);
        SendToBrogliaccioBatchNew sendToBrogliaccioBatchNew = new SendToBrogliaccioBatchNew();
        sendToBrogliaccioBatchNew.execute(null, cases);
        System.schedule('TestSendToBrogliaccioBatchNew', '0 17 * ? * * *', new SendToBrogliaccioBatchNew());
        Test.stopTest();
    }

    @IsTest
    public static void sendToBrogliaccioBatchTestException() {
        List<Case> cases = [SELECT Id, Last_Batch_Date_Time__c, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, Street_Address__c, Number_Address__c, Account.Name, ContactMobile, To_be_sent_Brogliaccio__c, All_Content_Versions_Integrated__c, Geolocation__Latitude__s, Sent_to_External__c, Geolocation__Longitude__s, Subject, Current_Queue__c, Comment_User__c, Brogliaccio_N_Attachment__c, Brogliaccio_DescriptioError__c FROM Case];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioCase(cases[2].Id, ''));
        Database.executeBatch(new SendToBrogliaccioBatchNew(), 50);
        SendToBrogliaccioBatchNew sendToBrogliaccioBatchNew = new SendToBrogliaccioBatchNew();
        sendToBrogliaccioBatchNew.execute(null, cases);
        System.schedule('TestSendToBrogliaccioBatchNew', '0 17 * ? * * *', new SendToBrogliaccioBatchNew());
        Test.stopTest();
    }
}