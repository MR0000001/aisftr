/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC034_EditOrderPracticeNumber_TEST – Test class for XC_LCC034_EditOrderPracticeNumber
*/
@isTest
public class XC_LCC034_EditOrderPracticeNumber_TEST {
     //Test Method updateOrderPracticeNumber
    static testMethod void updateOrderPracticeNumber(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        NE__Order__c o = new NE__Order__c();
        o.NE__Delivery_Date__c = Date.today();
        insert o;
    
        
        
        
        XC_UTIL_ResultWrapper rw = XC_LCC034_EditOrderPracticeNumber.updateOrderPracticeNumber (o.Id, 'test');
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
     //Test Method checkFinancialApprovalValue
    static testMethod void checkFinancialApprovalValue(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        NE__Order__c o = new NE__Order__c(); 
        o.NE__Delivery_Date__c = Date.today();
        insert o;
        
        XC_UTIL_ResultWrapper rw = XC_LCC034_EditOrderPracticeNumber.checkFinancialApprovalValue (o.Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    } 

}