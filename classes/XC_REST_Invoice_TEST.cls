@isTest
public class XC_REST_Invoice_TEST {
    
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
    
    static testMethod void getByAccErr(){

        Map<String,String> params = new Map<String,String>();

        account a = [select id from account][0];

        params.put('AccountID', a.id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Invoice.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }
    
    static testMethod void getByAcc(){

        Map<String,String> params = new Map<String,String>();

        account a = [select id from account][0];

        params.put('account_id', a.id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Invoice.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }
    
    
    static testMethod void getByAccOK1(){

        Map<String,String> params = new Map<String,String>();

        account a = [select id from account][0];

        params.put('account_id', a.id); 
        params.put('start_date', '2010-08-29');
        params.put('end_date', '2020-08-29');
        
        Zuora__ZInvoice__c z = new Zuora__ZInvoice__c();
        z.Zuora__Account__c = a.id;
        insert z;
        
        Zuora__InvoiceItem__c zi = new Zuora__InvoiceItem__c();
        zi.Zuora__Invoice__c = z.id;
        insert zi;
        
        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'wso2');
        XC_REST_Invoice.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 
        z.Zuora__Invoice_Items__r.add(zi);
		XC_REST_Invoice_U.getInvoiceWrapper(z);
        test.stopTest();
    }
    
    static testMethod void getByAccOK2(){

        Map<String,String> params = new Map<String,String>();

        account a = [select id from account][0];

        params.put('account_id', a.id); 
        params.put('start_date', '2010-08-29');
        params.put('end_date', '2020-08-29');
        
        Zuora__ZInvoice__c z = new Zuora__ZInvoice__c();
        z.Zuora__Account__c = a.id;
        insert z;
        
        Zuora__InvoiceItem__c zi = new Zuora__InvoiceItem__c();
        zi.Zuora__Invoice__c = z.id;
        insert zi;
        
        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'ok');
        XC_REST_Invoice.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 
        z.Zuora__Invoice_Items__r.add(zi);
		XC_REST_Invoice_U.getInvoiceWrapper(z);
        test.stopTest();
    }
    
    
    private static RestRequest generateGETRequest(Map<String,String> params, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'GET';
    	request.requestURI = '/v1/Invoice/*';

        if(operation!='err_header'){
            request = addHeader(request);
        }
        
        if(operation=='wso2'){
            request = addHeaderwso2(request);
        }

        for (String s : params.keySet()){
            request.addParameter(s, params.get(s));
        }

        return request;
    }
    
        static testMethod void getByAssOK(){

        Map<String,String> params = new Map<String,String>();

        Asset a = [select id from Asset][0];

        params.put('asset_id', a.id); 
        params.put('start_date', '2010-08-29');
        params.put('end_date', '2020-08-29');
        
        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Invoice.doGet();
        system.assertEquals(RestContext.response.statusCode, 200); 
        test.stopTest();
    }
    
    
    private static RestRequest addHeader(RestRequest request){
		request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', 'AXYZ');
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        return request;
    }
    
    private static RestRequest addHeaderwso2(RestRequest request){
		request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', 'AXYZ');
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('X-UniqueID', 'AXYZ');
        return request;
    }
    
    

}