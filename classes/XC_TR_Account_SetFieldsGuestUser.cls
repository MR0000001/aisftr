/**
 * Created by dolombardi on 11/07/2022.
 */

public with sharing class XC_TR_Account_SetFieldsGuestUser {
    public static void setFieldsBefore(List<Account> listNew) {
        for(Account account : listNew) {
            if(account.XC_isGuestUser__c) {
                account.XC_isGuestUserPicklist__c = 'Yes';
            }else {
                account.XC_isGuestUserPicklist__c = 'No';
            }
        }

    }

}