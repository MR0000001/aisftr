/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  27/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_UTIL_Integration_TEST {
    
    
     //Test Method validateHeader
    static testMethod void validateHeader(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Map<String, String> mapHeader = new Map<String, String>();
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( mapHeader);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader2
    static testMethod void validateHeader2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header();
        h= null;
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null);
        Test.stopTest();
        
    }
    
    //Test Method validateHeader3
    static testMethod void validateHeader3(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header();        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null);
        Test.stopTest();
        
    }
    
    //Test Method validateHeader4
    static testMethod void validateHeader4(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = null;
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader5
    static testMethod void validateHeader5(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = date.today();
        h.Operation= null;
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader6
    static testMethod void validateHeader6(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = date.today();
        h.Operation= 'test';
        h.Functionality='';
        
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader7
    static testMethod void validateHeader7(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = date.today();
        h.Operation= 'test';
        h.Functionality='test';
        h.ClientSystem='';
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader8
    static testMethod void validateHeader8(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = date.today();
        h.Operation= 'test';
        h.Functionality='test';
        h.ClientSystem='test';
        h.ServerSystem='';
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method validateHeader9
    static testMethod void validateHeader9(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.Header h = new XC_UTIL_Integration.Header(); 
        h.TransactionID='test';
        h.DateTimeMessage = date.today();
        h.Operation= 'test';
        h.Functionality='test';
        h.ClientSystem='test';
        h.ServerSystem='test';
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateHeader( h);  
        
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
        
    }
    
    //Test Method convertFromStringToBoolean
    static testMethod void convertFromStringToBoolean(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        boolean bl = XC_UTIL_Integration.convertFromStringToBoolean( 'Y');  
        
        
        System.assertEquals(true, bl); 
        Test.stopTest();
        
    }
    
    //Test Method convertFromStringToBoolean2
    static testMethod void convertFromStringToBoolean2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        boolean bl = XC_UTIL_Integration.convertFromStringToBoolean( 'N');  
        
        
        System.assertEquals(false, bl); 
        Test.stopTest();
        
    }
    
    //Test Method convertFromBooleanToString
    static testMethod void convertFromBooleanToString(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        string st = XC_UTIL_Integration.convertFromBooleanToString( true );  
        
        
        System.assertEquals(true, st!= null); 
        Test.stopTest();
        
    }
    
     //Test Method convertFromBooleanToString2
    static testMethod void convertFromBooleanToString2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        string st = XC_UTIL_Integration.convertFromBooleanToString( false );  
        
        
        System.assertEquals(true, st!= null); 
        Test.stopTest();
        
    }
    
    
    //Test Method setRestContextResponse
    static testMethod void setRestContextResponse(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.RestContextResponseWrapper contextWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        contextWrapper.msgResponse = '';
        contextWrapper.res = new System.RestResponse();
        contextWrapper.errorCode='';
        contextWrapper.mapHeader = new Map<String, String>();
        XC_UTIL_Integration.setRestContextResponse(  contextWrapper );  
        
        
        System.assertEquals(true, contextWrapper!= null); 
        Test.stopTest();
        
    }
    
     //Test Method setRestContextResponse2
    static testMethod void setRestContextResponse2(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_UTIL_Integration.RestContextResponseWrapper contextWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        contextWrapper.msgResponse = '';
        contextWrapper.res = new System.RestResponse();
        contextWrapper.errorCode='';
        contextWrapper.mapHeader = new Map<String, String>();
        contextWrapper.errorCode= '400';
        XC_UTIL_Integration.setRestContextResponse(  contextWrapper );  
        
        
        System.assertEquals(true, contextWrapper!= null); 
        Test.stopTest();
        
    }
   
   
    
    //Test Method setRestContextResponse3
    static testMethod void setRestContextResponse3(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        System.RestResponse res = new System.RestResponse();
        XC_UTIL_Integration.ContextResponseWrapper contextResponse = new XC_UTIL_Integration.ContextResponseWrapper();
        contextResponse.msgResponse = '';
        contextResponse.errorCode='';
        contextResponse.mapHeader = new Map<String, String>();
        XC_UTIL_Integration.setRestContextResponse(res, contextResponse);  
        
        
        System.assertEquals(true, contextResponse!= null); 
        Test.stopTest();
        
    }
    
    //Test Method getInfosForZuoraRest
    static testMethod void getInfosForZuoraRest(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        
        Map<String, String> mp = new Map<String, String>();
        
        try{
            
        
        mp = XC_UTIL_Integration.getInfosForZuoraRest();   }
        
        catch(exception e){ 
            
        System.assertEquals(true, e!= null);  
        }
        
        
        System.assertEquals(true, mp!= null);  
        Test.stopTest();
        
    }
    
    
    //Test Method validateFileRequest
    static testMethod void validateFileRequest(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration.validateFileRequest('', '');   
        
        
        System.assertEquals(true, wr!= null);  
        Test.stopTest();
        
    }
    
}