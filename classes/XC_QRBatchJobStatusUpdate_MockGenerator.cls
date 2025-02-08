@isTest
global class XC_QRBatchJobStatusUpdate_MockGenerator implements HttpCalloutMock {
    global Map<String, String> jobid_errcode;
    global Map<String, String> jobid_message;
    // Implement this interface method
    global XC_QRBatchJobStatusUpdate_MockGenerator(Map<String, String> code, Map<String, String> message){
        this.jobid_errcode = code != null ? code : new Map<String, String>();
        this.jobid_message = message != null ? message : new Map<String, String>();
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('PUT', req.getMethod());
        
        // Create a fake response
        Map<String, Object> reqBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        String bulkjobid = String.valueOf(reqBody.get('bulk_job_id'));

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        XC_BA002_QRGBatchJob_U.WSResult fakeres = new XC_BA002_QRGBatchJob_U.WSResult();
        fakeres.result = new XC_BA002_QRGBatchJob_U.Result();
        fakeres.result.error_code = (jobid_errcode != null && String.isNotBlank(jobid_errcode.get(bulkjobid)))? jobid_errcode.get(bulkjobid) : '';
        fakeres.result.message = (jobid_message != null && String.isNotBlank(jobid_message.get(bulkjobid)))? jobid_message.get(bulkjobid) : '';
        
        if(String.isNotBlank(fakeres.result.error_code)) res.setBody(JSON.serialize(fakeres));
        else res.setBody('');

        res.setStatusCode(200);

        return res;
    }
}