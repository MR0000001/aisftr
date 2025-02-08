/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 11/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_ProdCatAddress – Checks if the product category requires the commercial visit
*/ 
public class XC_TR_Opportunity_U_ProdCatAddress {
 private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_ProdCatAddress');
    /**
	* @author Federico Amici - federico.amici@nttdata.com
	* @description If the product category of the opportunity requires commercial visit and the address field is not filled, the opty is not inserted
	* @param listNew list of the opportunity to be inserted
	*/
    public static void checkProductCategory(List<Opportunity> listNew) {
        
        List<String> listProdCatNames = XC_UTIL_SObject.getListFieldValues(listNew, 'XC_TypeOfAddressRequired__c');

        for(Opportunity o : listNew) {
            if(String.isNotBlank(o.XC_TypeOfAddressRequired__c) &&
                String.isBlank(o.XC_Address__c)) {
                o.addError(Label.XC_CL_ProductCategoryInterest_Address);
            }
        }
        
    }
    
    /**
	* @author Federico Amici - federico.amici@nttdata.com
	* @description Creates the association between the product category and the field XC_AddressRequired__c
	* @param listProdCat list of the prodCat retrieved
    * @return the map
	*/
    /*private static Map<String, String> createMapProductCategoryToCommVisit(List<XC_ProductCategoryOfInterest__c> listProdCat) {
        
        Map<String, String> mapRet = new Map<String, String>();
        
        for(XC_ProductCategoryOfInterest__c prodCat : listProdCat) {
            mapRet.put(prodCat.Name, prodCat.XC_AddressesRequired__c);
        }
        
        return mapRet;
    }*/
}