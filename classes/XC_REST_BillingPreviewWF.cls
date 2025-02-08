/**
 * @File Name          : XC_REST_BillingPreviewWF.cls
 * @Description        : call zuora workflow to manage billing preview requirement
 * @Author             : dpalamides - dpalamides@deloitte.it
 * @Group              : 
 * @Last Modified By   : dpalamides - dpalamides@deloitte.it
 * @Last Modified On   : 12/06/2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/06/2020  dpalamides - dpalamides@deloitte.it     Initial Version
**/
public without sharing class XC_REST_BillingPreviewWF {

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
    * @author dpalamides - dpalamides@deloitte.it | 12/06/2020
    * @param req 
    * @return WrapperResponse 
    **/
    public static WrapperResponse callBillingPreviewWF(WrapperRequest req){
        
        WrapperResponse result = new  WrapperResponse();
        XC_UTIL_RESTCallout.CSWrapper wrInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_BillingPreviewWF);

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
    * @author dpalamides - dpalamides@deloitte.it | 12/06/2020
    * @param req 
    * @return WrapperResponse 
    **/
    private static WrapperResponse manageRequestResponse(HttpRequest req,WrapperResponse result){


        XC_UTIL_IntegrationLog.LogWrapper lw = new XC_UTIL_IntegrationLog.LogWrapper();
        lw.logEndpoint = req.getEndpoint();
        lw.httpMethod = req.getMethod();
        lw.logIntegrationName = 'BILLING PREVIEW WORKFLOW';
        lw.logTransactionID = '';
        lw.insertLogging = true;
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(req,lw).response;

        if(response == null) {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response NULL of the BillingPreviewWF API';
            result.errors.add(error);
            return result;
        }

        if(response.getStatusCode() == 200) {
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        } else {
            result.errors = new List<WrapperErrors>();
            WrapperErrors error = new WrapperErrors();
            error.title = 'Response with StatusCode ' + response.getStatusCode() + ' of the BillingPreviewWF API';
            result.errors.add(error);
            return result;
        }

        return result;
    }



}