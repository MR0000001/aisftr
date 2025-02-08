/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @description XC_UTIL_Asset_U – Method for XC_UTIL_Asset
*/ 

public class XC_UTIL_Asset_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Asset'); 

    /** @description PopulateAssetMaintenanceWrapper */
    public class AssetMaintenanceWrapper {
        public Map<Id, Id> mapAssetMaintenanceAsset = new Map<Id, Id>(); //map that assigns to each Asset the corresponding Maintenance Asset
        public Map<Id, Id> mapAssetBundleAsset = new Map<Id, Id>(); //map that assigns to each Asset the corresponding bundle Asset
        public Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapAssetMaintenanceWrapper = new Map<Id, XC_UTIL_Asset.MaintenanceWrapper>();
        public Boolean skipCheckYearFrequency = false;
    }

    /**
     * @description Method to check year (FOR CYCLOMATIC COMPLEXITY)
     * @param yearFrequency - Integer
     * @param mapAssetMaintenanceWrapper - Map<Id, MaintenanceWrapper>
     * @param assetId - String
     * @return MaintenanceWrapper
     */
    public static XC_UTIL_Asset.MaintenanceWrapper checkYear(Integer yearFrequency, Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapAssetMaintenanceWrapper, String assetId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@checkYear START');
        XC_UTIL_Asset.MaintenanceWrapper wr;
        if(yearFrequency > 0){
            wr = mapAssetMaintenanceWrapper.get(assetId);
            wr.yearFrequency = yearFrequency;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@checkYear END');
        return wr;
    }
}