/**
 * @description       : batch for the initial setup for the Safety Points Wallets implementation
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public with sharing class XC_BA005_SetupSafetyPointWallets implements Schedulable, Database.Batchable<SObject> {
    
    private String query;
    private Set<String> accountIds;

    public XC_BA005_SetupSafetyPointWallets() {
        this.accountIds = new Set<String>();
        this.query = getBatchQuery();
    }

    public XC_BA005_SetupSafetyPointWallets(Set<String> accountIds) {
        this.accountIds = accountIds;
        this.query = getBatchQuery();
    }

    private String getBatchQuery(){
        String query = 'SELECT Id,RecordTypeId,XC_ContractStatus__c,XC_Segment__c,XC_PartnerType__c,XC_SafetyPointsLicenseEnabled__c,XC_SafetyPointLicenseActivationDate__c,XC_SafetyPointsLicenseSuspension__c,XC_Partner_Contract_Standby__c,Gruppo_Merceologico__c,XC_Country__c  '+
                      +'FROM Account '+
                      +'WHERE RecordType.DeveloperName = \'XC_Account_Partner\'';
        if(!accountIds.isEmpty()) {
            query += ' AND Id IN :accountIds';
        }
        return query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){
        List<Account> lstAccounts = (List<Account>) scope;
        List<Account> lstAccountsToUpdate = new List<Account>();
        Set<String> setCountries = new Set<String>();
        Map<String, XC_CS011_SafetyPointsLicenseSettings__c> mapSafetyPointsLicenseSettings = new Map<String, XC_CS011_SafetyPointsLicenseSettings__c>();
        Set<Id> setAccountsToCheckForSPW = new Set<Id>();

        //get Safety Points License settings
        for (Account acc : lstAccounts) {
            setCountries.add(acc.XC_Country__c);
        }

        mapSafetyPointsLicenseSettings = XC_UTIL_SafetyPointsLicenseManagement.getSafetyPointsLicenseSettings(setCountries);

        for (Account acc : lstAccounts) {
            setAccountsToCheckForSPW.add(acc.Id);
            if (XC_UTIL_SafetyPointsWalletManagement.isSafetyPointWalletEligibleAccount(acc,mapSafetyPointsLicenseSettings)) {
                if (acc.Gruppo_Merceologico__c != 'LCRI05') continue; 
                acc.XC_SafetyPointsLicenseEnabled__c = true;
                acc.XC_SafetyPointLicenseActivationDate__c = System.now();
                lstAccountsToUpdate.add(acc);
            }
        }     

        //update account records with flag
        XC_UTIL_DML.updateRecords(lstAccountsToUpdate, false);

        //call flow to create safety points wallets
        Map<Id,List<XC_SafetyPointWallet__c>> mapAccountsWallets = XC_UTIL_SafetyPointsWalletManagement.getAccountWalletsList(setAccountsToCheckForSPW);

        for (Account acc : lstAccounts) {
            List<XC_SafetyPointWallet__c> lstWalletsFromAccount = new List<XC_SafetyPointWallet__c>();
            if (mapAccountsWallets.containsKey(acc.Id)) {
                lstWalletsFromAccount = mapAccountsWallets.get(acc.Id);
            } 

            if (lstWalletsFromAccount.isEmpty()){
                XC_UTIL_SafetyPointsWalletManagement.callFlowUpsertSafetyPointWallet(acc);
            }
        }
    }

    public void execute(SchedulableContext sc){
        XC_BA005_SetupSafetyPointWallets setupBatch = new XC_BA005_SetupSafetyPointWallets();
        Database.executeBatch(setupBatch, 200);
    }

    public void finish(Database.BatchableContext bc){}
}