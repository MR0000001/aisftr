/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 19/07/2019
 * @date Modification 
 * @description XC_LCC005_AccountDataAccordion – Controller for XC_LCP005_AccountDataAccordion Component
 */
public class XC_LCC005_AccountDataAccordion {
	
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');

    /** @description The Class ContinuationCommodityResult */
    public class ContinuationCommodityResult{

        /** @description success */
        @AuraEnabled
        public Boolean success {get; set;}

        /** @description message */
        @AuraEnabled
        public String message {get; set;}

        /** @description sobjectTypeName */
        @AuraEnabled
        public String sobjectTypeName {get; set;}

        /** @description sobjectId */
        @AuraEnabled
        public String sobjectId {get; set;}

        /** @description accountDocCountry */
        @AuraEnabled
        public String accountDocCountry {get; set;}

        /** @description identityNumber */
        @AuraEnabled
        public String identityNumber {get; set;}
        
        /** @description commodityAccountResult */
        @AuraEnabled
        public Object commodityAccountResult {get; set;}

        /** @description commodityContractResult */
        @AuraEnabled
        public Object commodityContractResult {get; set;}

        /** @description commodityCaseResult */
        @AuraEnabled
        public Object commodityCaseResult {get; set;}

        /** @description commodityInvoiceResult */
        @AuraEnabled
        public Object commodityInvoiceResult {get; set;}
        /** @description commodityInvoiceResult */
        @AuraEnabled
        public String accountsResponseJSON {get; set;}
    }

    /**
     * @description call to Commodity getContract
     * @param recordId the record id
     * @return the result wrapper
     * /
    @AuraEnabled(continuation=true cacheable=true)
    public static Object firstCallCommodityContinuation(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALL to firstCallCommodityContinuation');
        Map<String,Object> stateMap = new Map<String,Object>();
        Continuation con = new Continuation(40);
        con.continuationMethod='processFirstCommodityResponse';

        Id idObj = recordId;
        String sobjectTypeName = idObj.getSObjectType().getDescribe().getName();
        String identityNumber = ''; //XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId,sobjectTypeName);
        /*if(identityNumber == null || identityNumber == ''){
            //XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper(false, Label.XC_CL_NoDocForAccountMess);
            stateMap.put('success', false);
            stateMap.put('message', Label.XC_CL_NoDocForAccountMess);
            con.state = JSON.serialize(stateMap);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SET stateMap = '+stateMap);
            // Return it to the system for processing
            return con;
        }* /

        stateMap.put('recordId', recordId);
        stateMap.put('sobjectType', sobjectTypeName);
        stateMap.put('identityNumber', identityNumber);
        // Create a Continuation for the HTTPRequests
        //READ ACCOUNT
        try {
            stateMap.put('isActiveInterface1', true);
            HttpRequest req1 = XC_REST_ReadAccont.initReadAccountRequest(identityNumber);
            String requestLabel1 = con.addHttpRequest(req1);
            stateMap.put('requestLabel1', requestLabel1);
        } catch (XC_UTIL_RESTCallout.NotActiveInterfaceException ex) {
            stateMap.put('isActiveInterface1', false);
        }
        //GET CONTRACT
        try {
            stateMap.put('isActiveInterface2', true);
            HttpRequest req2 = XC_REST_Contract_Outbound.initContractOutboundRequest(identityNumber);
            String requestLabel2 = con.addHttpRequest(req2);
            stateMap.put('requestLabel2', requestLabel2);
        } catch (XC_UTIL_RESTCallout.NotActiveInterfaceException ex) {
            stateMap.put('isActiveInterface2', false);
        }
        
        con.state = JSON.serialize(stateMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SET stateMap = '+stateMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ return con = '+con);
        // Return it to the system for processing
        return con;
    }*/
    
