/**
 * The Class XC_TR_Account_U_ConcatenatePhone.
 * @author Simone Trenta - strenta@deloitte.it, Luca Tedeschi - ltedeschi@deloitte.it
 * @date Creation 17/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Account_U_ConcatenatePhone Concatenate AccountPhonePrefix and AccountPhone in Phone and MainPhonePrefix and AccountMainPhone in MainPhone
 */

public class XC_TR_Account_U_ConcatenatePhone {
    /**
     * Concatenate phone on insert.
     * @description 
     * @param listNew the list new
     */
    public static void concatenatePhoneOnInsert(List<Account> listNew){
        for(Account newAccount : listNew) {        
            if(!String.isBlank(newAccount.XC_AccountPhonePrefix__c) && !String.isBlank(newAccount.XC_AccountPhone__c)) {
                newAccount.Phone = '+' + newAccount.XC_AccountPhonePrefix__c.substringAfterLast('+') + newAccount.XC_AccountPhone__c;
            } else {
                newAccount.Phone = '';
            }
            if(!String.isBlank(newAccount.XC_MainPhonePrefix__c) && !String.isBlank(newAccount.XC_AccountMainPhone__c)) {
                newAccount.MainPhone__c = '+' + newAccount.XC_MainPhonePrefix__c.substringAfterLast('+') + newAccount.XC_AccountMainPhone__c;
            } else {
                newAccount.MainPhone__c = '';
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
    public static void concatenatePhoneOnUpdate(List<Account> listNew, Map<id, Account> mapOld, Map<id, Account> mapNew) {
        List<String> fieldToCheck = new List<String>{'XC_AccountPhonePrefix__c', 'XC_AccountPhone__c', 'XC_MainPhonePrefix__c', 'XC_AccountMainPhone__c'};
        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(!listNew.isEmpty()) {
            concatenatePhoneOnInsert(listNew);
        }
    }
    
    /**
     * Concatenate Name on insert.
     * @description 
     * @param listNew the list new
     */
    public static void concatenateNameOnInsert(List<Account> listNew){
        for(Account newAccount : listNew) {       
            if(XC_UTIL_Account.isResidential(newAccount.RecordTypeId)) {
                newAccount.Name = newAccount.XC_FirstName__c + ' ' + newAccount.XC_LastName__c;
            }
        }            
    }
    
    /**
     * @description Concatenate name on update.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void concatenateNameOnUpdate(List<Account> listNew, Map<id, Account> mapOld, Map<id, Account> mapNew) {
        List<String> fieldToCheck = new List<String>{'XC_FirstName__c', 'XC_LastName__c'};
        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(!listNew.isEmpty()) {
            concatenateNameOnInsert(listNew);
        }
    }

        /**
     * Concatenate Name on insert.
     * @description 
     * @param listNew the list new
     */
    public static void setSplitPayment(List<Account> listNew){
        for(Account newAccount : listNew) {       
            if((newAccount.XC_Segment__c == 'B2B' || newAccount.XC_Segment__c == 'B2G') && newAccount.XC_AccountTaxType__c  != null) {
                newAccount.XC_SplitPayment__c = newAccount.XC_AccountTaxType__c == 'Pubblica Amministrazione';
            }
        }            
    }
}