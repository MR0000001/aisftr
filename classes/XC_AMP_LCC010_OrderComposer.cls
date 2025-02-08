/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-17-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-11-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_AMP_LCC010_OrderComposer {


    /**
    * @description init order component with b2w token
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020
    * @param params
    * @return Map<String, Object> 
    **/
    @AuraEnabled 
    public static Map<String,Object> initOrderComposer(Map<String,Object> params){ //String opportunityId, Boolean isFullFlow
        Map<String,Object> orderComposerInfo = XC_AMP_UTIL_ViewConfiguration.getPartnerUserInfo();
        
        //catalog management
        if(Boolean.valueOf(params.get('isFullFlow'))){
            Map<Id,Opportunity> oppData = new Map<Id,Opportunity>([
                SELECT Id, XC_LegalEntity__c, XC_Segment__c
                FROM Opportunity
                WHERE Id =: String.valueOf(params.get('opportunityId'))
            ]);
            Map<String,String> catalogIds = XC_Util_LegalEntityOneOrg.getDefaultCatalogId(new Set<String>{oppData.values()[0].XC_LegalEntity__c}, new Set<String>{oppData.values()[0].XC_Segment__c});
            String key = oppData.values()[0].XC_LegalEntity__c+oppData.values()[0].XC_Segment__c;
            if(String.isNotBlank(catalogIds.get(key))){
                orderComposerInfo.put('catalogId',catalogIds.get(key));
            }
        }

        //catalog categories management
        List<Object> availableCategories = (List<Object>)orderComposerInfo.get('availableCategories');
        if((availableCategories==null || availableCategories.isEmpty()) && String.isNotBlank( String.valueOf(params.get('defaultCatalogCategories')) )){
            XC_AMP_UTIL_ViewConfiguration.getPartnerCatalogCategoriesInfos(orderComposerInfo, String.valueOf(params.get('defaultCatalogCategories')));
        }

        //getting b2w cartApiToken
        Map<String,Object> b2wCartApiInfo = XC_AMP_LCC010_U_CartAPI.retrieveCartAPIToken();
        orderComposerInfo.put('b2wAuth',b2wCartApiInfo);
        return orderComposerInfo;
    }


    /**
    * @description retrieves b2w order products
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-14-2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> retrieveProducts(Map<String,Object> params){
        return XC_AMP_LCC010_U_CartAPI.retrieveCartAPICatalogAndItems(params);
    }


    /**
    * @description upsert product without configuring attributes in first phase via b2w cartapi
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-15-2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> firstUpsertProduct(Map<String,Object> params){
        return XC_AMP_LCC010_U_CartAPI.firstUpsertCartAPICatalogItems(params);
    }

    /**
    * @description do the final checkout and create B2W order
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-15-2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> finalSaveConfiguration(Map<String,Object> params){
        return XC_AMP_LCC010_U_CartAPI.finalSaveConfiguration(params);
    }

    
    /**
    * @description remove item from cart
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-17-2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled 
    public static Map<String,Object> removeItemFromCart(Map<String,Object> params){
        return XC_AMP_LCC010_U_CartAPI.removeItem(params);
    }

}