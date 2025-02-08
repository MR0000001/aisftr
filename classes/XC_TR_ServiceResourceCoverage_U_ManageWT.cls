/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/01/2020
* @description XC_TR_ServiceResourceCoverage_U_ManageWT – Class for managing WorkType 
*/

public without sharing class XC_TR_ServiceResourceCoverage_U_ManageWT {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResourceCoverage_U_ManageWT');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to check if Partner has the new coverage of Service Resource
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    public static void checkPartnerCoverage(List<XC_ServiceResourceCoverage__c> listNew) {
        Map<String, List<XC_ServiceResourceCoverage__c>> mapSrSrc = new Map<String, List<XC_ServiceResourceCoverage__c>>();
        for(XC_ServiceResourceCoverage__c src : listNew) {
            if(src.XC_InheritedFromParent__c) {
                continue;
            }
            if(!mapSrSrc.containsKey(src.XC_ServiceResourceId__c)) {
                mapSrSrc.put(src.XC_ServiceResourceId__c, new List<XC_ServiceResourceCoverage__c>());
            }
            mapSrSrc.get(src.XC_ServiceResourceId__c).add(src);
        }
        List<ServiceResource> listServiceResource = new List<ServiceResource>([
            SELECT Id, XC_Account__c
            FROM ServiceResource 
            WHERE Id IN :mapSrSrc.keySet() AND XC_IsManager__c = true AND (XC_LegalEntity__c = :Label.XC_CL_EndesaX OR XC_LegalEntity__c = :Label.XC_CL_LegalEntity_EnelXMobilitySpain)
        ]);
        if(listServiceResource.isEmpty()) {
            return;
        }

        Map<String, String> mapSrPartnerId = new Map<String, String>();
        for(ServiceResource sr : listServiceResource) {
            mapSrPartnerId.put(sr.Id, sr.XC_Account__c);
        }
        
        List<String> listKeyToQuery = new List<String>();
        List<XC_ServiceResourceCoverage__c> listSrcToCheck = new List<XC_ServiceResourceCoverage__c>();
        for(ServiceResource sr : listServiceResource) {
            List<XC_ServiceResourceCoverage__c> listSrc = mapSrSrc.get(sr.Id);
            for(XC_ServiceResourceCoverage__c src : listSrc) {
                String keyZipCodeWT = sr.XC_Account__c + '_' + src.XC_ZipCodeText__c + '_' + src.XC_WorkTypeId__c;
                listKeyToQuery.add(keyZipCodeWT);
                listSrcToCheck.add(src);
            }
        }

        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>([
            SELECT Id, XC_Account__c, XC_Account__r.name, XC_WorkType__c, XC_ZipCode__c
            FROM XC_PartnerCoverage__c
            WHERE XC_ExternalIdForDuplication__c IN :listKeyToQuery 
        ]);
        
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = new List<XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listSrcToCheck) {
            Boolean canInsert = false;
            String partnerName = 'Partner';

            for(XC_PartnerCoverage__c pc : listPc) {
                if(mapSrPartnerId.containsKey(src.XC_ServiceResourceId__c) && pc.XC_Account__c == mapSrPartnerId.get(src.XC_ServiceResourceId__c)) {
                    partnerName = pc.XC_Account__r.name;
                    if(pc.XC_WorkType__c == src.XC_WorkTypeId__c && pc.XC_ZipCode__c == src.XC_ZipCodeText__c) {
                        canInsert = true;
                    }
                }
            }

            if(!canInsert) {
                src.addError(partnerName + ' ' + Label.XC_CL_ErrorSrcForPartner + ' for ' + src.XC_ZipCodeText__c);
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to populate ZipCode/WorkType
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    public static void populateZipCodeWorkTypeOnInsert(List<XC_ServiceResourceCoverage__c> listNew) {
        List<XC_ServiceResourceCoverage__c> listToPopulateLookup = new List<XC_ServiceResourceCoverage__c>();
        List<XC_ServiceResourceCoverage__c> listToPopulateFields = new List<XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listNew) {
            if(String.isBlank(src.XC_ZipCodeWorkTypeId__c) && String.isNotBlank(src.XC_WorkTypeId__c) && String.isNotBlank(src.XC_ZipCodeText__c)) {
                listToPopulateLookup.add(src);
            } else if(String.isBlank(src.XC_ExternalIdForDuplication__c) || (String.isNotBlank(src.XC_ZipCodeWorkTypeId__c) && String.isBlank(src.XC_WorkTypeId__c) && String.isBlank(src.XC_ZipCodeText__c))) {
                listToPopulateFields.add(src);
            }
        }

        if(!listToPopulateLookup.isEmpty()) {
            XC_TR_ServiceResCoverage_U_ManageWT_U.populateZipCodeWorkTypeFromFields(listToPopulateLookup);
        }
        if(!listToPopulateFields.isEmpty()) {
            XC_TR_ServiceResCoverage_U_ManageWT_U.populateZipCodeWorkTypeFromLookup(listToPopulateFields);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to fill ZipCode/WorkType on update
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    * @param mapOld - Map<Id, XC_ServiceResourceCoverage__c>
    * @param mapNew - Map<Id, XC_ServiceResourceCoverage__c>
    */
    public static void populateZipCodeWorkTypeOnUpdate(List<XC_ServiceResourceCoverage__c> listNew, Map<Id, XC_ServiceResourceCoverage__c> mapOld, Map<Id, XC_ServiceResourceCoverage__c> mapNew) {
        List<XC_ServiceResourceCoverage__c> listLookupChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ZipCodeWorkTypeId__c'}, mapOld, mapNew);
        List<XC_ServiceResourceCoverage__c> listFieldsChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_WorkTypeId__c','XC_ZipCodeText__c'}, mapOld, mapNew);
        if(!listFieldsChanged.isEmpty()) {
            XC_TR_ServiceResCoverage_U_ManageWT_U.populateZipCodeWorkTypeFromFields(listFieldsChanged);
        }
        if(!listLookupChanged.isEmpty()) {
            XC_TR_ServiceResCoverage_U_ManageWT_U.populateZipCodeWorkTypeFromLookup(listLookupChanged);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to check if Partner has the coverage of Service Resource (for update)
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    * @param mapOld - Map<Id, XC_ServiceResourceCoverage__c>
    * @param mapNew - Map<Id, XC_ServiceResourceCoverage__c>
    */
    public static void checkPartnerCoverageOnUpdate(List<XC_ServiceResourceCoverage__c> listNew, Map<Id, XC_ServiceResourceCoverage__c> mapOld, Map<Id, XC_ServiceResourceCoverage__c> mapNew) {
        List<XC_ServiceResourceCoverage__c> listFieldsChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_WorkTypeId__c','XC_ZipCodeText__c','XC_ZipCodeWorkTypeId__c'}, mapOld, mapNew);
        Map<String, List<XC_ServiceResourceCoverage__c>> mapSrSrc = new Map<String, List<XC_ServiceResourceCoverage__c>>();
        for(XC_ServiceResourceCoverage__c src : listFieldsChanged) {
            if(src.XC_InheritedFromParent__c) {
                continue;
            }
            if(!mapSrSrc.containsKey(src.XC_ServiceResourceId__c)) {
                mapSrSrc.put(src.XC_ServiceResourceId__c, new List<XC_ServiceResourceCoverage__c>());
            }
            mapSrSrc.get(src.XC_ServiceResourceId__c).add(src);
        }
        List<ServiceResource> listServiceResource = new List<ServiceResource>([
            SELECT Id, XC_Account__c
            FROM ServiceResource 
            WHERE Id IN :mapSrSrc.keySet() AND XC_IsManager__c = true AND (XC_LegalEntity__c = :Label.XC_CL_EndesaX OR XC_LegalEntity__c = :Label.XC_CL_LegalEntity_EnelXMobilitySpain)
        ]);
        if(listServiceResource.isEmpty()) {
            return;
        }

        Map<String, String> mapSrPartnerId = new Map<String, String>();
        for(ServiceResource sr : listServiceResource) {
            mapSrPartnerId.put(sr.Id, sr.XC_Account__c);
        }
        
        List<String> listKeyToQuery = new List<String>();
        List<XC_ServiceResourceCoverage__c> listSrcToCheck = new List<XC_ServiceResourceCoverage__c>();
        for(ServiceResource sr : listServiceResource) {
            List<XC_ServiceResourceCoverage__c> listSrc = mapSrSrc.get(sr.Id);
            for(XC_ServiceResourceCoverage__c src : listSrc) {
                String keyZipCodeWT = sr.XC_Account__c + '_' + src.XC_ZipCodeText__c + '_' + src.XC_WorkTypeId__c;
                listKeyToQuery.add(keyZipCodeWT);
                listSrcToCheck.add(src);
            }
        }

        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>([
            SELECT Id, XC_Account__c, XC_Account__r.name, XC_WorkType__c, XC_ZipCode__c
            FROM XC_PartnerCoverage__c
            WHERE XC_ExternalIdForDuplication__c IN :listKeyToQuery 
        ]);
        
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = new List<XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listSrcToCheck) {
            Boolean canInsert = false;
            String partnerName = 'Partner';

            for(XC_PartnerCoverage__c pc : listPc) {
                if(mapSrPartnerId.containsKey(src.XC_ServiceResourceId__c) && pc.XC_Account__c == mapSrPartnerId.get(src.XC_ServiceResourceId__c)) {
                    partnerName = pc.XC_Account__r.name;
                    if(pc.XC_WorkType__c == src.XC_WorkTypeId__c && pc.XC_ZipCode__c == src.XC_ZipCodeText__c) {
                        canInsert = true;
                    }
                }
            }

            if(!canInsert) {
                src.addError(partnerName + ' ' + Label.XC_CL_ErrorSrcForPartner + ' for ' + src.XC_ZipCodeText__c);
            }
        }
    }

    /** @description CheckResourceToManage */
    /*public class CheckResourceToManage {
        public List<ServiceResource> listServiceResourceToManage = new List<ServiceResource>();
        public Map<String, List<String>> mapServiceResourceTerritory = new Map<String, List<String>>();
        public Map<String, String> mapServiceResourceWithManager = new Map<String, String>();
        public Map<String, XC_ServiceResourceCoverage__c> mapSrCoverage = new Map<String, XC_ServiceResourceCoverage__c>();
        public Map<String, List<String>> mapTerritoryResourceToManage = new Map<String, List<String>>();
        public Map<String, List<String>> mapSrZipCodeWorkType = new Map<String, List<String>>();
        public List<String> listZipCodeWorkTypeManager = new List<String>();
        public List<XC_ServiceResourceCoverage__c> listZipCodeWorkTypeNoManager = new List<XC_ServiceResourceCoverage__c>();
        public Boolean success = false;
    }*/

    /** @description ServiceResourceDataWrapper */
    /*private class ServiceResourceDataWrapper {
        List<String> listAccountIds = new List<String>();
        Map<String, List<String>> mapTerritoryResource = new Map<String, List<String>>();
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to populate map: ServiceResource -> Manager
    * @param listServiceResourceManager - List<ServiceResource> 
    * @param listServiceResourceToManage - List<ServiceResource>
    * @return Map<String, String>
    */
    /*private static Map<String, String> populateMapServiceResource(List<ServiceResource> listServiceResourceManager, List<ServiceResource> listServiceResourceToManage) {
        Map<String, String> mapServiceResourceWithManager = new Map<String, String>();
        for(ServiceResource srManager : listServiceResourceManager) {
            for(ServiceResource srNotManager : listServiceResourceToManage) {
                if(srManager.XC_Account__c == srNotManager.XC_Account__c) {
                    mapServiceResourceWithManager.put(srNotManager.Id, srManager.Id);
                }
            }
        }
        return mapServiceResourceWithManager;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to insert ServiceResourceCoverage for Service Resource (no manager) for Territory (when insert for manager)
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    /*public static void onInsertForManager(List<XC_ServiceResourceCoverage__c> listNew) {
        List<XC_ServiceResourceCoverage__c> listSrcFiltered = XC_TR_ServiceResCoverage_U_ManageWT_U.filterForInheritedFromParent(listNew);
        if(listSrcFiltered.isEmpty()) {
            return;
        }
        List<String> listSrManagerIds = XC_UTIL_Sobject.getListFieldValues(listSrcFiltered, 'XC_ServiceResourceId__c');
        List<ServiceResource> listServiceResourceManager = new List<ServiceResource>([
            SELECT Id, XC_Account__c, 
                (SELECT Id, ServiceTerritoryId 
                FROM ServiceTerritories) 
            FROM ServiceResource
            WHERE XC_IsManager__c = true AND Id IN :listSrManagerIds
        ]);
        if(listServiceResourceManager.isEmpty()) {
            return;
        }

        ServiceResourceDataWrapper srManagerWrapper = populateServiceResourceData(listServiceResourceManager);
        CheckResourceToManage resourceManagedWrapper = XC_TR_ServiceResCoverage_U_ManageWT_U.selectServiceResourceNotManager(srManagerWrapper.listAccountIds, listServiceResourceManager, listSrcFiltered);
        if(!resourceManagedWrapper.success) {
            return;
        }

        resourceManagedWrapper.mapServiceResourceWithManager = populateMapServiceResource(listServiceResourceManager, resourceManagedWrapper.listServiceResourceToManage);
        resourceManagedWrapper.mapTerritoryResourceToManage = srManagerWrapper.mapTerritoryResource;
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = XC_TR_ServiceResCoverage_U_ManageWT_U.checkWrapperToInsertNoManager(resourceManagedWrapper);
        List<XC_UTIL_Sobject.WrapperResult> wrInsert = XC_UTIL_Sobject.insertListRecords(listSrcToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrInsert)) {
            listSrcFiltered[0].addError(wrInsert[0].errorMessage);
        }
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to insert ServiceResourceCoverage for Service Resource (no manager) for Territory
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    /*public static void onInsertForNoManager(List<XC_ServiceResourceCoverage__c> listNew) {
        List<XC_ServiceResourceCoverage__c> listSrcFiltered = XC_TR_ServiceResCoverage_U_ManageWT_U.filterForInheritedFromParent(listNew);
        if(listSrcFiltered.isEmpty()) {
            return;
        }
        List<String> listSrManagerIds = XC_UTIL_Sobject.getListFieldValues(listSrcFiltered, 'XC_ServiceResourceId__c');
        List<ServiceResource> listServiceResourceNoManager = new List<ServiceResource>([
            SELECT Id, XC_Account__c, 
                (SELECT Id, ServiceTerritoryId 
                FROM ServiceTerritories) 
            FROM ServiceResource
            WHERE XC_IsManager__c = false AND Id IN :listSrManagerIds
        ]);
        if(listServiceResourceNoManager.isEmpty()) {
            return;
        }

        // Costruiamo la lista degli Account delle SR No Manager, e la mappa SR no manager -> Lista Territory
        ServiceResourceDataWrapper srNoManagerWrapper = populateServiceResourceData(listServiceResourceNoManager);

        CheckResourceToManage srManagerWrapper = XC_TR_ServiceResCoverage_U_ManageWT_U.selectServiceResourceManager(srNoManagerWrapper.listAccountIds, listServiceResourceNoManager, listSrcFiltered);
        if(!srManagerWrapper.success) {
            return;
        }
        srManagerWrapper.mapServiceResourceWithManager = populateMapServiceResource(srManagerWrapper.listServiceResourceToManage, listServiceResourceNoManager);
        srManagerWrapper.mapTerritoryResourceToManage = srNoManagerWrapper.mapTerritoryResource;
        Boolean success = XC_TR_ServiceResCoverage_U_ManageWT_U.checkWrapperToInsertManager(srManagerWrapper, listServiceResourceNoManager);
        if(!success) {
            listSrcFiltered[0].addError(Label.XC_CL_ErrorCoverageManager);
        }
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to delete ServiceResourceCoverage for Service Resource (no manager) for Territory (when insert for manager)
    * @param listOld - List<XC_ServiceResourceCoverage__c>
    */
    /*public static void onDeleteForManager(List<XC_ServiceResourceCoverage__c> listOld) {
        List<XC_ServiceResourceCoverage__c> listSrcFiltered = XC_TR_ServiceResCoverage_U_ManageWT_U.filterForInheritedFromParent(listOld);
        if(listSrcFiltered.isEmpty()) {
            return;
        }
        List<String> listSrManagerIds = XC_UTIL_Sobject.getListFieldValues(listSrcFiltered, 'XC_ServiceResourceId__c');
        List<ServiceResource> listServiceResourceManager = new List<ServiceResource>([
            SELECT Id, XC_Account__c, 
                (SELECT Id, ServiceTerritoryId 
                FROM ServiceTerritories) 
            FROM ServiceResource
            WHERE XC_IsManager__c = true AND Id IN :listSrManagerIds
        ]);
        if(listServiceResourceManager.isEmpty()) {
            return;
        }

        ServiceResourceDataWrapper srManagerWrapper = populateServiceResourceData(listServiceResourceManager);
        CheckResourceToManage resourceManagedWrapper = XC_TR_ServiceResCoverage_U_ManageWT_U.selectServiceResourceNotManager(srManagerWrapper.listAccountIds, listServiceResourceManager, listSrcFiltered);
        if(!resourceManagedWrapper.success) {
            return;
        }

        resourceManagedWrapper.mapServiceResourceWithManager = populateMapServiceResource(listServiceResourceManager, resourceManagedWrapper.listServiceResourceToManage);
        resourceManagedWrapper.mapTerritoryResourceToManage = srManagerWrapper.mapTerritoryResource;
        resourceManagedWrapper.mapSrZipCodeWorkType = XC_TR_ServiceResCoverage_U_ManageWT_U.getMapSrZipCodeWorkType(resourceManagedWrapper.listServiceResourceToManage);
        resourceManagedWrapper.listZipCodeWorkTypeManager = XC_UTIL_Sobject.getListFieldValues(listSrcFiltered, 'XC_ZipCodeWorkTypeId__c');
        for(ServiceResource srNoManager : resourceManagedWrapper.listServiceResourceToManage) {
            for(XC_ServiceResourceCoverage__c srcNoManager : srNoManager.ServiceResourceCoverages__r) {
                resourceManagedWrapper.listZipCodeWorkTypeNoManager.add(srcNoManager);
            }
        }
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = XC_TR_ServiceResCoverage_U_ManageWT_U.checkWrapperToDeleteNoManager(resourceManagedWrapper);
        List<XC_UTIL_Sobject.WrapperResult> wrInsert = XC_UTIL_Sobject.deleteListRecords(listSrcToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrInsert)) {
            listSrcFiltered[0].addError(wrInsert[0].errorMessage);
        }
    
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to get territory and account for Service Resource
    * @param listServiceResource - List<ServiceResource>
    * @return ServiceResourceDataWrapper
    */
    /*private static ServiceResourceDataWrapper populateServiceResourceData(List<ServiceResource> listServiceResource) {
        ServiceResourceDataWrapper outputWrapper = new ServiceResourceDataWrapper();
        for(ServiceResource sr : listServiceResource) {
            outputWrapper.listAccountIds.add(sr.XC_Account__c);
            for(ServiceTerritoryMember stm : sr.ServiceTerritories) {
                if(!outputWrapper.mapTerritoryResource.containsKey(sr.Id)) {
                    outputWrapper.mapTerritoryResource.put(sr.Id, new List<String>());
                }
                outputWrapper.mapTerritoryResource.get(sr.Id).add(stm.ServiceTerritoryId);
            }
        }
        return outputWrapper;
    }*/

}