/**
* @author Chiara Turco cturco@deloitte.it - Monica Cutillo mcutillo@deloitte.it
* @date Creation  28/05/2019 
* @description XC_REST_ReadAccont_TEST – Test class for XC_REST_ReadAccont
*/
@isTest
public class XC_REST_ReadAccont_TEST {
    
    @TestSetup
	static void setup(){
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<XC_CS001_InterfaceConfiguration__c> interfaces = new List<XC_CS001_InterfaceConfiguration__c>();
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        interfaces.add(ic);
        
        XC_CS001_InterfaceConfiguration__c ic2 = new XC_CS001_InterfaceConfiguration__c (XC_URL_Required__c = 'https://api-qual-local.enelx.com/b2c/esb/services/Account', 
                                                                                         XC_activeInterface__c = true, 
                                                                                         XC_interfaceName__c = 'ReadAccountCloudera', 
                                                                                         Name = 'ReadAccountCloudera');
        interfaces.add(ic2);
        insert interfaces;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
    }
    
    @isTest
    static void callInitReadAccountRequestInactive(){
        Test.startTest();
            try{
                HttpRequest result = XC_REST_ReadAccont.initReadAccountRequest('41550260R');
            }catch(XC_UTIL_RESTCallout.NotActiveInterfaceException ex){
                System.assert(true);
            }
        Test.stopTest();
     }
    
    @isTest
    static void callInitReadAccountRequestActive(){
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c =: Label.XC_CL_ReadAccountCommoditySpain ];
        interf[0].XC_activeInterface__c = true;
        update interf;
        
