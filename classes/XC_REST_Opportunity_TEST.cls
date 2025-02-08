@isTest
public with sharing class XC_REST_Opportunity_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;

        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
 
        List<Asset> a = XC_DF_Asset.createAssets(acc);
        insert a;

        List<Contact> con = XC_DF_Contact.createResidentialContacts(acc);
        insert con;
    }

    @isTest
    static void emptyRequest(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost(); 
        XC_REST_Opportunity_U.WrapperResponse wrResp = (XC_REST_Opportunity_U.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Opportunity_U.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void post(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        XC_UTIL_Opportunity.OpportunityIFWrapper opp = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        opp.LegalEntity = 'EndesaX';
        opp.OpportunityName = 'test';
        opp.AccountID = [select id from account][0].id;
        opp.ContactID = [select id from contact][0].id;
        opp.ProductCategoryOfInterest = 'Caldera';
        opp.Status = 'Draft';
        opp.AddressID = [select id from xc_address__c][0].id;
        opp.CloseDate = date.today();
        params.Opportunity = opp;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void postWrongAccountID(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        XC_UTIL_Opportunity.OpportunityIFWrapper opp = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        opp.LegalEntity = 'EndesaX';
        opp.OpportunityName = 'test';
        opp.AccountID = 'AAA';
        opp.ContactID = [select id from contact][0].id;
        opp.ProductCategoryOfInterest = 'Caldera';
        opp.Status = 'Draft';
        opp.AddressID = [select id from xc_address__c][0].id;
        opp.CloseDate = date.today();
        params.Opportunity = opp;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void postWrongContactID(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        XC_UTIL_Opportunity.OpportunityIFWrapper opp = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        opp.LegalEntity = 'EndesaX';
        opp.OpportunityName = 'test';
        opp.AccountID = [select id from account][0].id;
        opp.ContactID = 'AAA';
        opp.ProductCategoryOfInterest = 'Caldera';
        opp.Status = 'Draft';
        opp.AddressID = [select id from xc_address__c][0].id;
        opp.CloseDate = date.today();
        params.Opportunity = opp;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void postWrongAddressID(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        XC_UTIL_Opportunity.OpportunityIFWrapper opp = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        opp.LegalEntity = 'EndesaX';
        opp.OpportunityName = 'test';
        opp.AccountID = [select id from account][0].id;
        opp.ContactID = [select id from contact][0].id;
        opp.ProductCategoryOfInterest = 'Caldera';
        opp.Status = 'Draft';
        opp.AddressID = 'AAA';
        opp.CloseDate = date.today();
        params.Opportunity = opp;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void postNullOpportunity(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        params.Opportunity = null;
    
        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'SMS');
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }

    @isTest
    static void postB2Bwrong(){

        XC_REST_Opportunity_U.WrapperRequest params = new XC_REST_Opportunity_U.WrapperRequest();
        XC_UTIL_Opportunity.OpportunityIFWrapper opp = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        opp.LegalEntity = 'EndesaX';
        opp.OpportunityName = 'test';
        opp.AccountID = [select id from account][0].id;
        opp.ContactID = [select id from contact][0].id;
        opp.ProductCategoryOfInterest = 'Caldera';
        opp.Status = 'Draft';
        opp.AddressID = [select id from xc_address__c][0].id;
        opp.CloseDate = date.today();
        params.Opportunity = opp;
    
        test.startTest();

        System.RestContext.request = generatePOSTb2b(params);
        XC_REST_Opportunity.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    /*
	*@ Description get Opportunity by OpportunityID
	*/
    @isTest
	static void testGETOpportunity(){
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        
        System.RestContext.request = generateRestRequestGetGood();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('OpportunityID',oppList[0].Id);
        test.startTest();
		XC_REST_Opportunity.doGet();
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
		test.stopTest();
    }
    
    /*
	*@ Description get Opportunity Wrong
	*/
    @isTest
	static void testGETOpportunityWrong(){

        System.RestContext.request = generateRestRequestGetWrong();
        System.RestContext.response = new RestResponse();
        System.RestContext.request.addParameter('OpportunityID','');
        test.startTest();
		//XC_REST_Lead.doGet();
        XC_REST_Opportunity.doGet();
        XC_REST_Opportunity_U.WrapperResponse wrResp = (XC_REST_Opportunity_U.WrapperResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Opportunity_U.WrapperResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
		test.stopTest();
	}
    
    
    
    private static RestRequest generatePOSTb2b(XC_REST_Opportunity_U.WrapperRequest params){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'POST';
    	request.requestURI = '/v1/Opportunity/*';
        request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', 'AXYZ');
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'CommodityItalyB2B');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');

        string body = JSON.serializePretty(params);

        request.requestBody = Blob.valueOf(body);

        return request;
    }
    

    private static RestRequest generatePOSTorPUTRequest(XC_REST_Opportunity_U.WrapperRequest params, String method, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/Opportunity/*';
      
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
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }
	
    
    private static RestRequest generateRestRequestGetGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'Get');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'GET');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'GET';
        request.requestURI = '/v1/Opportunity/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestGetWrong(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'Get');
        request.addHeader('Operation', 'GET');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'GET';
        request.requestURI = '/v1/Opportunity/*';

        return request; 
    }


}