/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  07/06/2019 
* @description XC_UTIL_RESTInbound_TEST – Test class for XC_UTIL_RESTInbound
*/
@istest
 public class XC_UTIL_RESTInbound_TEST {
    
    //Test Method checkHeader
    static testMethod void checkHeader(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     
     //Test Method checkHeader2
    static testMethod void checkHeader2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     //Test Method checkHeader3
    static testMethod void checkHeader3(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     //Test Method checkHeader4
    static testMethod void checkHeader4(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , 'test');
        mapParameters.put('Operation' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     //Test Method checkHeader5
    static testMethod void checkHeader5(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , 'test');
        mapParameters.put('Operation' , 'test');
        mapParameters.put('Functionality' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     //Test Method checkHeader6
    static testMethod void checkHeader6(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , 'test');
        mapParameters.put('Operation' , 'test');
        mapParameters.put('Functionality' , 'test');
        mapParameters.put('ClientSystem' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
     
     
     //Test Method checkHeader7
    static testMethod void checkHeader7(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , 'test');
        mapParameters.put('Operation' , 'test');
        mapParameters.put('Functionality' , 'test');
        mapParameters.put('ClientSystem' , 'test');
        mapParameters.put('ServerSystem' , 'test');
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        wr = XC_UTIL_RESTInbound.checkHeader(mapParameters) ;
        
        System.assertEquals(true,wr!=null);
        Test.stopTest();
        
    }
    
     
     
     //Test Method getIntegrationHeader
    static testMethod void getIntegrationHeader(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        Map<String, String> mapParameters = new Map<String, String>();
        XC_UTIL_Integration.Header header = new XC_UTIL_Integration.Header();
        mapParameters.put('TransactionID' , 'test');
        mapParameters.put('DateTimeMessage' , string.valueof(Datetime.now()));
        mapParameters.put('Operation' , 'test');
        mapParameters.put('Functionality' , 'test');
        mapParameters.put('ClientSystem' , 'test');
        mapParameters.put('ServerSystem' , 'test');
        header = XC_UTIL_RESTInbound.getIntegrationHeader(mapParameters) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
        
    }
     
     
      //Test Method isDateValid
    static testMethod void isDateValid(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        String dateValue = '';
        
        Boolean bln = XC_UTIL_RESTInbound.isDateValid(dateValue) ;
        
        System.assertEquals(true,!bln);
        Test.stopTest();
        
    }
     
     
     //Test Method isDateValid2
    static testMethod void isDateValid2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        String dateValue = '2019-05-06';
        
        Boolean bln = XC_UTIL_RESTInbound.isDateValid(dateValue) ;
        
        System.assertEquals(true,bln);
        Test.stopTest();
        
    }
     
           //Test Method checkDate
    static testMethod void checkDate(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        String dateValue = 'test';
        
        XC_UTIL_RESTInbound.checkDate(dateValue) ;
        
        System.assertEquals(true,dateValue!=null);
        Test.stopTest();
        
    }
     
     
      //Test Method checkDateISO
    static testMethod void checkDateISO(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        
        String dateValue = 'test';
        
        XC_UTIL_RESTInbound.checkDateISO(dateValue) ;
        
        System.assertEquals(true,dateValue!=null);
        Test.stopTest();
        
    }
     
     
    //Test Method checkDateISO
    static testMethod void checkUniqueId(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        list<account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
     
         //Test Method checkDateISO
    static testMethod void checkUniqueId1(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        
        list<account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_UniqueId__c = '123';
        insert acc;
        
        header.put('X-EmailAddress',acc[0].PrimaryEmail__c);
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        header.put('X-UniqueID','123');
       XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
    
             //Test Method checkDateISO
    static testMethod void checkUniqueId2(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        
        list<lead> acc = XC_DF_Lead.createResidentialLeads(1);
        insert acc;
        
        header.put('X-EmailAddress',acc[0].Email);
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
   
        //Test Method checkDateISO
    static testMethod void checkUniqueId3(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        list<account> acc = XC_DF_Account.createResidentialAccounts(2);
        acc[1].XC_AccountPhonePrefix__c = '+39';
        acc[1].XC_AccountPhone__c = '3875678976';
        insert acc;
        
                header.put('X-EmailAddress',acc[0].PrimaryEmail__c);
                header.put('X-Mobile','3875678976');
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
     
         //Test Method checkDateISO
    static testMethod void checkUniqueId4(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        list<asset> acc = XC_DF_Asset.createAssets(1);
        insert acc;
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
     
              //Test Method checkDateISO
    static testMethod void checkUniqueId5(){
    	insert XC_DF_OneOrg.createOneOrg('Spain'); 
        map<String,String> header = new map<String,String>();
        String idf = null;
        list<opportunity> acc = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert acc;
        
        Test.startTest(); 
        
        XC_UTIL_RESTInbound.wso2AuthCheck(acc[0].id,header) ;
        
        System.assertEquals(true,header!=null);
        Test.stopTest();
    }
     
}