    /**
     * @description processFirstCommodityResponse Callback method
     * @param labels
     * @param state
     * @return the result Object
     * /
    @AuraEnabled(cacheable=true)
    public static Object processFirstCommodityResponse(List<String> labels, Object state) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALLBACK to processFirstCommodityResponse');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ state = '+state);
        Map<String,Object> stateMap = (Map<String,Object>)JSON.deserializeUntyped((String)state);
        ContinuationCommodityResult result = new ContinuationCommodityResult();
        if(String.isBlank((String)stateMap.get('identityNumber'))){
            result.success = false;
            result.message = Label.XC_CL_NoDocForAccountMess;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ processFirstCommodityResponse result='+result);
            return result;
        }
        result.success = true;
        result.sobjectTypeName = (String)stateMap.get('sobjectType');
        result.sobjectId = (String)stateMap.get('recordId');
        result.identityNumber = (String)stateMap.get('identityNumber');

        if((Boolean)stateMap.get('isActiveInterface1')){
            // Get the responses by using unique labels
            String requestLabel1 = (String)stateMap.get('requestLabel1');
            HttpResponse response1 = Continuation.getResponse(requestLabel1);
            XC_LCC005_AccountCallToCommodity.MainResultWrapper accObj = XC_LCC005_AccountCallToCommodity.manageAccountCommodityResponse(response1, result.sobjectId, result.sobjectTypeName);
            result.commodityAccountResult = accObj;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityAccountResult = '+accObj);

        } else {
            result.commodityAccountResult = XC_REST_ReadAccont.setFakeResultForCommodityNew();
        }

        if((Boolean)stateMap.get('isActiveInterface2')){
            // Get the responses by using unique labels
            String requestLabel2 = (String)stateMap.get('requestLabel2');
            HttpResponse response2 = Continuation.getResponse(requestLabel2);
            if(response2!=null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ Contract response Body='+response2.getBody());
                Map<String,Object> wrapperResult = (Map<String,Object>) JSON.deserializeUntyped(response2.getBody());
                if(wrapperResult.get('Contract') != null){
                     Object obj = XC_LCC132_CallToCommodityContract.manageGetContractResponse((List<Object>)wrapperResult.get('Contract'));
                     result.commodityContractResult = obj;
                     XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityContractResult = '+result.commodityContractResult);
                }else{
                    result.commodityContractResult = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
                }
            }
        } else {
            Map<String,Object> callResult = XC_REST_Contract_Outbound.manageResponseFake();
            Object obj =  XC_LCC132_CallToCommodityContract.manageGetContractResponse((List<Object>)callResult.get('Contract'));
            result.commodityContractResult = obj;
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ processFirstCommodityResponse result='+result);
        return result;
    }*/

    /**
     * @description call to Commodity getContract
     * @param recordId the record id
     * @param identityNumber doc identity Number
     * @return the result wrapper
     * /
    @AuraEnabled(continuation=true cacheable=true)
    public static Object secondCallCommodityContinuation(String recordId, String identityNumber){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALL to secondCallCommodityContinuation');
        Id idObj = recordId;
        String sobjectTypeName = idObj.getSObjectType().getDescribe().getName();
        /*String identityNumber = XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId,sobjectTypeName);
        if(identityNumber == ''){
            XC_LCC005_AccountCallToCommodity.ResultWrapper rw = new XC_LCC005_AccountCallToCommodity.ResultWrapper(false, Label.XC_CL_NoDocForAccountMess);
            return rw;
        }* /

        Map<String,Object> stateMap = new Map<String,Object>();
        stateMap.put('recordId', recordId);
        stateMap.put('sobjectType', sobjectTypeName);
        stateMap.put('identityNumber', identityNumber);
        // Create a Continuation for the HTTPRequests
        Continuation con = new Continuation(40);
        con.continuationMethod='processSecondCommodityResponse';
        //READ CASE
        try {
            stateMap.put('isActiveInterface1', true);
            Date endD = Date.today();
            Date startD = endD.addDays(-180);
            Map<String, String> inputParam =new Map<String, String> 
            { 
                'IdentityNumberAccount' => identityNumber,
                'StartDate' => String.valueOf(startD),
                'EndDate' => String.valueOf(endD) 
            };
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ initReadCaseRequest inputParam='+inputParam);
            HttpRequest req1 = XC_REST_Case_Outbound.initReadCaseRequest(inputParam);

            String requestLabel1 = con.addHttpRequest(req1);
            stateMap.put('requestLabel1', requestLabel1);
        } catch (XC_UTIL_RESTCallout.NotActiveInterfaceException ex) {
            stateMap.put('isActiveInterface1', false);
        }
        //READ INVOICE LIST
        try {
            stateMap.put('isActiveInterface2', true);
            HttpRequest req2 = XC_REST_ReadInvoiceList.initReadInvoiceListRequest(new Map<String, String> { 'DocumentationID' => identityNumber});
            String requestLabel2 = con.addHttpRequest(req2);
            stateMap.put('requestLabel2', requestLabel2);
        } catch (XC_UTIL_RESTCallout.NotActiveInterfaceException ex) {
            stateMap.put('isActiveInterface2', false);
        }
        
        con.state = JSON.serialize(stateMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ SET stateMap = '+stateMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ return con = '+con);
        // Return it to the system for processing
        return con;
    }*/
    
