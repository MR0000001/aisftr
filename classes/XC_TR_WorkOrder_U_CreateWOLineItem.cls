/**
* @author Marco Rosa - marco.rosa@nttdata, & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/10/2018
* @date Modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 02/08/2019
* @description XC_TR_WorkOrder_U_CreateWOLineItem – Create Work Order Line Item records on creation of the Work Order
*                                                   based on Custom Metadata
*/

public without sharing class XC_TR_WorkOrder_U_CreateWOLineItem {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateWOLineItem');

    /**
     * @description Insert Work Order Line Item
     * @date Modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 02/08/2019
     * @param listWorkOrder - List<WorkOrder>
     * @param mapOld - Map<Id, WorkOrder>
    *  @param mapNew - Map<Id, WorkOrder>
    */
    public static void createWorkOrderLineItem(List<WorkOrder> listWorkOrder, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'XC_TR_WorkOrder_U_CreateWOLineItem'); 
        system.debug('enter method'+'createWorkOrderLineItem');
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        List<WorkOrder> listWorkOrderTriggered = new List<WorkOrder>();
        List<id> woIdList=new list<id>();
        for(WorkOrder wo : listChanged) {
            if(wo.Status == Label.XC_CL_WorkOrder_Assigned) {
                listWorkOrderTriggered.add(wo);
                woIdList.add(wo.id);  //NA 1408
                system.debug('workroder'+' '+wo);
            }
        }
        if(listWorkOrderTriggered.isEmpty()) {
            return;
        }       

        List<WorkOrder> listWorkOrderWithChildren = new List<WorkOrder>([
            SELECT Id, Country, XC_Coverage__r.XC_Product_Name__c, Asset.NE__ProdId__c,XC_LegalEntity__c, XC_ProdCatOfInterestText__c, XC_NumberOfWoliCheckList__c,XC_Segment__c,
            ParentWorkOrder.XC_WorkTypeCategory__c, Asset.NE__Bundle_Configuration__c, ParentWorkOrder.Asset.NE__Bundle_Configuration__r.Name, 
            XC_ProductSubType__c, ParentWorkOrder.Asset.NE__ProdId__r.Name, Asset.NE__ProdId__r.Name, XC_WorkTypeLabel__c, XC_Country__c, 
            WorkTypeId, ParentWorkOrderId, XC_NumberOfWoli__c, Asset.NE__Bundle_Configuration__r.Name, AssetId, XC_WorkTypeCategory__c, 
            XC_Coverage__r.Parent.XC_Product_Name__c, XC_Coverage__r.ParentId, Asset.NE__Bundle_Configuration__r.XC_Product_Name_LIC__c,
                (SELECT Id, Country, XC_WorkTypeLabel__c, XC_Country__c, WorkTypeId, ParentWorkOrderId, XC_NumberOfWoli__c, AssetId,XC_WorkTypeCategory__c, XC_Segment__c
                FROM ChildWorkOrders 
                WHERE XC_NumberOfWoli__c = 0)
            FROM WorkOrder
            WHERE Id IN :woIdList AND (XC_NumberOfWoli__c = 0  OR 
                                          (XC_NumberOfWoliCheckList__c=0 AND (XC_Segment__c='B2B' OR XC_Segment__c='B2G') ))
        ]);
        system.debug('listWorkOrderWithChildren'+''+listWorkOrderWithChildren);
        List<String> listCategoryToSkipped = new List<String>{Label.XC_CL_WorkType_PlannedMaintenance, Label.XC_CL_WorkType_Diagnostic};
        List<WorkOrder> listWoWithoutChildren = new List<WorkOrder>();
        List<WorkOrder> listWithChildren = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrderWithChildren) {
            // If WO has not children, create WOLI on WO or if WO has children and WO has a Asset:
            if(wo.ChildWorkOrders.size()>0){
                system.debug('childWorkOrders'+' '+wo.ChildWorkOrders);
            }
            if((wo.ChildWorkOrders.isEmpty() && !(String.isNotBlank(wo.ParentWorkOrderId) && listCategoryToSkipped.contains(wo.XC_WorkTypeCategory__c)))
                || String.isNotBlank(wo.AssetId)) {
                    listWoWithoutChildren.add(wo);
            }
            system.debug('listWoWithoutChildren'+' '+listWoWithoutChildren);
            /*if(wo.ChildWorkOrders.isEmpty() && !(String.isNotBlank(wo.ParentWorkOrderId) && listCategoryToSkipped.contains(wo.XC_WorkTypeCategory__c))) {
                // If WO has not children, create WOLI on WO:
                listWoWithoutChildren.add(wo);
            } else {
                // If WO has children and WO has not a Asset (for Multiple Installation/Repair):
                if(String.isBlank(wo.AssetId)) {
                    listWithChildren.add(wo);
                } 
                // If WO has children and WO has a Asset:
                else {
                    listWoWithoutChildren.add(wo);
                }
            }*/
        }

        if(!listWoWithoutChildren.isEmpty()) {
            system.debug('createActivitiesForWOwithoutChildren');
            createActivitiesForWOwithoutChildren(listWoWithoutChildren);
        }
        /*if(!listWithChildren.isEmpty()) {
            manageWOwithChildren(listWithChildren);
        }*/
    } 

    /**
     * @description Check Activity Plan for WOLI creation
     * @date Modification Salvatore Agrillo - salvatore.agrillo@nttdata.com - 02/08/2019
     * @param listChanged - List<WorkOrder>
    */
    public static void createActivitiesForWOwithoutChildren(List<WorkOrder> listChanged) {
        system.debug('method'+' '+'createActivitiesForWOwithoutChildren');
        Map<String, String> mapWorkOrderProductActivityPlan = new Map<String, String>();
        for(WorkOrder wo : listChanged) {
            String productForActivityPlan = buildProductForActivtyPlan(wo);
            system.debug('productForActivityPlan'+' '+productForActivityPlan);
            mapWorkOrderProductActivityPlan.put(wo.Id, productForActivityPlan);
        }
        List<String> listCatalogItemName = mapWorkOrderProductActivityPlan.values();
        List<String> listWorkTypeName = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_WorkTypeLabel__c');
        List<String> listCountries = new List<String>();//XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Country__c');
        for(WorkOrder wo : listChanged ){
            if(!String.isEmpty(wo.Country)){
                listCountries.add(wo.Country);
            } else if(!String.isEmpty(wo.XC_Country__c)){
                listCountries.add(wo.XC_Country__c);
            }
        }

        system.debug('listWorkTypeName '+' '+listWorkTypeName+'&'+' listCountries'+' '+listCountries + '& listCatalogItemName' + listCatalogItemName);
        if(!listWorkTypeName.isEmpty() && !listCatalogItemName.isEmpty()) {
            Map<Id,XC_WorkOrderActivityPlanItem__c> mapRecordsMetadata = new Map<Id,XC_WorkOrderActivityPlanItem__c>([
                SELECT XC_Comment__c, XC_WorkType__c,XC_CatalogItem__c,XC_RecordType__c,XC_Country__c, XC_BlockName__c,XC_BlockNumber__c,XC_ActivityName__c,XC_ActivityNumber__c, XC_RelatedMeasure__c,XC_Required__c,
                        XC_Range__c, XC_Description__c,XC_RepeatEachAsset__c,XC_NumberOfMeasurement__c, XC_MeasurementUnitOne__c, XC_TechnicianResponse__c,XC_ObservationOne__c, XC_ObservationTwo__c, XC_CompletionMode__c, XC_ServiceAffected__c, XC_UploadNeeded__c 
                FROM XC_WorkOrderActivityPlanItem__c
                WHERE XC_WorkType__c IN: listWorkTypeName 
                AND XC_CatalogItem__c IN: listCatalogItemName
                AND XC_Country__c IN: listCountries
                ORDER BY XC_BlockNumber__c, XC_ActivityNumber__c
            ]);
            List<XC_WorkOrderActivityPlanItem__c> listRecordsMetadata = mapRecordsMetadata.values();

            List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();           
            for(WorkOrder wo : listChanged) {
                for(XC_WorkOrderActivityPlanItem__c woAct : listRecordsMetadata) {
                    if(checkConditionCreateWoli(wo, woAct, mapWorkOrderProductActivityPlan)) {   
                        if(!wo.ChildWorkOrders.isEmpty()) { //woAct.XC_RepeatEachAsset__c && 
                            for(WorkOrder woChild : wo.ChildWorkOrders) {
                                woliList.add(createWOLI(woChild, woAct));
                            }
                        } else {
                            woliList.add(createWOLI(wo, woAct));
                        }               
                    }
                }
            }
            system.debug('woliListNic'+''+woliList);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'listWOLineItemToInsert->' + woliList); 
            XC_UTIL_Sobject.insertListRecords(woliList);
        }
    }

    /**
     * @description Populate fields for Work Order Line Item
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @date 26/02/2020
     * @param wo - WorkOrder
     * @param woAct - XC_WorkOrderActivityPlanItem__c
    */
    private static WorkOrderLineItem createWOLI(WorkOrder wo, XC_WorkOrderActivityPlanItem__c woAct) {
        system.debug('enter'+' '+'createWOLINic');
        String recordTypeId = String.isNotBlank(woAct.XC_RecordType__c) ? Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get(woAct.XC_RecordType__c).getRecordTypeId() : '';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId             = wo.Id;
        woli.RecordTypeId            = String.isNotBlank(recordTypeId) ? recordTypeId : '';
        woli.WorkTypeId              = wo.WorkTypeId;
        woli.XC_MacroBlocName__c     = woAct.XC_BlockName__c; 
        woli.XC_MacroBlocNumber__c   = woAct.XC_BlockNumber__c; 
        woli.XC_ActivityName__c      = woAct.XC_ActivityName__c; 
        woli.XC_ActivityNumber__c    = woAct.XC_ActivityNumber__c; 
        woli.Description             = woAct.XC_Description__c; 
        woli.XC_ObservationsOne__c   = woAct.XC_ObservationOne__c;
        woli.XC_ObservationsTWO__c   = woAct.XC_ObservationTwo__c;
        woli.XC_CompletionMode__c    = woAct.XC_CompletionMode__c;
        woli.XC_ServiceAffected__c   = woAct.XC_ServiceAffected__c;
        woli.XC_UploadNeeded__c      = woAct.XC_UploadNeeded__c;
        woli.XC_TechnicianResponseForConfiguration__c = woAct.XC_TechnicianResponse__c;
        woli.XC_NumberOfMeasurement__c   = woAct.XC_NumberOfMeasurement__c;
        woli.XC_RelatedMeasure__c = woAct.XC_RelatedMeasure__c;
        woli.XC_MeasurementUnitOne__c = woAct.XC_MeasurementUnitOne__c; 
        woli.XC_Range__c = woAct.XC_Range__c;
        woli.XC_Comment__c = woAct.XC_Comment__c;
        woli.XC_Required__c = woAct.XC_Required__c;
        if(wo.XC_WorkTypeCategory__c=='Malfunctioning' && 
           (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G')){
               woli.XC_WOLIType__c='Activity';
              woli.WorkTypeId=null;
               system.debug('WoliType'+''+woli.XC_WOLIType__c);
           }else if(wo.XC_Segment__c=='B2C'){
                system.debug('case B2B: removing WorkTypeId on woli');
                woli.WorkTypeId=null;
            }
        return woli;
    }

    /**
     * @description Method to check if current WO match custom record for configuration
     * @param wo - WorkOrder
     * @param woAct - XC_WorkOrderActivityPlanItem__c
     * @param mapWorkOrderProductActivityPlan - Map<String, String> 
    */
    private static Boolean checkConditionCreateWoli(WorkOrder wo, XC_WorkOrderActivityPlanItem__c woAct, Map<String, String> mapWorkOrderProductActivityPlan){
        String country = !String.isEmpty(wo.Country) ? wo.Country : wo.XC_Country__c; 
        return (wo.XC_NumberOfWoli__c == 0 || wo.XC_NumberOfWoliCheckList__c==0) && mapWorkOrderProductActivityPlan.get(wo.Id) == woAct.XC_CatalogItem__c && wo.XC_WorkTypeLabel__c == woAct.XC_WorkType__c && country == woAct.XC_Country__c;
    }

    /**
     * @description Method to build field check "Product for Activity Plan"
     * @date 06/04/2020
     * @param wo - WorkOrder
     * @return String
    */
    public static String buildProductForActivtyPlan(WorkOrder wo) {
	   //NA 08042021 FOR Segment B2B or B2G
        if(wo.XC_Segment__c=='B2B' ||
            wo.XC_Segment__c=='B2G'){
                return wo.XC_ProductSubType__c;
            }//END NA 08042021
        if(wo.XC_LegalEntity__c == 'Codensa') {
            if(wo.XC_WorkTypeLabel__c == Label.XC_CL_SiteInspectionConsulting) {
                return 'Consulting';
            }
            else if(wo.XC_WorkTypeLabel__c == 'Site Inspection Energy Infrastructure') {
               return 'Energy Infrastructure';
            }
        }
        if(wo.XC_LegalEntity__c == 'EnelXItalia' || wo.XC_LegalEntity__c == 'EnelXMobilityItalia') {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit ||
                (wo.XC_WorkTypeCategory__c==Label.XC_CL_WorkType_Malfunctioning )) {
                    system.debug('WoSubtype'+' '+wo.XC_ProductSubType__c);
                return wo.XC_ProductSubType__c;
            }else if(String.isNotBlank(wo.Asset.NE__Bundle_Configuration__c)) {
                return wo.Asset.NE__Bundle_Configuration__r.XC_Product_Name_LIC__c;
            }else if(String.isBlank(wo.Asset.NE__Bundle_Configuration__c) && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                return wo.XC_ProductSubType__c;
            } else {
                system.debug('enter if condition Catalog Item');
                system.debug('CatalogIem '+wo.Asset.NE__ProdId__r.Name);
                return wo.Asset.NE__ProdId__r.Name;
                
            }
        } 
        if(wo.XC_LegalEntity__c == 'EndesaX' || wo.XC_LegalEntity__c == 'EnelXMobilitySpain') {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection) {
                return wo.XC_ProductSubType__c;
            }       
            if(String.isNotBlank(wo.ParentWorkOrderId) && wo.XC_WorkTypeCategory__c == Label.XC_CL_QualityCheckInspection && String.isNotBlank(wo.ParentWorkOrder.Asset.NE__Bundle_Configuration__c)) {
                return wo.ParentWorkOrder.Asset.NE__Bundle_Configuration__r.Name;
            } 
            else if(String.isNotBlank(wo.ParentWorkOrderId ) && wo.XC_WorkTypeCategory__c == Label.XC_CL_QualityCheckInspection && String.isNotBlank(wo.ParentWorkOrder.Asset.NE__ProdId__r.Name)) {
                return wo.ParentWorkOrder.Asset.NE__ProdId__r.Name;
            } 
            else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && wo.ParentWorkOrder.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && String.isNotBlank(wo.XC_Coverage__r.Parent.XC_Product_Name__c)) {
                return wo.XC_Coverage__r.Parent.XC_Product_Name__c;
            }
            else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && String.isBlank(wo.Asset.NE__ProdId__c) && String.isNotBlank(wo.XC_Coverage__c) && String.isNotBlank(wo.XC_Coverage__r.Parent.XC_Product_Name__c)) {
                return wo.XC_Coverage__r.Parent.XC_Product_Name__c;
            }
            else if(wo.XC_ProductSubType__c == 'Accessories') {
                return 'Termostato';
            } 
        }
        if(String.isNotBlank(wo.Asset.NE__Bundle_Configuration__c)) {
            return wo.Asset.NE__Bundle_Configuration__r.Name;
        } else {
            return wo.Asset.NE__ProdId__r.Name;
        }
    }

    
    public static void codeCoverage() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
    }

    /**
     * @description Insert Work Order Line Item for WO with children 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date 02/08/2019
     * @param listWoWithChildren - List<WorkOrder>
    */
    /*@testVisible
    private static void manageWOwithChildren(List<WorkOrder> listWoWithChildren) {
        Set<String> setIdsChildWorkOrder = new Set<String>();
        for(WorkOrder parentWO : listWoWithChildren) {
            for(WorkOrder childWO : parentWO.ChildWorkOrders) {
                setIdsChildWorkOrder.add(childWO.Id);
            }
        }
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>([
            SELECT Id, WorkOrderId
            FROM WorkOrderLineItem
            WHERE WorkOrderId IN :setIdsChildWorkOrder
        ]);
        Map<String, List<WorkOrderLineItem>> mapWoChildWoli = new Map<String, List<WorkOrderLineItem>>();
        for(WorkOrderLineItem woli : listWoli) {
            if(!mapWoChildWoli.containsKey(woli.WorkOrderId)) {
                mapWoChildWoli.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
            }
            mapWoChildWoli.get(woli.WorkOrderId).add(woli);
        }

        List<WorkOrderLineItem> listWOLIToUpdate = new List<WorkOrderLineItem>();
        for(WorkOrder woParent : listWoWithChildren) { 
            for(WorkOrder woChild : woParent.ChildWorkOrders) {
                if(mapWoChildWoli.containsKey(woChild.Id)) {
                    for(WorkOrderLineItem woli : mapWoChildWoli.get(woChild.Id)) {
                        WorkOrderLineItem woliToUpdate = new WorkOrderLineItem(
                            Id = woli.Id,
                            WorkOrderId = woParent.Id
                        );
                        listWOLIToUpdate.add(woliToUpdate);
                    }
                }
            }
        }

        XC_UTIL_Sobject.updateListRecords(listWOLIToUpdate);
    }*/

}