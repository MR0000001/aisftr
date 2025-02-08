/**
 * The Class XC_REST_Lead_Outbound_U.
 *
 * @author            : Giuseppe Di Bonito
 * @date Creation     : 12/03/2021
 * @date Modification : 
 * @description       : Util for XC_REST_Lead_Outbound
 **/
public class XC_REST_Lead_Outbound_U {

    /**
     * The Class ResponseWrapper.
     *
     * @description the wrapper response
     */
    public class ResponseWrapper{
        
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();     
    }
         
    /**
     * Check required parameters.
     *
     * @param wrapper the wrapper
     * @return the XC_UTIL_Integration.ResultSnakeCase
     * @description check Required Parameters
     */
    public static XC_UTIL_Integration.Result checkRequiredParameters(XC_REST_Lead_W.WrapperLeadRequest leadWrapper) {
        XC_UTIL_Integration.Result response = new XC_UTIL_Integration.Result();

        if(leadWrapper == null){
            response.Message = Label.XC_CL_MandatoryField+' Lead';
            response.ErrorCode = '400';
            return response;
        }

        Map<String, String> requiredParameters = new Map<String, String>{
            'LeadType' => leadWrapper.Lead.LeadType,
            'LastName' => leadWrapper.Lead.LastName,
            'FirstName' => leadWrapper.Lead.FirstName,
            //'PhonePrefix' => leadWrapper.Lead.PhonePrefix,
            //'Phone' => leadWrapper.Lead.Phone,
            //'PrimaryEmail' => leadWrapper.Lead.PrimaryEmail,
            'IdentityType' => leadWrapper.Lead.IdentityType,
            'IdentityNumber' => leadWrapper.Lead.IdentityNumber,
            'AccountID' => leadWrapper.Lead.AccountID,
            'BillingExternalID' => leadWrapper.Lead.BillingExternalID,
            'ProductName' => leadWrapper.Lead.ProductName,
            'RequestDate' => leadWrapper.Lead.RequestDate
            //'OrderID' => leadWrapper.Lead.OrderID,
            //'ProductID' => leadWrapper.Lead.ProductID
            };
                
        for(String key : requiredParameters.keySet()) {
            if(String.isBlank(requiredParameters.get(key))) {
                response.Message = Label.XC_CL_MandatoryField +'lead.' + key;
                response.ErrorCode = '400';
                return response;
            }
        }
        
        if(leadWrapper.Lead.LeadType == 'Small Business' && String.isBlank(leadWrapper.Lead.BusinessName)) {
	        response.Message = Label.XC_CL_MandatoryField +'lead.BusinessName';
            response.ErrorCode = '400';
            return response;
        }
        
        if(leadWrapper.Lead.SendToGenesys == true && (String.isBlank(leadWrapper.Lead.ContactRequestDate) || (String.isBlank(leadWrapper.Lead.ContactRequestTimeSlot)))) {
	        response.Message = Label.XC_CL_MandatoryField +'lead.ContactRequestDate or lead.ContactRequestTimeSlot';
            response.ErrorCode = '400';
            return response;
        }  
                                            
        if(leadWrapper.Lead.Address == null || leadWrapper.Lead.Address.PointOfService.isEmpty() || String.isBlank(leadWrapper.Lead.Address.PointOfService[0].POS)) {
	        response.Message = Label.XC_CL_MandatoryField +'lead.Address.PointOfDelivery.POS';
            response.ErrorCode = '400';
            return response;
        }                                         
        
        response.ErrorCode = '0';
        return response;
    }
}