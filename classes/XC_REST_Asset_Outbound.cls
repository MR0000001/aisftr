/**
* @author Simone Trenta strenta@deloitte.com
* @date Creation 20/02/2019
* @date Modification 10/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description XC_REST_Asset_Outbound – Class that handles the Outbound REST for Asset object
*/ 

public with sharing class XC_REST_Asset_Outbound {

    /**
     * @description Call to get asset.
     * @param queryStringParams the map param, value
     * @return the string
     */
    public static String callToGetAsset(Map<String,String> queryStringParams) {

        XC_REST_Asset_U.WrapperListAssetResponse result = new XC_REST_Asset_U.WrapperListAssetResponse();
        XC_UTIL_RESTCallout.CSWrapper wrapper = XC_UTIL_RESTCallout.checkActiveInterface2(Label.XC_CL_AssetOutbound); 
        
        if(wrapper.activeInterface){
            String prefixUrl = wrapper.url;
            String url = XC_UTIL_RESTCallout.composeURL(prefixUrl, queryStringParams);
		
            Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound('Read', 'getAsset', 'CommoditySpainB2C');    

            /********************** Send outbound request *************************************/
            HttpRequest request = XC_UTIL_RESTCallout.newRequest('GET', url, headerDefinitions, '');
			System.debug('[AssetOutbound] request -> ' + request);

            //HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions.get('TransactionID'), 'AssetOutbound');
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'AssetOutbound');

            System.debug('[AssetOutbound] response -> ' + response);
            /********************* Parse response ********************************************/

            result = manageResponse(response);
		} else {
            result = manageResponseFake();
        }

		return JSON.serialize(result); 
    }

    /**
     * @description Manage response fake.
     * @return the x C RES T asset u. wrapper list asset response
     */
    private static XC_REST_Asset_U.WrapperListAssetResponse manageResponseFake() {
        XC_REST_Asset_U.WrapperListAssetResponse wrapper = new XC_REST_Asset_U.WrapperListAssetResponse();
        wrapper.Result.ErrorCode = '0';
        wrapper.Result.Message = Label.XC_CL_FakeResponse;
        return wrapper;
    }

    /**
     * @description Manage response.
     * @param response the response
     * @return the x C RES T asset u. wrapper list asset response
     */
    private static XC_REST_Asset_U.WrapperListAssetResponse manageResponse(HttpResponse response){
        
        XC_REST_Asset_U.WrapperListAssetResponse wrapper = new XC_REST_Asset_U.WrapperListAssetResponse();
        
        try{
            System.debug('[AssetOutbound] response Body -> ' + response.getBody());
			wrapper = (XC_REST_Asset_U.WrapperListAssetResponse)JSON.deserialize(response.getBody(), XC_REST_Asset_U.WrapperListAssetResponse.class);
        
        }catch(Exception e){

            wrapper.Result.Message = 'INTERNAL ERROR: ' + e;    
			wrapper.Result.ErrorCode = '500';
        	
        }
               
		return wrapper;
	}

}