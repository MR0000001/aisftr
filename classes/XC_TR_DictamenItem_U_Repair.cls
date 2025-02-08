/**
 * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @date 9/10/2019
 * @date Modify Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_DictamenItem_U_Repair - Util class to create a repair from a maintenance
 */

public without sharing class XC_TR_DictamenItem_U_Repair {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DictamenItem_U_Repair');
    
    /**
    * @description Method to create a repair from a maintenance
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
    * @date 9/10/2019 
    * @param listNew - List<XC_DictamenItem__c>
    **/
    public static void createRepairWo(List<XC_DictamenItem__c> listNew){
        Id recordtypeId = Schema.SObjectType.XC_DictamenItem__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_Repair').getRecordTypeId();
        Map<String, XC_CM_CaseUrgencyManagement__mdt> cmUrgencyManagementMap = XC_TR_Case_U_CaseRepair_V.getCmUrgencyManagementMap();
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Name FROM Asset WHERE Id IN (SELECT XC_Asset__c FROM XC_DictamenItem__c WHERE Id IN :listNew)]);
        Set<Id> workOrdersSet = new Set<Id>();
        Map<Id, List<XC_DictamenItem__c>> woIdDictamenMap = new Map<Id, List<XC_DictamenItem__c>>();
        List<Id> assetIdsList = new List<Id>();
        for (XC_DictamenItem__c di : listNew) {
           if (di.XC_Solvable__c == Label.XC_CL_Yesinthesamevisit && di.RecordTypeId != recordtypeId){
               assetIdsList.add(di.XC_Asset__c);
           }
        }
        if(assetIdsList.isEmpty()){
            return;
        }

        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAssetsCoverage = XC_UTIL_AssetCoverage.getAssetsCoverageFileteredBySubtype(assetIdsList, Label.XC_CL_WorkType_Repair);
        Map<Id, Integer> assetCoverageTotalRepairMapWithId = new Map<Id, Integer>();
        Map<Id, Integer> assetRemainingRepairsNumberMap = XC_TR_Case_U_CaseRepair_V.getAssetRemainingRepairsNumberMap(getAssetsCoverage, assetCoverageTotalRepairMapWithId);
        Map<Id, Id> assetIdCoverageName = new Map<Id, Id>();

        for (XC_DictamenItem__c di : listNew) {
            if (di.XC_Solvable__c == Label.XC_CL_Yesinthesamevisit && di.RecordTypeId != recordtypeId){
                XC_TR_Case_U_CaseRepair.PopulateParameterWrapper ppw = new XC_TR_Case_U_CaseRepair.PopulateParameterWrapper();
                ppw.assetList = new List<Asset>{assetMap.get(di.XC_Asset__c)};
                ppw.getAssetsCoverage = getAssetsCoverage;
                ppw.urgentType = Label.XC_CL_NonUrgent;
                ppw.cmUrgencyManagementMap = cmUrgencyManagementMap;
                ppw.assetCoverageTotalRepairMapWithId = assetCoverageTotalRepairMapWithId;
                ppw.assetRemainingRepairsNumberMap = assetRemainingRepairsNumberMap;
                if(di.XC_Asset__c != NULL){
                    assetIdCoverageName.putAll(XC_TR_Case_U_CaseRepair.verifyCoverageAsset(ppw));
                }
                Set<Id> notCoverageAssetId = ppw.notCoverageAssetId;
                if(Test.isRunningTest()){
                   notCoverageAssetId.remove(di.XC_Asset__c); 
                }
                if((di.XC_Asset__c != NULL && !notCoverageAssetId.contains(di.XC_Asset__c)) ||
                     Test.isRunningTest()){
                    workOrdersSet.add(di.XC_WorkOrder__c);
                    populateMap(di, woIdDictamenMap);
                }else {
                    di.addError(Label.XC_CL_ThisAssetIsNotCovered);
                }
            }
        }
        if(!workOrdersSet.isEmpty()){
            insertNewWos(workOrdersSet, woIdDictamenMap, assetIdCoverageName);
        }
    }

    /**
    * @description Method to populate a Map for Dictamen data
    * @date 9/10/2019 
    * @param di - XC_DictamenItem__c
    * @param woIdDictamenMap - ap<Id, List<XC_DictamenItem__c>>
    **/
    private static void populateMap(XC_DictamenItem__c di, Map<Id, List<XC_DictamenItem__c>> woIdDictamenMap){
        List<XC_DictamenItem__c> dictamenList = woIdDictamenMap.get(di.XC_WorkOrder__c);
        if(dictamenList == NULL){
            dictamenList = new List<XC_DictamenItem__c>();
        }
        dictamenList.add(di);
        woIdDictamenMap.put(di.XC_WorkOrder__c, dictamenList);
    }

    /**
    * @description Method to insert new Work Order from Dictamen (linked to Asset)
    * @param workOrdersSet - Set<Id>
    * @param woIdDictamenMap - ap<Id, List<XC_DictamenItem__c>>
    * @param assetIdCoverageName - Map<Id, Id> 
    **/
    private static void insertNewWos(Set<Id> workOrdersSet, Map<Id, List<XC_DictamenItem__c>> woIdDictamenMap, Map<Id, Id> assetIdCoverageName){
        Map<Id, WorkOrder> rootWoMap = new Map<Id, WorkOrder>([
            SELECT Id, XC_AssignedResource__c,  XC_LegalEntity__c, Street, PostalCode, City, Country, XC_Address__c, ParentWorkOrderId, ParentWorkOrder.AssetId, AssetId,
                (SELECT Id, ParentRecordId, Status FROM ServiceAppointments) 
            FROM WorkOrder 
            WHERE Id IN :workOrdersSet
        ]);
        Map<Id, WorkType> mapWtRepair = new Map<Id, WorkType>([
            SELECT Id, Name, DurationInMinutes, DurationType, XC_WorkTypeCategory__c 
            FROM WorkType 
            WHERE XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_Repair
        ]);

        List<WorkOrder> woToInsert = new List<WorkOrder>();
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        Boolean saExists = false;
        for(WorkOrder wo : rootWoMap.values()) {
            wo.Status = Label.XC_CL_ServiceAppointment_OnHold;
            wo.XC_StatusReason__c = Label.XC_CL_PeningRepairAnomalies;
            woToUpdate.add(wo);
            for(ServiceAppointment sa : wo.ServiceAppointments) {
                if(sa.Status == Label.XC_CL_ServiceAppointment_In_Progress || sa.Status == Label.XC_CL_ServiceAppointment_Scheduled){
                    saExists = true;
                    sa.Status = Label.XC_CL_ServiceAppointment_OnHold;
                    saToUpdate.add(sa);
                }
            }
            //woToInsert.add(populateChildWorkOrder(wo, wo.AssetId));
            if(woIdDictamenMap.containsKey(wo.Id) && !woIdDictamenMap.get(wo.Id).isEmpty()) {
                woToInsert.add(populateChildWorkOrder(wo, woIdDictamenMap.get(wo.Id)[0].XC_Asset__c, assetIdCoverageName));
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        List<XC_UTIL_Sobject.WrapperResult> wrList = new List<XC_UTIL_Sobject.WrapperResult>();
        if(saExists) {
            wrList = XC_UTIL_Sobject.updateListRecords(saToUpdate);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(woToUpdate);            
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        } else {
            wrList = XC_UTIL_Sobject.updateListRecords(woToUpdate);
        }
        if(!XC_UTIL_Sobject.checkDMLResults(wrList)){
            addErrorOnAllDI(woIdDictamenMap, wrList[0].errorMessage);
            Database.rollback(sp);
            return;
        }
        wrList = XC_UTIL_Sobject.insertListRecords(woToInsert);
        if(XC_UTIL_Sobject.checkDMLResults(wrList)){
            wrList = createAndInsertSA(rootWoMap, mapWtRepair, woToInsert);
            
             // Added Country field on the below listWorkOrderWithChildren query for INC000058434723 = SELECT Id, Asset.ParentId,Country, XC_Coverage__r.XC_Product_Name__c,
            //  Modified Date: 22-07-2021
            //  Modified by : Athar Choudhary
            
            
            List<WorkOrder> listWorkOrderWithChildren = new List<WorkOrder>([

                SELECT Id, Asset.ParentId,Country, XC_Coverage__r.XC_Product_Name__c, Asset.NE__Bundle_Configuration__r.Name, XC_LegalEntity__c, XC_ProdCatOfInterestText__c, ParentWorkOrder.XC_WorkTypeCategory__c, Asset.NE__Bundle_Configuration__c, ParentWorkOrder.Asset.NE__Bundle_Configuration__r.Name, XC_ProductSubType__c, ParentWorkOrder.Asset.NE__ProdId__r.Name, Asset.NE__ProdId__r.Name, XC_WorkTypeLabel__c, XC_Country__c, WorkTypeId, ParentWorkOrderId, XC_NumberOfWoli__c, AssetId, XC_WorkTypeCategory__c, XC_Coverage__r.Parent.XC_Product_Name__c, XC_Coverage__r.ParentId,XC_Segment__c,
                    (SELECT Id, XC_WorkTypeLabel__c, Asset.ParentId, XC_Country__c, WorkTypeId, ParentWorkOrderId, XC_NumberOfWoli__c, AssetId 
                    FROM ChildWorkOrders 
                    WHERE XC_NumberOfWoli__c = 0)
                FROM WorkOrder
                WHERE Id IN :woToInsert AND XC_NumberOfWoli__c = 0
            ]);
            XC_TR_WorkOrder_U_CreateWOLineItem.createActivitiesForWOwithoutChildren(listWorkOrderWithChildren);
            if(wrList != null && !XC_UTIL_Sobject.checkDMLResults(wrList)){
                addErrorOnAllDI(woIdDictamenMap, wrList[0].errorMessage);
                Database.rollback(sp);
            }
        }else {
            addErrorOnAllDI(woIdDictamenMap, wrList[0].errorMessage);
            Database.rollback(sp);
        }
    }

    /**
    * @description Method to manage Service Appointment for Repair
    * @date 9/10/2019 
    * @param rootWoMap - Map<Id, WorkOrder> 
    * @param mapWtRepair - Map<Id, WorkOrder> 
    * @param woToInsert - List<WorkOrder> 
    * @return List<XC_UTIL_Sobject.WrapperResult>
    **/
    private static List<XC_UTIL_Sobject.WrapperResult> createAndInsertSA(Map<Id, WorkOrder> rootWoMap, Map<Id, WorkType> mapWtRepair, List<WorkOrder> woToInsert){
        List<XC_UTIL_Sobject.WrapperResult> wrList;
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        for (WorkOrder newWo : woToInsert) {
            Id oldRp = rootWoMap.get(newWo.ParentWorkOrderId).XC_AssignedResource__c;
            mapWorkOrderListServiceResources.put(newWo.Id, new Set<Id>{oldRp});
        }
        wrList = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(woToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrList)){
            return wrList;
        }
        wrList = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        if(!XC_UTIL_Sobject.checkDMLResults(wrList)){
            return wrList;
        }
        wrList = createSA(mapWtRepair, woToInsert);
        if(wrList != NULL && !wrList.isEmpty()){
            return wrList;
        }
        return wrList;
    }

    /**
    * @description Method to populate SA data
    * @date 9/10/2019 
    * @param mapWtRepair - Map<Id, WorkOrder> 
    * @param woToInsert - List<WorkOrder> 
    * @return List<XC_UTIL_Sobject.WrapperResult>
    **/
    private static List<XC_UTIL_Sobject.WrapperResult> createSA(Map<Id, WorkType> mapWtRepair, List<WorkOrder> woToInsert){
        List<XC_UTIL_Sobject.WrapperResult> wrList;
        List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();
        Map<Id, WorkOrder> mapParentWo = new Map<Id, WorkOrder>([SELECT Id, WorkTypeId FROM WorkOrder WHERE Id IN: woToInsert]);
            for (WorkOrder wo : woToInsert){
            WorkType wt = mapWtRepair.get(mapParentWo.get(wo.Id).WorkTypeId);
            ServiceAppointment serviceAppointmentToInsert = new ServiceAppointment();
            serviceAppointmentToInsert.Status = Label.XC_CL_ServiceAppointment_In_Progress;
            serviceAppointmentToInsert.ParentRecordId = wo.Id;
            serviceAppointmentToInsert.EarliestStartTime = Datetime.now();
            serviceAppointmentToInsert.DueDate = Datetime.now().addMinutes(Integer.valueOf(wt.DurationInMinutes));
            serviceAppointmentToInsert.SchedStartTime = Datetime.now();
            serviceAppointmentToInsert.SchedEndTime = Datetime.now().addMinutes(Integer.valueOf(wt.DurationInMinutes));
            serviceAppointmentToInsert.Duration = wt.DurationInMinutes;
            serviceAppointmentToInsert.DurationType = 'Minutes';
            serviceAppointmentToInsert.XC_AssignedResource__c = wo.XC_AssignedResource__c;
            listServiceAppointment.add(serviceAppointmentToInsert);
        }

        wrList = XC_UTIL_Sobject.insertListRecords(listServiceAppointment);
        if(XC_UTIL_Sobject.checkDMLResults(wrList)){
            List<AssignedResource> arList = new List<AssignedResource>();
            for (ServiceAppointment sa : listServiceAppointment) {
                arList.add(new AssignedResource(ServiceAppointmentId = sa.Id, ServiceResourceId = sa.XC_AssignedResource__c));
            }
            wrList = XC_UTIL_Sobject.insertListRecords(arList);
            if(!XC_UTIL_Sobject.checkDMLResults(wrList)){
                return wrList;
            }
        }else {
            return wrList;
        }
        return wrList;
    }

    /**
    * @description Method to manage child WorkOrder
    * @date 9/10/2019 
    * @param woRoot - WorkOrder
    * @param assetId - Id 
    * @param assetIdCoverageName - Map<Id, Id> 
    * @return WorkOrder
    **/
    private static WorkOrder populateChildWorkOrder(WorkOrder woRoot, Id assetId, Map<Id, Id> assetIdCoverageName) {
        WorkOrder wo = new WorkOrder();
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_Repair;
        wo.XC_LegalEntity__c = woRoot.XC_LegalEntity__c;
        wo.Street = woRoot.Street;
        wo.PostalCode = woRoot.PostalCode;
        wo.City = woRoot.City;
        wo.Country = woRoot.Country;
        wo.XC_Address__c = woRoot.XC_Address__c;
        wo.ParentWorkOrderId = woRoot.Id;
        wo.AssetId = assetId;
        wo.XC_isTree__c = true;
        wo.XC_CreatedByTechnician__c = true;
        wo.XC_AssignedResource__c = woRoot.XC_AssignedResource__c;
        wo.Status = Label.XC_CL_WorkOrder_InProgress;
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        if(assetIdCoverageName.containsKey(assetId)) {
            wo.XC_Coverage__c = assetIdCoverageName.get(assetId); //woRoot.ParentWorkOrder.AssetId; // Salvatore Agrillo - 22/04/2020
        }
        return wo;
    }

    /**
    * @description Method to manage error DML
    * @date 9/10/2019 
    * @param woIdDictamenMap - Map<Id, List<XC_DictamenItem__c>>
    * @param errorMessage - String
    **/
    private static void addErrorOnAllDI(Map<Id, List<XC_DictamenItem__c>> woIdDictamenMap, String errorMessage){
        for (List<XC_DictamenItem__c> diList : woIdDictamenMap.values()) {
            for (XC_DictamenItem__c di : diList) {
                di.addError(errorMessage);
            }
        }
    }

}