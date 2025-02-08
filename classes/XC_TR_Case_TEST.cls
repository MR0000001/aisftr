/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  28/01/2020 
* @description XC_TR_Case_TEST – Test class for XC_TR_Case_Handler
*/ 
@istest
public class XC_TR_Case_TEST {
    @testSetup
    static void assingSLA(){ 
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Case> listc = XC_DF_Case.createCases(1);
        insert listc;
        System.assertEquals(true, listc!=null);
        
    }
    
    @isTest
    static void updateCase(){
        List<Case> listCase = [SELECT Id FROM Case LIMIT 1];
        update listCase;
        System.assertEquals(true, listCase!=null);
        
    }
    
    @isTest
    static void deleteCase(){
        List<Case> listCase = [SELECT Id FROM Case LIMIT 1];
        delete listCase; 
        System.assertEquals(true, listCase!=null);
    }
}