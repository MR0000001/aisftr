/**
* @author Giulio Serra giserra@deloitte.it
* @date Creation 21/08/2018
* @date Modification dd/mm/yyyy
* @description XC_SC006_AutoNotifySkillClosure – notify 
*/

public with sharing class XC_SC006_AutoNotifySkillClosure implements Schedulable, Database.Batchable<sObject>{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC006_AutoNotifySkillClosure');
             
    /**
     * @description execute method
     * @param sc - SchedulableContext
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC006_AutoNotifySkillClosure());
	}     

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT Id,EffectiveEndDate,XC_DaysToExpiration__c,ServiceResourceId FROM ServiceResourceSkill WHERE EffectiveEndDate != null AND XC_DaysToExpiration__c > 0 AND XC_DaysToExpiration__c <= 10 ';
        return Database.getQueryLocator(query);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<	ServiceResourceSkill> scope) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ scopes' +scope);
        List<Id> serviceResourceId = XC_UTIL_Sobject.getListFieldValues(scope, 'ServiceResourceId');
        /** Modifica Salvatore Agrillo 31/05/2019 */
        List<ServiceResource> listServiceResource = [SELECT Id,XC_Contact__c, XC_Contact__r.Email, XC_Contact__r.LastName, XC_Contact__r.FirstName, XC_Contact__r.AccountId,XC_Contact__r.XC_MainLegalEntity__c   
                                                     FROM ServiceResource 
                                                     WHERE Id IN :serviceResourceId];
        List<Contact> listContact = new List<Contact>();
        String legalEntity;
        for(ServiceResource sr : listServiceResource) {
            Contact cct = new Contact();
            cct.Id = sr.XC_Contact__c;
            cct.Email = sr.XC_Contact__r.Email;
            cct.LastName = sr.XC_Contact__r.LastName;
            cct.FirstName = sr.XC_Contact__r.FirstName;
            cct.AccountId = sr.XC_Contact__r.AccountId;
            cct.XC_MainLegalEntity__c = sr.XC_Contact__r.XC_MainLegalEntity__c;
            listContact.add(cct);
        }
		List<Map<String,Object>> customerInteractions = new List<Map<String,Object>>();
       	for(Contact cont : listContact){
            customerInteractions.add(createValueMap(cont));
        }
        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.manageCustomerInteractionInsert(customerInteractions);
        manageResults(results);
    }
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @date Creation 21/08/2018
    * @description create a map of values to send a customer interaction
    * @param c
    * @return Map<String,Object>
    */
    @TestVisible
    private Map<String,Object> createValueMap(Contact c){	
        Map<String,Object> data = new Map<String,Object>();
		data.put('customerType', 'Partner_SkillsExpiration_Email');
	   	data.put('skipComunication', false);
		data.put('email',c.Email);
	   	data.put('fullName',c.FirstName + ' ' + c.LastName);
        data.put('accountId',c.AccountId);
        data.put('legalEntity', c.XC_MainLegalEntity__c);
	   	XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ Map value' + ' ' + data); 
        return data;
    }
    
	/**
	* @author Giulio Serra giserra@deloitte.it 
	* @date Creation 21/08/2018
	* @date Modification dd/mm/yyyy
	* @description manage the update of the opportunities
    * @param results - List<XC_UTIL_Sobject.WrapperResult>
	*/
	private static void manageResults(List<XC_UTIL_Sobject.WrapperResult> results){
		for(XC_UTIL_Sobject.WrapperResult result : results){
			if(!result.success){
			    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error creating customer interaction:' + result);
            }
        }
	}

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.batchablecontext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC006_AutoNotifySkillClosure'); 
    }
}