    /**
     * @description processFirstCommodityResponse Callback method
     * @param labels
     * @param state
     * @return the result Object
     * /
    @AuraEnabled(cacheable=true)
    public static Object processSecondCommodityResponse(List<String> labels, Object state) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALLBACK to processSecondCommodityResponse - state='+state);
        Map<String,Object> stateMap = (Map<String,Object>)JSON.deserializeUntyped((String)state);
        ContinuationCommodityResult result = new ContinuationCommodityResult();
        result.success = true;
        result.sobjectTypeName = (String)stateMap.get('sobjectType');
        result.sobjectId = (String)stateMap.get('recordId');
        

        if((Boolean)stateMap.get('isActiveInterface1')){
            // Get the responses by using unique labels
            String requestLabel1 = (String)stateMap.get('requestLabel1');
            HttpResponse response1 = Continuation.getResponse(requestLabel1);
            XC_REST_Case_W.WrapperCaseResponseGET caseObj = XC_REST_Case_Outbound.manageResponseGET(response1);
            if(caseObj.CaseList!= null && !caseObj.CaseList.isEmpty()){
                result.commodityCaseResult = XC_LCC132_CallToCommodityContract.manageGetCaseResponse(caseObj.CaseList);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityCaseResult = '+result.commodityCaseResult);
        } else {
            XC_REST_Case_W.WrapperCaseResponseGET caseObj = XC_REST_Case_Outbound.manageFakeResponseGET();
            if(caseObj.CaseList!= null && !caseObj.CaseList.isEmpty()){
                result.commodityCaseResult = XC_LCC132_CallToCommodityContract.manageGetCaseResponse(caseObj.CaseList);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityCaseResult FAKE result= '+result.commodityCaseResult);
        }
        if((Boolean)stateMap.get('isActiveInterface2')){
            // Get the responses by using unique labels
            String requestLabel2 = (String)stateMap.get('requestLabel2');
            HttpResponse response2 = Continuation.getResponse(requestLabel2);
            XC_REST_Invoice_W.ReadInvoiceListResponse invoiceObj = XC_REST_ReadInvoiceList.manageResponse(response2);
            if(invoiceObj.Invoice != null && !invoiceObj.Invoice.isEmpty()){
                result.commodityInvoiceResult = XC_LCC132_CallToCommodityContract.manageInvoiceListResponse(invoiceObj.Invoice);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityInvoiceResult = '+result.commodityInvoiceResult);
        } else {
            XC_REST_Invoice_W.ReadInvoiceListResponse invoiceObj = XC_REST_ReadInvoiceList.manageFakeResponse();
            if(invoiceObj.Invoice != null && !invoiceObj.Invoice.isEmpty()){
                result.commodityInvoiceResult = XC_LCC132_CallToCommodityContract.manageInvoiceListResponse(invoiceObj.Invoice);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ commodityInvoiceResult FAKE result= '+result.commodityInvoiceResult);
        }
        
        return result;
    }*/


    /** ******************************* Methods to handle the callbacks without the continuation ******************************* */

    /**
     * @description callToCommodity
     * @param recordId the input
     * @return the callback result 
     * /
    @AuraEnabled
    public static ContinuationCommodityResult callToCommodity(String recordId){
        ContinuationCommodityResult res = new ContinuationCommodityResult(); 

        String objType = ((Id)recordId).getSObjectType().getDescribe().getName();
        XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData = XC_LCC005_AccountCallToCommodity.retrieveIdentityData(recordId, objType);
        //String identityNumber = identityData.identityNumber; //XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId, objType);
        if(String.isBlank(identityData.identityNumber)){
            res.success = false;
            res.message = 'Cant find the identity number'; //TODO LABEL
            return res;
        }
        XC_LCC005_AccountCallToCommodity.MainResultWrapper accountResult = readAccount(identityData, recordId);
        //res.commodityAccountResult = readAccount(identityNumber, recordId, objType);
        res.accountsResponseJSON = JSON.serialize(accountResult.accountsResponseJSON);
        System.debug('@@@@ res.accountsResponseJSON callToCommodity: ' + res.accountsResponseJSON);
        res.commodityAccountResult = accountResult;
        res.commodityContractResult = readContract(identityData); //.identityNumber, identityData.country
        res.commodityCaseResult = readCase(identityData); //.identityNumber,  identityData.country
        res.commodityInvoiceResult = readInvoice(identityData); //,  identityData.country
        res.accountDocCountry = identityData.country;
        res.success = true;
        
        return res;
    }*/

