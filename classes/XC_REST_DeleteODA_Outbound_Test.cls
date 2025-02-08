@istest
public class XC_REST_DeleteODA_Outbound_Test {
 static testMethod void  DeleteODAOutboundResponseWrapper(){    
    	XC_CS001_InterfaceConfiguration__c interfaceConfig = new XC_CS001_InterfaceConfiguration__c (Name = 'DeleteODA', XC_interfaceName__c = 'DeleteODA', XC_activeInterface__c = true, XC_URL_Required__c = 'test//v1/purchase-order');
        insert interfaceConfig;  

        XC_REST_DeleteODA_Outbound_U.RequestWrapper wrapperInput = new XC_REST_DeleteODA_Outbound_U.RequestWrapper();
        XC_REST_DeleteODA_Outbound_U.ODAWrapper pr = new XC_REST_DeleteODA_Outbound_U.ODAWrapper();
        pr.target_system = 'S4D';
        //pr.supplier_code_io = '20000004509';
        pr.source_system = 'XCustomerB2C';
        wrapperInput.purchase_order = pr;

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new PurchaseOrder_Mock());
		XC_REST_DeleteODA_Outbound.DeleteODAOutboundResponseWrapper wrResp = XC_REST_DeleteODA_Outbound.callToPostDeleteODA(wrapperInput, 'S4D');
        System.assertEquals(0, Integer.valueOf(wrResp.result.result.error_code), 'Wrong assert result');
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