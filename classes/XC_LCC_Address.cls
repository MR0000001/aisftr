public without sharing class XC_LCC_Address {

    // private static final String CREDENTIALS = 'username=endesaXtest,password=X4BAmYSTuC'; 

    private static final String autocompleteEndpoint = 'callout:XC_AddressAutocomplete';
    private static final String validateEndpoint = 'callout:XC_AddressValidation';

    /**
     * @description Return the country by user info
     * @author Simone Trenta - strenta@deloitte.it
     * @return country
    */
    @AuraEnabled
    public static String getCountryByUser(){ 
        String country = XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
        if (country=='SPAIN'){
            return 'Spain';
        } else {
            return country;
        }
    }

    @AuraEnabled
    public static String[] getHiddenFieldsByCountry(String country, Boolean isSFMObject) {
        String[] result = new String[]{};
        if(isSFMObject){
            if(country =='United States'){
                country = 'USA';
            }
            country = country + '_SFM';
        }
        Schema.FieldSet fieldSet = Schema.SObjectType.XC_Address__c.fieldSets.getMap().get(country);
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                result.add(f.getFieldPath());
            }
        } else { //st - global address
            result = new List<String>{'XC_Municipality__c','XC_ClarificatorType__c','XC_ClarificatorValue__c'};
        }
        return result;
    }

    @AuraEnabled
    public static Boolean saveAddressApex(String inputAddress, String recordId) {
        try {   
            system.debug('test: '+inputAddress);
            Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputAddress);
            system.debug('test1: '+fieldMap.get('region'));
            XC_Address__c ad = populateAddress(new XC_Address__c(), fieldMap, recordId);
            Boolean isAccountPartner = isAccountPartner(recordId);
            ad.RecordTypeId = XC_UTIL_Address.getAddressRecordTypeByCountry(ad.XC_AddressCountry__c, isAccountPartner);
            insert ad;
            return true;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean isAccountPartner(Id accountId) {
        try {
            if (XC_UTIL_Sobject.getObjectType(accountId) != 'Account') return false;
            Account acc = [SELECT id, RecordType.DeveloperName FROM Account WHERE Id = :accountId];
            return acc.RecordType.DeveloperName == 'XC_Account_Partner';
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
	public static String getAddressByCup(String podValue) {
        XC_REST_AddressByPOD.ResultWrapper address = XC_REST_AddressByPOD.callToAddressByPOD(podValue);
        return JSON.serialize(address);
    }

    // AUTOCOMPLETE METHODS
    @AuraEnabled
    public static Object[] autoCompleteCity(string inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);
        
        //st - gestione country senza autocomplete
        try{
            getServerSystem((String)fieldMap.get('country'));
        }catch(Exception e){
            return new Object[]{};
        }
        
        String city = ((String)fieldMap.get('city')).replace('Ñ','N').replace('ñ','n');
        city = EncodingUtil.urlEncode(city, 'UTF-8');

        return sendAutocompleteRequest(
            new Map<String,String>{
                'country' => (String)fieldMap.get('country'),
                'city' => (String)fieldMap.get('city')
            },
            (String)fieldMap.get('country')
        );
    }

    @AuraEnabled
    public static Object[] autoCompleteStreet(String inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);
		string streetNumer = (String)fieldMap.get('streetNumber');
        if((String)fieldMap.get('country')=='Chile'||(String)fieldMap.get('country')=='Colombia'){
            return sendAutocompleteRequest(
                new Map<String,String>{
                    'city' => (String)fieldMap.get('city'),
                    'street' => (String)fieldMap.get('address'),
                    'country' => (String)fieldMap.get('country')
                    //'street_number' => '55'
                },
                (String)fieldMap.get('country')
            );
        } else{
            return sendAutocompleteRequest(
                new Map<String,String>{
                    'city_code' => (String)fieldMap.get('cityCode'),
                    'province_code' => (String)fieldMap.get('province_code'),
                    'street' => (String)fieldMap.get('address')
                },
                (String)fieldMap.get('country')
            );
        }
    }

    @AuraEnabled
    public static Object[] autoCompleteZipCode(string inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);
		system.debug('');
        return sendAutocompleteRequest(
            new Map<String,String>{
                'country' => (String)fieldMap.get('country'),
               	'city_code' => (String)fieldMap.get('cityCode'),
                'province_code' => (String)fieldMap.get('province_code'),
                'street_code' => fieldMap.get('addressCode')!=null? (String)fieldMap.get('addressCode') : '',
                'zip_code' => (String)fieldMap.get('postalCode'),
                'street_number' => (String)fieldMap.get('streetNumber')
                //'street_number' => '73'
                
            },
            
            (String)fieldMap.get('country')
        );
    }

    @AuraEnabled
    public static Object[] callToPODByAddress(String inputFields) {
        String[] res = new String[]{};
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        addrWrapper.address = inputMap.get('address') == null ? null : String.valueOf(inputMap.get('address'));
        addrWrapper.streetNumber = inputMap.get('streetNumber') == null ? null : String.valueOf(inputMap.get('streetNumber'));
        addrWrapper.zipCode = inputMap.get('postalCode') == null ? null : String.valueOf(inputMap.get('postalCode'));
        addrWrapper.province = inputMap.get('province') == null ? null : String.valueOf(inputMap.get('province'));
        addrWrapper.city = inputMap.get('city') == null ? null : String.valueOf(inputMap.get('city'));

        return new Object[]{};

        //XC_REST_PodsByAddressAPI.ResultWrapper wr = XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper);
        //System.debug(wr);
        //return wr.errorCode == 0 ? wr.podAddress.PointsOfDelivery : new Object[]{};
    }

    //TODO: questa parte dei lead va rivista perché sembra non funzioni nemmeno il vecchio componente...
    @AuraEnabled
    public static String updateAddressByLead(String inputFields, String recordId) {
        try {
            Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

            XC_Address__c address = [
                SELECT id,
                XC_AddressCountry__c ,
                XC_StreetTypeText__c,
                XC_Address__c,
                XC_StreetNumber__c,
                XC_Door__c,
                XC_PostalCode__c,
                XC_Stair__c,
                XC_Floor__c,
                XC_City__c,
                XC_AddressProvince__c,
                XC_Category__c,
                XC_Municipality__c,
                XC_GasCUPS__c,
                XC_ElectricCUPS__c,
                XC_InstallationAddress__c,
                XC_DeliveryAddress__c,
                XC_BillingAddress__c,
                XC_PickUpPoint__c,
                XC_WareHouse__c,
                XC_PointOfSales__c,
                XC_AddressValidated__c,
                XC_AddressValidatedCUPS__c,
                XC_ClarificatorType__c,
                XC_ClarificatorValue__c,
                XC_Locality__c,
                XC_Sidewalk__c,
                XC_Department__c,
                XC_AddressReference__c,
                XC_AddressReferenceValue__c,
                XC_Region__c, 
                XC_Note__c, 
                XC_DaneCode__c
                FROM XC_Address__c
                WHERE XC_Lead__c = :recordId
                LIMIT 1
            ];

            address = populateAddress(address, inputMap, recordId);
            update address;
            return address.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Object[] sendAutocompleteRequest(Map<String,String> params, String country) {
        HttpRequest req = getRequest(autocompleteEndpoint, country);
        String body = json.serialize(new Map<String,Object>{
            'Address' => params
        });
        
        req.setBody(body);

        //st - da completare
        Map<String,String> header = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'AddressAutocomplete', req.getHeader('ServerSystem'));
        HttpResponse res = XC_UTIL_RESTCallout.sendRequestLogging(req, header, 'AddressAutoComplete');        
       
        ApiResponse ar = new ApiResponse();
        try{
            ar = (ApiResponse)JSON.deserialize(res.getBody(), ApiResponse.class);
        } catch(Exception e){
            system.debug('exception'+' '+e.getMessage()); //NA
            system.debug('exception Line'+' '+e.getTypeName()); 
        }
        //
        
        return ar.isSuccess() ? (Object[]) ar.address : new Object[]{};
    }

    @AuraEnabled
    public static Object callForValidate(String inputFields) {
        Object result = null;
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);
		Map<String,Object> addressToSend = new Map<String,Object>{
            'Address' => new Map<String, String>{
                'country' => (String)inputMap.get('country'),
                'city' => (String)inputMap.get('city'),
                'province' => (String)inputMap.get('province'),
                'street' => (String)inputMap.get('address'),
                'street_number' => inputMap.get('streetNumber')==''?' ':(String)inputMap.get('streetNumber'),
                'street_type' => (String)inputMap.get('streetTypeText'),
                'zip_code' => inputMap.get('postalCode')==''?' ':(String)inputMap.get('postalCode'),
                'door' => inputMap.get('door')==null?'':(String)inputMap.get('door'),
                'stair' => inputMap.get('stair')==null?'':(String)inputMap.get('stair'),
                'floor' => inputMap.get('floor')==null?'':(String)inputMap.get('floor')
            }
        };
        
        HttpRequest req = getRequest(validateEndpoint, (String)inputMap.get('country'));
        req.setBody(json.serialize(addressToSend));
        
        Map<String,String> header = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'AddressValidate', req.getHeader('ServerSystem'));

        HttpResponse res = XC_UTIL_RESTCallout.sendRequestLogging(req, header, 'AddressValidate');  

        ApiResponse ar = new ApiResponse();
        try {
            String body = res.getBody();
            System.debug('test1: '+body);
            ar = (ApiResponse)JSON.deserialize(res.getBody(), ApiResponse.class);
            System.debug('test2: '+ar);
            System.debug('test3: '+ar);
            if (ar.isSuccess()) {
                System.debug('test4: '+ar);
                Map<String,String> address = ar.address[0];
                if (String.isBlank(address.get('street')) || String.isBlank(address.get('city')) || String.isBlank(address.get('street_number'))) {
                    result = Label.XC_CL_Address_Incorrect;
                } else {
                    result = JSON.serialize(address);
                }
            } else {
                System.debug('test5: '+ar);
                result = Label.XC_CL_Address_Incorrect;
            }
        } catch(Exception e){
            system.debug('exception'+' '+e.getMessage()); //NA
            system.debug('exception Line'+' '+e.getTypeName()); 
            return Label.XC_CL_Address_Incorrect;
        }
        return result;
    }
    
    @AuraEnabled
    public static Object getZipDirectly(String inputFields) {
        Object result = null;
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);
		Map<String,Object> addressToSend = new Map<String,Object>{
            'Address' => new Map<String, String>{
                'country' => (String)inputMap.get('country'),
                'city' => (String)inputMap.get('city'),
                'province' => (String)inputMap.get('province'),
                'street' => (String)inputMap.get('address'),
                'street_number' => inputMap.get('streetNumber')==''?' ':(String)inputMap.get('streetNumber'),
                'street_type' => (String)inputMap.get('streetTypeText'),
                'zip_code' => inputMap.get('postalCode')==''?' ':(String)inputMap.get('postalCode'),
                'door' => inputMap.get('door')==null?'':(String)inputMap.get('door'),
                'stair' => inputMap.get('stair')==null?'':(String)inputMap.get('stair'),
                'floor' => inputMap.get('floor')==null?'':(String)inputMap.get('floor')
            }
        };
        
        HttpRequest req = getRequest(validateEndpoint, (String)inputMap.get('country'));
        req.setBody(json.serialize(addressToSend));
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(req.getBody());
        System.debug(res);

        //st - da completare
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'AddressValidate';
        logWrapper.logEndpoint = validateEndpoint;
        logWrapper.logMessage = req.getBody();
        logWrapper.httpMethod = 'POST';
        intLog.insertIntegReqOutboundLog(logWrapper);
        Map<String,String> header = new Map<String,String>();
        header.put('Content-Type', 'application/json');
        header.put('ServerSystem', req.getHeader('ServerSystem'));
        intLog.setHeader(header);

        ApiResponse ar = new ApiResponse();
        try {
            String body = res.getBody();
            System.debug('test: '+body);
            ar = (ApiResponse)JSON.deserialize(res.getBody(), ApiResponse.class);
            intLog.insertIntegRespOutboundLog(ar.isSuccess(), res.getBody(), '', '');
            if (ar.isSuccess()) {
                Map<String,String> address = ar.address[0];
                result = JSON.serialize(address);
            } else {
                throw new AuraHandledException(Label.XC_CL_Address_Incorrect);
            }
        } catch(Exception e){
            intLog.insertIntegRespOutboundLog(false, res.getBody(), '', '');
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    //TODO: riabilitare alla fine, se funziona
    // @AuraEnabled
    // public static String[] getZipCodeDirectly(String inputFields) {
    //     Map<String,Object> outputMap = new Map<String,Object>();
    //     String[] res = new String[]{};
    //     Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);
    //     Map<String, String> fieldsToSend = new Map<String, String>{
    //         'city' => String.valueOf(inputMap.get('city')),
    //         'street' => String.valueOf(inputMap.get('streetType')) + ' ' + String.valueOf(inputMap.get('address')),
    //         'house' =>  String.valueOf(inputMap.get('streetNumber'))
    //     };

    //     String queryString = '';
    //     for(String field : fieldsToSend.KeySet()) {
    //         if (String.isNotBlank(fieldsToSend.get(field))) {
    //             queryString += ',' + field + '=' + fieldsToSend.get(field);
    //         }
    //     }
    //     outputMap = checkAddress(getParamsMap('checkAddress', 'ine=true,geo=true,cga=true' + EncodingUtil.urlEncode(queryString, 'UTF-8')));

    //     if (outputMap.get('zip') != null) {
    //         res.add(String.valueOf(outputMap.get('zip')));
    //         return res;
    //     }

    //     Set<String> zipSet = new Set<String>();
    //     Object[] sugg = (Object[]) outputMap.get('selList');
    //     if (sugg==null) return res;

    //     for (Object o : sugg) {
    //         Map<String,Object> convMap = (Map<String,Object>) o;
    //         if ( Integer.valueOf(convMap.get('provinceCode')) == Integer.valueOf(inputMap.get('provinceCode'))
    //             || Integer.valueOf(inputMap.get('provinceCode')) == Integer.valueOf(outputMap.get('provinceCode')) ) {
    //             zipSet.addAll(parseZipRes(''+convMap.get('zipRange')));
    //             system.debug('zipRange: '+convMap.get('zipRange'));
    //         }
    //     }
    //     res.addAll(zipSet);
    //     System.debug('res: '+res+', provCode: '+inputMap.get('provinceCode'));

    //     return res;
    // }

    // private static Map<String,Object> checkAddress(Map<String,String> paramMap) {
    //     Map<String,Object> outputMap = new Map<String,Object>();

    //     XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressValidationDC');
    //     if (isActiveInterface.activeInterface) {
    //         String prefixUrl = isActiveInterface.url;
    //         String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);

    //         Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'checkAddress', 'DataCentric');

    //         /********************** Send outbound request *************************************/
    //         HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
    //         HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'checkAddress');

    //         /********************* Parse response ********************************************/
    //         try{
    //         	outputMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
    //         } catch(Exception e) {
    //             XC_UTIL_Debug.debug(true, e+'');
    //         }

    //         switch on String.valueOf(outputMap.get('result')) {
    //             when '1' {
    //                 outputMap.put('ErrorCode', '200');
    //                 outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange );
    //             } when '2' {
    //                 outputMap.put('ErrorCode', '200');
    //                 outputMap.put('ErrorMessage', Label.XC_CL_Address_SlightModifications );
    //             } when '3' {
    //                 outputMap.put('ErrorCode', '200');
    //                 outputMap.put('ErrorMessage', Label.XC_CL_Address_ImportantModifications );
    //             } when '0' {
    //                 outputMap.put('ErrorCode', '400');
    //                 outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect );
    //             } when else {
    //                 outputMap.put('ErrorCode', '500');
    //                 outputMap.put('ErrorMessage', 'Server Error' );
    //             }
    //         }
    //     }

    //     return outputMap;
    // }

    //  private static Set<String> parseZipRes(String zipRange) {
    //     Set<String> res = new set<String>();
    //     String[] zipInterval = zipRange.split('-');
    //     Integer min = Integer.valueOf(zipInterval[0]);
    //     Integer max = Integer.valueOf(zipInterval[zipInterval.size() - 1]);
    //     for(Integer i = min; i <= max; i++) {
    //         res.add(String.valueOf(i).leftPad(5, '0'));
    //     }
    //     return res;
    // }

    // private static Map<String,String> getParamsMap(String method, String paramString){
    //     return new Map<String,String>{
    //         'method' => method,
    //         'arguments' => CREDENTIALS + ',' + paramString
    //     };
    // }

    private static XC_Address__c populateAddress(XC_Address__c ad, Map<String,Object> fieldMap, String recordId){
        String objectType = XC_UTIL_Sobject_U_Retrieve.getObjectType(recordId);
        if (objectType == 'Account') ad.XC_Account__c = recordId;
        if (objectType == 'Lead') ad.XC_Lead__c = recordId;

        ad.XC_AddressValidated__c = (Boolean)fieldMap.get('validate');
        ad.XC_AddressNotValidated__c = !ad.XC_AddressValidated__c;
        ad.XC_AddressValidatedCUPS__c  = (Boolean) (fieldMap.get('validatedCups') != null? fieldMap.get('validatedCups') :false) ;
        ad.XC_InstallationAddress__c = true;
        ad.XC_DeliveryAddress__c = true;
        ad.XC_BillingAddress__c = true;
        ad.XC_PickUpPoint__c = true;
        ad.XC_WareHouse__c = true;
        ad.XC_PointOfSales__c = true;

        //questo controllo probabilmente dipende dal fatto che i valori di XC_StreetType__c sono incompleti
        if (fieldMap.get('streetTypeText') != null) {
            ad.XC_StreetTypeText__c  = (String)fieldMap.get('streetTypeText');
            ad.XC_StreetType__c = null;
        } else {
            if (fieldMap.get('streetType') != null) {
                ad.XC_StreetType__c = (String)fieldMap.get('streetType');
            }
        }
        if (fieldMap.get('country')!='Chile'){
            Map<String, Object> fieldInputMap = new Map<String, Object>{
                'XC_AddressCountry__c' => fieldMap.get('country'),
                'XC_Address__c' => fieldMap.get('address'),
                'XC_StreetNumber__c' => fieldMap.get('streetNumber'),
                'XC_Door__c' => fieldMap.get('door'),
                'XC_GasCUPS__c' => fieldMap.get('gas'),
                'XC_ElectricCUPS__c' => fieldMap.get('electric'),
                'XC_PostalCode__c' => fieldMap.get('postalCode'),
                'XC_Stair__c' => fieldMap.get('stair'),
                'XC_Floor__c' => fieldMap.get('floor'),
                'XC_City__c' => fieldMap.get('city'),                                               
                'XC_Municipality__c' => fieldMap.get('municipality'),                                                       
                'XC_AddressProvince__c' => fieldMap.get('province'),
                'XC_Category__c' => fieldMap.get('category'),
                'XC_ClarificatorType__c' => fieldMap.get('clarifType'),
                'XC_ClarificatorValue__c' => fieldMap.get('clarifValue'),
                'XC_Region__c' => fieldMap.get('region'),
                'XC_Note__c' => fieldMap.get('note'),
                'XC_Lead__c' => fieldMap.get('lead'),
                'XC_Department__c' => fieldMap.get('department'),
                'XC_AddressReferenceValue__c' => fieldMap.get('addressRefVal'),
                'XC_AddressReference__c' => fieldMap.get('addressRef'),
                'XC_Sidewalk__c' => fieldMap.get('sidewalk'),
                'XC_Locality__c' => fieldMap.get('locality'),
                'XC_DaneCode__c' => fieldMap.get('daneCode')
               };
           
            for (String field : fieldInputMap.keySet()) {
                if (String.isNotBlank((String)fieldInputMap.get(field))) { //for update purpose
                    ad.put(field, fieldInputMap.get(field));
                }
            }
            return ad;
        }else {
            Map<String, Object> fieldInputMap = new Map<String, Object>{
                'XC_AddressCountry__c' => fieldMap.get('country'),
                'XC_Address__c' => fieldMap.get('address'),
                'XC_StreetNumber__c' => fieldMap.get('streetNumber'),
                'XC_Door__c' => fieldMap.get('door'),
                'XC_GasCUPS__c' => fieldMap.get('gas'),
                'XC_ElectricCUPS__c' => fieldMap.get('electric'),
                'XC_PostalCode__c' => fieldMap.get('postalCode'),
                'XC_Stair__c' => fieldMap.get('stair'),
                'XC_Floor__c' => fieldMap.get('floor'),
                'XC_Municipality__c' => fieldMap.get('city'),
                'XC_City__c' => fieldMap.get('municipality'),
                'XC_AddressProvince__c' => fieldMap.get('province'),
                'XC_Category__c' => fieldMap.get('category'),
                'XC_ClarificatorType__c' => fieldMap.get('clarifType'),
                'XC_ClarificatorValue__c' => fieldMap.get('clarifValue'),
                'XC_Region__c' => fieldMap.get('region'),
                'XC_Note__c' => fieldMap.get('note'),
                'XC_Lead__c' => fieldMap.get('lead'),
                'XC_Department__c' => fieldMap.get('department'),
                'XC_AddressReferenceValue__c' => fieldMap.get('addressRefVal'),
                'XC_AddressReference__c' => fieldMap.get('addressRef'),
                'XC_Sidewalk__c' => fieldMap.get('sidewalk'),
                'XC_Locality__c' => fieldMap.get('locality'),
                'XC_DaneCode__c' => fieldMap.get('daneCode')
                };
           
            for (String field : fieldInputMap.keySet()) {
                if (String.isNotBlank((String)fieldInputMap.get(field))) { //for update purpose
                    ad.put(field, fieldInputMap.get(field));
                }
            }
            return ad;
        }
    }

    private static HttpRequest getRequest(String endpoint, String country) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(autocompleteEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('ServerSystem', getServerSystem(country));
        req.setEndpoint(endpoint);
        return req;
    }

    /**
     * @description Return the server system for the given country 
     * @param country the country
     * @return server system
    */
    @AuraEnabled
    public static String getServerSystem(String country) {
        XC_CM_CountryISOCodeAssociation__mdt[] config = [SELECT Id, ServerSystem__c FROM XC_CM_CountryISOCodeAssociation__mdt WHERE DeveloperName = :country];
        if (config.size() == 0 || String.isBlank(config[0].ServerSystem__c)) throw new AuraHandledException('Country not configured');
        return config[0].ServerSystem__c;
    }

    // CLASSES
    public class ApiResponse {
        private Result result;
        @AuraEnabled public List<Map<String,String>> address;

        public Boolean isSuccess() {
            return this.result != null && this.result.error_code == '0';
        }
    }

    public class Result {
        String message, error_code;
        String[] result;
    }

    @AuraEnabled
    public static Boolean getRecordTypeParentObject(String recordId){
        String objType = XC_UTIL_Sobject.getObjectType(recordId);
        String recordTypeName = '';
        if(objType == 'Account'){
            recordTypeName = [Select RecordType.Name from account where id = :  recordId LIMIT 1].RecordType.Name;
        }else if(objType == 'Lead'){
            recordTypeName = [Select RecordType.Name from Lead where id = :  recordId LIMIT 1].RecordType.Name;
        }
        return recordTypeName.contains('SFM');
    }
}