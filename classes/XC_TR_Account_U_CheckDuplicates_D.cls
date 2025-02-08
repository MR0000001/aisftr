/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 30/08/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Account_U_CheckDuplicates_D – DAO for the XC_TR_Account_U_CheckDuplicates_D class 
*/

public without sharing class XC_TR_Account_U_CheckDuplicates_D {

    /**
     * Gets the account in fiscal code list.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param accountToCheckFiscalCode the account to check fiscal code
     * @return the account in fiscal code list
     * @description Search if exist an account by Fiscal Code
     */
    public static List<Account> getAccountInFiscalCodeList(List<Account> accountToCheckFiscalCode){
    List<String> accountDocIDValues = XC_UTIL_Sobject.getListFieldValues(accountToCheckFiscalCode, 'IdentityNumber__c');
    List<String> accountDocTypeValues = XC_UTIL_Sobject.getListFieldValues(accountToCheckFiscalCode, 'IdentityType__c');
            
    Map<Id,Account> allAccountMap = new Map<Id,Account>([
        SELECT Id, Name, IdentityNumber__c,IdentityType__c, XC_SkipDuplication__c,PrimaryEmail__c,XC_FirstName__c,XC_LastName__c, RecordTypeId, XC_CommercialCode__c, MainPhone__c,Phone, XC_BirthDate__c, XC_InternalCommercialCode__c
        FROM Account  
        WHERE IdentityNumber__c IN: accountDocIDValues
        AND IdentityType__c IN: accountDocTypeValues]);
    List<Account> allAccount = allAccountMap.values();

            return allAccount;
        }

    /**
     * Gets the account in email list.
     *
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @param accountToCheckEmail the account to check email
     * @return the account in email list
     * @description Search if exist an account by Email
     */
    public static List<Account> getAccountInEmailList(List<Account> accountToCheckEmail){
        List<String> accountEmail = XC_UTIL_Sobject.getListFieldValues(accountToCheckEmail, 'PrimaryEmail__c');

        Map<Id,Account> allAccountMap = new Map<Id,Account>([
            SELECT Id, Name, IdentityNumber__c, PrimaryEmail__c, RecordTypeId,XC_AccountPhone__c,XC_AccountPhonePrefix__c,XC_LastName__c,XC_FirstName__c
            FROM Account 
            WHERE PrimaryEmail__c IN: accountEmail]);    
        List<Account> allAccount = allAccountMap.values();

        return allAccount;
    }  
}