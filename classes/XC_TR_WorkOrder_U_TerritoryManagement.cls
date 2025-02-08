/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
 * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
 * @date  : 05/02/2019
 * @description Populate the Preferred Resource (Required) of the Work Order, based on the
 *               Service Territory Zip Code and Required Skill for the Work Order.
**/

public without sharing class XC_TR_WorkOrder_U_TerritoryManagement {
     
    /*private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_TerritoryManagement');

    private class PreferenceInputWrapper {
        Boolean ignorePreferences; 
        List<WorkOrder> listNew = new List<WorkOrder>(); 
        Map<Id, List<SkillRequirement>> mapSkillRequested = new Map<Id, List<SkillRequirement>>(); 
        Map<Id, List<Id>> mapWorkOrderListServiceTerritories = new Map<Id, List<Id>>(); 
        String preferredAccountId;
    }

    private class EligibleServiceResourceWrapper {
        List<Id> listServiceTerritoryId = new List<Id>(); 
        Map<Id, List<Id>> mapServiceTerritoryListServiceResource = new Map<Id, List<Id>>(); 
        List<SkillRequirement> listSkillRequested = new List<SkillRequirement>(); 
        Map<Id, ServiceResource> mapServiceResources = new Map<Id, ServiceResource>();
        String preferredAccountId;
    }

    private class PreferredResourceWrapper {
        WorkOrder wo; 
        List<Id> listServiceTerritoryId = new List<Id>(); 
        Map<Id, List<Id>> mapServiceTerritoryListServiceResource = new Map<Id, List<Id>>(); 
        Map<Id, Id> mapServiceTerritoryAccountId = new Map<Id, Id>();
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = new Map<Id, Id>(); 
        List<SkillRequirement> listSkillRequested = new List<SkillRequirement>(); 
        Map<Id, ServiceResource> mapServiceResources = new Map<Id, ServiceResource>();
    }*/
    
    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to populate the Preferred Resources (Required) of the Work Order, based on the
     *              Service Territory Zip Code and Required Skill for the Work Order.eth
     * @param mapOld - map Id -> old value of record
     * @param mapNew - map Id -> new value of record
     */
    /*public static void manageTerritoriesOnUpdate(Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<String> fieldList = new List<String> {'PostalCode'};
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            XC_UTIL_ResourcePreference.removeResourcePreferences(listChanged);
            manageTerritoriesOnInsert(listChanged);
        }
    }*/

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to populate the Preferred Resources (Required) of the Work Order, based on the
     *               Service Territory Zip Code and Required Skill for the Work Order.eth
     * @param listNew - list Id of new records
     */
    /*public static void manageTerritoriesOnInsert(List<WorkOrder> listNew) {
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = manageTerritories(listNew, false);
        if(!mapWorkOrderListServiceResources.isEmpty()){   
            XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(listNew, mapWorkOrderListServiceResources);
        }   
    } */

    /**
     * @description Method to get map of Set Service Resource for WorkOrder
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param ignorePreferences - Boolean
     * @return mapWorkOrderListServiceResources - Map: key->Id Work Order, value->Set of Required Service Resource to be inserted
     */
    /*public static Map<Id, Set<Id>> manageTerritories(List<WorkOrder> listNew, Boolean ignorePreferences) {  
        return manageTerritories(listNew, ignorePreferences, null);
    }*/

    /**
     * @description Method to get map of Set Service Resource (with accountId) for WorkOrder
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param ignorePreferences - Boolean
     * @param preferredAccountId - id account for assignment
     * @return mapWorkOrderListServiceResources - Map: key->Id Work Order, value->Set of Required Service Resource to be inserted
     */
    /*public static Map<Id, Set<Id>> manageTerritories(List<WorkOrder> listNew, Boolean ignorePreferences, String preferredAccountId) { 
        List<WorkOrder> workOrdersToPreAssign = XC_TR_WorkOrder_U_TerritoryManagement_U.getWorkOrderToPreAssign(listNew);
        if(workOrdersToPreAssign.isEmpty()){
            return new Map<Id, Set<Id>>(); 
        }
        return manageRequiredResourcesByTerritories(workOrdersToPreAssign, ignorePreferences, preferredAccountId);
    } */

    /**
     * @description Method to get map of Set Service Resource (with accountId) for WorkOrder
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param ignorePreferences - Boolean
     * @param preferredAccountId - id account for assignment
     * @return mapWorkOrderListServiceResources - Map: key->Id Work Order, value->Set of Required Service Resource to be inserted
     */
    
    /*private static Map<Id, Set<Id>> manageRequiredResourcesByTerritories(List<WorkOrder> listNew, Boolean ignorePreferences, String preferredAccountId) { 
        //-----------------------
        //-----Get Zip Codes-----
        //-----------------------
        List<String> listZipCodes = XC_UTIL_Sobject.getListFieldValues(listNew, 'PostalCode');
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        if(listZipCodes.isEmpty()) {
            XC_TR_WorkOrder_U_TerritoryManagement_U.manageNoCandidatesFound(listNew, mapWorkOrderListServiceResources);
            return mapWorkOrderListServiceResources;
        }
        //----------------------------- 
        //-----Get Skill Requested-----
        //----------------------------- 
        Map<Id, List<SkillRequirement>> mapSkillRequested = XC_UTIL_Skill.getMapWorkOrderSkills(listNew);
        Map<Id, List<Id>> mapSkillIdRequested = XC_UTIL_Skill.getMapWorkOrderSkillIds(mapSkillRequested);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapSkillRequested ---> ' + mapSkillRequested);  
        //-----------------------------------------------
        //-----Get ZipCodeSkill TerritoryAssociation-----
        //----------------------------------------------- 
        Map<String, List<XC_ZipCodeSkill_TerritoryAssociation__c>> mapZipCodeTerritoryAssociation = XC_TR_WorkOrder_U_TerritoryManagement_U.getMapZipCodeTerritory(listZipCodes);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapZipCodeTerritoryAssociation ---> ' + mapZipCodeTerritoryAssociation); 
        if(!mapZipCodeTerritoryAssociation.isEmpty()) {
            //------------------------------------------------------------
            //-----Get Map Work Order -> List of Elegible Territories-----
            //------------------------------------------------------------
            Map<Id, List<Id>> mapWorkOrderListServiceTerritories = getMapWorkOrderListServiceTerritories(listNew, mapSkillIdRequested, mapZipCodeTerritoryAssociation);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapWorkOrderListServiceTerritories ---> ' + mapWorkOrderListServiceTerritories); 
            if(!mapWorkOrderListServiceTerritories.isEmpty()){
                //----------------------------------------------------------
                //-----Get Map Work Order -> List of Elegible Resources-----
                //----------------------------------------------------------
                PreferenceInputWrapper preferenceInputWrapper = new PreferenceInputWrapper();
                preferenceInputWrapper.ignorePreferences = ignorePreferences;
                preferenceInputWrapper.listNew = listNew;
                preferenceInputWrapper.mapSkillRequested = mapSkillRequested;
                preferenceInputWrapper.mapWorkOrderListServiceTerritories = mapWorkOrderListServiceTerritories;
                preferenceInputWrapper.preferredAccountId = preferredAccountId;
                mapWorkOrderListServiceResources = getMapWorkOrderListServiceResources(preferenceInputWrapper);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapWorkOrderListServiceResources ---> ' + mapWorkOrderListServiceResources); 
            }
        }   
        XC_TR_WorkOrder_U_TerritoryManagement_U.manageNoCandidatesFound(listNew, mapWorkOrderListServiceResources);
        return mapWorkOrderListServiceResources;
    } */
 
    /**
     * @description Method to populate a Map: WorkOrder -> List of Elegible Service Territories based on Zip Code and Skills
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param mapSkillIdRequested - the map skill id requested
     * @param mapZipCodeTerritoryAssociation - the map zip code territory association
     * @return mapWorkOrderListServiceTerritories - the map work order list service territories
     */
    /*private static Map<Id, List<Id>> getMapWorkOrderListServiceTerritories(List<WorkOrder> listNew, Map<Id, List<Id>> mapSkillIdRequested, Map<String, List<XC_ZipCodeSkill_TerritoryAssociation__c>> mapZipCodeTerritoryAssociation){
        Map<Id, List<Id>> mapWorkOrderListServiceTerritories = new Map<Id, List<Id>> ();
        for(WorkOrder wo : listNew) {
            List<Id> listSkillRequested = XC_UTIL_Skill.getSkillRequestedList(mapSkillIdRequested, wo);
            List<String> listServiceTerritoryId = new List<String>();
            if(mapZipCodeTerritoryAssociation.containsKey(wo.PostalCode)) {
                List<XC_ZipCodeSkill_TerritoryAssociation__c> listZipCodeTerritoryAssociation = mapZipCodeTerritoryAssociation.get(wo.PostalCode);
                for(XC_ZipCodeSkill_TerritoryAssociation__c zipTerr : listZipCodeTerritoryAssociation) {
                    String listOfSkills = zipTerr.XC_ListOfSkills__c;
                    if(String.isBlank(listOfSkills)){
                        continue;
                    }
                    List<String> listOfTerritorySkill = zipTerr.XC_ListOfSkills__c.split(';');                    
                    if (XC_UTIL_Skill.checkSkillIds(listSkillRequested, listOfTerritorySkill)) {
                        listServiceTerritoryId.add(zipTerr.XC_ServiceTerritoryId__c);
                    } 
                } 
                mapWorkOrderListServiceTerritories.put(wo.Id, listServiceTerritoryId);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@mapWorkOrderListServiceTerritories--->' + mapWorkOrderListServiceTerritories); 
            }
        } 
        return mapWorkOrderListServiceTerritories;
    }*/

    /**
     * @description Method to populate a Map: WorkOrder -> List of Elegible Service Resources based on Territory and Preferences
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param preferenceInputWrapper - PreferenceInputWrapper
     * @return mapWorkOrderListServiceResources - the map work order list service resources
     */ 
    /*private static Map<Id, Set<Id>> getMapWorkOrderListServiceResources(PreferenceInputWrapper preferenceInputWrapper) {     
        Set<Id> setAllTerritoryId = XC_TR_WorkOrder_U_TerritoryManagement_U.getSetAllTerritoryId(preferenceInputWrapper.mapWorkOrderListServiceTerritories);
        List<ServiceTerritoryMember> listServiceTerritoryMember = XC_TR_WorkOrder_U_TerritoryManagement_D.retrievelistServiceTerritoryMember(setAllTerritoryId);
        Map<Id, List<Id>> mapServiceTerritoryListServiceResource = XC_TR_WorkOrder_U_TerritoryManagement_U.getMapServiceTerritoryListServiceResource(listServiceTerritoryMember);
        Map<Id, Id> mapServiceTerritoryAccountId = XC_TR_WorkOrder_U_TerritoryManagement_U.getMapServiceTerritoryAccountId(setAllTerritoryId);
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = XC_TR_WorkOrder_U_TerritoryManagement_U.getMapWorkOrderPreferredResourceAccount(preferenceInputWrapper.listNew, preferenceInputWrapper.preferredAccountId);
        Map<Id, ServiceResource> mapServiceResources = XC_TR_WorkOrder_U_TerritoryManagement_U.getMapServiceResources(preferenceInputWrapper.listNew, preferenceInputWrapper.mapWorkOrderListServiceTerritories, mapServiceTerritoryListServiceResource);
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>> ();       
        for(WorkOrder wo : preferenceInputWrapper.listNew) {
            if(!preferenceInputWrapper.mapWorkOrderListServiceTerritories.containsKey(wo.Id)) {
                continue;
            }
            List<Id> listServiceTerritoryId = preferenceInputWrapper.mapWorkOrderListServiceTerritories.get(wo.Id);
            List<SkillRequirement> listSkillRequested = XC_UTIL_Skill.getSkillRequestedList(preferenceInputWrapper.mapSkillRequested, wo);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@listSkillRequested--->' + listSkillRequested); 
            List<Id> listAllServiceResource = new List<Id> (); 
            Boolean useAllResources = false;
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ignorePreferences--->' + preferenceInputWrapper.ignorePreferences);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@useAllResources--->' + useAllResources); 

            if(!preferenceInputWrapper.ignorePreferences) {
                PreferredResourceWrapper preferredWrapper = new PreferredResourceWrapper();
                preferredWrapper.wo = wo;
                preferredWrapper.listServiceTerritoryId = listServiceTerritoryId;
                preferredWrapper.mapServiceTerritoryListServiceResource = mapServiceTerritoryListServiceResource;
                preferredWrapper.mapServiceTerritoryAccountId = mapServiceTerritoryAccountId;
                preferredWrapper.mapWorkOrderPreferredResourceAccount = mapWorkOrderPreferredResourceAccount;
                preferredWrapper.listSkillRequested = listSkillRequested;
                preferredWrapper.mapServiceResources = mapServiceResources;
                List<Id> listPreferredPartnerServiceResources = retrievePreferredResourcesList(preferredWrapper);
                
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@listPreferredPartnerServiceResources--->' + listPreferredPartnerServiceResources);                     
                if(!listPreferredPartnerServiceResources.isEmpty()){
                    listAllServiceResource.addAll(listPreferredPartnerServiceResources); 
                } else {
                    useAllResources = true;
                }
            } 
            if(preferenceInputWrapper.ignorePreferences || useAllResources) {
                EligibleServiceResourceWrapper eligibleWrapper = new EligibleServiceResourceWrapper();
                eligibleWrapper.listServiceTerritoryId = listServiceTerritoryId;
                eligibleWrapper.listSkillRequested = listSkillRequested;
                eligibleWrapper.mapServiceResources = mapServiceResources;
                eligibleWrapper.mapServiceTerritoryListServiceResource = mapServiceTerritoryListServiceResource;
                eligibleWrapper.preferredAccountId = preferenceInputWrapper.preferredAccountId;
                populateListAllServiceResource(eligibleWrapper, listAllServiceResource);
            } 
            populateMapWorkOrderListServiceResources(wo, listAllServiceResource, mapWorkOrderListServiceResources);
        }
        return mapWorkOrderListServiceResources;
    } */

    /*private static void populateListAllServiceResource(EligibleServiceResourceWrapper eligibleWrapper, List<Id> listAllServiceResource){
        List<Id> listAllPartnerServiceResources = getEligibleServiceResources(eligibleWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@listAllPartnerServiceResources--->' + listAllPartnerServiceResources);  
        if(!listAllPartnerServiceResources.isEmpty()){
            listAllServiceResource.addAll(listAllPartnerServiceResources); 
        }
    }

    private static void populateMapWorkOrderListServiceResources(WorkOrder wo, List<Id> listAllServiceResource, Map<Id, Set<Id>> mapWorkOrderListServiceResources){
        if(!listAllServiceResource.isEmpty()) {
            Set<Id> setAllServiceResource = new Set<Id>();
            setAllServiceResource.addAll(listAllServiceResource);
            mapWorkOrderListServiceResources.put(wo.Id, setAllServiceResource);
        }
    }*/

    /**
     * @description Method to get a List of Service Resources of a certain territory based on Skills and AssignToPartner flag
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param eligibleWrapper - EligibleServiceResourceWrapper
     * @return listAllServiceResource - the eligible service resources
     */
    /*@testVisible
    private static List<Id> getEligibleServiceResources(EligibleServiceResourceWrapper eligibleWrapper) {
        List<Id> listAllServiceResource = new List<Id>();
        for(Id serviceTerritoryId : eligibleWrapper.listServiceTerritoryId) {
            if(eligibleWrapper.mapServiceTerritoryListServiceResource.containsKey(serviceTerritoryId)) {
                List<Id> listServiceResourceId = eligibleWrapper.mapServiceTerritoryListServiceResource.get(serviceTerritoryId);
                if(!listServiceResourceId.isEmpty()) {
                    List<Id> listFilteredServiceResourceIds = filterEligibleServiceResourceList(listServiceResourceId, eligibleWrapper.listSkillRequested, eligibleWrapper.mapServiceResources);
                    listAllServiceResource.addAll(listFilteredServiceResourceIds);
                } 
            }
        }   
        return listAllServiceResource; 
    } */

    /**
     * @description Method to filter a List of Service Resources based on Skills and AssignToPartner flag
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listServiceResourceId - the list service resource id
     * @param listSkillRequested - the list skill requested
     * @param mapServiceResources - the map service resources
     * @return listEligibleServiceResourceId - List of Eligible Service Resource
     */
    /*@testVisible
    private static List<Id> filterEligibleServiceResourceList(List<Id> listServiceResourceId, List<SkillRequirement> listSkillRequested, Map<Id, ServiceResource> mapServiceResources){
        List<Id> listEligibleServiceResourceId = new List<Id>();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@mapServiceResources--->' + mapServiceResources); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@listSkillRequested--->' + listSkillRequested);   
        for(Id srId : listServiceResourceId) {
            ServiceResource sr = mapServiceResources.get(srId);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@sr.ServiceResourceSkills--->' + sr.ServiceResourceSkills); 
            if(!sr.ServiceResourceSkills.isEmpty()){
                Boolean isEligible = XC_UTIL_Skill.checkSkills(listSkillRequested, sr.ServiceResourceSkills);
                if(isEligible){ 
                    listEligibleServiceResourceId.add(sr.Id);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@listEligibleServiceResourceId--->' + listEligibleServiceResourceId); 
        return listEligibleServiceResourceId;
    }  */

    /**
     * @description Method to retrieve the List of Preferred Resources for a Work Order
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param preferredWrapper - PreferredResourceWrapper 
     * @return listPreferredPartnerServiceResources - list of Service Resource
     */
    /*private static List<Id> retrievePreferredResourcesList(PreferredResourceWrapper preferredWrapper) {
        List<Id> listPreferredPartnerServiceResources = new List<Id>();
        if(preferredWrapper.mapWorkOrderPreferredResourceAccount.containsKey(preferredWrapper.wo.Id)) {
            Id accountId = preferredWrapper.mapWorkOrderPreferredResourceAccount.get(preferredWrapper.wo.Id);
            List<Id> listServiceTerritoryPreferredPartnerId = XC_TR_WorkOrder_U_TerritoryManagement_U.getServiceTerritoryPreferredPartner(preferredWrapper.listServiceTerritoryId, preferredWrapper.mapServiceTerritoryAccountId, accountId);
            EligibleServiceResourceWrapper eligibleWrapper = new EligibleServiceResourceWrapper();
            eligibleWrapper.listServiceTerritoryId = listServiceTerritoryPreferredPartnerId;
            eligibleWrapper.listSkillRequested = preferredWrapper.listSkillRequested;
            eligibleWrapper.mapServiceResources = preferredWrapper.mapServiceResources;
            eligibleWrapper.mapServiceTerritoryListServiceResource = preferredWrapper.mapServiceTerritoryListServiceResource;
            listPreferredPartnerServiceResources = getEligibleServiceResources(eligibleWrapper);
        }
        return listPreferredPartnerServiceResources; 
    }*/
}