/**
* @author              Luisana Rocco lrocco@deloitte.it
* @date Creation       16/02/2021
* @date Modification   dd/mm/yyyy
* @description         XC_REST_AssetList_TEST – XC_REST_AssetList\XC_REST_AssetList_U\XC_REST_AssetList_D\XC_REST_AssetList_W
*/


@isTest
public without sharing class XC_REST_AssetList_TEST {


    @TestSetup
	static void setup(){

        
        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        catItem.NE__UsageCode__c = 'SRPG';
        insert catItem;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_FirstName__c = 'Test';
        acc[0].XC_LastName__c = 'Test';
        acc[0].IdentityNumber__c = 'TSTTST80A01F839I';
        acc[0].XC_DocumentCountry__c = 'Italy';
        acc[0].IdentityType__c = 'CF';
        insert acc;

        List<XC_Address__c> addr = XC_DF_Address.createAddress(acc);
        insert addr;

        List<Contact> con = XC_DF_Contact.createResidentialContacts(acc);
        con[0].FirstName = 'Test';
        con[0].LastName = 'Test';
        con[0].XC_ContactDocumentNumber__c = 'TSTTST80A01F839I';
        con[0].XC_ContactDocumentType__c = 'CF';
        con[0].XC_ContactDocumentCountry__c = 'Italy';
        insert con;
 
        List<Asset> a = XC_DF_Asset.createAssets(acc);
        a[0].ContactId = con[0].Id;
        a[0].AccountId = acc[0].Id;
        a[0].XC_LegalEntity__c = 'EnelXItalia';
        a[0].Status = 'Active';
        a[0].XC_AnnualRenewalDateIndex__c = system.today().addyears(2);
        a[0].NE__CatalogItem__c = catItem.Id;
        insert a;

       
    }

    /*
	*@ Description Asset found
	*/
    @isTest
	static void testGetAsset(){ 
        
        system.debug([select id, XC_AnnualRenewalDateIndex__c,XC_LegalEntity__c, account.IdentityNumber__c, Status  from asset]);
        System.RestContext.request = generateReqRightHeaderGET();
        Map<id,XC_CM_PartnerAssetConfiguration__mdt> partnerMap = new Map <Id,XC_CM_PartnerAssetConfiguration__mdt>([SELECT XC_QueryID__c FROM XC_CM_PartnerAssetConfiguration__mdt LIMIT 1]);
        System.RestContext.request.addParameter('query_id', partnerMap.values()[0].XC_QueryID__c);
        System.RestContext.request.addParameter('identity_number', 'TSTTST80A01F839I');
        System.RestContext.request.addParameter('legal_entity', 'EnelXItalia');
        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_AssetList.doGet();
        XC_REST_AssetList_W.WrapperResponseGET wrResp = (XC_REST_AssetList_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_AssetList_W.WrapperResponseGET.class);
        System.assertEquals(0, Integer.valueOf(wrResp.result.error_code), 'Wrong assert result');
        test.stopTest();
    }


    /*
	*@ Description Asset not found
	*/
    @isTest
	static void testGetAsset2(){ 
        
        System.RestContext.request = generateReqRightHeaderGET();
        Map<id,XC_CM_PartnerAssetConfiguration__mdt> partnerMap = new Map <Id,XC_CM_PartnerAssetConfiguration__mdt>([SELECT XC_QueryID__c FROM XC_CM_PartnerAssetConfiguration__mdt LIMIT 1]);
        System.RestContext.request.addParameter('query_id',  partnerMap.values()[0].XC_QueryID__c);
        System.RestContext.request.addParameter('identity_number', '383939338');
        System.RestContext.request.addParameter('start_date', String.valueOf(system.today()));
        System.RestContext.request.addParameter('end_date', String.valueOf(system.today()));
       
        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_AssetList.doGet();
        XC_REST_AssetList_W.WrapperResponseGET wrResp = (XC_REST_AssetList_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_AssetList_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.error_code), 'Wrong assert result');
        test.stopTest();
    }
    
    /*
	*@ Description missing queryId
	*/
    @isTest
	static void testGetAssetMissingQueryId(){ 
        
        System.RestContext.request = generateReqRightHeaderGET();
        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_AssetList.doGet();
        XC_REST_AssetList_W.WrapperResponseGET wrResp = (XC_REST_AssetList_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_AssetList_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.error_code), 'Wrong assert result');
        test.stopTest();
    }
    
    /*
	*@ Description Missing mandatory identityNumber and start\end date
	*/
    @isTest
	static void testGetAssetMissingIdentityAndDate(){ 
        
        System.RestContext.request = generateReqRightHeaderGET();
        Map<id,XC_CM_PartnerAssetConfiguration__mdt> partnerMap = new Map <Id,XC_CM_PartnerAssetConfiguration__mdt>([SELECT XC_QueryID__c FROM XC_CM_PartnerAssetConfiguration__mdt LIMIT 1]);
        System.RestContext.request.addParameter('query_id',  partnerMap.values()[0].XC_QueryID__c);
       
        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_AssetList.doGet();
        XC_REST_AssetList_W.WrapperResponseGET wrResp = (XC_REST_AssetList_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_AssetList_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.error_code), 'Wrong assert result');
        test.stopTest();
    }

    /*
	*@ Description wrong header
	*/
    @isTest
	static void testGetAssetWrongHeader(){ 
        
        System.RestContext.request = generateReqRightHeaderGET();
        String trasaction = System.RestContext.request.headers.remove('TransactionID');
        System.RestContext.response = new RestResponse();

        test.startTest();
        XC_REST_AssetList.doGet();
        XC_REST_AssetList_W.WrapperResponseGET wrResp = (XC_REST_AssetList_W.WrapperResponseGET) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_AssetList_W.WrapperResponseGET.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.error_code), 'Wrong assert result');
        test.stopTest();
    }
    
 



    /*
	*@ Description generate right header request GET
	*/
    private static RestRequest generateReqRightHeaderGET(){
       
        RestRequest request = new RestRequest();
		
        request.addHeader('TransactionID', 'TransactionIDTest');
        request.addHeader('Functionality', 'readAsset');
        request.addHeader('DateTimeMessage', '20210101100000039');
        request.addHeader('ClientSystem', 'Test');
        request.addHeader('ServerSystem','XCustomerB2C');  
        request.addHeader('Operation','read');  

		request.httpMethod = 'GET';
		request.requestURI = '/v1/AssetList/*';
        return request;
    }
    
}