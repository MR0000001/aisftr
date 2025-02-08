@isTest
public with sharing class XC_REST_Product_TEST {

        
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

    }
    
    
    static testMethod void getByAcc(){

        Map<String,String> params = new Map<String,String>();

        account a = [select id from account][0];

        params.put('account_id', a.id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Product.doGet();
        system.assertEquals(RestContext.response.statusCode, 400); 

        test.stopTest();
    }
    
        
    static testMethod void get1(){

        Map<String,String> params = new Map<String,String>();

        params.put('country', 'Spain');
        params.put('product_id', 'asd');
        params.put('quantity', '1');
        params.put('request_type', 'asd');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Product.doGet();
        system.assertEquals(RestContext.response.statusCode, 400); 

        test.stopTest();
    }
    
    
    static testMethod void get2(){

        Map<String,String> params = new Map<String,String>();

        params.put('country', 'Spain');
        params.put('product_id', 'asd');
        params.put('quantity', '1');
        params.put('request_type', 'asd');
        params.put('customer_zip_code', 'asd');
        

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Product.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }
    
    
    private static RestRequest generateGETRequest(Map<String,String> params, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'GET';
    	request.requestURI = '/v1/Product/*';

        if(operation!='err_header'){
            request = addHeader(request);
        }

        for (String s : params.keySet()){
            request.addParameter(s, params.get(s));
        }

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