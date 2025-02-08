/**
 * The Class XC_REST_SendSMS.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it - Simone Trenta strenta@deloitte.it
 * @date Creation     : 30/10/2018
 * @date Modification : 26/06/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : XC_REST_SendSMS – Rest Resourse for sending SMS
 */
    

public class XC_REST_SendSMS {
    
    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{
		
		/** 
         * @description The success. 
         */
		@AuraEnabled
		public Boolean success {get; set;} 

		/** 
         * @description The message. 
         */
        @AuraEnabled
		public String message {get; set;} 
	}

    /**
     * @description The Class WrapperSMSRequest.
     */
    public class WrapperSMSRequest {

        public XC_REST_SMS_W.WrapperSMS SMS;
    }

    /**
     * @description  The Class WrapperSMSResponse.
     */
    public class WrapperSMSResponse {
        
        public XC_UTIL_Integration.Result Result;

        public XC_REST_SMS_W.WrapperSMS SMS;

    }


    /**
     * CallToSendSMS.
     *
     * @param requestSMS the wrapper request
     * @return the result wrapper
     * @description method to send the sms
     */
    public static ResultWrapper callToSendSMS(WrapperSMSRequest requestSMS) {

        ResultWrapper result = new ResultWrapper();
        result = validateRequest(requestSMS);
        if(!result.success){
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_SendSMS); 
        if(isActiveInterface.activeInterface){

            String url = isActiveInterface.url;
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'SendSMS', 'SmsGwSpain');
            String body = JSON.serialize(requestSMS, true);

            /********************** Create outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[sendSMS] request -> ' + request);
            System.debug('[sendSMS] request BODY -> ' + body);

            /********************** Send outbound request *************************************/
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'SendSMS');    
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'SendSMS');    
            
            
            result = manageResponse(response);
      
		} else {
			result.success = true;
            result.message = 'Fake Response'; 
		} 

        return result;
    }


    /**
     * ValidateRequest.
     *
     * @param requestSMS the wrapper request
     * @return the result wrapper
     * @description method to validate the mandatory fields
     */
    private static ResultWrapper validateRequest(WrapperSMSRequest requestSMS){
        ResultWrapper res = new ResultWrapper();

        Map<String,String> mandatoryFields = new Map<String,String>{'OutboundInteractionID' => requestSMS.SMS.OutboundInteractionID,
                                                                    'Country' => requestSMS.SMS.Country,
                                                                    'Mobile' => requestSMS.SMS.Mobile,
                                                                    'Text' => requestSMS.SMS.Text,
                                                                    'TextFormat' => requestSMS.SMS.TextFormat
                                                                    };

        for(String field : mandatoryFields.keySet()) {
            if(String.isBlank(mandatoryFields.get(field))) {
                res.message = 'Missing mandatory field: SMS.'+field;
                res.success = false;
                return res;
            } 
        } 

        res.success = true;
        return res;
    }


    /**
     * ManageResponse.
     *
     * @param response the response
     * @return the result wrapper
     * @description method to manage the response
     */
    private static ResultWrapper manageResponse(HttpResponse response){
		
        ResultWrapper result = new ResultWrapper();

        if(response == null) {
            result.success = false;
            result.message = Label.XC_CL_ResponseServer;
            System.debug('No response from the server');
            return result;
        } 

        System.debug('[sendSMS] response -> ' + response);
        if(response.getStatusCode() == 200) {
            System.debug('[sendSMS] response Body -> ' + response.getBody());
            WrapperSMSResponse responseSMS = (WrapperSMSResponse) JSON.deserialize(response.getBody(), WrapperSMSResponse.class);
            if(responseSMS.Result.ErrorCode != '0') {
                result.success = false;
                result.message = responseSMS.Result.Message;
                System.debug('ERROR for SendSMS! -> StatusCode: ' + response.getStatusCode() + '   Status: ' + response.getStatus());

            } else {
                return updateCustomerInteraction(responseSMS);
            }
        } else {
            result.success = false;
            result.message = 'Status Code = ' + response.getStatusCode();
            System.debug('Status Code = ' + response.getStatusCode());
            return result;
        }
        
		return result;
	}

    
    /**
     * UpdateCustomerInteraction.
     *
     * @param responseWr the response wrapper
     * @return the result wrapper
     * @description method to update the customer interaction with the SMS id
     */
    private static ResultWrapper updateCustomerInteraction(WrapperSMSResponse responseWr){

        ResultWrapper result = new ResultWrapper();

        XC_Customer_Interaction__c custInter = new XC_Customer_Interaction__c();
        custInter.Id = responseWr.SMS.OutboundInteractionID;
        if(responseWr.SMS.SMSID.contains('INFO - ')) {
            custInter.XC_SMSID__c = responseWr.SMS.SMSID.split('INFO - ')[1];
        } else {
            custInter.XC_SMSID__c = responseWr.SMS.SMSID;
        }
        
        XC_UTIL_Sobject.WrapperResult resUpdate = XC_UTIL_Sobject.updaterecord(custInter);
        if(!resUpdate.success) {
            result.success = false;
            result.message = Label.XC_CL_UpdateCustomerInteraction + custInter.Id + ': ' + resUpdate.errorMessage;
            return result;

        } else {
            result.success = true;
            result.message = 'OK';
            System.debug('OK, sending SMS!');
            return result;
        }
    }

}