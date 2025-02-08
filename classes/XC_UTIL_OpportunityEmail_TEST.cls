/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_UTIL_OpportunityEmail_TEST – Test class for XC_UTIL_OpportunityEmail 
*/
@istest
public class XC_UTIL_OpportunityEmail_TEST{
    
    //Test Method createOpportunity
    static testMethod void createOpportunity(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        List<String> attachmentList = new List<String>();
        emailMessage emailToSend= new emailMessage();
        emailToSend.ToAddress= 'test@mail.com';
        emailToSend.BccAddress= 'test2@mail.com';
        emailToSend.TextBody= 'Test';
        
        string st = XC_UTIL_OpportunityEmail.sendMail(emailToSend, attachmentList);
        
        System.assertEquals(true, st!=null);
        Test.stopTest();
        
    }
    
    
    
}