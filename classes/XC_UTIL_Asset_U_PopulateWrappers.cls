/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 06/05/2019
* @description XC_UTIL_Asset_U_PopulateWrappers – Method for populate Wrapper in XC_UTIL_Asset
*/ 

public class XC_UTIL_Asset_U_PopulateWrappers {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Asset'); 

    /**
     * @description Method to populate mapAssetMaintenanceAsset
     * @param populateWrapper - PopulateMaintenanceAssetWrapper
     */
    public static void populateMaintenanceAsset(XC_UTIL_Asset.PopulateMaintenanceAssetWrapper populateWrapper) {
        if(!populateWrapper.maintenanceAssetList.isEmpty()){
            Asset assetAirConditioning = new Asset();
            populateWrapper.wr.isAssetActive = true;
            populateWrapper.wr.isMaintenanceAssetActive = true;
            for(Asset asset : populateWrapper.maintenanceAssetList){
                if(asset.XC_Product_Name_LIC__c.contains('aire acondicionado') && ('Add').equals(asset.NE__Action__c)){
                    assetAirConditioning = asset;
                }
            }
            if(String.isNotBlank(assetAirConditioning.Id)){
                populateWrapper.mapAssetMaintenanceAsset.put(populateWrapper.assetId, assetAirConditioning.Id); 
            }else{
                populateWrapper.mapAssetMaintenanceAsset.put(populateWrapper.assetId, populateWrapper.maintenanceAssetList[0].Id); 
            }
        } else { 
            populateWrapper.wr.isAssetActive = false;
        }
    }

     /**
     * @description Method to populate AssetMaintenanceWrapper
     * @param listAssetIds - List<String>
     * @return assetMaintenanceWrapper
    **/
    public static XC_UTIL_Asset_U.AssetMaintenanceWrapper populateAssetMaintenanceWrapper(List<String> listAssetIds) { 
        Map<Id, Asset> mapAsset = XC_UTIL_Asset.retrieveMapAssetMaintenance(listAssetIds);       
        XC_UTIL_Asset_U.AssetMaintenanceWrapper assetMaintenanceWrapper = new XC_UTIL_Asset_U.AssetMaintenanceWrapper();
        for(String assetId : listAssetIds){
            Asset a = mapAsset.get(assetId);
            if(a.Status == Label.XC_CL_Asset_StatusActive){
                if(a.NE__Bundle_Configuration__c != null){
                    assetMaintenanceWrapper.mapAssetBundleAsset.put(assetId, a.NE__Bundle_Configuration__c);
                    if(a.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || a.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia){
                        assetMaintenanceWrapper.skipCheckYearFrequency = true;
                    }
                }else {
                    XC_UTIL_Asset.MaintenanceWrapper wr = new XC_UTIL_Asset.MaintenanceWrapper();
                    wr.isAssetActive = true;
                    if(!a.NE__Assets__r.isEmpty()){
                        wr.isMaintenanceAssetActive = true;
                        assetMaintenanceWrapper.mapAssetMaintenanceAsset.put(assetId, a.NE__Assets__r[0].Id); 
                    }else if((a.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || a.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && a.XC_Product_Type__c == 'Coverage' && a.XC_Product_Subtype__c == 'Maintenance'){
                        wr.isMaintenanceAssetActive = true;
                    	assetMaintenanceWrapper.mapAssetMaintenanceAsset.put(assetId, assetId); 
                        assetMaintenanceWrapper.skipCheckYearFrequency = true;
                    }else { 
                        wr.isMaintenanceAssetActive = false;
                    }
                    assetMaintenanceWrapper.mapAssetMaintenanceWrapper.put(assetId, wr);
                }
            } else {
                XC_UTIL_Asset.MaintenanceWrapper wr = new XC_UTIL_Asset.MaintenanceWrapper();
                wr.isAssetActive = false;
                assetMaintenanceWrapper.mapAssetMaintenanceWrapper.put(assetId, wr);
            }
        }
        return assetMaintenanceWrapper;
    }  
}