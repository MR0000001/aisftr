/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 16/07/2019
* @date Modification dd/mm/yyyy
* @description XC_REST_ReadInvoiceList – REST class for ReadInvoiceList CommoditySpainB2C service
*/ 
public class XC_REST_ReadInvoiceList {

    /**
     * @description Call to ReadInvoiceList.
     * @param queryStringParameters the map with paramaters of query string
     * @return the XC_REST_Invoice_W.ReadInvoiceListResponse
     */
    public static XC_REST_Invoice_W.ReadInvoiceListResponse callToReadInvoiceList(Map<String, String> queryStringParameters) {
        System.debug('[ReadInvoiceList] callToReadInvoiceList >>> queryStringParameters -> ' + queryStringParameters);
        XC_REST_Invoice_W.ReadInvoiceListResponse result; // = new XC_REST_Invoice_W.ReadInvoiceListResponse();
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ReadInvoiceListCommoditySpain); 
        if(isActiveInterface.activeInterface){

			//String prefixUrl = isActiveInterface.url;
            //String url = XC_UTIL_RESTCallout.composeUrl(prefixUrl, queryStringParameters);
            System.debug('[ReadInvoiceList] callToReadInvoiceList url -> ' + isActiveInterface.url);
            String url = XC_UTIL_RESTCallout.composeURL(isActiveInterface.url, queryStringParameters); //paramMap
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readInvoiceList', 'CommoditySpainB2C');
            
            //String body = '{ "RetrieveInvoice ": { "Documentation" : { "DocumentationID" : "'+ queryStringParameters.get('DocumentationID') +'" } } }';

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, ''); //body
            System.debug('[ReadInvoiceList] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'ReadInvoiceList');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ReadInvoiceList');

            System.debug('[ReadInvoiceList] response -> ' + response);

