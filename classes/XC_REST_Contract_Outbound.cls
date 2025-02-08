/*****************************************************************************************************************
* @author :          : Federico Amici - federico.amici@nttdata.com
* @date Creation 	 : 20/02/2019
* @date Modification : 12/06/2019 by Simone Trenta - strenta@deloitte.it
* @description :     : XC_REST_Contract_Outbound – Rest Resource that deals with the outbound REST for 
													the Contract object
******************************************************************************************************************/

public class XC_REST_Contract_Outbound {

	/* @description the call input wrapper */
	public class ContractOutboudCallInputData{
		/** @description identityNumber **/
        public String identityNumber;
		/** @description pos **/
        public String pos;
		/** @description country **/
        public String country;
		/** @description insertLoggin to insert **/
		public Boolean insertLoggin;
		/** @description insertLoggin to insert **/
		public String identityType;

		//11-02-2022 Add segment to wrapper to distinguish between B2C and B2B Commodity integrations - alag@deloitte.es
		public String segment;
	}

	/* @description the call output wrapper */
	public class ContractOutboudCallOutputData{
		/** @description fieldsData map **/ 
        public Map<String,Object> fieldsData;
        /** @description XC_UTIL_IntegrationLog to insert **/
        public List<XC_Integration_Log__c> integrationLog;
	}

	/**
	* @description callToGetContract 
	* @param identityNumber the identityNumber 
	* @param pos the POS
	* @return the response wrapper
	*/
	public static Map<String,Object> callToGetContract(String identityNumber, String pos) {
		System.debug('in callToGetContract con doc = '+identityNumber+ ' e '+pos);
		Map<String,Object> result = new Map<String,Object>();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ContractOutbound);
        if(isActiveInterface.activeInterface){

			String prefixUrl = isActiveInterface.url; 
            Map<String,String> paramMap = new Map<String,String>();

			if(String.isNotBlank(identityNumber)){
				paramMap.put('IdentityNumber',identityNumber);
			}

			if(String.isNotBlank(pos)){
				paramMap.put('POS',pos);
			}

			String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap); 	
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getContract', 'CommoditySpainB2C');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
			System.debug('[ContractOutbound] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'ContractOutbound');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ContractOutbound');

			System.debug('[ContractOutbound] response -> ' + response);

