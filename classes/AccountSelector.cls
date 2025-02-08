/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : TestAccountSelector
 * @last modified by  : Davide Desideri
 * @last modified on  : 25-01-2023
**/

public without sharing class AccountSelector {
    public static List<Account> getAccountWithGenericConditions(List<String> knowLedgeFields, List<String> whereClause, Date birthday) {
        String query = 'SELECT ';
        for(Integer i=0; i<knowLedgeFields.size(); i++) {
            query += knowLedgeFields[i]+' ,';
        }
        query = query.substring(0, query.length()-1);
        query += 'FROM Account';
        if(whereClause != null && !whereClause.isEmpty()){
            query += ' WHERE ';
            for(Integer i=0; i<whereClause.size(); i++) {
                query += whereClause[i]+' AND';
            }
            query = query.substring(0, query.length()-3);
        }
        System.debug('@@@ query '+query);
        System.debug('@@@ birthday '+birthday);
        return (List<Account>) Database.query(query);
    }

    public static Account getAccountById(Id AccId) {
        Account account = [
                SELECT Id, FirstName, LastName, PersonBirthdate, Gender__pc, Birthday_Place__pc, Birthday_Zone__pc, Birthday_Nation__pc, Fiscal_Code__pc
                FROM Account
                WHERE Id =: AccId
        ];

        return account;
    }

    public static Map<String, Account> getAccountsForGEDPdfByIds(List<String> accountIds) {
        Map<String, Account> accountsMap = new Map<String, Account>([SELECT Account_Fiscal_Code__c, Partita_IVA__c, Name, PersonEmail, Fiscal_Code__pc, Email_Account__c, BillingAddress FROM Account WHERE Id IN: accountIds]);

        return accountsMap;
    }

    public static Account getAccountByFiscalCode(String fiscalCode) {
        return [SELECT Name FROM Account WHERE Fiscal_Code__pc =: fiscalCode];
    }

    public static List<Account> getAccountsByFiscalCode(String fiscalCode) {
        return [SELECT Name FROM Account WHERE Fiscal_Code__pc =: fiscalCode];
    }

    public static List<Account> getAccountsByBusinessAccountKeys(List<String> businessAccountKeys) {
        return [SELECT Type_Sigeud__c, Description_Sigeud__c, Account_Fiscal_Code__c, Partita_IVA__c, Name, Pec__c, Email_Account__c, BillingStreet, BillingPostalCode, BillingCity, BillingState, BusinessAccountKey__c, RecordType.DeveloperName FROM Account WHERE BusinessAccountKey__c =: businessAccountKeys AND RecordType.DeveloperName = 'Business_Account'];
    }

    public static String getBussinessAccountId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.RecordTypeDeveloperName_BusinessAccount).getRecordTypeId();
    }
}