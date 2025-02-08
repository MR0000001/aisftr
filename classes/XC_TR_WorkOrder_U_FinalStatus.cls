/**
 * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com & Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date 16-11-2018
 * @date Modification 05/02/2020 Salvatore Agrillo - salvatore.agrillo@nttdata.com 
 * @description XC_TR_WorkOrder_U_FinalStatus - Class to manage the status of work order
 */   

public without sharing class XC_TR_WorkOrder_U_FinalStatus {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_FinalStatus');
    private static Boolean calledGlovia = false;

    public class UtilMapWrapper{
        Map<Id, List<String>> woIdUploadedDocuments = new Map<Id, List<String>>();
        Map<Id, Map<String, Integer>> woIdUploadedDocumentTypesMap = new Map<Id, Map<String, Integer>>();
    }
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to update WorkOrder fields
     */
    public static void updateWorkOrderFinalStatus(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<WorkOrder> workOrderinFinalStatusList = new List<WorkOrder>();//XC_UTIL_WorkOrder.workOrdersInFinalStatus(listChanged);
        for(WorkOrder wo : listChanged){
            if(wo.XC_Check_Final_Status__c){
                workOrderinFinalStatusList.add(wo);
            } else if(wo.Status != Label.XC_CL_WorkOrder_InProgress) {
                wo.XC_UpdatedByApp__c = false;
            }
        }
        if(workOrderinFinalStatusList.isEmpty()){
            return;
        }
        List<Id> woIds = XC_UTIL_SObject.getIds(workOrderinFinalStatusList);
        Map<Id, WorkOrder> woWithAppointmentsMap = new Map<Id, WorkOrder>([
            SELECT Id,
                (SELECT Id, ActualDuration
                FROM ServiceAppointments
                WHERE ActualDuration != null)
            FROM WorkOrder   
            WHERE Id IN: woIds]);

        List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
        for(WorkOrder wo : workOrderinFinalStatusList){
            if(wo.StartDate == null ){ 
                wo.StartDate = System.Now();
            }
            wo.EndDate = System.Now();
            for(ServiceAppointment sa : woWithAppointmentsMap.get(wo.Id).ServiceAppointments){
                if(sa.ActualDuration != null &&  wo.XC_TotalActualDuration__c != null){
                    wo.XC_TotalActualDuration__c = wo.XC_TotalActualDuration__c + sa.ActualDuration;   
                }        
            }

            // For WorkExecuted:
            if(!wo.XC_WorkExecuted__c) {
                wo.XC_WorkExecuted__c = true;
            }
        }
        updateDeliveryStatus(workOrderinFinalStatusList);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 04/07/2020
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to check if it is possible to close Work Order Site Inspection
     */
    public static void checkForSiteInspection(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        // Check WO with new Status:
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }

        // Check if there is a block for this check:
        List<XC_CM_LegalEntity_Configuration__mdt> listLEconf = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BlockNotRequiredSiteInspection__c,XC_SiteInspReqTechProdSubType__c,XC_SkipTechProdbyCatInterest__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE (XC_LegalEntity__c = :Label.XC_CL_LegalEntity_Italy OR XC_LegalEntity__c = :Label.XC_CL_LegalEntity_EnelXMobilityItalia) AND XC_Stream__c = :listChanged[0].XC_Segment__c
        ]);
        if(listLEconf.isEmpty() || (!listLEconf.isEmpty() && String.isBlank(listLEconf[0].XC_SiteInspReqTechProdSubType__c))) {
            return;
        }

        // Retrieve Subtype to check:
        List<String> listTechProductSubtypes = listLEconf[0].XC_SiteInspReqTechProdSubType__c.split(';');
        Set<String> setSubTypes = new Set<String>();
        setSubTypes.addAll(listTechProductSubtypes);
        //NR0807 -- Skip the Technical Product Check by  XC_ProductCategoryOfInterest__c
        Set<String> categoryInterestSet = new Set<String>();
        if(String.isNotBlank(listLEconf[0].XC_SkipTechProdbyCatInterest__c)) {
            String[] categoryInterestList = listLEconf[0].XC_SkipTechProdbyCatInterest__c.split(';');
            categoryInterestSet.addAll(categoryInterestList);
        }
        // Filter WO for Italy and with Existing Configuration and with New Status Completed:
        List<WorkOrder> listWoToManage = new List<WorkOrder>();
        for(WorkOrder wo : listChanged) {
            if(String.isNotBlank(wo.XC_Configuration__c) && (wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection && mapOld.get(wo.Id).Status != Label.XC_CL_Completed && mapNew.get(wo.Id).Status == Label.XC_CL_Completed) {
                listWoToManage.add(wo);
            }
        }
        if(listWoToManage.isEmpty()) {
            return;
        }

        // Query Configuration Items:
        List<String> listOrderId = XC_UTIL_Sobject.getListFieldValues(listWoToManage, 'XC_Configuration__c');
        List<NE__Order__c> listOrder = new List<NE__Order__c>([
                SELECT Id, XC_FinancialPracticeStatus__c, XC_Status__c, NE__Type__c, NE__AccountId__c,NE__OptyId__r.XC_Contact__c, XC_FinancialPracticeNumber__c, XC_FinancialInstitution__c, NE__AccountId__r.IdentityType__c, 
                        NE__AccountId__r.IdentityNumber__c, NE__AccountId__r.XC_DocumentCountry__c, NE__AccountId__r.Name, NE__OptyId__r.XC_ProductCategoryOfInterest__c, NE__OptyId__r.XC_Address__r.XC_PostalCode__c,
                        XC_LegalEntity__c, XC_Segment__c, NE__OptyId__r.XC_CTI_Interaction__c,XC_CTICallRecording__c,
                        (
                            SELECT Id, Name, XC_BillingProfileLineItem__c, XC_LegalEntityFormula__c, XC_PaymentMethod__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c,XC_Wbe__c, XC_CreditAssignmentAvailable__c, 
                                XC_CityCode__c, XC_UrbanSection__c, XC_Sheet__c, XC_Particle__c, XC_Subordinate__c, XC_HouseType__c,NE__ProdId__c,XC_Complex_Product__c
                            FROM NE__Order_Items__r),
                        (
                            SELECT Id 
                            FROM Work_Orders__r
                        )
                FROM NE__Order__c
                WHERE Id IN :listOrderId
        ]);
        Map<String, NE__Order__c> mapOrder = new Map<String, NE__Order__c>();
        for(NE__Order__c ord : listOrder) {
            for(WorkOrder wo : ord.Work_Orders__r) {
                mapOrder.put(wo.Id, ord);
            }
        }

        List<WorkOrder> listWoWithError = new List<WorkOrder>();
        for(WorkOrder wo : listWoToManage) {
            // Retrieve order and order items:
            if(!mapOrder.containsKey(wo.Id)) {
                continue;
            }
            NE__Order__c ord = mapOrder.get(wo.Id);
            //NR0807 -- Skip the Technical Product Check by Opportunity XC_ProductCategoryOfInterest__c
            if(categoryInterestSet.contains(ord.NE__OptyId__r.XC_ProductCategoryOfInterest__c)) {
                continue;
            }

            List<NE__OrderItem__c> listOrderItemsChild = ord.NE__Order_Items__r;
            // Check if in the Order Items there is one that needs to be checked:
            Boolean checkNeeded = false;
            for(NE__OrderItem__c oi : listOrderItemsChild) {
                if(setSubTypes.contains(oi.XC_Product_Subtype__c)) {
                    checkNeeded = true;
                    break;
                }
            }
            if(checkNeeded) {
                Boolean withoutError = false;
                for(NE__OrderItem__c oi : listOrderItemsChild) {
                    if(oi.XC_Product_Type__c == Label.XC_CL_Technical && oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubTypeValue) {
                        withoutError = true;
                    }
                }
                if(!withoutError) {
                    listWoWithError.add(wo);
                }
            }
        }
        for(WorkOrder wo : listWoWithError) {
            wo.addError('('+wo.WorkOrderNumber+') ' + Label.XC_CL_LCC099_CheckTechProductSIError);
        }
    }
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com / Salvatore Agrillo salvatore.agrillo@nttdata.com
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to update WorkOrder data fields
     */
    public static void updateStartDateOnWorkOrder(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            for(WorkOrder wo : listChanged){
                if(wo.Status == Label.XC_CL_WorkOrder_InProgress){
                    wo.StartDate = System.now();
                } 
            }    
        }     
    }


    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listNew - List<WorkOrder>
     * @param mapOld - Map<Id,WorkOrder>
     * @param mapNew - Map<Id,WorkOrder>
     * @description Method to create a list of updated work order for which the status is changed.
     */
    public static void manageWorkOrderFinalStatus(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'Status','XC_SubStatus__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<WorkOrder> workOrderinFinalStatusList = XC_UTIL_WorkOrder.workOrdersInFinalStatus(listChanged);
        if(!workOrderinFinalStatusList.isEmpty()){
            updateSteps(workOrderinFinalStatusList);
            updateAsset(workOrderinFinalStatusList, mapNew);
            XC_TR_WorkOrder_U_FinalStatus_U.createWorkOrderMaintenance(workOrderinFinalStatusList); // MR-SS - 12/12/2018 -  ESCEP-551 ESCEP-833
        } 
    }

    /**
     * @author Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listWorkOrder - List<WorkOrder>
     * @description Method to check that the status of the WorkOrder is completed and set to Completed OK the corresponding step status
     */   
    public static void updateSteps(List<WorkOrder> listWorkOrder){ 
        List<WorkOrder> listWoRepair = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair) {
                listWoRepair.add(wo);
            }
        }
        List<XC_Provisioning_Step__c> listStep = new List<XC_Provisioning_Step__c>();
        List<String> listConfigurationItemIds = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_Configuration_Item__c');
        if(listConfigurationItemIds.isEmpty() && listWoRepair.isEmpty()){
            return;
        }
        List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>([
            SELECT Id, XC_Flow_API_Name__c, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c
            FROM XC_Provisioning_Step__c
            WHERE XC_Status__c = :Label.XC_CL_Provisioning_Step_InProgress AND 
                    (XC_Configuration_Item__c IN :listConfigurationItemIds OR 
                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c IN :listWorkOrder)
        ]);
        if(listSteps.isEmpty()){
            return;
        }
        Map<Id, List<XC_Provisioning_Step__c>> mapConfItemProvisioningSteps = new Map<Id, List<XC_Provisioning_Step__c>>();
        Map<Id, XC_Provisioning_Step__c> mapWorkOrderTechQuote = new Map<Id, XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c ps : listSteps) {
            if(listConfigurationItemIds.contains(ps.XC_Configuration_Item__c)) {
                if(!mapConfItemProvisioningSteps.containsKey(ps.XC_Configuration_Item__c)) {
                    mapConfItemProvisioningSteps.put(ps.XC_Configuration_Item__c, new List<XC_Provisioning_Step__c>());
                }
                mapConfItemProvisioningSteps.get(ps.XC_Configuration_Item__c).add(ps);
            } else {
                mapWorkOrderTechQuote.put(ps.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c, ps);
            }
        }

        /*Map<id,NE__OrderItem__c> mapConfigurationItems = new Map<id,NE__OrderItem__c>([
            SELECT id, 
                (SELECT id, XC_Flow_API_Name__c 
                FROM Provisioning_Steps__r 
                WHERE XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress) 
            FROM NE__OrderItem__c 
            WHERE Id IN: listConfigurationItemIds
        ]);*/
       
        for(WorkOrder wo : listWorkOrder){
            String stepStatus = '';
            if(wo.Status == Label.XC_CL_Completed){
                stepStatus = Label.XC_CL_Completed_OK;
            } else if(wo.Status == Label.XC_CL_CannotComplete || wo.Status == Label.XC_CL_Cancelled){
                stepStatus = Label.XC_CL_Step_CompletedKO;
            }     
                   
            if(!String.isBlank(stepStatus)) {
                if(mapConfItemProvisioningSteps.containsKey(wo.XC_Configuration_Item__c)) {
                    /*NE__OrderItem__c oi = mapConfigurationItems.get(wo.XC_Configuration_Item__c);
                    List<XC_Provisioning_Step__c> psList = oi.Provisioning_Steps__r;*/
                    List<XC_Provisioning_Step__c> psList = mapConfItemProvisioningSteps.get(wo.XC_Configuration_Item__c);
                    listStep.addAll(XC_TR_WorkOrder_U_FinalStatus_U.retrieveProvisioningStep(stepStatus, psList, wo));
                } else if(mapWorkOrderTechQuote.containsKey(wo.Id)) {
                    listStep.addAll(XC_TR_WorkOrder_U_FinalStatus_U.retrieveProvisioningStep(stepStatus, new List<XC_Provisioning_Step__c>{mapWorkOrderTechQuote.get(wo.Id)}, wo));
                }
            }

        }
        XC_UTIL_Sobject.updateListRecords(listStep);
    }
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @date Modification 04/03/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listWorkOrder - List<WorkOrder>
     * @param mapNew - Map<Id, WorkOrder>
     * @description Method to update the Status of an Asset when the connected Work Order is completed
     */   
     public static void updateAsset(List<WorkOrder> listWorkOrder, Map<Id, WorkOrder> mapNew){
        List<WorkOrder> listWoToManage = new List<WorkOrder>();
        List<Id> listParentWoIds = new List<Id>();
        List<String> listWorkTypeToManage = new List<String>{Label.XC_CL_WorkType_Repair, Label.XC_CL_WorkType_Delivery, Label.XC_CL_WorkType_DeliveryInstallation};
        for(WorkOrder wo: listWorkOrder) {
            if(listWorkTypeToManage.contains(wo.XC_WorkTypeCategory__c)) {
                listWoToManage.add(wo);
                if(String.isNotBlank(wo.ParentWorkOrderId)) {
                    listParentWoIds.add(wo.ParentWorkOrderId);
                }
            }
        }
        
        if(!listWoToManage.isEmpty()) {
            List<Id> woIds = XC_UTIL_Sobject.getIds(listWoToManage);
            List<Asset> assetListToUpdate = new List<Asset>();
            Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
                SELECT Id, Status, XC_statusreason__c, Asset.XC_NumberOfRepairs__c, Asset.XC_DateOfFirstRepair__c, Asset.SerialNumber, AssetId, WorkOrderNumber, ParentWorkOrderId,
                    (SELECT Id, Asset.SerialNumber, WorkOrderNumber, AssetId, Status
                    FROM ChildWorkOrders),
                    (SELECT Id,XC_SerialControlled__c,XC_Concat_AssetId__c 
                    FROM ProductsRequired)
                FROM WorkOrder 
                WHERE Id IN: woIds OR Id IN: listParentWoIds
            ]);

            List<Id> listWoIdDI = new List<Id>();
            for(WorkOrder wo : listWoToManage) {
                if(wo.Status == Label.XC_CL_Completed && String.isNotBlank(wo.AssetId)){
                    Asset assetToUpdate = new Asset();
                    Boolean assetUpdated = false;
                    assetToUpdate.Id = wo.AssetId;
                    if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair) {
                        if(mapWorkOrder.get(wo.Id).Asset.XC_DateOfFirstRepair__c == null){
                            assetToUpdate.XC_DateOfFirstRepair__c = Date.today();
                            assetUpdated = true;
                        }
                        if(mapWorkOrder.get(wo.Id).Asset.XC_NumberOfRepairs__c != null){
                            Decimal numberOfRepairs = mapWorkOrder.get(wo.Id).Asset.XC_NumberOfRepairs__c;
                            assetToUpdate.XC_NumberOfRepairs__c = numberOfRepairs + 1;
                            assetUpdated = true;
                        }    
                    } 
                    else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                        Boolean actualEndDateExists = mapNew.containsKey(wo.Id) && String.isNotBlank(String.valueOf(mapNew.get(wo.Id).XC_ActualEndDate__c));
                        assetToUpdate.InstallDate = actualEndDateExists ? Date.newInstance(mapNew.get(wo.Id).XC_ActualEndDate__c.year(), mapNew.get(wo.Id).XC_ActualEndDate__c.month(), mapNew.get(wo.Id).XC_ActualEndDate__c.day()) : Date.today();
                        assetUpdated = true;
                    }
                    if(assetUpdated) {
                        assetListToUpdate.add(assetToUpdate);
                    }
                }
                if(wo.Status == Label.XC_CL_Completed && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                    listWoIdDI.add(wo.Id);
                }
            }
            if(!listWoIdDI.isEmpty()){
                Map<Id, String> mapWoError = XC_UTIL_WorkOrder.getMapWorkOrderErrorSerialNumber(mapWorkOrder, listWoIdDI);
                for(Id woId : mapWoError.keySet()) {
                    if(mapNew.containsKey(woId)) {
                        mapNew.get(woId).addError(mapWoError.get(woId));
                    }
                }
            }
            XC_UTIL_Sobject.updateListRecords(assetListToUpdate);
        }
    }   
    /**
    * @description Method to create RMA and Good Issue for Glovia when WO is updated in Completed
    * @author Roberta Porrega - roberta.porrega@nttdata.com
    * @Modification by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 05/02/2020
    * @param listNew - List<WorkOrder>
    * @param mapOld - Map<Id,WorkOrder>
    * @param mapNew - Map<Id,WorkOrder>
    */
   public static void createForGlovia(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew) {
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        List<WorkOrder> listWORepairToCheck = new List<WorkOrder>();
        if(listChanged.isEmpty()) {
            return;
        }
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        /*List<WorkOrder> listWorkOrderReturned = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderInstalled = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderRepair = new List<WorkOrder>();*/
        for(WorkOrder wo : listChanged) {
            if(checkReturn(wo)) {
                listWorkOrderToUpdate.add(wo);  
            } else if(!calledGlovia && XC_TR_WorkOrder_U_FinalStatus_U.checkForGoodIssue(wo)) {
                listWorkOrderToUpdate.add(wo);   
            } else if(checkRepair(wo)) {
                listWORepairToCheck.add(wo);   
            } 
        }
        if(!listWORepairToCheck.isEmpty()){
            List<WorkOrder> woToProcessList = checkProductReservationSkipped(listWORepairToCheck);
            if(!woToProcessList.isEmpty()){
                listWorkOrderToUpdate.addAll(woToProcessList);
            }
        }
        updateFieldToDoGoodIssue(listWorkOrderToUpdate);
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/6/2020 
    * @param listWorkOrderToUpdate 
    * @return List<WorkOrder> 
    **/
    private static List<WorkOrder> checkProductReservationSkipped(List<WorkOrder> listWorkOrderToUpdate){
        Map<String, WorkOrder> woMap = new Map<String, WorkOrder>();
        List<WorkOrder> woListToProcess = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrderToUpdate){
            woMap.put(wo.Id, wo);
        }
        List<String> woIds = XC_UTIL_Sobject.getIds(listWorkOrderToUpdate);
        List<XC_Provisioning_Step__c> stepLists = new List<XC_Provisioning_Step__c>([SELECT Id, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c
                                                                                    FROM XC_Provisioning_Step__c 
                                                                                    WHERE XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c IN: woMap.keySet()
                                                                                    AND XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedPartner__c !=: null
                                                                                    AND XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningReservationSpareParts_Flow
                                                                                    AND XC_Status__c =: Label.XC_CL_Completed_Ok ]);
        for(XC_Provisioning_Step__c step : stepLists){
            String workorderId = step.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c;
            if(!String.isBlank(workorderId) && woMap.containsKey(workorderId)){
                woListToProcess.add(woMap.get(workorderId));
            }
        }
        return woListToProcess;
    }

    /**
    * @description Method to populate list for WO Repair
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 05/02/2020
    * @param wo - WorkOrder
    * @return Boolean
    */
    public static Boolean checkRepair(WorkOrder wo) {
        return wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && (wo.Status == Label.XC_CL_WorkOrder_Completed || wo.Status == Label.XC_CL_Cancelled || wo.Status == Label.XC_CL_CannotComplete) ; // SS 17/06/2020 before also  && !wo.XC_SentGoodIssue__c
    }

    /**
    * @description Method to populate list for WO Return
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 05/02/2020
    * @param wo - WorkOrder
    * @return Boolean
    */
    private static Boolean checkReturn(WorkOrder wo) {
        return wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Return && wo.Status == Label.XC_CL_WorkOrder_Completed ; // SS 17/06/2020 before also  && !wo.XC_SentGoodIssue__c
    }

    /**
    * @description Method to call Glovia
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 05/02/2020
    * @param listWorkOrderReturned - List<Id>
    * @param listWorkOrderInstalled - List<Id>
    * @param listWorkOrderRepair - List<Id>
    */
    private static void updateFieldToDoGoodIssue(List<WorkOrder> listWorkOrderToUpdate) {
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        if(!listWorkOrderToUpdate.isEmpty()){
            for(WorkOrder wo : listWorkOrderToUpdate){
                Workorder woToUpdate = new Workorder(Id = wo.Id, XC_ToDoGoodIssueOrRMA__c = true);
                woListToUpdate.add(woToUpdate);
            }
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woListToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
        /*if(!listWorkOrderReturned.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Call createRMA');
            XC_TR_WorkOrder_U_CreateRMA.createRMA(listWorkOrderReturned);  
        }
        if(!listWorkOrderInstalled.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Call createGoodIssueFromSalesOrder');
            calledGlovia = true;
            XC_TR_WorkOrder_U_CreateGoodIssue.createGoodIssueFromSalesOrder(listWorkOrderInstalled); 
        }  
        if(!listWorkOrderRepair.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Call createGoodIssueForRepair');
            XC_TR_WorkOrder_U_CreateGoodIssue_U.createGoodIssueForRepair(listWorkOrderRepair);
        }*/
   }
   
	   /**
	 * @author Domenico Del Prete - domenico.delprete@nttdata.com
	 * @date 30/07/2020
	 * @param listOfWo - List<WorkOrder>
	 * @description Method to update XC_DeliveryStatus__c on NE__OrderItem__c
	 */
   public static void updateDeliveryStatus(List<WorkOrder> listOfWo){
    List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
    for(WorkOrder wo : listOfWo){    
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery){
            if(String.isNotBlank(wo.XC_Configuration_Item__c)) {
                listOrderItemToUpdate.add(new NE__OrderItem__c(
                    Id = wo.XC_Configuration_Item__c,
                    XC_DeliveryStatus__c = Label.XC_CL_ConfigurationItem_Delivered
                ));
            }
        }
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.Status == Label.XC_CL_WorkOrder_Completed){
            wo.XC_InstallationDate__c = Date.today();
            if(String.isNotBlank(wo.XC_Configuration_Item__c)) {
                listOrderItemToUpdate.add(new NE__OrderItem__c(
                    Id = wo.XC_Configuration_Item__c,
                    XC_DeliveryStatus__c = Label.XC_CL_ConfigurationItem_Installed
                ));
            }
        }                 
    }
    XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
    XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
    XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdate);
    XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
    XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
   }

    /**
    * @description method to verify if the compliance check is needed before work order completion
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void checkWorkOrderCompliance(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew) {
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        checkWorkOrderCompliance(listChanged, new List<WorkOrder>());
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 24/06/2021 
    * @param listChanged 
    **/
    public static void checkWorkOrderCompliance(List<WorkOrder> listChanged, List<WorkOrder> listWorkOrderParent){
        List<WorkOrder> workOrderinFinalStatusList = new List<WorkOrder>();
        for(WorkOrder wo : listChanged){
            if(wo.Status == Label.XC_CL_WorkOrder_Completed){
                workOrderinFinalStatusList.add(wo);
            }
        }
        if(workOrderinFinalStatusList.isEmpty()){
            return;
        }
        Map<Id, Set<String>> woIdDocumentsRequiredMap = getDocumentRequired(workOrderinFinalStatusList);
        if(woIdDocumentsRequiredMap.isEmpty()){
            return;
        }
        UtilMapWrapper wrapper = getUploadedDocuments(woIdDocumentsRequiredMap);
        Map<Id, List<String>> woIdUploadedDocuments = wrapper.woIdUploadedDocuments;
        Map<Id, List<String>> woIdMissingDocumentsMap = checkMissingDocuments(woIdDocumentsRequiredMap, woIdUploadedDocuments);
        if(woIdMissingDocumentsMap.isEmpty()){
            return;
        }
        returnErrorForMissingDocument(woIdMissingDocumentsMap, workOrderinFinalStatusList, listWorkOrderParent);
    }

    /**
    * @description return the error on the workorder missing of one or more documents
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/06/2021
    * @param woIdMissingDocumentsMap 
    * @param workOrderinFinalStatusList 
    **/
    private static void returnErrorForMissingDocument(Map<Id, List<String>> woIdMissingDocumentsMap, List<WorkOrder> workOrderinFinalStatusList, List<WorkOrder> listWorkOrderParent){
        Map<String, String> documentLabelAPIMap = retrievePicklistValue();
        for(WorkOrder wo : workOrderinFinalStatusList){
            String missingDocuments = '';
            Integer i = 1;
            if(woIdMissingDocumentsMap.containsKey(wo.Id) && !woIdMissingDocumentsMap.get(wo.Id).isEmpty()){
                for(String missingDocument : woIdMissingDocumentsMap.get(wo.Id)){
                    missingDocuments += documentLabelAPIMap.get(missingDocument);
                    if(i < woIdMissingDocumentsMap.get(wo.Id).size()){
                        missingDocuments += ', ';
                    }
                    i++;
                }
            }
            if(!String.isEmpty(missingDocuments)){ 
                if(String.isEmpty(wo.ParentWorkOrderId) ){
                    wo.addError('(' + wo.WorkOrderNumber + ') ' + Label.XC_CL_WOCompliance_DocumentsNeeded + ' ' + missingDocuments);
                } else {
                    for(WorkOrder woParent : listWorkOrderParent){
                        if(woParent.Id == wo.ParentWorkOrderId){
                            woParent.addError('(' + wo.WorkOrderNumber + ') ' + Label.XC_CL_WOCompliance_DocumentsNeeded + ' ' + missingDocuments);
                        }
                    }
                }
            }
        }
    }


    /**
    * @description retrieve all Picklist Values for the field XC_Documents__c in order to retrieve the corresponding label
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/06/2021 
    * @return Map<String, String> 
    **/
    private static Map<String, String> retrievePicklistValue(){
        Map<String, String> pickListValuesMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = XC_WorkOrderCompliance__c.XC_Documents__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return pickListValuesMap;
    }

    /**
    * @description retrieve a map where the key is the workorderId and the value is the list of missing documents
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/06/2021
    * @param woIdDocumentsRequiredMap 
    * @param woIdMissingDocumentsMap 
    * @return Map<Id, List<String>> 
    **/
    private static Map<Id, List<String>> checkMissingDocuments(Map<Id, Set<String>> woIdDocumentsRequiredMap,Map<Id, List<String>> woIdUploadedDocuments ){
        Map<Id, List<String>> woIdMissingDocumentsMap = new Map<Id, List<String>>();
        for(String woId : woIdDocumentsRequiredMap.keySet()){
            List<String> uploadedDocumentList = new List<String>();
            if(woIdUploadedDocuments.containsKey(woId)){
                uploadedDocumentList = woIdUploadedDocuments.get(woId);
            }
            for(String docRequired : woIdDocumentsRequiredMap.get(woId)){
                if( uploadedDocumentList.isEmpty() || (!uploadedDocumentList.isEmpty() && !uploadedDocumentList.contains(docRequired)) ){
                    if(!woIdMissingDocumentsMap.containsKey(woId)){
                        woIdMissingDocumentsMap.put(woId, new List<String>());
                    }
                    woIdMissingDocumentsMap.get(woId).add(docRequired);
                }   
            }
        }
        return woIdMissingDocumentsMap;
    }

    /**
    * @description retrieve all the already uploaded documents
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/06/2021
    * @param woIdDocumentsRequiredMap 
    * @return Map<Id, List<String>> 
    **/
    private static UtilMapWrapper getUploadedDocuments(Map<Id, Set<String>> woIdDocumentsRequiredMap){
        UtilMapWrapper wrapper = new UtilMapWrapper();
        Set<Id> woIdList = woIdDocumentsRequiredMap.keySet();
        Map<Id, List<String>> woIdUploadedDocuments = new Map<Id, List<String>>();
        Map<Id, Map<String, Integer>> woIdUploadedDocumentTypesMap = new Map<Id, Map<String, Integer>>();
        List<XC_DocumentType__c> documentTypeList = new List<XC_DocumentType__c>([SELECT Id, Category__c, XC_WorkOrder__c, numberOfFiles__c 
                                                                                    FROM XC_DocumentType__c
                                                                                    WHERE XC_WorkOrder__c IN: woIdList]);
        for(XC_DocumentType__c docType : documentTypeList){
            if(!woIdUploadedDocuments.containsKey(docType.XC_WorkOrder__c)){
                woIdUploadedDocuments.put(docType.XC_WorkOrder__c, new List<String>());
                woIdUploadedDocumentTypesMap.put(docType.XC_WorkOrder__c, new Map<String, Integer>());
            }
            woIdUploadedDocuments.get(docType.XC_WorkOrder__c).add(docType.Category__c);
            woIdUploadedDocumentTypesMap.get(docType.XC_WorkOrder__c).put(docType.Category__c, Integer.valueOf(docType.numberOfFiles__c));
        }
        wrapper.woIdUploadedDocuments = woIdUploadedDocuments;
        wrapper.woIdUploadedDocumentTypesMap = woIdUploadedDocumentTypesMap;
        return wrapper;
    }
    /**
    * @description get the Documents required for the workorder list in input. The method has been set as public in order to verify the doc required with a simple call
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/06/2021
    * @param workOrderinFinalStatusList 
    * @param woCompliancesList 
    * @return Map<Id, List<String>> 
    **/
    public static Map<Id, Set<String>> getDocumentRequired (List<WorkOrder> workOrderinFinalStatusList){
        Set<String> legalEntitySet = new Set<String>();
        Set<String> segmentSet = new Set<String>();
        for(WorkOrder wo : workOrderinFinalStatusList){
            legalEntitySet.add(wo.XC_LegalEntity__c);
            segmentSet.add(wo.XC_Segment__c);
        }
        if(legalEntitySet.isEmpty() || segmentSet.isEmpty()){
            return new Map<Id, Set<String>>();
        }
        Map<Id, List<String>> documentRequiredMap = new  Map<Id, List<String>>();
        List<XC_WorkOrderCompliance__c> woCompliancesList = getComplianceRecords(legalEntitySet, segmentSet);
        Map<Id, Set<String>> woIdDocumentsRequiredMap = new Map<Id, Set<String>>();
        for(WorkOrder wo : workOrderinFinalStatusList){
            for(XC_WorkOrderCompliance__c woc : woCompliancesList){
                if(String.isBlank(woc.XC_Documents__c)){
                    continue;
                }
                if(checkMatch(wo, woc)){
                    if(!woIdDocumentsRequiredMap.containskey(wo.Id)){
                        woIdDocumentsRequiredMap.put(wo.Id, new Set<String>());
                    }
                    woIdDocumentsRequiredMap.get(wo.Id).addAll(woc.XC_Documents__c.split(';'));
                }
            }
        }
        return woIdDocumentsRequiredMap;
    }

    /**
    * @description check if the wo field match with the woc record
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @return Boolean 
    **/
    private static Boolean checkMatch(WorkOrder wo, XC_WorkOrderCompliance__c woc){
        if(wo.XC_LegalEntity__c != woc.XC_LegalEntity__c || wo.XC_Segment__c != woc.XC_Segment__c){
            return false;
        }
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType woSchema = schemaMap.get('WorkOrder');
        Boolean check = false;
        if(!String.isBlank(woc.XC_ConditionField1__c) && !String.isBlank(woc.XC_ConditionValue1__c)){
            check = checkMatchFieldValue(wo, woc.XC_ConditionField1__c, woc.XC_ConditionValue1__c, woc.XC_ConditionOperator1__c, woSchema);
        }
        if(check && !String.isBlank(woc.XC_ConditionField2__c) && !String.isBlank(woc.XC_ConditionValue2__c)){
            check = checkMatchFieldValue(wo, woc.XC_ConditionField2__c, woc.XC_ConditionValue2__c, woc.XC_ConditionOperator2__c, woSchema);
        }
        if(check && !String.isBlank(woc.XC_ConditionField3__c) && !String.isBlank(woc.XC_ConditionValue3__c)){
            check = checkMatchFieldValue(wo, woc.XC_ConditionField3__c, woc.XC_ConditionValue3__c, woc.XC_ConditionOperator3__c, woSchema);
        }
        if(check && !String.isBlank(woc.XC_ConditionField4__c) && !String.isBlank(woc.XC_ConditionValue4__c)){
            check = checkMatchFieldValue(wo, woc.XC_ConditionField4__c, woc.XC_ConditionValue4__c, woc.XC_ConditionOperator4__c, woSchema);
        }
        if(check && !String.isBlank(woc.XC_ConditionField5__c) && !String.isBlank(woc.XC_ConditionValue5__c)){
            check = checkMatchFieldValue(wo, woc.XC_ConditionField5__c, woc.XC_ConditionValue5__c, woc.XC_ConditionOperator5__c, woSchema);
        }
        return check;
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @param fieldToCheck 
    * @param fieldValueToCheck 
    * @param conditionOperator 
    * @return Boolean 
    **/
    private static Boolean checkMatchFieldValue(WorkOrder wo, String fieldToCheck, String fieldValueToCheck, String conditionOperator, Schema.SObjectType woSchema){
        Map<String, Schema.SObjectField> fieldMap = woSchema.getDescribe().fields.getMap();
        String fielddataType = String.valueOf(fieldMap.get(fieldToCheck).getDescribe().getType());
        String stringValue = String.valueOf(wo.get(fieldToCheck));
        
        switch on fielddataType {
            when 'STRING', 'REFERENCE', 'EMAIL', 'PHONE', 'URL', 'PICKLIST', 'ID' {		
                return compareString(stringValue, fieldValueToCheck, conditionOperator);
            } when 'BOOLEAN' {		 
                Boolean booleanValue = fieldValueToCheck.equalsIgnoreCase('TRUE');
                return wo.get(fieldToCheck) == booleanValue;
            } when 'DOUBLE', 'INTEGER', 'CURRENCY', 'PERCENT' {	
                if(String.isEmpty(stringValue)){
                    return false;
                }
                if(fieldValueToCheck.contains(',')){
                    fieldValueToCheck = fieldValueToCheck.replace(',', '.');
                }
                return compareNumber(stringValue, fieldValueToCheck, conditionOperator);
            } when else {		  
                return false;
            }
        }
    }
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @param value 
    * @param fieldValueToCheck 
    * @param conditionOperator 
    * @return Boolean 
    **/
    @TestVisible
    private static Boolean compareString(String value, String fieldValueToCheck, String conditionOperator) {
        if(conditionOperator == '=' || String.isBlank(conditionOperator)){
            return value == fieldValueToCheck;
        } else if(conditionOperator == 'contains'){
            return value.containsIgnoreCase(fieldValueToCheck); 
        } else {
            return false;
        }
    }
    
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @param value 
    * @param fieldValueToCheck 
    * @param conditionOperator 
    * @return Boolean 
    **/
    @TestVisible
    private static Boolean compareNumber(String value, String fieldValueToCheck, String conditionOperator) {
        if(conditionOperator == '=' || String.isBlank(conditionOperator)){
            return Decimal.valueof(value) == Decimal.valueof(fieldValueToCheck);
        } else if(conditionOperator == '>'){
            return Decimal.valueof(value) > Decimal.valueof(fieldValueToCheck);
        } else if(conditionOperator == '<') {
            return Decimal.valueof(value) < Decimal.valueof(fieldValueToCheck);
        } else {
            return false;
        }
    }

    /**
    * @description get Compliance Records
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/06/2021 
    * @param legalEntitySet 
    * @param segmentSet 
    * @return List<XC_WorkOrderCompliance__c> 
    **/
    private static List<XC_WorkOrderCompliance__c> getComplianceRecords(Set<String> legalEntitySet, Set<String> segmentSet) {
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_WorkOrderCompliance__c');
        query += ' FROM XC_WorkOrderCompliance__c ';
        query += ' WHERE XC_LegalEntity__c IN:legalEntitySet AND XC_Segment__c IN: segmentSet';
        List<XC_WorkOrderCompliance__c> woCompliancesList = Database.query(String.escapeSingleQuotes(query));
        return woCompliancesList;
    }

    /**
    * @description method to be called by rest class in order th return the document required/added to a list of workorder
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 11/06/2021
    * @param workOrderIdList 
    * @return Map<Id, Map<String, Integer>> 
    **/
    public static Map<Id, Map<String, Integer>> getWOComplianceDocuments(List<Id> workOrderIdList){
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('WorkOrder');
        query += ' FROM WorkOrder ';
        query += ' WHERE ParentWorkOrderId IN: workOrderIdList OR Id IN: workOrderIdList ';
        List<Workorder> woQueriedList = Database.query(query);
        Map<Id, Set<String>> woIdDocumentsRequiredMap = getDocumentRequired(woQueriedList);
        if(woIdDocumentsRequiredMap.isEmpty()){
            return new Map<Id, Map<String, Integer>>();
        }
        Map<String, String> documentLabelAPIMap = retrievePicklistValue();
        UtilMapWrapper wrapper = getUploadedDocuments(woIdDocumentsRequiredMap);
        Map<Id, List<String>> woIdUploadedDocuments = wrapper.woIdUploadedDocuments;
        Map<Id, Map<String, Integer>> woIdUploadedDocumentTypesMap = wrapper.woIdUploadedDocumentTypesMap;
        Map<Id, Map<String, Integer>>  woIdDocumentsMap = new Map<Id, Map<String, Integer>>();
        for(WorkOrder wo : woQueriedList){
            if(!woIdDocumentsRequiredMap.containsKey(wo.Id)){
                continue;
            }
            String woId = wo.Id;
            String woIdForMap = String.isEmpty(wo.ParentWorkOrderId) ? wo.Id : wo.ParentWorkOrderId;
            List<String> uploadedDocumentList = new List<String>();
            if(woIdUploadedDocuments.containsKey(woId)){
                uploadedDocumentList = woIdUploadedDocuments.get(woId);
            }
            for(String docRequired : woIdDocumentsRequiredMap.get(woId)){
                if( !uploadedDocumentList.isEmpty() && uploadedDocumentList.contains(docRequired)) {
                    if(!woIdDocumentsMap.containsKey(woIdForMap)){
                        woIdDocumentsMap.put(woIdForMap, new Map<String, Integer>());
                    }
                    woIdDocumentsMap.get(woIdForMap).put(documentLabelAPIMap.get(docRequired), woIdUploadedDocumentTypesMap.get(woIdForMap).get(docRequired));
                } else {
                    if(!woIdDocumentsMap.containsKey(woIdForMap)){
                        woIdDocumentsMap.put(woIdForMap, new Map<String, Integer>());
                    }
                    woIdDocumentsMap.get(woIdForMap).put(documentLabelAPIMap.get(docRequired), 0);
                }
            }
        }
        return woIdDocumentsMap;
    }
}