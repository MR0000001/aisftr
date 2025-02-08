/**
* @author andrea di cicco
* @date 01/10/2020
* @description class used to automate the risk scoring check
*/
public class XC_TR_Opportunity_RiskScoring {
        /**
     * @author Andrea Di Cicco
     * @description method used to set the risk scoring
     * @param listNew 
    */
    public static void checkRiskScoring(List<Opportunity> listNew){
        Set<String> accountToCheck = new Set<String>();
        Set<String> documentNumberToCheck = new Set<String>();
        Set<String> documentTypeToCheck = new Set<String>();
        Set<String> segmentToCheck = new Set<String>();
        Set<String> documentCountryToCheck = new Set<String>();
        
        for(Opportunity opp : listNew){
            Boolean checkComplexProduct = (opp.XC_Segment__c == 'B2B' || opp.XC_Segment__c == 'B2G') && (opp.XC_LegalEntity__c != 'Codensa' && opp.XC_LegalEntity__c != 'EnelX' && opp.XC_LegalEntity__c != 'EnelDistribution');
            if(checkComplexProduct){
                accountToCheck.add(opp.AccountId);
            }
        }

        if(accountToCheck.isEmpty()){
            return;
        }
        Map<Id, Account> accountToRetrieveInfo = new Map<Id, Account>([SELECT id, IdentityNumber__c, IdentityType__c, XC_Segment__c, XC_DocumentCountry__c FROM Account WHERE ID IN: accountToCheck ]);
        documentNumberToCheck.addAll(XC_UTIL_Sobject.getListFieldValues(accountToRetrieveInfo.values(), 'IdentityNumber__c'));
        documentTypeToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToRetrieveInfo.values(), 'IdentityType__c'));
        segmentToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToRetrieveInfo.values(), 'XC_Segment__c'));
        documentCountryToCheck.addAll(XC_UTIL_SObject.getListFieldValues(accountToRetrieveInfo.values(), 'XC_DocumentCountry__c'));
        List<XC_AccountBlacklistInformation__c> blackList = new List<XC_AccountBlacklistInformation__c>();



        if(!Schema.sObjectType.XC_AccountBlacklistInformation__c.isAccessible()){ 
            return;
        }
        
        blackList = [SELECT id, XC_BlacklistStatus__c,  
                    XC_IdentityNumber__c, XC_IdentityType__c, XC_Segment__c, XC_DocumentCountry__c, LastModifiedDate FROM XC_AccountBlacklistInformation__c 
                    WHERE XC_DocumentCountry__c IN: documentCountryToCheck
                    AND XC_IdentityType__c IN: documentTypeToCheck
                    AND XC_IdentityNumber__c IN: documentNumberToCheck 
                    AND XC_Segment__c  IN: segmentToCheck ];
        
        for(Opportunity opp : listNew){
            if(accountToRetrieveInfo.get(opp.AccountId) == null){
                continue;
            }
            Account acc = accountToRetrieveInfo.get(opp.AccountId);
            acc.XC_LastUpdateBlacklist__c = System.today();
            acc.XC_CheckBlacklist__c = 'Customer not present in the blacklist';
            opp.XC_LastUpdateBlacklist__c = System.today();
            opp.XC_CheckBlacklist__c = 'OK';
            for(XC_AccountBlacklistInformation__c accBlackList : blackList){
                
                Boolean check = acc.IdentityNumber__c ==  accBlackList.XC_IdentityNumber__c && acc.XC_Segment__c == accBlackList.XC_Segment__c && acc.IdentityType__c == accBlackList.XC_IdentityType__c && acc.XC_DocumentCountry__c == accBlackList.XC_DocumentCountry__c;
                acc.XC_LastUpdateBlacklist__c = System.today();
                
                System.debug('check blacklist' + check);
                if(check){
                    acc.XC_CheckBlacklist__c = 'KO - Customer present in the blacklist';
                    opp.XC_CheckBlacklist__c = 'KO';
                    acc.XC_LastUpdateBlacklist__c = Date.newinstance(accBlackList.LastModifiedDate.year(),  accBlackList.LastModifiedDate.month(), accBlackList.LastModifiedDate.day());
                    opp.XC_LastUpdateBlacklist__c = Date.newinstance(accBlackList.LastModifiedDate.year(),  accBlackList.LastModifiedDate.month(), accBlackList.LastModifiedDate.day());
                    continue;
                    
                }
            }
        }
        XC_UTIL_DML.updateRecords(accountToRetrieveInfo.values());

    }

}