    /**
     * @description callToCommodity
     * @param recordId the input
     * @param selectedAccount the selected Account
     * @return the callback result 
     */
    @AuraEnabled
    public static ContinuationCommodityResult callToCommodity(String recordId, String selectedAccount){
        ContinuationCommodityResult res = new ContinuationCommodityResult(); 

        String objType = ((Id)recordId).getSObjectType().getDescribe().getName();
        XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData = XC_LCC005_AccountCallToCommodity.retrieveIdentityData(recordId, objType);
        //String identityNumber = identityData.identityNumber; //XC_LCC005_AccountCallToCommodity.retrieveIdentityNumber(recordId, objType);
        if(String.isBlank(identityData.identityNumber)){
            res.success = false;
            res.message = 'Cant find the identity number';
            return res;
        }
        XC_LCC005_AccountCallToCommodity.MainResultWrapper accountResult = readAccount(recordId, selectedAccount); //identityData, //identityNumber 
        //res.commodityAccountResult = readAccount(identityNumber, recordId, objType);
        res.accountsResponseJSON = JSON.serialize(accountResult.accountsResponseJSON);
        System.debug('@@@@ res.accountsResponseJSON callToCommodity: ' + res.accountsResponseJSON);
        res.commodityAccountResult = accountResult;

        List<XC_Integration_Log__c> integrationLogs = new List<XC_Integration_Log__c>();
        XC_LCC005_AccountCallToCommodity.ResultWrapper callCommRes = readContract(identityData, accountResult.addressMap);
        if(callCommRes != null && callCommRes.integrationLog != null){
            integrationLogs.addAll(callCommRes.integrationLog);
        }
        res.commodityContractResult = callCommRes;

        callCommRes = readCase(identityData, accountResult.addressMap);
        if(callCommRes != null && callCommRes.integrationLog != null){
            integrationLogs.addAll(callCommRes.integrationLog);
        }
        res.commodityCaseResult = callCommRes;

        callCommRes = readInvoice(identityData);
        if(callCommRes != null && callCommRes.integrationLog != null){
            integrationLogs.addAll(callCommRes.integrationLog);
        }
        res.commodityInvoiceResult = callCommRes;

        res.accountDocCountry = identityData.country;
        res.success = true;

        List<XC_UTIL_Sobject.WrapperResult> insertInegLogResult = XC_UTIL_Sobject.insertListRecords(integrationLogs);
        
        return res;
    }

    /**
     * @description readAccount
     * @param identityData
     * @param recordId the Account Id
     * @return XC_LCC005_AccountCallToCommodity.MainResultWrapper
     * /
    private static XC_LCC005_AccountCallToCommodity.MainResultWrapper readAccount(XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData, String recordId){ //String identityNumber
        String objType = ((Id)recordId).getSObjectType().getDescribe().getName();
        XC_REST_ReadAccont.WrapperResult callResult = XC_REST_ReadAccont.callToReadAccount(recordId, new Map<String, String> 
            { 'IdentityNumber' => identityData.identityNumber,
              'IdentityType'   => identityData.identityType },
            true
        );
        
        XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LCC005_AccountCallToCommodity manageAccountCommodityResponse > '+commodityResult);

        XC_LCC005_AccountCallToCommodity.MainResultWrapper rw = new XC_LCC005_AccountCallToCommodity.MainResultWrapper();
        if(commodityResult == null || commodityResult.Account == null || commodityResult.Account.isEmpty()){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NoAccountForDoc;
            return rw;
        }
        
        List<XC_LCC005_AccountCallToCommodity.ResultWrapper> accRes = XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(callResult, recordId, objType);     
        rw.success = true;
        rw.accountsResulWrappers = accRes;
        //rw.accountsResponseJSON = new XC_REST_Account_W.WrapperResponseGET();
        rw.accountsResponseJSON = commodityResult;
        System.debug('@@@@ readAccount : ' + rw.accountsResponseJSON);
        return rw;
    }*/

