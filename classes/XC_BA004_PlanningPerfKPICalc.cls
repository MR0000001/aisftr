/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_BA004_PlanningPerfKPICalc – Batch Class to perform the massive Planning Performance KPI calculation
 */
public without sharing class XC_BA004_PlanningPerfKPICalc implements Database.Batchable<SObject>, Database.StateFul {

    private class NoWalletException extends Exception {}

    private static final String ACCOUNT_PARTNER_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
    private static final String PLANNING_PERFORMANCE = 'Planning Performance';
    private static final String COMPLETED = 'Completed';
    private static final String ERROR = 'Error';
    private static final String TEST = 'Test';

    private Set<String> accountIds = new Set<String>();
    private Integer nextTry = 1;
    private String requestId;
    private String country;

    public XC_BA004_PlanningPerfKPICalc(Set<String> accountIds, String requestId, String country, Integer nextTry) {
        this.accountIds = accountIds;
        this.requestId = requestId;
        this.country = country;
        this.nextTry = nextTry;
    }

    public XC_BA004_PlanningPerfKPICalc(String requestId, String country) {
        this.requestId = requestId;
        this.country = country;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, XC_SafetyPointLicenseActivationDate__c ' +
            'FROM Account ';
        if(!accountIds.isEmpty()) { 
            query += 'WHERE Id IN :accountIds';
        } else {
            query += 'WHERE RecordTypeId = :ACCOUNT_PARTNER_RT AND Country__c = :country AND XC_SafetyPointsLicenseEnabled__c = TRUE AND XC_SafetyPointLicenseActivationDate__c != NULL';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        XC_KPI_Planning_Performance_Detail__c d = new XC_KPI_Planning_Performance_Detail__c();
        for(Account a : accounts) {
            Savepoint sp = Database.setSavepoint();
            try {
                List<XC_SafetyPointWallet__c> wallets = XC_UTIL_SafetyPointsWalletManagement.getUsableWallets(a.Id);
                d = XC_BA004_PlanningPerfKPICalc_U.createKPIDetail(requestId, a.Id, country);
                d.XC_RetryNumber__c = nextTry;
                insert d;
                if(!TEST.equals(d.XC_Request_Type__c)) {
                    if(!wallets.isEmpty()) {
                        if(!XC_UTIL_SPLicenseAccount.checkActivationDateBetweenRange(a, Date.valueOf(d.XC_Request_Start_Date__c), Date.valueOf(d.XC_Request_End_Date__c))) {
                            Map<String, Object> params = new Map<String, Object>();
                            params.put('walletIdInput', wallets.get(0).Id);
                            params.put('detailKPIInputId', d.Id);
                            params.put('pointsToAdd', d.XC_SPs_Added__c);
                            params.put('KPIType', PLANNING_PERFORMANCE);
                            Flow.Interview.XC_FL_UpsertSafetyPointWallet upsertWalletFlow = new Flow.Interview.XC_FL_UpsertSafetyPointWallet(params);
                            upsertWalletFlow.start();
                        }
                    } else {
                        throw new NoWalletException('No Active or Suspended wallet');
                    }
                }
            }
            catch(NoWalletException ex) {
                d.XC_Request_Status__c = 'Error';
                d.XC_Request_Details__c = ex.getMessage();
                update d;
            }
            catch(Exception ex) {
                Database.rollback(sp);
                d = XC_BA004_PlanningPerfKPICalc_U.createKPIDetailError(requestId, a.Id, country, ex.getMessage() + ': ' + ex.getStackTraceString());
                d.XC_RetryNumber__c = nextTry;
                insert d;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<XC_KPI_Planning_Performance_Detail__c> errorDetails = [
            SELECT Id
            FROM XC_KPI_Planning_Performance_Detail__c
            WHERE XC_KPI_Planning_Performance__c = :requestId AND XC_Request_Status__c = 'Error' AND XC_RetryNumber__c = :nextTry
        ];
        List<String> errorIds = new List<String>();
        for(XC_KPI_Planning_Performance_Detail__c d : errorDetails) {
            errorIds.add(d.Id);
        }
        XC_KPI_Planning_Performance__c req = new XC_KPI_Planning_Performance__c();
        req.Id = requestId;
        if(errorDetails.isEmpty()) {
            req.XC_Request_Status__c = COMPLETED;
            req.XC_Request_Details__c = '';
        } else {
            req.XC_Request_Status__c = ERROR;
            req.XC_Request_Details__c = String.valueOf(errorDetails.size()) + ' Planning Performance Request Detail failed: ' + String.join(errorIds, ', ');
        }
        update req;
    }
}