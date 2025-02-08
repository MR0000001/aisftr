/**
 * The Class XC_REST_RetrieveInvoicePDF.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/09/2019
 * @date Modification : 
 * @description       : XC_REST_RetrieveInvoicePDF – Rest Resourse to retrieve the invoice PDF
 */

public without sharing class XC_REST_RetrieveInvoicePDF {

    /**
     * @description The WrapperRequest.
     */
    public class WrapperRequest {
        public WrapperRetrieveInvoice RetrieveInvoice;
    }

    /**
     * @description The WrapperRetrieveInvoice.
     */
    public class WrapperRetrieveInvoice {
        // For Request
        public String InvoiceID;
        public String InvoiceSequential;
        public String ContractID;
        public String CompanyOwner;
        public String BusinessLine;
        public String ProcessDate;
        public String PaymentGateway;
        public String ContractNumber;
        public String Market;
        public String User;
        public String InvoiceCode;
        public String SystemDate;
        public String UserID;
        public String Password;
        public String InvoiceType;
        public String DocumentType;
        public String OrigenSystem;

        // For Response
        public String OrigenInvoice;
        public String InvoicePDF;
        public String FAROCode;
        public String FARODescription;
        public String MLCode;
        public String MLDescription;
        public String GdICode;
        public String GdIDescription;
        public String PrinterCode;
    }

    /**
     * @description The WrapperResponse.
     */
    public class WrapperResponse {
        public XC_UTIL_Integration.Result Result;
        public WrapperRetrieveInvoice RetrieveInvoice;
    }


    /**
     * CallToRetrieveInvoice.
     *
     * @param retrieveInvoiceWrRequest the wrapper request
     * @return the WrapperResponse
     * @description method to call RetrieveInvoicePDF API
     */
    public static WrapperResponse callToRetrieveInvoice(WrapperRetrieveInvoice retrieveInvoiceWrRequest) {

        WrapperResponse result = new WrapperResponse();
        result = validateRequest(retrieveInvoiceWrRequest);
        if(result.Result.ErrorCode != '0'){
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_RetrieveInvoicePDF); 
        if(isActiveInterface.activeInterface){

            WrapperRequest requestWr = new WrapperRequest();
            requestWr.RetrieveInvoice = retrieveInvoiceWrRequest;

            String url = isActiveInterface.url;
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'RetrieveInvoice', 'CommoditySpainB2C');
            String body = JSON.serialize(requestWr, true);

            /********************** Create outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[retrieveInvoicePDF] request -> ' + request);
            System.debug('[retrieveInvoicePDF] request BODY -> ' + body);

            /********************** Send outbound request *************************************/
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'RetrieveInvoicePDF');    
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'RetrieveInvoicePDF');    
            
            result = manageResponse(response);
      
		} else {
			result.Result = new XC_UTIL_Integration.Result();
            result.Result.ErrorCode = '0';
            result.Result.Message = 'Fake Response';
		} 

        return result;
    }


    /**
     * ValidateRequest.
     *
     * @param retrieveInvoiceWrRequest the wrapper request
     * @return the WrapperResponse
     * @description method to validate the mandatory fields
     */
    private static WrapperResponse validateRequest(WrapperRetrieveInvoice retrieveInvoiceWrRequest){
        WrapperResponse res = new WrapperResponse();
        res.Result = new XC_UTIL_Integration.Result();

        Map<String,String> mandatoryFields = new Map<String,String>{'InvoiceID' => retrieveInvoiceWrRequest.InvoiceID,
                                                                    'InvoiceSequential' => retrieveInvoiceWrRequest.InvoiceSequential,
                                                                    //'ContractID' => retrieveInvoiceWrRequest.ContractID,
                                                                    'CompanyOwner' => retrieveInvoiceWrRequest.CompanyOwner,
                                                                    'BusinessLine' => retrieveInvoiceWrRequest.BusinessLine,
                                                                    'PaymentGateway' => retrieveInvoiceWrRequest.PaymentGateway,
                                                                    //'ContractNumber' => retrieveInvoiceWrRequest.ContractNumber,
                                                                    'Market' => retrieveInvoiceWrRequest.Market,
                                                                    'InvoiceCode' => retrieveInvoiceWrRequest.InvoiceCode,
                                                                    'UserID' => retrieveInvoiceWrRequest.UserID,
                                                                    'Password' => retrieveInvoiceWrRequest.Password,
                                                                    'InvoiceType' => retrieveInvoiceWrRequest.InvoiceType,
                                                                    //'DocumentType' => retrieveInvoiceWrRequest.DocumentType,
                                                                    'OrigenSystem' => retrieveInvoiceWrRequest.OrigenSystem
                                                                    };

        for(String field : mandatoryFields.keySet()) {
            if(String.isBlank(mandatoryFields.get(field))) {
                res.Result.ErrorCode = '400';
                res.Result.Message = 'Missing mandatory field: RetrieveInvoice.' + field;
                return res;
            } 
        }

        if(retrieveInvoiceWrRequest.ProcessDate == null) {
            res.Result.ErrorCode = '400';
            res.Result.Message = 'Missing mandatory field: RetrieveInvoice.ProcessDate';
            return res;
        }

        if(retrieveInvoiceWrRequest.SystemDate == null) {
            res.Result.ErrorCode = '400';
            res.Result.Message = 'Missing mandatory field: RetrieveInvoice.SystemDate';
            return res;
        }

        res.Result.ErrorCode = '0';
        return res;
    }


    /**
     * ManageResponse.
     *
     * @param response the response
     * @return the WrapperResponse
     * @description method to manage the response
     */
    private static WrapperResponse manageResponse(HttpResponse response){
		
        WrapperResponse res = new WrapperResponse();
        res.Result = new XC_UTIL_Integration.Result();
        
        if(response == null) {
            res.Result.ErrorCode = '500';
            res.Result.Message = 'ERROR. ' + Label.XC_CL_ResponseServer;
            System.debug('[retrieveInvoicePDF] No response from the server');
            return res;
        } 

        System.debug('[retrieveInvoicePDF] response -> ' + response);
        if(response.getStatusCode() == 200) {
            //System.debug('[retrieveInvoicePDF] response Body -> ' + response.getBody());
            res = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            res.Result.ErrorCode = '500';
            res.Result.Message = 'ERROR. Status Code = ' + response.getStatusCode();
            //System.debug('[retrieveInvoicePDF] Status Code = ' + response.getStatusCode());
            //return res;
        }
        
		return res;
	}


}