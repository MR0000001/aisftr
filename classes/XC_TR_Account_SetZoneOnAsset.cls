/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 15-03-2022
 * @last modified date  : 15-03-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_Account_Handler to populate XC_AccountZone__c on Asset
 * @test class          : XC_TR_Account_SetZoneOnAsset_Test
**/

public with sharing class XC_TR_Account_SetZoneOnAsset {

    public final static String NETWORK_RT = 'TAM_Network';

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method populates the XC_AccountZone__c field on Asset related to the Account.
     * @param listNew The list of new Account
     * @param mapOld mapOld Account
     * @param mapNew mapNew Account
     */
    public static void setZoneOnAsset(List<Account> listNew, Map<Id, Account> mapOld, Map<Id, Account> mapNew){
        List<String> fieldsToCheck = new List<String>{'XC_Zone__c'};
        List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
        
        if(listChanged.isEmpty()){
            return;
        }

        List<Asset> assetToUpdate = new List<Asset>();
        List<Asset> assetList = [SELECT Id, AccountId, XC_AccountZone__c 
                                 FROM Asset 
                                 WHERE AccountId IN: listNew AND RecordType.DeveloperName =: NETWORK_RT];        

        if(!assetList.isEmpty()){
            for(Account acc : listChanged){
                for(Asset ass : assetList){
                    if(ass.AccountId==acc.Id){
                        ass.XC_AccountZone__c = acc.XC_Zone__c;
                        assetToUpdate.add(ass);
                    }
                }
            }
        }

        if(!assetToUpdate.isEmpty()){
            update assetToUpdate;
        }
    }
}