    /**
     * @description readAccount
     * @param recordId the Account Id
     * @param selectedAccount the selected Commodity Account
     * @return XC_LCC005_AccountCallToCommodity.MainResultWrapper
     */
    private static XC_LCC005_AccountCallToCommodity.MainResultWrapper readAccount(String recordId, String selectedAccount){ //XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData, //String identityNumber
        String objType = ((Id)recordId).getSObjectType().getDescribe().getName();
        //XC_REST_ReadAccont.WrapperResult callResult = XC_REST_ReadAccont.callToReadAccount(Label.XC_CL_ReadAccountCommoditySpain, new Map<String, String> { 'IdentityNumber' => identityNumber});
        XC_REST_ReadAccont.WrapperResult callResult = new XC_REST_ReadAccont.WrapperResult();
        callResult.readAccountResponse = new XC_REST_Account_W.WrapperResponseGET();
        callResult.viewDefinitions = XC_UTIL_ViewDefinitionsReadAccount.getReadAccountViewDefinitions();
        selectedAccount = '{"Account": [ ' + selectedAccount + '] }';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LCC005_AccountCallToCommodity selectedAccount > ' + selectedAccount);
        callResult.readAccountResponse = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize(selectedAccount, XC_REST_Account_W.WrapperResponseGET.class );
        XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LCC005_AccountCallToCommodity manageAccountCommodityResponse > '+commodityResult);

        XC_LCC005_AccountCallToCommodity.MainResultWrapper rw = new XC_LCC005_AccountCallToCommodity.MainResultWrapper();
        if(commodityResult == null || commodityResult.Account == null || commodityResult.Account.isEmpty()){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_NoAccountForDoc;
            return rw;
        }
        rw.addressMap = new Map<String,String>();
        if(commodityResult.Account[0].Address != null && !commodityResult.Account[0].Address.isEmpty()){
            for(XC_UTIL_Address.AddressWrapper address : commodityResult.Account[0].Address){
                rw.addressMap.put(address.AddressID, getAddressConcatenationDescription(address)); //address.Address //Fix 1051
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'addressMap > '+rw.addressMap);
        }
        
        
        List<XC_LCC005_AccountCallToCommodity.ResultWrapper> accRes = XC_LCC005_AccountCallToCommodity_Manage.manageCallCommodityMain(callResult, recordId, objType);     
        rw.success = true;
        rw.accountsResulWrappers = accRes;
        rw.accountsResponseJSON = new XC_REST_Account_W.WrapperResponseGET();
        rw.accountsResponseJSON = commodityResult;
        System.debug('@@@@ readAccount : ' + rw.accountsResponseJSON);
        return rw;
    }

    /**
     * @description getAddressConcatenationDescription
     * Address + 
     * es: DIPUTACIO 199 - 08011 BARCELONA BARCELONA
     * @param address
     * @return the address description
     */
    private static String getAddressConcatenationDescription(XC_UTIL_Address.AddressWrapper address){
        String address_desc = address.Address;
        if(String.isNotBlank(address.StreetNumber)){
            address_desc += ' ' + address.StreetNumber;
        }
        if(String.isNotBlank(address.ZipCode)){
            address_desc += ' ' + address.ZipCode;
        }
        if(String.isNotBlank(address.City) || String.isNotBlank(address.Province)){
            address_desc += ' -';
            if(String.isNotBlank(address.City)){
                address_desc += ' ' + address.City;
            }
            if(String.isNotBlank(address.Province)){
                address_desc += ' ' + address.Province;
            }
        }
        return address_desc;
    }

