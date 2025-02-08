/**
 *
 * @author :             Riccardo Cossu ric.cossu@nttdata.it
 * @date Creation :      01/02/2019
 * @date Modification :  10/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       XC_REST_Order_Outbound – Rest Resourse for sending a Request to an external System
 */
 
public class XC_REST_Order_Outbound {
    /**
     * @description
     */
    public class WrapperResponse{
        /** The Result. */
		public XC_UTIL_Integration.Result Result  = new  XC_UTIL_Integration.Result();
        /** The Order. */
        public XC_UTIL_Order.OrderIFWrapper Order;
    } 
  
    /** 
     * @description Call to order outbound POST. 
     *
     * @param postWrapper the post wrapper
     * @return the x C RES T order out bound u. wrapper post response
     */
    // Method POST
	public static WrapperResponse callToOrderOutboundPOST(XC_REST_Order_U.WrapperPOSTRequest  postWrapper) {

		WrapperResponse responseWrapper = new WrapperResponse();        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_OrderOutbound);
        
        if(isActiveInterface.activeInterface){
			
            /* Create the request */
            String url = isActiveInterface.url;
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Create', 'createOrder', 'CommoditySpainB2C');
            String body = JSON.serialize(postWrapper);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
            System.debug('[OrderOutboundPOST] request -> ' + request);
   
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'OrderOutbound');   
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'OrderOutbound');   
            
            System.debug('[OrderOutboundPOST] response -> ' + response);
            /********************* Parse response ********************************************/
            responseWrapper = manageResponse(response);
		} else {
            responseWrapper.Result.ErrorCode = '0';
        	responseWrapper.Result.Message = Label.XC_CL_FakeResponse;
        }

        System.debug('[OrderOutboundPOST] result -> ' + responseWrapper);
		return responseWrapper; 
	}
    
    /**
     * @description Call to order outbound PUT.
     *
     * @param putWrapper the put wrapper
     * @return the x C RES T order out bound u. wrapper put response
     */
    //METHOD PUT
    public static WrapperResponse callToOrderOutboundPUT(XC_REST_Order_U.WrapperPUTRequest putWrapper){
        
        WrapperResponse responseWrapper = new WrapperResponse();        
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_OrderOutbound);    
        
        if(isActiveInterface.activeInterface){
			
            /* Create the request */
            String url = isActiveInterface.url;
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Update', 'updateOrder', 'CommoditySpainB2C');
            String body = JSON.serialize(putWrapper);

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('PUT', url, headerDefinitions, body);
            System.debug('[OrderOutboundPUT] request -> ' + request);
   
            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'OrderOutbound');   
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'OrderOutbound');   

            System.debug('[OrderOutboundPUT] response -> ' + response);     
            
            /********************* Parse response ********************************************/
            responseWrapper = manageResponse(response);
		} else {
            responseWrapper.Result.ErrorCode = '0';
        	responseWrapper.Result.Message = Label.XC_CL_FakeResponse;
        	return responseWrapper;
        }

        System.debug('[OrderOutboundPUT] result -> ' + responseWrapper);
		return responseWrapper;
    }
	
    /**
     *@description  Manage post response.
     *
     * @param response the response
     * @return the x C RES T order out bound u. wrapper post response
     */
    @testVisible
    private static WrapperResponse manageResponse(HttpResponse response) {
        WrapperResponse wrapperResult = new WrapperResponse();
        
        try{
            System.debug('[OrderOutbound] response Body -> ' + response.getBody());
        	wrapperResult = (WrapperResponse) JSON.deserialize(response.getBody(), WrapperResponse.class);
        }catch(Exception e){
            wrapperResult.Result.Message = 'INTERNAL ERROR: ' + e;
        	wrapperResult.result.ErrorCode = '500';
        }
        
        return wrapperResult;
    }

}