/**
 * The Class XC_LCC006_AccountCreditCheck.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 17/09/2018
 * @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
 * @description XC_LCC006_AccountCreditCheck – STUB Controller for XC_LCP006_AccountCreditCheck Component
 */


public class XC_LCC006_AccountCreditCheck {
    
    /**
     * The Class ResultWrapper.
     * @description ResultWrapper
     */
    public class ResultWrapper{
        
        /** The success. 
        * @description success
        */
        @AuraEnabled
        public Boolean success {get; set;} 
        
        /** The record fields.
        * @description recordFields
         */
        @AuraEnabled
        public List<FieldWrapper> recordFields {get; set;} 
        
    }
    
    /**
     * The Class FieldWrapper.
     * @description FieldWrapper
     */
    public class FieldWrapper{
        
        /** The field label. 
        * @description fieldLabel
        */
        @AuraEnabled
        public String fieldLabel {get; set;} 
        
        /** The field value. 
        * @description fieldValue
        */
        @AuraEnabled 
        public String fieldValue {get; set;} 
    }
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC006_AccountCreditCheck');
    
    /**
     * Call commodity.
     *
     * @param recordId the record id
     * @description Call Commodity
     * @return the result wrapper
     */
    @AuraEnabled
    public static ResultWrapper callCommodity(Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in callCommodity');
        ResultWrapper result = new ResultWrapper();
        Account accnt = retrieveAccount(recordId);
        
        //NEW
        Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface('AccountCreditCheck');
        String url = '';
        String requestString = '';
        if(activeInterface){
           
            HttpRequest request = XC_UTIL_RESTCallout.createRequest(url, requestString);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request,'XC_LCC006_AccountCreditCheck');
            result = manageResponse(response);
        } else {
            String fakeResponse = '{"Credit Check result":"Credit check verified."}';
            result = manageResponseFake(fakeResponse,accnt);
        }
        return result; 
    }
    
    /**
     * Manage response fake.
     * @description manage a Fake Response
     * @param fakeResponse the fake response
     * @param accnt the accnt
     * @return the result wrapper
     */
    private static ResultWrapper manageResponseFake(String fakeResponse, Account accnt){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in manageResponseFake');
        ResultWrapper result = new ResultWrapper();
        result.recordFields = new List<FieldWrapper>();
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(fakeResponse); 
        for(String key : responseMap.keySet()){
            FieldWrapper wr = new FieldWrapper();
            wr.fieldLabel = key;
            wr.fieldValue = (String)responseMap.get(key);
            result.recordFields.add(wr);
            accnt.XC_Credit_check_result__c = (String)responseMap.get(key);
        }
        if(!Test.isrunningTest()){ XC_UTIL_Sobject.updateRecord(accnt); }
        result.success = true;
        return result;
    }
    
    /**
     * Manage response.
     * @description manage response
     * @param response the response
     * @return the result wrapper
     */
    private static ResultWrapper manageResponse(HttpResponse response){
        ResultWrapper result = new ResultWrapper();
        return result;
    }
    
    /**
     * Retrieve account.
     * @description retrieve Account 
     * @param recordId the record id
     * @return the account
     */
    private static Account retrieveAccount(Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in retrieveAccount');
        Account a = new Account();
        return a;
    }
}