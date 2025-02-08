/**XC_REST_SendPEC.sendRequest(req);
 * The Class XC_REST_Lead_Outbound.
 *
 * @author            : Giuseppe Di Bonito
 * @date Creation     : 12/03/2021
 * @date Modification : 
 * @description       : Lead Outbound Interface
 **/
public class XC_REST_Lead_Outbound {

    /**
     * sendRequest.
     *
     * @author Giuseppe DI Bonito
     * @param wrapper the wrapper
     * @return the Response Wrapper
     * @description Send a request for a Lead
     */
    public static XC_REST_Lead_Outbound_U.ResponseWrapper sendRequest(XC_REST_Lead_W.WrapperLeadRequest wrapper, String serverSystem){
        
        XC_REST_Lead_Outbound_U.ResponseWrapper rw = new XC_REST_Lead_Outbound_U.ResponseWrapper();

        XC_UTIL_Integration.Result checkParameters = XC_REST_Lead_Outbound_U.checkRequiredParameters(wrapper);
        if(checkParameters.ErrorCode != '0') {
            rw.Result = checkParameters;
            return rw;
        }
        XC_UTIL_RESTCallout.CSWrapper isActiveInterface = XC_UTIL_RESTCallout.checkActiveInterface2('LeadOutbound');
        if(isActiveInterface.activeInterface){
            
            try{
                String url = isActiveInterface.url;
                String body = JSON.serialize(wrapper, true);
                
                Map<String,String> headerDefinitions = XC_UTIL_RESTCallout.createHeaderOutbound((wrapper.Lead.LeadType == 'B2B') ? 'B2B' : 'B2C', 'open_charge', serverSystem);
                
                HttpRequest request = XC_UTIL_RESTCallout.newRequest('POST', url, headerDefinitions, body);
                HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(request, headerDefinitions, 'LeadOutbound');   

                System.debug('RESPONSE -> ' + response.getBody());
                rw = (XC_REST_Lead_Outbound_U.ResponseWrapper) JSON.deserialize(response.getBody(), XC_REST_Lead_Outbound_U.ResponseWrapper.class);
                
            } catch(Exception e) {
                rw.Result.ErrorCode = '400';
                rw.Result.Message = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            }
            
		} return rw;
    }
}

/* ESEMPIO DI REQUEST

XC_REST_Lead_W.WrapperLeadRequest leadWrapper = new XC_REST_Lead_W.WrapperLeadRequest();
leadWrapper.Lead.LeadType = 'Residential';
leadWrapper.Lead.LastName = 'ZINGARIELLO';
leadWrapper.Lead.FirstName = 'EMANUEL';
leadWrapper.Lead.PhonePrefix = '+39';
leadWrapper.Lead.Phone = '3933053311';
leadWrapper.Lead.PrimaryEmail = 'emanuelzingariello@yopmail.it';
leadWrapper.Lead.IdentityType = 'CF';
leadWrapper.Lead.IdentityNumber = 'ZNGMNL84C24L182B';
leadWrapper.Lead.AccountID = '0017a00001XW5MvAAL';
leadWrapper.Lead.BillingExternalID = 'a147a000006NO5uAAG';
leadWrapper.Lead.ProductName = 'Open Charge';
leadWrapper.Lead.SendToGenesys = true;
leadWrapper.Lead.ContactRequestDate = '2021-05-12';
leadWrapper.Lead.ContactRequestTimeSlot = '10-12';
leadWrapper.Lead.Stream = null;

List<XC_UTIL_Address.PoSWrapper> poss = new List<XC_UTIL_Address.PoSWrapper>();
XC_UTIL_Address.PoSWrapper pos = new XC_UTIL_Address.PoSWrapper();
pos.POS = 'IT002E0015555A';
poss.add(pos);
XC_UTIL_Address.AddressWrapper adr = new XC_UTIL_Address.AddressWrapper('REST');
leadWrapper.Lead.address = adr;
leadWrapper.Lead.address.PointOfService = poss;
XC_REST_Lead_Outbound.sendRequest(leadWrapper,'CommodityItalyB2C'); 

*/