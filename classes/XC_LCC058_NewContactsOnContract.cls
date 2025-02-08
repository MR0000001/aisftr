/**
* @author Monica Cutillo monicaa.cutillo@nttdata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
* @date Creation 12/12/2018
* @date Modification dd/mm/yyyy
* @description XC_LCC058_NewContactsOnContract – Override the standard New Action on ContactsOnContract custom object
*/

public with sharing class XC_LCC058_NewContactsOnContract {
    
	/**
	 * @description Retrive data.
	 *
	 * @param recordId the record id
	 * @return the string
	 */
	@AuraEnabled
    public static String retriveData(String recordId){
        Map<Id,XC_ContractLineItem__c> cliMap = new Map<Id,XC_ContractLineItem__c>([SELECT id, XC_Contract__c 
                        FROM XC_ContractLineItem__c WHERE Id=: recordId limit 1]);

        List<XC_ContractLineItem__c> cli = cliMap.values();


        if(!cli.isEmpty() && cli[0].XC_Contract__c!=null){
            return retriveContractData(cli[0].XC_Contract__c,recordId);
        }
        return '';
    }    
    

    /**
     * @description Retrive contract data.
     *
     * @param contractId the contract id
     * @param contractLineItemId the contract line item id
     * @return the string
     */
    @AuraEnabled
    public static String retriveContractData(String contractId, String contractLineItemId){
        
     
        Map<Id,Contract> contractsMap = new Map<Id,Contract>([SELECT id, AccountId, Opportunity__r.Id, Opportunity__r.XC_Contact__c, EndDate 
                                    from Contract where id =: contractId]);

        List<Contract> contracts = contractsMap.values();

        Map<String,Object> mapResult = new Map<String,Object>();
        if(!contracts.isEmpty()){
            mapResult.put('accountId',contracts[0].AccountId);
            mapResult.put('contractId',contractLineItemId);
            mapResult.put('startDate', Date.today());
            
            mapResult.put('endDate', contracts[0].EndDate);
            
            mapResult.put('contractRole', retriveRolePicklistValues());
            mapResult.put('contactList', retriveContactsNotRelated(contractLineItemId, contracts[0].AccountId));
        }
        System.debug('retriveContractData mapResult='+mapResult);
        return JSON.serialize(mapResult);
    }

    /**
     * @description Creates the contacts on contract.
     *
     * @param stringValues the string values
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createContactsOnContract(String stringValues){
        Map<String,Object> valuesMap = (Map<String, Object>) JSON.deserializeUntyped(stringValues);

        XC_ContactToContractLineItem__c newCoc = new XC_ContactToContractLineItem__c();
        newCoc.XC_Account__c = (String)valuesMap.get('accountId');
        newCoc.XC_ContractLineItemBis__c = (String)valuesMap.get('contractId');
         if(valuesMap.get('startDate')!=null){
        newCoc.XC_StartDate__c = Date.valueOf((String)(valuesMap.get('startDate')));
         }
        if(valuesMap.get('endDate')!=null){
        newCoc.XC_EndDate__c = Date.valueOf((String)(valuesMap.get('endDate')));
        }
        newCoc.XC_ContactRole__c = (String)valuesMap.get('roleValue');
        newCoc.XC_Contact__c = (String)valuesMap.get('contactValue');

        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(newCoc);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper(result);
        System.debug('@@@@ createContactsOnContract result:'+rw);
        return rw;
    }

    /**
     * @description Retrive role picklist values.
     *
     * @return the list
     */
    private static List<Map<String,String>> retriveRolePicklistValues(){
        List<Map<String,String>> result = new List<Map<String,String>>(); 
        List<Schema.PicklistEntry> listPicklistValues = XC_UTIL_Sobject.retrieveAllPicklistValues('XC_ContactToContractLineItem__c', 'XC_ContactRole__c');
        for(Schema.PicklistEntry pval : listPicklistValues){
            Map<String,String> row = new Map<String,String>();
            row.put('key', pval.getValue());
            row.put('value', pval.getLabel());
            result.add(row);  
        }
        return result;
    }
	
    /**
     * @description Retrive contacts not related.
     *
     * @param contractLineItemId the contract line item id
     * @param accountId the account id
     * @return the list
     */
    //TODO Eliminare dalla picklist i contact che hanno già un record in XC_ContactToContractLineItem__c con stesso XC_ContractLineItemBis__c(recordId di pagina) 
    private static List<Map<String,String>> retriveContactsNotRelated(String contractLineItemId, String accountId){
        System.debug('entrato in retriveContactsNotRelated con id '+contractLineItemId);
        List<Map<String,String>> result = new List<Map<String,String>>();
        
        Map<Id,AccountContactRelation> contactAccountRelMap = new Map<Id,AccountContactRelation>([SELECT ContactId 
            from AccountContactRelation where AccountId =: accountId]);
        List<AccountContactRelation> contactAccountRel = contactAccountRelMap.values();

        List<String> idsContactRelated = new List<String>(); 
        for(AccountContactRelation acr: contactAccountRel){
            idsContactRelated.add(acr.ContactId);
        }

        Map<Id,XC_ContractLineItem__c> contactsOnContractLineItemsMap = new Map<Id,XC_ContractLineItem__c>([SELECT id, (SELECT id, XC_Contact__c
         from Contacts_to_Contract_Line_Items__r)  from XC_ContractLineItem__c  WHERE id =: contractLineItemId]);
        List<XC_ContractLineItem__c> contactsOnContractLineItems = contactsOnContractLineItemsMap.values();

        System.debug('related del contractLineItem = '+contactsOnContractLineItems);
        List<String> idsContactWithContract = new List<String>();
        for(XC_ContractLineItem__c cwc: contactsOnContractLineItems){
            List<XC_ContactToContractLineItem__c> cocList =  cwc.Contacts_to_Contract_Line_Items__r;
            for(XC_ContactToContractLineItem__c c : cocList){
           		 idsContactWithContract.add(c.XC_Contact__c);
            }
        }
        
		System.debug('Contact da eliminare nella picklist = '+idsContactWithContract);
        Map<Id,Contact> contactsMap = new Map<Id,Contact>([SELECT id, Name from Contact where Id IN: idsContactRelated 
            AND Id NOT IN: idsContactWithContract]);
        List<Contact> contacts = contactsMap.values();

        System.debug('avaible contact = '+contacts);
        for(Contact contact: contacts){
            Map<String,String> row = new Map<String,String>();
            row.put('key',contact.Id); 
            row.put('value',contact.Name);
            result.add(row);
        }

        return result;
    }


}