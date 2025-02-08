/**
 * @description The Class XC_REST_Product_U.
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation 07/10/2019 
 * @description REST Utility Class for Product Interface
 */ 
public with sharing class XC_REST_Product_U {

    /**
     * @description wrapper class for Post request
     */
    public class RequestWrapper {

        public CheckAvailabilityWrapper check_availability;
        public List<ProductWrapper> product;
    }

    /**
     * @description wrapper class for Post response
     */
    public class ResponseWrapper {

        public XC_UTIL_Integration.ResultSnakeCase result; 
        public List<ProductWrapper> product;
        
        /**
        * @description constructor
        */
        public ResponseWrapper(){
            this.result = new XC_UTIL_Integration.ResultSnakeCase();
        }
    }

    /**
     * @description wrapper class 
     */
    public class CheckAvailabilityWrapper {

        public String customer_zip_code;
        public String address_id;
        public String country;
        public String partner_id;

    }

    /**
     * @description wrapper class 
     */
    public class ProductWrapper {

        public String product_id;
        public Integer quantity;
        public String request_type;
        public Date product_availability_date;

    }

    private static RequestWrapper urlToWrapper(Map<String, String> params){
        RequestWrapper wrResp = new RequestWrapper();

        CheckAvailabilityWrapper caWr = new CheckAvailabilityWrapper();
        caWr.customer_zip_code = params.get('customer_zip_code');
        caWr.address_id = params.get('address_id');
        caWr.country = params.get('country');
        caWr.partner_id = params.get('partner_id');

        wrResp.check_availability = caWr;

        List<String> prodIdList = params.get('product_id').split('-');
        List<String> quantityList = params.get('quantity').split('-');
        List<String> reqTypeList = params.get('request_type').split('-');

        List<ProductWrapper> product = new List<ProductWrapper>();
        for(Integer i=0; i<prodIdList.size(); i++){
            ProductWrapper p = new ProductWrapper();
            p.product_id = prodIdList[i];
            p.quantity = Integer.valueOf(quantityList[i]);
            p.product_id = prodIdList[i];
            product.add(p);
        }

        wrResp.product = product;
        return wrResp;
    }


    /**
    * @description validate request
    * @param params the wrapper request 
    * @param header the header
    * @return the wrapper result
    */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> params, Map<String, String> header){
        XC_UTIL_Integration.WrapperResult result = XC_UTIL_Integration.validateHeader(header);
        if(result.errorFlag) {
            return result; 
        }

        result = XC_UTIL_RESTInbound.checkObjectPermission('NE__Product__c', 'read');
        if(result.errorFlag){
            return result; 
        } 

        List<String> mandatoryFields = new List<String>{
            'country',
            'product_id',
            'quantity',
            'request_type'
        };
        for(String s : mandatoryFields){
            if(String.isBlank(params.get(s))){
                result.errorFlag = true;
                result.errorMessage = 'ERROR. Missing mandatory field: '+s;
                return result;
            }
        }

        if(String.isBlank(params.get('customer_zip_code'))&&String.isBlank(params.get('address_id'))){
            result.errorFlag = true;
            result.errorMessage = 'ERROR. Missing one of this fields: customer_zip_code, address_id';
            return result;
        }

        List<String> prodIdList = params.get('product_id').split('-');
        List<String> quantityList = params.get('quantity').split('-');
        List<String> reqTypeList = params.get('request_type').split('-');
        if(prodIdList.size()!=quantityList.size()||prodIdList.size()!=reqTypeList.size()){
            result.errorFlag = true;
            result.errorMessage = 'ERROR. Not same number of product_id, quantity, request_type sended';
            return result;
        }
       
        return result;
    }

    
    /**
    * @description get product availability
    * @param params the wrapper
    * @return the wrapper result
    */
    public static List<ProductWrapper> getProductFromGlovia(Map<String, String> params){
        List<ProductWrapper> result = new List<ProductWrapper>();

        RequestWrapper wrReq = urlToWrapper(params);

        Map<String, Date> resMap = XC_UTIL_Glovia.checkAvailabilityShipment(wrReq);

        for(ProductWrapper pw : wrReq.product){
            ProductWrapper p = new ProductWrapper();
            p.product_id = pw.product_id;
            p.product_availability_date = resMap.get(pw.product_id);
            p.request_type = pw.request_type;
            result.add(p);
        }

        return result;
    }


}