            /********************* Parse response ********************************************/
            result = manageResponse(response);

		} else {
            result = manageFakeResponse();
        }

		return result;
    }

    /**
     * @description Call to ReadInvoiceList.
     * @param queryStringParameters the map with paramaters of query string
     * @return the XC_REST_Invoice_W.ReadInvoiceListResponse
     */
    public static XC_REST_Invoice_W.ReadInvoiceListResponse callToReadInvoiceList(Map<String, String> queryStringParameters, String country) {
        System.debug('[ReadInvoiceList] callToReadInvoiceList >>> queryStringParameters -> ' + queryStringParameters);
        XC_REST_Invoice_W.ReadInvoiceListResponse result; // = new XC_REST_Invoice_W.ReadInvoiceListResponse();
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_ReadInvoiceListCommoditySpain, country); 
        if(isActiveInterface.activeInterface){

			//String prefixUrl = isActiveInterface.url;
            //String url = XC_UTIL_RESTCallout.composeUrl(prefixUrl, queryStringParameters);
            System.debug('[ReadInvoiceList] callToReadInvoiceList url -> ' + isActiveInterface.url);
            String url = isActiveInterface.url; // XC_UTIL_RESTCallout.composeURL(isActiveInterface.url, queryStringParameters); //paramMap
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readInvoiceList', isActiveInterface.serverSystem);
            
            String body = '{ "RetrieveInvoice": { "Documentation" : { "DocumentationID" : "'
                                                                        + queryStringParameters.get('DocumentationID') +'", '+
                                                                      '"DocumentationType" : "' 
                                                                        + queryStringParameters.get('DocumentationType') +'"} } }';

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body); 
            System.debug('[ReadInvoiceList] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'ReadInvoiceList');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ReadInvoiceList');

            System.debug('[ReadInvoiceList] response -> ' + response);

            /********************* Parse response ********************************************/
            result = manageResponse(response);

		} else {
            result = manageFakeResponse();
        }

		return result;
    }

    /**
	* @description init the Commodity ReadInvoiceList Request
	* @param paramsMap params Map
	* @return the HttpRequest
	*/
	public static HttpRequest initReadInvoiceListRequest(Map<String, String> paramsMap){
       System.debug('@@@@ initReadCaseRequest - paramsMap--->'+paramsMap);
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ReadInvoiceListCommoditySpain);
        System.debug('@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramsMap);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readInvoiceList', 'CommoditySpainB2C');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, '');
			System.debug('[InvoiceOutbound] request -> ' + request);
			return request;
        }

		throw new XC_UTIL_RESTCallout.NotActiveInterfaceException();
    }
    
    /**
     * @description Manage response.
     * @param response the response
     * @return the XC_REST_Invoice_W.ReadInvoiceListResponse
     */
    @TestVisible
    public static XC_REST_Invoice_W.ReadInvoiceListResponse manageResponse(HttpResponse response){
        XC_REST_Invoice_W.ReadInvoiceListResponse wrapperResult = new XC_REST_Invoice_W.ReadInvoiceListResponse();
        try {
            System.debug('[ReadInvoiceList] response -> ' + response);
            System.debug('[ReadInvoiceList] response Body -> ' + response.getBody());
            String jsonBodyResponse = response.getBody();
            jsonBodyResponse = jsonBodyResponse.replace('""', 'null');
            System.debug('jsonBodyResponse: ' + jsonBodyResponse);
        	wrapperResult = (XC_REST_Invoice_W.ReadInvoiceListResponse) JSON.deserialize(jsonBodyResponse, XC_REST_Invoice_W.ReadInvoiceListResponse.class);
        
        } catch(Exception e){
            wrapperResult.Result.Message = 'INTERNAL ERROR: ' + e.getMessage();
        	wrapperResult.Result.ErrorCode = '500';
        }

        return wrapperResult;
    }

    /**
     * @description Manage fake response
     * @return a XC_REST_Invoice_W.ReadInvoiceListResponse
     */
    @TestVisible
    public static XC_REST_Invoice_W.ReadInvoiceListResponse manageFakeResponse(){
        String jsonFakeResponse = 
        '{'+
            '"Result" : {'+
                '"ErrorCode" : "0",'+
                '"Message" : "" },'+
              '"RetrieveInvoice" : {'+
                '"Invoice" : [{'+
                '"InvoiceID" : "AI_00001",'+
                '"BusinessLine" : "00001",'+
                '"ContractNumber" : "ABC111222444",'+
                '"InvoiceNumber" : "INV0001",'+
                '"InvoiceCode" : "INCODE1",'+
                '"ContractID" : "CR_00001",'+
                '"CompanyOwner" : "25",'+
                '"IssueDate" : "2019-07-31",'+
                '"Amount" : "10000",'+
                '"InvoiceStatus" : "Open",'+
                '"ObligationPaid" : true,'+
                '"InvoiceSequential" : "1",'+
                '"InvoiceReference" : "Test Ref",'+
                '"ContractSequential" : "CON-000255",'+
                '"ObligationSequential" : "+OBL_00041",'+
                '"FractionationIndicator" : "test FR",'+
                '"AuthorizedRegistrationDate" : "2019-03-01",'+
                '"DateFrom" : "2019-12-31",'+
                '"DateTo" : "2019-01-01",'+
                '"TermEndDate" : "2019-12-31",'+
                '"Address" : { '+
                    '"AddressType"   : "Main Address",'+
                    '"Country"       : "Spain",'+
                    '"Category"      : "Main House",'+
                    '"Address"       : "Diana",'+
                    '"StreetType"    : "Via",'+
                    '"Street"        : "Diana",'+
                    '"StreetNumber"  : "200",'+
                    '"Floor"         : "1",'+
                    '"Stair"         : "1A",'+
                    '"Door"          : "4",'+
                    '"ZipCode"       : "80100",'+
                    '"Region"        : "Lazio",'+
                    '"Province"      : "Roma",'+
                    '"City"          : "Albano"'+
                ' }'+
              '}]'+
            '}'+
        '}';
        XC_REST_Invoice_W.ReadInvoiceListResponse wrapperResult = (XC_REST_Invoice_W.ReadInvoiceListResponse) JSON.deserialize(jsonFakeResponse, XC_REST_Invoice_W.ReadInvoiceListResponse.class);
        return wrapperResult;
    }
}