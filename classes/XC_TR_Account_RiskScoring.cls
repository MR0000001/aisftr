/**
* @author andrea di cicco
* @date 30/09/2020
* @description class used to automate the risk scoring check
*/
public without sharing class XC_TR_Account_RiskScoring {
    /**
     * @author Andrea Di Cicco
     * @description method used to set the risk scoring
     * @param listNew 
    */
    public static void checkRiskScoring(List<Account> listNew){
        List<Account> accountToCheck = new List<Account>();
        Set<String> documentNumberToCheck = new Set<String>();
        Set<String> documentTypeToCheck = new Set<String>(); 
        Set<String> segmentToCheck = new Set<String>();
        Set<String> documentCountryToCheck = new Set<String>();
        for(Account acc : listNew){
            Boolean checkComplexProduct = (acc.XC_Segment__c == 'B2B' || acc.XC_Segment__c == 'B2G') && (acc.XC_DocumentCountry__c != 'Chile' && acc.XC_DocumentCountry__c!= 'Colombia');
            if(checkComplexProduct){
                accountToCheck.add(acc);
            }
        }

        if(accountToCheck.isEmpty()){
            return;
        }
        documentNumberToCheck.addAll(XC_UTIL_Sobject.getListFieldValues(accountToCheck, 'IdentityNumber__c'));
        documentTypeToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToCheck, 'IdentityType__c'));
        segmentToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToCheck, 'XC_Segment__c'));
        documentCountryToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToCheck, 'XC_DocumentCountry__c'));
        List<XC_AccountBlacklistInformation__c> blackList = new List<XC_AccountBlacklistInformation__c>();



        if(!Schema.sObjectType.XC_AccountBlacklistInformation__c.isAccessible()){ 
            return;
        }
        
        blackList = [SELECT id, XC_BlacklistStatus__c,  
                    XC_IdentityNumber__c, XC_IdentityType__c, XC_Segment__c, XC_DocumentCountry__c, LastModifiedDate
                    FROM XC_AccountBlacklistInformation__c 
                    WHERE XC_DocumentCountry__c IN: documentCountryToCheck
                    AND XC_IdentityType__c IN: documentTypeToCheck
                    AND XC_IdentityNumber__c IN: documentNumberToCheck 
                    AND XC_Segment__c  IN: segmentToCheck ];

        
        for(Account acc : accountToCheck){
            acc.XC_LastUpdateBlacklist__c = System.today();
            acc.XC_CheckBlacklist__c = 'Customer not present in the blacklist';
            for(XC_AccountBlacklistInformation__c accBlackList : blackList){
                Boolean check = acc.IdentityNumber__c ==  accBlackList.XC_IdentityNumber__c && acc.XC_Segment__c == accBlackList.XC_Segment__c && acc.IdentityType__c == accBlackList.XC_IdentityType__c && acc.XC_DocumentCountry__c == accBlackList.XC_DocumentCountry__c;
                System.debug('check blacklist' + check);
                if(check){
                    acc.XC_CheckBlacklist__c = 'KO - Customer present in the blacklist';
                    acc.XC_LastUpdateBlacklist__c = Date.newinstance(accBlackList.LastModifiedDate.year(),  accBlackList.LastModifiedDate.month(), accBlackList.LastModifiedDate.day());
                    continue;
                }
            }
        }

    }
}