/**
 * Created by dolombardi on 12/07/2022.
 */
@IsTest
public with sharing class XC_TR_Account_SetFieldsGuestUser_TEST {
    @isTest
    static void checkIsGuestUser(){
        Account a = new Account(XC_isGuestUser__c = true);
        List<Account> listAccount = new List<Account>();
        listAccount.add(a);
        XC_TR_Account_SetFieldsGuestUser.setFieldsBefore(listAccount);
    }

}