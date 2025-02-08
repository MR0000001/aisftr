/**
 * The Class XC_TR_Contact_U_ConcatenatePhone.
 *
 * @author Luca Tedeschi - ltedeschi@deloitte.it
 * @date Creation 17/09/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Account_U_ConcatenatePhone Concatenate PhonePrefix and ContactPhone in Phone and MobilePrefix and ContactMobile in MobilePhone
 */

public class XC_TR_Contact_U_ConcatenatePhone { 
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_U_ConcatenatePhone');
    /**
     * @description Concatenate phone on insert.
     *
     * @param listNew the list new
     */
    public  static void concatenatePhoneOnInsert(List<Contact> listNew){
             
        for(Contact newContact : listNew) {             
            if (!String.isBlank(newContact.XC_PhonePrefix__c) && !String.isBlank(newContact.XC_ContactPhone__c)){
            	newContact.Phone = '+' + newContact.XC_PhonePrefix__c.substringAfterLast('+') + newContact.XC_ContactPhone__c;
            }
            else {
                newContact.Phone = '';
            }
			if (!String.isBlank(newContact.XC_MobilePrefix__c) && !String.isBlank(newContact.XC_ContactMobile__c)) {           
            	newContact.MobilePhone = '+' + newContact.XC_MobilePrefix__c.substringAfterLast('+') + newContact.XC_ContactMobile__c;
            }else{
                newContact.MobilePhone = '';
            }
        } 
    }
    
    /**
     * @description Concatenate phone on update.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public  static void concatenatePhoneOnUpdate(List<Contact> listNew, Map<id, Contact> mapOld, Map<id, Contact> mapNew){
        
            List<String> fieldToCheck = new List<String>{'XC_PhonePrefix__c', 'XC_ContactPhone__c', 'XC_MobilePrefix__c', 'XC_ContactMobile__c'};
            ListNew = XC_UTIL_Sobject.getListChanged(fieldToCheck, mapOld, mapNew);
        
             
       		ConcatenatePhoneOnInsert(ListNew);
    }
}