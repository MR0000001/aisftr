/**
 * The Class XC_REST_SMS.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 13/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for SMS
 */
 

public without sharing class XC_REST_SMS_W {

    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
            
        /** The Account. */
        public WrapperSMS SMS = new WrapperSMS();

    }


    /**
     * The Class WrapperSMS.
     *
     * @description the wrapper sms
     */
    public class WrapperSMS {

        /** The SMS ID. */
        public String SMSID;

        /** The Status Code. */
        public String StatusCode;

        /** The Status Description. */
        public String StatusDescription;

        /** The Date. */
        public String DateSMS;
        
        public String OutboundInteractionID;

        public String Country;

        public String Sender;

        public String Mobile;

        public String Text;

        public String TextFormat;

        public DateTime ScheduleDate;

    }

    
    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
            
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
    }

}