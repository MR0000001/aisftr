/**
 * The Class XC_LCC011_NewAddress.
 *
 * @author dpalamides,
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC011_NewAddress -  Controller for XC_LCP011_NewAddress
 */
public without sharing class XC_LCC167_NewAddressXygo {

    //private static final String DC_URL = 'https://online.datacentric.es/ws/postal.ajax?method=autocomplete&arguments=username=endesaXtest,password=X4BAmYSTuC,';
    //private static final String DC_URL_CHECK_ADDRESS = 'https://online.datacentric.es/ws/postal.ajax?method=checkAddress&arguments=username=endesaXtest,password=X4BAmYSTuC,ine=true,geo=true,cga=true';

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC167_NewAddressXygo');
    private final static Boolean MOCK_VALIDATION = false;

    /**
    * @author dpalamides 
    * @date Creation 10/04/2019
    * @description Class XygoSearchAddressHeaderWrapper
    */
    public class XygoSearchAddressHeaderWrapper {
        public Integer Codigo     ;
        public String  Glosa      ;
        public String  Descripcion;
    }
    /**
    * @author dpalamides 
    * @date Creation 10/04/2019
    * @description Class XygoSearchAddressResultWrapper
    */
    public class XygoSearchAddressResultWrapper {
        public String  Metodo        ;
        public String  Id            ;
        public String  DireccionOrPOI;
        public Integer Tipo          ;
        public String  Pais          ;
        public String  Locacion      ;
        public String  Calle         ;
        public String  Numero        ;
        public String  EntreCalle    ;
        public String  Comuna        ;
        public String  Provincia     ;
        public String  Region        ;
        public Integer IdTipo        ;
    }
    
    /**
    * @author dpalamides
    * @date Creation 08/04/2019
    * @description classes.WrapperRespGET
    */
    public class WrapperRespXygoGET{
        //public XC_UTIL_EntityIntegration.Header Header
        public XygoSearchAddressHeaderWrapper JSON;
        public List<XygoSearchAddressResultWrapper>  Resultados;
    }

    /**
     * Save address apex.
     *
     * @author dpalamides -  
     * @param inputAddress the input address
     * @return the x C UTI L result wrapper
     * @description Method for save address from button on Account detail page.
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveAddressApex(String inputAddress) {
        return XC_LCC167_U_NewAddressXygo.saveAddressApex(inputAddress);
    }

    /**
     * Save address apex.
     *
     * @author dpalamides -
     * @param recordId the input Id
     * @return String serialized address fields
     * @description retrieve an address from parent record id
     */
    @AuraEnabled
    public static String getAddressApex(String recordId) {
        XC_Address__c add = null;
        Map<String,Object> res = new Map<String,Object>();
        if (XC_UTIL_Sobject.getObjectType(recordId) == 'Lead' && Schema.sObjectType.XC_Address__c.isAccessible()) {
            try {
                add = [
                        SELECT id, XC_Lead__c,
                                XC_AddressCountry__c,
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
                                XC_ClarificatorType__c, //new
                                XC_ClarificatorValue__c  //new
                        FROM XC_Address__c
                        WHERE XC_Lead__r.id = :recordId
                        limit 1
                ];
            }catch (Exception e){
                add=null;
            }
        }
        if(add==null){
            return JSON.serialize(res, true);
        }

        res.put('country',add.XC_AddressCountry__c);
        res.put('streetTypeText',add.XC_StreetTypeText__c);
        res.put('address',add.XC_Address__c);
        res.put('streetNumber',add.XC_StreetNumber__c);
        res.put('postalCode',add.XC_PostalCode__c);
        res.put('city',add.XC_City__c);
        res.put('province',add.XC_AddressProvince__c);
        res.put('municipality',add.XC_Municipality__c);
        res.put('validate',add.XC_AddressValidated__c);
        res.put('validatedCups',add.XC_AddressValidatedCUPS__c);
        res.put('clarifType',add.XC_ClarificatorType__c);
        res.put('clarifValue',add.XC_ClarificatorValue__c);
        res.put('lead',add.XC_Lead__c);

        return JSON.serialize(res, true);
    }

    /**
     * @author dpalamides -  
     * @description Retrieve account record type name.
     *
     * @param accountId the account id
     * @return the string
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrieveAccountRecordTypeName(Id accountId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        if(XC_UTIL_Sobject.getObjectType(accountId) != 'Account'){
            rw.success = false;
            return rw;
        }

        Map<id,Account> acc = new Map<id,Account>([SELECT id, IdentityNumber__c, IdentityType__c, RecordType.DeveloperName FROM Account WHERE Id=:accountId limit 1]);
        if(acc.values().isEmpty()){
            return rw;
        }

        Account a = acc.values()[0];
        rw.success = true;
        rw.typeMessage = a.RecordType.DeveloperName;
        if(a.IdentityType__c!=null ){
            rw.objectInfo = a.IdentityNumber__c;
        }

        return rw;
    }

    /**
     *
     * @param podValue  the pod id
     * @return the String
     * @author: Roberta Porrega - roberta.porrega@nttdata.com
     * @description : Method for retrive the response of the XC_REST_AddressByPOD class
    */
    @AuraEnabled
    public static String getAddressByCup(String podValue) {
        XC_REST_AddressByPOD.ResultWrapper address = XC_REST_AddressByPOD.callToAddressByPOD(podValue);
        return JSON.serialize(address);
    }

    /* ---------------------- Methods for autocompleting address ---------------------- */

    /**
     * @description AutoComplete street
     * @param inputFields the input fields
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static List<String> autoCompleteStreet(string inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);

        String street = (String) fieldMap.get('address');
        String country = (String) fieldMap.get('country');
        String province = (String) fieldMap.get('province');
        String city = (String) fieldMap.get('city');

        street = street.replace('Ñ','N');
        street = street.replace('ñ','n');
        street = EncodingUtil.urlEncode(city+' '+street, 'UTF-8');

        String queryString = '';
        if(String.isNotBlank(city)&&String.isNotBlank(province)){
            queryString = 'provinceCode='+province+',cityCode='+city+',input='+street;
        } else {
            queryString = 'input='+street;
        }

        Map<String,String> paramMap = new Map<String,String>{
                'busqueda'=>String.escapeSingleQuotes(street),
                'tipo'=> 'direccion',//EncodingUtil.urlEncode('comuna, calle_comuna', 'UTF-8'), // 
                'cant'=>'20',
                'id_pais'=>(country == 'Colombia' ? '57' : '56')
        };

        return sendRequestDC(paramMap);
    }

    /**
     * @description AutoComplete city
     * @param inputFields the input fields
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static List<String> autoCompleteCity(string inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);

        String city = (String) fieldMap.get('city');

        city = city.replace('Ñ','N');
        city = city.replace('ñ','n');
        city = EncodingUtil.urlEncode(city, 'UTF-8');

        Map<String,String> paramMap = new Map<String,String>{  };

        return sendRequestDC(paramMap);
    }

    /**
     * @description AutoComplete zip
     * @param inputFields the input fields
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static List<String> autoCompleteZipCode(string inputFields) {
        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(inputFields);


        String zip = (String) fieldMap.get('postalCode');
        String province = (String) fieldMap.get('provinceCode');
        String city = (String) fieldMap.get('cityCode');

        Map<String,String> paramMap = new Map<String,String>{ };

        return sendRequestDC(paramMap);
    }

    /**
     * @description Get the zipcode
     * @param inputFields the address serialized
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static List<String> getZipCodeDirectly(String inputFields) {
        Map<String,Object> outputMap = new Map<String,Object>();
        List<String> res = new List<String>();
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

        String queryString = '';

        Map<String, String> fieldsToSend = new Map<String, String>{
                'city' => String.valueOf(inputMap.get('city')),
                'street' => String.valueOf(inputMap.get('streetType'))+' '+String.valueOf(inputMap.get('address')),
                'house' =>  String.valueOf(inputMap.get('streetNumber'))
        };

        for(String field : fieldsToSend.KeySet()) {
            if(fieldsToSend.get(field)!=null&&fieldsToSend.get(field)+''!='') {
                queryString += ','+field+'='+fieldsToSend.get(field);
            }
        }

        Map<String,String> paramMap = new Map<String,String>{
                'method'=>'checkAddress',
                'arguments'=>'username=endesaXtest,password=X4BAmYSTuC,ine=true,geo=true,cga=true'+EncodingUtil.urlEncode(queryString, 'UTF-8')
        };

        outputMap = checkAddress(paramMap);

        if(outputMap.get('zip') != null){
            res.add(String.valueOf(outputMap.get('zip')));
            return res;
        }

        Set<String> zipSet = new Set<String>();
        List<Object> sugg = (List<Object>) outputMap.get('selList');
        for (Object o : sugg){
            Map<String,Object> convMap = (Map<String,Object>) o;
            if( Integer.valueOf(convMap.get('provinceCode')) == Integer.valueOf(inputMap.get('provinceCode'))
                    || Integer.valueOf(inputMap.get('provinceCode')) == Integer.valueOf(outputMap.get('provinceCode')) ){
                zipSet.addAll(parseZipRes(''+convMap.get('zipRange')));
                system.debug('zipRange: '+convMap.get('zipRange'));
            }
        }
        res.addAll(zipSet);
        system.debug('res: '+res+', provCode: '+inputMap.get('provinceCode'));

        return res;
    }

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

    /**
     * @description Return the country by user info
     * @author dpalamides
     * @return country
    */
    @AuraEnabled
    public static String getCountryByLead(String recordId){
        try {
            Lead l = (Lead) XC_UTIL_Sobject.selectAllFields(recordId)[0];
            return l.XC_Country__c;
        }catch(Exception e) {
            return null;
        }

    }

    /**
     * @description Validate address with Data Centric service
     * @param inputFields the address serialized
     * @return a map of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static Map<String,Object> callForValidateXygo(String inputFields) {

        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

        XC_UTIL_Address.AddressWrapper addrToValidate = new XC_UTIL_Address.AddressWrapper('REST');

        addrToValidate.streetType = String.valueOf(inputMap.get('streetType'))!= null ? String.valueOf(inputMap.get('streetType'))  : ' ';
        addrToValidate.street =  String.valueOf(inputMap.get('address'));// + (String.valueOf(inputMap.get('country'))!= 'Colombia' ? String.valueOf(inputMap.get('streetNumber')) : '');
        if(String.valueOf(inputMap.get('streetNumber')) != null){
            addrToValidate.street = addrToValidate.street.remove(' '+String.valueOf(inputMap.get('streetNumber')));
        }
        addrToValidate.streetNumber = String.valueOf(inputMap.get('country'))!= 'Colombia' && String.valueOf(inputMap.get('streetNumber')) != null ? String.valueOf(inputMap.get('streetNumber')) : ' ';
        addrToValidate.city = String.valueOf(inputMap.get('city'));
        //addrToValidate.province = String.valueOf(inputMap.get('region'));
        addrToValidate.zipCode = ' ';
        //addrToValidate.Province       =   String.valueOf(inputMap.get('province') != null ? inputMap.get('province') : '');
        addrToValidate.country = String.valueOf(inputMap.get('country'));
        addrToValidate.RecordNum = '20';
        XC_REST_AddressValidation.ResultWrapper rw = callToAddressValidation(addrToValidate);

        if(rw.success){
            outputMap.put('ErrorCode', '200');
            outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange);
        }else{
            outputMap.put('ErrorCode', '400');
            outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect);
        }

        /*
        String queryString = '';

        Map<String, String> fieldsToSend = new Map<String, String>{
                'city' => String.valueOf(inputMap.get('city')),
                'street' => String.valueOf(inputMap.get('streetType'))+' '+String.valueOf(inputMap.get('address')),
                //'zip' => String.valueOf(inputMap.get('postalCode')),
                'house' =>  String.valueOf(inputMap.get('streetNumber') != null ? inputMap.get('streetNumber') : ''),
                'recordNum' => '20'
        };

        for(String field : fieldsToSend.KeySet()) {
            if(fieldsToSend.get(field)!=null&&fieldsToSend.get(field)+''!='') {
                queryString += ','+field+'='+fieldsToSend.get(field);

            } else {
                outputMap.put('ErrorCode', '400');
                outputMap.put('ErrorMessage', Label.XC_CL_MandatoryField +field);
                return outputMap;
            }
        }

        Map<String,String> paramMap = new Map<String,String>{
                'method'=>'checkAddress',
                'arguments'=>'username=endesaXtest,password=X4BAmYSTuC,ine=true,geo=true,cga=true'+EncodingUtil.urlEncode(queryString, 'UTF-8')
        };
        */
        return outputMap;//checkAddress(paramMap);
    }

    private static XC_REST_AddressValidation.ResultWrapper callToAddressValidation(XC_UTIL_Address.AddressWrapper addrToValidate) {
        XC_REST_AddressValidation.ResultWrapper result = new XC_REST_AddressValidation.ResultWrapper();

        if(MOCK_VALIDATION){
            result.success = true;
            result.addressResult = 'Validation OK';
            result.address = JSON.serialize(addrToValidate, true);
            return result;
        }

        Map<String, String> fieldsToSend = new Map<String, String>{
                'street_type' => addrToValidate.streetType,
                'street' => addrToValidate.street,
                'street_number' => addrToValidate.streetNumber,
                'zip_code' => addrToValidate.zipCode,
                'city' => addrToValidate.city,
                'country' => addrToValidate.country,
                'iso_country' => addrToValidate.country == 'Chile' ? 'CHL' : 'COL'
                //'province' => addrToValidate.province
        };

        Map<String,Object> addr =  new Map<String, Object>{
                'Address' => fieldsToSend
        };

        XC_UTIL_Integration.Result checkParameters = XC_REST_AddressValidation_U.checkRequiredParameters(addrToValidate);
        if(checkParameters.ErrorCode != '0' && false) {
            result.success = false;
            result.addressResult = checkParameters.Message;
            return result;
        }

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_Address_Validation);
        System.debug('isActiveInterface:'+isActiveInterface);
        if(isActiveInterface.activeInterface){

            String url = isActiveInterface.url;

            XC_REST_AddressValidation_U.WrapperAddressRequest addRequest = new XC_REST_AddressValidation_U.WrapperAddressRequest();
            //addRequest.Address = fieldsToSend;

            System.debug('[AddressValidation] request -> ' + addr);//addRequest.Address);
            String body = JSON.serialize(addr, true);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'ValidateAddress', 'LatamAddressNormalizer');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[AddressValidation] request -> ' + request);
            System.debug('[AddressValidation] request Body -> ' + body);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'AddressValidation');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'AddressValidation');

            System.debug('[AddressValidation] response -> ' + response);
            
            /********************* Parse response ********************************************/
            //result = manageResponse(response);
            Map<String,Object> mapp = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> addrList = (List<Object>) mapp.get('Address');
            Boolean found = false;
            for(Object addrStr : addrList != null ? addrList : new List<Object>()){
                Map<String,Object> addMap = (Map<String,Object>) addrStr;
                System.debug(addrToValidate.street.toUpperCase());
                System.debug(String.valueOf(addMap.get('street')).toUpperCase());
                System.debug(addrToValidate.streetNumber);
                System.debug(String.valueOf(addMap.get('street_number')));
                System.debug(addrToValidate.city.toUpperCase());
                System.debug(String.valueOf(addMap.get('city')).toUpperCase());
                System.debug(String.valueOf(addMap.get('country')).toUpperCase());
                found =(
                        //  (addrToValidate.streetType == String.valueOf(addMap.get('StreetType')) || String.isEmpty(addrToValidate.streetType))
                        addrToValidate.street.toUpperCase() ==  String.valueOf(addMap.get('street')).toUpperCase()//+ (String.valueOf(addMap.get('Country'))== 'Colombia' ? ' '+String.valueOf(addMap.get('StreetNumber')) : '')
                                && (addrToValidate.streetNumber == String.valueOf(addMap.get('street_number')) || String.valueOf(addMap.get('country')).toUpperCase()== 'COLOMBIA')
                                && addrToValidate.city.toUpperCase() == String.valueOf(addMap.get('province')).toUpperCase()
                                && addrToValidate.country.toUpperCase() == String.valueOf(addMap.get('country')).toUpperCase()
                );

                if(found){
                    break;
                }
            }
            result.success = (response.getStatusCode() == 200 && found);
            result.addressResult = response.getBody();
            result.address = JSON.serialize(addrToValidate, true);
        } else {
            result.success = true;
            result.addressResult = 'Validation OK';
            result.address = JSON.serialize(addrToValidate, true);
        }

        System.debug('[AddressValidation] result -> ' + result);
        return result;
    }


    private static Map<String,Object> checkAddress(Map<String,String> paramMap) {
        Map<String,Object> outputMap = new Map<String,Object>();


        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressValidationDC');
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'checkAddress', 'Xygo');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'checkAddress');

            //outputMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

            if(MOCK_VALIDATION){
                outputMap = new Map<String,Object>();
                outputMap.put('ErrorCode', '200');
                outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange);
            }else {
                System.debug('Validation response:'+response.getBody());
                outputMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                switch on String.valueOf(outputMap.get('result')) {
                    when '1' {
                        outputMap.put('ErrorCode', '200');
                        outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange);
                    } when '2' {
                        outputMap.put('ErrorCode', '200');
                        outputMap.put('ErrorMessage', Label.XC_CL_Address_SlightModifications);
                    } when '3' {
                        outputMap.put('ErrorCode', '200');
                        outputMap.put('ErrorMessage', Label.XC_CL_Address_ImportantModifications);
                    } when '0' {
                        outputMap.put('ErrorCode', '400');
                        outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect);
                    } when else {
                        outputMap.put('ErrorCode', '500');
                    }
                }
            }

        }
        return outputMap;
    }

    /**
     * @description send a request to Xygo
     * @param paramMap the paramMap
     * @return a list of string
     * @author Simone Trenta - strenta@deloitte.it
    */
    private static List<String> sendRequestDC(Map<String,String> paramMap){
        List<String> result = new List<String>();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressAutocompleteCHL');
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'AutoCompletAddress', 'Xygo');

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'AutoCompleteAddress');

            /********************* Parse response ********************************************/
            System.debug('response##'+response);
            //List<Object> resToConv = (List<Object>) JSON.deserializeUntyped(response.getBody());
            WrapperRespXygoGET wrResp = (WrapperRespXygoGET) JSON.deserialize(response.getBody(), WrapperRespXygoGET.class);
            System.debug('Xygo_RESPONSE:'+response.getBody());
            for(XygoSearchAddressResultWrapper o : wrResp.Resultados != null ? wrResp.Resultados : new List<XygoSearchAddressResultWrapper>()){
                //Map<String,Object> r = (Map<String,Object>) o;
                XC_LCC167_U_NewAddressXygo.AddressWrapper addr = new XC_LCC167_U_NewAddressXygo.AddressWrapper();
                addr.country = o.pais == '56' ? 'Chile' : 'Colombia';
                addr.province = o.region;
                addr.city = o.provincia;
                addr.municipality = o.comuna;
                addr.address = o.calle;
                addr.streetNumber = o.numero;

                result.add(String.valueOf(JSON.serialize(addr)));
            }
        }

        return result;
    }

    /**
    * @description Validate address trough Xygo service
    * @param inputFields the address serialized
    * @return a list of results
    * @author Simone Trenta - strenta@deloitte.it
    */
    @AuraEnabled
    public static List<String> callToPODByAddress(String inputFields) {

        List<String> res = new List<String>();
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields);

        XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
        //addrWrapper.streetType = inputMap.get('streetType')==null ? null : String.valueOf(inputMap.get('streetType'));
        addrWrapper.address = inputMap.get('address')==null ? null : String.valueOf(inputMap.get('address'));
        addrWrapper.streetNumber = inputMap.get('streetNumber')==null ? null : String.valueOf(inputMap.get('streetNumber'));
        addrWrapper.zipCode = inputMap.get('postalCode')==null ? null : String.valueOf(inputMap.get('postalCode'));
        addrWrapper.province = inputMap.get('province')==null ? null : String.valueOf(inputMap.get('province'));
        addrWrapper.city = inputMap.get('city')==null ? null : String.valueOf(inputMap.get('city'));

        XC_REST_PodsByAddressAPI.ResultWrapper wr = XC_REST_PodsByAddressAPI.callToPODByAddress(addrWrapper);

        if(wr.podAddress!=null && wr.podAddress.PointsOfDelivery!=null){
            for (XC_UTIL_Address.AddressWrapper a : wr.podAddress.PointsOfDelivery) {
                res.add(JSON.serialize(a, true));
            }
        }

        return res;
    }

    /**
     * @description update address
     * @param inputFields the address serialized
     * @param leadId the lead id
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static String updateAddressByLead(String inputFields) {
        return JSON.serialize(XC_LCC167_U_NewAddressXygo.updateAddressByLead(inputFields),true);
    }

    /**
     * @description update lead
     * @param leadId the lead id
     * @param addressId the address id
     * @return a list of results
     * @author Simone Trenta - strenta@deloitte.it
     */
    @AuraEnabled
    public static String updateLead(String leadId, String addressId) {
        Lead l = new Lead();
        l.id = leadId;
        l.XC_LeadAddress__c = addressId;
        XC_UTIL_Sobject.WrapperResult res = XC_UTIL_Sobject.updateRecord(l);
        return JSON.serialize(res,true);
    }

    /**
     * @description Return a set of zips, parsing a range of zips
     * @param zipRange the zipRange
     * @author Simone Trenta - strenta@deloitte.it
     * @return the results set
    */
    private static Set<String> parseZipRes(String zipRange){
        Set<String> res = new set<String>();
        List<String> zipInterval = zipRange.split('-');

        if(zipInterval.size()==1){
            res.addAll(zipInterval);
            return res;
        }

        for(integer i = Integer.valueOf(zipInterval[0]); i<=Integer.valueOf(zipInterval[1]); i++){
            String is = i+'';

            integer zeroToadd = 5-is.length();

            for(integer x = 0; x < zeroToadd; x ++){
                is = '0'+is;
            }

            res.add(is);
        }

        return res;
    }

}