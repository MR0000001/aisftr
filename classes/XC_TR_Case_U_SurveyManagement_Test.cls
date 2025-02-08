/*
* @author Marco Ottaviano mottaviano@deloitte.it
* @date Creation 22/10/2019
* @description Test Class for XC_TR_Case_U_SurveyManagement //
*/

@isTest
public without sharing class XC_TR_Case_U_SurveyManagement_Test {
    @TestSetup
    static void makeData(){
      /* List<Account> accountTosinert=XC_DF_Account.createResidentialAccounts(1);
        insert accountTosinert;
        List<Contact> contactToInsert = XC_DF_Contact.createResidentialContacts(accountTosinert);
        insert contactToInsert;
        */
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_GetFeedbackResponse__c survey = new XC_GetFeedbackResponse__c();
        survey.Name='test1';
        survey.XC_Question1__c='Come ti chiami?';
        survey.XC_Answer1__C='Marco';
        survey.XC_QuestionId1__c='NOME';
        survey.XC_SurveyId__c='externalId01';
        insert survey;
    }

    @isTest
    static void test_one() {
        
       Case caseToinsert=XC_DF_Case.createCaseFromType('XCMOT007','ATCL040',null);
       casetoInsert.Status='ESTA001';
        caseToinsert.Origin='CAN002';
        caseToinsert.XC_SurveyExID__c =[SELECT XC_SurveyId__c FROM XC_GetFeedbackResponse__c LIMIT 1].XC_SurveyId__c;
        Test.startTest();
            insert caseToinsert;
            
        Test.stopTest();

        System.assertEquals(String.valueof([SELECT XC_SurveyId__c FROM CASE LIMIT 1].XC_SurveyId__c),String.valueof([SELECT ID FROM XC_GetFeedbackResponse__c LIMIT 1].Id) );
    }

    @isTest
    static void setLegalEntityFromSurveyContact(){
    	List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> contNew = XC_DF_Contact.createResidentialContacts(acc);
        insert contNew;
        
        XC_GetFeedbackResponse__c survey2 = new XC_GetFeedbackResponse__c();
        survey2.Name='test1';
        survey2.XC_Question1__c='Come ti chiami?';
        survey2.XC_Answer1__C='Marco';
        survey2.XC_QuestionId1__c='NOME';
        survey2.XC_SurveyId__c='test_externalId02';
        survey2.XC_Contact__c = contNew[0].Id;
        insert survey2;
        List<XC_GetFeedbackResponse__c> gfResp = [SELECT Id, XC_SurveyId__c FROM XC_GetFeedbackResponse__c WHERE XC_SurveyId__c = 'test_externalId02' LIMIT 1];
        update gfResp;
        
       	Case caseToinsert = XC_DF_Case.createCaseFromType('XCMOT007','ATCL040', null);
       	casetoInsert.Status='ESTA001';
       	caseToinsert.Origin='CAN002';
       	caseToinsert.XC_SurveyExID__c = 'test_externalId02'; //[SELECT XC_SurveyId__c FROM XC_GetFeedbackResponse__c LIMIT 1].XC_SurveyId__c;
        
       	Test.startTest();
        	List<XC_UTIL_Sobject.WrapperResult> dmlRes = XC_UTIL_DML.insertRecords(new List<Case>{caseToinsert});
       	Test.stopTest();
        Case caso = [SELECT XC_LegalEntity__c FROM Case WHERE Id =: dmlRes[0].recordId LIMIT 1];
       	System.assertEquals(caso.XC_LegalEntity__c, 'EndesaX');
    }
    
    @isTest
    static void populateCustomerInteraction(){
        Case caseToinsert = XC_DF_Case.createCaseFromType('XCMOT007','ATCL040', null);
        Map<Id, Case> mapOld = new Map<Id, Case>();
        Map<Id, Case> mapNew = new Map<Id, Case>();
        Test.startTest();
        XC_TR_Case_U_SurveyManagement.populateCustomerInteraction(caseToinsert);
        XC_TR_Case_U_SurveyManagement.interactionForChangeMOP( mapOld,   mapNew);
        Test.stopTest();
    }
}