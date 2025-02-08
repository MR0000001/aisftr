/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 12/11/2020
* @date Modification 
* @description Check on insert/update of account fiscal code 
*/

public without sharing class  XC_TR_PersonalDoc_U_CheckFiscalCode {

    /**
	 * On personal document insert.
	 * @description check if the field has changed
	 * @param listNew the list pd
	 */
	public static void onPersonalDocumentInsert(List<XC_PersonalDocument__c> listNew) {

		List<XC_PersonalDocument__c> pdList = new List<XC_PersonalDocument__c>();
        for(XC_PersonalDocument__c pd : listNew) {
            if(String.isNotBlank(pd.XC_Contact__c) && String.isNotBlank(pd.XC_DocumentNumber__c) && (pd.XC_DocumentType__c == 'CF' || pd.XC_DocumentType__c == 'Codice Fiscale')) {
                pdList.add(pd);
            }
        }

        if(!pdList.isEmpty()) {
            checkFiscalCode(pdList);
		}
	}


	/**
	 * On contact update.
	 * @description check if the field has changed
	 * @param listCon the list acc
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void onPersonalDocumentUpdate(List<XC_PersonalDocument__c> listCon, Map<Id,XC_PersonalDocument__c> mapOld, Map<Id,XC_PersonalDocument__c> mapNew){
		List<String> fieldList = new List<String>{'XC_DocumentNumber__c'};
		List<XC_PersonalDocument__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkFiscalCode(listCon);
		}
	}

    /**
	 * Check fiscal code
	 * @description check the fiscal code validity
	 * @param listCon the list con
	 */
	private static void checkFiscalCode(list<XC_PersonalDocument__c> listCon){

        List<String> listConId = new List<String>();
        for(XC_PersonalDocument__c c:listCon){
            listConId.add(c.XC_Contact__c);
        }

        Map<Id,Contact> mapCon = new Map<Id,Contact>([
            SELECT id, FirstName, LastName, Birthdate, XC_Sex__c  FROM Contact WHERE id IN: listConId
        ]);
 
        for(XC_PersonalDocument__c c:listCon){
            if(c.XC_DocumentType__c != 'CF' && c.XC_DocumentType__c != 'Codice Fiscale'){
                continue;
            }

            XC_UTIL_ITAFiscalCode.CFDataWrapper inputData = new XC_UTIL_ITAFiscalCode.CFDataWrapper();
 
            inputData.cfToValidate = c.XC_DocumentNumber__c;
            inputData.firstName = mapCon.get(c.XC_Contact__c).FirstName;
            inputData.lastName = mapCon.get(c.XC_Contact__c).LastName;

            inputData.birthDate = mapCon.get(c.XC_Contact__c).Birthdate != null ? mapCon.get(c.XC_Contact__c).Birthdate : null;
            inputData.sex = !String.isBlank(mapCon.get(c.XC_Contact__c).XC_Sex__c) ? mapCon.get(c.XC_Contact__c).XC_Sex__c : null;
         
            XC_UTIL_ITAFiscalCode.CFDataWrapper checkResult = XC_UTIL_ITAFiscalCode.checkItalianCF(inputData);
 
            if(!checkResult.isValid){
                c.addError(inputData.errorCode);
            }
        }
    }
}