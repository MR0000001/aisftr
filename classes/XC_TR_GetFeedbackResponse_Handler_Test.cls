/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella - fmelella@deloitte.it
* @date Creation 26/09/2019
* @date Modification 
* @description  Test Class of  XC_TR_GetFeedbackResponse_Handler
*/

@isTest
public with sharing class XC_TR_GetFeedbackResponse_Handler_Test {

    
    @isTest
    public static void insertOfSurvey() {
        XC_GetFeedbackResponse__c survey = new XC_GetFeedbackResponse__c();
        survey.Name='test1';
        survey.XC_Question1__c='Come ti chiami?';
        survey.XC_Answer1__C='Marco';
        survey.XC_QuestionId1__c='NOME';

        Test.startTest();
            insert survey;
            System.assertEquals(survey.Name,'test1');
        Test.stopTest();
    }

     @isTest
    public static void resumeSurvey() {
        XC_GetFeedbackResponse__c survey = new XC_GetFeedbackResponse__c();
        survey.Name='test1';
        survey.XC_Question1__c='Come ti chiami?';
        survey.XC_Answer1__C='Marco';
        survey.XC_QuestionId1__c='NOME';
        insert survey;

        Test.startTest();
           XC_GetFeedbackResponse__c surveyMod=[SELECT Id,XC_Answer1__C,XC_Question2__c,XC_Answer2__C,XC_QuestionId2__c,Name FROM XC_GetFeedbackResponse__c WHERE Name='test1' LIMIT 1];

            surveyMod.XC_Answer1__C ='Federico';
            surveyMod.XC_Question2__c='Eta?';
            surveyMod.XC_Answer2__C='26';
            surveyMod.XC_QuestionId2__c='ETA';
            update surveyMod;
            System.assertEquals(surveyMod.Name,'test1');
        Test.stopTest();
    }

      @isTest
    public static void deleteSurvey() {
        XC_GetFeedbackResponse__c survey = new XC_GetFeedbackResponse__c();
        survey.Name='test1';
        survey.XC_Question1__c='Come ti chiami?';
        survey.XC_Answer1__C='Marco';
        survey.XC_QuestionId1__c='NOME';
        insert survey;

        Test.startTest();
           XC_GetFeedbackResponse__c surveyMod=[SELECT Id,XC_Answer1__C,XC_Question2__c,XC_Answer2__C,XC_QuestionId2__c,Name FROM XC_GetFeedbackResponse__c WHERE Name='test1' LIMIT 1];

            Database.delete(surveyMod);
        Test.stopTest();
    }
}