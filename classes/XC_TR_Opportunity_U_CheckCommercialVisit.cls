/**
 * The Class XC_TR_Opportunity_U_CheckCommercialVisit.
 *
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 26/09/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Opportunity_U_CheckCommercialVisit – Check if the Commercial Visit is required
 */ 

public class XC_TR_Opportunity_U_CheckCommercialVisit {

    /**
     *  @description Gets the commercial visit required.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void getCommercialVisitRequired(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        List<String> fieldsToCheck = new List<String>{'XC_ProductCategoryOfInterest__c'};
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
        if(!listChanged.isEmpty()){
            getProductCategoryCommercialVisit(listChanged);
        }
    }

    /**
     *  @description Gets the product category commercial visit.     *
     * @param listNew the list new
     */
    public static void getProductCategoryCommercialVisit (List<Opportunity> listNew){
        List<String> listProductCategoryNames = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_ProductCategoryOfInterest__c');
        if(!listProductCategoryNames.isEmpty()){
            List<XC_ProductCategoryOfInterest__c> productsOfInterest = XC_TR_Lead_U_CheckDuplicates_D.retrieveProductCategoriesFromNames(listProductCategoryNames);
            for(Opportunity opp : listNew){
                for (XC_ProductCategoryOfInterest__c prodInt : productsOfInterest){
                    if(opp.XC_ProductCategoryOfInterest__c == prodInt.Name){
                        opp.XC_CommercialVisitRequired__c = isCommercialVisitRequired(opp, prodInt);
                        opp.XC_TypeOfAddressRequired__c = prodInt.XC_AddressesRequired__c;
                    }
                }    
            }
        } 
    }

    /**
     * @description check if the Commercial Visit is Required
     * @param opp
     * @param prodInt
     * @return Boolean
     */
    private static Boolean isCommercialVisitRequired (Opportunity opp, XC_ProductCategoryOfInterest__c prodInt){
        if(opp.XC_IsTechnicalQuote__c){
            return false;
        }
        return prodInt.XC_CommercialVisit__c;
    }

}