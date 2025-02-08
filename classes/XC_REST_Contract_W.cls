/**
 * The Class XC_REST_Contract_W.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 18/12/2018
 * @date Modification : 24/05/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_Contract_W – UTIL for XC_REST_Contract
 **/


public without sharing class XC_REST_Contract_W {


    /**
     * @description The Class WrapperContractRequest.
     */
    public class WrapperContractRequest {
        public XC_UTIL_Account.AccountIFWrapper wrAccount = new XC_UTIL_Account.AccountIFWrapper();
        public XC_UTIL_Address.AddressWrapper wrAddress = new XC_UTIL_Address.AddressWrapper(); 
        public XC_REST_Contract_W.WrapperAsset wrAsset;
    }
    

    /**
     * @description The Class WrapperContractResponse.
     */
    public class WrapperContractResponse {
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        public List<XC_UTIL_Contract.ContractIFWrapper> Contract;
    }


    /**
     * @description The Class WrapperAccount.
     */
    public class WrapperAccount {
        public String UniqueID;
        public String AccountID;
        public String PrimaryEmail;
        public String IdentityNumber;
        public String POS;
    }


    /**
     * @description The Class WrapperAddress.
     */
    public class WrapperAddress {
        public String AddressID;
        public String StreetType;
        public String Address;
        public String StreetNumber;
        public String ZipCode;
        public String City;
        public String Country;
    }


    /**
     * @description The Class WrapperAsset.
     */
    public class WrapperAsset {
        public String AssetID;
    }


    /**
     * @description The Class ContractSourceWrapper.
    */
    public class ContractSourceWrapper{
        public string errorMessage; 
        public boolean errorFlag;
        public WrapperContractRequest reqWr; // source of the contract
        
        /**
         * @description The Class ContractSourceWrapper constructor
        */
        public ContractSourceWrapper(){
            errorFlag = false;
            errorMessage = '';
        }
    }

}