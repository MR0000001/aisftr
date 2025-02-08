/**
 * The Class XC_REST_DoxeeFileInCategory_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 05/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_DoxeeFileInCategory - XC_REST_DoxeeFileInCategory_U
 **/


@isTest
public without sharing class XC_REST_DoxeeFileInCategory_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }


    // POST Correct Account
    @isTest
    static void testDoPostAccount(){

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ACCOUNT';
        fileInCategoryWr.ObjectID = accList[0].Id;
        fileInCategoryWr.Category = 'SF_INVOICE';
        fileInCategoryWr.NumberOfFile = 1;
        fileInCategoryWr.DossierID = 'pippoplutopaperino';
        fileInCategoryWr.Purl = 'pippoplutopaperino';
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }
    
    // POST Correct Account purl2
    @isTest
    static void testDoPostAccountPurl2(){

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ACCOUNT';
        fileInCategoryWr.ObjectID = accList[0].Id;
        fileInCategoryWr.Category = 'SF_INVOICE';
        fileInCategoryWr.NumberOfFile = 1;
        fileInCategoryWr.DossierID = 'pippoplutopaperino';
        fileInCategoryWr.Purl = 'pippo@pluto@paperino';
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }
    
        // POST Correct Account
    @isTest
    static void testDoPostAccount1(){

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ACCOUNT';
        fileInCategoryWr.ObjectID = accList[0].Id;
        fileInCategoryWr.Category = 'SF_INVOICE';
        fileInCategoryWr.dOSSIERid = 'SF_INVOICE';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Update Account
    @isTest
    static void testDoPostUpdateAccount(){

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        XC_DocumentType__c docType = new XC_DocumentType__c();
        docType.XC_Account__c = accList[0].Id;
        docType.Category__c = 'SF_INVOICE';
        insert docType;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ACCOUNT';
        fileInCategoryWr.ObjectID = accList[0].Id;
        fileInCategoryWr.Category = 'SF_INVOICE';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Configuration
    @isTest
    static void testDoPostConfiguration(){

        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'Order');
        insert orderList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'CONFIGURATION';
        fileInCategoryWr.ObjectID = orderList[0].Id;
        fileInCategoryWr.Category = 'SF_DNI';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Workorder
    @isTest
    static void testDoPostWorkorder(){

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'WORKORDER';
        fileInCategoryWr.ObjectID = woList[0].Id;
        fileInCategoryWr.Category = 'SF_SERVICE_REPORT';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Contract
    @isTest
    static void testDoPostContract(){

        List<Contract> contractList = XC_DF_Contract.createContracts(1);
        insert contractList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'CONTRACT';
        fileInCategoryWr.ObjectID = contractList[0].Id;
        fileInCategoryWr.Category = 'SF_CONTRACT_SIGNED';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Asset
    @isTest
    static void testDoPostAsset(){

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        insert assetList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ASSET';
        fileInCategoryWr.ObjectID = assetList[0].Id;
        fileInCategoryWr.Category = 'SF_INSTALLATION_DOC_SIGNATURE';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Individual
    @isTest
    static void testDoPostIndividual(){

        Individual ind = new Individual();
        ind.LastName = 'TEST';
        insert ind;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'INDIVIDUAL';
        fileInCategoryWr.ObjectID = ind.Id;
        fileInCategoryWr.Category = 'SF_PRIVACY_DOCUMENT';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


    // POST Correct Configuration Item
    @isTest
    static void testDoPostConfItem(){

        List<NE__OrderItem__c> confItemList = XC_DF_OrderItem.createOrderItems(1);
        insert confItemList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'CONFIGURATION_ITEM';
        fileInCategoryWr.ObjectID = confItemList[0].Id;
        fileInCategoryWr.Category = 'SF_CIE';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }


     // POST Catch
    @isTest
    static void testDoPostCatch(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(500, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');

    }


    // POST No Category Item
    @isTest
    static void testDoPostNoCategoryItem(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Required Fields
    @isTest
    static void testDoPostNoRequiredFields(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"CategoryItem":[{}]}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST No Number Of File
    @isTest
    static void testDoPostNoNumberOfFile(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"CategoryItem":[{"ObjectType":"123","ObjectID":"123","Category":"123"}]}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Zero Number Of File 
    @isTest
    static void testDoPostZeroNumberOfFile(){

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody = Blob.valueOf('{"CategoryItem":[{"ObjectType":"123","ObjectID":"123","Category":"123","NumberOfFile":0}]}');

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }


    // POST Wrong Category
    @isTest
    static void testDoPostWrongCategory(){

        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'ACCOUNT';
        fileInCategoryWr.ObjectID = accList[0].Id;
        fileInCategoryWr.Category = 'SF_DNI';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        XC_REST_DoxeeFileInCategory_U.ResponseWrapper wrResp = (XC_REST_DoxeeFileInCategory_U.ResponseWrapper) JSON.deserialize (System.RestContext.response.responsebody.toString(), XC_REST_DoxeeFileInCategory_U.ResponseWrapper.class);
        System.assertEquals(400, Integer.valueOf(wrResp.result.ErrorCode), 'Wrong assert result');
    }

    // POST Correct BP
    @isTest
    static void testDoPostBP(){
		
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfileBankTrans(1);

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_DoxeeFileInCategory_U.RequestWrapper body = new XC_REST_DoxeeFileInCategory_U.RequestWrapper();
        XC_REST_DoxeeFileInCategory_U.FileWrapper fileInCategoryWr = new XC_REST_DoxeeFileInCategory_U.FileWrapper();
        fileInCategoryWr.ObjectType = 'CONTRACT';
        fileInCategoryWr.ObjectID = bpList[0].Id;
        fileInCategoryWr.Category = 'SF_CONTRACT_SIGNED';
        fileInCategoryWr.NumberOfFile = 1;
        body.CategoryItem = new List<XC_REST_DoxeeFileInCategory_U.FileWrapper>();
        body.CategoryItem.add(fileInCategoryWr);
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serialize(body, true));

        System.RestContext.response = new RestResponse();

        test.startTest();
		XC_REST_DoxeeFileInCategory.doPost();
        test.stopTest();
        
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');
    }





    private static RestRequest generateRestRequestPOSTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'FileIncategory');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/FileInCategory/*';

        return request; 
    }
}