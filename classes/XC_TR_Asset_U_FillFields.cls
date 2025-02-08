/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 10/05/2019
 * @description XC_TR_Asset_U_FillFields – Class to fill Asset Fields
 */

public without sharing class XC_TR_Asset_U_FillFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_U_FillFields');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate fields for list of Asset
    * @param assetList - List<Asset>
    */
    public static void populateFields(List<Asset> assetList) {
        List<Id> idList = XC_UTIL_Sobject.getListFieldValues(assetList, 'NE__Order_Config__c');
        Map<Id, NE__Order__c> mapIdConf = new Map<Id, NE__Order__c>([
			SELECT Id, XC_InstallationAddress__c, XC_DeliveryAddress__c, XC_Segment__c, XC_Contact__c, XC_Contact__r.AccountId, XC_Company_Code__c, XC_Cost_Center__c,
				NE__OptyId__r.XC_ReceivingChannel__c, NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_CompanyCode__c, NE__OptyId__r.XC_CostCenter__c, 
				XC_DeliveryAddress__r.XC_PickUpPoint__c, XC_LegalEntity__c, NE__OptyId__r.XC_Contact__r.AccountId
			FROM NE__Order__c 
			WHERE Id IN :idList
		]); 
        populateFields(assetList, mapIdConf);
        fillEmobilityFields(assetList, mapIdConf);
    }


    /**
	 * @description Populate lookup pod contact
	 * @param assetsToProcess - List<Asset>
     * @param mapAssetIdToOrder
	 */
	private static void populateFields(List<Asset> assetsToProcess, Map<Id, NE__Order__c> mapAssetIdToOrder) { 
		List<User> runningUser = new List<User>();
		Boolean getLegalEntityFromUser = false;
		Set<Id> accSet = new Set<Id>();
		Map<Id, Account> accMap = new Map<Id, Account>();
		
		List<String> confItemList = XC_UTIL_Sobject.getListFieldValues(assetsToProcess, 'XC_Configuration_Item__c');
        Map<Id,List<NE__Order_Item_Attribute__c>> mapConfigurationItemListAttribute=XC_UTIL_ConfigurationItem.getOrderItemAttributeMap(confItemList);
		
		for(Asset a : assetsToProcess){
			if(a.NE__Order_Config__c == null){
				getLegalEntityFromUser = true;
				if(String.isNotBlank(a.AccountId)) {
					accSet.add(a.AccountId);
				}
				//break;
			}
		}
		if(getLegalEntityFromUser){
			runningUser = new List<User>([SELECT Id, XC_LegalEntity__c FROM User WHERE Id = :UserInfo.getUserId()]);
		}
		if(!accSet.isEmpty()) {
			accMap = new Map<Id, Account>([SELECT Id, XC_Segment__c FROM Account WHERE Id IN :accSet]);
		}
		for(Asset a : assetsToProcess) { 
			if(a.NE__Order_Config__c != null) {
				NE__Order__c order = mapAssetIdToOrder.get(a.NE__Order_Config__c); 
				a.ContactId = (String.isNotBlank(order.XC_Contact__c)) ? order.XC_Contact__c : order.NE__OptyId__r.XC_Contact__c;
				a.AccountId = (String.isNotBlank(order.XC_Contact__r.AccountId)) ? order.XC_Contact__r.AccountId : order.NE__OptyId__r.XC_Contact__r.AccountId;
				a.XC_LegalEntity__c = order.XC_LegalEntity__c;
				a.XC_Segment__c = order.XC_Segment__c;
				a.XC_ReceivingChannel__c = order.NE__OptyId__r.XC_ReceivingChannel__c;
				if(order.XC_InstallationAddress__c != null) {
					a.XC_Address__c = order.XC_InstallationAddress__c;
				} else if (order.XC_InstallationAddress__c == null && order.XC_DeliveryAddress__c != null && !order.XC_DeliveryAddress__r.XC_PickUpPoint__c) { 
					a.XC_Address__c = order.XC_DeliveryAddress__c;
				}
			} else {
				if(!runningUser.isEmpty() && !String.isBlank(runningUser[0].XC_LegalEntity__c) && String.isBlank(a.XC_LegalEntity__c)) {
					a.XC_LegalEntity__c = runningUser[0].XC_LegalEntity__c;
				}
				if(String.isNotBlank(a.AccountId) && accMap.containsKey(a.AccountId)) {
					a.XC_Segment__c = accMap.get(a.AccountId).XC_Segment__c;
				}
			}
			if(a.XC_ContractStartDate__c == null) a.XC_ContractStartDate__c = Date.valueOf(a.XC_ActivationDate__c); 
			//a.XC_Service_AutoRenew__c =  ( a.XC_Product_Name__c != null && a.XC_Product_Name__c.Contains(Label.XC_CL_OK) || ( a.XC_LegalEntity__c==Label.XC_CL_LegalEntity_Italy && a.XC_Segment__c=='B2C' && a.XC_Product_Type__c==Label.XC_CL_ProductTypeCoverage) ) ? true : false;
			//Fix on Service AutoRenew [MO] 24-11-2020
			a.XC_Service_AutoRenew__c = a.XC_Segment__c=='B2C' && a.XC_BillingModel__c == Label.XC_CL_BillingModel_Recurring &&
									( (a.XC_Product_Type__c==Label.XC_CL_ProductTypeService) ||
									 ( (a.XC_LegalEntity__c==Label.XC_CL_LegalEntity_Italy || a.XC_LegalEntity__c==Label.XC_CL_LegalEntity_EnelXMobilityItalia) && a.XC_Product_Type__c==Label.XC_CL_ProductTypeCoverage));
			//end fix on Service AutoRenew
			List<NE__Order_Item_Attribute__c> listAttributeConfItem = a.XC_Configuration_Item__c !=null && mapConfigurationItemListAttribute.containsKey(a.XC_Configuration_Item__c) ? mapConfigurationItemListAttribute.get(a.XC_Configuration_Item__c) : new List<NE__Order_Item_Attribute__c>();
			XC_TR_Asset_U_PopulateDate.populateEndDateContract(a,listAttributeConfItem);
			populateRenewalDurationAsset(a,listAttributeConfItem);
		}
	}

	/**
	 * @author Marco Ottaviano - mottaviano@deloitte.it
    * @description Populate XC_RenewalDuration__c on asset
	* @param asset 
	* @ param listAttributeConfItem - List of Configuration Item Attribute
	*/
	public static void populateRenewalDurationAsset(Asset asset,List<NE__Order_Item_Attribute__c> listAttributeConfItem) {
		Boolean found = false;
		if(!listAttributeConfItem.isEmpty()) {
			for(NE__Order_Item_Attribute__c attr : listAttributeConfItem) {
				if(attr.XC_DeveloperName__c == Label.XC_CL_ConfigItemAttribute_DevRenewalDuration && String.isNotBlank(attr.NE__Value__c) && attr.NE__Value__c!='0' /* && String.isNotBlank(asset.XC_BillingModel__c)*/) {
					asset.XC_RenewalDuration__c = Integer.valueOf(attr.NE__Value__c);
					found = true;
					break;
				 }
			}
		}
		if(!found && asset.XC_Service_AutoRenew__c) {
			asset.XC_RenewalDuration__c = 12;
		}
	}

    /**
	 * @description Cart configuration from asset
	 * @param assetList - List<Asset>
     * @param listConf - List<NE__Order__c>
	 */
	private static void fillEmobilityFields(List<Asset> assetList, Map<Id, NE__Order__c> mapIdToOrder) { 
		for(Asset ass : assetList) {
			if(ass.NE__Order_Config__c != null) {
				NE__Order__c order = mapIdToOrder.get(ass.NE__Order_Config__c);
				ass.XC_CompanyCode__c = (String.isNotBlank(order.XC_Company_Code__c)) ? order.XC_Company_Code__c : order.NE__OptyId__r.XC_CompanyCode__c;
				ass.XC_CostCenter__c = (String.isNotBlank(order.XC_Cost_Center__c)) ? order.XC_Cost_Center__c : order.NE__OptyId__r.XC_CostCenter__c;
			}
		}
	}  

    /**
     * @description Method to populate Asset Ownership
     * @param listAsset - List<Asset>
     */
    public static void populateAssetOwnership(List<Asset> listAsset){
        for(Asset a : listAsset) {
            if(a.NE__Order_Config__c != null){ 
                a.XC_AssetOwnership__c = Label.XC_CL_AssetOwnership_SoldByEnelX;//'Sold by Enel X';
            }
            else{
            	a.XC_AssetOwnership__c = Label.XC_CL_AssetOwnership_Customer; //'Customer';
            }
        }        
	}
	
	/**
    * @author Giuseppe Di Bonito - gdibonito@deloitte.it
    * @description Copy salesforce id from XC_SubscriptionId__c to XC_Subscription__c
    * @param assetList - List<Asset> updated
    */
	public static void populateSubscriptionLookup(Map<Id, Asset> mapOld, Map<Id, Asset> mapNew){
		XC_UTIL_Debug.debug(DEBUGACTIVE, '$$ In populateSubscriptionLookup (Asset after update)');
		List<String> fieldlist = new List<String>();
		fieldList.add('XC_SubscriptionId__c');
		List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
		if(listChanged.isEmpty()){
			XC_UTIL_Debug.debug(DEBUGACTIVE, '$$ No XC_SubscriptionId__c to update');
			return;
		}
		Map<String, Asset> assMap = new Map<String, Asset>();
		for(Asset a : listChanged){
			if(!String.isBlank(a.XC_SubscriptionId__c)){
				assMap.put(a.XC_SubscriptionId__c, a);
			}
		}
		XC_UTIL_Debug.debug(DEBUGACTIVE, '$$ assMap: ' + assMap);
        Map<Id, Zuora__Subscription__c> quMap = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__External_Id__c 
												  									 FROM Zuora__Subscription__c 
												 									 WHERE Zuora__External_Id__c in: assMap.keySet()]);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '$$ quMap: ' + quMap);
		for(Zuora__Subscription__c zs : quMap.values()) {           
            if(assMap.keyset().contains(zs.Zuora__External_Id__c)){
				assMap.get(zs.Zuora__External_Id__c).XC_Subscription__c = zs.id;
			}    
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '$$ assMap.values(): ' + assMap.values());
	}


}