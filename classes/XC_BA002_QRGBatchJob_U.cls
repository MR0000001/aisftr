/**
* @author Tommaso Precania - tommaso.precania@accenture.com
* @date Creation 01/12/2021
* @date Modification 10/12/2021
* @description XC_BA002_QRGBatchJob_U – Helper class containing methods called by XC_BA002_QRGBatchJob 
* @                                     in order to send to Mashery notification about QueuedRequest Group work finished
*/
public with sharing class XC_BA002_QRGBatchJob_U {
    public static final String IN_ERROR = 'IN ERROR';
    public static final String REQUEST_SENT = 'REQUEST SENT';
    public static final String COMPLETED = 'COMPLETED';
    public static final String NOTCOMPLETED = 'NOT COMPLETED';

    public class WSResult {
        public Result result;
    }
    public class Result{
        public String error_code;
        public String message;
    }
    public static String getQuery(Integer daysAgo){
        String query =  '';
        query +=  'SELECT id, XC_FileName__c, XC_JobId__c, XC_Status__c ';
        query +=  ' FROM  XC_QueuedRequestGroup__c ' ;    
        query +=  ' WHERE XC_Status__c = \'' + NOTCOMPLETED + '\' ';
        query += ((daysAgo != null && daysAgo > 0)? (' AND LastModifiedDate = LAST_N_DAYS:'+ daysAgo) : '');
        query += ' LIMIT 50000 ';
        System.debug('@@@ XC_BA002_QRGBatchJob_U :: query :: ' + query);
        return query;
    }

    public static Set<String> getNotCompletedJobIds(List<XC_QueuedRequestGroup__c> scope){
        List<String> jobList = new List<String>();
        Set<String> jobNotCompleted = new Set<String>();

        if(scope != null)
        {
            //Take list of XC_JobId__c
            for (XC_QueuedRequestGroup__c qrg : scope) {
                jobList.add(qrg.XC_JobId__c);
            }
    
            //Take list of XC_QueuedRequest__c with IDBulk equal to XC_JobId__c
            AggregateResult[] groupedResults = [SELECT XC_BulkJobId__c FROM XC_QueuedRequest__c WHERE XC_BulkJobId__c IN :jobList AND (not XC_Status__c in ('Completed','In Error')) GROUP BY XC_BulkJobId__c];
            
            for(AggregateResult jobNC : groupedResults)
            {
                jobNotCompleted.add((String) jobNC.get('XC_BulkJobId__c'));
            }
        }

        return jobNotCompleted;
    }

    public static Map<String, XC_QueuedRequestGroup__c> getToProcessRecords(List<XC_QueuedRequestGroup__c> scope){
        Map<String, XC_QueuedRequestGroup__c> jobIdQRG = new Map<String, XC_QueuedRequestGroup__c>();
        Set<String> jobNotCompleted = getNotCompletedJobIds(scope);
        for (XC_QueuedRequestGroup__c qrg : scope) 
        {
            if(!jobNotCompleted.contains(qrg.XC_JobId__c))
            {
                jobIdQRG.put(qrg.XC_JobId__c, qrg);
            }
        }
        return jobIdQRG;
    }

    public static XC_UTIL_RESTCallout.HttpResponseWrapper sendRequest(HttpRequest request, Map<String,String> headerDefinitions){
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = headerDefinitions.get('Functionality');
        logWrapper.logTransactionID = headerDefinitions.get('TransactionID');
        logWrapper.clientSystem = headerDefinitions.get('ClientSystem');
        logWrapper.serverSystem = headerDefinitions.get('ServerSystem');
        logWrapper.insertLogging = false; 
        
        XC_UTIL_RESTCallout.HttpResponseWrapper result = new XC_UTIL_RESTCallout.HttpResponseWrapper();
        Http http = new Http();
        
        System.debug('@@@ XC_BA002_QRGBatchJob_U :: request In sendRequestLogging mapVersion' + request );
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();  
        logWrapper.logEndpoint = request.getEndpoint(); 
        logWrapper.httpMethod = request.getMethod();
        logWrapper.logMessage = (request.getBody().length()>131072) ? request.getBody().substring(0, 131072) : request.getBody();

        try{
            System.debug('@@@ XC_BA002_QRGBatchJob_U :: request body :: '+request.getBody());
            intLog.setHeader(headerDefinitions);
            System.debug('@@@ XC_BA002_QRGBatchJob_U :: header :: ' + headerDefinitions);
            intLog.insertIntegReqOutboundLog(logWrapper);//INIT IntegrationLog (NON fa INSERT)
            
            result.response = Http.send(request);
            
            System.debug('@@@ XC_BA002_QRGBatchJob_U :: Response in sendRequestLogging mapVersion' + result.response);

            result.integrationLog = XC_UTIL_RESTCallout.getResponseLogging(intLog, result.response);

        } catch(Exception e){
            String logError = '@@@ XC_BA002_QRGBatchJob_U :: catch_SendRequestLogging ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause();
            System.debug(LoggingLevel.FINEST, logError);
            result.integrationLog = XC_UTIL_RESTCallout.getResponseLoggingError(intLog, logError);
        }
        System.debug('@@@ XC_BA002_QRGBatchJob_U :: @@@ RESPONSE @@@ ' + result.response);
        return result;
    }
}