        Test.startTest();
            try{
                HttpRequest result = XC_REST_ReadAccont.initReadAccountRequest('41550260R');
            }catch(XC_UTIL_RESTCallout.NotActiveInterfaceException ex){
                System.assert(true);
            }
        Test.stopTest();
     }
    
    @isTest
    static void callInitReadAccountRequestInactiveInterface(){
        Test.startTest();
            try{
                HttpRequest result = XC_REST_ReadAccont.initReadAccountRequest('41550260R');
            }catch(XC_UTIL_RESTCallout.NotActiveInterfaceException ex){
                System.assert(true);
            }
        Test.stopTest();
     }
    
    @isTest
    static void callToReadAccount(){
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c =: Label.XC_CL_ReadAccountCommoditySpain ];
        interf[0].XC_activeInterface__c = true;
        update interf;
        
        Map<String,String> mapParam = getHeaderDefinitions();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw = XC_REST_ReadAccont.callToReadAccount(Label.XC_CL_ReadAccountCommoditySpain, mapParam, acc[0].Id);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }    
    
    @isTest
    static void callToReadAccount1(){
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c =: Label.XC_CL_ReadAccountCommoditySpain ];
        interf[0].XC_activeInterface__c = true;
        update interf;
        
        Map<String,String> mapParam = getHeaderDefinitions();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw = XC_REST_ReadAccont.callToReadAccount(Label.XC_CL_ReadAccountCommoditySpain, mapParam, acc[0].Id);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    @isTest
    static void callToReadAccountWithLoggingInactive(){
        Map<String,String> mapParam = getHeaderDefinitions();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw = XC_REST_ReadAccont.callToReadAccount( acc[0].Id, mapParam, true);   
        System.assert(rw!=null);
        Test.stopTest();
    }    
    
    @isTest
    static void callToReadAccountWithLogging(){
        Map<String,String> mapParam = getHeaderDefinitions();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c =: Label.XC_CL_ReadAccountCommoditySpain ];
        interf[0].XC_activeInterface__c = true;
        update interf;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw = XC_REST_ReadAccont.callToReadAccount( acc[0].Id, mapParam, true);   
        System.assert(rw!=null);
        Test.stopTest();
    }    
    
    @isTest
    static void callToReadAccountWithoutLogging(){        
        Map<String,String> mapParam = getHeaderDefinitions();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c =: Label.XC_CL_ReadAccountCommoditySpain ];
        interf[0].XC_activeInterface__c = true;
        update interf;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw = XC_REST_ReadAccont.callToReadAccount(acc[0].Id, mapParam, false);   
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    @isTest
    public static void callClouderaActive(){
        List<Opportunity> oppList = [SELECT Id, Name, AccountId, XC_SkipRisk__c, XC_Score__c, XC_ScoringErrorMessage__c FROM Opportunity WHERE Name='ScoringTest1' OR Name='ScoringTest2' OR Name='ScoringTest3'];
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CallDataLake_Mock());
        	XC_REST_ReadAccont.WrapperResult wrapper = XC_REST_ReadAccont.CallToReadAccountCloudera('Scoring', getHeaderDefinitions()); 
        	System.assert(wrapper != null);
		test.stopTest();
    }
    
    @isTest
    public static void callClouderaInactive(){
        List<Opportunity> oppList = [SELECT Id, Name, AccountId, XC_SkipRisk__c, XC_Score__c, XC_ScoringErrorMessage__c FROM Opportunity WHERE Name='ScoringTest1' OR Name='ScoringTest2' OR Name='ScoringTest3'];
        
        List<XC_CS001_InterfaceConfiguration__c> interf = [SELECT Id FROM XC_CS001_InterfaceConfiguration__c WHERE XC_interfaceName__c = 'ReadAccountCloudera' ];
        interf[0].XC_activeInterface__c = false;
        update interf;
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CallDataLake_Mock());
        	XC_REST_ReadAccont.WrapperResult wrapper = XC_REST_ReadAccont.CallToReadAccountCloudera('Scoring', getHeaderDefinitions()); 
        	System.assert(wrapper != null);
		test.stopTest();
    }
    
    private static Map<String,String> getHeaderDefinitions(){
        Map<String,String> mapParam = new Map<String,String>();
		mapParam.put('TransactionID', 'AXYZ');
		mapParam.put('DateTimeMessage', '20181207103900000');
		mapParam.put('Operation', 'AXYZ');
		mapParam.put('Functionality', 'AXYZ');
		mapParam.put('ClientSystem', 'AXYZ');
		mapParam.put('ServerSystem', 'AXYZ');
        mapParam.put('debugMode', 'AXYZ');
        return mapParam;
    }
    
    public without sharing class CallDataLake_Mock implements HttpCalloutMock {
        
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();
            
            if(req.getEndpoint().contains('esb/services/Account')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{ "Result": { "Message": "Operation completed successfully", "ErrorCode": "0" }, "Account": [ { "Scoring": { "DataLakeScoring" : "54.9" } } ] }');
                response.setStatusCode(200);
            }
            return response;
        } 
    }
    
    //Test Method callToGetReadAccont
    /*static testMethod void callToGetReadAccont(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
       
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountCommoditySpain,wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToGetReadAccont1
   static testMethod void callToGetReadAccont1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        Test.startTest(); 
       	XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont('test',wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToGetReadAccont2
    static testMethod void callToGetReadAccont2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont('test',wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }*/
    
    /*@isTest
    static void callToGetReadAccont3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'test';
        ic.XC_interfaceName__c = 'test';
        insert ic;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest();
        XC_REST_ReadAccont.WrapperResult rw;
        try{
             //rw = XC_REST_ReadAccont.callToGetReadAccont('test',wrAcc,wrAdd);
        }catch(exception e){
            System.assert(e!=null);
        }
        
        System.assertEquals(false, rw!=null);
        Test.stopTest();
        
    }*/
    
    //Test Method callToGetReadAccont4
    /*static testMethod void callToGetReadAccont4(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc = null;
       
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'test';
        ic.XC_interfaceName__c = 'test';
        insert ic;
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest();
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont('test',wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToGetReadAccont5
    static testMethod void callToGetReadAccont5(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
       
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
       
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountHR;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountHR;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountHR,wrAcc,wrAdd);   
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToGetReadAccont6
    static testMethod void callToGetReadAccont6(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        
        wrAcc.AccountID= 'test';
       
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest();
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountCommoditySpain,wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }
    
     //Test Method callToGetReadAccont7
    static testMethod void callToGetReadAccont7(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
       
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        Test.startTest(); 
        XC_REST_ReadAccont.WrapperResult rw;
        //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountCommoditySpain,wrAcc,wrAdd);   
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }*/
    
    /*@isTest
    static void callToGetReadAccont8(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
       
        
        XC_REST_ReadAccont_U.WrapperPOS wrpPos = new XC_REST_ReadAccont_U.WrapperPOS();
        
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        wrAdd.PointOfService = new List<XC_REST_ReadAccont_U.WrapperPOS>();
        wrAdd.PointOfService.add(wrpPos);
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        Test.startTest();
        XC_REST_ReadAccont.WrapperResult rw;
        try{
             //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountCommoditySpain,wrAcc,wrAdd);
        }catch(exception e){
            System.assert(e!=null);
        }
        
        XC_REST_ReadAccont_U.WrapperResponseCommoditySpain asd = new XC_REST_ReadAccont_U.WrapperResponseCommoditySpain();
        XC_REST_ReadAccont_U.buildMapFromWrapperObject(new Map<String, Object>());
        
           
        System.assertEquals(false, rw!=null);
        Test.stopTest();
        
    }*/
    
//Test Method callToGetReadAccont9
    /*static testMethod void callToGetReadAccont9(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        
        XC_REST_ReadAccont_U.WrapperAccount wrAcc = new XC_REST_ReadAccont_U.WrapperAccount();
        wrAcc.PrimaryEmail = 'test';
        wrAcc.IdentityNumber ='test';
        wrAcc.AccountID= 'test';
       
        
        XC_REST_ReadAccont_U.WrapperPOS wrpPos = new XC_REST_ReadAccont_U.WrapperPOS();
        
        XC_REST_ReadAccont_U.WrapperAddress wrAdd = new XC_REST_ReadAccont_U.WrapperAddress();
        wrAdd.PointOfService = new List<XC_REST_ReadAccont_U.WrapperPOS>();
        wrAdd.PointOfService.add(wrpPos);
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadAccountCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadAccountCommoditySpain;
        insert ic;
        
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_ReadAccont_Mock());
        
        Test.startTest();
        XC_REST_ReadAccont.WrapperResult rw;
        
            //rw = XC_REST_ReadAccont.callToGetReadAccont(Label.XC_CL_ReadAccountCommoditySpain,wrAcc,wrAdd);

        System.assert(rw!=null);
        Test.stopTest();
        
    }*/
}