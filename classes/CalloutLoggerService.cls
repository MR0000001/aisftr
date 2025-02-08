/**
 * Created by ABOZZANO00 on 06/08/2020.
 */
public with sharing class CalloutLoggerService {

    public static Callout_Logger__c initializeUpdateCalloutLog(HttpRequest clientRequest, HttpResponse response, String body, Long totalTime, String service, String externalSystem, String namedCredentials, String recordId) {
        Callout_Logger__c logger = new Callout_Logger__c();
        populateLogger(logger, clientRequest, response, body, totalTime, service, externalSystem, namedCredentials, recordId);
        insert(logger);
        return logger;
    }

    public static Callout_Logger__c createCalloutLog(HttpRequest clientRequest, HttpResponse response, String body, Long totalTime, String service, String externalSystem, String namedCredentials, String recordId) {
        Callout_Logger__c logger = new Callout_Logger__c();
        populateLogger(logger, clientRequest, response, body, totalTime, service, externalSystem, namedCredentials, recordId);
        return logger;
    }

    public static void populateLogger(Callout_Logger__c logger, HttpRequest clientRequest, HttpResponse response, String body, Long totalTime, String service, String externalSystem, String namedCredentials, String recordId) {
        HttpRequest request = clientRequest;
        logger.NamedCredential__c = String.isNotBlank(namedCredentials)? namedCredentials.abbreviate(Callout_Logger__c.NamedCredential__c.getDescribe().getLength()) : '';
        logger.RequestMessage__c =  Util.abbreviateTo10k(body);
        logger.Time__c = totalTime;
        logger.Service__c = service;
        logger.System__c = externalSystem;
        logger.RecordID__c = recordId;
        logger.Timestamp__c = Datetime.now();
        logger.HTTPMethod__c = (request != null) ? request.getMethod() : null;
        logger.Endpoint__c =  (request != null) ? request.getEndpoint() : null;
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
    }

    public static void insertCalloutLoggers(List<Callout_logger__c> calloutLoggers, Boolean allOrNone) {
        if(!calloutLoggers.isEmpty()) {
            Database.SaveResult[] saveResults = Database.insert(calloutLoggers, allOrNone);
            Error_Log_Event__e logEvent = ErrorLogEventHandler.createEvent(saveResults);
            if(logEvent != null) ErrorLogEventHandler.publishEventDMLSafe(logEvent);
        }
    }


    public static Database.DeleteResult[] deleteCalloutLoggers(List<Callout_logger__c> calloutLoggers, Boolean allOrNone) {
        Database.DeleteResult[] results = new List<Database.DeleteResult>();

        if(calloutLoggers != null && !calloutLoggers.isEmpty()) {
            try {
                results = Database.delete(calloutLoggers, allOrNone);
                ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('CalloutLoggerService', 'deleteCalloutLoggers', e);
            }
        }
        return results;
    }
}