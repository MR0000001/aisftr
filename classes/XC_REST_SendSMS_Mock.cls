/**
 * The Class XC_REST_SendSMS_Mock.
 *
 * @author            : Simone Trenta strenta@deloitte.it
 * @date Creation     : 03/06/2019
 * @date Modification : 26/06/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : XC_REST_SendSMS_Mock – Mock class for sending SMS
 */

@isTest
global class XC_REST_SendSMS_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {    
        
        HttpResponse response = new HttpResponse();
        
        if(req.getEndpoint().endsWith('1')) {
            XC_REST_SendSMS.WrapperSMSResponse resp = new XC_REST_SendSMS.WrapperSMSResponse();
        	resp.Result = new XC_UTIL_Integration.Result();
        	resp.Result.ErrorCode = '1';
            resp.Result.Message = 'Error';
        	resp.SMS = new XC_REST_SMS_W.WrapperSMS();
        	resp.SMS.SMSID = '1234';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp, true));
            response.setStatusCode(200);
        } else if(req.getEndpoint().endsWith('500')) {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('');
            response.setStatusCode(500);
        } else {
            XC_REST_SendSMS.WrapperSMSResponse resp = new XC_REST_SendSMS.WrapperSMSResponse();
        	resp.Result = new XC_UTIL_Integration.Result();
        	resp.Result.ErrorCode = '0';
            resp.Result.Message = 'Operation completed successfully';
        	resp.SMS = new XC_REST_SMS_W.WrapperSMS();
        	resp.SMS.SMSID = '1234';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp, true));
            response.setStatusCode(200);
        }
        
        return response;
    }
}