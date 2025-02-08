/**
 * The Class XC_REST_Account_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_REST_Account_U – Util for Rest Resourse to Create/Update Account
 * 
 */


public without sharing class XC_REST_Account_W {


    /**
     * The Class WrapperRequest.
     *
     * @description the wrapper request
     */
    public class WrapperRequest {
            
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
    }


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
        
        /** The Contact. */
        public List<XC_UTIL_Account.ContactIFWrapper> Contact;
        
        /** The Address. */
        public List<XC_UTIL_Address.AddressWrapper> Address;
        
        /** The Billing profile. */
        public List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> BillingProfile;
        
        /** The Interaction. */
        public List<XC_UTIL_Account.InteractionWrapper> Interaction;

        /** The Identity. */
        public List<XC_UTIL_Account.IdentityIFWrapper> Identity;
    }
    

    /**
     * The Class WrapperResponseGET.
     *
     * @description the wrapper response for GET method
     */
    public class WrapperResponseGET {
            
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
        
        /** The Account. */
        public List<XC_UTIL_Account.AccountIFWrapper> Account;
    }
}