/**
 * @author             Luisana Rocco lrocco@deloitte.it
 * @date Creation       15/02/2021
 * @date Modification   dd/mm/yyyy
 * @description         XC_REST_AssetList_W – util wrapper class for Rest Resourse XC_REST_AssetList
 */

public without sharing class XC_REST_AssetList_W {

    /**
    * The Class WrapperResponseGET.
    *
    * @description the wrapper response for GET method
    */
    public class WrapperResponseGET {
            
        /** The Result. */
        public WrapperResult  Result = new WrapperResult();
        
        /** The Asset. */
        public List<WrapperAsset> Asset;

        /** The  Offset. */
        public WrapperOffset Offset;
    }


    /** @description Wrapper Result */
    public class WrapperResult{
        public String error_code;
        public String message;
        public String logError;
    }    

    /**
    * The Class WrapperParentAsset.
    *
    * @description the wrapper parent asset
    */

    public class WrapperAsset {

        /** The assetID. */
        public String asset_id;

        /** The legal entity. */
        public String legal_entity;

        /** The original sales order. */
        public String original_sales_order;

        /** The last order. */
        public String last_order;

        /** The external id. */
        public String external_id;

        /** The asset name. */
        public String asset_name;

        /** The prod id. */
        public String prod_id;

        /** The status. */
        public String status;

        /** The purchase date. */
        public String purchase_date;

        /** The contract start date. */
        public String contract_start_date;

        /** The annual renewal date. */
        public String annual_renewal_date;

        /** The contract end date. */
        public String contract_end_date;

        /** The disconnection date. */
        public String disconnection_date;

        /** The billing model. */
        public String billing_model;

        /** The payment method. */
        public String payment_method;

        /** The last name. */
        public String last_name;

        /** The first name. */
        public String first_name;

        /** The docuement number. */
        public String document_number;

        /** The address name. */
        public String address_name;

        /** The street type. */
        public String street_type;

        /** The address. */
        public String address;

        /** The street number. */
        public String street_number;

        /** The assetID. */
        public String postal_code;

        /** The postal code. */
        public String city;

        /** The province. */
        public String province;

        /** The country. */
        public String country;

        /** The primary phone. */
        public String primary_phone;

        /** The secondary phone. */
        public String secondary_phone;

        /** The primary email. */
        public String primary_email;

        /** The account type. */
        public String account_type;

        /** The evaluated age. */
        public Integer evaluated_age;

        /** The serial number. */
        public String serial_number;

    }

    
    /**
    * The Class WrapperOffset.
    *
    * @description the wrapper Offset 
    */

    public class WrapperOffset {

        /** The next record id. */
        public String next_record_id;
    }


}