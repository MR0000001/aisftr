/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       18/03/2020
 * @date Modification   
 * @description         test class for XC_REST_PurchaseOrder_Outbound
*/


@isTest
public without sharing class XC_REST_PurchaseOrder_Outbound_TEST {

    @isTest
    public static void testPostPurchase(){

        XC_CS001_InterfaceConfiguration__c interfaceConfig = new XC_CS001_InterfaceConfiguration__c (Name = 'CreatePurchaseOrder', XC_interfaceName__c = 'CreatePurchaseOrder', XC_activeInterface__c = true, XC_URL_Required__c = 'test//v1/purchase-order');
        insert interfaceConfig;  

        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrapperInput = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper pr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        pr.target_system = 'S4D';
        pr.supplier_code_io = '20000004509';
        pr.source_system = 'XCustomerB2C';
        wrapperInput.purchase_order = pr;

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new PurchaseOrder_Mock());
		XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper wrResp = XC_REST_PurchaseOrder_Outbound.callToPostPurchaseOrder(wrapperInput, 'S4D');
        System.assertEquals(0, Integer.valueOf(wrResp.result.result.error_code), 'Wrong assert result');
        test.stopTest();
    }


    @isTest
    public static void testPutPurchase(){

        XC_CS001_InterfaceConfiguration__c interfaceConfig = new XC_CS001_InterfaceConfiguration__c (Name = 'UpdatePurchaseOrder', XC_interfaceName__c = 'UpdatePurchaseOrder', XC_activeInterface__c = true, XC_URL_Required__c = 'test//v1/purchase-order');
        insert interfaceConfig;  

        XC_REST_PurchaseOrder_Inbound_U.RequestWrapper wrapperInput = new XC_REST_PurchaseOrder_Inbound_U.RequestWrapper();
        XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper pr = new XC_REST_PurchaseOrder_Inbound_U.PurchaseOrderWrapper();
        pr.po_number = 'PONumberVal';
        pr.sfdc_id = 'SFDCIDVal';
        wrapperInput.purchase_order = pr;

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new PurchaseOrder_Mock());
		XC_REST_PurchaseOrder_Outbound.PurchaseOrderInboundResponseWrapper wrRes = XC_REST_PurchaseOrder_Outbound.callToPutPurchaseOrder(wrapperInput, 'S4D');
        System.assertEquals(0, Integer.valueOf(wrRes.result.result.error_code), 'Wrong assert result');
        test.stopTest();
    }



    public without sharing class PurchaseOrder_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('/v1/purchase-order')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"result": {"message": "Operation completed successfully", "error_code": "0"}}');
                response.setStatusCode(200); 
            }
            return response;
        }
    }

}