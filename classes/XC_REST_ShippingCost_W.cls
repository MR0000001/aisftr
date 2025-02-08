/**
 * The Class XC_REST_ShippingCost.
 *
 * @author            : Gklaras Dionysios dgklaras@deloitte.gr
 * @date Creation     : 14/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for ShippingCost
 */
public with sharing class XC_REST_ShippingCost_W {
    
    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {

        /** The Address. */
        public WrapperAddress Address = new  WrapperAddress();
       
    }

    /**
     * The Class WrapperAddress.
     *
     * @description the wrapper Address
     */
    public class WrapperAddress {

        public String StreetType;

        public String Address;
        
        public String StreetNumber;
        
        public String ZipCode;
        
        public String City;
        
        public String Country ;
        
        public String Stair;
        
        public String Floor;
        
        public String Door;
        
        public String Province;
        
        public String MunicipalCode;
        
        public String MunicipalName;
        
        public String StreetCode;
        
        public String Municipality;
        
        public String Region;

    }
        
    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {

        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();

        public WrapperShippingCostArea ShippingCostArea;
       
    }
    
    /**
     * The Class ShippingCostArea.
     *
     * @description the wrapper ShippingCostArea
     */
    public class WrapperShippingCostArea {

        public String ShippingCostArea;
       
    }
}