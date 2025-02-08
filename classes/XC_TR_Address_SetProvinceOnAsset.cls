/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 15-03-2022
 * @last modified date  : 15-03-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_Address_Handler to populate XC_AddressProvince__c on Asset
 * @test class          : XC_TR_Address_SetProvinceOnAsset_Test
**/

public with sharing class XC_TR_Address_SetProvinceOnAsset {

    public final static String NETWORK_RT = 'TAM_Network';

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method populates the XC_AddressProvince__c field on Asset related to the XC_Address__c.
     * @param listNew The list of new XC_Address__c
     * @param mapOld mapOld XC_Address__c
     * @param mapNew mapNew XC_Address__c
     */
    public static void setProvinceOnAsset(List<XC_Address__c> listNew, Map<Id, XC_Address__c> mapOld, Map<Id, XC_Address__c> mapNew){
        List<String> fieldsToCheck = new List<String>{'XC_AddressProvince__c'};
        List<XC_Address__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck,mapOld,mapNew);
        
        if(listChanged.isEmpty()){
            return;
        }

        List<Asset> assetToUpdate = new List<Asset>();
        List<Asset> assetList = [SELECT Id, XC_Address__c, XC_AddressProvince__c 
                                 FROM Asset 
                                 WHERE XC_Address__c IN: listNew AND RecordType.DeveloperName =: NETWORK_RT];        

        if(!assetList.isEmpty()){
            for(XC_Address__c add : listChanged){
                for(Asset ass : assetList){
                    if(ass.XC_Address__c==add.Id){
                        ass.XC_AddressProvince__c = add.XC_AddressProvince__c;
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