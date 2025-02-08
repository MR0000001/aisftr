/**
* @author Tommaso Precania - tommaso.precania@accenture.com
* @date Creation 01/12/2021
* @date Modification 10/12/2021
* @description XC_BA002_QRGBatchJob – Batch class to send to Mashery notification about QueuedRequest Group work finished
*/
public with sharing class XC_BA002_QRGBatchJob implements  Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public Integer numberOfDaysAgo;
    public static final String WS_API_NAME = 'QRBatchJobStatusUpdate';
    

    public XC_BA002_QRGBatchJob (Integer daysAgo){
        this.numberOfDaysAgo = daysAgo;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(XC_BA002_QRGBatchJob_U.getQuery(this.numberOfDaysAgo));
    }

    public void execute(Database.BatchableContext bc, List<XC_QueuedRequestGroup__c> scope){
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(WS_API_NAME, '');
        
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        Map<String, XC_QueuedRequestGroup__c> jobIdQRG;
        Map<String, HttpResponse> jobIdResp = new Map<String, HttpResponse>();

        if(isActiveInterface != null && isActiveInterface.activeInterface)
        {
            jobIdQRG = XC_BA002_QRGBatchJob_U.getToProcessRecords(scope);
        }

        if(jobIdQRG != null && !jobIdQRG.isEmpty())
        {
            //Here need to call Marshery systems and if the response is OK we'll can chnage the status on QRG
            Integer timeout = 120000 / jobIdQRG.size();
            
            for(String jid : jobIdQRG.keySet())
            {
                Map<String, String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('PUT', WS_API_NAME, isActiveInterface.serverSystem);
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', isActiveInterface.url, headerDefinitions, JSON.serialize(new Map<String,String>{'bulk_job_id' => jid}));
                request.setTimeout(timeout);
                //Here close call to Marshery
                XC_UTIL_RESTCallout.HttpResponseWrapper httpRWr = XC_BA002_QRGBatchJob_U.sendRequest(request, headerDefinitions);
                jobIdResp.put(jid, httpRWr.response);
                integrationLogsToInsert.add(httpRWr.integrationLog.get(0));
            }

            for(String jid : jobIdQRG.keySet())
            {
                HttpResponse resp = jobIdResp.get(jid);
                XC_QueuedRequestGroup__c qrg = jobIdQRG.get(jid);
                XC_BA002_QRGBatchJob_U.WSResult respBody;
                if(resp != null)
                {
                    try{
                        respBody = (XC_BA002_QRGBatchJob_U.WSResult) JSON.deserialize(resp.getBody(), XC_BA002_QRGBatchJob_U.WSResult.class);
                    }catch(Exception e){
                        System.debug('@@@ XC_BA002_QRGBatchJob :: exception error :: ' + e.getMessage());
                    }
                    qrg.XC_Status__c = respBody != null && respBody.result != null && respBody.result.error_code == '0' ? XC_BA002_QRGBatchJob_U.REQUEST_SENT : XC_BA002_QRGBatchJob_U.IN_ERROR ;
                    qrg.XC_ResultMessage__c = respBody != null && respBody.result != null ? respBody.result.message : '';
                }
                else 
                {
                    qrg.XC_Status__c = XC_BA002_QRGBatchJob_U.IN_ERROR;
                    qrg.XC_ResultMessage__c = Label.XC_CL_QRGBatchGenericError;
                }
            }

            
            List<XC_UTIL_Sobject.WrapperResult> updateResults = XC_UTIL_Sobject.updateListRecords(jobIdQRG.values(), false);
            String valueInsertDML = (XC_CS_UtilityGlobalValues__c.getInstance('XC_BA002_QRGBatchJob') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('XC_BA002_QRGBatchJob').Value__c : 'false';
            if(valueInsertDML=='true') List<XC_UTIL_Sobject.WrapperResult> insertResults = XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert, false);
        }
    }

    public void finish(Database.BatchableContext bc){}
}