/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 12/11/2020
* @date Modification 
* @description Check on insert/update of account fiscal code 
*/

public without sharing class  XC_TR_Account_U_CheckFiscalCode {


    /**
	 * On Account Insert.
	 * @description check if the field has changed
	 * @param listNew the list acc
	 */
	public static void onAccountInsert(List<Account> listNew) {

        List<Account> accList = new List<Account>();
        for(Account a : listNew) {
            if(String.isNotBlank(a.IdentityNumber__c) && (a.IdentityType__c == 'CF' || a.IdentityType__c == 'Codice Fiscale')) {
                accList.add(a);
            }
        }

        if(!accList.isEmpty()) {
            checkFiscalCode(accList);
		}
	}


	/**
	 * On contact update.
	 * @description check if the field has changed
	 * @param listCon the list acc
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void onAccountUpdate(List<Account> listCon, Map<Id,Account> mapOld, Map<Id,Account> mapNew){
		List<String> fieldList = new List<String>{'IdentityNumber__c'};
		List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkFiscalCode(listCon);
		}
	}

    /**
	 * Check fiscal code
	 * @description check the fiscal code validity
	 * @param listCon the list con
	 */
	private static void checkFiscalCode(list<Account> listCon){
        for(Account c:listCon){
            if(c.XC_AccountType__c != 'Residential') {
                continue;
            }

            if(c.IdentityType__c != 'CF' && c.IdentityType__c != 'Codice Fiscale'){
                continue;
            }
            
            XC_UTIL_ITAFiscalCode.CFDataWrapper inputData = new XC_UTIL_ITAFiscalCode.CFDataWrapper();
 
            inputData.cfToValidate = c.IdentityNumber__c;
            inputData.firstName = c.XC_FirstName__c;
            inputData.lastName = c.XC_LastName__c;

            inputData.birthDate = c.XC_BirthDate__c != null ? c.XC_BirthDate__c : null;
         
            XC_UTIL_ITAFiscalCode.CFDataWrapper checkResult = XC_UTIL_ITAFiscalCode.checkItalianCF(inputData);
 
            if(!checkResult.isValid){
                c.addError(inputData.errorCode);
            }
        }
    }
}