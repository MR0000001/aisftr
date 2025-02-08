/**
 * Created by snekkanti002 on 16/09/2021.
 */

public without sharing class AccountService {
    public static Map<String, Account> getAccountsForGEDPdfByIds(Map<String, String> caseIdAccountId) {
        DebugService.printLimits('AccountService', 'getAccountsForGEDPdfByIds', 'start');
        Map<String, Account> caseIdAccountDetailMap = new Map<String, Account>();

        Map<String, Account> accountsMap = AccountSelector.getAccountsForGEDPdfByIds(caseIdAccountId.values());

        for(String cId : caseIdAccountId.keySet()) {
            caseIdAccountDetailMap.put(cId, accountsMap.get(caseIdAccountId.get(cId)));
        }

        DebugService.printLimits('AccountService', 'getAccountsForGEDPdfByIds', 'end');
        return caseIdAccountDetailMap;
    }

    public static List<Historical_IAM__c> postProcessIAMCallout(List<Account> accounts, ResponseIAM responseIAM) {
        DebugService.printLimits('AccountService', 'postProcessIAMCallout', 'start');
        List<Historical_IAM__c> historicalIams = new List<Historical_IAM__c>();

        try {
            for(Account acc : accounts) {
                Historical_IAM__c historicalIam = new Historical_IAM__c();
                historicalIam.AccountId__c = acc.Id;
                historicalIam.IntegrationStatus__c = responseIAM.status == Integer.valueOf(Label.Generic_HTTPResult_Success) ? Label.Generic_Success : Label.Generic_Error;
                historicalIam.DateTimeSubmission__c = System.now();
                historicalIams.add(historicalIam);

                acc.Date_Time_Sent_To_IAM__pc = acc.Date_Time_Sent_To_IAM__pc == null ? System.now() : acc.Date_Time_Sent_To_IAM__pc;
                acc.ToBeSentIAM__pc = responseIAM.status == Integer.valueOf(Label.Generic_HTTPResult_Success) ? false : true;
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('AccountService', 'postProcessIAMCallout', e);
        }
        DebugService.printList('BatchIntegrationToIAM', 'postProcessIAMCallout', 'historicalIams', historicalIams, true);
        DebugService.printLimits('AccountService', 'postProcessIAMCallout', 'end');

        return historicalIams;
    }

    public static List<String> getAccountIdsFromFiscalCode(String fiscalCode) {
        DebugService.printLimits('AccountService', 'getAccountIdsFromFiscalCode', 'start');
        Set<String> accountIds = new Set<String>();

        for(Account acc : AccountSelector.getAccountsByFiscalCode(fiscalCode)) {
            accountIds.add(acc.Id);
        }

        System.debug('accountIds ' + accountIds);

        DebugService.printLimits('AccountService', 'getAccountIdsFromFiscalCode', 'end');

        return new List<String>(accountIds);
    }

    public static Map<String, Account> getBusinessAccountKeyMap(List<String> businessAccountKeys) {
        Map<String, Account> businessAccountKeyMap = new Map<String, Account>();

        List<Account> accounts = AccountSelector.getAccountsByBusinessAccountKeys(businessAccountKeys);

        if(!accounts.isEmpty()) {
            for(Account acc : accounts) {
                businessAccountKeyMap.put(acc.BusinessAccountKey__c, acc);
            }
        }

        return businessAccountKeyMap;
    }

    public static List<Database.SaveResult> insertAccounts(List<Account> accounts, Boolean allOrNone) {
        DebugService.printLimits('AccountService', 'insertAccounts', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if(accounts != null && !accounts.isEmpty()) {
            System.debug(accounts + ' is not null or empty');
            try {
                results = Database.insert(accounts, allOrNone);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('AccountService', 'insertAccounts', e);
            }
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            DebugService.printDatabaseResults('AccountService', 'insertAccounts', 'results', results);
        }
        DebugService.printLimits('AccountService', 'insertAccounts', 'end');

        return results;
    }

    public static List<Database.SaveResult> updateAccounts(List<Account> accounts, Boolean allOrNone) {
        DebugService.printLimits('AccountService', 'updateAccounts', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if(accounts != null && !accounts.isEmpty()) {
            System.debug(accounts + ' is not null or empty');
            try {
                results = Database.update(accounts, allOrNone);
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('AccountService', 'updateAccounts', e);
            }
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
            DebugService.printDatabaseResults('AccountService', 'updateAccounts', 'results', results);
        }
        DebugService.printLimits('AccountService', 'updateAccounts', 'end');

        return results;
    }
}