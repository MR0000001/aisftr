/**
 * The Class XC_TR_CLI_U_ManageContract_D.
 *
 * @author Giulio Serra - giserra@deloitte.it
 * @date Creation 29/08/2018
 * @date Modification dd/mm/yyyy
 * @description XXC_TR_CLI_U_ManageContract_D DAO for class XC_TR_ContractLineItem_U_ManageContract
 */
public without sharing class XC_TR_CLI_U_ManageContract_D {
	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CLI_U_ManageContract_D');
     /**
      * @description Gets the opportunities from contracts.
      * @param contracts the contracts
      * @return the opportunities from contracts
      */
     public static Map<Id,Opportunity> getOpportunitiesFromContracts(List<Contract> contracts){
        Set<String> opportunityToQuery = new Set<String>(XC_UTIL_Sobject.getListFieldValues(contracts,'Opportunity__c'));
        return new Map<Id,Opportunity>([SELECT Id, XC_Contact__c FROM Opportunity WHERE Id =:opportunityToQuery]); 
    }
    
    /**
     * @description Gets the contract from contract line.
     * @param lines the lines
     * @return the contract from contract line
     */
    public static Map<Id,Contract> getContractFromContractLine(List<XC_ContractLineItem__c> lines){
        Set<String> contractToQuery = new Set<String>(XC_UTIL_Sobject.getListFieldValues(lines,'XC_Contract__c'));
        return new Map<Id,Contract>([SELECT Id,AccountId,Opportunity__c,CNT_EndDate__c,XC_Configurations__c FROM Contract 
                                     WHERE Id =: contractToQuery]); 
    }
    
    /**
     * @description Gets the asset from contract line item.
     * @param lines the lines
     * @return the asset from contract line item
     */
    public static Map<Id,Asset> getAssetFromContractLineItem(List<XC_ContractLineItem__c> lines){
         Set<String> assetToQuery = new Set<String>(XC_UTIL_Sobject.getListFieldValues(lines,'XC_Asset__c'));
        return new Map<Id,Asset>([SELECT id,NE__Bundle_Configuration__c,NE__Root_Order_Item__c FROM Asset WHERE Id =: assetToQuery]);
    }
    
     
}