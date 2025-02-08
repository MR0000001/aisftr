/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  27/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_UTIL_ResultWrapper_TEST {
    //Test Method XC_UTIL_ResultWrapper
    static testMethod void XC_UTIL_ResultWrapper(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();        
        
        
        System.assertEquals(true, wr!=null);
        Test.stopTest();
        
    }
    
    //Test Method XC_UTIL_ResultWrapper
    static testMethod void XC_UTIL_ResultWrapper1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(true);
        
        
        
        
        System.assertEquals(true, wr!=null);
        Test.stopTest();
        
    }
    
    
    
    
    //Test Method XC_UTIL_ResultWrapper
    static testMethod void XC_UTIL_ResultWrapper2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        
        XC_UTIL_Sobject.WrapperResult sobjectResult  = new XC_UTIL_Sobject.WrapperResult();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(sobjectResult);
        
        
        System.assertEquals(true, wr!=null);
        Test.stopTest();
        
    }
    
    
    
    //Test Method XC_UTIL_ResultWrapper 
    static testMethod void XC_UTIL_ResultWrapper3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        list <Account> lstacc = XC_DF_Account.createCondominiumAccounts(1);
        XC_LCC002_NewLead_W.InsertResultWrapper insertWr = new XC_LCC002_NewLead_W.InsertResultWrapper(lstacc[0].Id);
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(insertWr);
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    } 
    
    
}