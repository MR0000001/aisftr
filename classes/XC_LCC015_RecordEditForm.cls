/**
* @author Monica Cutillo
* @date Creation 25/09/2018
* @description XC_LCC015_RecordEditForm
*/

public with sharing class XC_LCC015_RecordEditForm {
    
    /**
     * Gets the fields set values.
     * @description Gets the fields set values.
     * @param objName the obj name
     * @param fieldsSetName the fields set name
     * @return the fields set values
     */
    @AuraEnabled
    public static List<String> getFieldsSetValues(String objName, String fieldsSetName){
        return XC_UTIL_Sobject.getListFieldsFromFieldSet(objName, fieldsSetName);
    }
    
	/**
	 * Call to address validation.
	 *
	 * @param leadId the lead id
	 * @param addrMap the addr map
	 * @return the x C RES T address validation. result wrapper
	 * @author: Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
	 * @description : Method for retrive the response of the XC_REST_AddressValidation class
	 */
     @AuraEnabled
     public static XC_REST_AddressValidation.ResultWrapper callToAddressValidation(String leadId, Map<String,Object> fieldMap) {
        
          XC_UTIL_Address.AddressWrapper aw = new XC_UTIL_Address.AddressWrapper('REST');
         XC_REST_AddressValidation.ResultWrapper result = new XC_REST_AddressValidation.ResultWrapper();
        //Map<String,Object> addrMap = (Map<String, Object>) JSON.deserializeUntyped(addrMapp);
       System.debug('filedMap = '+JSON.serialize(fieldMap ));
       /*
        addrToValidate.country = (String)addrMap.get('XC_Country__c');
        addrToValidate.streetType = (String)addrMap.get('XC_StreetType__c');
        addrToValidate.street= (String)addrMap.get('XC_Address__c');
        addrToValidate.streetNumber= (String)addrMap.get('XC_StreetNumber__c');
        //addrToValidate.typeOfHouse=addrMap.get('XC_TypeOfHouse__c');
        addrToValidate.door= (String)addrMap.get('XC_Door__c');
        addrToValidate.stair = (String)addrMap.get('XC_Stair__c');
        addrToValidate.zipCode=  (String)addrMap.get('XC_ZipCode__c');
        //addrToValidate.cityHall=addrMap.get('XC_CityHall__c');
        addrToValidate.city=  (String)addrMap.get('XC_City__c');
        addrToValidate.province=  (String)addrMap.get('XC_Province__c');
        //addrToValidate.pod=addrMap.get('XC_PoD__c');
        addrToValidate.category=  (String)addrMap.get('XC_Category__c');
        System.debug('@@@@ Address To Validate '+addrToValidate); */
         
         if(fieldMap.get('XC_Country__c')!=null){
          aw.Country = XC_UTIL_Country.retriveCountryCode((String) fieldMap.get('XC_Country__c'));
        }
      
        aw.Street       = fieldMap.get('XC_Address__c')!=null      ? (String) fieldMap.get('XC_Address__c')      : '';
        aw.StreetNumber = fieldMap.get('XC_StreetNumber__c')!=null ? (String) fieldMap.get('XC_StreetNumber__c') : '';
        aw.ZipCode      = fieldMap.get('XC_ZipCode__c')!=null   ? (String) fieldMap.get('XC_ZipCode__c')   : '';
        aw.Province     = fieldMap.get('XC_Province__c')!=null     ? (String) fieldMap.get('XC_Province__c')     : '';
        aw.City         = fieldMap.get('XC_City__c')!=null         ? (String) fieldMap.get('XC_City__c')         : '';       
        aw.StreetType   = fieldMap.get('XC_StreetType__c')!=null   ? (String) fieldMap.get('XC_StreetType__c')   : '';
        aw.Category     = fieldMap.get('XC_Category__c')!=null     ? (String) fieldMap.get('XC_Category__c')     : '';
        
            
            
        result = XC_REST_AddressValidation.callToAddressValidation(aw);
         System.debug('RISULTATO VALIDATE = '+result);
        return result;
    }

    /**
	 * Call to address validation data centric
	 *
	 * @param fieldMap the addr map
	 * @return the x C RES T address validation. result wrapper
	 * @author: Simone Trenta - strenta@deloitte.it
	 * @description : Method for retrive the response of the XC_REST_AddressValidation class
	 */
     @AuraEnabled
     public static XC_REST_AddressValidation.ResultWrapper callToAddressValidationDC(Map<String,Object> fieldMap) {

        XC_REST_AddressValidation.ResultWrapper result = new XC_REST_AddressValidation.ResultWrapper();

        Map<String,Object> inmapdc = new Map<String,Object>();
        inmapdc.put('city', fieldMap.get('XC_City__c'));
        inmapdc.put('streetType', fieldMap.get('XC_StreetTypeText__c'));
        inmapdc.put('address', fieldMap.get('XC_Address__c'));
        inmapdc.put('postalCode', fieldMap.get('XC_ZipCode__c')); 
        inmapdc.put('streetNumber', fieldMap.get('XC_StreetNumber__c'));

        Map<String,Object> resmapdc = XC_LCC011_NewAddress.callForValidateDC(JSON.serialize(inmapdc));
        result.success = (resmapdc.get('ErrorCode')=='200');

        System.debug('RISULTATO VALIDATE = '+result);
        return result;
    }
}