    /**
     * @description readContract
     * @param identityData
     * @return XC_LCC005_AccountCallToCommodity.ResultWrapper 
     */
    private static XC_LCC005_AccountCallToCommodity.ResultWrapper readContract(XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData, Map<String,String> addressMap){ //String identityNumber, String country){
        XC_LCC005_AccountCallToCommodity.ResultWrapper res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        XC_REST_Contract_Outbound.ContractOutboudCallInputData inputWR = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
        inputWR.identityNumber = XC_LCC005_AccountDataAccordion.adaptDocumentNumber(identityData.identityType, identityData.identityNumber);
        inputWR.identityType = identityData.identityType == 'RUT'? '1': identityData.identityType;
        inputWR.pos = '';
        inputWR.country = identityData.country;
        inputWR.insertLoggin = false;
        XC_REST_Contract_Outbound.ContractOutboudCallOutputData outWr = XC_REST_Contract_Outbound.callToGetContract(inputWR);
        Map<String,Object> mapCon = outWr.fieldsData;

        system.debug('conRes: '+mapCon);

        if(mapCon != null && mapCon.get('Contract') != null){
            res = XC_LCC132_CallToCommodityContract.manageGetContractResponse((List<Object>)mapCon.get('Contract'), addressMap); 
            res.integrationLog = outWr.integrationLog;
        } else {
            res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        }

        system.debug('conRes2: '+res);
        return res;
    }    

    /**
     * @description readContract
     * @param identityData
     * @return XC_LCC005_AccountCallToCommodity.ResultWrapper 
     */
    private static XC_LCC005_AccountCallToCommodity.ResultWrapper readCase(XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData , Map<String,String> addressMap ){ //String identityNumber, String country){
        XC_LCC005_AccountCallToCommodity.ResultWrapper res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        identityData.identityNumber = XC_LCC005_AccountDataAccordion.adaptDocumentNumber(identityData.identityType, identityData.identityNumber);
        identityData.identityType = identityData.identityType == 'RUT'? '1': identityData.identityType;
        Map<String, String> inputParam =new Map<String, String> { 
            'IdentityNumberAccount' => identityData.identityNumber, 
            'IdentityType' => identityData.identityType, 
            'StartDate' => String.valueOf(Date.today()),
            'EndDate' => String.valueOf(Date.today().addDays(-180))  
        };

        XC_REST_Case_W.WrapperCaseResponseGET caseObj = XC_REST_Case_Outbound.callToGetCase(inputParam, identityData.country, false);
        if(caseObj.CaseList!= null && !caseObj.CaseList.isEmpty()){
            res = XC_LCC132_CallToCommodityContract.manageGetCaseResponse(caseObj.CaseList, addressMap);
            res.integrationLog = caseObj.integrationLog;
        } else {
            res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        }
        return res;
    }

    /**
     * @description readInvoice
     * @param identityData
     * @return XC_LCC005_AccountCallToCommodity.ResultWrapper
     */
    private static XC_LCC005_AccountCallToCommodity.ResultWrapper readInvoice(XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData){ //XC_LCC005_AccountCallToCommodity.IdentifyDataWrapper identityData, String country){
        XC_LCC005_AccountCallToCommodity.ResultWrapper res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        identityData.identityNumber = XC_LCC005_AccountDataAccordion.adaptDocumentNumber(identityData.identityType, identityData.identityNumber);
        identityData.identityType = identityData.identityType == 'RUT'? '1': identityData.identityType;
        XC_REST_Invoice_W.ReadInvoiceListResponse invoiceObj = XC_REST_ReadInvoiceList.callToReadInvoiceList(new Map<String, String> 
        { 'DocumentationID'   => identityData.identityNumber,
          'DocumentationType' => identityData.identityType }, identityData.country);

        system.debug('invRes: '+invoiceObj);

        if(invoiceObj.RetrieveInvoice != null && invoiceObj.RetrieveInvoice.Invoice != null && !invoiceObj.RetrieveInvoice.Invoice.isEmpty()){
            res = XC_LCC132_CallToCommodityContract.manageInvoiceListResponse(invoiceObj.RetrieveInvoice.Invoice);

        } else {
            res = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        }

        system.debug('invRes2: '+res);

        return res;
    }
    /*
    * @author Andrea Di Cicco
    * @date 30/03/2020
    * @description method used to adapt the document number for external system
    * @param documentType the type of the document
    * @param documentNumber the document number
    * @return the changed document number
    */
    public static String adaptDocumentNumber(String documentType, String documentNumber){

        if(documentType == 'NIT' && documentNumber.length() == 10){
            documentNumber = documentNumber.left(9) +  '-' + documentNumber.right(1);
        }

        return documentNumber;
    }
}