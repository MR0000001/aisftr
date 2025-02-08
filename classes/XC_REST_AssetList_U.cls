/**
 * @author             Luisana Rocco lrocco@deloitte.it
 * @date Creation       12/02/2021
 * @date Modification   dd/mm/yyyy
 * @description         XC_REST_AssetList_U – util class for Rest Resourse XC_REST_AssetList
 */

public without sharing class XC_REST_AssetList_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_AssetList_U');

    
    /**
     * @description Check read params.
     * @param requestParams the request params
     * @param mapHeader the map of the headers
     * @return the wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult checkReadParams(Map<string,string> requestParams, Map<String, String> mapHeader){
        
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_Integration.validateHeader(mapHeader);
        if(resultWrapper.ErrorFlag) {
            result.errorMessage = resultWrapper.errorMessage; 
            result.errorFlag = true;
            return result;
        }

        if(String.isBlank(requestParams.get('query_id'))) {
            result.errorMessage = Label.XC_CL_MandatoryField +' query_id';
            result.errorFlag = true;
            return result;
        } 

        // Validate Query String Parameters
        Map<String, String> requiredParameters = new Map<String, String>{
                                                                        'start_date' => requestParams.get('start_date'),
                                                                        'end_date' => requestParams.get('end_date'),
                                                                        'identity_number' => requestParams.get('identity_number')
                                                                        };

        Boolean checkParams = false;
        for(String key : requiredParameters.keySet()) {
            if(String.isNotBlank(requiredParameters.get(key))) {
                checkParams = true;
            }   
        }

        result = validateParamsGET (requestParams, checkParams);
        
        
        return result;
        
    }


    /**
     * ValidateParamsGET.
     *
     * @param requestParams the request params
     * @param checkParams the boolean
     * @return the wrapper result
     * @description method to verify if query string parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateParamsGET(Map<String, String> requestParams, Boolean checkParams){

        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if(!checkParams) {
            result.errorMessage = Label.XC_CL_MandatoryField +' identity_number, start_date or end_date';
            result.errorFlag = true;
            return result;
        } 

        if(String.isBlank(requestParams.get('identity_number'))){
            if(String.isBlank(requestParams.get('start_date')) || String.isBlank(requestParams.get('end_date'))) {
                result.errorMessage = Label.XC_CL_MandatoryField +' start_date or end_date';
                result.errorFlag = true;
                return result;
            }else{
                if(!XC_UTIL_RESTInbound.checkDate(requestParams.get('start_date') + ' 00:00:00')) {
                    result.errorMessage = ('ERROR. '+ Label.XC_CL_DateFormat_Error).replace('.', '') + ' start_date';
                    result.errorFlag = true;
                    return result;
                } else if(!XC_UTIL_RESTInbound.checkDate(requestParams.get('end_date') + ' 23:59:59')) {
                  	result.errorMessage = ('ERROR. '+ Label.XC_CL_DateFormat_Error).replace('.', '') + ' end_date';
                    result.errorFlag = true;
                    return result;
                }
            }
        }

        return result;

    }

        
    /**
    * createWrapperResponse.
    *
    * @param requestParams the request params
    * @return the wrapper response get
    * @description method to create the wrapper response
    */
    public static XC_REST_AssetList_W.WrapperResponseGET createWrapperResponse(Map<String, String> requestParams) {

        XC_REST_AssetList_W.WrapperResponseGET wrRes = new XC_REST_AssetList_W.WrapperResponseGET();
        Map<String,Object> utilMap = new Map<String,Object>();
        utilMap.put('wrRes', wrRes);

        List<Asset> assetList = XC_REST_AssetList_D.getAssetListByParams(requestParams, utilMap);
        if(wrRes.Result.error_code == '400'){
            return wrRes;
        }

        if(assetList.size() > 0) {       
            wrRes.Result.message = 'Operation completed successfully';
            wrRes.Result.error_code = '0';
            utilMap.put('wrRes', wrRes);
            populateWrapperResponse(assetList, utilMap);
        }else {
            wrRes.Result.message = Label.XC_CL_AssetNotFound;
            wrRes.Result.logError = Label.XC_CL_AssetNotFound;
            wrRes.Result.error_code = '400';
        }

        return wrRes;

    }



    /**
    * populateWrapperResponse.
    *
    * @param assetList the asset list
    * @param utilMap the util map
    * @return the wrapper response get
    * @description method to populater the wrapper response 
    */
    public static void populateWrapperResponse(List<Asset> assetList, Map<String,Object> utilMap){

        XC_REST_AssetList_W.WrapperResponseGET wrRes = (XC_REST_AssetList_W.WrapperResponseGET) utilMap.get('wrRes');
        Integer queryLimit = (Integer)utilMap.get('queryLimit');

        Integer size = (queryLimit == assetList.size()) ? assetList.size() - 1 : assetList.size();
        wrRes.Asset = new List<XC_REST_AssetList_W.WrapperAsset>();

        for(Integer i = 0 ; i < size ; i++){  
            wrRes.Asset.add(populateWrFields(assetList.get(i)));
        }

        if(queryLimit == assetList.size()){
            wrRes.Offset = new XC_REST_AssetList_W.WrapperOffset();
            wrRes.Offset.next_record_id = assetList.get(assetList.size()-1).Id;
        }

    }


    /**
    * populateWrFields.
    *
    * @param asset the asset 
    * @param utilMap the util map
    * @return the asset wrapper 
    * @description method to populater the wrapper fields
    */
    public static XC_REST_AssetList_W.WrapperAsset populateWrFields(Asset ass){

		XC_REST_AssetList_W.WrapperAsset assetWr = new XC_REST_AssetList_W.WrapperAsset();
        assetWr.asset_id = ass.Id;
        assetWr.legal_entity = ass.XC_LegalEntity__c; 
        assetWr.original_sales_order = (!String.isBlank(ass.XC_Original_Creation_Order_Lookup__c)) ? ass.XC_Original_Creation_Order_Lookup__r.Name : '';
        assetWr.last_order = ass.NE__Order_Config__r.Name; 
        assetWr.external_id = ass.ExternalId__c; 
        assetWr.asset_name = ass.Name;
        assetWr.prod_id = (!String.isBlank(ass.NE__CatalogItem__c)) ? ass.NE__CatalogItem__r.NE__UsageCode__c : '';
        assetWr.status = ass.Status;
        assetWr.purchase_date = String.valueOf(ass.PurchaseDate);
        assetWr.contract_start_date = String.valueOf(ass.XC_ContractStartDate__c);
        assetWr.annual_renewal_date = String.valueOf(ass.XC_AnnualRenewalDateIndex__c);
        assetWr.contract_end_date = String.valueOf(ass.XC_ContractEndDate__c);
        assetWr.disconnection_date = String.valueOf(ass.XC_DisconnectionDate__c);
        assetWr.billing_model = ass.XC_BillingModel__c;
        assetWr.payment_method = ass.XC_PaymentMethod__c;
        assetWr.last_name = ass.Contact.LastName;
        assetWr.first_name = ass.Contact.FirstName;
        assetWr.document_number = ass.Account.IdentityNumber__c;
        assetWr.address_name = ass.XC_Address__r.Name;
        assetWr.primary_phone = ass.Contact.Phone; 
        assetWr.secondary_phone = ass.Contact.MobilePhone;
        assetWr.primary_email = ass.account.PrimaryEmail__c;
        assetWr.account_type = ass.Account.Account_Type__c;
        assetWr.evaluated_age = (String.isBlank(ass.Account.XC_Age__c)) ? 0 : Integer.valueOf(ass.Account.XC_Age__c);
        assetWr.serial_number = ass.SerialNumber;

        if(!String.isBlank(ass.XC_Address__c)){
            assetWr.street_type = (!String.isBlank(ass.XC_Address__r.XC_StreetTypeText__c)) ? ass.XC_Address__r.XC_StreetTypeText__c: ass.XC_Address__r.XC_StreetType__c;
            assetWr.address = ass.XC_Address__r.XC_Address__c;
            assetWr.street_number = ass.XC_Address__r.XC_StreetNumber__c;
            assetWr.postal_code = ass.XC_Address__r.XC_PostalCode__c;
            assetWr.city = ass.XC_Address__r.XC_City__c;
            assetWr.province = ass.XC_Address__r.XC_AddressProvince__c;
            assetWr.country = ass.XC_Address__r.XC_AddressCountry__c;
        }

        return assetWr;
    }


}