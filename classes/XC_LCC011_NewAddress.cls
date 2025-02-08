/**
 * The Class XC_LCC011_NewAddress.
 *
 * @author Lorenzo Orlanducci,
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC011_NewAddress -  Controller for XC_LCP011_NewAddress
 */
public without sharing class XC_LCC011_NewAddress {

    //private static final String DC_URL = 'https://online.datacentric.es/ws/postal.ajax?method=autocomplete&arguments=username=endesaXtest,password=X4BAmYSTuC,';
    //private static final String DC_URL_CHECK_ADDRESS = 'https://online.datacentric.es/ws/postal.ajax?method=checkAddress&arguments=username=endesaXtest,password=X4BAmYSTuC,ine=true,geo=true,cga=true';

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC011_NewAddress');    
    
    /**
     * Save address apex.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @param inputAddress the input address
     * @return the x C UTI L result wrapper
     * @description Method for save address from button on Account detail page.
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveAddressApex(String inputAddress) { 
       return XC_LCC011_U_NewAddress.saveAddressApex(inputAddress);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
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
        String province = (String) fieldMap.get('provinceCode');
        String city = (String) fieldMap.get('cityCode');       

        //street = street.replace('Ñ','N');
        //street = street.replace('ñ','n');
        street = EncodingUtil.urlEncode(street, 'UTF-8');

        String queryString = '';
        if(String.isNotBlank(city)&&String.isNotBlank(province)){
            queryString = 'provinceCode='+province+',cityCode='+city+',input='+street;
        } else {
            queryString = 'input='+street;
        }       

        Map<String,String> paramMap = new Map<String,String>{
            'method'=>'autocomplete',
            'arguments'=>'username=endesaXtest,password=X4BAmYSTuC,search=street,'+queryString
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

        Map<String,String> paramMap = new Map<String,String>{
            'method'=>'autocomplete',
            'arguments'=>'username=endesaXtest,password=X4BAmYSTuC,search=city,input='+city
        };

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

        Map<String,String> paramMap = new Map<String,String>{
            'method'=>'autocomplete',
            'arguments'=>'username=endesaXtest,password=X4BAmYSTuC,search=zip,provinceCode='+province+',cityCode='+city+',input='+zip
        };
 
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
        if(sugg==null){
            return res;
        }
        
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
 
    private static Map<String,Object> checkAddress(Map<String,String> paramMap) {
        Map<String,Object> outputMap = new Map<String,Object>();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressValidationDC');
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'checkAddress', 'DataCentric');
        
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'checkAddress');

            /********************* Parse response ********************************************/
            try{
            	outputMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());      
            } catch(Exception e){
                XC_UTIL_Debug.debug(true, e+'');
            }

            switch on String.valueOf(outputMap.get('result')) {
                when '1' {
                    outputMap.put('ErrorCode', '200');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_NoChange );
                } when '2' {
                    outputMap.put('ErrorCode', '200');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_SlightModifications );
                } when '3' {
                    outputMap.put('ErrorCode', '200');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_ImportantModifications );
                } when '0' {
                    outputMap.put('ErrorCode', '400');
                    outputMap.put('ErrorMessage', Label.XC_CL_Address_Incorrect );
                } when else {
                    outputMap.put('ErrorCode', '500');
                    outputMap.put('ErrorMessage', 'Server Error' );
                }
            }
            
        }
        
        return outputMap;
    } 

    /**
     * @description send a request to Data Centric
     * @param paramMap the paramMap
     * @return a list of string
     * @author Simone Trenta - strenta@deloitte.it
    */
    private static List<String> sendRequestDC(Map<String,String> paramMap){
        List<String> result = new List<String>();

        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('AddressAutocompleteDC');
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, paramMap);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'AutoCompletAddress', 'DataCentric');
        
            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request,  headerDefinitions.get('TransactionID') , 'AutoCompleteAddress');

            /********************* Parse response ********************************************/
            
            List<Object> resToConv = (List<Object>) JSON.deserializeUntyped(response.getBody());
            for(Object o : resToConv){
                Map<String,Object> r = (Map<String,Object>) o;
                result.add(String.valueOf(JSON.serialize(r)));
            }
        } 
    
        return result;
    }

     /**
     * @description Validate address trough Data Centric service
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
        return JSON.serialize(XC_LCC011_U_NewAddress.updateAddressByLead(inputFields),true);
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

    /**
     * @description Validate address with Mashery service
     * @param inputFields the address serialized
     * @return a map of results
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     */
    @AuraEnabled  
    public static Map<String,Object> callForValidateDC(String inputFields) {    
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(inputFields); 
        return XC_REST_AddressValidation.callToAddressValidationNew(inputMap);
    }

}