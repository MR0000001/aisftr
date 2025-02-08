/**
 * The Class XC_REST_ReadAccont.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation 04/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_REST_ReadAccont – Manage GET Rest Call ReadAccount Outbound
 */


public class XC_REST_ReadAccont {
    
    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ReadAccont');

    /**
     * @description The Class WrapperResult.
     */
    public class WrapperResult { 
        
        /** The Success. */
        public Boolean success = true;
        
        /** The Message. */
        public String message;

        /** The read Account Response. */
        public XC_REST_Account_W.WrapperResponseGET readAccountResponse;
        
        /** The hr response. */
        public XC_REST_ReadAccont_U.WrapperResponseHR hrResponse;
        
        /** The commodity spain response. */
        public XC_REST_ReadAccont_U.WrapperResponseCommoditySpain commoditySpainResponse;
        
        /** The cloudera response. */
        public String clouderaResponse;
        
        /** The all response labels. */
        public Map<String,Map<String,String>> allResponseLabels = new Map<String,Map<String,String>>();
        
        /** The all view definitions info. */
        public Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewDefinitions = new Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition>();
    
        /** The ServerSystem called */
        public String serverSystem;

        /** @description XC_UTIL_IntegrationLog to insert **/
        public List<XC_Integration_Log__c> integrationLog;
    }

