/**
 * @description       : Util Class for Safety Points Wallet Management
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 24-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_UTIL_SafetyPointsWalletManagement {

    public class SafetyPointsWallet{
        String country{get;set;}
        String legalEntity{get;set;}
        Integer walletNumber{get;set;}
        Integer initPoints{get;set;}
        Integer minPoints{get;set;}
        Integer maxPoints{get;set;}
        String walletStatus{get;set;}

        public SafetyPointsWallet(String country, String legalEntity, Integer walletNumber, Integer initPoints, Integer minPoints, Integer maxPoints, String walletStatus){
            this.country = country;
            this.legalEntity = legalEntity;
            this.walletNumber = walletNumber;
            this.initPoints = initPoints;
            this.minPoints = minPoints;
            this.maxPoints = maxPoints;
            this.walletStatus = walletStatus;
        }
    }

    public static void createNewSafetyPointWalletSettings(SafetyPointsWallet spw){
        XC_CS012_SafetyPointsWalletSettings__c newSPWSettings = new XC_CS012_SafetyPointsWalletSettings__c();
        newSPWSettings.XC_Country__c = spw.country;
        newSPWSettings.XC_InitialPoints__c = spw.initPoints;
        newSPWSettings.XC_LegalEntity__c = spw.legalEntity;
        newSPWSettings.XC_MaximumPoints__c = spw.maxPoints;
        newSPWSettings.XC_MinimumPoints__c = spw.minPoints;
        newSPWSettings.XC_WalletNumber__c = spw.walletNumber;
        newSPWSettings.Name = 'EnelXItalia_Italia_'+spw.walletNumber;//TODO check this field
        insert newSPWSettings;
    }
    
    /**
    * @description get info from Safety Points Wallets by country and legal entity
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param country 
    * @param legalEntity 
    * @param walletNumber 
    * @return XC_CS012_SafetyPointsWalletSettings__c 
    **/
    public static XC_CS012_SafetyPointsWalletSettings__c getSpecificSafetyPointsWalletSettings(String country, String legalEntity, Integer walletNumber){
        List<XC_CS012_SafetyPointsWalletSettings__c> safetyPointsWalletSettings = [SELECT XC_Country__c, XC_InitialPoints__c,XC_LegalEntity__c,XC_MaximumPoints__c,
                                                                                   XC_MinimumPoints__c,XC_WalletNumber__c 
                                                                                   FROM XC_CS012_SafetyPointsWalletSettings__c 
                                                                                   WHERE XC_Country__c = :country 
                                                                                   AND XC_LegalEntity__c = :legalEntity
                                                                                   AND XC_WalletNumber__c = :walletNumber];
        if (!safetyPointsWalletSettings.isEmpty()) {
            return safetyPointsWalletSettings[0];
        } else {
            return null;
        }                                                                   
    }

    /**
    * @description get all Safety points wallet from countries and legal entities passed by parameters
    * @author pedro.danielalmeida@nttdata.com | 10-05-2022 
    * @param countries 
    * @param legalEntities 
    * @return Map<String, XC_CS012_SafetyPointsWalletSettings__c> 
    **/
    public static Map<String,XC_CS012_SafetyPointsWalletSettings__c> getSafetyPointsWalletSettings(Set<String> countries, Set<String> legalEntities){
        Map<String,XC_CS012_SafetyPointsWalletSettings__c> mapSafetyPointsWalletSettings = new Map<String,XC_CS012_SafetyPointsWalletSettings__c>();
        for (XC_CS012_SafetyPointsWalletSettings__c safetyPointsWalletSettings : [SELECT XC_Country__c, XC_InitialPoints__c,XC_LegalEntity__c,XC_MaximumPoints__c,
                                                                                  XC_MinimumPoints__c,XC_WalletNumber__c 
                                                                                  FROM XC_CS012_SafetyPointsWalletSettings__c 
                                                                                  WHERE XC_Country__c IN :countries 
                                                                                  AND XC_LegalEntity__c IN :legalEntities]) {
            mapSafetyPointsWalletSettings.put(safetyPointsWalletSettings.XC_Country__c+safetyPointsWalletSettings.XC_LegalEntity__c+safetyPointsWalletSettings.XC_WalletNumber__c,safetyPointsWalletSettings);
        }
        return mapSafetyPointsWalletSettings;
    }

    /**
    * @description updates Safety Points Wallet Settings (Custom Settings)
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param safetyPointsWalletSettings 
    **/
    public static void updateSafetyPointsWalletSettings(SafetyPointsWallet safetyPointsWalletSettings){
        XC_CS012_SafetyPointsWalletSettings__c safetyPointsSettings = getSpecificSafetyPointsWalletSettings(safetyPointsWalletSettings.country,safetyPointsWalletSettings.legalEntity,safetyPointsWalletSettings.walletNumber);

        if (safetyPointsSettings != null) {
            safetyPointsSettings.XC_InitialPoints__c = safetyPointsWalletSettings.initPoints;
            safetyPointsSettings.XC_MinimumPoints__c = safetyPointsWalletSettings.minPoints;
            safetyPointsSettings.XC_MaximumPoints__c = safetyPointsWalletSettings.maxPoints;

            try {
                update safetyPointsSettings;
            } catch (DMLException e) {
                //TODO
            }
        }
    }


    /**
    * @description create a XC_SafetyPointWallet__c record for the account
    * @author pedro.danielalmeida@nttdata.com | 10-05-2022 
    * @param accountId 
    * @param walletNumber 
    * @param balance 
    * @param status 
    * @return XC_SafetyPointWallet__c 
    **/
    public static XC_SafetyPointWallet__c createSingleSafetyPointsWallet(String accountId, Integer walletNumber, Integer balance,String status){

            XC_SafetyPointWallet__c sfw = new XC_SafetyPointWallet__c();
            sfw.XC_Account__c = accountId;
            sfw.XC_SPW_ActivationDate__c = System.today();
            sfw.XC_SPW_ClearedDate__c = null;
            sfw.XC_SPW_Number__c = walletNumber;
            sfw.XC_SPW_Balance__c = balance;
            sfw.XC_SPW_Status__c = status;//'To Be Active';
            
            return sfw;
    }

    /**
    * @description get the account's number of wallets
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param accountId 
    * @return Integer 
    **/
    public static Integer getAccountWalletsNumber(String accountId){
        Integer accountWalletsNumber = 0;

        for (AggregateResult agg : [SELECT count(Id) numWallets 
                                    FROM XC_SafetyPointWallet__c 
                                    WHERE XC_Account__c = :accountId]) {
            accountWalletsNumber = (Integer)agg.get('numWallets');
        }

        return accountWalletsNumber;
    }

    /**
    * @description returns the Safety Point Wallets from accounts
    * @author pedro.danielalmeida@nttdata.com | 10-05-2022 
    * @param accountIds 
    * @return List<XC_SafetyPointWallet__c> 
    **/
    public static List<XC_SafetyPointWallet__c> getAccountWallets(Set<Id> accountIds){
        List<XC_SafetyPointWallet__c> lstAccountWallets = [SELECT Id,XC_SPW_Number__c,XC_SPW_Status__c,XC_Account__c,Name,XC_SPW_Balance__c 
                                                           FROM XC_SafetyPointWallet__c 
                                                           WHERE XC_Account__c IN :accountIds
                                                           ORDER BY XC_SPW_Number__c ASC];
        return lstAccountWallets;
    }

    /**
    * @description gets the next available wallet to became Active
    * @author pedro.danielalmeida@nttdata.com | 10-05-2022 
    * @param accountIds 
    * @return Map<Id, XC_SafetyPointWallet__c> 
    **/
    public static Map<Id,XC_SafetyPointWallet__c> getNextAccountsWalletsToActivate(Set<Id> accountIds){
        Map<Id,XC_SafetyPointWallet__c> mapAccountWalletsToActivate = new Map<Id,XC_SafetyPointWallet__c>();
        List<XC_SafetyPointWallet__c> lstAccountWallets = getAccountWallets(accountIds);
        
        for (XC_SafetyPointWallet__c sfw : lstAccountWallets) {
            if(sfw.XC_SPW_Status__c == 'Cleared' || sfw.XC_SPW_Status__c == 'Active' || sfw.XC_SPW_Status__c == 'Suspended') continue;

            if (mapAccountWalletsToActivate.containsKey(sfw.XC_Account__c)) {
                XC_SafetyPointWallet__c oldSfw = mapAccountWalletsToActivate.get(sfw.XC_Account__c);
                if (oldSfw.XC_SPW_Balance__c > 0) continue; 
                if (sfw.XC_SPW_Balance__c > 0 && (oldSfw.XC_SPW_Number__c > sfw.XC_SPW_Number__c)) {
                    mapAccountWalletsToActivate.put(sfw.XC_Account__c,sfw);
                }
            } else {
                mapAccountWalletsToActivate.put(sfw.XC_Account__c,sfw);
            }
        }
        return mapAccountWalletsToActivate;
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description get the Wallets available to be used, it has to be always one
    *@param accountId account id of the searched wallet
    *@return Safety Point Wallets to be used for the accountId in input
    **/
    public static List<XC_SafetyPointWallet__c> getUsableWallets(String accountId) {
        return [
            SELECT Id, XC_SPW_Number__c
            FROM XC_SafetyPointWallet__c
            WHERE XC_Account__c = :accountId AND XC_SPW_Status__c IN ('Active', 'Suspended')
            ORDER BY XC_SPW_Number__c
        ];
    }

    
    /**
    * @description calls the flow XC_FL_UpsertSafetyPointWallet
    * @author pedro.danielalmeida@nttdata.com | 11-05-2022 
    * @param lstAccounts 
    **/
    public static void callFlowUpsertSafetyPointWallet(Account accountParam){
        Map<String, Object> params = new Map<String, Object>();
        params.put('account', accountParam);

        Flow.Interview.XC_FL_UpsertSafetyPointWallet upsertSPW = new Flow.Interview.XC_FL_UpsertSafetyPointWallet(params);
        if (!Test.isRunningTest()) {
            try {
                upsertSPW.start();
            } catch (Exception e) {
                System.debug('Error Caught executing flow: '+e.getMessage());
            }
            
        }
    }

    /**
    * @description return true if a given account is eligible for Safety Point Wallet system
    * @author pedro.danielalmeida@nttdata.com | 11-05-2022 
    * @param acc 
    * @return Boolean 
    **/
    public static Boolean isSafetyPointWalletEligibleAccount(Account acc, Map<String, XC_CS011_SafetyPointsLicenseSettings__c> mapSafetyPointsLicenseSettings){
        XC_CS011_SafetyPointsLicenseSettings__c spwlSettings = mapSafetyPointsLicenseSettings.get(acc.XC_Country__c);
        List<String> lstPartnerTypes = new List<String>();
        if (spwlSettings == null) return false;
        if (!String.isBlank(acc.XC_PartnerType__c)){
            lstPartnerTypes.addAll(acc.XC_PartnerType__c.split(';'));
        }
        Boolean partnerTypeFS = lstPartnerTypes.contains('Field Service');
        Boolean segmentB2C = acc.XC_Segment__c == 'B2C';
        Boolean partnerRecordType = acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        Boolean countrySpwIsEnabled = spwlSettings.XC_SafetyPointsLicenseEnabled__c == true;
        Boolean accountContractIsActive = acc.XC_ContractStatus__c == 'Active';
        Boolean isEligible = (partnerRecordType && countrySpwIsEnabled && accountContractIsActive && segmentB2C && partnerTypeFS);
        
        return isEligible;
    }

    /**
    * @description return a map with account as key and a list of wallets as values, used for know if accounts already have wallets
    * @author pedro.danielalmeida@nttdata.com | 24-05-2022 
    * @param accountIds 
    * @return Map<Id, List<XC_SafetyPointWallet__c>> 
    **/
    public static Map<Id,List<XC_SafetyPointWallet__c>> getAccountWalletsList(Set<Id> accountIds){
        Map<Id,List<XC_SafetyPointWallet__c>> mapAccountsWallets = new Map<Id,List<XC_SafetyPointWallet__c>>();
        List<XC_SafetyPointWallet__c> lstSafetyPointWallets = new List<XC_SafetyPointWallet__c>();

        for (XC_SafetyPointWallet__c spw : [SELECT Id,XC_Account__c,XC_SPW_Status__c,XC_SPW_Balance__c 
                                            FROM XC_SafetyPointWallet__c 
                                            WHERE XC_Account__c 
                                            IN :accountIds]) {
            if (mapAccountsWallets.containsKey(spw.XC_Account__c)) {
                lstSafetyPointWallets = mapAccountsWallets.get(spw.XC_Account__c);
                lstSafetyPointWallets.add(spw);
                mapAccountsWallets.put(spw.XC_Account__c, lstSafetyPointWallets);
            } else {
                mapAccountsWallets.put(spw.XC_Account__c, new List<XC_SafetyPointWallet__c> {spw});
            }
        }
        return mapAccountsWallets;
    }
}