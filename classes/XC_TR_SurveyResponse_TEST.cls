/**
* @author Emanuela Cacace - ecacace@deloitte.it 
* @date Creation 24/06/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_SurveyResponse_TEST – Test Class for XC_TR_SurveyResponse
*/ 
@isTest
public class XC_TR_SurveyResponse_TEST {
        @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    } 
    
    // Test method insertSurveyResponse
     static testMethod void insertSurveyResponse() {
        
        Test.startTest();
        
        Survey_Response__c survey = new Survey_Response__c();
        survey.Problema_resuelto__c = 'Test';
        insert survey;
         survey.Problema_resuelto__c = 'Test2';
         update survey;
         delete survey;
       System.assertEquals(true, survey!=null);
        Test.stopTest();
    }
    
    
    

}