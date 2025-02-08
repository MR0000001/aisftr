/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/07/2019
* @description XC_TR_WorkOrder_U_ManageBooking – Util class for WorkOrder Trigger
*/ 

public without sharing class XC_TR_WorkOrder_U_ManageBooking {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_Handler');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/07/2019
     * @description Method to check if WO can be booked
     * @param listNew - List<WorkOrder>
     */
    public static void manageForBooking(List<WorkOrder> listNew){ 
        List<WorkOrder> listWorkOrderWithParent = new List<WorkOrder>();
        for(WorkOrder wo : listNew) {
            if(wo.XC_WorkTypeCategory__c != 'Quality Check Inspection') {
                listWorkOrderWithParent.add(wo);
            }
        }
        if(listWorkOrderWithParent.isEmpty()) {
            return;
        }
        List<String> listIdRootWorkOrder = XC_UTIL_SObject.getListFieldValues(listWorkOrderWithParent, 'ParentWorkOrderId');
        if(listIdRootWorkOrder.isEmpty()){
            return;
        }

        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, XC_NumberWorkOrdersDI__c,XC_Segment__c , XC_HierarchyLevel__c, PostalCode, XC_WorkTypeCategory__c, XC_Configuration__c, XC_isTree__c, AssetId, XC_PositionInMaintenancePlan__c, Duration,
            (SELECT Id, XC_RequiredPartnerId__c,XC_Segment__c , XC_WorkTypeCategory__c, WorkTypeId, XC_WorkTypeLabel__c, Duration FROM ChildWorkOrders) 
            FROM WorkOrder
            WHERE Id IN :listIdRootWorkOrder]);
        
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            Integer numberOfChildren = wo.ChildWorkOrders.size();
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                return;
            }
            if(numberOfChildren == wo.XC_NumberWorkOrdersDI__c) {
                wo.XC_RequiredPartnerId__c = wo.ChildWorkOrders.isEmpty() ? '' : wo.ChildWorkOrders[0].XC_RequiredPartnerId__c;
                wo.XC_ReadyToBeBooked__c = true;
                // Check to change Work Type informations for Parent Work Order for D&I:
                if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.XC_Segment__c == 'B2C') {
                    List<String> listWorkTypeExcluded = new List<String>{Label.XC_CL_WorkType_DeliveryInstallation, 'Delivery & Installation - Gas'};
                    Boolean changeWorkType = true;
                    String firstWorkTypeId = '';
                    for(WorkOrder woChild : wo.ChildWorkOrders) {
                        if(!listWorkTypeExcluded.contains(woChild.XC_WorkTypeLabel__c)) {
                            firstWorkTypeId = wo.ChildWorkOrders[0].WorkTypeId;
                            break;
                        }
                    }
                    for(WorkOrder woChild : wo.ChildWorkOrders) {
                        if(woChild.WorkTypeId != firstWorkTypeId && !listWorkTypeExcluded.contains(woChild.XC_WorkTypeLabel__c)) {
                            changeWorkType = false;
                            break;
                        }
                    }
                    if(changeWorkType) {
                        wo.WorkTypeId = wo.ChildWorkOrders[0].WorkTypeId;
                        wo.XC_WorkTypeLabel__c = wo.ChildWorkOrders[0].XC_WorkTypeLabel__c;
                    }
                    //
                    Decimal totalDuration = 0;
                    for(WorkOrder woChild : wo.ChildWorkOrders) {
                        if(woChild.Duration != null){
                            totalDuration += woChild.Duration;
                        } 
                    }
                    if(totalDuration != 0){
                        wo.Duration = totalDuration;
                    }
                    //
                }
                listWorkOrderToUpdate.add(wo);
            }
        }
        
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(res)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error in After Insert for WorkOrder (manageForBooking)');
        } else if(!listWorkOrderToUpdate.isEmpty()) {
            verifyBookingNotificationStep(listWorkOrderToUpdate); // STAB NEW_60 - SS - 27/08/2021
            manageWOBooked(listWorkOrderToUpdate);
        }      
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/07/2019
     * @description Method to manage WO booked
     * @param listWorkOrder - List<WorkOrder>
     */
    public static void manageWOBooked(List<WorkOrder> listWorkOrder) {
        List<XC_UTIL_Sobject.WrapperResult> wrList = new List<XC_UTIL_Sobject.WrapperResult>();
        wrList = insertProductReqFromChildren(listWorkOrder);
        XC_UTIL_Sobject.WrapperResult resWrapperSkill = XC_UTIL_Skill.insertSkillOnParentFromChildren(listWorkOrder);
        Map<Id, Set<Id>> resourcePreferenceToInsert = XC_UTIL_ResourcePreference_U.getResPrefFromChildren(listWorkOrder);
        List<WorkOrder> woWithResourcePreferencesOnChildren = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            Set<Id> rpIds = resourcePreferenceToInsert.get(wo.Id);
            if (!rpIds.isEmpty()){
                woWithResourcePreferencesOnChildren.add(wo);
            }
        }
        wrList = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(woWithResourcePreferencesOnChildren, resourcePreferenceToInsert);
        //XC_UTIL_WorkOrder.populateDurationFromChildren(new Map<Id, WorkOrder>(listWorkOrder));
    }
    
    /**
    * @description insertProductReqFromChildren
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 16/9/2019 
    * @param woParentList 
    * @return List<XC_UTIL_Sobject.WrapperResult> 
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> insertProductReqFromChildren(List<WorkOrder> woParentList){
        List<Id> parentIds = XC_UTIL_Sobject.getIds(woParentList);
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, ParentWorkOrderId, 
                (SELECT Id, ParentRecordId, XC_Concat_AssetId__c, ProductRequiredNumber,XC_OwnedByEnelX__c, XC_Asset__c,XC_SerialControlled__c, XC_Mode__c,XC_ProcurementType__c, Product2Id,  Product2.Name, QuantityRequired, XC_ConcatenatedCostCenter__c, XC_ConcatenatedWBE__c 
                FROM ProductsRequired) 
            FROM WorkOrder 
            WHERE ParentWorkOrderId IN :parentIds OR Id IN :parentIds
        ]);
        Map<Id, Map<Id, ProductRequired>> woParentProductReqChildren = new Map<Id, Map<Id, ProductRequired>>();
        for (WorkOrder wo : woList) {
            Boolean isParent = parentIds.contains(wo.Id);
            Id keyId = isParent ? wo.Id : wo.ParentWorkOrderId;
            Map<Id, ProductRequired> productRequiredMap = woParentProductReqChildren.get(keyId);
            if (productRequiredMap == null){
                productRequiredMap = new Map<Id, ProductRequired>();
            }
            for (ProductRequired pr : wo.ProductsRequired) {
                ProductRequired product = productRequiredMap.get(pr.Product2Id);
                if(product == null){
                    product = new ProductRequired();
                    product.QuantityRequired = 0;
                }
                if (isParent){
                    product = pr.clone();
                    product.Id = pr.Id;
                    product.QuantityRequired = 0;
                    product.XC_Concat_AssetId__c = '';
                }

                product.XC_OwnedByEnelX__c = pr.XC_OwnedByEnelX__c;
                //product.XC_Asset__c = pr.XC_Asset__c;
                product.XC_Mode__c = pr.XC_Mode__c;
                product.XC_SerialControlled__c = pr.XC_SerialControlled__c;
                product.XC_ProcurementType__c = pr.XC_ProcurementType__c;
                product.Product2Id = pr.Product2Id;
                product.QuantityRequired = !isParent ? product.QuantityRequired + pr.QuantityRequired : product.QuantityRequired;
                product.XC_Concat_AssetId__c = !isParent ? getConcatAsset(product.XC_Concat_AssetId__c, pr.XC_Concat_AssetId__c) : product.XC_Concat_AssetId__c;
                product.XC_Concat_AssetId__c = product.XC_Concat_AssetId__c.replace(';;', ';');
                product.XC_ConcatenatedWBE__c = !isParent ? getConcatAsset(product.XC_ConcatenatedWBE__c, pr.XC_ConcatenatedWBE__c) : product.XC_ConcatenatedWBE__c;
                product.XC_ConcatenatedCostCenter__C = !isParent ? getConcatAsset(product.XC_ConcatenatedCostCenter__C, pr.XC_ConcatenatedCostCenter__C) : product.XC_ConcatenatedCostCenter__C;                
                productRequiredMap.put(pr.Product2Id, product);
            }
            woParentProductReqChildren.put(keyId, productRequiredMap);
        }
        return insertProductReqFromChildren(woParentProductReqChildren);    
    }

    /**
    * @description Method to get contact Asset by String
    * @param oldConcatAsset - String 
    * @param newConcatAsset - String
    * @return String
    **/
    @TestVisible
    private static String getConcatAsset(String oldConcatAsset, String newConcatAsset){
        Set<String> concatAsset;
        if(!String.isBlank(oldConcatAsset)){
            concatAsset = new Set<String>(oldConcatAsset.split(';'));
        }else {
            if(!String.isBlank(newConcatAsset)) {
                return newConcatAsset;
            }
            return '';
        }

        concatAsset.add(';'+newConcatAsset);
        return String.join(new List<String>(concatAsset), ';');
    }

    /**
    * @description insertProductReqFromChildren
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 16/9/2019 
    * @param woParentProductReqChildren 
    * @return List<XC_UTIL_Sobject.WrapperResult> 
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> insertProductReqFromChildren(Map<Id, Map<Id, ProductRequired>> woParentProductReqChildren){
        List<ProductRequired> prListToInsert = new List<ProductRequired>();
        for (Id parentId : woParentProductReqChildren.keySet()) {
            Map<Id, ProductRequired> prMap = woParentProductReqChildren.get(parentId);
            for (Id prId : prMap.keySet()) {
                ProductRequired pr = prMap.get(prId);
                if (pr.ParentRecordId == null){
                    pr.ParentRecordId = parentId;
                }
                pr.Product2Id = prId;
                prListToInsert.add(pr);
            }
        }
        return XC_UTIL_Sobject.upsertListRecords(prListToInsert);
    }

    /**
    * @description verifyBookingNotificationStep - check the step Booking Notification. If it is in progress, the step has to be re-launched and the related CI created
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 27/08/2021 
    * @param listWorkOrderToUpdate 
    **/
    private static void verifyBookingNotificationStep (List<WorkOrder> listWorkOrderToUpdate){
        List<XC_Provisioning_Step__c> bookNotificationSteps = new List<XC_Provisioning_Step__c>();
        List<String> orderItemVerifiedList = new List<String> ();
        List<String> orderIdList = new List<String>();
        for(WorkOrder wo : listWorkOrderToUpdate){
            orderIdList.add(wo.XC_Configuration__c);
        }
        if(orderIdList.isEmpty()){
            return;
        }
        String segmentB2C = 'B2C';
        String bookNotificationFlow= Label.XC_CL_ProvisioningSendBookingNotification_Flow;
        List<String> productReservationFlowsList = new List<String>{Label.XC_CL_ProvisioningProductReservation_Flow, Label.XC_CL_ProvisioningReservationSpareParts_Flow};
        String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_Provisioning_Step__c'));
        query += String.escapeSingleQuotes(' FROM XC_Provisioning_Step__c WHERE XC_Configuration_Item__r.NE__OrderId__c IN: orderIdList AND (XC_Flow_API_Name__c =: bookNotificationFlow OR XC_Flow_API_Name__c IN: productReservationFlowsList) AND XC_Segment__c =: segmentB2C');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stepsQuery---> ' + query);
        List<XC_Provisioning_Step__c> stepList = Database.query(query);
        for(XC_Provisioning_Step__c step : stepList){
            if(productReservationFlowsList.contains(step.XC_Flow_API_Name__c) && step.XC_MasterofProductReservation__c){
                orderItemVerifiedList.add(step.XC_Configuration_Item__c);
            }
        }
        for(XC_Provisioning_Step__c step : stepList ){
            if(orderItemVerifiedList.contains(step.XC_Configuration_Item__c) &&  step.XC_Flow_API_Name__c == bookNotificationFlow && step.XC_Status__c == Label.XC_CL_Provisioning_Step_InProgress ){
                bookNotificationSteps.add(step);
            }
        }
        if(!bookNotificationSteps.isEmpty()){
            XC_UTIL_ProvisioningStep.insertEvent(bookNotificationSteps);
        }
    }
}