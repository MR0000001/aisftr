/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
 * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
 * @date  : 05/02/2019
* @description XC_TR_WorkOrder_U_TerritoryManagement_D – DAO Class for XC_TR_WorkOrder_U_TerritoryManagement
*/
public without sharing class XC_TR_WorkOrder_U_TerritoryManagement_D {
   
    /**
     * @description Retrieve map service resources.
     * @param listServiceResourceIds the list service resource ids
     * @return the map
     */
    public static Map<Id,ServiceResource> retrieveMapServiceResources(List<Id> listServiceResourceIds){
        if(!Schema.sObjectType.ServiceResource.isAccessible()){ return new Map<Id,ServiceResource>(); }
        Map<Id, ServiceResource> mapServiceResources = new Map<Id, ServiceResource>([
                        SELECT Id, XC_Score__c, IsActive, IsCapacityBased,
                            (SELECT ID, SkillId, SkillLevel, EffectiveStartDate, EffectiveEndDate 
                            FROM ServiceResourceSkills)
                        FROM ServiceResource
                        WHERE Id IN: listServiceResourceIds
                    ]);                     
        return mapServiceResources;
    }

    
    /**
     * @description Retrieve zip code skill territory association.
     * @param zipCodeList the zip code list
     * @return the list
     */
    public static List<XC_ZipCodeSkill_TerritoryAssociation__c> retrieveZipCodeSkillTerritoryAssociation (List<String> zipCodeList){
        if(!Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible()){ return new List<XC_ZipCodeSkill_TerritoryAssociation__c>(); }
        List<XC_ZipCodeSkill_TerritoryAssociation__c> listZipSkillTerr = [SELECT Id, XC_ServiceTerritoryId__c,   
                                                     XC_ListOfSkills__c, XC_ZipCode__c
                                                     FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                     WHERE XC_ZipCode__c IN: zipCodeList];
        return listZipSkillTerr;
    }
    
    /**
     * @description Retrieve list service territory member.     
     * @param setAllTerritoryId the set all territory id
     * @return the list
     */
    public static List<ServiceTerritoryMember> retrieveListServiceTerritoryMember(Set<Id> setAllTerritoryId){
        if(!Schema.sObjectType.ServiceTerritoryMember.isAccessible()){ return new List<ServiceTerritoryMember>(); } 
        List<ServiceTerritoryMember> listserviceTerritoryMember = [
            SELECT Id, ServiceResourceId, ServiceTerritoryId, 
                   ServiceResource.ResourceType, ServiceResource.IsActive, ServiceResource.XC_Account__c 
            FROM ServiceTerritoryMember
            WHERE ServiceTerritoryId IN: setAllTerritoryId
            AND ServiceResource.ResourceType = 'T'
            AND ServiceResource.IsActive = true
            AND ServiceResource.XC_AccountStatus__c =: Label.XC_CL_Account_StatusActive];
        return listserviceTerritoryMember;
    }
    
    /**
     * @description Retrieve list of service territories.     
     * @param setAllTerritoryId the set all territory id
     * @return the list
     */
    public static List<ServiceTerritory> retrieveListServiceTerritory(Set<Id> setAllTerritoryId){
        if(!Schema.sObjectType.ServiceTerritory.isAccessible()){ return new List<ServiceTerritory>();}        
        List<ServiceTerritory> serviceTerritoryList = [
            SELECT Id, XC_AccountId__c 
            FROM ServiceTerritory 
            WHERE Id IN: setAllTerritoryId];
        return serviceTerritoryList;
    } 

    /**
     * @description Retrieve list of service territories.
     * @return the list
     */
    public static List<ServiceResource> retrieveNoCandidatesFoundResource(){
        if(!Schema.sObjectType.ServiceResource.isAccessible()){ return new List<ServiceResource>();  }
        List<ServiceResource> noCandidatesFound = [SELECT Id FROM ServiceResource WHERE Name =: Label.XC_CL_NoCandidateFound];
        return noCandidatesFound;
    }
}