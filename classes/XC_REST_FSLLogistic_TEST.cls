/** 
* @Author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @Date Creation 12/06/2020
* @Description XC_REST_FSLLogistic_TEST - TEST Class for XC_REST_FSLLogistic
*/

@isTest
private class XC_REST_FSLLogistic_TEST {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_FSLLogistic');  

    @TestSetup
	static void setup() { 
		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
        insert org;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        orderList[0].XC_EmobilityWebAppType__c  = Label.XC_CL_EmobilityWebAppType_Recharge;
        orderList[0].XC_Company_Code__c = 'C001';
        insert orderList;
        List<gii__PriceBookEntry__c> priceBookEntry = new List<gii__PriceBookEntry__c>();
        priceBookEntry = [select id,giic_AccountAssignmentCategory__c,gii__ProductCode__c, giic_LineNumber__c, gii__Product__r.gii__ProductReference__c, gii__Product__c,gii__Product__r.Name, giic_CategoryPosition__c, giic_Description__c, giic_UnitMeasure__c, giic_MaterialGroup__c, giic_UnitRequisitioner__c, giic_ContractPosition__c,giic_Plant__c from gii__PriceBookEntry__c];
    }

    @isTest
    static void testPostCreateSalesOrderFromConfig() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createSalesOrderFromConfig';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }

    @isTest
    static void testPostCheckAvailability() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'checkAvailability';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }

    @isTest
    static void testPostCreateSalesOrder() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createSalesOrder';
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }

    @isTest
    static void testPostCreateSalesOrderDelivery() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createSalesOrderDelivery';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }

    @isTest
    static void testPostNoOperation() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'errorOperation';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
     @isTest
    static void getProductReferenceMapping() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__ProductReference__c,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getProductReferenceMapping';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        inputWrapper.productReferenceId = new List<String>{pref.gii__ProductReference__c};
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
      @isTest
    static void getGloviaProductMapping() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
         XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getProductReferenceMapping';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        List<XC_UTIL_FSLLogistic.GloviaProduct> inputWrappe = new List<XC_UTIL_FSLLogistic.GloviaProduct>();
		 Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> resultData = new Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>>();
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
     @isTest
    static void createSalesOrdersB2B() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createSalesOrdersB2B';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
	@isTest
    static void createGoodsIssueGlovia() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createGoodsIssueGlovia';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
    @isTest
    static void createRMAGloviaB2B() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createRMAGloviaB2B';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
      @isTest
    static void getMapWorkOrderLineItemWarehouse() {
        
        
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getMapWorkOrderLineItemWarehouse';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= inputWrapper.recordID;
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;
        inputWrapper.listWOLI = new List<WorkOrderLineItem>{woli};
            
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
     @isTest
    static void getPricebookEntryRecord() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        System.assertEquals(true, pref.gii__PrimarySupplier__c==Giic_UtilityClass_Test.objAccountSupplier.Id);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        gii__PriceBookEntry__c pdentry = [select id from gii__PriceBookEntry__c limit 1];
        pdentry.giic_Description__c = 'test';
        pdentry.giic_UnitMeasure__c = 'M';
        update pdentry;
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getPricebookEntryRecord';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        inputWrapper.priceBookentryId = new List<String>{String.valueOf(pdentry.Id)};
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
      @isTest
    static void createMaterialTranspGloviaB2B() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'createMaterialTranspGloviaB2B';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
    
      @isTest
    static void getGloviaProductMapping2() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getGloviaProductMapping';
        inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
    
    @isTest
    static void getWarehouseRecords() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
        Gii__Warehouse__c wh = [select id, gii__Account__c from Gii__Warehouse__c limit 1];
        
        Gii__Warehouse__c wh2 = new Gii__Warehouse__c();
        wh2.gii__Account__c = acc[0].id;
        wh2.giic_WarehouseCode__c = 'XXXYYY';
        insert wh2;
            
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'getWarehouseRecords';
        //inputWrapper.recordID = new List<NE__Order__c>([SELECT Id FROM NE__Order__c LIMIT 1])[0].Id;
        //
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'Approved';
        WorkOrder wo = new WorkOrder();      
        wo.XC_PreferredPArtner__c = wh2.gii__Account__c;
        wo.State = 'Italy';
        
        insert wo;
        woli.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woli.XC_AccountId__c = wh2.gii__Account__c;
        insert woli;
        
         
        inputWrapper.warehouseIdList = new List<String>{woli.Id};
        inputWrapper.searchFilters = new Map<String,String>();
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        test.isRunningTest();
        test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
    
    @isTest
    static void testPostCancelSalesOrder() {
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'test');
        request.addHeader('DateTimeMessage', '20191207100000039');
        request.addHeader('ClientSystem', 'XRecharge');
        request.addHeader('ServerSystem','XCustomerB2C');  
        XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        inputWrapper.operation = 'cancelSalesOrder';
        request.addParameter('InputSelfCallout', EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(inputWrapper))));
		request.httpMethod = 'POST';
		request.requestURI = '/v1/FSLLogistic/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Test.startTest();
		XC_REST_FSLLogistic.doPost();
		Test.stopTest();
    }
    
}