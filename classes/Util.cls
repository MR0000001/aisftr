/**
 * Created by LCONATO00 on 23/07/2020.
 */

public without sharing class Util {
    public static String abbreviateTo10k(String s){
        if(10000 < s.length()) {
            return s.substring(0, 10000);
        } else {
            return s;
        }
    }

    public static String abbreviateToFieldLength(String s, Schema.SObjectField sobjectField) {
        Integer maxLength = sobjectField.getDescribe().getLength();
        maxLength = 80000;
        if (s.length() < maxLength) {
            return s;
        } else {
            return s.substring(0, maxLength - 10);
        }
    }
   /* public static void saveToLog(HttpRequest clientRequest, HttpResponse response, String body, Long totalTime, String service, String externalSystem, String namedCredentials, String recordId) {
        Callout_Logger__c logger = new Callout_Logger__c();

        HttpRequest request = clientRequest;

        logger.NamedCredential__c = namedCredentials;
        logger.RequestMessage__c = body;
        logger.Time__c = totalTime;
        logger.Service__c = service;
        logger.System__c = externalSystem;
        logger.RecordID__c = recordId;

        logger.Timestamp__c = Datetime.now();
        logger.HTTPMethod__c = request.getMethod();
        logger.Endpoint__c = request.getEndpoint();

        if (response != null) {
            String status = response.getStatus();
            Integer statusCode = response.getStatusCode();
            logger.ResponseMessage__c = Util.abbreviateTo10k(response.getBody());
            logger.HTTPStatus__c = status;
            logger.HTTPStatusCode__c = statusCode;

            if (statusCode == 200 || statusCode == 201) {
                logger.Status__c = 'SUCCESS';
            } else {

                logger.Status__c = 'FAILED';
            }
        } else {
            logger.Status__c = 'FAILED';
            logger.ErrorMessage__c = 'Response is NULL';
        }
        insert(logger);
    }*/
}