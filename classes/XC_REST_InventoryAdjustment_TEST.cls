@isTest
public without sharing class XC_REST_InventoryAdjustment_TEST {

    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
    }
    
    static testMethod void put(){

        XC_REST_InventoryAdjustment_U.RequestWrapper req = new XC_REST_InventoryAdjustment_U.RequestWrapper();
        List<XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper> warehouse_inventories = new List<XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper>();
		XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper w = new XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper();
        
        req.warehouse_inventories = warehouse_inventories;
	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_InventoryAdjustment.doPut();
        
        req.warehouse_inventories.add(w);
        System.RestContext.request = generatePUTRequest(req, 'test');
        XC_REST_InventoryAdjustment.doPut();
        
        req.warehouse_inventories = new List<XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper>();
		w = new XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper();
        w.warehouse_code = 'asd';
        w.quantity = 1;
        w.location = 'asd';
        w.reason = 'asd';
        req.warehouse_inventories.add(w);
        System.RestContext.request = generatePUTRequest(req, 'test');
        XC_REST_InventoryAdjustment.doPut();
        
        req.warehouse_inventories = new List<XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper>();
		w = new XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper();
        w.warehouse_code = 'asd';
        w.quantity = 1;
        w.location = 'asd';
        w.reason = 'asd';
        w.product_code = 'asd';
        req.warehouse_inventories.add(w);
        System.RestContext.request = generatePUTRequest(req, 'test');
        XC_REST_InventoryAdjustment.doPut();
        
        XC_REST_InventoryAdjustment_U.SerialNumbersWrapper sn = new XC_REST_InventoryAdjustment_U.SerialNumbersWrapper();
        sn.serial_number = 'asd';
        req.warehouse_inventories = new List<XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper>();
		w = new XC_REST_InventoryAdjustment_U.WharehouseInventoriesWrapper();
        w.warehouse_code = 'asd';
        w.quantity = 1;
        w.location = 'asd'; 
        w.reason = 'asd';
        w.product_code = 'asd';
        w.serial_numbers = new List<XC_REST_InventoryAdjustment_U.SerialNumbersWrapper>();
        w.serial_numbers.add(sn);
        req.warehouse_inventories.add(w);
        System.RestContext.request = generatePUTRequest(req, 'test');
        XC_REST_InventoryAdjustment.doPut();
        
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }

    
    static testMethod void emptyput(){

        XC_REST_InventoryAdjustment_U.RequestWrapper req = new XC_REST_InventoryAdjustment_U.RequestWrapper();

	
        test.startTest();
        
        System.RestContext.request = generatePUTRequest(req, 'test');
        
        XC_REST_InventoryAdjustment.doPut();
        system.assertEquals(RestContext.response.statusCode, 200);        

        test.stopTest();
    }
    
    private static RestRequest generatePUTRequest(XC_REST_InventoryAdjustment_U.RequestWrapper req, String operation){

        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'PUT';
    	request.requestURI = '/v1/InventoryAdjustment/*'; 

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

}