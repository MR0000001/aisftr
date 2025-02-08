/**
 * The Class XC_REST_NextBestOffer.
 *
 * @author            : Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation     : 28/12/2018
 * @date Modification : 01/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Manage NextBestOffer integration with Cloudera
 */

public class XC_REST_NextBestOffer {
    
    /**
     * The Class WrapperResponse.
     *
     * @description the wrapper response
     */
    public class WrapperResponse {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Account. */
        public XC_UTIL_Account.AccountIFWrapper Account;
        
        /** The Product. */
        public List<WrapperProduct> Product;
    }

    /**
     * The Class WrapperProduct.
     *
     * @description the wrapper product
     */
    public class WrapperProduct {
        
        /** The Product category. */
        public String ProductCategory;
        
        /** The Product. */
        public String Product;
    }

    /**
     * The Class WrapperParameter.
     *
     * @description the wrapper parameters
     */
    public class WrapperParameter {
        
        /** The Parameter name. */
        public String ParameterName;
        
        /** The Parameter value. */
        public String ParameterValue;
    }

    /**
     * The Class WrapperResult.
     *
     * @description the wrapper result
     */
    public class WrapperResult {
        
        /** The Success. */
        public Boolean Success = true;
        
        /** The Message. */
        public String Message;
        
        /** The Products. */
        public List<WrapperProduct> Products;
    }

    /**
     * Call to get next best offer.
     *
     * @param wrAccount the wr account
     * @param offerParameters the offer parameters
     * @return the wrapper result
     * @description method to get the next best offer
     */
    public static WrapperResult callToGetNextBestOffer(XC_UTIL_Account.AccountIFWrapper wrAccount, List<WrapperParameter> offerParameters){
        WrapperResult result = new WrapperResult();

        result = inputValidations(wrAccount, offerParameters);
        if(!result.success){
            return result;
        }
        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_NextBestOffer);
        if(isActiveInterface.activeInterface){
            String prefixUrl = isActiveInterface.url;
            String url = setEndpointUrl(wrAccount, offerParameters, prefixUrl);

            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'GetNextBestOffer', 'ClouderaB2C');

            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'NextBestOffer');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'NextBestOffer');


            result = manageResponse(response);
        } else {
			result = setWrapperFakeResult();
		}

        System.debug('@@@@ callToGetNextBestOffer RESULT--->'+result);
        return result;
    }


    /**
     * Sets the endpoint url.
     *
     * @param wrAccount the wr account
     * @param offerParameters the offer parameters
     * @param prefixUrl the prefix url
     * @return the string
     * @description method to set the endpoint
     */
    private static String setEndpointUrl (XC_UTIL_Account.AccountIFWrapper wrAccount, List<WrapperParameter> offerParameters, String prefixUrl){
        Map<String,String> mapParam = new Map<String,String>();

        if(wrAccount.UniqueID != null){
            mapParam.put('UniqueID', wrAccount.UniqueID);
        }
        if(wrAccount.AccountID != null){
            mapParam.put('AccountID', wrAccount.AccountID);
        }
        else if(wrAccount.PrimaryEmail != null){
            mapParam.put('PrimaryEmail', wrAccount.PrimaryEmail);
        }
        else if(wrAccount.IdentityNumber != null){
            mapParam.put('IdentityNumber', wrAccount.IdentityNumber);
        }

        if(offerParameters!=null){
            for(WrapperParameter param : offerParameters){
                mapParam.put(param.ParameterName, param.ParameterValue);
            }
        }
        
        return XC_UTIL_RESTCallout.composeURL(prefixUrl, mapParam);
    }


    /**
     * Input validations.
     *
     * @param wrAccount the wr account
     * @param offerParameters the offer parameters
     * @return the wrapper result
     * @description method to validate input parameters
     */
    private static WrapperResult inputValidations(XC_UTIL_Account.AccountIFWrapper wrAccount, List<WrapperParameter> offerParameters){
        WrapperResult result = new WrapperResult();
        if(wrAccount == null || (String.isBlank(wrAccount.AccountID) && String.isBlank(wrAccount.PrimaryEmail) && String.isBlank(wrAccount.IdentityNumber))){
            result.success = false;
            result.message = Label.XC_CL_NextBestOffer_AccountNotSpecified;
            return result;
        }
        if(offerParameters == null || offerParameters.isEmpty()){
            result.success = false;
            result.message = Label.XC_CL_NextBestOffer_ParamsNotSpecified;
            return result;
        }
        return result;
    }
   

    /**
     * Manage response.
     *
     * @param response the response
     * @return the wrapper result
     * @description method to manage response
     */
    private static WrapperResult manageResponse(HttpResponse response){
		WrapperResult result = new WrapperResult();

        System.debug('RESPONSE before deserialize -> ' + response.getBody());

        if(response == null) {
            System.debug('ERROR on callToGetNextBestOffer! -> StatusCode: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            result.success = false;
            return result;
        }

        WrapperResponse wrResp = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        if(wrResp.Result.ErrorCode == '0') {
            result = setWrapperResult(true, wrResp);
        } else {
            System.debug('ERROR on callToGetNextBestOffer! -> StatusCode: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            result = setWrapperResult(false, wrResp);
        }

		return result;
	}


	/**
	 * Sets the wrapper result.
	 *
	 * @param success the success
	 * @param wrResp the wr resp
	 * @return the wrapper result
     * @description method to set the wrapper result
	 */
	@TestVisible
    private static WrapperResult setWrapperResult(Boolean success, WrapperResponse wrResp){
        WrapperResult result = new WrapperResult();
        result.success = success;
        result.message = wrResp.Result.Message;
        if(success && wrResp.Product != null && !wrResp.Product.isEmpty()){
            result.Products = wrResp.Product;
        }
        return result;
    }


	/**
	 * Sets the wrapper fake result.
	 *
	 * @return the wrapper result
     * @description method to set the fake response
	 */
	@TestVisible
    private static WrapperResult setWrapperFakeResult(){
        WrapperResult result = new WrapperResult();
        result.success = true;
        result.message = 'OK';
        WrapperProduct pr = new WrapperProduct();
        pr.ProductCategory = 'Product Category 1';
        pr.Product = 'Category 1';
        result.Products = new List<WrapperProduct>();
        result.Products.add(pr);
        return result;
    }


}