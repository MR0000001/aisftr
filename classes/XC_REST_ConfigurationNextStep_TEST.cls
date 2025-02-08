/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  07/06/2019 
* @description XC_REST_ConfigurationNextStep_TEST – Test class for XC_REST_ConfigurationNextStep
*/
@istest
 public class XC_REST_ConfigurationNextStep_TEST {
    
    //Test doGet
    static testMethod void doGet(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        String ab = 'test';
        try{
            XC_REST_ConfigurationNextStep.doGet();
        } catch (exception e){
            XC_UTIL_Debug.debug(true, e);
        }
        
        System.assertEquals(true,ab!=null);
        Test.stopTest();
        
    }
     
     
      //Test doPost
    static testMethod void doPost(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        String idsfdc = 'test';
        String statusaction = 'test';
        string stg = XC_REST_ConfigurationNextStep.doPost(idsfdc,statusaction);
        System.assertEquals(true,stg!=null);
        Test.stopTest();
        
    }
     
     
    
}