/**
* @description XC_UTIL_Integration - Util class for Integration
*/
 
public without sharing class XC_UTIL_Integration {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Integration');


    /** @description Wrapper Header */ 
    public class Header{
        public String TransactionID; 
        public DateTime DateTimeMessage;
        public String Operation;
        public String Functionality;
        public String ClientSystem;
        public String ServerSystem;
    }

    /** @description Wrapper Result */
    public class Result{
        public String ErrorCode;
        public String Message;
        //Add for RFID
        public String Description;
        public String logError;
    }    

    /** @description WrapperResult */
    public class WrapperResult{
        public string errorMessage;
        public boolean errorFlag;
        public String errorCode;
        
        /** @description Costructor */
        public WrapperResult(){
            errorFlag = false;
            errorMessage = '';
            errorCode = '';
        }
    }

    /** @description ContextResponseWrapper */
    public class ContextResponseWrapper {
        public String msgResponse;
        public String errorCode;
        public Map<String, String> mapHeader;
    }

    /** @description RestContextResponseWrapper */
    public class RestContextResponseWrapper {
        public System.RestResponse res;
        public String msgResponse;
        public String errorCode;
        public Map<String, String> mapHeader = new Map<String, String>();
    }
    
    /** @description Wrapper Result in snake case (with underscores) */
    public class ResultSnakeCase {
        public String error_code;
        public String message;
        /** @description constructor */
        public ResultSnakeCase(){
            this.error_code = '';
            this.message = '';
        }
    } 

    /**
    * @description method to validateHeader
    * @return WrapperResult
    * @param mapHeader
    */
    public static WrapperResult validateHeader(Map<String, String> mapHeader) {
        return XC_UTIL_Integration_U.validateHeader(mapHeader);
    }


    /**
    * @description method to validateHeader
    * @return WrapperResult
    * @param h
    **/
    public static WrapperResult validateHeader(XC_UTIL_Integration.Header h){
        WrapperResult wR = new WrapperResult();
        
        if(h==null){
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header';
            wR.errorFlag = true;
            return wR;
        }

        if (String.isBlank(h.TransactionID)){
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.TransactionID';
            wR.errorFlag = true;
            return wR;
        }

        if (h.DateTimeMessage == null) {
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.DateTimeMessage';
            wR.errorFlag = true;
            return wR;
        }

        // First, instantiate a new Pattern object "MyPattern"
        //Pattern MyPattern = Pattern.compile('[20**][01-12][01-31][00-23][00-59][00-59][000-999]');

        // Then instantiate a new Matcher object "MyMatcher"
        //Matcher MyMatcher = MyPattern.matcher(String.valueOf(h.DateTimeMessage));

        /*if (!MyMatcher.matches()) {
            wR.errorMessage = 'Header.DateTimeMessage not correct';
            wR.errorFlag = true;
            return wR;
        }*/
        
        if (String.isBlank(h.Operation)){
            wR.errorMessage = Label.XC_CL_MandatoryField +' Header.Operation';
            wR.errorFlag = true;
            return wR;
        }

        if (String.isBlank(h.Functionality)){
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.Functionality';
            wR.errorFlag = true;
            return wR;
        }    
        
        if (String.isBlank(h.ClientSystem)){
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.ClientSystem';
            wR.errorFlag = true;
            return wR;
        }

        if (String.isBlank(h.ServerSystem)){
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.ServerSystem';
            wR.errorFlag = true;
            return wR;
        } 
        

        return wR;
    }

    /**
    * @description method to convertFromStringToBoolean
    * @return Boolean
    * @param str - String
    */
    public static Boolean convertFromStringToBoolean (String str){
        if (str == 'Y'){
            return true;
        }
        return false;
    }

    /**
    * @description method to convertFromStringToBoolean
    * @return String
    * @param bool - Boolean
    */
    public static String convertFromBooleanToString (Boolean bool){
        if (bool){
            return 'Y';
        }
        return 'N';
    }

    /**
    * @description method to convertFromStringToBoolean
    * @param contextWrapper - RestContextResponseWrapper
    */
    public static void setRestContextResponse(RestContextResponseWrapper contextWrapper) {
        Integer errorHTTP;
        contextWrapper.res.responseBody = Blob.valueOf(contextWrapper.msgResponse);
        contextWrapper.res.addHeader('Content-Type', 'application/json;charset=UTF-8');  
        contextWrapper.res.addHeader('TransactionID', contextWrapper.mapHeader.get('TransactionID'));
        contextWrapper.res.addHeader('DateTimeMessage', DateTime.Now().formatGMT('yyyyMMddHHmmssSSS'));
        contextWrapper.res.addHeader('Operation', contextWrapper.mapHeader.get('Operation'));
        contextWrapper.res.addHeader('Functionality', contextWrapper.mapHeader.get('Functionality'));
        contextWrapper.res.addHeader('ClientSystem', contextWrapper.mapHeader.get('ClientSystem'));
        contextWrapper.res.addHeader('ServerSystem', contextWrapper.mapHeader.get('ServerSystem'));

        List<String> errorCodeList = new List<String> {'400', '401', '404', '500', '501', '502', '503'};

        //Mapping errorCode input parameter - HTTP Status
        //More values of errorCode might be mapped to same HTTP status 
        /*if((contextWrapper.errorCode == '400') || (contextWrapper.errorCode == '401') || (contextWrapper.errorCode == '404') || (contextWrapper.errorCode == '500') 
            || (contextWrapper.errorCode == '501') || (contextWrapper.errorCode == '502') || (contextWrapper.errorCode == '503')) {*/
        
        if(errorCodeList.contains(contextWrapper.errorCode)){
            errorHTTP = Integer.valueOf(contextWrapper.errorCode);
        } else {
            errorHTTP = 200;
        }
            /*if(contextWrapper.errorCode=='404')
                errorHTTP = 404;
            else
                if(contextWrapper.errorCode=='500')
                    errorHTTP = 500;
                else    
                    errorHTTP = 200;*/
        
        errorHTTP = 200;

        contextWrapper.res.statusCode = errorHTTP;
    }

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Version of the setRestContextResponse method used to reduce the input list parameter
     * @param res - System.RestResponse
     * @param contextResponse - ContextResponseWrapper
    **/
    public static void setRestContextResponse(System.RestResponse res, ContextResponseWrapper contextResponse) {
        
        Integer errorHTTP;
        Map<String, String> mapHeader = contextResponse.mapHeader;

        res.responseBody = Blob.valueOf(contextResponse.msgResponse);
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');  
        res.addHeader('TransactionID', mapHeader.get('TransactionID'));
        res.addHeader('DateTimeMessage', DateTime.Now().formatGMT('yyyyMMddHHmmssSSS'));
        res.addHeader('Operation', mapHeader.get('Operation'));
        res.addHeader('Functionality', mapHeader.get('Functionality'));
        res.addHeader('ClientSystem', mapHeader.get('ClientSystem'));
        res.addHeader('ServerSystem', mapHeader.get('ServerSystem'));

        //Mapping errorCode input parameter - HTTP Status
        //More values of errorCode might be mapped to same HTTP status 
        if((contextResponse.errorCode == '400') ||
            (contextResponse.errorCode == '404') ||
            (contextResponse.errorCode == '500')) {
            errorHTTP = Integer.valueOf(contextResponse.errorCode);
        } else {
            errorHTTP = 200;
        }
            /*if(errorCode=='404')
                errorHTTP = 404;
            else
                if(errorCode=='500')
                    errorHTTP = 500;
                else    
                    errorHTTP = 200;*/
        
        errorHTTP = 200;

        res.statusCode = errorHTTP;
    }


    /**
    * @author Nicola Mariniello nmariniello@deloitte.it
    * @date Creation 14/12/2018
    * @description Method to get the access_token and the zuora_ids for sending a REST request
    * @return Map<String, String>
    */
    public static Map<String, String> getInfosForZuoraRest(){
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        if(Schema.sObjectType.Zuora_OAuth__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.EntityName__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.EntityId__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Client_Secret__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Client_Id__c.isAccessible() && Schema.sObjectType.Zuora_OAuth__c.fields.Host__c.isAccessible()){
            zws = [SELECT EntityName__c, EntityId__c, Client_Secret__c, Client_Id__c, Host__c FROM Zuora_OAuth__c WHERE EntityName__c LIKE '%Spain%' LIMIT 1];
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://' + zws.Host__c + '/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials' + '&client_secret=' + zws.Client_Secret__c + '&client_id=' + zws.Client_Id__c);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        Map<String, String> resultMap = new  Map<String, String>();
        resultMap.put('access_token', (String) response.get('access_token'));
        resultMap.put('zuora_ids', zws.EntityId__c);
        resultMap.put('host', zws.Host__c);

        return resultMap;     
    }

    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @date Creation 19/03/2019
    * @description Validate input request for Doxee integration
    * @param  objectType
    * @param  category
    * @return WrapperResult 
    */
    public static WrapperResult validateFileRequest(String objectType, String category){ 
        WrapperResult wR = new WrapperResult();
        List<XC_CM_FileCategoryObjectTypeMapping__mdt> mappingRow = new List<XC_CM_FileCategoryObjectTypeMapping__mdt>();
        if(Schema.sObjectType.XC_CM_FileCategoryObjectTypeMapping__mdt.isAccessible() && Schema.sObjectType.XC_CM_FileCategoryObjectTypeMapping__mdt.fields.id.isAccessible() && Schema.sObjectType.XC_CM_FileCategoryObjectTypeMapping__mdt.fields.XC_FileCategory__c.isAccessible() && Schema.sObjectType.XC_CM_FileCategoryObjectTypeMapping__mdt.fields.XC_ObjectType__c.isAccessible()){
            mappingRow = [SELECT id, XC_FileCategory__c, XC_ObjectType__c 
                            FROM XC_CM_FileCategoryObjectTypeMapping__mdt
                            WHERE XC_FileCategory__c =: category AND XC_ObjectType__c =: objectType ];
        }
        if ( mappingRow.size() == 0 ){
            wR.errorMessage = Label.XC_CL_InvalidObjT+' '+objectType+' '+Label.XC_CL_FileCategory+' '+category;
            wR.errorFlag = true;
            return wR;
        }
        
        return wR;   
    }
    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @date Creation 15/10/2019
    * @description Check if all the fields in the map are filled
    * @param  fieldMap
    */
    public static WrapperResult checkMandatory(Map<String,Object> fieldMap){
        WrapperResult result = new WrapperResult();
        for(String s:fieldMap.keySet()){
            if(fieldMap.get(s)==null||String.isBlank(fieldMap.get(s)+'')){
                result.errorMessage = 'ERROR. Missing mandatory field: '+s;
                result.errorFlag = true;
                return result; 
            }
        }
        return result; 
    }    
}