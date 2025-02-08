/**
 * @description The Class XC_LCC054_RedirectAsset.
 */
public class XC_LCC054_RedirectAsset {
    
    /**
     * @description Gets the record type id by name.
     *
     * @param recordTypeName the record type name
     * @return the record type id by name
     */
    @AuraEnabled
    public static String getRecordTypeIdByName(String recordTypeName){
        String rt = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return rt;
    }

}