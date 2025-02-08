/**
 * *****************************************************************************************************.
 *
 * @author            : Luca Tedeschi ltedeschi@deloitte.it
 * @date Creation     : 03/06/2019
 * @date Modification : 
 * @description       : XC_REST_RetrieveInvoice_Mock – Mock class for XC_REST_RetrieveInvoice
 * *****************************************************************************************************
 */

@isTest
global class XC_REST_RetrieveInvoice_MOCK implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {    
        
        XC_UTIL_RESTCallout.CSWrapper intf = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_RetriveInvoice); 
        
        XC_REST_RetrieveInvoice.WrapperRequest wrReq = (XC_REST_RetrieveInvoice.WrapperRequest) JSON.deserialize(req.getBody(), XC_REST_RetrieveInvoice.WrapperRequest.class);
        
    	// Optionally, only send a mock response for a specific endpoint
        System.assertEquals(intf.url, req.getEndpoint());
        
        XC_REST_RetrieveInvoice.WrapperResponse resp = new XC_REST_RetrieveInvoice.WrapperResponse();
        resp.Result = new XC_UTIL_Integration.WrapperResult();
        resp.Result.ErrorCode = '0';
        
        if (wrReq.Invoice.Country == 'err') {
        	resp.Result.ErrorCode = '400';
        }
            
        resp.Result.errorMessage = 'Operation completed successfully';
        resp.Invoice = new XC_REST_RetrieveInvoice.InvoiceWrapper();
        resp.Invoice.InvoiceNumber = '1234';

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(resp, true));
        res.setStatusCode(200);
        return res;

    }
    

}