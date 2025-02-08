/**
 * Created by snekkanti002 on 24/09/2021.
 */

@IsTest
public with sharing class TestFlowGEDDeleteAttachments {

    @TestSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
    }

    @IsTest
    public static void gedDeleteAttachments() {
        FlowGEDDeleteAttachments.FlowInput input = new FlowGEDDeleteAttachments.FlowInput();

        String caseId = [SELECT Id, AccountId FROM Case LIMIT 1].Id;
        input.caseId = caseId;

        Test.startTest();
        FlowGEDDeleteAttachments.gedDeleteAttachments(new List<FlowGEDDeleteAttachments.FlowInput>{input});
        Test.stopTest();
    }

    @IsTest
    public static void gedDeleteAttachmentsException() {
        FlowGEDDeleteAttachments.FlowInput input = new FlowGEDDeleteAttachments.FlowInput();

        String caseId = [SELECT Id, AccountId FROM Case LIMIT 1].Id;
        input.caseId = caseId;

        Test.startTest();
        FlowGEDDeleteAttachments.gedDeleteAttachments(null);
        Test.stopTest();
    }
}