/**
 * The Class XC_REST_Case_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util class for handling Case REST
 **/

    
public without sharing class XC_REST_Case_W {


    /**
     * The Class WrapperCaseRequest.
     *
     * @description wrapper request of REST call
     */
    public class WrapperCaseRequest {
        
        /** The Case X. */
        public XC_UTIL_Case.CaseRESTWrapper CaseX;

        /**
         * WrapperCaseRequest.
         *
         * @param caseX the case X
         * @description instantiates a new wrapper case request
         */
        public WrapperCaseRequest(XC_UTIL_Case.CaseRESTWrapper caseX) {
            this.CaseX = caseX;
        }
    }
    

    /**
     * The Class WrapperCaseResponseGET.
     *
     * @description wrapper request of GET REST call
     */
    public class WrapperCaseResponseGET {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The Case list. */
        public List<XC_UTIL_Case.CaseRESTWrapper> CaseList;
        
        /** @description XC_UTIL_IntegrationLog to insert **/
        public List<XC_Integration_Log__c> integrationLog;
    }


    /**
     * The Class WrapperCaseResponseUPSERT.
     *
     * @description wrapper response of POST/PUT REST call
     */
    public class WrapperCaseResponseUPSERT {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        
        /** The Case item. */
        public XC_UTIL_Case.CaseRESTWrapper CaseItem;
    }

    /**
     * The Class WrapperAccount.
     *
     * @description wrapper account
     */
    public class WrapperAccount{
        
        /** The Unique ID. */
        public String UniqueID;
        
        /** The Account ID. */
        public String AccountID;
        
        /** The Primary email. */
        public String PrimaryEmail;
        
        /** The Identity number. */
        public String IdentityNumber;
        
        /** The Start date of case. */
        public String StartDateOfCase;
        
        /** The End date of case. */ 
        public String EndDateOfCase;

        /** The Origin of case. */
        public String Origin;
        /**
         * WrapperAccount.
         *
         * @description instantiates a new wrapper account.
         */
        public WrapperAccount() {
            XC_UTIL_Debug.debug(true, 'WrapperAccount Constructor');
        }

        /**
         * WrapperAccount.
         *
         * @param acc the acc
         * @description instantiates a new wrapper account
         */
        public WrapperAccount(Account acc) {
            this.UniqueID = '';
            this.AccountID = acc.Id;
            this.PrimaryEmail = acc.PrimaryEmail__c;
        }
    }


    /**
     * The Class WrapperContact.
     *
     * @description wrapper contact
     */
    public class WrapperContact {
        
        /** The Unique ID. */
        public String UniqueID;
        
        /** The Contact ID. */
        public String ContactID;
        
        /** The Account ID. */
        public String AccountID;
        
        /** The Email. */
        public String Email;
        
        /** The Identity number. */
        public String IdentityNumber;
        
        /** The Start date of case. */
        public String StartDateOfCase;
        
        /** The End date of case. */
        public String EndDateOfCase;
        
        /** The Origin of case. */
        public String Origin;

        /**
         * WrapperContact.
         *
         * @description instantiates a new wrapper contact.
         */
        public WrapperContact() {
            XC_UTIL_Debug.debug(true, 'WrapperContact Constructor');
        }
        
        /**
         * WrapperContact.
         *
         * @param con the contact
         * @description instantiates a new wrapper contact
         */
        public WrapperContact(Contact con) {
            this.ContactID = con.Id;
            this.AccountID = con.AccountId;
            this.Email = con.Email;
        }
    }


    /**
     * Create Account Wrapper.
     *
     * @param mapParameters the map parameters
     * @return the account wrapper
     * @description method to create the Account wrapper
     */
    public static XC_REST_Case_W.WrapperAccount createAccountWrapper(Map<String, String> mapParameters) {

        XC_REST_Case_W.WrapperAccount wrapper = new XC_REST_Case_W.WrapperAccount();

        wrapper.UniqueID = mapParameters.get('UniqueID');
        wrapper.PrimaryEmail = mapParameters.get('PrimaryEmail');
        wrapper.AccountID = mapParameters.get('AccountID');
        wrapper.IdentityNumber = mapParameters.get('IdentityNumberAccount');
        wrapper.StartDateOfCase = mapParameters.get('StartDate') + ' 00:00:00.000';
        wrapper.EndDateOfCase = mapParameters.get('EndDate') + ' 23:59:59.000';
        wrapper.Origin = mapParameters.get('Channel')=='App eMobility' ? Label.XC_CL_Case_Origin_AppEmobility : mapParameters.get('Channel') ;
        System.debug('@@@ ' + wrapper);
        return wrapper;
    }


    /**
     * Create Contact Wrapper.
     *
     * @param mapParameters the map parameters
     * @return the contact wrapper
     * @description method to create the Contact wrapper
     */
    public static XC_REST_Case_W.WrapperContact createContactWrapper(Map<String, String> mapParameters) {
        
        XC_REST_Case_W.WrapperContact wrapper = new XC_REST_Case_W.WrapperContact();

        wrapper.ContactID = mapParameters.get('ContactID');
        wrapper.Email = mapParameters.get('Email');
        wrapper.IdentityNumber = mapParameters.get('IdentityNumberContact');
        wrapper.StartDateOfCase = mapParameters.get('StartDate') + ' 00:00:00';
        wrapper.EndDateOfCase = mapParameters.get('EndDate') + ' 23:59:59';
        wrapper.Origin = mapParameters.get('Channel')=='App eMobility' ? Label.XC_CL_Case_Origin_AppEmobility : mapParameters.get('Channel') ;
        System.debug('@@@ ' + wrapper);
        return wrapper;
    }


    /**
     * Create Case Wrapper.
     *
     * @param mapParameters the map parameters
     * @return the case wrapper
     * @description method to create the Case wrapper
     */
    public static XC_UTIL_Case.CaseRESTWrapper createCaseWrapper(Map<String, String> mapParameters) {
        
        XC_UTIL_Case.CaseRESTWrapper wrapper = new XC_UTIL_Case.CaseRESTWrapper();

        wrapper.CaseID = mapParameters.get('CaseID');
        wrapper.CaseNumber = mapParameters.get('CaseNumber');

        System.debug('@@@ ' + wrapper);
        return wrapper;
    }
}