/**
 * The Class XC_LCC031_createUpdateWorkOrder.
 *
 * @author Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date Creation 15/11/2018
 * @description Interface Outbound for Work Order
 */

public class XC_LCC031_createUpdateWorkOrder {
    
    /** The Constant CLASS_NAME. */
    private static final String CLASS_NAME = '';
    
    /**
     * @description The Class ResultWrapper.
     */
    //Wrapper response
    public class ResultWrapper{
        
        /** @description The transaction ID. */
        @AuraEnabled
        public String  transactionID {get;set;}
        
        /** @description The system X. */
        @AuraEnabled
        public String  systemX       {get;set;}
        
        /** @description The result. */
        @AuraEnabled
        public String  result         {get;set;} 
        
        /** @description The work order ID. */
        @AuraEnabled
        public String workOrderID    {get;set;}
        
        /** @description The note. */
        @AuraEnabled
        public String note {get;set;}
        
    }
    
    /**
     * @description The Class FieldWrapper.
     */
    //Wrapper request
    public class FieldWrapper{	
        
        /** @description The transaction ID. */
        //===HEADER=== 
        String transactionID;
        
        /** @description The system X. */
        String systemX;
        
        /** @description The action. */
        String action;
        
        /** @description The account id. */
        //===WORK ORDER==
        String accountId;
        
        /** @description The contact id. */
        String contactId;
        
        /** @description The work type. */
        String workType;
        
        /** @description The name. */
        String name;
        
        /** @description The description. */
        String description;
        
        /** @description The country. */
        //===ADDRESS===
        String country;
        
        /** @description The city. */
        String city;
        
        /** @description The postal code. */
        String postalCode;
        
        /** @description The street. */
        String street;
        
        /** @description The state. */
        String state;
        
        
    }
    
    /**
     * @description Execute authentication call.
     * 
     * @param fWr the f wr
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper executeAuthenticationCall(FieldWrapper fWr){
        Map<String, String> headerDef = new Map<String, String>();
        String bodyRequest = '{"transactionID" : "'+fWr.transactionID+'","System" : "'+fWr.systemX+'","action" : "'+fWr.action+'","accountId" : "'+fWr.accountId+
            					'" ,"contactId" : "'+fWr.contactId+'" ,"workType" : "'+fWr.workType+'" ,"name" : "'+fWr.name+'" ,"description" : "'+fWr.description+
            					'"  ,"country" : "'+fWr.country+'" ,"city" : "'+fWr.city+'" ,"postalCode" : "'+fWr.postalCode+'" ,"street" : "'+fWr.street+'" ,"state" : "'+fWr.state+'"}';        
        HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST','https://URL', headerDef, bodyRequest);
        HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request, CLASS_NAME);
        return manageAuthenticationResponce(response);
    }
    
    /**
     * @description Manage authentication responce.
     *
     * @param response the response
     * @return the result wrapper
     */
    private static ResultWrapper manageAuthenticationResponce(HttpResponse response){
        ResultWrapper result = new ResultWrapper();
        if(response==null) {
            return result; //if the response is null return result empty
        }
        else {
            return result;
        //	result = JSON.deserializeUntyped(response.getBody());
        }
    }
}