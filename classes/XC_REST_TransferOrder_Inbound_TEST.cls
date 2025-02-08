/**
* @author Simone Trenta - strenta@deloitte.it 
* @date Creation 15/10/2019 
* @description REST INTERFACE : 
*/
@isTest
public with sharing class XC_REST_TransferOrder_Inbound_TEST {
    
    static testMethod void ok(){
        
        List<Id> recordID=new List<id>();
        // Local Warehouse creation
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWh.giic_ServerSystem__c='Redsla';
        update Giic_UtilityClass_Test.objWh;
        //TransferOrderCreation
        Giic_UtilityClass_Test.transferOrderCreation();
        //Product creation 
        Giic_UtilityClass_Test.productCreation();      
        //Query on Product
        gii__Product2Add__c[] objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                            gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                           ];
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        //TOLine
        Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);        
        List<gii__TransferOrder__c> trasferOrderList = new List<gii__TransferOrder__c>([SELECT Id, gii__Account__r.Name ,gii__FromWarehouse__r.giic_WarehouseCode__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseCode__c,gii__OrderDate__c,gii__RequiredDate__c,
                                                                                        gii__ShipToZipPostalCode__c,gii__ShipToStreet__c,gii__ShipToState__c,gii__ShipToName__c,
                                                                                        gii__ShipToCity__c,gii__ShipToCountry__c,Name,giic_status__c,giic_TransferOrderType__c,
                                                                                        gii__Account__r.Phone,gii__Account__r.PrimaryEmail__c, gii__FromWarehouse__r.giic_WarehouseType__c,
                                                                                        gii__FromWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__FromWarehouse__r.giic_ParentWarehouse__r.giic_ServerSystem__c,
                                                                                        gii__TransferToWarehouse__r.giic_WarehouseType__c, 
                                                                                        (SELECT ID, gii__Quantity__c,gii__Product__r.gii__ProductReference__r.Name,
                                                                                         gii__Product__r.gii__ProductCode__c ,gii__RequiredDate__c,Name,
                                                                                         gii__Product__r.giic_EANReference__c         
                                                                                         FROM gii__TransferOrderLines__r)  
                                                                                        FROM gii__TransferOrder__c 
                                                                                       ]);
        
  
        gii__TransferOrderLine__c tli = new gii__TransferOrderLine__c();
        tli.gii__TransferOrder__c = trasferOrderList[0].id;
        tli.gii__Product__c = objProdRef[0].id;
        tli.gii__Quantity__c = 2;
        insert tli;
        
        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper tr = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper();
        tr.status = 'test';
        tr.to_id = trasferOrderList[0].id;
        
        params.transfer_order = tr;
        
               List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper> iw = new List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper>();
        XC_REST_TransferOrder_Inbound_U.ItemsWrapper i = new XC_REST_TransferOrder_Inbound_U.ItemsWrapper();
        i.tol_id = tli.id;
        iw.add(i);
        tr.items = iw;
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }
    
    static testMethod void err2(){

        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper tr = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper();
        tr.status = 'test';
        tr.to_id = '123';
        
        params.transfer_order = tr;
        
        
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }

    static testMethod void err1(){
        
        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper tr = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper();
        tr.status = 'test';
        tr.to_id = '1123';
        
        List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper> iw = new List<XC_REST_TransferOrder_Inbound_U.ItemsWrapper>();
        XC_REST_TransferOrder_Inbound_U.ItemsWrapper i = new XC_REST_TransferOrder_Inbound_U.ItemsWrapper();
        iw.add(i);
        tr.items = iw;
        
        params.transfer_order = tr;
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }
    
    static testMethod void err(){
        
        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper tr = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper();
        tr.status = 'test';
        params.transfer_order = tr;
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }
    
    static testMethod void empyRequest1(){
        
        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper tr = new XC_REST_TransferOrder_Inbound_U.TransferOrderWrapper();
        params.transfer_order = tr;
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }
    
    static testMethod void empyRequest(){
        
        XC_REST_TransferOrder_Inbound_U.RequestWrapper params = new XC_REST_TransferOrder_Inbound_U.RequestWrapper();
        
        test.startTest();
        
        System.RestContext.request = generatPUTRequest(params, 'OK');
        XC_REST_TransferOrder_Inbound.doPut();
        system.assertEquals(RestContext.response.statusCode, 200); 
        
        test.stopTest();
    }
    
    
    private static RestRequest generatPUTRequest(XC_REST_TransferOrder_Inbound_U.RequestWrapper params, String operation){
        
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        
        request.httpMethod = 'PUT';
        request.requestURI = '/v1/TransferOrder/*';
        
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