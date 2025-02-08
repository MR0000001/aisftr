/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class CalloutHelper {
    private static Long startTime;

    public static void setStartTime() {
        DebugService.printLimits('CalloutHelper', 'setStartTime', 'start');
        startTime = Datetime.now().getTime();
        System.debug('startTime ' + startTime);
        DebugService.printLimits('CalloutHelper', 'setStartTime', 'end');
    }

    @TestVisible
    private static Long setFinishTime() {
        DebugService.printLimits('CalloutHelper', 'setFinishTime', 'start');
        Long finishTime = Datetime.now().getTime();
        DebugService.printLimits('CalloutHelper', 'setFinishTime', 'end');
        return finishTime;
    }

    public static Long getTotalTime() {
        DebugService.printLimits('CalloutHelper', 'getTotalTime', 'start');
        Long finishTime = setFinishTime();
        System.debug('finishTime ' + finishTime);
        DebugService.printLimits('CalloutHelper', 'getTotalTime', 'end');

        return (finishTime - startTime) / 1000;
    }

    public static HttpRequest initializeRequest(String endpoint, String method, Integer timeout, String headerContentType, String headerAuthorization, String headerAccept, String body) {
        DebugService.printLimits('CalloutHelper', 'initializeRequest', 'start');
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout);

        if(String.isNotBlank(headerContentType)) {
            System.debug('Entered if headerContentType');
            req.setHeader('Content-Type', headerContentType);
        }

        if(String.isNotBlank(headerAuthorization)) {
            System.debug('Entered if headerAuthorization');
            req.setHeader('Authorization', headerAuthorization);
        }

        if(String.isNotBlank(headerAccept)) {
            System.debug('Entered if headerAccept');
            req.setHeader('Accept', headerAccept);
        }

        if(String.isNotBlank(body)) {
            System.debug('Body is not blank');
            req.setBody(body);
        }

        DebugService.printLimits('CalloutHelper', 'initializeRequest', 'end');
        return req;
    }

    public static void handleException(HttpResponse res, HttpRequest req, String reqBody, Long totalTime, String externalSystem, String namedCredential, Exception e) {
        DebugService.printLimits('CalloutHelper', 'handleException', 'start');
        Error_Log_Event__e errorEvent = null;
        if (res == null) {
            CalloutLoggerService.initializeUpdateCalloutLog(req, null, reqBody, totalTime, '', externalSystem, namedCredential,'');
            errorEvent = ErrorLogEventHandler.createInfoEvent(e);
        } else {
            errorEvent = ErrorLogEventHandler.createEvent(e);
        }
        System.debug('errorEvent -> '+ errorEvent);
        Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        DebugService.printLimits('CalloutHelper', 'handleException', 'end');
    }

    public static HttpResponse setHttpResponse(String status, Integer statusCode, String body, Map<String, String> headerMap, String className, String methodName) {
        DebugService.printLimits('CalloutHelper', 'setHttpResponse', 'start');

        HttpResponse httpResponse = new HttpResponse();

        httpResponse.setStatus(status);
        httpResponse.setStatusCode(statusCode);
        httpResponse.setBody(body);

        if(headerMap != null && !headerMap.isEmpty()) {
            for(String key : headerMap.keySet()) {
                httpResponse.setHeader(key, headerMap.get(key));
            }
        }

        DebugService.printResponse(className, methodName, httpResponse);
        DebugService.printLimits('CalloutHelper', 'setHttpResponse', 'end');
        return httpResponse;
    }

    public static RestResponse setRestResponse(Integer statusCode, String body, Map<String, String> headerMap, String className, String methodName) {
        DebugService.printLimits('CalloutHelper', 'setRestResponse', 'start');
        RestResponse restResponse = RestContext.response;

        restResponse.statusCode = statusCode;
        restResponse.responseBody = Blob.valueOf(body);

        if(headerMap != null && !headerMap.isEmpty()) {
            for(String key : headerMap.keySet()) {
                restResponse.addHeader(key, headerMap.get(key));
            }
        }

        DebugService.printRestResponse(className, methodName, restResponse);
        DebugService.printLimits('CalloutHelper', 'setRestResponse', 'end');
        return restResponse;
    }
}