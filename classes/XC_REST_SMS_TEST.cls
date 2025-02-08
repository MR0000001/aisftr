@isTest
public with sharing class XC_REST_SMS_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        XC_Customer_Interaction__c custInt = new XC_Customer_Interaction__c();
        custInt.XC_Communication_Type__c = 'Send_SMS'; 
        custInt.XC_Channel__c = 'SMS';
        custInt.XC_SMSID__c = 'test';
        insert custInt;

    }

    static testMethod void emptyRequest(){

        XC_REST_SMS_W.WrapperRequest params = new XC_REST_SMS_W.WrapperRequest();
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);
        test.stopTest();
    
    }

    static testMethod void put(){

        XC_REST_SMS_W.WrapperRequest params = new XC_REST_SMS_W.WrapperRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.SMSID = 'test';
        sms.StatusCode = 'MB0004';
        sms.StatusDescription = 'Arrived at the recipient';
        sms.DateSMS = '2019-05-22 10:25:26';
        params.sms = sms;
        
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_SMSID__c = 'test';
        insert ci;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        params.sms = null;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        sms.DateSMS = '';
        params.sms = sms;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        sms.StatusCode = '';
        params.sms = sms;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        test.stopTest();
    
    }
    
    static testMethod void putErrorTest(){

        XC_REST_SMS_W.WrapperRequest params = new XC_REST_SMS_W.WrapperRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.SMSID = 'test';
        sms.StatusCode = 'MB0004';
        sms.StatusDescription = 'Arrived at the recipient';
        sms.DateSMS = '2019-05-22 10:25:26';
        params.sms = sms;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        params.sms = null;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        sms.DateSMS = '';
        params.sms = sms;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        sms.StatusCode = '';
        params.sms = sms;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        test.stopTest();
    
    }

    static testMethod void putNotFound(){

        XC_REST_SMS_W.WrapperRequest params = new XC_REST_SMS_W.WrapperRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.SMSID = 'test1';
        sms.StatusCode = 'MB0004';
        sms.StatusDescription = 'Arrived at the recipient';
        sms.DateSMS = '2019-05-22 10:25:26';
        params.sms = sms;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_SMS.doPut(); 

        test.stopTest();
    
    }


 
    
    static testMethod void internalErr(){

        XC_REST_SMS_W.WrapperRequest params = new XC_REST_SMS_W.WrapperRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.SMSID = 'test';
        sms.StatusCode = 'MB0004';
        sms.StatusDescription = 'Arrived at the recipient';
        sms.DateSMS = '2019-05-22 10:25:26';
        params.sms = sms;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        System.RestContext.request.requestBody = Blob.valueOf((JSON.serializePretty(params)).replace('"test"',','));

        XC_REST_SMS.doPut(); 
        System.assertEquals(true, true);

        test.stopTest();
    
    }


    private static RestRequest generatePOSTorPUTRequest(XC_REST_SMS_W.WrapperRequest params, String method, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/SMS/*';
      
        if(operation!='err_header'){
            request = addHeader(request);
        }

        string body = JSON.serializePretty(params);
        body = body.replace('DateSMS','Date');

        request.requestBody = Blob.valueOf(body);

        return request;
    }


    private static RestRequest addHeader(RestRequest request){
		request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', 'AXYZ');
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }



}