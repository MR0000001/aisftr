/**
 * @author            : Roberta Porrega roberta.porrega@nttdata.com - Simone Trenta strenta@deloitte.it
 * @date Creation     : 08/05/2019
 * @description       : XC_REST_PaymentMethodSIA – Rest Resourse for Payment SIA
 */
public without sharing class XC_REST_PaymentMethodSIA {

    private static final String CHANNEL_CC = 'CRMWEBAPP';
    private static final String CHANNEL_SDD = 'CRMWEBAPP_SDD';

    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{

        /** @description The success. */
        @AuraEnabled
        public Boolean success {get; set;}
        /** @description The errorMessage. */
        @AuraEnabled
        public String errorMessage {get; set;}
        /** @description The paymentMethodSIA. */
        @AuraEnabled
        public String paymentMethodSIA  {get; set;}
        /** @description The recordId. */
        @AuraEnabled
        public String interactionRecordId  {get; set;}
        /** @description The sepa result. */
        @AuraEnabled
        public String sepaResult {get; set;}
    }

    /**
     * callForCreditCard
     *
     * @description Call   callForCreditCard
     * @param reqWrapp the req to validate
     * @param contactId the contactId
     * @param billingProfileId the billingProfileId
     * @return the result wrapper
     */
    public static ResultWrapper callForCreditCard(XC_REST_PaymentMethodSIA_U.RequestWrapper reqWrapp, String contactId, String billingProfileId) {
        ResultWrapper result = new ResultWrapper();

        XC_UTIL_Integration.Result checkParameters = XC_REST_PaymentMethodSIA_U.checkRequiredParameters(reqWrapp);
        if(checkParameters.ErrorCode != '0') {
            result.success = false;
            result.errorMessage = checkParameters.Message;
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_PaymentMethodSIA);
        if(!isActiveInterface.activeInterface){
            result = manageResponseFake();
            return result;
        }

        String accId = '';
        Schema.SObjectType sobjectType = ((Id)contactId).getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        if(sobjectName=='Contact'){
            Map<Id,Contact> cons = New Map<Id,Contact>([SELECT id, AccountId FROM Contact WHERE id =: contactId]);
            accId = cons.values()[0].AccountId;
        }else{
            accId = contactId;
        }

        reqWrapp.additionalInfo.put('AccountID', accId);
        reqWrapp.additionalInfo.put('BillingProfileID', billingProfileId);

        String body = JSON.serialize(reqWrapp, true);
        body = body.replace('"currencyX":', '"currency":');
        body = body.replace('"typeX":', '"type":');
        Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'PaymentMethodSIA', 'PaymentMethodSIA');
        headerDefinitions.put('X-Request-ID', '1');
        headerDefinitions.put('channel', CHANNEL_CC);

        /********************** Send outbound request *************************************/
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', isActiveInterface.url, headerDefinitions, body);
        request.setClientCertificateName('SIA_CERT');
        System.debug('[Payment Method SIA] request Body -> ' + body);

        //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'Payment Method SIA');
        //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions , 'Payment Method SIA');
        List<XC_Integration_Log__c> integrationLogOutboundToInsert = new List<XC_Integration_Log__c>(); 
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'Payment Method SIA';
        logWrapper.insertLogging = false;
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request,  headerDefinitions , logWrapper);
        HTTPResponse response = httpRWr.response;

        System.debug('[Payment Method SIA] response -> ' + response);
        httpRWr.integrationLog.get(0).XC_BillingProfile__c = billingProfileId;
        httpRWr.integrationLog.get(0).XC_Log_TransactionId__c = headerDefinitions.get('TransactionID');
        integrationLogOutboundToInsert.add(httpRWr.integrationLog.get(0));
        if(!integrationLogOutboundToInsert.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
        }
        /********************* Parse response ********************************************/
        if(response==null){
            result.errorMessage = '404: Server not available';
            result.paymentMethodSIA='';
            return result;
        }

        result = manageResponse(response);
        System.debug('[Payment Method SIA] result -> ' + result);
        return result;
    }



    /**
     * callForSEPA
     *
     * @description Call   callForSEPA
     * @param reqWr the request wrapper
     * @return the result wrapper
     */
    public static XC_REST_PaymentMethodSIA_U.ResponseWrapper callForSEPA(XC_REST_PaymentMethodSIA_U.RequestWrapperSEPA reqWr) {
        XC_REST_PaymentMethodSIA_U.ResponseWrapper result = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('PaymentMethodSIA_SEPA');
        if(!isActiveInterface.activeInterface){
            result = manageResponseFakeSEPA();
            return result;
        }

        
        String bp = reqWr.bp;
        reqWr.bp = '';
        String body = JSON.serialize(reqWr, true);
        Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'PaymentMethodSIA_SEPA', 'PaymentMethodSIA_SEPA');
        headerDefinitions.put('X-Request-ID', '1');
        headerDefinitions.put('channel', CHANNEL_SDD);

        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', isActiveInterface.url, headerDefinitions, body);
        request.setClientCertificateName('SIA_CERT');
        System.debug('[Payment Method SIA] request Body -> ' + body);

        List<XC_Integration_Log__c> integrationLogOutboundToInsert = new List<XC_Integration_Log__c>(); 
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'PaymentMethodSIA_SEPA';
        logWrapper.insertLogging = false;
        XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request,  headerDefinitions , logWrapper);
        HTTPResponse response = httpRWr.response; 
        System.debug('[Payment Method SIA] response -> ' + response);
        httpRWr.integrationLog.get(0).XC_BillingProfile__c = bp;
        httpRWr.integrationLog.get(0).XC_Log_TransactionId__c = headerDefinitions.get('TransactionID');
        integrationLogOutboundToInsert.add(httpRWr.integrationLog.get(0));
        if(!integrationLogOutboundToInsert.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(integrationLogOutboundToInsert);
        }

        if(response==null){
            return result;
        }

        result = (XC_REST_PaymentMethodSIA_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_PaymentMethodSIA_U.ResponseWrapper.class);

        System.debug('[Payment Method SIA] result -> ' + result);
        return result;
    }


    /**
     * @description Manage response fake.
     * @return the result wrapper
     */
    @TestVisible
    private static XC_REST_PaymentMethodSIA_U.ResponseWrapper manageResponseFakeSEPA() {
        XC_REST_PaymentMethodSIA_U.ResponseWrapper wrapper = new XC_REST_PaymentMethodSIA_U.ResponseWrapper();
        wrapper.debtorCode = '20191023101248946393';
        wrapper.debtorStatus = 'ACTIVE';
        return wrapper;
    }


    /**
     * @description Manage response fake.
     * @return the result wrapper
     */
    @TestVisible
    private static ResultWrapper manageResponseFake() {
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.success = true;
        wrapper.paymentMethodSIA = '';
        return wrapper;
    }

    /**
     * @description Manage response
     * @param response the response
     * @return the result wrapper
     */
    @TestVisible
    private static ResultWrapper manageResponse(HttpResponse response){
        ResultWrapper result = new ResultWrapper();
 
        if(response == null) {
            result.success = false;
            return result;
        }

        if(response.getStatusCode() == 200){
            System.debug('Payment Method SIA! -> response: ' + response.getBody());
            XC_REST_PaymentMethodSIA_U.responseWrapper wrapperResult =
                    (XC_REST_PaymentMethodSIA_U.responseWrapper) JSON.deserialize(response.getBody(), XC_REST_PaymentMethodSIA_U.responseWrapper.class);

            if(wrapperResult.code == 'INVALID_REQUEST') {
                System.debug('Sia ERROR');
                result.success = false;
                result.errorMessage = wrapperResult.details;
                return result;
            } else {
                result.success = true;
                result.paymentMethodSIA = JSON.serialize(wrapperResult, true);
                System.debug('Payment Method SIA! -> paymentMethodSIA: ' +result.paymentMethodSIA);
            }

        } else {
            result.success = false;
            result.errorMessage = response.getStatusCode() + ': ' + response.getStatus();
            System.debug('ERROR for Payment Method SIA! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());
        }

        return result;
    }


}