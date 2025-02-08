/**
 * The Class XC_REST_ReadAccont.
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.it
 * @date Creation 04/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_REST_ContractToCommodity – Manage GET Rest Call ContractToCommodity Outbound
 */
public class XC_REST_ContractToCommodity {
    
    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ContractToCommodity');

    /**
     * @description The Class WrapperResult.
     */
    public class WrapperResult { 
        
        /** The Success. */
        public Boolean success = false;
        
        /** The Message. */
        public String message;
        /** The Message. */
        public String gasContractId='';
        /** The Message. */
        public String electricContractId='';
        /** The Message. */
        public String identityNumber='';
        
       
    }

    /**
     * Call to get read accont.
     *
     * @param interfaceName the interface name
     * @param wrAccount the wr account
     * @param wrAddress the wr address
     * @return the wrapper result
     * @description Central method to do a GET ReadAccont call outbound
     * @parameter interfaceName name to identify the Provider of the service
     */
    public static WrapperResult callToContractCommodity(String interfaceName, String documentNumber){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont interfaceName--->'+interfaceName);
        WrapperResult result = new WrapperResult();
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(interfaceName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ is activeInterface = '+wrapper.activeInterface);
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String method = 'GET';
            String endpointUrl = '';//setEndpointUrl(prefixUrl, wrAccount, wrAddress);
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('', '', '');
            
            headerDefinitions.remove('TransactionID');
            headerDefinitions.put('transactionid', 'test');
            headerDefinitions.put('Host', 'api-qual-local.enelx.com');   
            headerDefinitions.put('datetimemessage', '20181207103900000'); 
            headerDefinitions.put('Connection', 'keep-alive');
            HttpRequest request = XC_UTIL_RESTCallout.newRequest(method, endpointUrl, headerDefinitions, '');
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), interfaceName);
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, interfaceName);

            result = manageResponse(interfaceName, response);
        } else {
            
                result = manageFakeResponse();
            
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ callToGetReadAccont RESULT--->'+result);
        return result;
    }
    
     /**
     * @description Manage response.
     *
     * @param interfaceName the interface name
     * @param response the response
     * @return the wrapper result
     */
    @TestVisible
    private static WrapperResult manageResponse(String interfaceName, HttpResponse response){
		WrapperResult result = new WrapperResult();
       // TO DO
		return result;
	}
    
     /**
     *@description  Sets the fake result for commodity new.
     *
     * @return the wrapper result
     */
    public static WrapperResult manageFakeResponse(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'manageFakeResponse...');

        WrapperResult result = new WrapperResult();
        result.success = true;
        result.message = 'OK';
        result.gasContractId =  '';
        result.electricContractId =  '';
        Double i = math.random();
        if(i>0.4){
             result.gasContractId = '8009EgasContract';
        }else{
             result.electricContractId = '8009ElectricContract';
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@#@#@# result setFakeResultForCommodityNew = '+ result);
        return result;
    }
}