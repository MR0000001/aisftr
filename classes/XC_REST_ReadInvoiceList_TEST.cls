@isTest
public class XC_REST_ReadInvoiceList_TEST {
    
    @TestSetup
	static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ReadInvoiceListCommoditySpain;
        ic.XC_interfaceName__c = Label.XC_CL_ReadInvoiceListCommoditySpain;
        ic.XC_ServerSystem__c = 'CommoditySpainB2C';
        ic.XC_Country__c = 'Spain';
        insert ic;
    }
	
    static testMethod void callInitReadCaseRequest(){
        Test.startTest();  
            Map<String, String> paramsMap = new Map<String, String>();
            HttpRequest req = XC_REST_ReadInvoiceList.initReadInvoiceListRequest(paramsMap);
            System.assert(req!=null);
        Test.stopTest();
    }
	
    static testMethod void callToReadInvoiceList(){        
        Test.startTest();  
            Map<String, String> paramsMap = new Map<String, String>();
            XC_REST_Invoice_W.ReadInvoiceListResponse resp = XC_REST_ReadInvoiceList.callToReadInvoiceList(paramsMap);
            System.assert(resp!=null);
        Test.stopTest();
    }
	
    static testMethod void callToReadInvoiceListByCountry(){
        Test.startTest();  
            Map<String, String> paramsMap = new Map<String, String>();
            XC_REST_Invoice_W.ReadInvoiceListResponse resp = XC_REST_ReadInvoiceList.callToReadInvoiceList(paramsMap, 'Spain');
            System.assert(resp!=null);
        Test.stopTest();
    }
	
    static testMethod void callManageFakeResponse(){
        Test.startTest();  
            XC_REST_Invoice_W.ReadInvoiceListResponse res = XC_REST_ReadInvoiceList.manageFakeResponse();
            System.assert(res!=null);
        Test.stopTest();
    }
    
}