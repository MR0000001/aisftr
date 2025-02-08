/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 07/11/2018
* @date Modification 08/11/2018
* @description XC_TR_AssetItemAttribute_U_CheckWarranty - Manage the Warranty Asset
*/

public without sharing class XC_TR_AssetItemAttribute_U_CheckWarranty {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AssetItemAttribute_U_CheckWarranty');

    /**
     * @description  After asset item attribute insert.
     * @param listNew the list new
     */
    public static void afterAssetItemAttributeInsert(List<NE__AssetItemAttribute__c> listNew) {
		populateWarrantyEndDateOnAssetInsert(listNew);
	}


    /**
     * @description  After asset item attribute update.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void afterAssetItemAttributeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		List<String> fieldList = new List<String>{'NE__Value__c', 'NE__Old_Value__c'};
		List<NE__AssetItemAttribute__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            populateWarrantyEndDateOnAssetUpdate(listChanged);
		}
	}


    /**
     * @description Populate warranty end date on asset insert.
     * @param assetItemAttToProcess the asset item att to process
     */
    private static void populateWarrantyEndDateOnAssetInsert(List<NE__AssetItemAttribute__c> assetItemAttToProcess) {
        List<Asset> assetToUpdateList = new List<Asset>();
        
        List<NE__AssetItemAttribute__c> assetItemAttMoreInfo = getMoreInfoFromAssetItemAttribute(assetItemAttToProcess);
        for(NE__AssetItemAttribute__c a : assetItemAttMoreInfo) {

            if(a.XC_DeveloperName__c == Label.XC_CL_AssetItemAttribute_Warranty && a.NE__Asset__r.XC_Warranty_End_Date__c == null && a.NE__Value__c != null) {
                Asset assetToUpdate = new Asset();
                assetToUpdate.Id = a.NE__Asset__c;
                Integer yearsWarranty = Integer.valueOf(a.NE__Value__c.split(' ')[0]);
                assetToUpdate.XC_Warranty_End_Date__c = System.today().addYears(yearsWarranty);
                assetToUpdateList.add(assetToUpdate);
            }
        }

        XC_UTIL_Sobject.updateListRecords(assetToUpdateList);
    }


    /**
     * @description Populate warranty end date on asset update.
     * @param assetItemAttToProcess the asset item att to process
     */
    private static void populateWarrantyEndDateOnAssetUpdate(List<NE__AssetItemAttribute__c> assetItemAttToProcess) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in UPDATE AssetItemAttribute');
        List<Asset> assetToUpdateList = new List<Asset>();
        
        List<NE__AssetItemAttribute__c> assetItemAttMoreInfo = getMoreInfoFromAssetItemAttribute(assetItemAttToProcess);

        for(NE__AssetItemAttribute__c a : assetItemAttMoreInfo) {

            if(a.XC_DeveloperName__c == Label.XC_CL_AssetItemAttribute_Warranty && a.NE__Value__c != null && a.NE__Old_Value__c != null && a.NE__Asset__r.XC_Warranty_End_Date__c != null) {
                Asset assetToUpdate = new Asset();
                assetToUpdate.Id = a.NE__Asset__c;
                Integer valueNew = Integer.valueOf(a.NE__Value__c.split(' ')[0]);
                Integer valueOld = Integer.valueOf(a.NE__Old_Value__c.split(' ')[0]);
                assetToUpdate.XC_Warranty_End_Date__c = a.NE__Asset__r.XC_Warranty_End_Date__c.addYears( valueNew - valueOld );
                assetToUpdateList.add(assetToUpdate);
            }
        }
        XC_UTIL_Sobject.updateListRecords(assetToUpdateList);
    }


    /**
     * @description Gets the more info from asset item attribute.
     * @param assetItemAttList the asset item att list
     * @return the more info from asset item attribute
     */
    private static List<NE__AssetItemAttribute__c> getMoreInfoFromAssetItemAttribute(List<NE__AssetItemAttribute__c> assetItemAttList) {
		List<NE__AssetItemAttribute__c> newAssetItemAttributeList = new List<NE__AssetItemAttribute__c>();
		List<Id> idList = getAssetItemAttributeIds(assetItemAttList);

		Map<Id,NE__AssetItemAttribute__c> newAssetItemAttributeListMap = 
                new Map<Id,NE__AssetItemAttribute__c>([SELECT Id, Name, NE__Value__c, NE__Old_Value__c, XC_DeveloperName__c, NE__Asset__c, NE__Asset__r.XC_Warranty_End_Date__c
                                                        FROM NE__AssetItemAttribute__c
                                                        WHERE Id IN :idList]);

        newAssetItemAttributeList = newAssetItemAttributeListMap.values();

		return newAssetItemAttributeList;
	}


    /**
     * @description Gets the asset item attribute ids.
     * @param assetItemAttList the asset item att list
     * @return the asset item attribute ids
     */
    private static List<Id> getAssetItemAttributeIds(List<NE__AssetItemAttribute__c> assetItemAttList) {
		List<Id> idList = new List<Id>();
		for(NE__AssetItemAttribute__c a : assetItemAttList) {
			idList.add(a.Id);
		}
		return idList;
	}

}