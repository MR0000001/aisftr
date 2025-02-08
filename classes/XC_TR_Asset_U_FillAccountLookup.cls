/**
 * The Class XC_TR_Asset_U_FillAccountLookup.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 11/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to fill the Account lookup on Asset
 **/ 


public without sharing class XC_TR_Asset_U_FillAccountLookup {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_U_FillAccountLookup');

    /**
    * OnBeforeUpdate.
    * 
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description Fill Account field
    */
    public static void onBeforeUpdate(List<Asset> listNew, Map<Id, Asset> mapOld, Map<Id, Asset> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Asset_U_FillAccountLookup.onBeforeUpdate');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '#listChanged -> ' + listChanged);

        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Contact.AccountId FROM Asset WHERE Id IN: mapNew.keySet()]);
        for(Asset asset : listChanged) {
			if(asset.Status != 'Suspended' && asset.Status != 'Inactive') {
				asset.AccountId = assetMap.get(asset.Id).Contact.AccountId;
			}
		}
    }
}