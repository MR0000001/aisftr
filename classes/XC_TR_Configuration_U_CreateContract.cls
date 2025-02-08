/**
* @author Federico Amici
* @date Creation  / /2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Configuration_U_CreateContract – Class to create contract
*/

public without sharing class XC_TR_Configuration_U_CreateContract {
    
	/** 
	 * @description Handle creation contract.
	 *
	 * @param listNew the list new
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void handleCreationContract(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
		System.debug('eneter handleCreationContract');
		List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew);
        if(listConfigurationNew.isEmpty()){
            return;
		}
        
		/* B2B/G Sprint2 - Contract Creation - MC 20200603 */
		List<NE__Order__c> orderTypeChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'RecordTypeId'}, mapOld, mapNew);
		List<NE__Order__c> orderStatusChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'NE__OrderStatus__c'}, mapOld, mapNew);
		if(!orderTypeChanged.isEmpty()) {
        	checkForContractCreationWhenCreated(orderTypeChanged);
		}else if(!orderStatusChanged.isEmpty()) {
        	checkForContractCreationWhenSent(orderStatusChanged);
		}
	}

	/** 
     * @description Contract creation
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param orderStatusChanged orders to check for contract creation
     */
	private static void checkForContractCreationWhenSent(List<NE__Order__c> orderStatusChanged){
		Map<Id,Id> existingContr = searchExistingContract(orderStatusChanged);
		List<NE__Order__c> orderForCreation = new List<NE__Order__c> ();
		for(NE__Order__c conf : orderStatusChanged){
			if(existingContr.get(conf.Id) == null){
				orderForCreation.add(conf);
			}
		}
		
		if(!orderForCreation.isEmpty()){
			Boolean isChangeOrder = false;
			List<NE__Order__c> listOrder = new List<NE__Order__c>(); 
			for(NE__Order__c newOrder : orderForCreation) {
				System.debug('newOrder.NE__OrderStatus__c->' + newOrder.NE__OrderStatus__c);
				if(newOrder.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent) {
					System.debug('@@@AccountId ' + newOrder.NE__AccountId__c);
					listOrder.add(newOrder);    
				}
				if(newOrder.NE__Type__c.equals(Label.XC_CL_Configuration_TypeChangeOrder)){
					isChangeOrder = true;
				}
			}  
			if(!listOrder.isEmpty() && !isChangeOrder){ 
				XC_UTIL_Contract.createContracts(listOrder);
			}
		}
	}

	/** 
     * @description Contract creation
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param orderTypeChanged orders to check for contract creation
     */
	private static void checkForContractCreationWhenCreated(List<NE__Order__c> newOrders){
		List<NE__Order__c> ordersToCheck = getOrderForContractCreation(newOrders);
        System.debug('ordersToCheck'+ ordersToCheck);
		if(!ordersToCheck.isEmpty()){
			Map<Id,Id> existingContr = searchExistingContract(ordersToCheck);
			List<NE__Order__c> orderForCreation = new List<NE__Order__c> ();
			for(NE__Order__c conf : ordersToCheck){
                System.debug('conf'+ conf);
				if(existingContr.get(conf.Id) == null){
					orderForCreation.add(conf);
				}
			}

			XC_UTIL_Contract.createContracts(orderForCreation);
		}
	}

	/** 
     * @description get Order For Contract Creation
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param listNew the list new
     * @param operation INSERT or UPDATE
     */
	private static List<NE__Order__c> getOrderForContractCreation(List<NE__Order__c> listNew){
		List<NE__Order__c> result = new List<NE__Order__c>();
		Id orderRTid = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
		/* IF segmento b2b o b2g ma LE <> EnelXChile, EnelDistribution e Codensa >>> contract creation in INSERT */
		for(NE__Order__c config : listNew){
			if( config.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder && config.RecordTypeId == orderRTid &&
               //JJP 25/01/2022 - Start
			   (config.XC_Segment__c == 'B2B' || config.XC_Segment__c == 'B2G' || config.XC_Segment__c == 'B2C') && 
			   (config.XC_LegalEntity__c != 'EnelXChile' || config.XC_LegalEntity__c != 'EnelDistribution' || config.XC_LegalEntity__c != 'EnelXMobilityChile' || config.XC_LegalEntity__c != 'Codensa')){
               //JJP 25/01/2022 - End
				result.add(config);
			}
		}
		return result;
	}

	/** 
     * @description searchExistingContract
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param orders
     * @return Map<Id,Id> with Order Id -> Contract Id
     */
	private static Map<Id,Id> searchExistingContract(List<NE__Order__c> orders){
		Map<Id,Id> result = new Map<Id,Id>();
		Set<Id> ordIds = XC_UTIL_Sobject.getSetIds(orders);
		Map<Id,Contract> data = new Map<Id,Contract>([
			SELECT Id, XC_Configurations__c FROM Contract WHERE XC_Configurations__c IN: ordIds
		]);
		for(Contract contr : data.values()){
			result.put(contr.XC_Configurations__c, contr.Id);
		}
		return result;
	}
	
    /*
     * old method - avoid too deply nested if
     * 
	public static void handleCreationContract(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
		System.debug('eneter handleCreationContract');
		List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew);
		if(!listConfigurationNew.isEmpty()){
			List<String> fieldList = new List<String>{'NE__OrderStatus__c'};
			List<NE__Order__c> listOrderChanged = XC_UTIL_Sobject.getListChanged(listConfigurationNew, fieldList, mapOld, mapNew);
			if(!listOrderChanged.isEmpty()){
				List<NE__Order__c> listOrder = new List<NE__Order__c>(); 
				for(NE__Order__c newOrder : listOrderChanged) {
					System.debug('newOrder.NE__OrderStatus__c->' + newOrder.NE__OrderStatus__c);
					if(newOrder.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent) {
						System.debug('@@@AccountId ' + newOrder.NE__AccountId__c);
						listOrder.add(newOrder);    
					}
				} 
				if(!listOrder.isEmpty()){ 
					XC_UTIL_Contract.createContracts(listOrder);
				} 
			}
		}
	}
	*/

	/*private static void createContracts(List<NE__Order__c> listOrder) { 
		List<Contract> listContractToCreate = new List<Contract>();
		List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listOrder);

		for(NE__Order__c order : listConfigurationNew) { 
			Contract newContract = new Contract();
			newContract.Status = Label.XC_CL_Contract_Pending;
			newContract.AccountId = order.NE__AccountId__c;
			newContract.XC_Configurations__c = order.Id; 
			listContractToCreate.add(newContract); 
		}  
		XC_UTIL_Sobject.insertListRecords(listContractToCreate);
	}*/


}