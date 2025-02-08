/**
 * The Class XC_REST_Usage.
 *
 * @author            : Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation     : 18/12/2018
 * @date Modification : 28/12/2018
 * @description       : Manege POST call 'Usage' of Data for Accounts (Integration with Zuora)
 */


public class XC_REST_Usage {


    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The Account id. */
        public String AccountId; //required in alternativa ad AccountNumber
        
        /** The Account number. */
        public String AccountNumber; //required in alternativa ad AccountId
        
        /** The Charge id. */
        public String ChargeId;
        
        /** The End date time. */
        public String EndDateTime;
        
        /** The Quantity. */
        public Double Quantity; //required
        
        /** The Rbe status. */
        public String RbeStatus; //{Importing, Pending, Processed} -> "Only usage with Pending status can be updated."
        
        /** The Start date time. */
        public String StartDateTime; //required -> es: '2018-12-20T05:41:36.000+02:00'
        
        /** The Submission date time. */
        public String SubmissionDateTime;
        
        /** The Subscription id. */
        public String SubscriptionId;
        
        /** The uom. */
        public String UOM; //required
        //others custom fields
    }


    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The Success. */
        public Boolean Success;
        
        /** The Id. */
        public String Id;
        
        /** The Errors. */
        public List<Reasons> Errors;
    }


    /**
     * The Class Reasons.
     *
     * @description the wrapper reasons
     */
    public class Reasons {
        
        /** The Code. */
        public String Code;
        
        /** The Message. */
        public String Message;
    }


    /**
     * Creates the usage.
     *
     * @param zuoraTrackId the zuora track id
     * @param wrReq the wr req
     * @return the wrapper response
     * @description method to create usage in Zuora
     */
    public static WrapperResponse createUsage(String zuoraTrackId, WrapperRequest wrReq) {
        WrapperResponse result = new WrapperResponse();
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_UsageAccountsData);
		if(isActiveInterface.activeInterface) {
            Map<String, String> infoZuora = XC_UTIL_Integration.getInfosForZuoraRest();

			String url = isActiveInterface.url;
			String body = JSON.serialize(wrReq, true);

            Map<String,String> headerDefinitions = new Map<String,String>();
            headerDefinitions.put('Content-Type', 'application/json');
            headerDefinitions.put('Authorization', 'Bearer ' + infoZuora.get('access_token'));
            headerDefinitions.put('Zuora-Entity-Ids', infoZuora.get('zuora_ids'));
            headerDefinitions.put('Zuora-Track-Id', zuoraTrackId);
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, '', Label.XC_CL_UsageAccountsData);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogginG(request, headerDefinitions, Label.XC_CL_UsageAccountsData);
          
            result = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);

        } else {
            result.Success = true;
            result.Id = 'FakeID';
		}

        System.debug('RESULT UsageAccountsData Integration ---> ' + result);
        return result;
    }
}