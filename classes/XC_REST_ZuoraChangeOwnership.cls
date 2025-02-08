/**
 * @description The Class XC_REST_ZuoraChangeOwnership.
 */
public class XC_REST_ZuoraChangeOwnership {
 
 /**
  * @description The Class WrapperRequest.
  */
 public class WrapperRequest {
        
        /** The apply credit balance. */
        public Boolean applyCreditBalance;
        
        /** The collect X. */
        public Boolean collectX;
        
        /** The contract effective date. */
        public String contractEffectiveDate;
        
        /** The extends term. */
        public Boolean extendsTerm;
        
        /** The invoice. */ 
        public Boolean invoice;
        
        /** The invoice collect. */
        public Boolean invoiceCollect;
        
        /** The invoice target date. */
        public String invoiceTargetDate;
        
        /** The resume periods. */
        public String resumePeriods;
        
        /** The resume periods type. */
        public String resumePeriodsType;
        
        /** The resume policy. */
        public String resumePolicy;
        
        /** The resume specific date. */
        public String resumeSpecificDate;
        
        /** The run billing. */
        public Boolean runBilling;
        
        /** The target date. */
        public String targetDate;
    }

    /**
     * @description  The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The success. */
        public Boolean success;
        
        /** The subscription id. */
        public String subscriptionId;
        
        /** The resume date. */
        public String resumeDate;
        
        /** The term end date. */
        public String termEndDate;
        
        /** The total delta tcv. */
        public Double totalDeltaTcv;
        
        /** The reasons. */
        public List<Reasons> reasons;
    }

        /**
         *@description  The Class Reasons.
         */
        public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
	
	/**
	 *@description Resume subscription.
	 *
	 * @param subscriptionId the subscription id
	 * @param wrReq the wr req
	 * @return the wrapper response
	 */
	/*
    * @description  Method to send a request to change the ownership of a subscription
    ****************************************************************************************************/
    public static WrapperResponse resumeSubscription(String subscriptionId, WrapperRequest wrReq) {
        WrapperResponse result = new WrapperResponse();

        Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_ResumeSubscription);
		if(activeInterface) {
            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();

			String url = 'https://rest.sandbox.eu.zuora.com/v1/subscriptions/' + subscriptionId + '/resume';
			String body =  JSON.serialize(wrReq, true);
            body = body.replace('collectX', 'collect');

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
            headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));

            if(wrReq.invoice != null || wrReq.collectX != null) {
                headerDefinitions.put('zuora-version', '196.0');
            } else if (wrReq.runBilling != null || !String.isBlank(wrReq.targetDate)) {
                headerDefinitions.put('zuora-version', '211.0');
            }

	  		HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
	  		//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', 'ResumeSubscription');
	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, 'ResumeSubscription');

            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
		} else {
            result.success = true;
            result.subscriptionId = 'FakeID';
		}

        System.debug('RESULT ---> ' + result);
        return result;
    }
    
}