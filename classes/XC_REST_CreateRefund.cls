/**
 * The Class XC_REST_CreateRefund.
 *
 * @author 		 : Giulio Serra
 * @date Creation	 : 03/01/2019
 * @date Modification : 11/03/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description 	 : XC_REST_CreateRefund – Create a Zuora refund (API RefundPayment - https://www.zuora.com/developer/api-reference/#operation/POST_RefundPayment)
 */

public class XC_REST_CreateRefund {
    
	/**
	 * @description The Class RequestWrapper.
	 */
	public class RequestWrapper{
		
		/** The comment. */
		public String comment;
		
		/** The finance information. */
		public FinanceInformationWrapper financeInformation;
		
		/** The method type. */
		public String methodType;
		
		/** The reason code. */
		public String reasonCode;
		
		/** The reference id. */
		public String referenceId;
		
		/** The refund date. */
		public String refundDate;	
		
		/** The second refund reference id. */
		public String secondRefundReferenceId;
		
		/** The total amount. */
		public Double totalAmount;		// Y
		
		/** The type. */
		public String type;				// Y
		
		/** The Integration id NS. */
		public String IntegrationIdNS;
		
		/** The Integration status NS. */
		public String IntegrationStatusNS;
		
		/** The Origin NS. */
		public String OriginNS;
		
		/** The Sync date NS. */
		public String SyncDateNS;
		
		/** The Syncto net suite NS. */
		public String SynctoNetSuiteNS;	
	}

	/**
	 * @description The Class FinanceInformationWrapper.
	 */
	public class FinanceInformationWrapper{
		
		/** The bank account accounting code. */
		public String bankAccountAccountingCode;
		
		/** The bank account accounting code type. */
		public String bankAccountAccountingCodeType;
		
		/** The transferred to accounting. */
		public String transferredToAccounting;
		
		/** The unapplied payment accounting code. */
		public String unappliedPaymentAccountingCode;
		
		/** The unapplied payment accounting code type. */
		public String unappliedPaymentAccountingCodeType;
	}
                                                

	/**
	 * @description The Class ResponseWrapper.
	 */
	public class ResponseWrapper{
		
		/** The account id. */
		public String accountId;
		
		/** The amount. */
		public Double amount;
		
		/** The cancelled on. */
		public String cancelledOn;
		
		/** The comment. */
		public String comment;
		
		/** The created by id. */
		public String createdById;
		
		/** The created date. */
		public String createdDate;
		
		/** The credit memo id. */
		public String creditMemoId;
		
		/** The finance information. */
		public FinanceInformationWrapper financeInformation;
		
		/** The gateway id. */
		public String gatewayId;
		
		/** The gateway response. */
		public String gatewayResponse;
		
		/** The gateway response code. */
		public String gatewayResponseCode;
		
		/** The gateway state. */
		public String gatewayState;
		
		/** The id. */
		public String id;
		
		/** The marked for submission on. */
		public String markedForSubmissionOn;
		
		/** The method type. */
		public String methodType;
		
		/** The number response. */
		public String numberResponse;
		
		/** The payment id. */
		public String paymentId;
		
		/** The payment method id. */
		public String paymentMethodId;
		
		/** The payment method snapshot id. */
		public String paymentMethodSnapshotId;
		
		/** The reason code. */
		public String reasonCode;
		
		/** The reference id. */
		public String referenceId;
		
		/** The refund date. */
		public String refundDate;
		
		/** The refund transaction time. */
		public String refundTransactionTime;
		
		/** The second refund reference id. */
		public String secondRefundReferenceId;
		
		/** The settled on. */
		public String settledOn;
		
		/** The soft descriptor. */
		public String softDescriptor;
		
		/** The soft descriptor phone. */
		public String softDescriptorPhone;
		
		/** The status. */
		public String status;
		
		/** The submitted on. */
		public String submittedOn;
		
		/** The success. */
		public Boolean success;
		
		/** The type. */
		public String type;
		
		/** The updated by id. */
		public String updatedById;
		
		/** The updated date. */
		public String updatedDate;
		
		/** The Integration id NS. */
		public String IntegrationIdNS;
		
		/** The Integration status NS. */
		public String IntegrationStatusNS;
		
		/** The Origin NS. */
		public String OriginNS;
		
		/** The Sync date NS. */
		public String SyncDateNS;
		
		/** The Syncto net suite NS. */
		public String SynctoNetSuiteNS;
		
		/** The reasons. */
		public ReasonWrapper[] reasons;
	}

	/**
	 * @description The Class ReasonWrapper.
	 */
	public class ReasonWrapper{
		
		/** The code. */
		String code;
		
		/** The message. */
		String message;
	}


	/**
	 * @description Creates the refund.
	 *
	 * @param paymentId the payment id
	 * @param requestWrapper the request wrapper
	 * @return the response wrapper
	 */
	public static ResponseWrapper createRefund(String paymentId, RequestWrapper requestWrapper){
       
        ResponseWrapper result = new ResponseWrapper();
		XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_CreateRefund);
        
        if(isActiveInterface.activeInterface){
            
            try{
				String url = isActiveInterface.url.replace('paymentId', paymentId); 
				String body =  JSON.serialize(requestWrapper, true);
				body = fixNamesViolationsRequest(body);
				
				Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();
				Map<String,String> headerDefinitions = new Map<String,String> {'Content-Type' => 'application/json',
																				'Authorization' => ('Bearer ' + infoZuora.get('access_token')),
																				'Zuora-Entity-Ids' => (infoZuora.get('zuora_ids'))};

				HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
				//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,'','CreateRefund');
				HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,headerDefinitions,'CreateRefund');

				String responseBody = fixNamesViolationsResponse(response.getBody());
                System.debug('RESPONSE before deserialize -> ' + response.getBody());
				result = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
                System.debug('RESPONSE after deserialize -> ' + result);
            }catch(Exception e){
                
                result.Success = false;
                ReasonWrapper reason = new ReasonWrapper();
                reason.code = '400';
                reason.message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                
                result.reasons.add(reason);
            }
            
		} else {
            result.success = true;
		}

        return result;
    }


    /**
     * @description Fix names violations request.
     *
     * @param serializedData the serialized data
     * @return the string
     */
    private static String fixNamesViolationsRequest(String serializedData){

    	serializedData = serializedData.replace('OriginNS', 'Origin__NS');
    	serializedData = serializedData.replace('SyncDateNS', 'SyncDate__NS');
    	serializedData = serializedData.replace('IntegrationIdNS', 'IntegrationId__NS');
    	serializedData = serializedData.replace('IntegrationStatusNS', 'IntegrationStatus__NS');
    	serializedData = serializedData.replace('SynctoNetSuiteNS', 'SynctoNetSuite__NS');

    	return serializedData;
    }

	/**
	 * @description Fix names violations response.
	 *
	 * @param serializedData the serialized data
	 * @return the string
	 */
	private static String fixNamesViolationsResponse(String serializedData){

		serializedData = serializedData.replace('number', 'numberResponse');
    	serializedData = serializedData.replace('Origin__NS', 'OriginNS');
    	serializedData = serializedData.replace('SyncDate__NS', 'SyncDateNS');
    	serializedData = serializedData.replace('IntegrationId__NS', 'IntegrationIdNS');
    	serializedData = serializedData.replace('IntegrationStatus__NS', 'IntegrationStatusNS');
    	serializedData = serializedData.replace('SynctoNetSuite__NS', 'SynctoNetSuiteNS');

    	return serializedData;
    }
}