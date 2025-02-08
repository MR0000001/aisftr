/**
 * @File Name          : XC_REST_MixedVATWF.cls
 * @Description        : call zuora workflow to manage mixedvat requirement for italy
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 07-29-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/3/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_REST_MixedVATWF {

    public class WrapperRequest{
        public String subscriptionId;
        public String accountId;
        public String legalEntity;
        public String stream;
    }

    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The id. */
        public String id;
        
        /** The name. */
        public String name;
        
        /** The original workflow id. */
        public String originalWorkflowId;
        
        /** The type. */
        public String type;

        /** The status. */
        public String status;
        
        /** The run time. */
        public String runTime;
        
        /** The created at. */
        public String createdAt;
        
        /** The updated at. */
        public String updatedAt;
        
        /** The errors. */
        public List<WrapperErrors> errors = new List<WrapperErrors>();

        public XC_Integration_Log__c responseLog;
    }


    /**
     * The Class WrapperErrors.
     *
     * @description the wrapper errors
     */
    public class WrapperErrors {
        
        /** The status. */
        public String status;
        
        /** The code. */
        public String code;
        
        /** The title. */
        public String title;
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 31/3/2020 
    * @param req 
    * @return WrapperResponse 
    **/
    public static WrapperResponse callMixedVATWF(WrapperRequest req){
        
        WrapperResponse result = new  WrapperResponse();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_MixedVATWF);

        if(wrInterface.activeInterface){
            String legalEntity = req.legalEntity;
            String stream = req.stream;
            req.stream = null;

            String entityName = XC_UTIL_Integration_U.getEntityNameWithStream(legalEntity, stream);
            if(String.isBlank(entityName)) {
                result.errors = new List<WrapperErrors>();
                WrapperErrors error = new WrapperErrors();
                error.title = Label.XC_CL_EntityNameNotFound;
                result.errors.add(error);
                return result;
            }

            ZuoraWebService zws = new ZuoraWebService(entityName);

            String url = wrInterface.url;
            String body =  JSON.serialize(req, true);

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type','application/json');
            headerDefinitions.put('API-Token', zws.apiToken);

            XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
            lw.insertLogging = false;

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            return manageRequestResponse(request,result);

        }

        return result;

    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 31/3/2020 
    * @param req 
    * @return WrapperResponse 
    **/
    private static WrapperResponse manageRequestResponse(HttpRequest req,WrapperResponse result){


        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'MIXED VAT WORKFLOW';
        lw.logTransactionID = '';
        lw.insertLogging = false;
        // HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;
        XC_UTIL_RESTCallout.HttpResponseWrapper rw = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw);
        HttpResponse response = rw.response;

        if(response == null) {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response NULL of the MixedVATWF API';
            result.errors.add(error);
            return result;
        }

        if(response.getStatusCode() == 200) {
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the MixedVATWF API';
            result.errors.add(error);
            return result;
        }

        result.responseLog = !rw.integrationLog.isEmpty() ? rw.integrationLog[0] : null;


        return result;
    }



}