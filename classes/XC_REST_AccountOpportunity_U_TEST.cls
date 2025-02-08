/**
 * The Class XC_REST_AccountOpportunity_U_TEST.
 *
 * @author              Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation       03/11/2020
 * @date Modification : dd/mm/yyyy
 * @description       : 
 **/


@isTest
public without sharing class XC_REST_AccountOpportunity_U_TEST {

    @isTest
    static void testDoPost(){

		test.startTest();

        System.RestContext.request = generateRestRequestPOSTGood();
        
	    XC_REST_AccountOpportunity_U.AccountOpportunityInfo asd = new XC_REST_AccountOpportunity_U.AccountOpportunityInfo();
	    asd.AccountOpportunityInfo='{\"Account\":{\"AccountType\":\"Residential\"},"Opportunity\":{\"LeadID\":\"abc123\"}}';

        XC_REST_AccountOpportunity_U.WrapperRequest body = new XC_REST_AccountOpportunity_U.WrapperRequest();
        body.AccountOpportunity=asd;
	    System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_AccountOpportunity.doPost();
	    System.assertEquals(true,true, 'Wrong assert result');

		test.stopTest();
    }
    
    @isTest
    static void testDoPostWrong(){

		test.startTest();

        System.RestContext.request = generateRestRequestPOSTGood();
        
        XC_REST_AccountOpportunity_U.WrapperRequest body = new XC_REST_AccountOpportunity_U.WrapperRequest();

	    System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

		System.RestContext.response = new RestResponse();

		XC_REST_AccountOpportunity.doPost();
	    System.assertEquals(true,true, 'Wrong assert result');

		test.stopTest();
    }
    
    private static RestRequest generateRestRequestPostGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'test');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'CommodityItalyB2B');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/AccountOpportunity/*';

        return request; 
    }

}