    /**
	* @description init the Commodity ReadAccount Request
	* @param identityNumber Doc Id Number
	* @return the HttpRequest
	*/
	public static HttpRequest initReadAccountRequest(String identityNumber){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ initReadAccountRequest - identityNumber--->'+identityNumber);
        Map<String, String> paramsMap = new Map<String, String>();
        paramsMap.put('IdentityNumber', identityNumber);
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ReadAccountCommoditySpain);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String endpointUrl = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramsMap);
            String method = 'GET';
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'ReadAccount', 'CommoditySpainB2C');
            //headerDefinitions.put('Host', 'api-qual-local.enelx.com');   
            //headerDefinitions.put('Connection', 'keep-alive');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, endpointUrl, headerDefinitions, '');
			XC_UTIL_Debug.debug(DEBUGACTIVE, '[ReadAccount] request -> ' + request);
			return request;
        }

		throw new XC_UTIL_RESTCallout.NotActiveInterfaceException();
    }

    /**
     * Call to read account.
     *
     * @param interfaceName the interface name
     * @param paramsMap the parameters map
     * @param accountId
     * @return the wrapper result
     * @description Central method to do a GET ReadAccont call outbound
     */
    public static WrapperResult callToReadAccount(String interfaceName, Map<String, String> paramsMap, String accountId){
        return new WrapperResult();
    }

        /**
         * Call to read account.
         * @param recordId account/lead Id
         * @param paramsMap the parameters map
         * @param insertLoggin true to insert log, false otherwise
         * @return the wrapper result
         * @description Central method to do a GET ReadAccont call outbound
         */
        public static WrapperResult callToReadAccount(Id recordId, Map<String, String> paramsMap, Boolean insertLoggin){
        String interfaceName = Label.XC_CL_ReadAccountCommoditySpain;
        WrapperResult result = new WrapperResult();
        String documentCountry = getDocumentCountry(recordId);

        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface(interfaceName, documentCountry);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String endpointUrl = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramsMap);
            String method = 'GET';
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('ReadAccount', 'Read', wrapper.serverSystem);
            //headerDefinitions.put('Host', 'api-qual-local.enelx.com');   
            //headerDefinitions.put('Connection', 'keep-alive');
			
            system.debug('header** '+headerDefinitions);
            
            HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, endpointUrl, headerDefinitions, '');
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), interfaceName);
            XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
			logWrapper.logIntegrationName = 'ReadAccount';
			logWrapper.logTransactionID = headerDefinitions.get('TransactionID');
            logWrapper.insertLogging = insertLoggin; 
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWR = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, interfaceName);
            
            result = manageResponse(responseWR.response);
            result.integrationLog = responseWR.integrationLog;
        } else {
            result = setFakeResultForCommodityNew();
            /*if(Label.XC_CL_ReadAccountCommoditySpain == interfaceName){
                result = setFakeResultForCommodityNew();
            }else{
                result = setWrapperFakeResult();
            }*/
		}

        result.serverSystem = wrapper.serverSystem; //Anomalia 2400 [MC - 27/02/2020]
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont RESULT--->'+result);
        return result;
    }

    /**
     * @param recordId the parameters map
     * @return document country value
     * @description getDocumentCountry from record id
     */
    private static String getDocumentCountry(Id recordId){
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        if('Account' == sobjectType && Schema.sObjectType.Account.isAccessible()){
            List<Account> storedAccount = [ SELECT XC_DocumentCountry__c
                             FROM Account 
                             WHERE Id = : recordId];
            if(!storedAccount.isEmpty()){
                return storedAccount[0].XC_DocumentCountry__c;
            }
        }
        else if('Lead' == sobjectType && Schema.sObjectType.Lead.isAccessible()){
            List<Lead> storedLead = [ SELECT XC_DocumentCountry__c
                             FROM Lead 
                             WHERE Id = : recordId];
            if(!storedLead.isEmpty()){
                return storedLead[0].XC_DocumentCountry__c;
            }
        } return '';
    }

    /**
     * Call to read account.
     *
     * @param operation the operationd definition 
     * @param paramsMap the parameters map
     * @return the wrapper result
     * @description method to do a GET ReadAccont to retrieve EnrichedData, Scoring or PropensityToBuy infos from Cloudera
     */
    public static WrapperResult callToReadAccountCloudera(String operation, Map<String, String> paramsMap){
        
        WrapperResult result = new WrapperResult();
        
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ReadAccountCloudera);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String endpointUrl = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramsMap);
            String method = 'GET';
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound(operation, 'ReadCloudera', 'ClouderaB2C');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, endpointUrl, headerDefinitions, '');
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'ReadCloudera');

            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ReadCloudera');
            result = manageResponse(response);
        } else {
            // Fake result
            result.success = true;
            result.readAccountResponse = new XC_REST_Account_W.WrapperResponseGET();
            result.readAccountResponse.Account = new List<XC_UTIL_Account.AccountIFWrapper>();
            XC_UTIL_Account.AccountIFWrapper accWrapper = new XC_UTIL_Account.AccountIFWrapper();
            accWrapper.Scoring = new XC_UTIL_Account.ScoringWrapper();
            accWrapper.Scoring.DataLakeScoring = 54.9;

            result.readAccountResponse.Account.add(accWrapper);
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont RESULT--->'+result);
        return result;
    }


    /**
     * @description Manage response.
     *
     * @param response the response
     * @return the wrapper result
     */
    @TestVisible
    public static WrapperResult manageResponse(HttpResponse response){
        WrapperResult result = new WrapperResult();

        if(response == null) {
            result.success = false;
            result.message = 'Response NULL';
            return result;
        }

        System.debug('[ReadAccount] response Body -> ' + response.getBody());
        if(response.getStatusCode() == 200) {
            String jsonBodyResponse = response.getBody();
            jsonBodyResponse = jsonBodyResponse.replace('""', 'null');
            System.debug('jsonBodyResponse: ' + jsonBodyResponse);
            XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize(jsonBodyResponse, XC_REST_Account_W.WrapperResponseGET.class);
            result.success = true;
            result.message = response.getStatus();
            result.readAccountResponse = wrResp;
            //result.allResponseLabels = getCommodityLabels();
            result.viewDefinitions = XC_UTIL_ViewDefinitionsReadAccount.getReadAccountViewDefinitions();
            return result; 
        } else {
            result.success = false;
            result.message = response.getStatus();
            return result;
        }
    }


    /**
     * Call to get read accont.
     *
     * @param interfaceName the interface name
     * @param wrAccount the wr account
     * @param wrAddress the wr address
     * @return the wrapper result
     * @description Central method to do a GET ReadAccont call outbound
     * @parameter interfaceName name to identify the Provider of the service
     */
    /*public static WrapperResult callToGetReadAccont(String interfaceName, XC_REST_ReadAccont_U.WrapperAccount wrAccount, XC_REST_ReadAccont_U.WrapperAddress wrAddress){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont interfaceName--->'+interfaceName);
        WrapperResult result = new WrapperResult();
        result = inputValidations(interfaceName, wrAccount, wrAddress);
        if(!result.success){
            return result;
        }
        
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(interfaceName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String method = 'GET';
            String endpointUrl = setEndpointUrl(prefixUrl, wrAccount, wrAddress);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('ReadWorkOrder', 'Read', 'CommoditySpainB2C');
            
            headerDefinitions.remove('TransactionID');
            headerDefinitions.put('transactionid', 'test');
            headerDefinitions.put('Host', 'api-qual-local.enelx.com');   
            headerDefinitions.put('datetimemessage', '20181207103900000'); 
            headerDefinitions.put('Connection', 'keep-alive');
            HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, endpointUrl, headerDefinitions, '');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), interfaceName);
            result = manageResponse(interfaceName, response);
        } else {
            if(Label.XC_CL_ReadAccountCommoditySpain == interfaceName){
                result = setFakeResultForCommodityNew();
            }else{
                result = setWrapperFakeResult();
            }
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont RESULT--->'+result);
        return result;
    }*/

	/**
	 * @description Sets the endpoint url.
	 *
	 * @param prefixUrl the prefix url
	 * @param wrAccount the wr account
	 * @param wrAddress the wr address
	 * @return the string
	 */
	/*@TestVisible
    private static String setEndpointUrl (String prefixUrl, XC_REST_ReadAccont_U.WrapperAccount wrAccount, XC_REST_ReadAccont_U.WrapperAddress wrAddress){
        Map<String,String> mapParam = new Map<String,String>();

        mapParam.put('UniqueID', wrAccount.UniqueID);   
        mapParam.put('AccountID', wrAccount.AccountID);
        mapParam.put('PrimaryEmail', wrAccount.PrimaryEmail);
        mapParam.put('IdentityNumber', wrAccount.IdentityNumber);
        mapParam.put('EmployeeID', wrAccount.EmployeeID);

        //Address
        if(wrAddress != null){
            mapParam.put('CUPS', wrAddress.CUPS);
            mapParam.put('StreetType', wrAddress.StreetType);
            mapParam.put('Address', wrAddress.Address);
            mapParam.put('StreetNumber', wrAddress.StreetNumber);
            mapParam.put('Appartment', wrAddress.Appartment);
            mapParam.put('Door', wrAddress.Door);
            mapParam.put('Stair', wrAddress.Stair);
            mapParam.put('ZipCode', wrAddress.ZipCode);

            List<Map<String,String>> pointOfServices = new List<Map<String,String>>();

            if(wrAddress.PointOfService != null){
                for(XC_REST_ReadAccont_U.WrapperPOS wrp : wrAddress.PointOfService){
                    Map<String,String> pos = new Map<String,String>();
                    pos.put('POS', wrp.POS);
                    pos.put('POSType', wrp.POSType);
                    pointOfServices.add(pos);
                }

                mapParam.put('PointOfService', json.serialize(pointOfServices));
            }

        }

        for (String str : mapParam.keySet()){
            if (mapParam.get(str) == null){
                mapParam.remove(str);
            }
        }
        
        return XC_UTIL_RESTCallout.composeURL(prefixUrl,mapParam);
    }*/

    /**
     * @description Manage response.
     *
     * @param interfaceName the interface name
     * @param response the response
     * @return the wrapper result
     */
    /*@TestVisible
    private static WrapperResult manageResponse(String interfaceName, HttpResponse response){
		WrapperResult result = new WrapperResult();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ReadAccont > interfaceName= '+interfaceName+' - response='+response.getBody());

        if(Label.XC_CL_ReadAccountHR == interfaceName){
            return manageHRResponse(response); 
        } else if(Label.XC_CL_ReadAccountCommoditySpain == interfaceName){
            return manageCommoditySpainResponse(response);
        } else if(Label.XC_CL_ReadAccountCloudera == interfaceName){
            return manageClouderaResponse(response);
        }
		return result;
	}*/

	/**
	 * @description Manage HR response.
	 *
	 * @param response the response
	 * @return the wrapper result
	 */
	/*@TestVisible
    private static WrapperResult manageHRResponse(HttpResponse response){
        WrapperResult result = new WrapperResult();
        String normalizedBodyResponse = normalizeHRBodyResponse(response.getBody());
        XC_REST_ReadAccont_U.WrapperResponseHR wrResp = (XC_REST_ReadAccont_U.WrapperResponseHR) JSON.deserialize(normalizedBodyResponse, XC_REST_ReadAccont_U.WrapperResponseHR.class);
        
        if(response.getStatusCode()==200) {
            result.success = true;
            result.hrResponse =  wrResp;
            result.message =  wrResp.message;
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ERROR on callToGetReadAccont HR! -> StatusCode: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            result.success = false;
            if(wrResp != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ERROR on callToGetReadAccont! -> Wrapper Response message= ' + wrResp.message);
                result.message =  wrResp.message;
            }
        }
		return result;
    }*/
	
    /**
     *@description  Normalize HR body response.
     *
     * @param bodyResponse the body response
     * @return the string
     */
    /*private static String normalizeHRBodyResponse(String bodyResponse){
        return bodyResponse.replace('user-profiles', 'userProfiles');
    }*/

	/**
	 *@description  Sets the wrapper fake result.
	 *
	 * @return the wrapper result
	 */
	@TestVisible
    private static WrapperResult setWrapperFakeResult(){
        WrapperResult result = new WrapperResult();
        result.success = true;
        result.message = 'OK';
        return result;
    }

	/**
	 *  @description Manage commodity spain response.
	 *
	 * @param response the response
	 * @return the wrapper result
	 */
	/*@TestVisible
    private static WrapperResult manageCommoditySpainResponse(HttpResponse response){
        WrapperResult result = new WrapperResult();
        String normalizedBodyResponse = normalizeCommoditySpainBodyResponse(response.getBody());

        normalizedBodyResponse = normalizedBodyResponse.replace('Class', 'Class_x');
        XC_REST_ReadAccont_U.WrapperResponseCommoditySpain wrResp = (XC_REST_ReadAccont_U.WrapperResponseCommoditySpain) JSON.deserialize(normalizedBodyResponse, XC_REST_ReadAccont_U.WrapperResponseCommoditySpain.class);
        System.debug('@@@@@@ manageCommoditySpainResponse = '+wrResp);
        if(response.getStatusCode()==200) {
            result.success = true;
            result.commoditySpainResponse =  wrResp;
            result.allResponseLabels = getCommodityLabels();
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ERROR on callToGetReadAccont CommoditySpain! -> StatusCode: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            result.success = false;
        }
		return result;
    }*/

    /**
     *@description  Sets the fake result for commodity new.
     *
     * @return the wrapper result
     */
    public static WrapperResult setFakeResultForCommodityNew(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'setFakeResultForCommodityNew...');
        String commodityFakeResp = getCommodityFakeAccountResponse();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'commodityFakeResp=' + commodityFakeResp);
        //XC_REST_ReadAccont_U.WrapperResponseCommoditySpain wrResp = (XC_REST_ReadAccont_U.WrapperResponseCommoditySpain) JSON.deserialize(commodityFakeResp, XC_REST_ReadAccont_U.WrapperResponseCommoditySpain.class);
        XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize(commodityFakeResp, XC_REST_Account_W.WrapperResponseGET.class);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@#@#@# wrResp.Account = '+ wrResp.Account);

        WrapperResult result = new WrapperResult();
        result.success = true;
        result.message = 'OK';
        //result.commoditySpainResponse = wrResp;
        result.readAccountResponse = wrResp;
        //result.allResponseLabels = getCommodityLabels();
        result.viewDefinitions = XC_UTIL_ViewDefinitionsReadAccount.getReadAccountViewDefinitions();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@#@#@# result setFakeResultForCommodityNew = '+ result);
        return result;
    }

    /**
     * @description Normalize commodity spain body response.
     *
     * @param bodyResponse the body response
     * @return the string
     */
    /*private static String normalizeCommoditySpainBodyResponse(String bodyResponse){
        return bodyResponse.replace('Address/PointOfDelivery', 'Address_PointOfDelivery');
    }*/

	/**
	 * @description Manage cloudera response.
	 *
	 * @param response the response
	 * @return the wrapper result
	 */
	/*@TestVisible
    private static WrapperResult manageClouderaResponse(HttpResponse response){
        WrapperResult result = new WrapperResult();
        Map<String, Object> objResp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        if(response.getStatusCode()==200) { 
            result.success = true;
            result.clouderaResponse =  (String)objResp.get('EnrichedData');
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ ERROR on callToGetReadAccont Cloudera Data Lake! -> StatusCode: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            result.success = false;
        }
		return result;
    }*/
    
    /**
     * @description Input validations.
     *
     * @param interfaceName the interface name
     * @param wrAccount the wr account
     * @param wrAddress the wr address
     * @return the x C RES T read accont. wrapper result
     */
    /*public static XC_REST_ReadAccont.WrapperResult inputValidations(String interfaceName, XC_REST_ReadAccont_U.WrapperAccount wrAccount, XC_REST_ReadAccont_U.WrapperAddress wrAddress){
        XC_REST_ReadAccont.WrapperResult result = new XC_REST_ReadAccont.WrapperResult();
        result = accountValidation(interfaceName, wrAccount);
        
        return result;
    }*/

    /**
     * @description Account validation.
     *
     * @param interfaceName the interface name
     * @param wrAccount the wr account
     * @return the x C RES T read accont. wrapper result
     */
    /*private static XC_REST_ReadAccont.WrapperResult accountValidation(String interfaceName, XC_REST_ReadAccont_U.WrapperAccount wrAccount){
        XC_REST_ReadAccont.WrapperResult result = new XC_REST_ReadAccont.WrapperResult();

        if(wrAccount == null){
            result.success = false;
            result.message = Label.XC_CL_ReadAccont_AccountNotSpecified;
            return result;
        }
        
        if(Label.XC_CL_ReadAccountHR == interfaceName){
            if(wrAccount.EmployeeID == null){
                result.success = false;
                result.message = Label.XC_CL_ReadAccont_EmployeeIDNotSpecified;
                return result;
            }
        } else if(Label.XC_CL_ReadAccountCommoditySpain == interfaceName){
            if(wrAccount.IdentityNumber == null){
                result.success = false;
                result.message = Label.XC_CL_ReadAccont_IdentityNumberNotSpecified;
                return result;
            }
        } else {
            if(wrAccount.AccountID == null && wrAccount.PrimaryEmail == null && wrAccount.IdentityNumber == null){
                result.success = false;
                result.message = Label.XC_CL_ReadAccont_AccountNotSpecified;
                return result;
            }
        }
        
        return result;
    }*/

    /**
     * @description Gets the commodity fake response.
     * @return the commodity fakeresponse
     */
    /*@TestVisible
    private static String getFakeCommodityResponse(){
        String account = getCommodityFakeAccountResponse();
        account = account.removeStart('{');
        account = account.removeEnd('}');
        String fakeResult = '{'+
                            '"Result": {'+
                            '   "Message": "test"'+
                            '  }, '+
                            account+
                            ' }';
        return fakeResult;
    }*/

    /**
     * @description Gets the commodity fake Account response.
     * @return the commodity fakeresponse
     */
    @TestVisible
    private static String getCommodityFakeAccountResponse(){
        return '{																				'+
'   "Account":[                                                                 '+
'      {                                                                        '+
'         "AccountType":"Residential",                                          '+
'         "LastName":"Lopez Domínguez",                                         '+
'         "FirstName":"Pablo",                                                  '+
'         "Status":"Active",                                                    '+
'         "AccountStaus":"Active",                                              '+
'         "Country":"España",                                                   '+
'         "MainPhonePrefix":"+34",                                               '+
'         "PhonePrefix":"+34",                                                   '+
'         "MainPhone":"623477603",                                              '+
'         "Phone":"926577500",                                                  '+
'         "PrimaryEmail":"pablo.lopez2@gmail.com",                              '+
'         "CertifiedEmail":"pablo.lopez2@gmail.com",                            '+
'         "PreferenceLanguage":"Español",                                       '+
'         "ContactMethod":"",                                                   '+
'         "VulnerableCustomer":"",                                              '+
'         "ValueSegment":"",                                                    '+
'         "QualityIndex":"",                                                    '+
'         "Contact":[                                                           '+
'            {                                                                  '+
'               "LastName":"Lucio Sanchez",                                     '+
'               "FirstName":"Santos",                                           '+
'               "IdentityType":"NIF",                                           '+
'               "IdentityNumber":"7742983X",                                    '+
'               "Phone":"623477603",                                            '+
'               "MobilePhone":"926577500",                                      '+
'               "MobilePhonePrefix":"+34",                                       '+
'               "PhonePrefix":"+34",                                             '+
'               "PrimaryEmail":"santos.lucio@gmail.com",                        '+
'               "PreferenceLanguage":"Español",                                 '+
'               "Role":"Coach",                                                 '+
'               "GDPR":{                                                        '+
'                  "GiveDataToThirdParties":"Y",                                '+
'                  "LegalEntity":[                                              '+
'                     {                                                         '+
'                        "LegalEntity":"EndesaX",                               '+
'                        "GiveDataToLegalEntity":"Y",                           '+
'                        "GiveDataForMarketing":"N",                            '+
'                        "GiveDataForProfiling":"Y"                             '+
'                     }                                                         '+
'                  ]                                                            '+
'               }                                                               '+
'            },                                                                 '+
'            {                                                                  '+
'               "LastName":"Sebastian Villagra",                                '+
'               "FirstName":"Marcos",                                           '+
'               "IdentityType":"NIF",                                           '+
'               "IdentityNumber":"43661258M",                                   '+
'               "Phone":"663770044",                                            '+
'               "MobilePhone":"987883377",                                      '+
'               "PrimaryEmail":"marcos.vi@test.com",                             '+
'               "PreferenceLanguage":"Español",                                 '+
'               "MobilePhonePrefix":"+34",                                       '+
'               "PhonePrefix":"+34",                                             '+
'               "Role":""                                                       '+
'            }                                                                  '+
'         ],                                                                    '+
'         "BillingProfile":[                                                    '+
'            {                                                                  '+
'               "PaymentMethod":"Direct Debit",                                 '+
'               "IBAN":"ES 91 2100 0418 4502 0005 1332",                        '+
'               "CommodityContractNum":"86154244451",                           '+
'               "Country":"Spain"                                               '+
'            }                                                                  '+
'         ],                                                                    '+
'         "Address":[                                                           '+
'            {                                                                  '+
'               "AddressType":"",                                               '+
'               "AddressID":"ESP-FAKE-001",                                     '+
'               "Country":"España",                                             '+
'               "Category":"Domicilio Principal",                               '+
'               "Address":"Fereluz",                                            '+
'               "StreetType":"Calle",                                           '+
'               "Street":"Giolitti",                                            '+
'               "StreetNumber":"12",                                            '+
'               "Floor":"2",                                                    '+
'               "Stair":"1",                                                    '+
'               "Door":"B",                                                     '+
'               "ZipCode":"80100",                                              '+
'               "Province":"Madrid",                                            '+
'               "MunicipalName":"Madrid",                                       '+
'               "City":"Madrid",                                                '+
'               "PointOfService":[                                              '+
'                  {                                                            '+
'                     "POS":"ES4126119685457838CY",                             '+
'                     "POSID":"ESY",                                            '+
'                     "POSType":"Light"                                         '+
'                  }                                                            '+
'               ]                                                               '+
'            },                                                                 '+
'            {                                                                  '+
'               "AddressType":"Segunda Residencia",                             '+
'               "AddressID":"ESP-FAKE-002",                                     '+
'               "Country":"Spain",                                              '+
'               "Category":"Segunda Residencia",                                '+
'               "Address":"Port De Casablanca",                                 '+
'               "StreetType":"Calle",                                           '+
'               "StreetNumber":"11",                                            '+
'               "Floor":"5",                                                    '+
'               "Stair":"",                                                     '+
'               "Door":"D",                                                     '+
'               "ZipCode":"08039",                                              '+
'               "MunicipalName":"Barcelona",                                    '+
'               "Province":"Barcelona",                                         '+
'               "City":"Barcellona",                                            '+
'               "PointOfService":[                                              '+
'                  {                                                            '+
'                     "POS":"ES0186079796715968ZN",                             '+
'                     "POSID":"ES0186079796715968ZN",                           '+
'                     "POSType":"Gas"                                           '+
'                  },                                                           '+
'                  {                                                            '+
'                     "POS":"ES0013816078876368WM",                             '+
'                     "POSID":"ES0013816078876368WM",                           '+
'                     "POSType":"Light"                                         '+
'                  }                                                            '+
'               ]                                                               '+
'            }                                                                  '+
'         ]                                                                     '+
'      },                                                                       '+
'      {                                                                        '+
'         "AccountType":"Residential",                                          '+
'         "LastName":"Solinas",                                                 '+
'         "FirstName":"Mario",                                                  '+
'         "AccountStaus":"Active",                                              '+
'         "MainPhonePrefix":"+34",                                               '+
'         "PhonePrefix":"+34",                                                   '+
'         "MainPhone":"987485754",                                                '+
'         "Phone":"987384756",                                                  '+
'         "PrimaryEmail":"MarioSolinas@gmail.com",                              '+
'         "PreferenceLanguage":"EN",                                            '+
'         "ContactMethod":"",                                                   '+
'         "VulnerableCustomer":"",                                              '+
'         "ValueSegment":"",                                                    '+
'         "QualityIndex":"",                                                    '+
'         "Contact":[                                                           '+
'            {                                                                  '+
'               "LastName":"Lucio Sanchez",                                     '+
'               "FirstName":"Santos",                                           '+
'               "IdentityType":"NIF",                                           '+
'               "IdentityNumber":"7742983X",                                    '+
'               "Phone":"623477603",                                            '+
'               "MobilePhone":"926577500",                                      '+
'               "MobilePhonePrefix":"+34",                                       '+
'               "PhonePrefix":"+34",                                             '+
'               "PrimaryEmail":"santos.lucio@gmail.com",                        '+
'               "PreferenceLanguage":"Español",                                 '+
'               "Role":"Coach",                                                 '+
'               "GDPR":{                                                        '+
'                  "GiveDataToThirdParties":"Y",                                '+
'                  "LegalEntity":[                                              '+
'                     {                                                         '+
'                        "LegalEntity":"EndesaX",                               '+
'                        "GiveDataToLegalEntity":"Y",                           '+
'                        "GiveDataForMarketing":"N",                            '+
'                        "GiveDataForProfiling":"Y"                             '+
'                     } ,                                           '+
'                     {                                                         '+
'                        "LegalEntity":"eMobilityUK",                               '+
'                        "GiveDataToLegalEntity":"Y",                           '+
'                        "GiveDataForMarketing":"N",                            '+
'                        "GiveDataForProfiling":"N"                             '+
'                     }                                                         '+
'                  ]                                                            '+
'               }                                                               '+
'            },                                                                 '+
'            {                                                                  '+
'               "LastName":"Sebastian Villagra",                                '+
'               "FirstName":"Marcos",                                           '+
'               "IdentityType":"NIF",                                           '+
'               "IdentityNumber":"43661158M",                                   '+
'               "Phone":"663770044",                                            '+
'               "MobilePhone":"987883377",                                      '+
'               "PrimaryEmail":"marcos.vi@test.com",                             '+
'               "PreferenceLanguage":"Español",                                 '+
'               "MobilePhonePrefix":"+34",                                       '+
'               "PhonePrefix":"+34",                                             '+
'               "Role":""                                                       '+
'            }                                                                  '+
'         ],                                                                    '+
'         "BillingProfile":[                                                    '+
'            {                                                                  '+
'               "PaymentMethod":"Direct Debit",                                 '+
'               "IBAN":"ES 91 2100 0418 4502 0005 1332",                        '+
'               "CommodityContractNum":"86154244451",                           '+
'               "Country":"Spain"                                               '+
'            }                                                                  '+
'         ],                                                                    '+
'         "Address":[                                                           '+
'            {                                                                  '+
'               "AddressType":"",                                               '+
'               "AddressID":"ESP-FAKE-003",                                     '+
'               "Country":"España",                                             '+
'               "Category":"Domicilio Principal",                               '+
'               "Address":"Fereluz",                                            '+
'               "StreetType":"Calle",                                           '+
'               "Street":"Giolitti",                                            '+
'               "StreetNumber":"12",                                            '+
'               "Floor":"2",                                                    '+
'               "Stair":"1",                                                    '+
'               "Door":"B",                                                     '+
'               "ZipCode":"80100",                                              '+
'               "Province":"Madrid",                                            '+
'               "MunicipalName":"Madrid",                                       '+
'               "City":"Madrid",                                                '+
'               "PointOfService":[                                              '+
'                  {                                                            '+
'                     "POS":"ES4126119685457838CY",                             '+
'                     "POSID":"ESY",                                            '+
'                     "POSType":"Light"                                         '+
'                  }                                                            '+
'               ]                                                               '+
'            },                                                                 '+
'            {                                                                  '+
'               "AddressType":"Segunda Residencia",                             '+
'               "Country":"Spain",                                              '+
'               "Category":"Segunda Residencia",                                '+
'               "Address":"Port De Casablanca",                                 '+
'               "StreetType":"Calle",                                           '+
'               "StreetNumber":"11",                                            '+
'               "Floor":"5",                                                    '+
'               "Stair":"",                                                     '+
'               "Door":"D",                                                     '+
'               "ZipCode":"08039",                                              '+
'               "MunicipalName":"Barcelona",                                    '+
'               "Province":"Barcelona",                                         '+
'               "City":"Barcellona",                                            '+
'               "PointOfService":[                                              '+
'                  {                                                            '+
'                     "POS":"ES0186079796715968ZN",                             '+
'                     "POSID":"ES0186079796715968ZN",                           '+
'                     "POSType":"Gas"                                           '+
'                  },                                                           '+
'                  {                                                            '+
'                     "POS":"ES0013816078876368WM",                             '+
'                     "POSID":"ES0013816078876368WM",                           '+
'                     "POSType":"Light"                                         '+
'                  }                                                            '+
'               ]                                                               '+
'            }                                                                  '+
'         ]                                                                     '+
'      }                                                                        '+
'   ]                                                                           '+
'}                                                                              ';
    }

}