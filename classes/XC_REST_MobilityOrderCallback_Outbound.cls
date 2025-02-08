/**
 * The Class XC_REST_MobilityOrderCallback_Outbound.
 *
 * @author            : Giulio Serra giserra@deloitte.it
 * @date Creation     : 07/02/2019
 * @date Modification : 10/06/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : send the E-Mobility Callback
 */


public without sharing class XC_REST_MobilityOrderCallback_Outbound {

    /**
     * Call to mobility.
     *
     * @param wrRequest the wrapper request
     * @param serverSystem the server system
     * @return the response wrapper
     * @description method to call mobility
     */
    public static XC_REST_MobilityOrderCallback_U.ResponseWrapper callToMobility(XC_REST_MobilityOrderCallback_U.RequestWrapper wrRequest, String serverSystem) {
        
        XC_REST_MobilityOrderCallback_U.ResponseWrapper rw = new XC_REST_MobilityOrderCallback_U.ResponseWrapper();

        // To verify the Order Id and to get the transaction Id and the type
        Map<Id, NE__Order__c> ordMap = new Map<Id, NE__Order__c>([SELECT Id, XC_eMobTransactionId__c, NE__Type__c FROM NE__Order__c WHERE Id =: wrRequest.OrderID]);
        List<NE__Order__c> ordList = ordMap.values();
        if(ordList.isEmpty()) {
            System.debug('@@@ ERROR before call emobility : Order not found');
            rw.Result.ErrorCode = '400';
            rw.Result.Message = Label.XC_CL_OrderNotFound;
            return rw;
        }

        String mobilityInterface = (wrRequest.isChangeOpenCharge == true || ordList[0].NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder) ? Label.XC_CL_MobilityOrderCallback_PUT : Label.XC_CL_MobilityOrderCallback;
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(mobilityInterface);
        if(wrapper.activeInterface){
            
            wrRequest.emobTransactionId = (wrRequest.isChangeOpenCharge == true) ? null : ordList[0].XC_eMobTransactionId__c;
            wrRequest.isChangeOpenCharge = null;
            EmobilityToken emobTok = new EmobilityToken(wrRequest, wrapper.url);
            Id jobId = System.enqueueJob(emobTok);
            
            rw.Result.ErrorCode = '0';
        }else{
            rw.Result.ErrorCode = '0';
            rw.Result.Message = Label.XC_CL_FakeResponse;
        }

        return rw;
    }


    /**
     * The Class EmobilityToken.
     *
     * @description queueable class to call emobility for token
     */
    private class EmobilityToken implements Queueable, Database.AllowsCallouts {

        XC_REST_MobilityOrderCallback_U.RequestWrapper wrRequest;
        String endpointCallback;
        
        /**
         * @description Costructor
         * @param wrRequest the wrapper request
         * @param endpointCallback the endpoint
         */
        public EmobilityToken(XC_REST_MobilityOrderCallback_U.RequestWrapper wrRequest, String endpointCallback) {
            this.wrRequest = wrRequest;
            this.endpointCallback = endpointCallback;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            
            if(!Test.isRunningTest()){
                String token = generateTokenEMobility(wrRequest.emobTransactionId);
                if(String.isNotBlank(token)) {
                
                	callToEmobilityCallback(wrRequest, endpointCallback, token);

                } else {
                    System.debug('[generateTokenEMobility] Something has gone wrong');
                }
            }
        }
    }

    
    /**
     * GenerateTokenB2W.
     *
     * @param configurationInfo the configuration infos map
     * @param transactionId the transaction id
     * @return the status of response
     * @description method to generate Bit2Win token
     */
    public static String generateTokenEMobility(String transactionId){
        
        String tok;

        Map<Id, XC_CS006_eMobilityCredentials__c> emobCredMap = new Map<Id, XC_CS006_eMobilityCredentials__c>([SELECT Id, XC_ClientId__c, XC_ClientSecret__c, XC_Email__c, XC_Password__c, XC_ServerURL__c FROM XC_CS006_eMobilityCredentials__c]);
        List<XC_CS006_eMobilityCredentials__c> emobCredList = emobCredMap.values();
        if(emobCredList.isEmpty()) {
            return tok;
        }

        String url = emobCredList[0].XC_ServerURL__c + 'oauth/login?client_id=' + emobCredList[0].XC_ClientId__c + '&client_secret=' + emobCredList[0].XC_ClientSecret__c;
        Map<String,String> headerDefinitions = new Map<String,String>{'Content-Type' => 'application/json'};
        String body = '{"email":"' + emobCredList[0].XC_Email__c + '","password":"' + emobCredList[0].XC_Password__c + '"}';

        /** The request. */
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug('[generateTokenEMobility] request -> ' + request);

        /** The response. */
        HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request, 'GenerateTokenEMobility');
        System.debug('[generateTokenEMobility] response -> ' + response);
        if(response != null) {
            System.debug('[generateTokenEMobility] response Body -> ' + response.getBody());

            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
    
            if(result.get('code') == 200){
                System.debug('[generateTokenEMobility] OK');
    
                Map<String,Object> resultEMobility = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(result.get('result')));
                System.debug('[generateTokenEMobility] resultToken -> ' + resultEMobility);
                tok = (String) resultEMobility.get('access_token');
            }
        }
        
        System.debug('[generateTokenEMobility] token -> ' + tok);
        return tok;
    }


    /**
     * GenerateTokenB2W.
     *
     * @param wrRequest the wrapper request
     * @param endpoint the endpoint
     * @param token the emobility token
     * @description method to call E-Mobility for callback
     */
    public static void callToEmobilityCallback(XC_REST_MobilityOrderCallback_U.RequestWrapper wrRequest, String endpoint, String token){

        String emobTransactionId = wrRequest.emobTransactionId;
        wrRequest.emobTransactionId = null;

        if(String.isNotBlank(wrRequest.ZSubscriptionId) && String.isBlank(wrRequest.ZSubscriptionNumber)) {
            Map<Id, Zuora__Subscription__c> subMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__SubscriptionNumber__c, Zuora__External_Id__c
                                                                                            FROM Zuora__Subscription__c
                                                                                            WHERE Zuora__External_Id__c =: wrRequest.ZSubscriptionId LIMIT 1]);
            wrRequest.ZSubscriptionNumber = (subMap.isEmpty()) ? null : subMap.values()[0].Zuora__SubscriptionNumber__c;
        }

        if(String.isBlank(wrRequest.StartDateSubscription)) {
            wrRequest.StartDateSubscription = String.valueOf(System.today());
        }
        XC_REST_MobilityOrderCallback_U.RequestWrapperCallback req = new XC_REST_MobilityOrderCallback_U.RequestWrapperCallback();
        req.Order = wrRequest;
        
        //Creating PS to update
        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c(Id = wrRequest.StepID);
        wrRequest.StepID = null;
        
        String url = endpoint;
        String body = JSON.serialize(req, true);
        Map<String, String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'OrderManagment', 'E-Mobility');
        if(String.isNotBlank(emobTransactionId)) {
            headerDefinitions.put('TransactionID', emobTransactionId);
        }
        headerDefinitions.put('Authorization', 'Bearer ' + token);

        /********************** Send outbound request *************************************/
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
        System.debug('[MobilityOrderCallback] request -> ' + request);
        System.debug('[MobilityOrderCallback] request Body -> ' + request.getBody());

        //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'MobilityOrderCallback');
        HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'MobilityOrderCallback');

        System.debug('[MobilityOrderCallback] response -> ' + response);
        if(response != null) {
            System.debug('[MobilityOrderCallback] response Boby -> ' + response.getBody());
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
    
            if(result.get('code') != 200){
                ps.XC_Status__c = 'Completed KO';
            	ps.XC_ErrorMessage__c = String.valueOf(result.get('message'));
            
            } else {
                ps.XC_Status__c = 'Completed OK';
            }
            
            XC_UTIL_SObject.updateRecord(ps);
        }
    }

}