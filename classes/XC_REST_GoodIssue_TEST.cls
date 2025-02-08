/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  07/02/2020 
* @description XC_REST_GoodIssue_TEST – Test class for XC_REST_GoodIssue
*/ 
@isTest
public class XC_REST_GoodIssue_TEST {
    
    static testMethod void emptygoodissue(){

        test.startTest();
        
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 

        test.stopTest();
    }
    
	static testMethod void populategoodissue(){

        test.startTest();
        
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.locationCreation();
        
        List<gii__Product2Add__c> objProdRef= [Select id,name,gii__ProductCode__c from gii__Product2Add__c ];
        objProdRef[0].gii__ProductCode__c='Test';
        objProdRef[0].gii__PlanningPolicy__c=System.Label.giic_PlanningPolicy;
        //objProdRef[0].giic_ProcurementType__c=System.Label.giic_ProcurementTypeTransfer;
        objProdRef[0].gii__SerialControlled__c = true;
        objProdRef[0].gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.id;//lstAccount[0].Id;
        
        update objProdRef;
        
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.tOLineCreationSC(objProdRef);
        Map<Id,gii__TransferOrder__c> toMap = new Map<Id,gii__TransferOrder__c>([
            SELECT Id, Name, (
                SELECT Id, Name, gii__Product__r.gii__ProductCode__c, gii__Product__r.giic_EANReference__c
                FROM gii__TransferOrderLines__r ) 
                FROM gii__TransferOrder__c]);
        System.debug(toMap);
        
        XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        params.goods_issue.reference = 'XYZ';
        params.goods_issue.to_number = toMap.values()[0].Name;
        params.goods_issue.items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        XC_REST_GoodsIssue_U.ItemsWrapper item = new XC_REST_GoodsIssue_U.ItemsWrapper();
        item.qty = 1;
        item.product_code = toMap.values()[0].gii__TransferOrderLines__r[0].gii__Product__r.gii__ProductCode__c;
        item.to_line_number = toMap.values()[0].gii__TransferOrderLines__r[0].Name;
        params.goods_issue.items.add(item);
            
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
 
	private static RestRequest generatePOSTgoodIssue(XC_REST_GoodsIssue_U.RequestWrapper params, String method){

        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/GoodsIssue/*';

        
        request = addHeader(request);
   

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
    
    static testMethod void fail1(){

        test.startTest();
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
    }
    
	static testMethod void fail2(){

        test.startTest();
            
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        params.goods_issue.reference = 'XYZ';
        params.goods_issue.items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        XC_REST_GoodsIssue_U.ItemsWrapper item = new XC_REST_GoodsIssue_U.ItemsWrapper();
        item.qty = 1;
        item.product_code = 'ENEL-LB01';
        item.to_line_number = '006215';
        params.goods_issue.items.add(item);
            
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 

        test.stopTest();
    }
    
	static testMethod void fail3(){

        test.startTest();
            
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        params.goods_issue.reference = 'XYZ';
        params.goods_issue.to_number = 'TO-20200414-003305';
        params.goods_issue.items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        XC_REST_GoodsIssue_U.ItemsWrapper item = new XC_REST_GoodsIssue_U.ItemsWrapper();
        item.product_code = 'ENEL-LB01';
        item.to_line_number = '006215';
        params.goods_issue.items.add(item);
            
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 

        test.stopTest();
    }
    
    static testMethod void fail4(){

        test.startTest();
            
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        params.goods_issue.reference = 'XYZ';
        params.goods_issue.to_number = 'TO-20200414-003305';
        params.goods_issue.items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        XC_REST_GoodsIssue_U.ItemsWrapper item = new XC_REST_GoodsIssue_U.ItemsWrapper();
        item.qty = 1;
        item.to_line_number = '006215';
        params.goods_issue.items.add(item);
            
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void fail5(){

        test.startTest();
            
		XC_REST_GoodsIssue_U.RequestWrapper params = new XC_REST_GoodsIssue_U.RequestWrapper();  
        params.goods_issue = new XC_REST_GoodsIssue_U.GoodsIssueWrapper();
        params.goods_issue.document_date = Date.today();
        params.goods_issue.registration_date = Date.today();
        params.goods_issue.reference = 'XYZ';
        params.goods_issue.to_number = 'TO-20200414-003305';
        params.goods_issue.items = new List<XC_REST_GoodsIssue_U.ItemsWrapper>();
        XC_REST_GoodsIssue_U.ItemsWrapper item = new XC_REST_GoodsIssue_U.ItemsWrapper();
        item.qty = 1;
        item.product_code = 'ENEL-LB01';
        params.goods_issue.items.add(item);
            
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTgoodIssue(params, 'POST');
        XC_REST_GoodsIssue.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
	static testMethod void fail6(){

        test.startTest();
            
        XC_REST_GoodsIssue_U.SerialNumbersWrapper serialnumb = new XC_REST_GoodsIssue_U.SerialNumbersWrapper();
        serialnumb.serial_number = '';
        XC_REST_GoodsIssue_U.validateSerialNumber(serialnumb);    
        
        test.stopTest();
    }
    
    static testMethod void validateLotNumberTest(){
        XC_REST_GoodsIssue_U.LotNumbersWrapper abc = new XC_REST_GoodsIssue_U.LotNumbersWrapper();
        XC_REST_GoodsIssue_U.validateLotNumber(abc); 
    }
}