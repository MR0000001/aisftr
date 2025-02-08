/**
 * The Class XC_REST_Contract_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 18/12/2018
 * @date Modification : 29/05/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_Contract_U – UTIL for XC_REST_Contract
 **/


public without sharing class XC_REST_Contract_U {


    /**
     * Manage Get Case.
     *
     * @param params the request params map
     * @param wrResp The wrapper response
     * @description method to manage the get contract
     */
    public static void manageGetContract(Map<String, String> params, XC_REST_Contract_W.WrapperContractResponse wrResp) {

        wrResp.Contract = new List<XC_UTIL_Contract.ContractIFWrapper>();

        List<XC_UTIL_Contract.ContractIFWrapper> queriedWrapper = new List<XC_UTIL_Contract.ContractIFWrapper>();
        if (String.isNotBlank(params.get('AccountID')) || String.isNotBlank(params.get('PrimaryEmail')) || String.isNotBlank(params.get('IdentityNumber')) || String.isNotBlank(params.get('POS'))){
            
            XC_UTIL_Account.AccountIFWrapper accountWrapper = new XC_UTIL_Account.AccountIFWrapper();
            accountWrapper.AccountID = params.get('AccountID');
            accountWrapper.PrimaryEmail = params.get('PrimaryEmail');
            accountWrapper.IdentityNumber = params.get('IdentityNumber');
            accountWrapper.POS =  params.get('POS');

  
            List<Contract> contracts = XC_REST_Contract_D.getContractFromAccount(accountWrapper);
            System.debug('Contract -> ' + contracts);
            if(!contracts.isEmpty()) {
                Map<Id,String> accAdd = XC_REST_Contract_D.getAddressByAccount(contracts);
                queriedWrapper = wrappersFromContracts(contracts, accAdd);
                System.debug('queriedWrapper -> ' + queriedWrapper);
            }
            
        } else {
            queriedWrapper = manageGetContractPlus(params, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return;
            }
        }

        XC_REST_Contract_U.populateresponse(queriedWrapper, wrResp);
    }


    /**
     * ManageGetContractPlus.
     *
     * @param params the request params map
     * @param wrResp The wrapper response
     * @return the contract wrapper list
     * @description method to manage the get contract
     */
    public static List<XC_UTIL_Contract.ContractIFWrapper> manageGetContractPlus(Map<String, String> params, XC_REST_Contract_W.WrapperContractResponse wrResp) {

        List<XC_UTIL_Contract.ContractIFWrapper> queriedWrapper = new List<XC_UTIL_Contract.ContractIFWrapper>();

        if(String.isNotBlank(params.get('AssetID'))) {
            
            List<Contract> contracts = XC_REST_Contract_D.getContractFromAsset(params.get('AssetID'));
            if(!contracts.isEmpty()) {
                Map<Id,String> accAdd = XC_REST_Contract_D.getAddressByAccount(contracts);
                queriedWrapper = wrappersFromContracts(contracts, accAdd);
            }
            
        } else if(String.isNotBlank(params.get('AddressID'))) {

            XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
            addrWrapper.AddressID = params.get('AddressID');

            List<Contract> contracts = XC_REST_Contract_D.getContractFromAddress(addrWrapper);
            if(!contracts.isEmpty()) {
                Map<Id,String> accAdd = XC_REST_Contract_D.getAddressByAccount(contracts);
                queriedWrapper = wrappersFromContracts(contracts, accAdd);
            }
        
        } else if (checkAddressParameters(params)) {
            
            checkAddress(params, wrResp);
            if(wrResp.Result.ErrorCode != '0') {
                return new List<XC_UTIL_Contract.ContractIFWrapper>();
            }

            XC_UTIL_Address.AddressWrapper addrWrapper = new XC_UTIL_Address.AddressWrapper();
            addrWrapper.StreetType = params.get('StreetType');
            addrWrapper.Address = params.get('Address');
            addrWrapper.StreetNumber = params.get('StreetNumber');
            addrWrapper.ZipCode = params.get('ZipCode');
            addrWrapper.City = params.get('City');
            addrWrapper.Country = params.get('Country');

            List<Contract> contracts = XC_REST_Contract_D.getContractFromAddress(addrWrapper);
            if(!contracts.isEmpty()) {
                Map<Id,String> accAdd = XC_REST_Contract_D.getAddressByAccount(contracts);
                queriedWrapper = wrappersFromContracts(contracts, accAdd);
            }
            
        } else {
            wrResp.Result.Message = Label.XC_CL_NoKey;
            wrResp.Result.ErrorCode = '400';
            return new List<XC_UTIL_Contract.ContractIFWrapper>();
        }

        wrResp.Result.ErrorCode = '0';
        return queriedWrapper;
    }


    /**
     * CheckAddressParameters.
     *
     * @param params the parameters map
     * @description check if there is an Address parameter
     */ 
    public static Boolean checkAddressParameters(Map<String, String> params) {

        if(String.isNotBlank(params.get('StreetType')) || String.isNotBlank(params.get('Address')) || String.isNotBlank(params.get('StreetNumber')) || 
            String.isNotBlank(params.get('ZipCode')) || String.isNotBlank(params.get('City')) || String.isNotBlank(params.get('Country'))) {
                return true;
        }

        return false;
    }


    /**
     * CheckAddress.
     *
     * @param params the parameters map
     * @param wrResp the wrapper response
     * @description check if an address is valid
     */ 
    public static void checkAddress(Map<String, String> params, XC_REST_Contract_W.WrapperContractResponse wrResp) {

        if(String.isBlank(params.get('StreetType'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'StreetType';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(String.isBlank(params.get('Address'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'Address';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(String.isBlank(params.get('StreetNumber'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'StreetNumber';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(String.isBlank(params.get('ZipCode'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'ZipCode';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        if(String.isBlank(params.get('City'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'City';
            wrResp.Result.ErrorCode = '400';
            return;
        }
        
        if(String.isBlank(params.get('Country'))) {
            wrResp.Result.Message = Label.XC_CL_MandatoryField + 'Country';
            wrResp.Result.ErrorCode = '400';
            return;
        }

        wrResp.Result.ErrorCode = '0';
        return;
    }


    /**
     * PopulateResponse.
     *
     * @param listContract list of ContactIFWrapper
     * @param wrResp the response wrapper
     * @description populate the contract response
     */ 
    public static void populateResponse(List<XC_UTIL_Contract.ContractIFWrapper> listContract, XC_REST_Contract_W.WrapperContractResponse wrResp) {

        if(listContract.size() > 0) {
            wrResp.Result.ErrorCode = '0';
            wrResp.Result.Message = 'Operation completed successfully';
            wrResp.Contract = listContract;
        } else {
            wrResp.Result.ErrorCode = '400';
            wrResp.Result.Message = Label.XC_CL_NoContract;
            wrResp.Contract = new List<XC_UTIL_Contract.ContractIFWrapper>();
            return;
        }
    }


    /**
     * WrappersFromContracts.
     *
     * @param contracts the list of contract
     * @return the List<XC_UTIL_Contract.ContractIFWrapper>
     * @description generate wrappers from a list of contracts
     */ 
    private static List<XC_UTIL_Contract.ContractIFWrapper> wrappersFromContracts(List<Contract> contracts, map<Id,String> accountAddress){

        List<XC_UTIL_Contract.ContractIFWrapper> wrappers = new List<XC_UTIL_Contract.ContractIFWrapper>();

        for(Contract contract : contracts){

            XC_UTIL_Contract.ContractIFWrapper wrapper = new XC_UTIL_Contract.ContractIFWrapper();
            
            wrapper.AccountID = contract.AccountID;
            wrapper.ContractStartDate = contract.StartDate;
            wrapper.ContractTerm = contract.ContractTerm;
            wrapper.Currency_x = contract.CurrencyIsoCode;
            wrapper.Status = contract.Status;
            wrapper.ContractType = contract.Contract_Type__c;
            wrapper.OwnerExpirationNotice = contract.OwnerExpirationNotice;  
            wrapper.ContractNumber = contract.ContractNumber;

            /*public String AssetID;
            public String AddressID;*/

            if(accountAddress!=null){
                wrapper.AddressID = accountAddress.get(contract.AccountID);
            }
            
            wrappers.add(wrapper);
        }   
        return wrappers;
    }

}