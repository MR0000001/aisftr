/**
 * @File Name          : XC_UTIL_QueuedRequest_W.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 11-03-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_UTIL_QueuedRequest_W {

    public class WrapperRequest{

        /** The Account. */
        public XC_UTIL_Account.AccountIFWrapper Account = new XC_UTIL_Account.AccountIFWrapper();
        
        /** The Identity. */
        public List<XC_UTIL_Account.IdentityIFWrapper> Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
                
        /** The Contact. */
        public List<XC_UTIL_Account.ContactIFWrapper> Contact = new List<XC_UTIL_Account.ContactIFWrapper>();
                
        /** The Address. */
        public List<XC_UTIL_Address.AddressWrapper> Address = new List<XC_UTIL_Address.AddressWrapper>();
                
        /** The Billing profile. */
        public List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();

        /** The Order */
        public XC_UTIL_Order.OrderIFWrapper Order = new XC_UTIL_Order.OrderIFWrapper();

        /** The Opportunity */
        public XC_UTIL_Opportunity.OpportunityIFWrapper Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();

    }

}