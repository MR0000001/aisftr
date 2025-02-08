/**
 * The Class XC_REST_UpdateCreditCardPaymentMethod_U.
 *
 * @author            : Luca Tedeschi ltedeschi@deloitte.it - Simone Trenta strenta@deloitte.it
 * @date Creation     : 01/02/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util of XC_REST_UpdateCreditCardPaymentMethod
 **/


public class XC_REST_UpdateCreditCardPaymentMethod_U {

    /**
     * The Class WrapperRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperRequest {
        
        /** The address line 1. */
        public String addressLine1;
        
        /** The address line 2. */
        public String addressLine2;
        
        /** The card holder name. */
        public String cardHolderName;
        
        /** The city. */
        public String city;
        
        /** The country. */
        public String country;
        
        /** The default payment method. */
        public Boolean defaultPaymentMethod;
        
        /** The email. */
        public String email;
        
        /** The expiration month. */
        public String expirationMonth;
        
        /** The expiration year. */
        public String expirationYear;
        
        /** The num consecutive failures. */
        public Integer numConsecutiveFailures;
        
        /** The phone. */
        public String phone;
        
        /** The security code. */
        public String securityCode;
        
        /** The state. */
        public String state;
        
        /** The zip code. */
        public String zipCode;
        //public ;
    }
    
    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {
    	
	    /** The reasons. */
	    public List<Reasons> reasons;
        
        /** The success. */
        public Boolean success;
        
        /** The payment method id. */
        public String paymentMethodId;
    }
    
    /**
     * The Class Reasons.
     *
     * @description wrapper reasons
     */
    public class Reasons {
        
        /** The code. */
        public Integer code;
        
        /** The message. */
        public String message;
    }
    

}