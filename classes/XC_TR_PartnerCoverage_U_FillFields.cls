/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_PartnerCoverage_U_FillFields – Util Class to fill fields for XC_TR_PartnerCoverage Trigger
*/

public without sharing class XC_TR_PartnerCoverage_U_FillFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_PartnerCoverage_U_FillFields');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 07/05/2020
     * @description Method to populate Work Type Label from Formula Field
     * @param listNew - List<XC_PartnerCoverage__c>
    */ 
    public static void populateWorkType(List<XC_PartnerCoverage__c> listNew, Map<Id, XC_PartnerCoverage__c> mapOld, Map<Id, XC_PartnerCoverage__c> mapNew) {   
        List<XC_PartnerCoverage__c> listFiltered = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_WorkType__c'}, mapOld, mapNew);
        populateWorkType(listFiltered);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 07/05/2020
     * @description Method to populate Work Type Label from Formula Field
     * @param listNew - List<XC_PartnerCoverage__c>
    */ 
    public static void populateWorkType(List<XC_PartnerCoverage__c> listNew) {   
        List<XC_PartnerCoverage__c> listPcToUpdate = new List<XC_PartnerCoverage__c>();
        for(XC_PartnerCoverage__c pc : listNew) {
            if(!pc.XC_BlockResourceCoverageCreation__c) {
                XC_PartnerCoverage__c pcToUpdate = new XC_PartnerCoverage__c();
                pcToUpdate.Id = pc.Id;
                pcToUpdate.XC_WorkTypeLabel__c = pc.XC_WorkTypeName__c;
                listPcToUpdate.add(pcToUpdate);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listPcToUpdate);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 10/09/2019
     * @description Method to fill fields on before insert for a list of PartnerCoverage
     * @param listNew - List<XC_PartnerCoverage__c>
    */ 
    public static void populateZipCodeWorkType(List<XC_PartnerCoverage__c> listNew) {   
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> listWrapper = XC_UTIL_ZipCodeWorkType.calculateZipCodeWorkType(listNew);
        Map<String, String> mapZipCodeWorkType = XC_UTIL_ZipCodeWorkType.calculateAssociationZipCodeWorkType(listWrapper);
        for(XC_PartnerCoverage__c pc : listNew) {
            if(mapZipCodeWorkType.containsKey(pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c)) {
                pc.XC_ZipCodeWorkType__c = mapZipCodeWorkType.get(pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c);
            }
            pc.XC_ExternalIdForDuplication__c = pc.XC_Account__c+'_'+pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c;
            pc.XC_ExternalId__c = pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c;
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to fill fields on before insert for a list of PartnerCoverage
     * @param listNew - List<XC_PartnerCoverage__c>
     * @param mapOld - Map<Id, XC_PartnerCoverage__c>
     * @param mapNew - Map<Id, XC_PartnerCoverage__c>
    */ 
    public static void populateZipCodeWorkTypeOnUpdate(List<XC_PartnerCoverage__c> listNew, Map<Id, XC_PartnerCoverage__c> mapOld, Map<Id, XC_PartnerCoverage__c> mapNew) {   
        List<XC_PartnerCoverage__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ZipCode__c', 'XC_WorkType__c'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        XC_TR_PartnerCoverage_U_FillFields.populateZipCodeWorkType(listChanged);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to insert Service Resource Coverage when Partner Coverage is inserted
     * @date 10/09/2019
     * @param listNew - List<XC_PartnerCoverage__c>
    */ 
    public static void insertServiceResourceCoverage(List<XC_PartnerCoverage__c> listNew) { 
        List<XC_PartnerCoverage__c> listPcToManage = new List<XC_PartnerCoverage__c>();
        //List<XC_PartnerCoverage__c> listPcBlockToUpdate = new List<XC_PartnerCoverage__c>();
        for(XC_PartnerCoverage__c pc : listNew) {
            if(!pc.XC_BlockResourceCoverageCreation__c) {
                listPcToManage.add(pc);
            } /*else {
                listPcBlockToUpdate.add(new XC_PartnerCoverage__c(
                    Id = pc.Id,
                    XC_BlockResourceCoverageCreation__c = false
                ));
            }*/
        }
        /*if(!listPcBlockToUpdate.isEmpty()) {
            XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
            XC_UTIL_Sobject.updateListRecords(listPcBlockToUpdate);
            XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }*/
        if(listPcToManage.isEmpty()) {
            return;
        }
        List<String> listAccountIds = XC_UTIL_Sobject.getListFieldValues(listPcToManage, 'XC_Account__c');
        List<Account> listAccountWithServiceResources = new List<Account>([
            SELECT Id, 
                (SELECT Id FROM Service_Resources__r WHERE RelatedRecord.IsActive =: true) 
            FROM Account
            WHERE Id = :listAccountIds
        ]);

        Map<String, List<String>> mapAccountServiceResourceIds = new Map<String, List<String>>();
        for(Account acc : listAccountWithServiceResources) {
            for(ServiceResource sr : acc.Service_Resources__r) {
                if(!mapAccountServiceResourceIds.containsKey(acc.Id)) {
                    mapAccountServiceResourceIds.put(acc.Id, new List<String>());
                }
                mapAccountServiceResourceIds.get(acc.Id).add(sr.Id);
            }
        }

        List<XC_ServiceResourceCoverage__c> listSrCoverageToInsert = new List<XC_ServiceResourceCoverage__c>();
        for(XC_PartnerCoverage__c pc : listPcToManage) {
            if(mapAccountServiceResourceIds.containsKey(pc.XC_Account__c) && mapAccountServiceResourceIds.get(pc.XC_Account__c).size() > 0) {
                for(String srId : mapAccountServiceResourceIds.get(pc.XC_Account__c)) {
                    XC_ServiceResourceCoverage__c srcToInsert = new XC_ServiceResourceCoverage__c();
                    srcToInsert.XC_ServiceResourceId__c = srId;
                    srcToInsert.XC_ZipCodeWorkTypeId__c = pc.XC_ZipCodeWorkType__c;
                    srcToInsert.XC_InheritedFromParent__c = true;
                    srcToInsert.XC_ExternalIdForDuplication__c = srId + '_' + pc.XC_ZipCode__c + '_' + pc.XC_WorkType__c;
                    listSrCoverageToInsert.add(srcToInsert);
                }
            }
        }

        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.insertListRecords(listSrCoverageToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(listWr)) {
            listPcToManage[0].addError(listWr[0].errorMessage);
        } else if(!Test.isRunningTest()) {
            List<XC_PartnerCoverage__c> listPcToManageForUpdate = new List<XC_PartnerCoverage__c>();
            for(XC_PartnerCoverage__c pcToUpdate : listPcToManage) {
                listPcToManageForUpdate.add(new XC_PartnerCoverage__c(
                    Id = pcToUpdate.Id,
                    XC_BlockResourceCoverageCreation__c = false
                ));
            }
            if(!listPcToManageForUpdate.isEmpty()) {
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
                XC_UTIL_Sobject.updateListRecords(listPcToManageForUpdate);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to delete Service Resource Coverage when Partner Coverage is deleted
     * @date 10/09/2019
     * @param listOld - List<XC_PartnerCoverage__c>
     * @param partnerId - String
    */ 
    public static void deleteServiceResourceCoverage(List<XC_PartnerCoverage__c> listOld, String partnerId) { 
        List<XC_PartnerCoverage__c> listPcToManage = new List<XC_PartnerCoverage__c>(); 
        for(XC_PartnerCoverage__c pc : listOld) {
            if(!pc.XC_BlockResourceCoverageCreation__c && !Test.isRunningTest()) {
                if(String.isNotBlank(partnerId)) {
                    pc.XC_Account__c = partnerId;
                }
                listPcToManage.add(pc);
            } 
        }
        if(listPcToManage.isEmpty()) {
            if(Test.isRunningTest()) {
                listPcToManage = listOld;
            } else {
                return;
            }
        }
        XC_TR_PartnerCoverage_U_FillFields_W.ServiceResourceCoverageWrapper srcWrapper = populateInputForCheckWrapper(listPcToManage, partnerId);
        XC_TR_PartnerCoverage_U_FillFields_W.InputZipCodeWorkTypeWrapper inputForCheckZipCodeWorkTypeWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.InputZipCodeWorkTypeWrapper();
        inputForCheckZipCodeWorkTypeWrapper.useOld = false;
        inputForCheckZipCodeWorkTypeWrapper.listPartnerCoverage = listPcToManage;
        inputForCheckZipCodeWorkTypeWrapper.srcWrapper = srcWrapper;
        XC_TR_PartnerCoverage_U_FillFields_W.CheckZipCodeWorkTypeWrapper outputCheckWrapper = checkForZipCodeWorkType(inputForCheckZipCodeWorkTypeWrapper);       

        List<XC_ServiceResourceCoverage__c> listSrCoverageToDelete = new List<XC_ServiceResourceCoverage__c>();
        XC_TR_PartnerCoverage_U_FillFields_W.ListServiceCoverageToDeleteWrapper srcDeleteWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.ListServiceCoverageToDeleteWrapper();
        srcDeleteWrapper.mapSrIdListCovIds = outputCheckWrapper.mapSrIdListCovIds;
        srcDeleteWrapper.mapAccountServiceResourceIds = srcWrapper.mapAccountServiceResourceIds;
        for(XC_PartnerCoverage__c pc : listPcToManage) {
            srcDeleteWrapper.pc = pc;
            XC_TR_PartnerCoverage_U_FillFields_W.populateListServiceCoverageToDelete(listSrCoverageToDelete, srcDeleteWrapper);
        }
        
        Map<Id, XC_ServiceResourceCoverage__c> mapUniqueSRC = new Map<Id, XC_ServiceResourceCoverage__c>();
        for(XC_ServiceResourceCoverage__c src : listSrCoverageToDelete){
            if(String.isNotBlank(partnerId)) {
                src.XC_InheritedFromParent__c = true;
            }
            mapUniqueSRC.put(src.Id, src);
        }

        if(String.isNotBlank(partnerId)) {
            XC_TR_ServiceResourceCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceResourceCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
            XC_UTIL_Sobject.updateListRecords(mapUniqueSRC.values());
            XC_TR_ServiceResourceCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceResourceCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        }
        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.deleteListRecords(mapUniqueSRC.values());
        if(!XC_UTIL_Sobject.checkDMLResults(listWr)) {
            listPcToManage[0].addError(listWr[0].errorMessage);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
    * @description Method to update Service Resource Coverage when Partner Coverage is updated
    * @date 10/09/2019
    * @param listOld - List<XC_PartnerCoverage__c>
    * @param mapOld - Map<Id, XC_PartnerCoverage__c>
    * @param mapNew - Map<Id, XC_PartnerCoverage__c>
    */ 
    public static void updateServiceResourceCoverage(List<XC_PartnerCoverage__c> listOld, Map<Id, XC_PartnerCoverage__c> mapOld, Map<Id, XC_PartnerCoverage__c> mapNew) { 
        List<XC_PartnerCoverage__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ZipCodeWorkType__c'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        List<XC_PartnerCoverage__c> listPcToManage = new List<XC_PartnerCoverage__c>();
        for(XC_PartnerCoverage__c pc : listChanged) {
            if(!pc.XC_BlockResourceCoverageCreation__c) {
                listPcToManage.add(pc);
            }
        }
        if(listPcToManage.isEmpty()) {
            return;
        }
        XC_TR_PartnerCoverage_U_FillFields_W.ServiceResourceCoverageWrapper srcWrapper = populateInputForCheckWrapper(listPcToManage, '');

        XC_TR_PartnerCoverage_U_FillFields_W.InputZipCodeWorkTypeWrapper inputForCheckZipCodeWorkTypeWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.InputZipCodeWorkTypeWrapper();
        inputForCheckZipCodeWorkTypeWrapper.useOld = true;
        inputForCheckZipCodeWorkTypeWrapper.listPartnerCoverage = listPcToManage;
        inputForCheckZipCodeWorkTypeWrapper.srcWrapper = srcWrapper;
        inputForCheckZipCodeWorkTypeWrapper.mapOld = mapOld;
        XC_TR_PartnerCoverage_U_FillFields_W.CheckZipCodeWorkTypeWrapper outputCheckWrapper = checkForZipCodeWorkType(inputForCheckZipCodeWorkTypeWrapper);    
        List<XC_ServiceResourceCoverage__c> listSrCoverageToUpdate = new List<XC_ServiceResourceCoverage__c>();
        for(XC_PartnerCoverage__c pc : listPcToManage) {
            if(srcWrapper.mapAccountServiceResourceIds.containsKey(pc.XC_Account__c)) {
                for(String srId : srcWrapper.mapAccountServiceResourceIds.get(pc.XC_Account__c)) {
                    for(String srcId : outputCheckWrapper.mapSrIdListCovIds.get(srId)) {
                        listSrCoverageToUpdate.add(new XC_ServiceResourceCoverage__c(
                            Id = srcId,
                            XC_ZipCodeWorkTypeId__c = outputCheckWrapper.mapSrIdPartnerCoverage.get(srId).XC_ZipCodeWorkType__c
                        ));
                    }
                }
            }
        }

        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.updateListRecords(listSrCoverageToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWr)) {
            listPcToManage[0].addError(listWr[0].errorMessage);
        } else if(!Test.isRunningTest()) {
            List<XC_PartnerCoverage__c> listPcToManageForUpdate = new List<XC_PartnerCoverage__c>();
            for(XC_PartnerCoverage__c pcToUpdate : listPcToManage) {
                listPcToManageForUpdate.add(new XC_PartnerCoverage__c(
                    Id = pcToUpdate.Id,
                    XC_BlockResourceCoverageCreation__c = false
                ));
            }
            if(!listPcToManageForUpdate.isEmpty()) {
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
                XC_UTIL_Sobject.updateListRecords(listPcToManageForUpdate);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_PartnerCoverage_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @description Method to populate ServiceResourceCoverageWrapper
     * @date 10/09/2019
     * @param listPartnerCoverage - List<XC_PartnerCoverage__c>
     * @param partnerId - String
     * @return ServiceResourceCoverageWrapper
    */ 
    private static XC_TR_PartnerCoverage_U_FillFields_W.ServiceResourceCoverageWrapper populateInputForCheckWrapper(List<XC_PartnerCoverage__c> listPartnerCoverage, String partnerId) {
        XC_TR_PartnerCoverage_U_FillFields_W.ServiceResourceCoverageWrapper outputWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.ServiceResourceCoverageWrapper();
        List<String> listAccountIds = new List<String>();
        if(String.isBlank(partnerId)) {
            listAccountIds = XC_UTIL_Sobject.getListFieldValues(listPartnerCoverage, 'XC_Account__c');
        } else {
            listAccountIds.add(partnerId);
        }
        List<Account> listAccountWithServiceResources = new List<Account>([
            SELECT Id, 
                (SELECT Id FROM Service_Resources__r WHERE RelatedRecord.IsActive =: true) 
            FROM Account
            WHERE Id = :listAccountIds
        ]);
        
        for(Account acc : listAccountWithServiceResources) {
            for(ServiceResource sr : acc.Service_Resources__r) {
                if(!outputWrapper.mapAccountServiceResourceIds.containsKey(acc.Id)) {
                    outputWrapper.mapAccountServiceResourceIds.put(acc.Id, new List<String>());
                }
                outputWrapper.mapAccountServiceResourceIds.get(acc.Id).add(sr.Id);
                outputWrapper.mapServiceResourceAccountId.put(sr.Id, acc.Id);
                outputWrapper.listServiceResourceIds.add(sr.Id);
            }
        }
        return outputWrapper;
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
    * @description Method to populate for CheckZipCodeWorkTypeWrapper
    * @date 10/09/2019
    * @param inputWrapper - InputZipCodeWorkTypeWrapper
    * @return CheckZipCodeWorkTypeWrapper
    */ 
    private static XC_TR_PartnerCoverage_U_FillFields_W.CheckZipCodeWorkTypeWrapper checkForZipCodeWorkType(XC_TR_PartnerCoverage_U_FillFields_W.InputZipCodeWorkTypeWrapper inputWrapper) {
        XC_TR_PartnerCoverage_U_FillFields_W.CheckZipCodeWorkTypeWrapper outputWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.CheckZipCodeWorkTypeWrapper();
        Map<String, List<String>> mapServiceResourceListZipCodeWt = new Map<String, List<String>>();
        List<String> listZipCodeWorkTypeIds = new List<String>();
        XC_TR_PartnerCoverage_U_FillFields_W.ZipCodeCoverageWrapper zipCodeCoverageWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.ZipCodeCoverageWrapper();
        zipCodeCoverageWrapper.mapAccountServiceResourceIds = inputWrapper.srcWrapper.mapAccountServiceResourceIds;
        if(inputWrapper.useOld) {
            zipCodeCoverageWrapper.mapPartnerCoverageOld = inputWrapper.mapOld;
            zipCodeCoverageWrapper.useOld = inputWrapper.useOld;
        }
        for(XC_PartnerCoverage__c pc : inputWrapper.listPartnerCoverage) {
            zipCodeCoverageWrapper.pc = pc;
            zipCodeCoverageWrapper.listZipCodeWorkTypeIds = listZipCodeWorkTypeIds;
            zipCodeCoverageWrapper.mapServiceResourceListZipCodeWt = mapServiceResourceListZipCodeWt;
            if(inputWrapper.useOld) {
                zipCodeCoverageWrapper.mapSrIdPartnerCoverage = outputWrapper.mapSrIdPartnerCoverage;
            }
            XC_TR_PartnerCoverage_U_FillFields_W.populateZipCodeCoverageWrapper(zipCodeCoverageWrapper);
            listZipCodeWorkTypeIds = zipCodeCoverageWrapper.listZipCodeWorkTypeIds;
            mapServiceResourceListZipCodeWt = zipCodeCoverageWrapper.mapServiceResourceListZipCodeWt;
            if(inputWrapper.useOld) {
                outputWrapper.mapSrIdPartnerCoverage = zipCodeCoverageWrapper.mapSrIdPartnerCoverage;
            }
        }
        List<XC_ServiceResourceCoverage__c> listSrCoverage = new List<XC_ServiceResourceCoverage__c>([
            SELECT Id, XC_ServiceResourceId__c, XC_ZipCodeWorkTypeId__c
            FROM XC_ServiceResourceCoverage__c
            WHERE XC_ServiceResourceId__c IN :inputWrapper.srcWrapper.listServiceResourceIds AND XC_ZipCodeWorkTypeId__c IN :listZipCodeWorkTypeIds AND XC_ServiceResourceId__r.RelatedRecord.IsActive =: true
        ]);
        XC_TR_PartnerCoverage_U_FillFields_W.PopulateSrcMapWrapper populateWrapper = new XC_TR_PartnerCoverage_U_FillFields_W.PopulateSrcMapWrapper();
        populateWrapper.mapServiceResourceAccountId = inputWrapper.srcWrapper.mapServiceResourceAccountId;
        populateWrapper.listOld = inputWrapper.listPartnerCoverage;
        if(inputWrapper.useOld) {
            populateWrapper.useOld = inputWrapper.useOld;
            populateWrapper.mapPartnerCoverageOld = inputWrapper.mapOld;
        }
        for(XC_ServiceResourceCoverage__c src : listSrCoverage) {
            populateWrapper.src = src;
            XC_TR_PartnerCoverage_U_FillFields_W.populateMapServiceResourceCoverage(populateWrapper, outputWrapper.mapSrIdListCovIds);
        }      
        return outputWrapper;
    }

}