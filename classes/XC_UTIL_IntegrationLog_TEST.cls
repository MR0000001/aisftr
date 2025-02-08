/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  27/05/2019 
* @description XC_UTIL_ResultWrapper_TEST – Test class for XC_UTIL_ResultWrapper
*/
@isTest
public class XC_UTIL_IntegrationLog_TEST {
    
    //Test Method setTransactionID
    static testMethod void setTransactionID(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        il.setTransactionID( 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    //Test Method setHttpMethod
    static testMethod void setHttpMethod(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        il.setHttpMethod( 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    
    
    
     //Test Method insertIntegReqInboundLog
    static testMethod void insertIntegReqInboundLog(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        il.insertIntegReqInboundLog('test', 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    //Test Method insertIntegRespInboundLog
    static testMethod void insertIntegRespInboundLog(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
       
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        il.insertIntegRespInboundLog('test', true, 'test', 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }

        
    //Test Method setHeader
    static testMethod void setHeaderTest(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        il.setHeader( new Map<String,String> ()); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    //Test Method insertIntegReqOutboundLog
    static testMethod void insertIntegReqOutboundLog(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        XC_UTIL_IntegrationLog.LogWrapper  wr = new XC_UTIL_IntegrationLog.LogWrapper();
        il.insertIntegReqOutboundLog(wr); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    
    //Test Method insertIntegRespOutboundLog
    static testMethod void insertIntegRespOutboundLog(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        
        il.insertIntegRespOutboundLog(true, 'test', 'test', 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
    
    //Test Method getIntegRespOutboundLog
    static testMethod void getIntegRespOutboundLogTest(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        
        XC_UTIL_IntegrationLog il = new XC_UTIL_IntegrationLog();
        
        il.getIntegRespOutboundLog(true, 'test', 'test', 'test'); 
        
        
        System.assertEquals(true, il!=null); 
        Test.stopTest();
        
    }
    
   
    
}