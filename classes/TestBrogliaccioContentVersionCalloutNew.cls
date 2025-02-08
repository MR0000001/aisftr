/**
 * Created by snekkanti002 on 21/11/2021.
 */

@IsTest
public with sharing class TestBrogliaccioContentVersionCalloutNew {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        TestDataFactory.createContentVersions(cases);
    }

    @IsTest
    public static void brogliaccioContentVersionCalloutTest() {
        List<Case> cases = [
                SELECT Id,Start_Day_Access__c,Finish_Day_Access__c,CaseNumber,License_plate__c,Is_Person_Account_Account_on_Case__c, Concession_Number__c,Concession_Municipality__c,ID_Comune__c,Account.FirstName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c, Number_Address__c, Letter_Address__c, CreatedDate, Description, Account.LastName, Status, Case_Action__c, Account.Fiscal_Code__pc, Account.IsPersonAccount, Contact.Fiscal_Code_contact__c, Strada_KO__c, Sub_Status__c, Integration_Update_From_WSO2__c, ExternalSystemId_AMALV__c, Case_Specification__c, Account.Name, ContactMobile, Geolocation__Latitude__s, Geolocation__Longitude__s, Subject, Sent_to_External__c, ExternalSystemId_Brogliaccio__c, All_Content_Versions_Integrated__c, checkAnonymous__c, Current_Queue__c, Comment_User__c
                FROM Case
        ];

        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapperNew = TestDataFactory.createBrogliaccioCaseListWrapperNew(true, cases);

        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioContentVersionNew(true));

        Test.startTest();
        BrogliaccioContentVersionCalloutNew.brogliaccioContentVersionCallout(brogliaccioCaseListWrapperNew);
        Test.stopTest();
    }

    @IsTest
    public static void brogliaccioContentVersionCalloutKOTest() {
        List<Case> cases = [
                SELECT Id,Start_Day_Access__c,Finish_Day_Access__c,CaseNumber,License_plate__c,Is_Person_Account_Account_on_Case__c, Concession_Number__c,Concession_Municipality__c,ID_Comune__c,Account.FirstName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c, Number_Address__c, Letter_Address__c, CreatedDate, Description, Account.LastName, Status, Case_Action__c, Account.Fiscal_Code__pc, Account.IsPersonAccount, Contact.Fiscal_Code_contact__c, Strada_KO__c, Sub_Status__c, Integration_Update_From_WSO2__c, ExternalSystemId_AMALV__c, Case_Specification__c, Account.Name, ContactMobile, Geolocation__Latitude__s, Geolocation__Longitude__s, Subject, Sent_to_External__c, ExternalSystemId_Brogliaccio__c, All_Content_Versions_Integrated__c, checkAnonymous__c, Current_Queue__c, Comment_User__c
                FROM Case
        ];

        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapperNew = TestDataFactory.createBrogliaccioCaseListWrapperNew(true, cases);

        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioContentVersionNew(false));

        Test.startTest();
        BrogliaccioContentVersionCalloutNew.brogliaccioContentVersionCallout(brogliaccioCaseListWrapperNew);
        Test.stopTest();
    }

    @IsTest
    public static void contentVersionSelectorTest() {
        List<String> caseIds = new List<String>();
        List<String> contentDocumentIdIds = new List<String>();

        for(Case c : [SELECT id FROM Case]) caseIds.add(c.Id);

        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion]) contentDocumentIdIds.add(cv.ContentDocumentId);

        ContentVersionSelector.getContentVersionsByCaseIds(caseIds);
        ContentVersionSelector.getContentVersionsGEDByDocIds(contentDocumentIdIds);
    }
}