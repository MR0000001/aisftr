/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 21/08/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Lead_U_CheckDuplicates_D – DAO Class for XC_TR_Lead_U_CheckDuplicates
*/ 

public without sharing class XC_TR_Lead_U_CheckDuplicates_D {

	/**
	 * @description Retrieve product categories from names.
	 * @param listProdCatNames the list prod cat names
	 * @return the list
	 */
	 
	public static List<XC_ProductCategoryOfInterest__c> retrieveProductCategoriesFromNames(List<String> listProdCatNames){
		List<XC_ProductCategoryOfInterest__c> listProdCat = new List<XC_ProductCategoryOfInterest__c>();
		if(Schema.sObjectType.XC_ProductCategoryOfInterest__c.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.Id.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.Name.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.XC_CommercialVisit__c.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.XC_AddressesRequired__c.isAccessible()){
			listProdCat = [SELECT ID, Name, XC_CommercialVisit__c ,XC_AddressesRequired__c 
								FROM XC_ProductCategoryOfInterest__c
								WHERE Name IN: listProdCatNames];
		}
		return listProdCat;            					
	}

			
}