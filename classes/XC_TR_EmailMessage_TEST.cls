/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  06/02/2020 
* @description XC_TR_EmailMessage_TEST – Test class for XC_TR_EmailMessage_Handler
*/ 
@isTest
public class XC_TR_EmailMessage_TEST {

    @isTest
    static void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Case> cs = XC_DF_Case.createCases(1);
        insert cs;
        EmailMessage email = new EmailMessage();
        email.Incoming= true;  
        email.ParentId = cs[0].id;
        insert email;
        Test.stopTest();
        System.assertEquals(true, email.Incoming);
    }
    
     @isTest
    static void updateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.Incoming= true;  
        insert email;
        email.FromAddress= 'salvatore.scarpato@nttdata.com'; 
        update email;
        Test.stopTest();
        System.assertEquals(true, email.Incoming);
    }
    
    @isTest
    static void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.Incoming= true;  
        insert email;
        delete email;
        Test.stopTest();
        System.assertEquals(true, email.Incoming);
    }
}