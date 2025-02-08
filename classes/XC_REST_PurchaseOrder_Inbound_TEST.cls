/**
 * The Class XC_REST_PurchaseOrder_Inbound_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 19/03/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_PurchaseOrder_Inbound - XC_REST_PurchaseOrder_Inbound_U
 **/


@isTest
public without sharing class XC_REST_PurchaseOrder_Inbound_TEST {

    @TestSetup
    static void onSetup() {
      giic_GloviaLogisticSetting__c settings = giic_GloviaLogisticSetting__c.getOrgDefaults();
      settings.giic_DisableVRTestClasses__c = true;
      upsert settings custSettings__c.Id;
    }

    @isTest
    static void post() {

        System.RestContext.request = generateRestRequestPOSTGood();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    
    }

    
    @isTest
    static void postCatch() {

        System.RestContext.request = generateRestRequestPOSTGood();
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty('{Test}'));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPost();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void put() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
        gii__PurchaseOrder__c po = [SELECT Id FROM gii__PurchaseOrder__c LIMIT 1];

        System.RestContext.request = generateRestRequestPUTGoodS4P();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = po.Id;
        purchase_wr.po_result = '1';
        purchase_wr.po_results = po_resultWr;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
     @isTest
    static void put2() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
        gii__PurchaseOrder__c po = [SELECT Id FROM gii__PurchaseOrder__c LIMIT 1];

        System.RestContext.request = generateRestRequestPUTGoodS4P();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = po.Id;
        purchase_wr.po_result = 'OK';
        purchase_wr.po_results = po_resultWr;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    @isTest
    static void putNoOrder() {
        
        System.RestContext.request = generateRestRequestPUTGoodS4P();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = '1';
        purchase_wr.po_result = '1';
        purchase_wr.po_results = po_resultWr;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putMissingRequiredSupplier() {

        System.RestContext.request = generateRestRequestPUTGoodSupplier();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putMissingRequiredPoResultSupplier() {

        System.RestContext.request = generateRestRequestPUTGoodSupplier();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        po_resultWr.add(poWr);
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> items = new List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper item = new XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper();
        items.add(item);
        purchase_wr.sfdc_id = '1';
        purchase_wr.source_system = '1';
        purchase_wr.target_system = '1';
        purchase_wr.po_result = '1';
        purchase_wr.sfdc_id = '1';
        purchase_wr.po_results = po_resultWr;
        purchase_wr.items = items;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putEmptyItemsSupplier() {

        System.RestContext.request = generateRestRequestPUTGoodSupplier();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.error_code = 'test';
        poWr.message = 'test';
        po_resultWr.add(poWr);
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> items = new List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>();
        purchase_wr.sfdc_id = '1';
        purchase_wr.source_system = '1';
        purchase_wr.target_system = '1';
        purchase_wr.po_result = '1';
        purchase_wr.sfdc_id = '1';
        purchase_wr.po_results = po_resultWr;
        purchase_wr.items = items;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putMissingRequiredItemsSupplier() {

        System.RestContext.request = generateRestRequestPUTGoodSupplier();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.error_code = 'test';
        poWr.message = 'test';
        po_resultWr.add(poWr);
        List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper> items = new List<XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper item = new XC_REST_PurchaseOrder_Inbound_U.ItemsWrapper();
        items.add(item);
        purchase_wr.sfdc_id = '1';
        purchase_wr.source_system = '1';
        purchase_wr.target_system = '1';
        purchase_wr.po_result = '1';
        purchase_wr.sfdc_id = '1';
        purchase_wr.po_results = po_resultWr;
        purchase_wr.items = items;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putMissingRequiredS4P() {

        System.RestContext.request = generateRestRequestPUTGoodS4P();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putMissingRequiredPoResultS4P() {

        System.RestContext.request = generateRestRequestPUTGoodS4P();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = '1';
        purchase_wr.po_result = '1';
        purchase_wr.po_results = po_resultWr;
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));
		
        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putWrongClient() {

        System.RestContext.request = generateRestRequestPUTWrongClient();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
    
    @isTest
    static void putWrongHeader() {

        System.RestContext.request = generateRestRequestPUTWrong();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        body.purchase_order = purchase_wr;
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty(body));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
    
	    
    @isTest
    static void putCatch() {

        System.RestContext.request = generateRestRequestPUTGoodS4P();
        System.RestContext.request.requestBody =  Blob.valueOf(JSON.serializePretty('{Test}'));

        System.RestContext.response = new RestResponse();

        test.startTest();

        XC_REST_PurchaseOrder_Inbound.doPut();         
        System.assertEquals(200, System.RestContext.response.statusCode, 'Wrong assert result');

        test.stopTest();
    }
	
    
    private static RestRequest generateRestRequestPUTGoodSupplier(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'PUT');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'Supplier');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }

    private static RestRequest generateRestRequestPUTGoodS4P(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'PUT');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'S4P');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestPUTWrong(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'PUT');
        request.addHeader('Operation', 'PUT');
        request.addHeader('ClientSystem', 'S4P');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestPUTWrongClient(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'PUT');
        request.addHeader('Operation', 'PUT');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('ClientSystem', 'TEST');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'PUT';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }

    private static RestRequest generateRestRequestPOSTGood(){

        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'POST');
        request.addHeader('DateTimeMessage', '20190123110030000');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }
    
    private static RestRequest generateRestRequestPOSTWrong(){
		XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper abc = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        RestRequest request = new RestRequest();
    
        request.addHeader('TransactionID', 'test');
        request.addHeader('Functionality', 'POST');
        request.addHeader('Operation', 'POST');
        request.addHeader('ClientSystem', 'test');
        request.addHeader('ServerSystem','test');  

        request.httpMethod = 'POST';
        request.requestURI = '/v1/PurchaseOrder/*';

        return request; 
    }
    
    @isTest
    static void putWOLI() {
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper reqWR = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert listWo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = listWo[0].Id;
        insert woli;
        System.debug('woli: '+woli+'\nwoli.id: '+woli.id);
        
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = woli.Id;
        purchase_wr.po_result = '1';
        purchase_wr.po_results = po_resultWr;
        reqWR.purchase_order = purchase_wr;
        
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper abc = XC_REST_PurchaseOrder_Inbound_U.purchaseOrderUpdate(reqWR);
        purchase_wr.po_result = 'OK';
        reqWR.purchase_order = purchase_wr;
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper defg = XC_REST_PurchaseOrder_Inbound_U.purchaseOrderUpdate(reqWR);
    }

    
    @isTest
    static void put3() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
        gii__PurchaseOrder__c po = [SELECT Id FROM gii__PurchaseOrder__c LIMIT 1];

        
        //XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper reqWR = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = po.Id;
        purchase_wr.po_result = '1';
        purchase_wr.target_system = 'S4Q';
        purchase_wr.po_results = po_resultWr;
        reqWR.purchase_order = purchase_wr;
        

        test.startTest();

                 
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper abc = XC_REST_PurchaseOrder_Inbound_U.purchaseOrderUpdate(reqWR);

        test.stopTest();
    }
    
    @isTest
    static void put4() {
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        List<gii__Product2Add__c> prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj[0]);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation( prodRefObj[0]);
        gii__PurchaseOrder__c po = [SELECT Id FROM gii__PurchaseOrder__c LIMIT 1];

        
        //XC_REST_PurchaseOrder_Inbound_U.RequestWrapper body = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper purchase_wr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper> po_resultWr = new List<XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper>();
        XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper poWr = new XC_REST_PurchaseOrder_Inbound_U.PoResultsWrapper();
        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper reqWR = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        poWr.class_message = '111';
        poWr.message_number = 1;
        poWr.message = '111';
        po_resultWr.add(poWr);
        purchase_wr.po_number = '1';
        purchase_wr.sfdc_id = po.Id;
        purchase_wr.po_result = '1';
        purchase_wr.target_system = 'S4Q';
        purchase_wr.po_result = 'OK';
        purchase_wr.po_results = po_resultWr;
        reqWR.purchase_order = purchase_wr;
        

        test.startTest();

                 
        XC_REST_PurchaseOrder_Inbound_U.ResponseWrapper abc = XC_REST_PurchaseOrder_Inbound_U.purchaseOrderUpdate(reqWR);

        test.stopTest();
    }

}