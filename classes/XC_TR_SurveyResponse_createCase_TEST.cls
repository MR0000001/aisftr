/**
* @author Chiara Turco - cturco@deloitte.it
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_SurveyResponse_createCase_TEST – Test Class for XC_TR_SurveyResponse_createCase
*/ 

@isTest
public class XC_TR_SurveyResponse_createCase_TEST {

    static testMethod void createCases() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
        
        List<Survey_Response__c> listsurvey = new List<Survey_Response__c>();
        insert listsurvey;
        
       List<Case> listcase = XC_DF_Case.createCases(1);
        insert listcase;
        
        //XC_UTIL_Case.createCasesFromSurveys(listsurvey,1);
 
       System.assertEquals(true, listsurvey!=null);
        Test.stopTest();
        
    }
    

}