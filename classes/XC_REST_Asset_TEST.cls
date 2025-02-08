@isTest
public with sharing class XC_REST_Asset_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].PrimaryEmail__c='test@test.com';
        insert acc;

        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;
 
        List<Asset> a = XC_DF_Asset.createAssets(acc);
        insert a;

        List<Contact> con = XC_DF_Contact.createResidentialContacts(acc);
        insert con;
    }

    static testMethod void getByAccPrimaryEmail(){
        Map<String,String> params = new Map<String,String>();
        Account acc=[select id,PrimaryEmail__c from Account 
                     where PrimaryEmail__c!=null limit 1];
        params.put('PrimaryEmail',acc.PrimaryEmail__c); 
        system.debug('params'+' '+params.get('PrimaryEmail'));
        test.startTest();
        XC_REST_Asset_U_D.getAccount(params);  
        test.stopTest();
    }
    static testMethod void getByAcc(){

        Map<String,String> params = new Map<String,String>();
        
        params.put('AccountID', [SELECT id FROM Account][0].id);
        test.startTest();   
        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_UTIL_Asset.AssetRESTWrapper wrResp1 = (XC_UTIL_Asset.AssetRESTWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_UTIL_Asset.AssetRESTWrapper.class);
        System.assertEquals(true, wrResp1!=null, 'Wrong assert result');

        delete [SELECT id FROM Account][0];

        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void getByAccIdentity(){

        Map<String,String> params = new Map<String,String>();

        Account a = [SELECT id, IdentityNumber__c FROM Account][0];
        a.IdentityNumber__c = 'Z2736144T';
        a.IdentityType__c = 'NIE';
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        a.XC_NIE_expiration_date__c=myDate;
        a.XC_NIE_expedition_date__c=myDate-1;
        a.PrimaryEmail__c='test@test.com';
        update a;

        params.put('IdentityNumber', [SELECT id, IdentityNumber__c FROM Account][0].IdentityNumber__c);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void getByAddress(){

        Map<String,String> params = new Map<String,String>();
        params.put('StreetType', 'test');
        params.put('Address', 'test');
        params.put('StreetNumber', 'test');
        params.put('ZipCode', 'test');
        params.put('City', 'test');
        params.put('Country', 'test');
        params.put('Category', 'test');
        params.put('Door', 'test');
        params.put('Stair', 'test');
        params.put('Province', 'test');

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void getByPos(){

        Map<String,String> params = new Map<String,String>();
        

        XC_pointofservice__c p = new XC_pointofservice__c();
        p.xc_address__c = [select id from xc_address__c][0].id; 
        insert p;

        params.put('POSID', [SELECT id FROM XC_pointofservice__c][0].id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void getByAdd(){

        Map<String,String> params = new Map<String,String>();

        asset a = [select id, xc_address__c from asset][0];
        a.xc_address__c = [select id from xc_address__c][0].id;
        update a;

        params.put('AddressID', [SELECT id FROM XC_Address__c][0].id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_UTIL_Asset.AssetRESTWrapper wrResp = (XC_UTIL_Asset.AssetRESTWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_UTIL_Asset.AssetRESTWrapper.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void getByAssetId(){

        Map<String,String> params = new Map<String,String>();

        asset a = [select id, xc_address__c from asset][0];
        a.xc_address__c = [select id from xc_address__c][0].id;
        update a;

        params.put('AssetID', a.Id);

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'OK');
        XC_REST_Asset.doGet();
        XC_UTIL_Asset.AssetRESTWrapper wrResp = (XC_UTIL_Asset.AssetRESTWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_UTIL_Asset.AssetRESTWrapper.class);
        System.assertEquals(true, wrResp!=null, 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void postByAcc(){

        XC_REST_Asset_U.WrapperAssetRequest wrReq = new XC_REST_Asset_U.WrapperAssetRequest();
        XC_UTIL_Asset.AssetRESTWrapper assetWr = new XC_UTIL_Asset.AssetRESTWrapper();
        XC_UTIL_Account.AccountIFWrapper accWr = new XC_UTIL_Account.AccountIFWrapper();
        
        accWr.AccountID = [SELECT id FROM Account][0].id;
        wrReq.Account = accWr;

        assetWr.LegalEntity = 'test';
        assetWr.AssetName = 'test';
        assetWr.ContactID = [SELECT id FROM Contact][0].id;
        assetWr.Currency_r = 'EUR';
        wrReq.Asset = assetWr;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'POST', 'ok');
        XC_REST_Asset.doPost();
        XC_REST_Asset_U.WrapperAssetResponse wrResp1 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp1.result.errorcode), 'Wrong assert result');

        assetWr.purchaseDate = 'asd';
        wrReq.Asset = assetWr;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'POST', 'ok');
        XC_REST_Asset.doPost();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        assetWr.purchaseDate = '';
        assetWr.installDate = 'asd';
        wrReq.Asset = assetWr;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'POST', 'ok');
        XC_REST_Asset.doPost();
        XC_REST_Asset_U.WrapperAssetResponse wrResp3 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp3.result.errorcode), 'Wrong assert result');

        test.stopTest(); 
    }

    static testMethod void put(){

        XC_REST_Asset_U.WrapperAssetRequest wrReq = new XC_REST_Asset_U.WrapperAssetRequest();
        XC_UTIL_Asset.AssetRESTWrapper assetWr = new XC_UTIL_Asset.AssetRESTWrapper();

        assetWr.AssetID = [SELECT id FROM Asset][0].id;
        assetWr.LegalEntity = 'test';
        assetWr.AssetName = 'test';
        assetWr.ContactID = [SELECT id FROM Contact][0].id;
        assetWr.Currency_r = 'EUR';
        
        test.startTest();

        wrReq.Asset = null;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'PUT', 'ok');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp1 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp1.result.errorcode), 'Wrong assert result');

        wrReq.Asset = assetWr;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'PUT', 'ok');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(500, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void putBySubErr(){

        XC_REST_Asset_U.WrapperAssetRequest wrReq = new XC_REST_Asset_U.WrapperAssetRequest();
        XC_UTIL_Asset.AssetRESTWrapper assetWr = new XC_UTIL_Asset.AssetRESTWrapper();

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__ZuoraSubscriptionID__c = 'test';
        insert z;

        assetWr.SubscriptionID = 'test';
        assetWr.Status = Label.XC_CL_Asset_StatusSuspended;
        assetWr.LegalEntity = 'test';
        assetWr.AssetName = 'test';
        assetWr.ContactID = [SELECT id FROM Contact][0].id;
        assetWr.Currency_r = 'EUR';
        
        test.startTest();

        wrReq.Asset = assetWr;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'PUT', 'ok');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp1 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp1.result.errorcode), 'Wrong assert result');
        
        wrReq.Asset.Status = Label.XC_CL_Asset_StatusActive;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'PUT', 'ok');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void putBySub(){

        XC_REST_Asset_U.WrapperAssetRequest wrReq = new XC_REST_Asset_U.WrapperAssetRequest();
        XC_UTIL_Asset.AssetRESTWrapper assetWr = new XC_UTIL_Asset.AssetRESTWrapper();

        zqu__Quote__c z = new zqu__Quote__c();
        z.zqu__ZuoraSubscriptionID__c = 'test';
        insert z;

        List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
        oi[0].XC_ZQuoteId__c = z.id;
        //insert oi;

        Asset a = [select id, XC_Configuration_Item__c from asset][0];
        //a.XC_Configuration_Item__c = [select id from NE__OrderItem__c][0].id;
        //update a;

        assetWr.SubscriptionID = 'test';
        assetWr.Status = 'test';
        assetWr.LegalEntity = 'test';
        assetWr.AssetName = 'test';
        assetWr.ContactID = [SELECT id FROM Contact][0].id;
        assetWr.Currency_r = 'EUR';
        
        test.startTest();

        wrReq.Asset = assetWr;
        System.RestContext.request = generatePOSTorPUTRequest(wrReq, 'PUT', 'ok');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void errHeader(){
    
        Map<String,String> params = new Map<String,String>();
        XC_REST_Asset_U.WrapperAssetRequest assetWr = new XC_REST_Asset_U.WrapperAssetRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'err_header');
        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp1 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp1.result.errorcode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(assetWr, 'POST', 'err_header');
        XC_REST_Asset.doPost();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(assetWr, 'PUT', 'err_header');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp3 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp3.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    static testMethod void emptyReq(){
    
        Map<String,String> params = new Map<String,String>();
        XC_REST_Asset_U.WrapperAssetRequest assetWr = new XC_REST_Asset_U.WrapperAssetRequest();

        test.startTest();

        System.RestContext.request = generateGETRequest(params, 'empty');
        XC_REST_Asset.doGet();
        XC_REST_Asset_U.WrapperAssetResponse wrResp1 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp1.result.errorcode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(assetWr, 'POST', 'empty');
        XC_REST_Asset.doPost();
        XC_REST_Asset_U.WrapperAssetResponse wrResp2 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp2.result.errorcode), 'Wrong assert result');

        System.RestContext.request = generatePOSTorPUTRequest(assetWr, 'PUT', 'empty');
        XC_REST_Asset.doPut();
        XC_REST_Asset_U.WrapperAssetResponse wrResp3 = (XC_REST_Asset_U.WrapperAssetResponse) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_Asset_U.WrapperAssetResponse.class);
        System.assertEquals(400, Integer.valueOf(wrResp3.result.errorcode), 'Wrong assert result');

        test.stopTest();
    }

    private static RestRequest generateGETRequest(Map<String,String> params, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'GET';
    	request.requestURI = '/v1/WorkOrder/*';

        if(operation!='err_header'){
            request = addHeader(request);
        }

        for (String s : params.keySet()){
            request.addParameter(s, params.get(s));
        }

        return request;
    }

    private static RestRequest generatePOSTorPUTRequest(XC_REST_Asset_U.WrapperAssetRequest params, String method, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/WorkOrder/*';
      
        if(operation!='err_header'){
            request = addHeader(request);
        }

        request.requestBody = Blob.valueOf(JSON.serializePretty(params));

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