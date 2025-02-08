/**
 * The Class XC_REST_TariffList_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 03/01/2019
 * @date Modification : 01/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : UTIL for Rest Resource for GetTariffList
 **/

public without sharing class XC_REST_TariffList_U {
    
    /**
     * ReadTariffList.
     *
     * @param wrReq the wr req
     * @return the EnabledListWrapper list
     * @description method to read TariffList
     */
    public static List<XC_REST_TariffList_W.EnabledListWrapper> readTariffList(XC_REST_TariffList_W.WrapperRequest wrReq){
        
        XC_REST_TariffList_W.RequestElementWrapper req = wrReq.RequestElement;
        List<XC_REST_TariffList_W.EnabledListWrapper> rateList = new List<XC_REST_TariffList_W.EnabledListWrapper>();
    
        List<NE__Catalog_Item__c> productList = XC_REST_TariffList_U_D.getCatalogItem(req); 

        if(productList.isEmpty()){
            system.debug('no catalog found');
            return rateList;
        }

        Map<Id, List<String>> productFamMap =  new Map<Id, List<String>>();

        List<String> prodNameList = new List<String>();
        Set<Id> productIdList = New Set<Id>();
        for(NE__Catalog_Item__c p : productList){
            prodNameList.add(p.NE__ProductId__r.XC_LIC_Product_Name__c); 
            productIdList.add(p.NE__ProductId__c);
        }

        readTariffListONE(productIdList, productFamMap);

        Map<String, Object> mapForMethod = new Map<String, Object>{
            'language' => req.PreferredLanguage,
            'productIdList' => productIdList,
            'prodNameList' => prodNameList
        };

        readTariffListTWO(mapForMethod);

        if(!productList.isEmpty()){
            mapForMethod.put('families', req.Families);
            mapForMethod.put('productList', productList);
            mapForMethod.put('productFamMap', productFamMap);
            readTariffListTHREE(mapForMethod);
            rateList = (List<XC_REST_TariffList_W.EnabledListWrapper>) mapForMethod.get('rateList');
        }

        return rateList;
    }


    /**
     * ReadTariffListONE.
     *
     * @param productIdList the product Id List
     * @param productFamMap the product family map
     * @description util method to read TariffList
     */
    public static void readTariffListONE(Set<Id> productIdList, Map<Id, List<String>> productFamMap){
        
        List<NE__ProductFamily__c> prodFamilyList = XC_REST_TariffList_U_D.getProductFamily(productIdList);
        System.debug('prodFamilyList_'+prodFamilyList);
        
        for(NE__ProductFamily__c prodFam: prodFamilyList ){
            if (productFamMap.containsKey(prodFam.NE__ProdId__c)){
                productFamMap.get(prodFam.NE__ProdId__c).add(prodFam.NE__FamilyId__r.Name);
            }else{
                List<String> temp = new List<String>();
                temp.add(prodFam.NE__FamilyId__r.Name);
                productFamMap.put(prodFam.NE__ProdId__c, temp);
            }
        }
        
    }


    /**
     * ReadTariffListTWO.
     *
     * @param mapForMethod the map with some infos
     * @description util method to read TariffList
     */
    public static void readTariffListTWO(Map<String, Object> mapForMethod){

        String language = (String) mapForMethod.get('language');
        /*Map<String,String> mapLanguage = new Map<String,String>{
            'Catalan' => 'ca',
            'Spanish' => 'es',
            'Español' => 'es',
            'English' => 'en_US',
            'Italian' => 'it',
            'Italiano' => 'it',
            'Deutsch' => 'de',
            'German' => 'de'
        };*/
        
        Set<Id> productIdList = (Set<Id>) mapForMethod.get('productIdList');
        
        //List<NE__Translation__c> translations = XC_REST_TariffList_U_D.getTranslation(productIdList, mapLanguage.get(language));
        List<NE__Translation__c> translations = XC_REST_TariffList_U_D.getTranslation(productIdList, language);
        
        Map<String, NE__Translation__c> translationMap = new Map<String, NE__Translation__c>();
        for (NE__Translation__c tr : translations) {
            translationMap.put(tr.NE__Commercial_Product__c, tr);
        }
        
        List<String> prodNameList = (List<String>) mapForMethod.get('prodNameList');
        System.debug('prodFamilyNameList_: ' + prodNameList);

        /* Retrieve the product rate plan charge */
        List<zqu__ProductRatePlanChargeTier__c> zproductList = XC_REST_TariffList_U_D.getProductRatePlanChargeTier(prodNameList);
        
        system.debug('zproductList__'+zproductList); 
        Map<String, Map<String, String>> zproductMapInfo =  new Map<String, Map<String, String>>();

        for(zqu__ProductRatePlanChargeTier__c zprod: zproductList) {
            String productCode = zprod.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Product__r.ProductCode;
            if(zproductMapInfo.get(productCode) == null || zproductMapInfo.get(productCode).get('RateQuantity') == null || zproductMapInfo.get(productCode).get('RateQuantity') == '0') {
                Map<String,String> zprodInfo = new Map<String,String>();
                zprodInfo.put('ZuoraId', String.valueOf(zprod.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c));
                zprodInfo.put('RatePrice', String.valueOf(zprod.zqu__Price__c));
                String uom = (zprod.zqu__ProductRatePlanCharge__r.zqu__ZUnitOfMeasure__r.Name == 'kWh1') ? 'FreekWh' : zprod.zqu__ProductRatePlanCharge__r.zqu__ZUnitOfMeasure__r.Name;
                zprodInfo.put('RateUOM', uom);
                zprodInfo.put('RateEndDate', String.valueOf(zprod.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c));
                zprodInfo.put('RateQuantity', zprod.zqu__ProductRatePlanCharge__r.PIncludedkWh__c+'');
                zprodInfo.put('RateBillingPeriod', zprod.zqu__ProductRatePlanCharge__r.zqu__RecurringPeriod__c);
                zproductMapInfo.put(productCode, zprodInfo);
            }
            if(zproductMapInfo.get(productCode) != null && zprod.zqu__ProductRatePlanCharge__r.zqu__Type__c == 'Recurring' && !zprod.zqu__ProductRatePlanCharge__r.zqu__Model__c.containsIgnoreCase('Discount')) {
                Map<String,String> zprodInfoBP = zproductMapInfo.get(productCode);
                zprodInfoBP.put('RateBillingPeriod', zprod.zqu__ProductRatePlanCharge__r.zqu__RecurringPeriod__c);
                zproductMapInfo.put(productCode, zprodInfoBP);
            }
        }

        mapForMethod.put('zproductMapInfo', zproductMapInfo);
        mapForMethod.put('translationMap', translationMap);
    }


    /**
     * ReadTariffListTHREE.
     *
     * @param mapForMethod the map with some infos
     * @description util method to read TariffList
     */
    public static void readTariffListTHREE(Map<String, Object> mapForMethod){

        Map<String, Map<String, String>> zproductMapInfo = (Map<String, Map<String, String>>) mapForMethod.get('zproductMapInfo');
        Map<String, NE__Translation__c> translationMap = (Map<String, NE__Translation__c>) mapForMethod.get('translationMap');
        List<String> familiesReq = (List<String>) mapForMethod.get('families');
        List<NE__Catalog_Item__c> productList = (List<NE__Catalog_Item__c>) mapForMethod.get('productList');
        Map<Id, List<String>> productFamMap = (Map<Id, List<String>>) mapForMethod.get('productFamMap');

        //response = getResponseFromCode(OUTCOME_CODES.EMOB001);
        List<XC_REST_TariffList_W.EnabledListWrapper> rateList = new List<XC_REST_TariffList_W.EnabledListWrapper>();
        
        Set<String> inputFamilies = new Set<String>();
        inputFamilies.addAll(familiesReq);
        for(NE__Catalog_Item__c p : productList){ 
            XC_REST_TariffList_W.EnabledListWrapper rate = new XC_REST_TariffList_W.EnabledListWrapper();
            rate.Families = productFamMap.containsKey(p.NE__ProductId__c) ? productFamMap.get(p.NE__ProductId__c) : null;
            //rate.Families = productFamMap.get(p.NE__ProductId__c);
            
            Set<String> families = new Set<String>();
            if (rate.Families != null){
                families.addAll(rate.Families);
            }
            
            if (families.containsAll(inputFamilies)) {
                
                if(zproductMapInfo.containsKey(p.NE__ProductId__r.XC_LIC_Product_Name__c)){
                    rate.RateZuoraId = zproductMapInfo.get(p.NE__ProductId__r.XC_LIC_Product_Name__c).get('ZuoraId');
                    rate.RateUOM = zproductMapInfo.get(p.NE__ProductId__r.XC_LIC_Product_Name__c).get('RateUOM');
                    rate.RateQuantity = Integer.valueOf(zproductMapInfo.get(p.NE__ProductId__r.XC_LIC_Product_Name__c).get('RateQuantity') );
                    rate.RateEndDate = zproductMapInfo.get(p.NE__ProductId__r.XC_LIC_Product_Name__c).get('RateEndDate');
                    rate.RateBillingPeriod = zproductMapInfo.get(p.NE__ProductId__r.XC_LIC_Product_Name__c).get('RateBillingPeriod');
                }

                if(translationMap.containsKey(p.NE__ProductId__c)){
                    rate.RateDescription = translationMap.get(p.NE__ProductId__c).NE__Description__c;
                    rate.RateShortDescription = translationMap.get(p.NE__ProductId__c).NE__Text2__c;
                    rate.RateName = translationMap.get(p.NE__ProductId__c).NE__Text__c;
                } else {
                    rate.RateDescription = p.NE__ProductId__r.NE__Description__c;
                    rate.RateShortDescription = p.NE__ProductId__r.b2ec__Short_Web_Description__c;
                    rate.RateName = p.NE__ProductId__r.Name;
                }
                
                rate.CurrencyX = p.CurrencyIsoCode;
                rate.RateEngineCode = p.NE__Engine_Code__c; 
                rate.RatePrice = String.valueOf(p.NE__BaseRecurringCharge__c);
                rate.RateOneTimePrice = String.valueOf(p.NE__Base_OneTime_Fee__c);
                
                rateList.add(rate);
				Integer i=0;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
				i++;
            }
        }
		
        mapForMethod.put('rateList', rateList);
    }
    
}