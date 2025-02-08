@isTest
public without sharing class XC_REST_GoodsReceipt_TEST {

    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
    }
    
    static testMethod void emptypost5(){
		XC_REST_GoodsReceipt_Inbound_U.coverage();
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.po_id = 'asd';
        a.items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper o = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        o.qty = 3;
        o.warehouse_code = 'asd';
        o.location_name = 'asd';
        o.product_code = 'asd';
        o.pol_id = 'asd';
        o.serial_numbers = new List<XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper>();
        XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper sn = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
        o.serial_numbers.add(sn);
        a.items.add(o);
        req.goods_receipt = a;
	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptypost4(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.po_id = 'asd';
        a.items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper o = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        o.qty = 3;
        o.warehouse_code = 'asd';
        o.location_name = 'asd';
        a.items.add(o);
        req.goods_receipt = a;
	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptypost3(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.po_id = 'asd';
        a.items = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper o = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        a.items.add(o);
        req.goods_receipt = a;
	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    
    static testMethod void emptypost2(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.po_id = 'asd';
        req.goods_receipt = a;
	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptypost1(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.po_number = '123';
        req.goods_receipt = a;

	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptypost(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        req.goods_receipt = a;

	
        test.startTest();
        
        System.RestContext.request = generatePostRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    
    static testMethod void emptyput6(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.source_system = 'asd';
        a.target_system = 'oj';
        a.goods_receipts_result = 'lk';
   
        req.goods_receipt = a;
		
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'Create');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptyput5(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.source_system = 'asd';
        a.target_system = 'oj';
        a.goods_receipts_result = 'lk';
   
        req.goods_receipt = a;
		
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'UpdateCancellation');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptyput4(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.source_system = 'asd';
        a.target_system = 'oj';
        a.goods_receipts_result = 'lk';
   
        req.goods_receipt = a;
		
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'Update');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void emptyput3(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.source_system = 'asd';
        a.target_system = 'oj';
        a.goods_receipts_result = 'lk';
   
        req.goods_receipt = a;
		
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }

    
    static testMethod void emptyput2(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        a.source_system = 'asd';
        a.target_system = 'oj';
        a.goods_receipts_result = 'lk';
        a.gr_results = new List<XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper>();
        XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper gr = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
        a.gr_results.add(gr);
        req.goods_receipt = a;
		
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    
    static testMethod void emptyput(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        a.sfdc_id = 'ads';
        req.goods_receipt = a;

	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    static testMethod void put1(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        

        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
     
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper b = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper c = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper d = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
        
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        Map<String, String> mapHeader = generateMapHeader('Update');
        //XC_REST_GoodsReceipt_Inbound_U.goodReceiptUpdate(reqWR,  mapHeader);
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }

    
    static testMethod void put(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();

        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper b = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper c = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper d = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
        
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        Map<String, String> mapHeader = generateMapHeader('Update');
        //XC_REST_GoodsReceipt_Inbound_U.goodReceiptUpdate(reqWR,  mapHeader);
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }

    
    static testMethod void emptyput1(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();

	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    private static RestRequest generatePUTRequest(XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'PUT';
    	request.requestURI = '/v1/GoodsReceipt/*'; 

        if(operation!='err_header'){
            request = addHeader(request);
        }
        
        request.addHeader('Operation', operation);
        
        

		request.requestBody = Blob.valueOf(JSON.serializePretty(req));

        return request;
    }
    
     private static RestRequest generatePOSTRequest(XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'POST';
    	request.requestURI = '/v1/GoodsReceipt/*'; 

        if(operation!='err_header'){
            request = addHeader(request);
        }

		request.requestBody = Blob.valueOf(JSON.serializePretty(req));

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
    
    private static Map<String, String> generateMapHeader(String Operation){
         Map<String, String> request  = new  Map<String, String>();
         request.put('TransactionID', 'AXYZ');
		 request.put('DateTimeMessage', '20181207103900000');
		 request.put('Operation', Operation);
		 request.put('Functionality', 'AXYZ');
		 request.put('ClientSystem', 'AXYZ');
		 request.put('ServerSystem', 'AXYZ');
         request.put('debugMode', 'AXYZ');
         return request;
        
    }
    
     
    static testMethod void post(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();

        test.startTest();
        
        System.RestContext.request = generatePOSTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
  
        
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    
    private static XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper generateGoodsReceiptWrapper(){
        gii__PurchaseOrderReceipt__c abc = new gii__PurchaseOrderReceipt__c();
        insert abc;
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper w = new XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper();
        w.document_date =System.today() ;
        w.reference='';
        w.registration_date=System.today();
        w.source_system='';
        w.sfdc_id='';
        w.target_system='';
        w.po_number='';
        w.to_number='1';
        w.rma_number='';
        w.sfdc_id=abc.id;
        w.po_id='';
        w.to_id='';
        w.rma_id='';
        List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper> itemsWrapperList = new List<XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper>();
        w.items = itemsWrapperList;  
        
        w.goods_receipt_number='';
        w.accounting_period= 2;
        w.goods_receipts_result='';
        return w;
       
        
    }
    
    @isTest static  void post2(){

        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper req = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();

        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_GoodsReceipt_Inbound.doPost();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper(); 
        XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper b = new XC_REST_GoodsReceipt_Inbound_U.ItemsWrapper();
        XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper c = new XC_REST_GoodsReceipt_Inbound_U.SerialNumbersWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper d = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
        
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        Map<String, String> mapHeader = generateMapHeader('Create');
        //XC_REST_GoodsReceipt_Inbound_U.caseCreate(reqWR,  mapHeader);
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }

    
    @isTest static void caseUpdateTest(){
               Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__PurchaseOrderReceipt__c por = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                    FROM gii__PurchaseOrderReceipt__c  LIMIT 1];
        System.debug('PORRRR = '+por);
        Map<String, String> mapHeader = new  Map<String, String>();
        XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
        XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper();
        a.sfdc_id = por.Id;
        a.goods_receipts_result = 'OK';
        reqWR.goods_receipt = a;
        
        
        XC_REST_GoodsReceipt_Inbound_U.caseUpdate(reqWR, mapHeader);
        
    }
    
     @isTest static void caseUpdateNOTOKTest2(){
               Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__PurchaseOrderReceipt__c por = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                    FROM gii__PurchaseOrderReceipt__c  LIMIT 1];
         Map<String, String> mapHeader = new  Map<String, String>();
         XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
         XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper();
         List<XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper> grResultList = new List<XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper>();
         XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper gr = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
         gr.message = 'errorTest';
         gr.message_number = 1;
         gr.class_message = 'XC_REST_GoodsReceipt_TEST';
         grResultList.add(gr);
         a.sfdc_id = por.Id;
         a.gr_results = grResultList;
         reqWR.goods_receipt = a;
         XC_REST_GoodsReceipt_Inbound_U.caseUpdate(reqWR,mapHeader);
            
        
    }
    
    
    
     @isTest static void caseCreateTest(){
               Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        gii__PurchaseOrderReceipt__c por = [SELECT Id, giic_IntegrationStatus__c,giic_IntegrationOperation__c,Giic_TargetSystem__c , giic_MaterialDocument__c, giic_YearDocument__c
                                    FROM gii__PurchaseOrderReceipt__c  LIMIT 1];
         Map<String, String> mapHeader = new  Map<String, String>();
         XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
         XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper();
         a.sfdc_id = por.Id;
         a.to_id =  Giic_UtilityClass_Test.objTO.Id;
         reqWR.goods_receipt = a;
         XC_REST_GoodsReceipt_Inbound_U.caseCreate(reqWR,mapHeader);
            
        
    }
    
    
     
     @isTest static void caseUpdateCancellationTest(){
               Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
        upsert Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderReceiptStaging__c POStaging= new gii__PurchaseOrderReceiptStaging__c(giic_IntegrationOperation__c='Cancellation Request', giic_IntegrationStatus__c='Not Started', giic_PurchaseOrder__c=giic_UtilityClass_Test.objPO.Id);
        insert POStaging;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
         
         Map<String, String> mapHeader = new  Map<String, String>();
         XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
         XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper();
         a.sfdc_id = POStaging.Id;
         a.goods_receipts_result = 'OK';
         a.to_id =  Giic_UtilityClass_Test.objTO.Id;
         reqWR.goods_receipt = a;
         XC_REST_GoodsReceipt_Inbound_U.caseUpdateCancellation(reqWR,mapHeader);
            
        
    }
    
    
     @isTest static void caseUpdateCancellationNOTOKTest(){
               Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(prodRefObj);
        upsert Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderReceiptStaging__c POStaging= new gii__PurchaseOrderReceiptStaging__c(giic_IntegrationOperation__c='Cancellation Request', giic_IntegrationStatus__c='Not Started', giic_PurchaseOrder__c=giic_UtilityClass_Test.objPO.Id);
        insert POStaging;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
         
         Map<String, String> mapHeader = new  Map<String, String>();
         XC_REST_GoodsReceipt_Inbound_U.RequestWrapper reqWR = new XC_REST_GoodsReceipt_Inbound_U.RequestWrapper();
         XC_REST_GoodsReceipt_Inbound_U.GoodsReceiptWrapper a = generateGoodsReceiptWrapper();
         List<XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper> grResultList = new List<XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper>();
         XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper gr = new XC_REST_GoodsReceipt_Inbound_U.GrResultsWrapper();
         gr.message = 'errorTest';
         gr.message_number = 1;
         gr.class_message = 'XC_REST_GoodsReceipt_TEST';
         grResultList.add(gr);
         a.sfdc_id = POStaging.Id;
        
         a.to_id =  Giic_UtilityClass_Test.objTO.Id;
          a.gr_results = grResultList;
         reqWR.goods_receipt = a;
         XC_REST_GoodsReceipt_Inbound_U.caseUpdateCancellation(reqWR,mapHeader);
            
        
    }
    

}