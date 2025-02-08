/**
 * The Class XC_TR_Asset_U_PopulateContractsLineItem.
 *
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 19/10/2018
 * @description XC_TR_Asset_U_PopulateContractsLineItem
 */
public without sharing class XC_TR_Asset_U_PopulateContractsLineItem {

  	 /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Manage the creation of new Asset
	 *@param assetsToProcess
     */
    public static void manageAssetCreation(List<Asset> assetsToProcess){
		List<String> listOfConfigurationId = new List<String>();
		Map<Id, List<Asset>> config2Asset = getMapOrder2Asset(assetsToProcess);
		String typeOfConfiguration = getConfigurationType(config2Asset.keyset());
		Map<Id, List<Asset>> contractToAsset = getMapContract2Asset(config2Asset);
		
		populateContractLookupOnAsset(contractToAsset, assetsToProcess, typeOfConfiguration); 
	}
    
	/**
     * @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com && Sara Miozza sara.miozza@nttdata.com
     * @description Populate Asset lookup on Contract 
	 * @param contractToAsset - Map<Id, List<Asset>>
	 * @param listAssetToProcess - List<Asset>
	 * @param typeOfConfiguration - String
     */
	private static void populateContractLookupOnAsset(Map<Id, List<Asset>> contractToAsset, List<Asset> listAssetToProcess, String typeOfConfiguration){
		List<Asset> assetList = new List<Asset>();
		if(!String.isBlank(typeOfConfiguration) && typeOfConfiguration.equals(Label.XC_CL_Configuration_TypeChangeOrder)){
			List<Asset> listOldAsset = new List<Asset>([SELECT id, XC_Contract__c  
														FROM Asset 
														WHERE NE__Order_Config__c =: listAssetToProcess[0].NE__Order_Config__c AND XC_Contract__c <> null]);
			for(Asset a : listAssetToProcess){
				if(a.NE__Order_Config__c != null && a.NE__Bundle_element__c == null && a.NE__Root_Order_Item__c == null && String.isBlank(a.NE__Parent_Order_Item__c) && !String.isEmpty(a.XC_PaymentMethod__c)) {
					Asset ass = new Asset(Id= a.Id);
					ass.XC_Contract__c = listOldAsset[0].XC_Contract__c;
					assetList.add(ass);
				}
				
			}
		}else{
			for(Id contractId : contractToAsset.keySet()){
				for(Asset a : contractToAsset.get(contractId)){
					if(a.NE__Order_Config__c != null && a.NE__Bundle_element__c == null && a.NE__Root_Order_Item__c == null && String.isBlank(a.NE__Parent_Order_Item__c) && !String.isEmpty(a.XC_PaymentMethod__c)){
					Asset ass = new Asset(Id= a.Id);
					ass.XC_Contract__c = contractId;
					assetList.add(ass);
					}
				}
			}
		}
		XC_UTIL_SObject.updateListRecords(assetList);
	}
	 
    /**
     * @description Get Contract from Asset.
     * @param  listNew - List<Asset>
	 * @param  mapOld - Map<Id,Asset>
	 * @param  mapNew - Map<Id,Asset>
     */
    public static void updateContractFromAsset(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
		List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
		if(!listChanged.isEmpty()){
			List<String> contractsId = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Contract__c');
			List<Contract> contractList = new List<Contract>([SELECT Id,(SELECT Id,Status,XC_Contract__c, XC_DeactivationByChangeOrder__c,XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c,XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c  FROM Assets1__r ORDER BY CreatedDate DESC limit 4999) FROM Contract WHERE Id IN: contractsId]);
			updateStatusOnContract(contractList);
		}
    }
    
     /**
      * @description Update status on contract.
      * @param  contracts - List<Contract>
      */ 
     public static void updateStatusOnContract(List<Contract> contracts){
		System.debug('entrato in updateStatusOnContract');
		List<Contract> contractToUpdate = new List<Contract>(); 
		for(Contract c : contracts){
			integer allCancelled = 0;
			integer allActive = 0;
			integer totalAsset = c.Assets1__r.size();
			Asset masterAsset = c.Assets1__r[0];
			Boolean changeOrderPurchase= false;
			if(String.isNotBlank(masterAsset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c)) {
				changeOrderPurchase = !masterAsset.XC_DeactivationByChangeOrder__c && masterAsset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c.containsIgnorecase('purchase')  ? true : false;
			}			
			if(!masterAsset.XC_DeactivationByChangeOrder__c || masterAsset.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c != Label.XC_CL_Configuration_TypeChangeOrder || changeOrderPurchase){
				for(Asset a : c.Assets1__r){
					if(checkStatusAssetActive(a)){
						allActive++;
					}else if(checkStatusInactive(a)){
						allCancelled++;
					}else{
						break; 
					}
				}
				if(allActive == totalAsset){
					c.Status = Label.XC_CL_Contract_Active;
					contractToUpdate.add(c);
				}else if(allCancelled == totalAsset && !changeOrderPurchase){
					c.Status = Label.XC_CL_Contract_Cancelled;
					contractToUpdate.add(c);
				} else if(allCancelled == totalAsset && changeOrderPurchase) {
					c.Status = 'Ended';
					c.EndDate = System.today(); 
					contractToUpdate.add(c);
				}
			}
		}
		XC_UTIL_Sobject.updateListRecords(contractToUpdate);       
     } 
    
	/**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description create a map that contains a key of Configuration and a values of Assets related to  the configuration's childrens(Configurations Items)
	 *@param listAsset
	 * @return Map<Id,List<Asset>>
     */
	private static Map<Id, List<Asset>> getMapOrder2Asset (List<Asset> listAsset){

		Map<Id, List<Asset>> configurationsToAsset = new Map<Id, List<Asset>>();
		Set<Id> setOrderId = orderIdFromListAsset(listAsset);

		Id orderID;
		List<Asset> assetFromOrder;
		List<Asset> listAssetTmp;

		for(Asset a : listAsset){

			assetFromOrder = configurationsToAsset.get(a.NE__Order_Config__c);

			if(assetFromOrder == null) {
				assetFromOrder = new List<Asset>();
			}

			assetFromOrder.add(a);
			if(!String.isBlank(a.NE__Order_Config__c)){
                configurationsToAsset.put(a.NE__Order_Config__c, assetFromOrder);
            }

		}
		return configurationsToAsset;
	}

	/**
     * @author Giulio Serra - giserra@deloitte.com , Federico Amici - federico.amici@nttdata.com
	 * @param listAsset
     * @description create a set that contains a list of IDs of orders items contained inside a list
	 * @return Set<Id>
     */
	private static Set<Id> orderIdFromListAsset(List<Asset> listAsset){

		Set<Id> confIdFromAsset = new Set<Id>();
		for(Asset a : listAsset){
			confIdFromAsset.add(a.NE__Order_Config__c);
		}
		return confIdFromAsset;
	}



	/**
	 * Gets the map contract 2 asset.
	 *
	 * @author Giulio Serra - giserra@deloitte.com , Federico Amici - federico.amici@nttdata.com
	 * @param configurationToAsset the configuration to asset
	 * @return the map contract 2 asset
	 * @description create a map with the contract and all the assets that that must be connected to it by a junction object(Contract Item)
	 */
	private static Map<Id,List<Asset>> getMapContract2Asset(Map<Id,List<Asset>> configurationToAsset){

		Map<Id,List<Asset>> contractToAsset = new Map<Id,List<Asset>>();
		Map<Id,Contract> contractsFromConfigurationsMap = new Map<Id,Contract>([SELECT Id, XC_Configurations__c, StartDate, EndDate 
													  FROM Contract
													  WHERE XC_Configurations__c IN :configurationToAsset.keySet()]);
		List<Contract> contractsFromConfigurations = contractsFromConfigurationsMap.values();

		System.debug('@@@ ' + contractsFromConfigurations);
		for(Id configurationId : configurationToAsset.keySet()){

			Contract c = contractFromconfigurationId(configurationId, contractsFromConfigurations);
			System.debug(c);
			if(c != null){

				List<Asset> assetsFromConfigurationMap = configurationToAsset.get(configurationId);

				if(contractToAsset.keySet().contains(c.Id)){
					List<Asset> assetsFromContractsMap = contractToAsset.get(c.Id);
					
					assetsFromContractsMap.addAll(assetsFromConfigurationMap);
					contractToAsset.put(c.id, assetsFromContractsMap);

				} else {
					contractToAsset.put(c.id , assetsFromConfigurationMap);
				}
			}
		}


		return contractToAsset;
	}

	/**
	 * Contract fromconfiguration id.
	 *
	 * @param configurationId the configuration id
	 * @param listcontract the listcontract
	 * @return the contract
	 * @description 
	 */
	private static Contract contractFromconfigurationId(Id configurationId, List<Contract> listcontract){

		for(Contract c : listcontract){
			if(c.XC_Configurations__c == configurationId){
				return c;
			}
		}

		return null;
	}

	private static String getConfigurationType(Set<Id> configurationId){
		String typeOfConfiguration;
		List<NE__Order__c> listOfConfiguration = new List<NE__Order__c>([SELECT Id, NE__Type__c
																		 FROM NE__Order__c 
																		 WHERE Id IN : configurationId]);
		if(!listOfConfiguration.isEmpty()){
			typeOfConfiguration = listOfConfiguration[0].NE__Type__c;
		}
		return typeOfConfiguration;
	}

	private static Boolean checkStatusAssetActive(Asset a){
		return a.Status == Label.XC_CL_Asset_StatusActive && a.XC_Contract__c!= null;
	}

	private static Boolean checkStatusInactive(Asset a){
		return a.Status == Label.XC_CL_Asset_StatusInactive && a.XC_Contract__c!=null;
	}



	/**
	 * @author Nicola Mariniello - nmariniello@deloitte.com , Luisana Rocco - lrocco@deloitte.it
	 * @param  listNew - List<Asset>
	 * @param  mapOld - Map<Id,Asset>
	 * @param  mapNew - Map<Id,Asset>
	 * @description method to check if XC_ContractEndDate__c is changed
	*/
	public static void updateContractEndDate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
		List<String> fieldList = new List<String>{'XC_ContractEndDate__c'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
		if(!listChanged.isEmpty()){
			List<String> contractsId = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Contract__c');
			List<Contract> contractList = new List<Contract>([SELECT Id, EndDate, ContractTerm, (SELECT Id,Status,XC_Contract__c,XC_ContractEndDate__c, XC_ContractStartDate__c , NE__Order_Config__r.NE__Configuration_Type__c, XC_Segment__c  FROM Assets1__r where  NE__Order_Config__r.NE__Type__c = 'InOrder' ORDER BY CreatedDate DESC) FROM Contract WHERE Id IN: contractsId]);
			updateEndDateOnContract(contractList);
		}
    }


	/**
	 * @author Nicola Mariniello - nmariniello@deloitte.com , Luisana Rocco - lrocco@deloitte.it
	 * @param  List<Contract> - contractList
	 * @description method to update contract end date based on the latest end date of the Assets
	*/
	public static void updateEndDateOnContract(List<Contract> contractList){

		Set<Contract> contrToUpdate = new Set<Contract>();
		Boolean needToUpdate = false;
		for(Contract contr: contractList){
			for(Asset ass : contr.Assets1__r){
				if(ass.XC_ContractEndDate__c != null && ass.Status == Label.XC_CL_Asset_StatusActive && ass.XC_Segment__c == 'B2C'){
					needToUpdate = true;
					if(contr.EndDate == null){
						contr.EndDate = ass.XC_ContractEndDate__c;
					}else if(ass.XC_ContractEndDate__c > contr.EndDate){
						contr.EndDate = ass.XC_ContractEndDate__c;
					}	
					contr.ContractTerm = (ass.XC_ContractStartDate__c!=null && ass.XC_ContractEndDate__c!=null) ?  ass.XC_ContractStartDate__c.monthsBetween(ass.XC_ContractEndDate__c) : 12;
				}
			}
			if(needToUpdate){
				contrToUpdate.add(contr);
			}
		}

		if(!contrToUpdate.isEmpty()){
			List<Contract> contr = new List<Contract>();
			contr.addAll(contrToUpdate);
			XC_UTIL_Sobject.updateListRecords(contr);    
		}
		   
	}


	/**
	 * @author  Luisana Rocco - lrocco@deloitte.it
	 * @param  listNew - List<Asset>
	 * @param  mapOld - Map<Id,Asset>
	 * @param  mapNew - Map<Id,Asset>
	 * @description method to update  vas contract ext id from the Assets
	*/
	public static void updateContractField(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
		List<String> fieldList = new List<String>{'XC_Contract__c', 'XC_VASContractExtID__c'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
		Set<Asset> assetToCheck = new Set<Asset>();
		if(!listChanged.isEmpty()){

			for(Asset a : listChanged){
				if(a.XC_Segment__c=='B2C' && !String.isBlank(a.XC_VASContractExtID__c)){
					assetToCheck.add(a);
				}
			}
			if(!assetToCheck.isEmpty()){
				List<String> contractsId = XC_UTIL_Sobject.getListFieldValues(new List<Asset>(assetToCheck), 'XC_Contract__c');
				if(!contractsId.isEmpty()){
					Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, XC_VASContractExtID__c FROM Contract WHERE Id IN: contractsId]);
					updateFieldOnContract(assetToCheck, contractMap);
				}
			}
    	}
	}
	

	/**
	 * @author  Luisana Rocco - lrocco@deloitte.it
	 * @param  assetToCheck - Set<Asset>
	 * @param  contractMap - Map<Id,Contract>
	 * @description util metho to update  vas contract ext id from the Assets
	*/
	public static void updateFieldOnContract(Set<Asset> assetToCheck, Map<Id, Contract> contractMap){
		
		Set<Contract> contractToUpdate = new Set<Contract>();
		for(Asset a: assetToCheck){
			Contract contr = contractMap.get(a.XC_Contract__c);
			if(!String.isBlank(a.XC_VASContractExtID__c) && a.XC_VASContractExtID__c != contr.XC_VASContractExtID__c){
				contr.XC_VASContractExtID__c = a.XC_VASContractExtID__c;
				contractToUpdate.add(contr);
			}
		}
		
		if(!contractToUpdate.isEmpty()){
			XC_UTIL_Sobject.updateListRecords(new List<Contract>(contractToUpdate)); 
		}
	}
}