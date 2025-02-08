/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 06/10/2020
* @date Modification 
* @description Check on insert/update of contact fiscal code 
*/

public without sharing class  XC_TR_Contact_U_CheckFiscalCode {

    /**
	 * On contact insert.
	 * @description check on insert
	 * @param listCon the list con
	 */
	public static void onContactInsert(List<Contact> listCon){
		checkFiscalCode(listCon);
	}

	/**
	 * On contact update.
	 * @description check if the field has changed
	 * @param listCon the list con
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void onContactUpdate(List<Contact> listCon, Map<Id,Contact> mapOld, Map<Id,Contact> mapNew){
		List<String> fieldList = new List<String>{'XC_ContactDocumentNumber__c'};
		List<NE__AssetItemAttribute__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkFiscalCode(listCon);
		}
	}

    /**
	 * Check fiscal code
	 * @description check the fiscal code validity
	 * @param listCon the list con
	 */
	private static void checkFiscalCode(list<Contact> listCon){
        for(Contact c:listCon){
            if(c.XC_ContactDocumentType__c != 'CF' && c.XC_ContactDocumentType__c != 'Codice Fiscale'){
                continue;
            }
            
            XC_UTIL_ITAFiscalCode.CFDataWrapper inputData = new XC_UTIL_ITAFiscalCode.CFDataWrapper();
 
            inputData.cfToValidate = c.XC_ContactDocumentNumber__c;
            inputData.firstName = c.FirstName;
            inputData.lastName = c.LastName;

            inputData.birthDate = c.Birthdate != null ? c.Birthdate : null;
            inputData.sex = !String.isBlank(c.XC_Sex__c) ? c.XC_Sex__c : null;
         
            XC_UTIL_ITAFiscalCode.CFDataWrapper checkResult = XC_UTIL_ITAFiscalCode.checkItalianCF(inputData);
 
            if(!checkResult.isValid){
                c.addError(inputData.errorCode);
            }
        }
    }

}