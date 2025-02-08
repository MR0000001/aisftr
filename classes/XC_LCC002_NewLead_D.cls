/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 06/09/2018
* @date Modification dd/mm/yyyy
* @description XC_LCC002_NewLead_D – DAO Class for XC_LCC002_NewLead
*/

public without sharing class XC_LCC002_NewLead_D {
	
	/**
	 * @description Retrieve product categories from names. 
	 * @param listProdCatNames the list prod cat names
	 * @return the list
	 */
	public static List<XC_ProductCategoryOfInterest__c> retrieveProductCategoriesFromNames(List<String> listProdCatNames){ 
		Map<Id,XC_ProductCategoryOfInterest__c> listProdCatMap =  new Map<Id,XC_ProductCategoryOfInterest__c>([
			SELECT ID, Name, XC_CommercialVisit__c, XC_AddressesRequired__c 
			FROM XC_ProductCategoryOfInterest__c
			WHERE Name IN: listProdCatNames]); 
		List<XC_ProductCategoryOfInterest__c> listProdCat = listProdCatMap.values();
		return listProdCat;		
	}
}