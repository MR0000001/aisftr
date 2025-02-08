/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/01/2020
* @description XC_TR_ServiceResCoverage_U_ManageWT_U – Util Class for ServiceResourceCoverage trigger (for managing WorkType)
*/

public without sharing class XC_TR_ServiceResCoverage_U_ManageWT_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResourceCoverage_U_ManageWT');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to get Map: Sr -> ZipCodeWorkType
    * @param listServiceResource - List<ServiceResource>
    * @return Map<String, List<String>>
    */
    public static Map<String, List<String>> getMapSrZipCodeWorkType(List<ServiceResource> listServiceResource) {
        Map<String, List<String>> mapOutput = new Map<String, List<String>>();
        for(ServiceResource sr : listServiceResource) {
            for(XC_ServiceResourceCoverage__c src : sr.ServiceResourceCoverages__r) {
                if(!mapOutput.containsKey(sr.Id)) {
                    mapOutput.put(sr.Id, new List<String>());
                }
                mapOutput.get(sr.Id).add(src.XC_ZipCodeWorkTypeId__c);
            }
        }
        return mapOutput;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to select only coverage with XC_InheritedFromParent__c to false
    * @param listSrc - List<XC_ServiceResourceCoverage__c>
    * @return List<XC_ServiceResourceCoverage__c>
    */
    public static List<XC_ServiceResourceCoverage__c> filterForInheritedFromParent(List<XC_ServiceResourceCoverage__c> listSrc) {
        List<XC_ServiceResourceCoverage__c> listSrcFiltered = new List<XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listSrc) {
            if(src.XC_InheritedFromParent__c == false) {
                listSrcFiltered.add(src);
            }
        }
        return listSrcFiltered;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to populate Lookup ZipCode/WorkType from fields
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    public static void populateZipCodeWorkTypeFromFields(List<XC_ServiceResourceCoverage__c> listNew) {
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> listWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>();
        for(XC_ServiceResourceCoverage__c src : listNew) {
            XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wr = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper();
            wr.zipCode = src.XC_ZipCodeText__c;
            wr.workType = src.XC_WorkTypeId__c;
            listWrapper.add(wr);
        }
        Map<String, String> mapZipCodeWorkType = XC_UTIL_ZipCodeWorkType.calculateAssociationZipCodeWorkType(listWrapper); 

        for(XC_ServiceResourceCoverage__c src : listNew) {
            if(!Test.isRunningTest() && mapZipCodeWorkType.containsKey(src.XC_ZipCodeText__c+'_'+src.XC_WorkTypeId__c)) {
                src.XC_ZipCodeWorkTypeId__c = mapZipCodeWorkType.get(src.XC_ZipCodeText__c+'_'+src.XC_WorkTypeId__c);
                src.XC_ExternalIdForDuplication__c = src.XC_ServiceResourceId__c + '_' + src.XC_ZipCodeText__c + '_' + src.XC_WorkTypeId__c;
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 19/05/2020
    * @description Method to populate Lookup ZipCode/WorkType from lookup
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    */
    public static void populateZipCodeWorkTypeFromLookup(List<XC_ServiceResourceCoverage__c> listNew) {
        List<String> listZcwtIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_ZipCodeWorkTypeId__c');
        List<XC_ZipCodeWorkType__c> listZcwt = new List<XC_ZipCodeWorkType__c>([
            SELECT Id, XC_ZipCode__c, XC_WorkType__c 
            FROM XC_ZipCodeWorkType__c 
            WHERE Id IN :listZcwtIds
        ]);
        for(XC_ServiceResourceCoverage__c src : listNew) {
            for(XC_ZipCodeWorkType__c zcwt : listZcwt) {
                if(src.XC_ZipCodeWorkTypeId__c == zcwt.Id) {
                    if(String.isBlank(src.XC_ZipCodeText__c) || String.isBlank(src.XC_WorkTypeId__c)) {
                        src.XC_ZipCodeText__c = zcwt.XC_ZipCode__c;
                        src.XC_WorkTypeId__c = zcwt.XC_WorkType__c; 
                    }
                    if(String.isBlank(src.XC_ExternalIdForDuplication__c)) {
                        src.XC_ExternalIdForDuplication__c = src.XC_ServiceResourceId__c + '_' + src.XC_ZipCodeText__c + '_' + src.XC_WorkTypeId__c;
                    }
                    break;
                }
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to get Service Resource (not manager) for managing
    * @param listAccountIds - List<String>
    * @param listServiceResourceManager - List<ServiceResource>
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    * @return XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage
    */
    /*public static XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage selectServiceResourceNotManager(List<String> listAccountIds, List<ServiceResource> listServiceResourceManager, List<XC_ServiceResourceCoverage__c> listNew) {
        XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage outputWrapper = new XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage();
        // E' necessaria effettuare una nuova query su ServiceResource (per i non manager) perché avevamo bisogno del campo Account dalla SR Manager:
        outputWrapper.listServiceResourceToManage = new List<ServiceResource>([
            SELECT Id, XC_Account__c, 
                (SELECT Id, ServiceTerritoryId 
                FROM ServiceTerritories),
                (SELECT Id, XC_ZipCodeWorkTypeId__c
                FROM ServiceResourceCoverages__r)  
            FROM ServiceResource
            WHERE XC_IsManager__c = false AND XC_Account__c IN :listAccountIds
        ]);
        if(outputWrapper.listServiceResourceToManage.isEmpty()) {
            return outputWrapper;
        }
        
        for(ServiceResource srNotManager : outputWrapper.listServiceResourceToManage) {
            for(ServiceTerritoryMember stmNotManager : srNotManager.ServiceTerritories) {
                if(!outputWrapper.mapServiceResourceTerritory.containsKey(srNotManager.Id)) {
                    outputWrapper.mapServiceResourceTerritory.put(srNotManager.Id, new List<String>());
                }
                outputWrapper.mapServiceResourceTerritory.get(srNotManager.Id).add(stmNotManager.ServiceTerritoryId);
            }
        }
        if(outputWrapper.mapServiceResourceTerritory.isEmpty()) {
            return outputWrapper;
        }

        for(XC_ServiceResourceCoverage__c srcManager : listNew) {
            outputWrapper.mapSrCoverage.put(srcManager.XC_ServiceResourceId__c, srcManager);
        }

        outputWrapper.success = true;
        return outputWrapper;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to check if Service Resource Coverage can be inserted
    * @param resourceManagedWrapper - XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage
    * @return List<XC_ServiceResourceCoverage__c> 
    */
    /*public static List<XC_ServiceResourceCoverage__c> checkWrapperToInsertNoManager(XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage resourceManagedWrapper) {
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = new List<XC_ServiceResourceCoverage__c>();
        for(ServiceResource srNotManager : resourceManagedWrapper.listServiceResourceToManage) {
            List<String> listServiceTerritoryNotManager = resourceManagedWrapper.mapServiceResourceTerritory.containsKey(srNotManager.Id) ? resourceManagedWrapper.mapServiceResourceTerritory.get(srNotManager.Id) : new List<String>();
            String idManager = resourceManagedWrapper.mapServiceResourceWithManager.get(srNotManager.Id);
            List<String> listServiceTerritoryManager = resourceManagedWrapper.mapTerritoryResourceToManage.get(idManager);
            for(String serviceTerritoryId : listServiceTerritoryNotManager) {
                if(listServiceTerritoryManager.contains(serviceTerritoryId)) {
                    XC_ServiceResourceCoverage__c srcToInsert = new XC_ServiceResourceCoverage__c();
                    srcToInsert.XC_ServiceResourceId__c = srNotManager.Id;
                    srcToInsert.XC_ZipCodeWorkTypeId__c = resourceManagedWrapper.mapSrCoverage.get(idManager).XC_ZipCodeWorkTypeId__c;
                    listSrcToInsert.add(srcToInsert);
                }
            }
        }
        return listSrcToInsert;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to check if Service Resource Coverage must be delete
    * @param resourceManagedWrapper - XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage
    * @return List<XC_ServiceResourceCoverage__c> 
    */
    /*public static List<XC_ServiceResourceCoverage__c> checkWrapperToDeleteNoManager(XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage resourceManagedWrapper) {
        List<XC_ServiceResourceCoverage__c> listSrcToDelete = new List<XC_ServiceResourceCoverage__c>();
        List<String> listSrcToDeleteTemp = new List<String>();
        for(ServiceResource srNotManager : resourceManagedWrapper.listServiceResourceToManage) {
            List<String> listServiceTerritoryNotManager = resourceManagedWrapper.mapServiceResourceTerritory.get(srNotManager.Id);
            if(listServiceTerritoryNotManager != null && listServiceTerritoryNotManager.size() > 0) {
                String idManager = resourceManagedWrapper.mapServiceResourceWithManager.get(srNotManager.Id);
                List<String> listServiceTerritoryManager = resourceManagedWrapper.mapTerritoryResourceToManage.get(idManager);
                for(String serviceTerritoryId : listServiceTerritoryNotManager) {
                    if(listServiceTerritoryManager.contains(serviceTerritoryId)) {
                        for(String zipCodeWorkTypeManager : resourceManagedWrapper.listZipCodeWorkTypeManager) {
                            if(resourceManagedWrapper.mapSrZipCodeWorkType.get(srNotManager.Id).contains(zipCodeWorkTypeManager)) {
                                listSrcToDeleteTemp.add(zipCodeWorkTypeManager);
                            }
                        }
                    }
                }
            }
        }

        for(String zipCodeTypeToDelete : listSrcToDeleteTemp) {
            for(XC_ServiceResourceCoverage__c srcToDelete : resourceManagedWrapper.listZipCodeWorkTypeNoManager) {
                if(srcToDelete.XC_ZipCodeWorkTypeId__c == zipCodeTypeToDelete) {
                    listSrcToDelete.add(new XC_ServiceResourceCoverage__c(Id = srcToDelete.Id));
                }
            }
        }
        return listSrcToDelete;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to get Service Resource (manager) for managing
    * @param listAccountIds - List<String>
    * @param listServiceResourceNoManager - List<ServiceResource>
    * @param listNew - List<XC_ServiceResourceCoverage__c>
    * @return XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage
    */
    /*public static XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage selectServiceResourceManager(List<String> listAccountIds, List<ServiceResource> listServiceResourceNoManager, List<XC_ServiceResourceCoverage__c> listNew) {
        XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage outputWrapper = new XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage();
        // E' necessaria effettuare una nuova query su ServiceResource (per i non manager) perché avevamo bisogno del campo Account dalla SR Manager:
        outputWrapper.listServiceResourceToManage = new List<ServiceResource>([
            SELECT Id, XC_Account__c, 
                (SELECT Id, ServiceTerritoryId 
                FROM ServiceTerritories),
                (SELECT Id, XC_ZipCodeWorkTypeId__c
                FROM ServiceResourceCoverages__r) 
            FROM ServiceResource
            WHERE XC_IsManager__c = true AND XC_Account__c IN :listAccountIds
        ]);
        if(outputWrapper.listServiceResourceToManage.isEmpty()) {
            return outputWrapper;
        }
        
        for(ServiceResource srManager : outputWrapper.listServiceResourceToManage) {
            for(ServiceTerritoryMember stmManager : srManager.ServiceTerritories) {
                if(!outputWrapper.mapServiceResourceTerritory.containsKey(srManager.Id)) {
                    outputWrapper.mapServiceResourceTerritory.put(srManager.Id, new List<String>());
                }
                outputWrapper.mapServiceResourceTerritory.get(srManager.Id).add(stmManager.ServiceTerritoryId);
            }
        }
        if(outputWrapper.mapServiceResourceTerritory.isEmpty()) {
            return outputWrapper;
        }

        for(XC_ServiceResourceCoverage__c srcNoManager : listNew) {
            outputWrapper.mapSrCoverage.put(srcNoManager.XC_ServiceResourceId__c, srcNoManager);
        }

        outputWrapper.mapSrZipCodeWorkType = getMapSrZipCodeWorkType(outputWrapper.listServiceResourceToManage);

        outputWrapper.success = true;
        return outputWrapper;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/01/2020
    * @description Method to check if Service Resource Coverage can be inserted
    * @param resourceManagedWrapper - XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage
    * @param listServiceResourceNoManager - List<ServiceResource>
    * @return Boolean
    */
    /*public static Boolean checkWrapperToInsertManager(XC_TR_ServiceResourceCoverage_U_ManageWT.CheckResourceToManage resourceManagedWrapper, List<ServiceResource> listServiceResourceNoManager) {
        for(ServiceResource srNoManager : listServiceResourceNoManager) {
            List<String> listServiceTerritoryNotManager = resourceManagedWrapper.mapTerritoryResourceToManage.get(srNoManager.Id);
            String idManager = resourceManagedWrapper.mapServiceResourceWithManager.get(srNoManager.Id);
            //List<String> listServiceTerritoryManager = resourceManagedWrapper.mapServiceResourceTerritory.get(idManager);
            //if(listServiceTerritoryManager.isEmpty() || listServiceTerritoryManager == null) {
            //    return false;
            //}
            String zipCodeWorkTypeId = resourceManagedWrapper.mapSrCoverage.get(srNoManager.Id).XC_ZipCodeWorkTypeId__c;
            if(resourceManagedWrapper.mapSrZipCodeWorkType.containsKey(idManager) && !resourceManagedWrapper.mapSrZipCodeWorkType.get(idManager).contains(zipCodeWorkTypeId)) {
                return false;
            } 
            //for(String serviceTerritoryId : listServiceTerritoryNotManager) {
            //  if(!listServiceTerritoryManager.contains(serviceTerritoryId) || (resourceManagedWrapper.mapSrZipCodeWorkType.containsKey(idManager) && !resourceManagedWrapper.mapSrZipCodeWorkType.get(idManager).contains(zipCodeWorkTypeId))) {
            //      return false;
            //  } 
            //}
        }
        return true;
    }*/

}