/**
 * @description The Class XC_LCC025_AssetPath.
 */
public without sharing class XC_LCC025_AssetPath {

	/**
	 * @description Update DB.
	 * @param recordId the record id
	 * @param assetStatus the asset status
	 */
	@AuraEnabled
    public static void updateDB(String recordId, String assetStatus){      
        if(!Schema.sObjectType.Asset.isAccessible()){
            return;
        } 
              
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, Status 
            FROM Asset WHERE Id=:recordId]);

        Asset asset = new Asset();
        asset = assetMap.values();

        asset.Status = assetStatus;
        XC_UTIL_Sobject.updateRecord(asset);
    }
}