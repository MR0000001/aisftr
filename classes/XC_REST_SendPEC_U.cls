/**
 * The Class XC_REST_SendPEC_U.
 *
 * @author            : Giuseppe Di Bonito
 * @date Creation     : 15/02/2021
 * @date Modification : 
 * @description       : Util for XC_REST_SendPEC
 **/
public class XC_REST_SendPEC_U {
    
    /**
     * The Class RequestWrapper.
     *
     * @description the wrapper request
     */
    public class RequestWrapper{
        
        public SendPEC SendPEC;
        
        /**
         * @description Instantiates a new request wrapper.
         */
        public RequestWrapper(){
            SendPEC = new SendPEC();
        }
    }
    
    /**
     * The Class SendPEC.
     *
     * @description the file wrapper
     */
    public class SendPEC{
        
        public String receiver_pec;
        public String body;
        public String subject;
        public String sender_pec;
        public String legal_entity;
        public String email_type;
    }
        

    /**
     * The Class ResponseWrapper.
     *
     * @description the wrapper response
     */
    public class ResponseWrapper{
        
        public XC_UTIL_Integration.ResultSnakeCase Result = new XC_UTIL_Integration.ResultSnakeCase();     
    }
         
    /**
     * Check required parameters.
     *
     * @param wrapper the wrapper
     * @return the XC_UTIL_Integration.ResultSnakeCase
     * @description check Required Parameters
     */
    public static XC_UTIL_Integration.ResultSnakeCase checkRequiredParameters(RequestWrapper wrapper) {
        XC_UTIL_Integration.ResultSnakeCase response = new XC_UTIL_Integration.ResultSnakeCase();

        Map<String, String> requiredParameters = new Map<String, String>{'receiver_pec' => wrapper.SendPEC.receiver_pec,
                                                                            'body' => wrapper.SendPEC.body,
                                                                            'subject' => wrapper.SendPEC.subject,
                                                                            'sender_pec' => wrapper.SendPEC.sender_pec,
                                                                            'legal_entity' => wrapper.SendPEC.legal_entity
                                                                        };
        for(String key : requiredParameters.keySet()) {
            if(String.isBlank(requiredParameters.get(key))) {
                response.message = Label.XC_CL_MandatoryField +'pec.' + key;
                response.error_code = '400';
                return response;
            }
        }
        response.error_code = '0';
        return response;
    }
}