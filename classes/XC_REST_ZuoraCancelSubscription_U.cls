/**
 * The Class XC_REST_ZuoraCancelSubscription_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 01/02/2019
 * @date Modification : 19/02/2019 by Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : UTIL for XC_REST_ZuoraCancelSubscription
 **/


public class XC_REST_ZuoraCancelSubscription_U {

    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
        
        /** The apply credit balance. */
        public Boolean applyCreditBalance;
        
        /** The cancellation effective date. */
        public String cancellationEffectiveDate;
        
        /** The cancellation policy. */
        public String cancellationPolicy;
        
        /** The collect X. */
        public Boolean collectX;
        
        /** The document date. */
        public List<String> documentDate;
        
        /** The invoice. */
        public Boolean invoice;
        
        /** The invoice collect. */
        public Boolean invoiceCollect;
        
        /** The invoice target date. */
        public String invoiceTargetDate;
        
        /** The run billing. */
        public Boolean runBilling;
        
        /** The target date. */
        public String targetDate;

        /** The legal entity. */
        public String legalEntity;

        /** The stream. */
        public String stream;
    }

    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The credit memo id. */
        public String creditMemoId;
        
        /** The paid amount. */
        public String paidAmount;
        
        /** The payment id. */
        public String paymentId;
        
        /** The success. */
        public Boolean success = false;
        
        /** The process id. */
        public String processId;
        
        /** The subscription id. */
        public String subscriptionId;
        
        /** The cancelled date. */
        public String cancelledDate;
        
        /** The total delta mrr. */
        public String totalDeltaMrr;
        
        /** The total delta tcv. */
        public String totalDeltaTcv;
        
        /** The invoice id. */
        public String invoiceId;
        
        /** The reasons. */
        public List<WrapperReason> reasons = new List<WrapperReason>();
    }

    /**
     * The Class WrapperReason.
     *
     * @description the wrapper reason
     */
    public class WrapperReason {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }

}