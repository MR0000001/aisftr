/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  27/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_UTIL_Integration_U_TEST {
    
    
    //Test Method validateHeader
    @isTest
    static void validateHeader(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('TRANSACTIONID', 'test');
        mapHeader.put('DATETIMEMESSAGE', 'test');
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration_U.validateHeader( mapHeader);  
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
    }
    
    
    @isTest
    static void validateHeaderNoTransaction(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('DATETIMEMESSAGE', 'test');
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration_U.validateHeader( mapHeader);  
        
        System.assertEquals(true, wr!=null); 
        Test.stopTest();
    }
    
    
    @isTest
    static void validateHeaderNoDate(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('TRANSACTIONID', 'test');
        XC_UTIL_Integration.WrapperResult wr = XC_UTIL_Integration_U.validateHeader( mapHeader);  

        System.assertEquals(true, wr!=null); 
        Test.stopTest();
    }
    
    
    @isTest
    static void getEntityName(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        String entity = XC_UTIL_Integration_U.getEntityName('EndesaX');
        entity = XC_UTIL_Integration_U.getEntityName('');
        entity = XC_UTIL_Integration_U.getEntityNameWithStream('EndesaX', ''); 
        entity = XC_UTIL_Integration_U.getEntityNameWithStream('EndesaX', 'B2C');  
		String country = XC_UTIL_Integration_U.getCountryFromLegalEntity('EndesaX');  
        
        System.assertEquals(true, entity!=null); 
        Test.stopTest();
    }
    
    
    @isTest
    static void convert(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        String a = XC_UTIL_Integration_U.convertFromStringToPicklist('Y');
        a = XC_UTIL_Integration_U.convertFromStringToPicklist('N');
        a = XC_UTIL_Integration_U.convertFromStringToPicklist('');
        a = XC_UTIL_Integration_U.convertFromPicklistToString('');
        a = XC_UTIL_Integration_U.convertFromPicklistToString('Yes');
        a = XC_UTIL_Integration_U.convertFromPicklistToString('No');
        
        System.assertEquals(true, a!=null); 
        Test.stopTest();
    }    
}