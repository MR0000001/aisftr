/**
 * @author Federico Amici federico.amici@nttdata.com
 * @date Creation 28/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_REST_Case_Outbound – Class that handles the Outbound REST for Case object
 * @Note     The replacements in the JSON have to be deleted, except for Case -> Case_List
 */

public class XC_REST_Case_Outbound { 

    /**
     * @description Call to create case.
     * @param caseWr the case wrapper
     * @return the XC_REST_Case_W.WrapperCaseResponseUpsert
     */
    public static XC_REST_Case_W.WrapperCaseResponseUpsert callToCreateCase(XC_UTIL_Case.CaseRESTWrapper caseWr) {
        XC_REST_Case_W.WrapperCaseResponseUpsert rw = new XC_REST_Case_W.WrapperCaseResponseUpsert();
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CaseOutboundYourban'); 
        if(isActiveInterface.activeInterface){ 
            /* Create the parts for the response */
            String url = isActiveInterface.url+'/'+caseWr.CaseID;
            YourbanToken emobTok = new YourbanToken(caseWr, url, 'POST');
            Id jobId = System.enqueueJob(emobTok);
            
            rw.Result.ErrorCode = '0';
        }else{
            rw.Result.ErrorCode = '0';
            rw.Result.Message = Label.XC_CL_FakeResponse;
        }
        
        return rw;
    }



    /**
     * @description Call to update case.
     * @param caseWr the case wrapper
     * @return the XC_REST_Case_W.WrapperCaseResponseUpsert
     */
    public static XC_REST_Case_W.WrapperCaseResponseUpsert callToUpdateCase(XC_UTIL_Case.CaseRESTWrapper caseWr) {
        XC_REST_Case_W.WrapperCaseResponseUpsert rw = new XC_REST_Case_W.WrapperCaseResponseUpsert();
    
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('CaseOutboundYourban'); 
        if(isActiveInterface.activeInterface){ 
            /* Create the parts for the response */
            String url = isActiveInterface.url+'/'+caseWr.CaseID;
            YourbanToken emobTok = new YourbanToken(caseWr, url, 'PUT');
            Id jobId = System.enqueueJob(emobTok);
            
            rw.Result.ErrorCode = '0';
        }else{
            rw.Result.ErrorCode = '0';
            rw.Result.Message = Label.XC_CL_FakeResponse;
        }
        
        return rw;
    }


