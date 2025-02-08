/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  18/03/2020 
* @description XC_REST_WBE_Inbound_Test – Test class for XC_REST_WBE_Inbound
*/

@isTest
public with sharing class XC_REST_WBE_Inbound_Test {

    static testMethod void  updateMethodTest(){

    XC_WbeTracking__c trak = new XC_WbeTracking__c();
    trak.XC_WBS__c='IT2KE600W0YS';
    trak.XC_Status__c='Send';
    trak.XC_ProductService__c='test';
    trak.XC_SapPillar__c='D4P';
    trak.XC_Scope__c='B2B/G';
    trak.XC_TypeOfSending__c='Service Creation';
    trak.XC_Wbe__c= 'IT2KE600W0YS1131000071';
    insert trak;
    XC_REST_WBE_Inbound_U.RequestWrapper wrResp = new XC_REST_WBE_Inbound_U.RequestWrapper();
    wrResp.wbes = new List<XC_REST_WBE_Inbound_U.WbeWrapper>();
    XC_REST_WBE_Inbound_U.WbeWrapper wb = new XC_REST_WBE_Inbound_U.WbeWrapper();
    wb.wbs ='IT2KE600W0YS';
    wb.wbe ='IT2KE600W0YS1131000071';
    wb.sfdc_id =trak.id;
    wb.order_id =trak.id;
    wb.wbe_error_code = 'OK';
    wb.wbe_message='OK';
    wrResp.wbes.add(wb);

   XC_REST_WBE_Inbound reqst=new XC_REST_WBE_Inbound();
   String JsonMsg=JSON.serialize(wrResp);
   Test.startTest();

   RestRequest req = new RestRequest(); 
   RestResponse res = new RestResponse();

    req.requestURI = '/v1/WBE/*';
    req.httpMethod = 'PUT';
    req.addHeader('TransactionID', 'AXYZ');
    req.addHeader('DateTimeMessage', '20181207103900000');
    req.addHeader('Operation', 'AXYZ');
    req.addHeader('Functionality', 'ViewActivableOffers');
    req.addHeader('ClientSystem', 'AXYZ');
    req.addHeader('ServerSystem', 'AXYZ');
    req.addHeader('debugMode', 'AXYZ');
    req.requestBody = Blob.valueof(JsonMsg);

    RestContext.request = req;
    RestContext.response= res;
    XC_REST_WBE_Inbound.doPut();
    trak.XC_Status__c='Approved';
    update trak;
    XC_REST_WBE_Inbound.doPut();

    //update TestOpp;
    Test.stopTest();

   }
		static testMethod void  updateMethodTest2(){
        
        List<String> wid = new List<String>();
        XC_REST_WBE_Inbound_U.WbeWrapper wb = new XC_REST_WBE_Inbound_U.WbeWrapper();
		wb.wbs ='IT2KE600W0YS';
        XC_REST_WBE_Inbound_U.RequestWrapper params = new XC_REST_WBE_Inbound_U.RequestWrapper();
        //wbr.wbes=wb;
        XC_WbeTracking__c trak = new XC_WbeTracking__c();
        trak.XC_WBS__c=wb.wbs;
        trak.XC_Status__c='Send';
        trak.XC_ProductService__c='test';
        trak.XC_SapPillar__c='D4P';
        trak.XC_Scope__c='B2B/G';
        trak.XC_TypeOfSending__c='Service Creation';
        trak.XC_Wbe__c= 'IT2KE600W0YS1131000071';
        insert trak;
        Map<Id, XC_WbeTracking__c> mapW = new Map<Id, XC_WbeTracking__c>();
        mapW.put(trak.id,trak);
        Test.startTest();
		System.RestContext.request = generatPUTRequest(params, 'OK');
        //XC_REST_TransferOrder_Inbound.doPut();
        //system.assertEquals(RestContext.response.statusCode, 200);
		Test.stopTest();
    }
        private static RestRequest generatPUTRequest(XC_REST_WBE_Inbound_U.RequestWrapper params, String operation){
        
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        
        request.httpMethod = 'PUT';
        request.requestURI = '/v1/TransferOrder/*';
        
        if(operation!='err_header'){
            request = addHeader(request);
        }
        
        string body = JSON.serializePretty(params);
        request.requestBody = Blob.valueOf(body);
        
        return request;
    }
    
    private static RestRequest addHeader(RestRequest request){
        request.addHeader('TransactionID', 'AXYZ');
        request.addHeader('DateTimeMessage', '20181207103900000');
        request.addHeader('Operation', 'AXYZ');
        request.addHeader('Functionality', 'ViewActivableOffers');
        request.addHeader('ClientSystem', 'AXYZ');
        request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }
}