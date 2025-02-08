/**
* @author Andrea Di Cicco
* @date Creation 10/09/2020
* @description REST INTERFACE : 
*/
public class XC_REST_DeleteODA_Outbound_U {
    /**
     * @description wrapper class for request 
     */
    public class RequestWrapper {
        public ODAWrapper purchase_order;
    }

    /**
     * @description wrapper class for response
     */
    public class ResponseWrapper {
        public XC_UTIL_Integration.ResultSnakeCase result;
        
        /**
        * @description constructor
        */
        public ResponseWrapper(){ 
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }
    
     /**
     * @description wrapper class for request 
     */
    public class ODAWrapper {
        public String sfdc_id;
        public String source_system;
        public String target_system;
        public String po_number;
    }
}