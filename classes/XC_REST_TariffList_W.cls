/**
 * The Class XC_REST_TariffList_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 29/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for Rest Resource for GetTariffList
 **/


public without sharing class XC_REST_TariffList_W {

    /**
     * @description The Class WrapperRequest.
     */
    public class WrapperRequest {
        
        /** 
        * @description The request element.
        */
        public requestElementWrapper requestElement;
    }
    

    /**
     * @description The Class requestElementWrapper.
     */
    public class requestElementWrapper {
        
        /**
        * @description The Country. 
        */
        public String Country;
        
        /** 
        * @description The Families. 
        */
        public List<String> Families;
        
        /**
        * @description The Preferred language. 
        */
        public String PreferredLanguage;
    }
    

    /**
     * @description The Class WrapperResponse.
     */
    public class WrapperResponse {
        
        /** The Result description. */
        public String ResultDescription;
        
        /** The Result code. */
        public String ResultCode;
        
        /** The Result. */
        public String Result;
        
        /** The Enabled rates list. */
        public List<EnabledListWrapper> EnabledRatesList;
    }

    
    /**
     * @description The Class EnabledListWrapper.
     */
    public class EnabledListWrapper {
        
        /** The Rate zuora id. */
        public String RateZuoraId;
        
        /** The Rate UOM. */
        public String RateUOM;
        
        /** The Rate short description. */
        public String RateShortDescription;
        
        /** The Rate quantity. */
        public Integer RateQuantity;
        
        /** The Rate price. */
        public String RatePrice;

        /** The Rate one time price. */
        public String RateOneTimePrice;
        
        /** The Rate name. */
        public String RateName;
        
        /** The Rate engine code. */
        public String RateEngineCode;
        
        /** The Rate end date. */
        public String RateEndDate;
        
        /** The Rate description. */
        public String RateDescription;
        
        /** The Rate billing period. */
        public String RateBillingPeriod;
        
        /** The Families. */
        public List<String> Families;

        /**
        * @description Currency. 
        */
        public String CurrencyX; 
    }
    

    /**
     * Validate Request.
     *
     * @param mapHeader the map header
     * @param wrReq the wr req
     * @return the wrapper result
     * @description method to validate request
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, WrapperRequest wrReq) {
        XC_UTIL_Integration.WrapperResult result;

        result = XC_UTIL_RESTInbound.checkObjectPermission('NE__Catalog_Item__c', 'read');
        if(result.errorFlag) {
            return result;
        }

        result = XC_UTIL_Integration.validateHeader(mapHeader);
        if(result.errorFlag) {
            return result;
        }
            
        if(mapHeader.get('Functionality') != 'ViewActivableOffers') {
            result.errorMessage = 'Wrong Functionality value';
            result.errorFlag = true;
            return result;
        }

        if(wrReq.requestElement == null ){
            result.errorMessage = 'Missing mandatory field: requestElement';
            result.errorFlag = true;
            return result;
        }
        
        if(String.isBlank(wrReq.requestElement.Country)) { 
            result.errorMessage = 'Missing mandatory field: requestElement.Country';  
            result.errorFlag = true;
            return result;
        }
        
        if(wrReq.requestElement.Families == null || wrReq.requestElement.Families.size() == 0) {
            result.errorMessage = 'Missing mandatory field: requestElement.Families';
            result.errorFlag = true;
            return result;
        }
        
        if(String.isBlank(wrReq.requestElement.PreferredLanguage)) {
            result.errorMessage = 'Missing mandatory field: requestElement.PreferredLanguage';
            result.errorFlag = true;
            return result;
        }
        
        return result;
    }  

}