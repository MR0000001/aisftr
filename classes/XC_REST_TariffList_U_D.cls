/**
 * The Class XC_REST_TariffList_U.
 *
 * @author            : Simone Trenta - strenta@deloitte.it
 * @date Creation     : 04/09/2019
 * @date Modification : 
 * @description       : UTIL for Rest Resource for GetTariffList
 **/

public without sharing class XC_REST_TariffList_U_D {

    /**
     * getCatalogItem
     *
     * @param req the wr req
     * @return the NE__Catalog_Item__c list
     * @description method to read TariffList
     */
    public static List<NE__Catalog_Item__c> getCatalogItem(XC_REST_TariffList_W.RequestElementWrapper req){
        Map<Id, NE__Catalog_Item__c> productMap = new Map<Id, NE__Catalog_Item__c>([
            SELECT Name, NE__ProductId__r.name, NE__ProductId__r.XC_LIC_Product_Name__c, NE__ProductId__r.NE__Description__c, NE__BaseRecurringCharge__c,
                NE__ProductId__r.b2ec__Short_Web_Description__c, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__Engine_Code__c, 
                NE__ProductId__c, NE__Base_OneTime_Fee__c, CurrencyIsoCode 
            FROM NE__Catalog_Item__c 
            WHERE NE__ProductId__c IN (SELECT NE__ProdId__c FROM NE__ProductFamily__c WHERE NE__FamilyId__r.Name IN : req.Families)
            AND NE__Visible__c = true AND NE__Catalog_Id__r.XC_Country__c =: req.Country]);

        return productMap.values();
    }

    /**
     * getProductFamily
     *
     * @param productIdList the productIdList
     * @return the NE__ProductFamily__c list
     * @description method to read TariffList
     */
    public static List<NE__ProductFamily__c> getProductFamily(Set<Id> productIdList){
        Map<Id, NE__ProductFamily__c> prodFamilyMap = new Map<Id, NE__ProductFamily__c>([
            SELECT NE__ProdId__c, Name, NE__FamilyId__r.Name, NE__ProdId__r.Name  
            FROM NE__ProductFamily__c
            WHERE NE__ProdId__c IN :productIdList //and NE__FamilyId__r.Name != :Constants.EMobilityProductFamilyNameZuora 
            /*AND NE__FamilyId__r.Name != :Constants.EMobilityProductFamilyPayPerUse*/]);

        return prodFamilyMap.values();
    }

    /**
     * getTranslation
     *
     * @param productIdList the productIdList
     * @param lang the language
     * @return the NE__Translation__c list
     * @description method to read TariffList
     */
    public static List<NE__Translation__c> getTranslation(Set<Id> productIdList, String lang) {

        Map<Id, XC_CM_LanguageZuoraMapping__mdt> mapLanguageZuora = 
            new Map<Id, XC_CM_LanguageZuoraMapping__mdt>([SELECT Id, XC_NELanguage__c
                                                            FROM XC_CM_LanguageZuoraMapping__mdt
                                                            WHERE XC_Invoice_Language__c =: lang LIMIT 1]);
        
        String language = (!mapLanguageZuora.isEmpty() && String.isNotBlank(mapLanguageZuora.values()[0].XC_NELanguage__c)) ? mapLanguageZuora.values()[0].XC_NELanguage__c : 'en_US';

        Map<Id, NE__Translation__c> translationsMap = 
            new Map<Id, NE__Translation__c>([SELECT Id, NE__Commercial_Product__c, NE__Language_user__c, NE__Description__c, NE__Text__c, NE__Text2__c 
                                                FROM NE__Translation__c 
                                                WHERE NE__Commercial_Product__c IN :productIdList AND NE__Language_user__c =: language]);

        return translationsMap.values();
    }

    /**
     * getProductRatePlanChargeTier
     *
     * @param prodNameList the prodNameList
     * @return the zqu__ProductRatePlanChargeTier__c list
     * @description method to read TariffList
     */
    public static List<zqu__ProductRatePlanChargeTier__c> getProductRatePlanChargeTier(List<String> prodNameList){
        Map<Id, zqu__ProductRatePlanChargeTier__c> zproductMap = new Map<Id, zqu__ProductRatePlanChargeTier__c>([
            SELECT zqu__Price__c,
                zqu__ProductRatePlanCharge__r.zqu__ZUnitOfMeasure__r.Name,
                zqu__ProductRatePlanCharge__r.zqu__RecurringPeriod__c,
                zqu__ProductRatePlanCharge__r.zqu__Type__c,
                zqu__ProductRatePlanCharge__r.zqu__Model__c,
                zqu__ProductRatePlanCharge__r.PIncludedkWh__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.ProductCode,
                zqu__ProductRatePlanCharge__r.zqu__DefaultQuantity__c
            FROM zqu__ProductRatePlanChargeTier__c
            WHERE /*zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.Name IN: prodNameList*/
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.ProductCode IN: prodNameList
                AND zqu__ProductRatePlanCharge__r.PIncludedkWh__c != null]);

        return zproductMap.values();
    }

}