    /**
     * @description Call to get case.
     *
     * @param queryStringParameters the map with paramaters of query string
     * @return the XC_REST_Case_W.WrapperCaseResponseGET
     */
    // GET
    public static XC_REST_Case_W.WrapperCaseResponseGET callToGetCase(Map<String, String> queryStringParameters) {
        System.debug('[CaseOutbound] callToGetCase >>> queryStringParameters -> ' + queryStringParameters);
        XC_REST_Case_W.WrapperCaseResponseGET result = new XC_REST_Case_W.WrapperCaseResponseGET();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CaseOutbound); 
        if(isActiveInterface.activeInterface){
            
            queryStringParameters.put('StartDate','1900-01-01');
            queryStringParameters.put('EndDate','2030-01-01');

			String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeUrl(prefixUrl, queryStringParameters);
            System.debug('[CaseOutbound] callToGetCase url -> ' + url);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readCase', 'CommoditySpainB2C');
            
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            System.debug('[CaseOutbound] request -> ' + request);

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'CaseOutbound'); //XC_REST_Case_Outbound
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'CaseOutbound'); //XC_REST_Case_Outbound
            System.debug('[CaseOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            result = manageResponseGET(response);

		} else {
            result = manageFakeResponseGET();
            //result.Result.ErrorCode = '0';
            //result.Result.Message = 'Fake Response';
        }

		return result;
    }

    /**
     * @description Call to get case.
     *
     * @param queryStringParameters the map with paramaters of query string
     * @return the XC_REST_Case_W.WrapperCaseResponseGET
     */
    // GET
    public static XC_REST_Case_W.WrapperCaseResponseGET callToGetCase(Map<String, String> queryStringParameters, String country) {
        return callToGetCase(queryStringParameters, country, true);
    }

    /**
     * @description Call to get case.
     *
     * @param queryStringParameters the map with paramaters of query string
     * @return the XC_REST_Case_W.WrapperCaseResponseGET
     */
    // GET
    public static XC_REST_Case_W.WrapperCaseResponseGET callToGetCase(Map<String, String> queryStringParameters, String country, Boolean insertLoggin) {
        System.debug('[CaseOutbound] callToGetCase >>> queryStringParameters -> ' + queryStringParameters);
        XC_REST_Case_W.WrapperCaseResponseGET result = new XC_REST_Case_W.WrapperCaseResponseGET();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_CaseOutbound, country); 
        if(isActiveInterface.activeInterface){
            
            queryStringParameters.put('StartDate','1900-01-01');
            queryStringParameters.put('EndDate','2030-01-01');

			String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeUrl(prefixUrl, queryStringParameters);
            System.debug('[CaseOutbound] callToGetCase url -> ' + url);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readCase', isActiveInterface.serverSystem);
            
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            System.debug('[CaseOutbound] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'CaseOutbound'); //XC_REST_Case_Outbound
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
			logWrapper.logIntegrationName = 'CaseOutbound';
			logWrapper.logTransactionID = headerDefinitions.get('TransactionID');
            logWrapper.insertLogging = insertLoggin; 
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWR = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper); //(request, headerDefinitions, 'CaseOutbound'); //XC_REST_Case_Outbound
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'CaseOutbound'); //XC_REST_Case_Outbound
            System.debug('[CaseOutbound] response -> ' + responseWR.response);

            /********************* Parse response ********************************************/
            result = manageResponseGET(responseWR.response);
            result.integrationLog = responseWR.integrationLog;
		} else {
            result = manageFakeResponseGET();
            //result.Result.ErrorCode = '0';
            //result.Result.Message = 'Fake Response';
        }

		return result;
    }
    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
	* @description init the Commodity ReadCase Request
	* @param paramsMap params Map
	* @return the HttpRequest
	*/
	public static HttpRequest initReadCaseRequest(Map<String, String> paramsMap){
       System.debug('@@@@ initReadCaseRequest - paramsMap--->'+paramsMap);
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CaseOutbound);
        System.debug('@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramsMap);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'readCase', 'CommoditySpainB2C');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
			System.debug('[CaseOutbound] request -> ' + request);
			return request;
        }

		throw new XC_UTIL_RESTCallout.NotActiveInterfaceException();
    }


    /**
     * @description Manage response.
     *
     * @param response the response
     * @return the XC_REST_Case_W.WrapperCaseResponseUpsert
     */
    @TestVisible
    private static XC_REST_Case_W.WrapperCaseResponseUpsert manageResponseUPSERT(HttpResponse response){
        
        XC_REST_Case_W.WrapperCaseResponseUpsert wrapperResult = new XC_REST_Case_W.WrapperCaseResponseUpsert();
        
        try {

            System.debug('[CaseOutbound] response Body -> ' + response.getBody());

        	String jsonResponse = response.getBody().replace('Case', 'Case_Item');
        	wrapperResult = (XC_REST_Case_W.WrapperCaseResponseUpsert) JSON.deserialize(jsonResponse, XC_REST_Case_W.WrapperCaseResponseUpsert.class);
        
        } catch(Exception e){
            wrapperResult.Result.Message = 'INTERNAL ERROR: ' + e;
        	wrapperResult.Result.ErrorCode = '500';
        }

        return wrapperResult;
    }

    
    /**
     * @description Manage response.
     *
     * @param response the response
     * @return the XC_REST_Case_W.WrapperCaseResponseGET
     */
    @TestVisible
    public static XC_REST_Case_W.WrapperCaseResponseGET manageResponseGET(HttpResponse response){
        
        XC_REST_Case_W.WrapperCaseResponseGET wrapperResult = new XC_REST_Case_W.WrapperCaseResponseGET();
        
        try {

            System.debug('[CaseOutbound] response Body -> ' + response.getBody());

        	String jsonResponse = response.getBody().replace('"Case"', '"CaseList"');
        	wrapperResult = (XC_REST_Case_W.WrapperCaseResponseGET) JSON.deserialize(jsonResponse, XC_REST_Case_W.WrapperCaseResponseGET.class);
        } catch(Exception e){
            wrapperResult.Result.Message = 'INTERNAL ERROR: ' + e;
        	wrapperResult.Result.ErrorCode = '500';
        }

        return wrapperResult;
    }

    /**
     * @description Manage fake response
     * @return the XC_REST_Case_W.WrapperCaseResponseGET
     */
    @TestVisible
    public static XC_REST_Case_W.WrapperCaseResponseGET manageFakeResponseGET(){
        String jsonFakeResponse = 
        '{'+
            '"Result" : {'+
                '"ErrorCode" : "0",'+
                '"Message" : "" },'+
            '"CaseList" : [{'+
                '"CaseNumber" : "1-1436388812",'+
                '"CaseReason" : "Retrs. Prestación del servicio",'+
                '"CaseSubCause" : "Disconformidad Servicio STP",'+
                '"Channel" : "Calidad Técnica NO Conforme",'+
                '"Country" : "Spain",'+
                '"Priority" : "Baja",'+
                '"CreatedDate" : "07/07/2019 12.34",'+
                '"CloseDate" : "",'+
                '"Status" : "Pdte. Cierre",'+
                '"CaseResult" : "",'+
                '"ContactPhone" : "+34978763455",'+
                '"NotificationEmail" : "MarioSolinas@gmail.com",'+
                '"ContactPreferredTime" : "",'+
                '"ProductCategory" : "SIAC",'+
                '"TypeOfIntermediary" : "Calidad Técnica NO Conforme ",'+
                '"PresentationMedium" : "Notificación personal",'+
                '"LastCaseComment" : "",'+
                '"Description" : "Cliente reclama por el cobro del ajuste de cuota de okluz negocios en la factura secc. 1076, por importe 152,92Euro.. Reclama que lo dió de baja porque no se le ha prestado ningún servicio en relación con este contrato, por lo que no está conforme con el pago de dicho contrato.. Solicita devolución de cobros realizados y anulación de este concepto en sus facturas.. . Tel. 616271184.. . Muchas gracias 19/05/2017 "'+
            '}]'+
        '}';
        XC_REST_Case_W.WrapperCaseResponseGET wrapperResult = (XC_REST_Case_W.WrapperCaseResponseGET) JSON.deserialize(jsonFakeResponse, XC_REST_Case_W.WrapperCaseResponseGET.class);
        return wrapperResult;
    }


    /**
     * The Class YourbanToken.
     *
     * @description queueable class to call yourban for token
     */
    private class YourbanToken implements Queueable, Database.AllowsCallouts {

        XC_UTIL_Case.CaseRESTWrapper wrRequest;
        String endpointCallback;
        String method;
        
        /**
         * @description Costructor
         * @param wrRequest the wrapper request
         * @param endpointCallback the endpoint
         */
        public YourbanToken(XC_UTIL_Case.CaseRESTWrapper wrRequest, String endpointCallback, String method) {
            this.wrRequest = wrRequest;
            this.endpointCallback = endpointCallback;
            this.method = method;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            
            if(!Test.isRunningTest()){
                String token = XC_REST_MobilityOrderCallback_Outbound.generateTokenEMobility(wrRequest.CaseID);
                if(String.isNotBlank(token)) {
                
                	callToYourban(wrRequest, endpointCallback, token, method);

                } else {
                    System.debug('[generateTokenEMobility] Something has gone wrong');
                }
            }
        }
    }


    private static void callToYourban(XC_UTIL_Case.CaseRESTWrapper wrRequest, String endpoint, String token, String method){
            
        String url = endpoint;
        String body = JSON.serialize(wrRequest, true);
        body = body.replace('"CaseX":', '"Case":');
        body = body.replace('"CaseX" :', '"Case" :');
        Map<String, String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound(method=='POST'?'Create':'Update', 'Case', 'Yourban');

        headerDefinitions.put('Authorization', 'Bearer ' + token);

        /********************** Send outbound request *************************************/
        HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, url, headerDefinitions, body);
    
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'Case');

        if(response != null) {
            System.debug('[caseYourban] response Boby -> ' + response.getBody());
        }

    }
    

}