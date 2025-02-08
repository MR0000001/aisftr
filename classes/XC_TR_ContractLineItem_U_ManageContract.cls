/**
 * @description The Class XC_TR_ContractLineItem_U_ManageContract.
 */
public without sharing class XC_TR_ContractLineItem_U_ManageContract {
    
     /**
      * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
      * @param listNew the list new
      * @param mapOld the map old
      * @param mapNew the map new
      * @description Manage the ContractLineItem method who is triggered when the field Status is changed
      */
    public static void manageContractLineItemStatusOnUpdate(List<XC_ContractLineItem__c> listNew, Map<Id,XC_ContractLineItem__c> mapOld, Map<Id,XC_ContractLineItem__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_ContractLineItem__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            checkContractLineItemStatus(listChanged);
        }
    }
    
    /**
     * @description Check contract line item status.
     * @param listNew the list new
     */
    public static void checkContractLineItemStatus(List<XC_ContractLineItem__c> listNew){
        List<id> contractLineItemIds = XC_UTIL_Sobject.getIds(listNew);
        List<XC_ContractLineItem__c> cliList = new List<XC_ContractLineItem__c>();
        if(Schema.sObjectType.XC_ContractLineItem__c.isAccessible() && Schema.sObjectType.XC_ContractLineItem__c.fields.Id.isAccessible() && Schema.sObjectType.XC_ContractLineItem__c.fields.XC_Status__c.isAccessible() && Schema.sObjectType.XC_ContractLineItem__c.fields.XC_Contract__c.isAccessible()){
            cliList = [SELECT Id, XC_Status__c,XC_Contract__c FROM XC_ContractLineItem__c WHERE Id IN: contractLineItemIds];
        }
        List<String> fatherIds = XC_UTIL_Sobject.getListFieldValues(cliList,'XC_Contract__c');
        updateStatusOnContract(fatherIds);
        
    }
    
     /**
      * @description Update status on contract.
      * @param contractsIds the contracts ids
      */
     public static void updateStatusOnContract(List<String> contractsIds){
        List<Contract> contractToUpdate = new List<Contract>();
        Map<Id,Contract> mapContracts = new Map<Id,Contract>([SELECT id, Status, (select id, XC_Status__c FROM Contract_Line_Items1__r) 
                                                     FROM Contract where id IN: contractsIds]);
         
         
         Map<Id,List<XC_ContractLineItem__c>> mapIdContractLineItem =  new Map<Id,List<XC_ContractLineItem__c>>();
         for(Id c : mapContracts.keySet()){
             mapIdContractLineItem.put(c,mapContracts.get(c).Contract_Line_Items1__r);
         }
         
         for(Id c : mapIdContractLineItem.keySet()){
             integer allCancelled = 0;
             integer allActive = 0;
             integer cliTotalItem = mapIdContractLineItem.get(c).size();
             for(XC_ContractLineItem__c cli : mapIdContractLineItem.get(c)){
                 if(cli.XC_Status__c == 'Active'){
                     allActive++;
                 }else if(cli.XC_Status__c == 'Cancelled'){
                     allCancelled++;
                 }else{
                     break; 
                 }
             }
             if(allActive == cliTotalItem){
                 mapContracts.get(c).Status = 'Active';
                 contractToUpdate.add(mapContracts.get(c));
             }else if(allCancelled == cliTotalItem){
                 mapContracts.get(c).Status = 'Cancelled';
                 contractToUpdate.add(mapContracts.get(c));
             }
         }
         
         XC_UTIL_Sobject.updateListRecords(contractToUpdate);
         
     }
    
     /**
      * Generate cont on contract.
      *
      * @author Giulio Serra giserra@deloitte.it
      * @param listNew the list new
      * @description create the contact on contract on Contract Line item
      */
    public static void generateContOnContract(List<XC_ContractLineItem__c> listNew){
       
        List<XC_ContactToContractLineItem__c> toInsert = new List<XC_ContactToContractLineItem__c>();
        Map<Id,Contract> fatherContracts = XC_TR_CLI_U_ManageContract_D.getContractFromContractLine(listNew);
        Map<Id,Opportunity> queriedOpportunity = XC_TR_CLI_U_ManageContract_D.getOpportunitiesFromContracts(fatherContracts.values());
        
		System.debug('@@@ listNew' + listNew );
        System.debug('@@@ contracts' + fatherContracts );
        System.debug('@@@ opp' + queriedOpportunity);
        
        for(XC_ContractLineItem__c line : listNew){
            
            if(shouldCreateContactsOnContract(line,fatherContracts,queriedOpportunity)){
                Contract fatherFromLine = fatherContracts.get(line.XC_Contract__c);
                toInsert.add(createNewContactOnContract(fatherFromLine,queriedOpportunity.get(fatherFromLine.Opportunity__c),line));
            }
        	
        }
        
        System.debug('@@@ final insert' + toInsert );
        XC_UTIL_SObject.insertListRecords(toInsert);
    }
    
    /**
     * @param line the line
     * @param fatherContracts the father contracts
     * @param opportunity the opportunity
     * @description Should create contacts on contract.
     * @return the boolean
     */
    @TestVisible
	private static Boolean shouldCreateContactsOnContract(XC_ContractLineItem__c line,Map<Id,Contract> fatherContracts,Map<Id,Opportunity> opportunity){
        Contract fatherFromLine = fatherContracts.get(line.XC_Contract__c);
        return fatherFromLine != null && (fatherFromLine.XC_Configurations__c != null && opportunity.get(fatherFromLine.Opportunity__c) != null);
	}
    
    /**
     * Creates the new contact on contract.
     *
     * @author Giulio Serra giserra@deloitte.it
     * @param contract the contract
     * @param opp the opp
     * @param father the father
     * @return the x C contact to contract line item c
     * @description create new contactOnContract
     */
    @TestVisible
    private static XC_ContactToContractLineItem__c createNewContactOnContract(Contract contract,Opportunity opp,XC_ContractLineItem__c father){

		XC_ContactToContractLineItem__c coc = new XC_ContactToContractLineItem__c();
        
       	coc.XC_ContractLineItemBis__c = father.id;
		coc.XC_Account__c = contract.AccountId;
		coc.XC_Contact__c = opp.XC_Contact__c;
		coc.XC_StartDate__c = Date.today();
		coc.XC_EndDate__c = contract.CNT_EndDate__c;
        coc.XC_ContactRole__c = Label.XC_CL_COC_ContractHolder;

		return coc;
	}
}