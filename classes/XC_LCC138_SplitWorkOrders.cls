/**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 24/07/2019
 * @date Modification 31/07/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCC138_SplitWorkOrders - Controller class of the component XC_LCP138_SplitWorkOrders
 */

public without sharing class XC_LCC138_SplitWorkOrders {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC138_SplitWorkOrders');

    /** @description PopulateWoWrapper */
    private class PopulateWoWrapper {
        Map<String, List<WorkOrder> > splittedWoMap = new Map<String, List<WorkOrder> >();
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        Map<Id, WorkOrder> workOrdersMap = new Map<Id, WorkOrder>();
        String recordId = '';
        Map<String, WorkOrder> mapTechSkillWoNew = new Map<String, WorkOrder>();
        List<WorkOrder> woListToInsert = new List<WorkOrder>();
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param recordId
    * @description check if it is possible to split the Work Orders
    * @return Boolean
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkSplittingPossibility(String recordId) {
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        Map<Id, WorkOrder> workOrdersMap = retrieveChildWo(recordId);
        WorkOrder wo = workOrdersMap.get(recordId);
        if(wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Repair && wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_DeliveryInstallation) {
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_SplitOnlyRepairWO;
            return resWrapper;
        }
        List<WorkOrder> woChilds = workOrdersMap.get(recordId).ChildWorkOrders;
        List<WorkOrder> woList = new List<WorkOrder>();
        if(!woChilds.isEmpty()) {
            for(WorkOrder woCh : woChilds) {
                if(!checkForTypeChildren(wo, woCh)) {
                    resWrapper.success = false;
                    resWrapper.resultMessage = Label.XC_CL_CheckChildrenRepair;
                    return resWrapper;
                }
            }
        }
        else{
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_AtLeastOneWoChildren;
            return resWrapper;
        }
        resWrapper.success = true;
        return resWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Check for type Children
    * @param wo - WorkOrder
    * @param woCh - WorkOrder
    * @return Boolean
    */
    private static Boolean checkForTypeChildren(WorkOrder wo, WorkOrder woCh) {
        return ((wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && woCh.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair) ||
                (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && woCh.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation));
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param recordId
    * @description retrieve Work Order and his Childs
    * @return Map<Id, WorkOrder>
    */
    private static Map<Id, WorkOrder> retrieveChildWo(String recordId){
        Map<Id, WorkOrder> workOrdersMap = new Map<Id, WorkOrder>([
                                        SELECT Id, Street, PostalCode, City, Country, XC_Address__c, XC_NumberWorkOrdersDI__c, XC_Configuration__c, XC_WorkTypeLabel__c, XC_WorkTypeCategory__c, Asset.NE__Bundle_Configuration__c, CaseId, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_Address__c,
                                        XC_Address__r.XC_City__c, XC_Address__r.XC_AddressCountry__c, XC_HierarchyLevel__c, XC_isTree__c, Duration,XC_TechnicalSkill__c, XC_Urgent_Repair__c, XC_Commitment__c,
                                        (SELECT Id, Street, PostalCode, City, XC_Address__c, XC_NumberWorkOrdersDI__c, Country, XC_Configuration__c, XC_WorkTypeLabel__c, XC_WorkTypeCategory__c, Asset.NE__Bundle_Configuration__c, CaseId, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_Address__c,
                                        XC_Address__r.XC_City__c, XC_Address__r.XC_AddressCountry__c, XC_HierarchyLevel__c, XC_isTree__c, Duration, XC_TechnicalSkill__c
                                        FROM ChildWorkOrders)
                                        FROM WorkOrder
                                        WHERE Id =: recordId]);
        return workOrdersMap;
    }


    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param recordId
    * @description check if it is possible to split the Work Orders
    * @return XC_UTIL_Sobject.WrapperResult
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkHierarchyLevelAndSplit(String recordId){
        Savepoint sp = Database.setSavepoint();
        XC_UTIL_ResultWrapper resWrap = new XC_UTIL_ResultWrapper();
        Map<Id, WorkOrder> workOrdersMap = retrieveChildWo(recordId);
        WorkOrder wo = workOrdersMap.get(recordId);

        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair) {
            if(wo.XC_HierarchyLevel__c == 0) {
                resWrap = splitWorkOrders(recordId);
            } else if(wo.XC_HierarchyLevel__c == 1) {
                resWrap = reparentChildrenOnCase(workOrdersMap, recordId);
            }
        } else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
            String orderId = wo.XC_Configuration__c;
            if(wo.XC_HierarchyLevel__c == 0) {
                resWrap = XC_UTIL_WorkOrderSplit.getBundleMapInsertMiddleWorkOrder(resWrap, wo, workOrdersMap);
            } 
            if(wo.XC_HierarchyLevel__c == 1) {
                resWrap = splitSingleWO(wo);
            }
            resWrap.recordId = orderId;
        }

        XC_UTIL_WorkOrderSplit.doRollBack(sp, resWrap.success);
        return resWrap;
    }

    /**
    * @description splitSingleWO
    * @author Valeria Martino | 1/8/2019
    * @param middleWorkOrder WorkOrder 
    * @return XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper splitSingleWO(WorkOrder middleWorkOrder)  {
        List<WorkOrder> listChildWorkOrder = new List<WorkOrder>();
        listChildWorkOrder.addAll(middleWorkOrder.ChildWorkOrders); 
        List<WorkOrder> childWorkOrderToUpdate = new List<WorkOrder>();
        for(WorkOrder workOrderChild :listChildWorkOrder) {
            WorkOrder woChild = new WorkOrder(
                Id = workOrderChild.Id,
                XC_Configuration__c = middleWorkOrder.XC_Configuration__c
            );
            childWorkOrderToUpdate.add(woChild);
        }

        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<XC_UTIL_sObject.WrapperResult> dmlUpdateWorkOrderResult = XC_UTIL_sObject.updateListRecords(childWorkOrderToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(dmlUpdateWorkOrderResult)) {
            resWrapper.resultMessage = dmlUpdateWorkOrderResult[0].errorMessage;
            return resWrapper;
        }

        XC_UTIL_sObject.WrapperResult dmlDeleteWorkOrderResult = XC_UTIL_Sobject.deleteRecord(middleWorkOrder);
        if(!dmlDeleteWorkOrderResult.success) {
            resWrapper.resultMessage = dmlDeleteWorkOrderResult.errorMessage;
            return resWrapper;
        }

        resWrapper.success = true;
        return resWrapper;
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param recordId
    * @description check if it is possible to split the Work Orders
    * @return XC_UTIL_Sobject.WrapperResult
    */
    private static XC_UTIL_ResultWrapper splitWorkOrders(String recordId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        Map<Id, WorkOrder> workOrdersMap = retrieveChildWo(recordId);
        resWrapper.recordId = workOrdersMap.get(recordId).CaseId;
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        List<WorkOrder> woChilds = workOrdersMap.get(recordId).ChildWorkOrders;
        Map<String, List<WorkOrder> > splittedWoMap = XC_UTIL_WorkOrderSplit.splitWorkOrdersByTechSkill(woChilds);
        PopulateWoWrapper populateWrapper = new PopulateWoWrapper();
        populateWrapper.splittedWoMap = splittedWoMap;
        populateWrapper.resWrapper = resWrapper;
        populateWrapper.workOrdersMap = workOrdersMap;
        populateWrapper.recordId = recordId;
        populateWO(populateWrapper);
        resWrapper = populateWrapper.resWrapper;
        List<WorkOrder>  woListToInsert = populateWrapper.woListToInsert;
        Map<String, WorkOrder> mapTechSkillWoNew = populateWrapper.mapTechSkillWoNew;
        List<XC_UTIL_Sobject.WrapperResult> wrpWoInsertList = XC_UTIL_Sobject.insertListRecords(woListToInsert);
        XC_UTIL_Sobject.WrapperResult wrpWoInsert = XC_UTIL_Query.getGlobalDMLResults(wrpWoInsertList);
        if(!wrpWoInsert.success) {
            resWrapper.success = false;
            resWrapper.resultMessage = wrpWoInsert.errorMessage;
            return resWrapper;
        }
        else{
            resWrapper.success = true;
        }
        for(String techSkill : splittedWoMap.keySet()) {
            for(WorkOrder woCh : splittedWoMap.get(techSkill)) {
                woCh.ParentWorkOrderId = mapTechSkillWoNew.get(techSkill).Id;
                woListToUpdate.add(woCh);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrpListChild = XC_UTIL_Sobject.updateListRecords(woListToUpdate);
        XC_UTIL_Sobject.WrapperResult wrpChild = XC_UTIL_Query.getGlobalDMLResults(wrpListChild);
        if(!wrpChild.success) {
            resWrapper.success = false;
            resWrapper.resultMessage = wrpChild.errorMessage;
            return resWrapper;
        }
        else{
            resWrapper.success = true;
        }
        XC_UTIL_Skill.insertSkillOnParentFromChildren(woListToInsert);
        insertRequiredResPreference(woListToInsert);
        WorkOrder wo = new WorkOrder(Id = recordId);
        XC_UTIL_Sobject.WrapperResult resWrapParent = XC_UTIL_Sobject.deleteRecord(wo);
        if(!resWrapParent.success) {
            resWrapper.success = false;
            resWrapper.resultMessage = resWrapParent.errorMessage;
            return resWrapper;
        }
        else{
            resWrapper.success = true;
        }
        return resWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @param wr - PopulateWoWrapper
    * @description Method to populate WO
    */
    private static void populateWO(PopulateWoWrapper wr) {
        for(String techSkill : wr.splittedWoMap.keySet()) {
            if(String.isEmpty(techSkill)) {
                wr.resWrapper.success = false;
                wr.resWrapper.resultMessage = Label.XC_CL_WoWithoutTechSkill;
            } else {
                WorkOrder wo = new WorkOrder();
                wo.XC_WorkTypeLabel__c = wr.workOrdersMap.get(wr.recordId).XC_WorkTypeLabel__c;
                wo.XC_WorkTypeCategory__c = wr.workOrdersMap.get(wr.recordId).XC_WorkTypeCategory__c;
                wo.CaseId = wr.workOrdersMap.get(wr.recordId).CaseId;
                wo.Street = wr.workOrdersMap.get(wr.recordId).XC_Address__r.XC_Address__c;
                wo.PostalCode = wr.workOrdersMap.get(wr.recordId).XC_Address__r.XC_PostalCode__c;
                wo.City = wr.workOrdersMap.get(wr.recordId).XC_Address__r.XC_City__c;
                wo.Country = wr.workOrdersMap.get(wr.recordId).XC_Address__r.XC_AddressCountry__c;
                wo.XC_Address__c = wr.workOrdersMap.get(wr.recordId).XC_Address__c;
                wo.XC_HierarchyLevel__c = 1;
                wo.XC_Urgent_Repair__c = wr.workOrdersMap.get(wr.recordId).XC_Urgent_Repair__c;
                wo.XC_Commitment__c = wr.workOrdersMap.get(wr.recordId).XC_Commitment__c;
                wo.XC_isTree__c = true;
                wo.Duration = populateWorkOrderDuration(wr.splittedWoMap.get(techSkill));
                wo.XC_CreatedAutomaticallyBySystem__c = true;
                wr.woListToInsert.add(wo);
                wr.mapTechSkillWoNew.put(techSkill, wo);
            }
        }
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param workOrdersMap
    * @param recordId
    * @description check if it is possible to split the Work Orders
    * @return XC_UTIL_Sobject.WrapperResult
    */
    private static XC_UTIL_ResultWrapper reparentChildrenOnCase(Map<Id, WorkOrder> workOrdersMap, String recordId){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        resWrapper.recordId = workOrdersMap.get(recordId).CaseId;
        List<WorkOrder> allChildrenWo = new List<WorkOrder>();
        allChildrenWo.addAll(workOrdersMap.get(recordId).ChildWorkOrders);
        WorkOrder wo = new WorkOrder(Id = recordId);
        List<WorkOrder> woListChildrenToUpdate = new List<WorkOrder>();
        for(WorkOrder woCh : allChildrenWo) {
            woCh.CaseId = workOrdersMap.get(recordId).CaseId;
            woListChildrenToUpdate.add(woCh);
        }
        List<XC_UTIL_Sobject.WrapperResult> reWrapChildren = XC_UTIL_Sobject.updateListRecords(woListChildrenToUpdate);
        XC_UTIL_Sobject.WrapperResult wrpChild = XC_UTIL_Query.getGlobalDMLResults(reWrapChildren);
        if(!wrpChild.success) {
            resWrapper.success = false;
            resWrapper.resultMessage = wrpChild.errorMessage;
            return resWrapper;
        }
        XC_UTIL_Sobject.WrapperResult resWrapParent = XC_UTIL_Sobject.deleteRecord(wo);
        resWrapper.success = resWrapParent.success;
        resWrapper.resultMessage = resWrapParent.errorMessage;
        return resWrapper;
    }


    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param childrenWO
    * @description Populate Duration for Work Order
    * @return Decimal
    */
    private static Decimal populateWorkOrderDuration(List<WorkOrder> childrenWO){
        Decimal duration;
        for(WorkOrder wo : childrenWO) {
            if(duration == null) {
                duration = wo.Duration;
            } else if(wo.Duration != null) {
                duration += wo.Duration;
            }
        }
        return duration;
    }


    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param listWoIntermediate
    * @description Insert Required Resource Preference
    */
    private static void insertRequiredResPreference(List<WorkOrder> listWoIntermediate){
        Map<Id, Set<Id> > rpToInsert = XC_UTIL_ResourcePreference_U.getResPrefFromChildren(listWoIntermediate);
        List<WorkOrder> woWithoutChildren = new List<WorkOrder>();
        List<WorkOrder> woWithChildren = new List<WorkOrder>();
        for (WorkOrder wo : listWoIntermediate) {
            Set<Id> rpIds = rpToInsert.get(wo.Id);
            if (rpIds.isEmpty()) {
                woWithoutChildren.add(wo);
            }else {
                woWithChildren.add(wo);
            }
        }
        XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(woWithChildren, rpToInsert);
        XC_TR_WorkOrder_U_RequiredResMgmt.manageRequiredResourcesOnInsert(woWithoutChildren);
    }
}