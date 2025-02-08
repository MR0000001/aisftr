/**
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 18/12/2018
 * @date Modification : 02/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : XC_REST_Contract_DAO – DAO of XC_REST_Contract
 **/

public without sharing class XC_REST_Contract_DAO {  

    /**
     * @param wa the account wrapper
     * @return the contract from account
     * @description Method to get Contract from Account parameters
     */
    public static List<Contract> getContractFromAccount(XC_UTIL_Account.AccountIFWrapper wa){
        List<Contract> contracts = new List<Contract>();

        if(String.isNotBlank(wa.UniqueID)) { 
            
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, UniqueIdentifier__c, (SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,ContractNumber FROM Contracts) FROM Account WHERE UniqueIdentifier__c =: wa.UniqueID]);
            List<Account> accounts = accMap.values();
            if(accounts.size() > 0) {
                contracts = accounts.get(0).Contracts;
            } else {
                return new List<Contract>();
            }

        } else if(String.isNotBlank(wa.AccountID)){

            Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,ContractNumber
                                                                    FROM Contract WHERE AccountId =: wa.AccountID]);
            contracts = contractMap.values();

        }else if(String.isNotBlank(wa.PrimaryEmail)) {

            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,PrimaryEmail__c, (SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,ContractNumber FROM Contracts) FROM Account WHERE PrimaryEmail__c =: wa.PrimaryEmail]);
            List<Account> accounts = accMap.values();
            if(accounts.size() > 0) {
                contracts = accounts.get(0).Contracts;
            } else {
               return new List<Contract>();
            }

        } else if(String.isNotBlank(wa.IdentityNumber)) {

            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, (SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,ContractNumber FROM Contracts) FROM Account WHERE IdentityNumber__c =: wa.IdentityNumber]);
            List<Account> accounts = accMap.values();
            if(accounts.size() > 0) {
                contracts = accounts.get(0).Contracts;
            } else {
                return new List<Contract>();
            }
        }

        return contracts;
    }


    /**
     * Gets the contract from address.
     *
     * @param wa the wa
     * @return the contract from address
     * @description : Method to get Contract from Address parameters
     */
    public static List<Contract> getContractFromAddress(XC_UTIL_Address.AddressWrapper wa){
        List<Contract> contracts = new List<Contract>();

        Map<Id, XC_Address__c> addressMap;
        List<XC_Address__c> address;
        if(String.isNotBlank(wa.AddressID)) {
            addressMap = new Map<Id, XC_Address__c>([SELECT Id, XC_Account__c, XC_StreetType__c, XC_Address__c, XC_StreetNumber__c, XC_PostalCode__c, XC_City__c, XC_AddressCountry__c
                                                        FROM XC_Address__c 
                                                        WHERE Id =: wa.AddressID]);
        } else {
            addressMap = new Map<Id, XC_Address__c>([SELECT Id, XC_Account__c, XC_StreetType__c, XC_Address__c, XC_StreetNumber__c, XC_PostalCode__c, XC_City__c, XC_AddressCountry__c
                                                        FROM XC_Address__c 
                                                        WHERE XC_StreetType__c = :wa.StreetType AND XC_Address__c =: wa.Address AND XC_StreetNumber__c = :wa.StreetNumber AND XC_PostalCode__c = : wa.ZipCode AND XC_City__c = :wa.City AND XC_AddressCountry__c = :wa.Country]);
        }
        address = addressMap.values();
        system.debug('###############'+ address);

        if(!address.isEmpty()) {
            Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,BillingAddress
                                                                    FROM Contract WHERE AccountId =: address[0].XC_Account__c]);
            contracts = contractMap.values();
        } else {
            return new List<Contract>();
        }
        
        return contracts;
    }


    /**
     * Gets the contract from asset.
     *
     * @param assetID the asset ID
     * @return the contract from asset
     * @description : Method to get Contract from Asset ID
     */
    public static List<Contract> getContractFromAsset(String assetID){

        Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id,AccountId,StartDate,ContractTerm,CurrencyIsoCode,Status,Contract_Type__c,OwnerExpirationNotice,
                                                                (SELECT Id FROM Assets1__r WHERE Id =: assetID)
                                                                FROM Contract WHERE Id IN (SELECT XC_Contract__c FROM Asset WHERE Id =: assetID)]);
        List<Contract> contracts = contractMap.values();
        system.debug('@@@log - '+contracts+' '+assetID );
        
        if(contracts.isEmpty()) {
            return new List<Contract>();
        }
        
        return contracts;
    }
}