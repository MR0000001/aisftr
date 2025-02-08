@isTest
public with sharing class XC_REST_TariffList_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        NE__Family__c fam = new NE__Family__c();
        fam.name = 'Corporate';
        insert fam;

        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        insert prod;

        NE__ProductFamily__c pfam = new NE__ProductFamily__c();
        pfam.NE__FamilyId__c = fam.id;
        pfam.NE__ProdId__c = prod.id;
        insert pfam;

        NE__Catalog__c c = new NE__Catalog__c();
        c.XC_Country__c = 'Spain';
        insert c;

        NE__Catalog_Item__c cat = new NE__Catalog_Item__c();
        cat.NE__ProductId__c = prod.id;
        cat.NE__Catalog_Id__c = c.id;
        insert cat;

        NE__Translation__c t = new NE__Translation__c();
        t.NE__Commercial_Product__c = prod.id;
        t.NE__Language_user__c = 'es';
        insert t;

        
        zqu__ZProduct__c zp = new zqu__ZProduct__c();
        insert zp;

        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
        prp.zqu__ZProduct__c = zp.id;
        insert prp;

        zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c();
        prpc.zqu__ProductRatePlan__c = prp.id;
        insert prpc;

        zqu__ProductRatePlanChargeTier__c prpct = new zqu__ProductRatePlanChargeTier__c();
        prpct.zqu__ProductRatePlanCharge__c = prpc.id;
        insert prpct;


    }

    static testMethod void post(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();
        XC_REST_TariffList_W.requestElementWrapper re = new XC_REST_TariffList_W.requestElementWrapper();
        re.Country = 'Spain';
        re.PreferredLanguage = 'Spanish';
        re.Families = new list<String>();
        re.Families.add('Corporate');
        params.requestElement = re;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }


    static testMethod void post2(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();
        XC_REST_TariffList_W.requestElementWrapper re = new XC_REST_TariffList_W.requestElementWrapper();
        re.Country = 'Spain';
        re.PreferredLanguage = 'Test';
        re.Families = new list<String>();
        re.Families.add('Corporate');
        params.requestElement = re;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }
    
   	static testMethod void postNotFound(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();
        XC_REST_TariffList_W.requestElementWrapper re = new XC_REST_TariffList_W.requestElementWrapper();
        re.Country = 'Spain';
        re.PreferredLanguage = 'Spanish';
        re.Families = new list<String>();
        re.Families.add('Fake');
        params.requestElement = re;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void postValidateheader(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();
        XC_REST_TariffList_W.requestElementWrapper re = new XC_REST_TariffList_W.requestElementWrapper();
        
        params.requestElement = re;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'err_header');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void postValidateError(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();
        XC_REST_TariffList_W.requestElementWrapper re = new XC_REST_TariffList_W.requestElementWrapper();
        
        params.requestElement = re;

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        re.Country = 'Spain';
        params.requestElement = re;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        re.Families = new list<String>();
        re.Families.add('Fake');
        params.requestElement = re;
        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void empyRequest(){

        XC_REST_TariffList_W.WrapperRequest params = new XC_REST_TariffList_W.WrapperRequest();

        test.startTest();

        System.RestContext.request = generatePOSTorPUTRequest(params, 'POST', 'OK');
        XC_REST_TariffList.doPost();
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    private static RestRequest generatePOSTorPUTRequest(XC_REST_TariffList_W.WrapperRequest params, String method, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/TariffList/*';
      
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