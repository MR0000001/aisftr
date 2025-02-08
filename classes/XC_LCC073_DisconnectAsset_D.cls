/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 30/01/2019
*@date Modification dd/mm/yyyy
*@description controller for custom lightning component for disconnect  asset 
*/
public without sharing class XC_LCC073_DisconnectAsset_D {
    /**
    *@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
    *@description retrieve info of Asset  
    *@param recordId the record id
    *@return Asset
    */
    public static Asset getAsset(String recordId){
        //Set<String> setFields = new Set<String>{'Id', 'XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c'};
        //return (Asset) XC_UTIL_Query.selectFields(setFields, recordId);
        Map<Id,Asset> data = new Map<Id,Asset>([
            SELECT Id, XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c
              FROM Asset
             WHERE Id =: recordId
        ]);
        return data.values()[0];
    }

    /**
    *@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
    *@description retrieve info of Asset  
    *@param recordId the record id 
    *@return List of Case
    */
    public static List<Case> getCases(String recordId){
        /*if(Schema.sObjectType.Asset.fields.RecordTypeId.isAccessible() && Schema.sObjectType.Case.fields.AssetId.isAccessible() && Schema.sObjectType.Case.fields.Id.isAccessible() && Schema.sObjectType.Case.fields.Id.isAccessible() && Schema.sObjectType.Asset.fields.Id.isAccessible() && Schema.SObjectType.Case.isAccessible()){
            List<Case> caseList = [SELECT Id, AssetId, Asset.RecordTypeId, XC_Subtype__c, XC_Communication_Date__c, Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c FROM Case WHERE Id =: recordId];
            return caseList;
        } else {
            return new List<Case>();
        }*/
        Map<Id,Case> data = new Map<Id,Case>([
            SELECT Id, AssetId, Asset.RecordTypeId, XC_Subtype__c, XC_Communication_Date__c, Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c, Origin
            FROM Case 
            WHERE Id =: recordId
        ]);
        return data.values();
    }
}