            /********************* Parse response ********************************************/
            result = manageResponse(response);

		} else {
			result = manageResponseFake();

		}

		System.debug('[ContractOutbound] result -> ' + result);
		return result; 
	}
	
	/**
	* @description callToGetContract with insert loggin
	* @param identityNumber the identityNumber 
	* @param pos the POS
	* @param country the country to use on interface url selection
	* @return the response wrapper
	*/
	public static Map<String,Object> callToGetContract(String identityNumber, String pos, String country) {
		ContractOutboudCallInputData callData = new ContractOutboudCallInputData();
		callData.identityNumber = identityNumber;
		callData.pos = pos;
		callData.country = country;
		callData.insertLoggin = true;

		ContractOutboudCallOutputData outWr = callToGetContract(callData);
		return outWr.fieldsData;
	}
	
		/**
	* @description callToGetContract with insert loggin
	* @param identityNumber the identityNumber 
	* @param identityType
	* @param pos the POS
	* @param country the country to use on interface url selection
	* @return the response wrapper
	*/
	public static Map<String,Object> callToGetContract(String identityNumber, String identityType, String pos, String country) {
		ContractOutboudCallInputData callData = new ContractOutboudCallInputData();
		callData.identityNumber = identityNumber;
		callData.identityType = EncodingUtil.urlEncode(identityType, 'UTF-8');
		callData.pos = pos;
		callData.country = country;
		callData.insertLoggin = true;

		ContractOutboudCallOutputData outWr = callToGetContract(callData);
		return outWr.fieldsData;
	}

	/**
	* @description callToGetContract with option to insert loggin
	* @param callData the ContractOutboudCallInputData inpur wrapper
	* @return the response wrapper
	*/
	public static ContractOutboudCallOutputData callToGetContract(ContractOutboudCallInputData callData) {
		System.debug('in callToGetContract con doc = '+ callData.identityNumber+ ' e '+ callData.pos);
		ContractOutboudCallOutputData result = new ContractOutboudCallOutputData();
		XC_UTIL_RESTCallout.CSWrapper isActiveInterface;
		//11-02-2022 alag@deloitte.es B2BG Adoption Contract API - START
		System.debug('ALC segment: '+callData.segment);
		if(!String.isBlank(callData.segment) && callData.segment == 'Spain B2B'){
			isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterfaceB2B(Label.XC_CL_ContractOutbound, callData.country, callData.segment);
		}else{
			isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_ContractOutbound, callData.country);
		}
        //11-02-2022 alag@deloitte.es B2BG Adoption Contract API - END
        if(isActiveInterface.activeInterface){

			String prefixUrl = isActiveInterface.url; 
            Map<String,String> paramMap = new Map<String,String>();

			if(String.isNotBlank(callData.identityNumber)){
				paramMap.put('IdentityNumber', callData.identityNumber); 
			}
			if(String.isNotBlank(callData.identityType)){
				paramMap.put('IdentityType', callData.identityType);
			}
			//alag@deloitte.es 22-02-2022 Added filter to avoid sending prefix for Spain in case of B2B - START
			if(String.isNotBlank(callData.pos) && isActiveInterface.stream == 'B2B' && callData.country!='Spain'){
			//alag@deloitte.es 22-02-2022 Added filter to avoid sending prefix for Spain in case of B2B - END
				paramMap.put('POS', Constants.COUNTRY_ISO_CODES.get(callData.country) + '_' + callData.pos);
			} else if(String.isNotBlank(callData.pos)){
				paramMap.put('POS', callData.pos);
			}

			String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap); 
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getContract', isActiveInterface.serverSystem);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
			System.debug('[ContractOutbound] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'ContractOutbound');
			//HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'ContractOutbound');
			XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
			logWrapper.logIntegrationName = 'ContractOutbound';
			logWrapper.logTransactionID = headerDefinitions.get('TransactionID');
            logWrapper.insertLogging = callData.insertLoggin; 
            XC_UTIL_RESTCallout.HttpResponseWrapper responseWR = XC_UTIL_RESTCallout.sendRequestWithOptionLogging(request, headerDefinitions, logWrapper);

			System.debug('[ContractOutbound] response -> ' + responseWR.response);

            /********************* Parse response ********************************************/
            result.fieldsData = manageResponse(responseWR.response);
			result.integrationLog = responseWR.integrationLog;
		} else {
			result.fieldsData = manageResponseFake();
		}

		System.debug('[ContractOutbound] result -> ' + result);
		return result; 
	}
	/**
	* @description init the ContractOutbound Request
	* @param identityNumber Doc Id Number
	* @return the HttpRequest
	*/
	public static HttpRequest initContractOutboundRequest(String identityNumber){
		System.debug('@@@@ CALL initContractOutboundRequest - identityNumber=' + identityNumber);
		XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_ContractOutbound);
        if(isActiveInterface.activeInterface){

			String prefixUrl = isActiveInterface.url;
            Map<String,String> paramMap = new Map<String,String>();

			if(String.isNotBlank(identityNumber)){
				paramMap.put('IdentityNumber',identityNumber);
			}

            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap); 
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getContract', 'CommoditySpainB2C');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
			System.debug('[ContractOutbound] request -> ' + request);
			return request;
		}

		throw new XC_UTIL_RESTCallout.NotActiveInterfaceException();
	}

	/**
	* @param response the response
	* @description manages the response
	* @return the wrapper contract response
	*/
	private static Map<String,Object> manageResponse(HttpResponse response) {
		if(response==null){
			return new Map<String,Object>();
		}
		System.debug('[ContractOutbound] response Body -> ' + response.getBody());
		try{
			return (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
		}catch(JSONException ex){
			System.debug('Catch JSONException: '+ex.getMessage());
		}
        return new Map<String,Object>();
	}

	/**
	* @param response the fake response
	* @description manages the fake response
	* @return wrapper contract fake response
	*/
	public static Map<String,Object> manageResponseFake() {
		system.debug('fake');

		Map<String,Object> wrapperResult = new Map<String,Object>();

		Map<String,Object> result = new Map<String,Object>();
		result.put('ErrorCode','0');
		result.put('Message','Fake Response');

		Map<String,Object> contract = new Map<String,Object>();
		contract.put('ContractNumber','86154244451');
		contract.put('Status', 'Active');
		contract.put('ContractStartDate', '07/12/2018 10:25');
		contract.put('NameContractedService', 'Tempo Happy');
        contract.put('AddressID','ESP-FAKE-003');
		contract.put('OwnerCompany','Endesa');

		contract.put('ContractType', '');

		contract.put('Tariff','2.1');
		contract.put('MinimumElectricalConsumption','0');
		contract.put('TensionType','');
		contract.put('ContractedPower','4.6');
		contract.put('CIEAuthorizedMaximumPower','');
		contract.put('MaximumPowerPOD','10000');
        contract.put('ContractTerm'                   , ''            );
        contract.put('TypeOfSocialBonus'              , ''             );
        contract.put('SocialBonus'                    , ''               );
        contract.put('CNAE'                           , ''                          );
        contract.put('CIEExpirationRules'             , ''         );
		List<Map<String,Object>> contractList = new List<Map<String,Object>>();
		contractList.add(contract);
	
		wrapperResult.put('Result',result);
		wrapperResult.put('Contract',contractList);

        return wrapperResult;
	}

}