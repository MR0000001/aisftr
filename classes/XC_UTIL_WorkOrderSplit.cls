/**
* @author Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation 24/07/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_WorkOrderSplit - Util class for Work Order splitting
*/

public without sharing class XC_UTIL_WorkOrderSplit {

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param woListToSplit
    * @description split the Work Order based on the Technical Skill
    * @return Map<String, List<WorkOrder>>
    */
    public static Map<String, List<WorkOrder>> splitWorkOrdersByTechSkill(List<WorkOrder> woListToSplit){
        Map<String, List<WorkOrder>> splittedMap = new Map<String, List<WorkOrder>>();
        for(WorkOrder wo : woListToSplit){
            if(!splittedMap.containskey(wo.XC_TechnicalSkill__c)) {
                splittedMap.put(wo.XC_TechnicalSkill__c, new List<WorkOrder> ());
            }
            splittedMap.get(wo.XC_TechnicalSkill__c).add(wo);
        }  
        return splittedMap;
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @param skillListToSplit
    * @description split the Work Order based on the Technical Skill
    * @return Map<String, List<SkillRequirement>>
    */
    public static Map<String, List<SkillRequirement>> splitWorkOrdersByTechSkill(List<SkillRequirement> skillListToSplit){
        List<String> relatedRecordIds = XC_UTIL_Sobject.getListFieldValues(skillListToSplit, 'RelatedRecordId');
        Map<Id, WorkOrder> workOrdersMap = new Map<Id, WorkOrder>(
                                           [SELECT Id, XC_TechnicalSkill__c,
                                                (SELECT Id, SkillLevel, SkillId, RelatedRecordId
                                                 FROM SkillRequirements)
                                            FROM WorkOrder
                                            WHERE Id IN: relatedRecordIds]);
        Map<String, List<SkillRequirement>> splittedMap = new Map<String, List<SkillRequirement>>();
        for(WorkOrder wo : workOrdersMap.values()){
            if(!splittedMap.containskey(wo.XC_TechnicalSkill__c)) {
                splittedMap.put(wo.XC_TechnicalSkill__c, new List<SkillRequirement> ());
            }
            splittedMap.get(wo.XC_TechnicalSkill__c).addAll(wo.SkillRequirements);
        }  
        return splittedMap;
    }

    /**
    * @description getBundleMapInsertMiddleWorkOrder
    * @author Andrea Bravaccino | 1/8/2019
    * @param resWrap XC_UTIL_ResultWrapper 
    * @param wo WorkOrder 
    * @param workOrdersMap Map<Id, WorkOrder> 
    * @return XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper getBundleMapInsertMiddleWorkOrder(XC_UTIL_ResultWrapper resWrap, WorkOrder wo, Map<Id, WorkOrder> workOrdersMap){
        Map<Id, List<WorkOrder> > splittedMap = XC_UTIL_WorkOrderSplit.splitWorkOrdersByBundle(workOrdersMap.values());
        if (splittedMap.keySet().size() <2) {
            resWrap.success = true;
            resWrap.resultMessage = Label.XC_CL_Thereisonlyonebundle + '; ';
            wo.XC_HierarchyLevel__c = 1;
            wo.XC_isTree__c = true;
        }else {
            resWrap = XC_UTIL_WorkOrderSplit.insertMiddleWorkOrder(splittedMap, wo);
        }
        return resWrap;
    }

    /**
    * @author Andrea Bravaccino
    * @param woListToSplit
    * @description split the Work Order aggregated by asset's bundle
    * @return Map<Id, List<WorkOrder>> bundle id / workOrders with bundle
    */
    public static Map<Id, List<WorkOrder> > splitWorkOrdersByBundle(List<WorkOrder> woListToSplit){
        Map<Id, List<WorkOrder> > splittedMap = new Map<Id, List<WorkOrder> >();
        for(WorkOrder woParent : woListToSplit) {
            for (WorkOrder wo : woParent.ChildWorkOrders) {
                if(!splittedMap.containskey(wo.Asset.NE__Bundle_Configuration__c)) {
                    splittedMap.put(wo.Asset.NE__Bundle_Configuration__c, new List<WorkOrder> ());
                }
                splittedMap.get(wo.Asset.NE__Bundle_Configuration__c).add(wo);
            }
            
        }
        return splittedMap;
    }

    
    /**
    * @description insertMiddleWorkOrder
    * @author Andrea Bravaccino | 1/8/2019
    * @param splittedMap Map<Id, List<WorkOrder>> 
    * @param woRoot WorkOrder 
    * @return XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper insertMiddleWorkOrder(Map<Id, List<WorkOrder> > splittedMap, WorkOrder woRoot){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<WorkOrder> middleWoToInsert = getMiddleWoToInsert(splittedMap, woRoot);

        resWrapper.success = true;
        List<XC_UTIL_Sobject.WrapperResult> insertList = XC_UTIL_Sobject.insertListRecords(middleWoToInsert);
        if (!XC_UTIL_Sobject.checkDMLResults(insertList)) {
            return populateWrapperWithError(resWrapper, insertList.get(0).errorMessage);
        }

        resWrapper = updateMiddleWoInserted(resWrapper, splittedMap, middleWoToInsert);
        if (!resWrapper.success) {
            return resWrapper;
        }

        XC_UTIL_Sobject.WrapperResult deleteRoot = XC_UTIL_Sobject.deleteRecord(woRoot);
        if (!deleteRoot.success) {
            return populateWrapperWithError(resWrapper, deleteRoot.errorMessage);
        }
        resWrapper.success = true;
        resWrapper.typeMessage = 'success';
        return resWrapper;
    }

    private static XC_UTIL_ResultWrapper updateMiddleWoInserted(XC_UTIL_ResultWrapper resWrapper, Map<Id, List<WorkOrder> > splittedMap, List<WorkOrder> middleWoToInsert){
        Map<Id, Id> bundleMiddleWo = new Map<Id, Id>();
        Integer index = 0;
        for (Id bundleId : splittedMap.keySet()) {
            bundleMiddleWo.put(bundleId, middleWoToInsert.get(index).Id);
            index++;
        }

        List<WorkOrder> leafsToUpdate = getLeafsToUpdate(bundleMiddleWo, splittedMap);
        List<XC_UTIL_Sobject.WrapperResult> updateList = XC_UTIL_Sobject.updateListRecords(leafsToUpdate);
        if (!XC_UTIL_Sobject.checkDMLResults(updateList)) {
            return populateWrapperWithError(resWrapper, updateList.get(0).errorMessage);
        }

        XC_UTIL_Sobject.WrapperResult insertedResult = XC_UTIL_Skill.insertSkillOnParentFromChildren(middleWoToInsert);
        if(!insertedResult.success){
            return populateWrapperWithError(resWrapper, insertedResult.errorMessage);
        }
        Map<Id, Set<Id> > rpToInsert = XC_UTIL_ResourcePreference_U.getResPrefFromChildren(middleWoToInsert);
        List<WorkOrder> woWithoutChildren = new List<WorkOrder>();
        List<WorkOrder> woWithChildren = new List<WorkOrder>();
        for (WorkOrder wo : middleWoToInsert) {
            Set<Id> rpIds = rpToInsert.get(wo.Id);
            if (rpIds.isEmpty()) {
                woWithoutChildren.add(wo);
            }else {
                woWithChildren.add(wo);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> insertRpList = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(woWithChildren, rpToInsert);
        if (!XC_UTIL_Sobject.checkDMLResults(insertRpList)) {
            return populateWrapperWithError(resWrapper, insertRpList.get(0).errorMessage);
        }
        XC_TR_WorkOrder_U_RequiredResMgmt.manageRequiredResourcesOnInsert(woWithoutChildren);
        resWrapper.success = true;
        resWrapper.typeMessage = 'success';
        return resWrapper;
    }

    private static XC_UTIL_ResultWrapper populateWrapperWithError(XC_UTIL_ResultWrapper resWrapper, String resultMessage){
        resWrapper.success = false;
        resWrapper.resultMessage = resWrapper.resultMessage + resultMessage;
        resWrapper.typeMessage = 'error';
        return resWrapper;
    }

    private static List<WorkOrder> getLeafsToUpdate(Map<Id, Id> bundleMiddleWo, Map<Id, List<WorkOrder> > splittedMap){
        List<WorkOrder> leafsToUpdate = new List<WorkOrder>();
        for (Id bundleId : bundleMiddleWo.keySet()) {
            Id parentWoId = bundleMiddleWo.get(bundleId);
            for (WorkOrder leaf : splittedMap.get(bundleId)) {
                leaf.ParentWorkOrderId = parentWoId;
                leafsToUpdate.add(leaf);
            }
        }
        return leafsToUpdate;
    }

    private static List<WorkOrder> getMiddleWoToInsert(Map<Id, List<WorkOrder> > splittedMap, WorkOrder woRoot){
        List<WorkOrder> middleWoToInsert = new List<WorkOrder>();
        for (Id bundleId : splittedMap.keySet()) {
            WorkOrder woMiddle = new WorkOrder(
                XC_Configuration__c = woRoot.XC_Configuration__c,
                XC_WorkTypeLabel__c = woRoot.XC_WorkTypeLabel__c,
                XC_WorkTypeCategory__c = woRoot.XC_WorkTypeCategory__c,
                XC_HierarchyLevel__c = woRoot.XC_HierarchyLevel__c + 1,
                XC_isTree__c = true,
                Street = woRoot.Street,
                PostalCode = woRoot.PostalCode,
                City = woRoot.City,
                Country = woRoot.Country,
                XC_Address__c = woRoot.XC_Address__c,
                XC_NumberWorkOrdersDI__c = woRoot.XC_NumberWorkOrdersDI__c
            );
            middleWoToInsert.add(woMiddle);
        }
        return middleWoToInsert;
    }

    /**
    * @description doRollBack
    * @author Andrea Bravaccino | 1/8/2019
    * @param sp Savepoint 
    * @param success Boolean 
    */
    public static void doRollBack(Savepoint sp, Boolean success){
        if(!success){
            Database.rollback(sp);
        }
    }

}