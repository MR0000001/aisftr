/**
* @author            : Simone Trenta - strenta@deloitte.it
* @date Creation     : 22/07/2020
* @date Modification : dd/mm/yyyy
* @description XC_REST_DataExtractor_TEST
*/ 

@isTest
public class XC_REST_DataExtractor_TEST {
    
    static testMethod void empty6(){
        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert w;
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = w[0].id;
        params.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY = 'asd';
		params.FILE.DOCUMENT.TEMPLATE.DA.DATA_S = '2020-06-09 11:42:57.000';	
        params.FILE.DOCUMENT.TEMPLATE.DA.DATA_E = '';	
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void empty5(){
        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert w;
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = w[0].id;
        params.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY = 'asd';
		params.FILE.DOCUMENT.TEMPLATE.DA.DATA_S = '2020-06-09 11:42:57.000';	
        params.FILE.DOCUMENT.TEMPLATE.DA.DATA_E = '2020-06-09 11:42:57.00';	
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void empty4(){
        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert w;
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = w[0].id;
        params.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY = 'asd';
		params.FILE.DOCUMENT.TEMPLATE.DA.DATA_S = '2020-06-09 11:42:57.00';	
        params.FILE.DOCUMENT.TEMPLATE.DA.DATA_E = '2020-06-09 11:42:57.000';	
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
   	static testMethod void empty3(){
        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert w;
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = w[0].id;
        params.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY = 'asd';
		params.FILE.DOCUMENT.TEMPLATE.DA.DATA_S = '2020-06-09 11:42:57.000';	
        params.FILE.DOCUMENT.TEMPLATE.DA.DATA_E = '2020-06-09 11:42:57.000';	
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void ok(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Installation - Gas', 'Installation');
        String rt =  Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ESP_WorkOrder').getRecordTypeId();
        for(WorkOrder wo :woList) 
        {
            wo.RecordTypeId = rt;
            wo.XC_Segment__c ='B2C';
            
        }
        insert woList;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'WorkOrder - SERVICE_REPORT.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = woList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = woList[0].id;
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
        
    }
    
    static testMethod void empty2(){
        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert w;
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        params.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = w[0].id;
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void empty1(){
        
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        params.FILE = new XC_REST_DataExtractor_U.DataExtractorWrapper();
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    static testMethod void empty(){
        
        XC_REST_DataExtractor_U.WrapperRequest params = new XC_REST_DataExtractor_U.WrapperRequest();  
        
        test.startTest();
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOST(params, 'POST');
        XC_REST_DataExtractor.doPost();
        system.assertEquals(200, RestContext.response.statusCode); 
        
        test.stopTest();
    }
    
    
    private static RestRequest generatePOST(XC_REST_DataExtractor_U.WrapperRequest params, String method){
        
        RestRequest request = new RestRequest();
        
        request.httpMethod = 'POST';
        request.requestURI = '/v1/DataExtractor/*';
        
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
    
}