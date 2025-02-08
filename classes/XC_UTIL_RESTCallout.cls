/**
 * The Class XC_UTIL_RESTCallout.
 *
 * @author Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date Creation 10/10/2018
 * @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
 * @description Class Util for REST Callout
 **/
public without sharing class XC_UTIL_RESTCallout {      

    /**
     * The Class CSWrapper
     *
     * @description custom setting wrapper
     **/
    public class CSWrapper {
        public Boolean activeInterface;
        public String url;
        public String country;
        public String stream;
        public String serverSystem;
    }

    /**
     * The Class WrapperToken.
     * 
     * @description the wrapper token
     **/
    public class WrapperToken {
        public String accessToken;
  		public String instanceUrl;
  		public String id;
  		public String tokenType;
 		public String issuedAt;
  		public String signature;
        public String error;
        public String errorDescription;
    }

    /**
     * @description HttpResponseWrapper
     **/
    public class HttpResponseWrapper{
        /** @description HttpResponseWrapper **/
        public HttpResponse response;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public List<XC_Integration_Log__c> integrationLog;
    }

    /**
     * The Class NotActiveInterfaceException
     *
     * @description NotActiveInterfaceException Class
     **/
    public class NotActiveInterfaceException extends Exception {
        
    }

    /**
     * CheckActiveInterface.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param interfaceName
     * @return true if the interface is active, false otherwise
     * @description retrieve the checkbox value of the interface in the custom setting to define if the iterface in active or not
     **/
    public static Boolean checkActiveInterface(String interfaceName){
        Boolean activeInterface = false;
        
        XC_CS001_InterfaceConfiguration__c cs = XC_CS001_InterfaceConfiguration__c.getInstance(interfaceName);
        if(cs != null){
            activeInterface = cs.XC_activeInterface__c; 
        }
        return activeInterface;
    }


    /**
     * CheckActiveInterface.
     *
     * @author Federico Amici - federico.amici@nttdata.com
     * @param interfaceName name of the interface
     * @return the wrapper 
     * @description retrieve the checkbox value of the interface in the custom setting to define if the iterface in active or not.
     *              This version is used to return a wrapper instead of a Boolean
     **/
    public static CSWrapper checkActiveInterface(String interfaceName, String country){
        CSWrapper wrapper = new CSWrapper();
        wrapper.activeInterface = false;
        XC_CS001_InterfaceConfiguration__c cs = [Select XC_activeInterface__c, XC_URL_Required__c, XC_Stream__c, XC_ServerSystem__c
                                                    from XC_CS001_InterfaceConfiguration__c 
                                                    where XC_interfaceName__c = : interfaceName 
                                                    and XC_Country__c =: country 
                                                    LIMIT 1 ];
        if(cs != null){
            wrapper.activeInterface = cs.XC_activeInterface__c; 
            wrapper.url = cs.XC_URL_Required__c;
            wrapper.stream = cs.XC_Stream__c;
            wrapper.serverSystem = cs.XC_ServerSystem__c;
        }

        return wrapper;
    }


    /**
     * CheckActiveInterface2.
     *
     * @author Federico Amici - federico.amici@nttdata.com
     * @param interfaceName name of the interface
     * @return the wrapper 
     * @description retrieve the checkbox value of the interface in the custom setting to define if the iterface in active or not.
     *              This version is used to return a wrapper instead of a Boolean
     **/
    public static CSWrapper checkActiveInterface2(String interfaceName){
        CSWrapper wrapper = new CSWrapper();
        wrapper.activeInterface = false;

        XC_CS001_InterfaceConfiguration__c cs = XC_CS001_InterfaceConfiguration__c.getInstance(interfaceName);
        if(cs != null){
            wrapper.activeInterface = cs.XC_activeInterface__c; 
            wrapper.url = cs.XC_URL_Required__c;
        }

        return wrapper;
    }

    /**
     * CheckActiveInterfaceB2B.
     *
     * @author Álvaro Lag - alag@deloitte.es
     * @param interfaceName name of the interface
     * @return the wrapper 
     * @description retrieve the checkbox value of the interface in the custom setting to define if the iterface in active or not.
     *              This version is used to return a wrapper instead of a Boolean
     **/
    public static CSWrapper checkActiveInterfaceB2B(String interfaceName, String country, String segment){
        CSWrapper wrapper = new CSWrapper();
        wrapper.activeInterface = false;
        XC_CS001_InterfaceConfiguration__c cs = [Select XC_activeInterface__c, XC_URL_Required__c, XC_Stream__c, XC_ServerSystem__c
                                                    from XC_CS001_InterfaceConfiguration__c 
                                                    where XC_interfaceName__c = : interfaceName 
                                                    and XC_Country__c =: country AND XC_ServerSystem__c = 'CommoditySpainB2B'
                                                    LIMIT 1 ];
        if(cs != null){
            wrapper.activeInterface = cs.XC_activeInterface__c; 
            wrapper.url = cs.XC_URL_Required__c;
            wrapper.stream = cs.XC_Stream__c;
            wrapper.serverSystem = cs.XC_ServerSystem__c;
        }

        return wrapper;
    }

   
    /**
     * ComposeURL.
     *
     * @author Davide De Dona-Daniele Lico - Davide.DeDona@nttdata.com
     * @param baseURL the baseURL
     * @param mapParameters map of parameters
     * @return the url composed
     * @description create an URL
     **/
    public static String composeURL(String baseURL, Map<String,String> mapParameters){
          
        String retUrl = baseURL;
        if(!baseURL.contains('api_key')) {
            retUrl += '?';
        } else {
            retUrl += '&';
        }

        Integer counter = 0;
        for(String param: mapParameters.keySet()){
            retUrl += param;
            retUrl += '=';
            retUrl += mapParameters.get(param);
            counter++;
            if(counter < mapParameters.size()) {
                retUrl +='&';
            } 
        }
        return retUrl;
    }

    
    /**
     * NewRequest.
     *
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @param method http command
     * @param endpointUrl the url
     * @param headerDefinitions elements have as their key the name of 
     * @param body the body
     * @return the request
     * @description create an HTTP Request defined by the parameters in input
     **/
    public static HttpRequest newRequest(String method, String endpointUrl, Map<String,String> headerDefinitions, String body){
        System.debug('REST newRequest > method='+method+', endpointUrl='+endpointUrl+', body='+body);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod(method);
        for(String key :headerDefinitions.keySet()){
            System.debug('Header '+key+'='+headerDefinitions.get(key));
            if(headerDefinitions.get(key) != null) {
                request.setHeader(key, headerDefinitions.get(key));
            }
        }
        if(method != 'GET') {
        	request.setBody(body);
        }
        System.debug('@@@ REQUEST @@@' + request);
        System.debug('@@@ REQUEST HEADER @@@' + request.getHeader('TransactionID'));
        return request;
    }


    /**
     * CreateRequest.
     *
     * @author Riccardo Cossu - riccardo.cossu@nttdata.com
     * @description Create a HTTP Request
     * @param url the url
     * @param requestString the body of the request
     * @return the request
     **/
    public static HttpRequest createRequest(String url, String requestString){
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(url); 
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestString);    
        return request;
    }

    
    /**
     * SendRequest.
     *
     * @author Riccardo Cossu - riccardo.cossu@nttdata.com
     * @param request the request
     * @param callerClassName the caller
     * @param timeout the timeout
     * @return the response
     * @description Send a HTTP Request
     **/
    public static HttpResponse sendRequest(HttpRequest request, String callerClassName, Integer timeout){
        Http http = new Http();     
        HttpResponse response = new HttpResponse();
        try{
            request.setTimeout(timeout);
            response = http.send(request);
        } catch(Exception e){
            System.debug('@@@@ Error in : '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return response;
    }


    /**
     * SendRequest.
     *
     * @author Riccardo Cossu - riccardo.cossu@nttdata.com
     * @param request the request
     * @param callerClassName the caller
     * @return the response
     * @description Send a HTTP Request
     **/
    public static HttpResponse sendRequest(HttpRequest request, String callerClassName){
        return sendRequest(request, callerClassName, 120000);
    }

    /**
     * SendRequestLogging.
     * @ param request the request to send
     * @ param logTransactionID the id of transaction
     * @ param logIntegrationName the name of the integration
     * @ return the response
     * @description Send a HTTP Request saving the log
     ** /
    public static HttpResponse sendRequestLogging(HttpRequest request, String logTransactionID, String logIntegrationName){
        return sendRequestLogging(request, logTransactionID, logIntegrationName); //, 120000
    }*/

    /**
     * SendRequestLogging.
     *
     * @param request the request to send
     * @param logTransactionID the id of transaction
     * @param logIntegrationName the name of the integration
     * @return the response
     * @description Send a HTTP Request saving the log
     **/
    public static HttpResponse sendRequestLogging(HttpRequest request, String logTransactionID, String logIntegrationName){ //, Integer timeout
        //HttpResponseWrapper httpRWr = sendRequestWithOptionLogging(request, true);
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logTransactionID = logTransactionID;
        logWrapper.logIntegrationName = logIntegrationName;
        logWrapper.insertLogging = true;
        HttpResponseWrapper httpRWr = sendRequestWithOptionLogging(request, logWrapper);
        return httpRWr.response;
    }
    
     /**
     * SendRequestLogging.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param request the request to send
     * @param header map key value oh header
     * @param logIntegrationName the name of the integration
     * @return the response
     * @description Send a HTTP Request saving the log
     **/
    public static HttpResponseWrapper sendRequestLoggingNoIntegrationLog(HttpRequest request, Map<String,String> header, String logIntegrationName){
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = logIntegrationName;
        logWrapper.logTransactionID = header.get('TransactionID');
        logWrapper.insertLogging = false;
        HttpResponseWrapper httpRWr = sendRequestWithOptionLogging(request, header, logWrapper);
        return httpRWr;
        
    }
    
    /**
     * SendRequestLogging.
     *
     * @param request the request to send
     * @param logWrapper 
     * @return the response wrapper
     * @description Send a HTTP Request saving the log
     **/
    public static HttpResponseWrapper sendRequestWithOptionLogging(HttpRequest request, XC_UTIL_IntegrationLog.LogWrapper logWrapper){ //String logTransactionID, String logIntegrationName, Integer timeout,
        HttpResponseWrapper result = new HttpResponseWrapper();
        Http http = new Http();
        Integer timeout = 120000;
        System.debug('@@ request In sendRequestLogging ' + request );
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        logWrapper.logEndpoint = request.getEndpoint(); 
        logWrapper.httpMethod = request.getMethod();
        logWrapper.logMessage = (request.getBody().length()>131072) ? request.getBody().substring(0, 131071) : request.getBody();

        try{
            intLog.insertIntegReqOutboundLog(logWrapper); //INIT IntegrationLog (NON fa INSERT)
            request.setTimeout(timeout);
            System.debug('###Request in sendRequestLogging: ' + request);
            System.debug('###Request BODY in sendRequestLogging: ' + request.getBody());
            result.response = http.send(request);
            if(logWrapper.insertLogging){
                responseLogging(intLog, result.response);
            }else{
                result.integrationLog = getResponseLogging(intLog, result.response);
            }
        } catch(Exception e){
            String logError = 'catch_SendRequestLogging ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause();
            System.debug(LoggingLevel.FINEST, logError);
            if(logWrapper.insertLogging){
                responseLoggingError(intLog,logError);
            }else{
                result.integrationLog = getResponseLoggingError(intLog, logError);
            }
        }
        System.debug('###Response in sendRequestLogging: ' + result.response);
        return result;
    }

    /**
     * SendRequestLogging.
     *
     * @author Dario Tramontin dtramontin@deloitte.it
     * @param request the request to send
     * @param header map key value oh header
     * @param logIntegrationName the name of the integration
     * @return the response
     * @description Send a HTTP Request saving the log
     **/
    public static HttpResponse sendRequestLogging(HttpRequest request, Map<String,String> header, String logIntegrationName){
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = logIntegrationName;
        logWrapper.logTransactionID = header.get('TransactionID');
        logWrapper.serverSystem = header.get('ServerSystem'); 
        logWrapper.insertLogging = true;
        HttpResponseWrapper httpRWr = sendRequestWithOptionLogging(request, header, logWrapper);
        return httpRWr.response;
        //return sendRequestLogging(request, header,logIntegrationName, 120000);
    }

    /**
     * SendRequestLogging.
     *
     * @author Dario Tramontin dtramontin@deloitte.it
     * @param request the request to send
     * @param header
     * @param logWrapper 
     * @return the response
     * @description Send a HTTP Request saving the log
     **/
    public static HttpResponseWrapper sendRequestWithOptionLogging(HttpRequest request, Map<String,String> header, XC_UTIL_IntegrationLog.LogWrapper logWrapper){ //String logIntegrationName, Integer timeout
        HttpResponseWrapper result = new HttpResponseWrapper();
        Integer timeout = 120000;
        Http http = new Http();
        System.debug('@@ request In sendRequestLogging mapVersion' + request );
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();  
        logWrapper.logEndpoint = request.getEndpoint(); 
        logWrapper.httpMethod = request.getMethod();
        logWrapper.logMessage = (request.getBody().length()>131072) ? request.getBody().substring(0, 131072) : request.getBody();

        try{
            System.debug('test4: '+request.getBody());
            intLog.setHeader(header);
            System.debug('header' + header);
            intLog.insertIntegReqOutboundLog(logWrapper);       //INIT IntegrationLog (NON fa INSERT)
            request.setTimeout(timeout);
            result.response = http.send(request); 
            System.debug('###Response in sendRequestLogging mapVersion' + result.response);
            System.debug('###Response in sendRequestLogging mapVersion' + result.response.getBody());
            if(logWrapper.insertLogging){
                responseLogging(intLog, result.response);
            }else{
                result.integrationLog = getResponseLogging(intLog, result.response);
            }
        } catch(Exception e){
            String logError = 'catch_SendRequestLogging ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getLineNumber() + ' ' + e.getCause();
            System.debug(LoggingLevel.FINEST, logError);
            if(logWrapper.insertLogging){
                responseLoggingError(intLog, logError);
            }else{
                result.integrationLog = getResponseLoggingError(intLog, logError);
            }
        }
        System.debug('@@@ RESPONSE @@@ ' + result.response);
        return result;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description responseLogging
     * @param intLog
     * @param response the response to log
     **/
    public static void responseLogging(XC_UTIL_IntegrationLog intLog, HttpResponse response){
        if(response != null && String.isNotBlank(response.getBody())) {
            intLog.insertIntegRespOutboundLog((response.getStatusCode()==200?true:false), ((response.getBody().length()>131072)?response.getBody().substring(0, 131072):response.getBody()), String.valueOf(response.getStatusCode()), '');
        } else if(response != null && String.isBlank(response.getBody())) {
            intLog.insertIntegRespOutboundLog((response.getStatusCode()==200?true:false), ('Status = ' + response.getStatus()), String.valueOf(response.getStatusCode()), ('Status = ' + response.getStatus()));
        } else {
            intLog.insertIntegRespOutboundLog(false, 'null', '500', 'Response NULL');
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description responseLogging
     * @param intLog
     * @param logError the error to log
     **/
    public static void responseLoggingError(XC_UTIL_IntegrationLog intLog, String logError){
        intLog.insertIntegRespOutboundLog(false, 'null', '500', ((logError.length()>131072)?logError.substring(0, 131071):logError));
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description responseLogging
     * @param intLog
     * @param response the response to log
     * @return List<XC_Integration_Log__c> the logs not inserted
     **/
    public static List<XC_Integration_Log__c> getResponseLogging(XC_UTIL_IntegrationLog intLog, HttpResponse response){
        if(response != null && String.isNotBlank(response.getBody())) {
            return intLog.getIntegRespOutboundLog((response.getStatusCode()==200?true:false), ((response.getBody().length()>131072)?response.getBody().substring(0, 131072):response.getBody()), String.valueOf(response.getStatusCode()), '');
        } else if(response != null && String.isBlank(response.getBody())) {
            return intLog.getIntegRespOutboundLog((response.getStatusCode()==200?true:false), ('Status = ' + response.getStatus()), String.valueOf(response.getStatusCode()), ('Status = ' + response.getStatus()));
        } else {
            return intLog.getIntegRespOutboundLog(false, 'null', '500', 'Response NULL');
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description responseLogging
     * @param intLog
     * @param logError the error to log
     * @return List<XC_Integration_Log__c> the logs not inserted
     **/
    public static List<XC_Integration_Log__c> getResponseLoggingError(XC_UTIL_IntegrationLog intLog, String logError){
        return intLog.getIntegRespOutboundLog(false, 'null', '500', ((logError.length()>131072)?logError.substring(0, 131071):logError));
    }
 
    /**
     * RetrieveToken.
     *
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Create a HTTP Request
     * @param request the request
     * @return the string
     **/
    public static String retrieveToken(HttpRequest request) {
        System.debug('SendReqLogg');
        String logError = '';
        Http http = new Http();    
        HttpResponse response = new HTTPResponse(); 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();  
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logTransactionID = request.getHeader('TransactionID');
        logWrapper.logIntegrationName = 'AccessToken';
        logWrapper.logEndpoint = request.getEndpoint();
        logWrapper.httpMethod = request.getMethod();
        logWrapper.logMessage = '';
        Map<String, Object> token;

        try{
       		
            response = http.send(request);
            String responseBody = response.getBody();
            /*responseBody.replace('access_token', 'accessToken');
            responseBody.replace('instance_url', 'instanceUrl');
            responseBody.replace('token_type', 'tokenType');
            responseBody.replace('issued_at', 'issuedAt');
            responseBody.replace('error_description', 'errorDescription');*/
            token = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            return String.valueOf(token.get('access_token'));

        } catch(Exception e){
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            System.debug('LOGERROR ' + logError);
        } 
     	
       return '';
    }
     /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Create a HTTP Request
     * @return the token request
    **/
    public static HttpRequest getTokenRequest() {
        HttpRequest request = new HttpRequest(); 
        
        String org = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('@@@@@@@@ ' + org);
        XC_CS002_AccessToken__c accessToken;

        if((String.valueOf(org)).contains(Label.XC_DevOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('DevCredential');
        } else if((String.valueOf(org)).contains(Label.XC_CIOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('CICredential');
        } else if((String.valueOf(org)).contains(Label.XC_UATOrgURL) || (String.valueOf(org)).contains(Label.XC_UATComOrg)) {
            accessToken = XC_CS002_AccessToken__c.getValues('UATCredential');
        } else if((String.valueOf(org)).contains(Label.XC_CL_PRODOrgURL) || (String.valueOf(org)).contains(Label.XC_CL_PRODCommunityOrgURL)) {
            accessToken = XC_CS002_AccessToken__c.getValues('PRODCredential');
        } else if((String.valueOf(org)).contains(Label.XC_DevB2BOrgURL)){
            accessToken = XC_CS002_AccessToken__c.getValues('DevCredentialB2B');            
        } else if((String.valueOf(org)).contains('exdevhub')  || (String.valueOf(org)).contains(Label.XC_DEVHUBComB2BOrg)) {
            accessToken = XC_CS002_AccessToken__c.getValues('DevHubCredential');     
        }
         
        if(accessToken != null){
        request.setEndpoint(accessToken.XC_OrgURL__c + 'services/oauth2/token?grant_type=password' +
                            '&client_id='+ accessToken.XC_ConsumerKey__c +
                            '&client_secret=' + accessToken.XC_ConsumerSecret__c + 
                            '&username=' + accessToken.XC_User__c +
                            '&password=' + accessToken.XC_PasswordAndToken__c); 
        }
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        System.debug('@@@@ ' + request.getEndpoint());
        return request;
    }

    
    /**
     * ReplaceFieldJSON.
     *
     * @author Federico Amici - federico.amici@nttdata.com
     * @param jsonString the json
     * @param fieldWrapper field
     * @param replacement the replacement
     * @return the string with the field replaced
     * @description The method replace the first argument present in JSON with the second
     **/
    public static String replaceFieldJSON(String jsonString, String fieldWrapper, String replacement) {
        String s;
        if(jsonString.contains('"'+fieldWrapper+'":')||
           jsonString.contains('"'+fieldWrapper+'" :')) {
               jsonString = jsonString.replace('"'+ fieldWrapper +'":', '"'+ replacement + '":');
               jsonString = jsonString.replace('"' + fieldWrapper + '" :', '"' + replacement + '":');
               
        }
        s = jsonString;
        return s;

    }

    /**
     * CreateHeaderOutbound.
     *
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @param operation the operation
     * @param functionality the functionality
     * @param serverSystem the serverSystem
     * @return the header map
     * @description method to create the Header of outbound callout
     */
    public static Map<String,String> createHeaderOutbound(String operation, String functionality, String serverSystem) {
        Map<String,String> headerDefinitions = new Map<String,String>();
        
        String m = '4';
        String variants = '89ab';
        Blob b = Crypto.GenerateAESKey(128);
        String x = EncodingUtil.ConvertTohex(b);
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), variants.length());
        String n = variants.substring(idx, idx+1);
        String transactionIDcorrect = x.substring(0,8)+ '-' + x.substring(8,12) + '-' + M + x.substring(13,16) + '-' + N + x.substring(17,20) + '-' + x.substring(20);
        
        headerDefinitions.put('Content-Type', 'application/json;charset=UTF-8');
        headerDefinitions.put('TransactionID', transactionIDcorrect);
        headerDefinitions.put('DateTimeMessage', DateTime.Now().formatGMT('yyyyMMddHHmmssSSS'));
        headerDefinitions.put('Operation', operation);
        headerDefinitions.put('Functionality', functionality);
        headerDefinitions.put('ClientSystem', 'XCustomerB2C');
        headerDefinitions.put('ServerSystem', serverSystem);

        return headerDefinitions;
    }


    /**
    * @description sleep method for retry logics in callout (used for zuora concurrent callouts)
    * @author Francesco Imperioli - fimperioli@deloitte.it | 18/5/2020 
    * @param milliseconds 
    * @return void 
    **/
    public static void sleep(Integer milliseconds){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < milliseconds) {
            //sleep for 2s
            finishTime = DateTime.now().getTime();
        }
    }


    /*public static Map<String,String> retrieveHeader(HttpRequest request){
        Map<String,String> headerDefinitions = new Map<String,String>();
        String[] keyList = request.getHeaderKeys();
        for( String s : keyList){
            headerDefinitions.put(s,request.getHeader(s) );
        }

        return headerDefinitions;
    }*/
    
    


   
}