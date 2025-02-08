/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date  : 12/04/2019
 * @description XC_TR_WorkOrder_U_TerritoryManagement_U - Utility class for XC_TR_WorkOrder_U_TerritoryManagement
**/

public without sharing class XC_TR_WorkOrder_U_TerritoryManagement_U {
    
    /**     
     * @author: Marco Rosa - marco.rosa@nttdata.com
     * @description Method to filter WordOrder to be pre-assigned
     * @param listNew - list Id of new records
     * @return List<WorkOrder>
     */
    /*public static List<WorkOrder> getWorkOrderToPreAssign(List<WorkOrder> listNew){
        List<WorkOrder> workOrdersToPreAssign = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(wo.XC_ApplyLogicTerritory__c){
                workOrdersToPreAssign.add(wo);
            }
        }
        return workOrdersToPreAssign;
    }*/

    /**     
     * @description Method to get a Map: Id -> ServiceResource obtined by query of ServiceResource which are values of mapServiceTerritoryListServiceResource map
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param mapWorkOrderListServiceTerritories the map work order list service territories
     * @param mapServiceTerritoryListServiceResource the map service territory list service resource
     * @return mapServiceResources - the map service resources
     */
    /*public static Map<Id, ServiceResource> getMapServiceResources(List<WorkOrder> listNew, Map<Id, List<Id>> mapWorkOrderListServiceTerritories, Map<Id, List<Id>> mapServiceTerritoryListServiceResource){
        List<Id> listServiceResourceIdsAllPartners = new List<Id>(); 
        for(WorkOrder wo : listNew) {
            if(!mapWorkOrderListServiceTerritories.containsKey(wo.Id)) {
                continue;
            }
            List<Id> listServiceTerritoryId = mapWorkOrderListServiceTerritories.get(wo.Id); 
            for(Id serviceTerritoryId : listServiceTerritoryId) {
                if(!mapServiceTerritoryListServiceResource.containsKey(serviceTerritoryId)){
                    continue;
                }
                List<Id> listServiceResource = mapServiceTerritoryListServiceResource.get(serviceTerritoryId);
                if(!listServiceResource.isEmpty()){
                    listServiceResourceIdsAllPartners.addAll(listServiceResource);
                } 
            } 
        }
        Map<Id, ServiceResource> mapServiceResources = XC_TR_WorkOrder_U_TerritoryManagement_D.retrieveMapServiceResources(listServiceResourceIdsAllPartners);
        return mapServiceResources;
    } */

    /**
     * @description Method to populate a Map: ZipCode -> List of XC_ZipCodeSkill_TerritoryAssociation__c with the ZipCode
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param zipCodes - the zip codes
     * @return mapZipCodeAssociation - the map zip code territory
     */ 
    /*public static Map<String, List<XC_ZipCodeSkill_TerritoryAssociation__c>> getMapZipCodeTerritory(List<String> zipCodes) {
        Map<String, List<XC_ZipCodeSkill_TerritoryAssociation__c>> mapZipCodeAssociation = new Map<String, List<XC_ZipCodeSkill_TerritoryAssociation__c>> ();
        List<XC_ZipCodeSkill_TerritoryAssociation__c> listZipCodeTerritories = XC_TR_WorkOrder_U_TerritoryManagement_D.retrieveZipCodeSkillTerritoryAssociation(zipCodes);
        for (XC_ZipCodeSkill_TerritoryAssociation__c zipCodeTerritory: listZipCodeTerritories) {
            if(!String.isBlank(zipCodeTerritory.XC_ListOfSkills__c)){    
                if (!mapZipCodeAssociation.containskey(zipCodeTerritory.XC_ZipCode__c)) {
                    mapZipCodeAssociation.put(zipCodeTerritory.XC_ZipCode__c, new List<XC_ZipCodeSkill_TerritoryAssociation__c> ());
                }
                mapZipCodeAssociation.get(zipCodeTerritory.XC_ZipCode__c).add(zipCodeTerritory);
            }   
        }
        return mapZipCodeAssociation;
    } */

    /**
     * @description Method to populate a Map: ServiceTerritoryId -> List of ServiceResource associated with the territory
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listServiceTerritoryMember - the list service territory member
     * @return mapServiceTerritoryListServiceResource - the map service territory list service resource
     */
    /*public static Map<Id, List<Id>> getMapServiceTerritoryListServiceResource(List<ServiceTerritoryMember> listServiceTerritoryMember){
        Map<Id, List<Id>> mapServiceTerritoryListServiceResource = new Map<Id, List<Id>> ();
        for (ServiceTerritoryMember stm : listServiceTerritoryMember) {
            if (!mapServiceTerritoryListServiceResource.containskey(stm.ServiceTerritoryId)) {
                mapServiceTerritoryListServiceResource.put(stm.ServiceTerritoryId, new List<Id> ());
            }
            mapServiceTerritoryListServiceResource.get(stm.ServiceTerritoryId).add(stm.ServiceResourceId);
        }
        return mapServiceTerritoryListServiceResource;
    }*/

    /**
     * @description Given a list of ServiceTerritoryIds retrieves the territory of the Account Partner in input (preferred partner) @param listServiceTerritoryId the list service territory id
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param mapServiceTerritoryAccountId - the map service territory account id
     * @param preferredAccountId - accountId
     * @return listServiceTerritoryPreferredPartnerId - the service territory preferred partner
     */

    /*public static List<Id> getServiceTerritoryPreferredPartner(List<Id> listServiceTerritoryId, Map<Id, Id> mapServiceTerritoryAccountId, Id preferredAccountId){
        List<Id> listServiceTerritoryPreferredPartnerId = new List<Id>();
        for(Id serviceTerritoryId : listServiceTerritoryId) {
            if(mapServiceTerritoryAccountId.containsKey(serviceTerritoryId)) {
                if(mapServiceTerritoryAccountId.get(serviceTerritoryId) == preferredAccountId) {
                    listServiceTerritoryPreferredPartnerId.add(serviceTerritoryId);
                }
            } 
        }
        return listServiceTerritoryPreferredPartnerId;
    }*/

    /**
     * @description Method to populate a Map: ServiceTerritoryId -> AccountId
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param setAllTerritoryId - the set all territory id
     * @return mapServiceTerritoryAccountId - the map service territory account id
     */
    /*public static Map<Id, Id> getMapServiceTerritoryAccountId(Set<Id> setAllTerritoryId) {
        Map<Id, Id> mapServiceTerritoryAccountId = new Map<Id, Id>();
        List<ServiceTerritory> serviceTerritoryList = XC_TR_WorkOrder_U_TerritoryManagement_D.retrieveListServiceTerritory(setAllTerritoryId);
        for(ServiceTerritory st : serviceTerritoryList) {
            mapServiceTerritoryAccountId.put(st.Id, st.XC_AccountId__c);
        }
        return mapServiceTerritoryAccountId;
    } */

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to populate a Map: Id -> Id
     * @param listNew
     * @param accountId preferred accountId
     * @return a Map workOrderId -> preferredAccountId
     */
    /*public static Map<Id, Id> getMapWorkOrderPreferredResourceAccount(List<WorkOrder> listNew, String accountId) {
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = new Map<Id, Id>();
        if(String.isBlank(accountId)){
            mapWorkOrderPreferredResourceAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(listNew);
        } else {
            for(WorkOrder wo : listNew){
                mapWorkOrderPreferredResourceAccount.put(wo.Id, accountId); 
            }
        }
        return mapWorkOrderPreferredResourceAccount;
    } */

    /**
     * @description Method to get a set of all values in the mapWorkOrderListServiceTerritories map
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param mapWorkOrderListServiceTerritories - the map work order list service territories
     * @return setAllTerritoryId - the sets the all territory id
     */ 
    /*public static Set<Id> getSetAllTerritoryId(Map<Id, List<Id>> mapWorkOrderListServiceTerritories){
        Set<Id> setAllTerritoryId = new Set<Id>();
        for(Id workOrderId : mapWorkOrderListServiceTerritories.keySet()) {
            setAllTerritoryId.addAll(mapWorkOrderListServiceTerritories.get(workOrderId));
        }
        return setAllTerritoryId;
    } */

    /**
     * @description Method to manage No Candidate Found case
     * @author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @author: Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - list Id of new records
     * @param mapWorkOrderListServiceResources - Map: key-> id Work Order, value-> Set of Service Resource
     */
    /*public static void manageNoCandidatesFound(List<WorkOrder> listNew, Map<Id, Set<Id>> mapWorkOrderListServiceResources){
        List<WorkOrder> listWOWithNoCandidate = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if (!mapWorkOrderListServiceResources.containsKey(wo.Id)){
                listWOWithNoCandidate.add(wo);
            }
        }
        if(!listWOWithNoCandidate.isEmpty()) {
            List<ServiceResource> noCandidatesFound = XC_TR_WorkOrder_U_TerritoryManagement_D.retrieveNoCandidatesFoundResource();
            if(!noCandidatesFound.isEmpty()) { 
                for(WorkOrder wo : listWOWithNoCandidate) {
                    mapWorkOrderListServiceResources.put(wo.Id, new Set<Id>{noCandidatesFound[0].Id});  
                }
            }
        } 
    }*/
}