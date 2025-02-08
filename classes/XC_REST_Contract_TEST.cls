@isTest
public class XC_REST_Contract_TEST {
    
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
    
    static testMethod void getByAccErrorHeader(){

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', [SELECT id FROM Account][0].id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'err_header');
        XC_REST_Contract.doGet();
        system.assertEquals(RestContext.response.statusCode, 400); 

        test.stopTest();
    }
    
    static testMethod void getByAccNotFound(){

        Map<String,String> params = new Map<String,String>();
        params.put('AccountID', [SELECT id FROM Account][0].id);
        params.put('IdentityNumber', '123');
        params.put('PrimaryEmail', '123');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }

    static testMethod void getByAcc(){

        Map<String,String> params = new Map<String,String>();
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('AccountID', a.id);
        params.put('IdentityNumber', '123');
        params.put('PrimaryEmail', '123');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }
    
    static testMethod void getByUniqueId(){

        Map<String,String> params = new Map<String,String>();
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('AccountID', a.id);
        params.put('UniqueID', '123');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }

    static testMethod void getByAss(){

        Map<String,String> params = new Map<String,String>();
        Asset ass = [select id from asset][0];
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('AssetID', ass.id);
        //params.put('IdentityNumber', '123');


        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        

        test.stopTest();
    }

    static testMethod void getByAccEmail(){

        Map<String,String> params = new Map<String,String>();
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('IdentityNumber', '123');
        params.put('PrimaryEmail', '123');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }
    
    static testMethod void getByIdNumb(){

        Map<String,String> params = new Map<String,String>();
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('IdentityNumber', '123');
        //params.put('PrimaryEmail', '123');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }
    
    static testMethod void getByPos(){

        Map<String,String> params = new Map<String,String>();
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('POS', '123');
        //params.put('PrimaryEmail', '123');
        //

		XC_Address__c add = [select id from XC_Address__c][0];        
        XC_PointOfService__c pos = new XC_PointOfService__c();
        pos.XC_Address__c = add.id;
        insert pos;

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK'); 
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        
        params.put('POS', pos.id);
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null);      

        test.stopTest();
    }

    static testMethod void getByAdd(){

        Map<String,String> params = new Map<String,String>();
        
        XC_Address__c add = [select id from XC_Address__c][0];
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        //params.put('AddressID', add.id);
        //params.put('AccountID', a.id);
        //params.put('IdentityNumber', '123');
        //params.put('PrimaryEmail', '123');
        


        test.startTest();
        
        XC_REST_Contract_D.getAccountById(a.id);

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet(); 
        system.assert(RestContext.response != null); 
        
        params.put('StreetType', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        
        params.put('Address', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        
        params.put('StreetNumber', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        
        params.put('ZipCode', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 
        
        params.put('City', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null);  
        
        params.put('Country', '123');
        
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }
    
     static testMethod void getByAdd2(){

        Map<String,String> params = new Map<String,String>();
        
        XC_Address__c add = [select id from XC_Address__c][0];
        Account a = [SELECT id FROM Account][0];
        Contract c = new contract();
        c.accountId = a.id;
        insert c;
        params.put('AddressID', add.id);
        //params.put('AccountID', a.id);
        //params.put('IdentityNumber', '123');
        //params.put('PrimaryEmail', '123');
        
        test.startTest();
         
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Contract.doGet();
        system.assert(RestContext.response != null); 

        test.stopTest();
    }
    
    private static RestRequest generateGETRequest(Map<String,String> params, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'GET';
    	request.requestURI = '/v1/Contract/*';

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