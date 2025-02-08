/**
 * The Class XC_REST_RetrieveInvoice.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 18/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse to retrive invoice
 **/


public without sharing class XC_REST_RetrieveInvoice {
    

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The Invoice Wrapper. */
        public InvoiceWrapper Invoice;
    }


    /**
     * The Class InvoiceWrapper.
     *
     * @description wrapper invoice of REST call
     */
    public class InvoiceWrapper {
        
        /** The Date. */
        public String DateInvoice;

        /** The Country. */
            public String Country;

        /** The LegalEntity. */
        public String LegalEntity;

        /** The InvoiceNumber. */
        public String InvoiceNumber;

        /** The invoiceType. */
        public String invoiceType;

        /** The documentCategory. */
        public String documentCategory;

        /** The FileBase64. */
        public String FileBase64;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.WrapperResult Result;

        /** The Invoice Wrapper. */
        public InvoiceWrapper Invoice;
    }

    /**
     * @param invoiceWr the invoice wrapper
     * @param serverSystem the server system
     * @return the wrapper response
     * @description method to send a request to retrive an invoice
     */
    public static WrapperResponse callToRetriveInvoice(InvoiceWrapper invoiceWr, String serverSystem) {
        WrapperResponse result = new WrapperResponse();

        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_RetriveInvoice);
        if(wrInterface.activeInterface) {

            String url = wrInterface.url;

            WrapperRequest wrReq = new WrapperRequest();
            wrReq.Invoice = invoiceWr;
            String body = JSON.serialize(wrReq, true);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('ReadInvoice', 'ReadInvoice', serverSystem);

            /* The request */
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[retriveInvoice] request -> ' + request);
            System.debug('[retriveInvoice] request BODY -> ' + request.getBody());

            /* The response */
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions.get('TransactionID'), 'RetriveInvoice');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'RetriveInvoice');
            
            System.debug('[retriveInvoice] response -> ' + response);
            System.debug('[retriveInvoice] response BODY -> ' + response.getBody());

            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        }

        return result;
    }



}