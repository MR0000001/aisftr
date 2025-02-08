/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 21/03/2019
* @description XC_TR_ContractLineItem_U_PopulateEndDate – 
*/
public without sharing class XC_TR_ContractLineItem_U_PopulateEndDate {
	
	/**
	 * @description Populate end date.
	 * @param listNew the list new
	 */
	public static void populateEndDate(List<XC_ContractLineItem__c> listNew){
		List<Id> assetListId = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Asset__c');
		Map<Id,Id> assetIdConfItemIdMap = new Map<Id,Id>();
		Map<Id,Integer> configuratioItemWithMonthRenting = new Map<Id,Integer>();
		List<XC_ContractLineItem__c> cliToUpdateList = new List<XC_ContractLineItem__c>();
		List<Asset> assetBundleList = queryOnAsset(assetListId);

		for(Asset ast : assetBundleList ){
			assetIdConfItemIdMap.put(ast.Id, ast.XC_Configuration_Item__c);
		}
		List<String> orderItemBundleListId = XC_UTIL_Sobject.getListFieldValues(assetBundleList, 'XC_Configuration_Item__c');
		List<NE__OrderItem__c> orderItemList = queryOnConfItem(orderItemBundleListId);

		for(NE__OrderItem__c orItem: orderItemList){
			configuratioItemWithMonthRenting.put(orItem.NE__Bundle_Configuration__c, Integer.valueOf(orItem.XC_Max_Months_Renting__c));
		}						
		for(XC_ContractLineItem__c cli : listNew){
			if(cli.XC_StartDate__c != null){
				Id bundleConfigurationItemId;
				Integer monthRenting;
				Id bundleAssetId = cli.XC_Asset__c;
				if(assetIdConfItemIdMap.containsKey(bundleAssetId)){
					bundleConfigurationItemId = assetIdConfItemIdMap.get(bundleAssetId);
				}
				System.debug('@@##@@ -->' + bundleConfigurationItemId);
				if(configuratioItemWithMonthRenting.containsKey(bundleConfigurationItemId)){
					monthRenting = configuratioItemWithMonthRenting.get(bundleConfigurationItemId);
				}
				System.debug('@@##@@ monthRenting -->' + monthRenting);
				if(monthRenting!=null){
					cli.XC_EndDate__c = cli.XC_StartDate__c.addMonths(monthRenting);//cli.XC_StartDate__c.addMonths(mapAssetMaxMonth.get(cli.XC_Asset__c)); 
				}
				System.debug('@@@ CLI New End Date --> '+ cli.XC_EndDate__c);
			} 
		}							
	}

	/**
    * @description query from Asset
    * @param assetListId
    * @return caseList
     */
    public static List<Asset> queryOnAsset(List<Id> assetListId) {
		List<Asset> assetBundleList = new List<Asset>(); 
		if(Schema.sObjectType.Asset.isAccessible() && Schema.sObjectType.Asset.fields.Id.isAccessible() && Schema.sObjectType.Asset.fields.XC_Configuration_Item__c.isAccessible()){
			assetBundleList = [SELECT Id, XC_Configuration_Item__c
								FROM Asset 
								WHERE Id In:assetListId];
		}
		return assetBundleList;
	}
	/**
    * @description queryOnConfItem
    * @param orderItemBundleListId
    * @return orderItemList
     */
	public static List<NE__OrderItem__c> queryOnConfItem(List<String> orderItemBundleListId) {
		List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
		if(Schema.sObjectType.NE__OrderItem__c.isAccessible() && Schema.sObjectType.NE__OrderItem__c.fields.Id.isAccessible() && Schema.sObjectType.NE__OrderItem__c.fields.XC_Max_Months_Renting__c.isAccessible() && Schema.sObjectType.NE__OrderItem__c.fields.NE__Bundle_Configuration__c.isAccessible()){
			orderItemList = [SELECT Id, XC_Max_Months_Renting__c,NE__Bundle_Configuration__c
								FROM NE__OrderItem__c
								WHERE NE__Bundle_Configuration__c IN: orderItemBundleListId 
								AND XC_Max_Months_Renting__c != 0 AND XC_Max_Months_Renting__c != null];
		}
		return orderItemList;
	}
}