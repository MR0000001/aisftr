/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 12/06/2019
 * @date Modification MAY 2022 - FA/GDB - PERFORMANCE IMPROVEMENT
 * @description Handles the actions following the work order closure
 */
public with sharing class XC_TR_WorkOrder_U_CloseActions {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_Handler');

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @date Creation 12/06/2019
     * @date Modification dd/mm/yyyy
     * @description Handles the actions following the work order closure
     * @param listNew list of work order updated
     * @param mapOld the map of old work order versions
     * @param mapNew the map of new work order versions
     */
     
    public static void copyLossReason(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {

        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }
        List<WorkOrder> listToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit && !String.isEmpty(wo.XC_Opportunity__c)){
                listToUpdate.add(wo);
            }

        }
        if(!listToUpdate.isEmpty()){
            List<String> listOpportunityIds = XC_UTIL_SObject.getListFieldValues(listToUpdate, 'XC_Opportunity__c');
            Map<Id, Opportunity> mapOpportunity = 
                new Map<Id, Opportunity>([SELECT Id, XC_LossReason__c FROM Opportunity WHERE ID IN :listOpportunityIds]);
            Map<String, Opportunity> mapWOIdOpportunity = getMapWOIdOpportunity(listToUpdate, mapOpportunity);
            List<Opportunity> listOptyToUpdate = new List<Opportunity>();
            Opportunity optyToUpdate;

            for(WorkOrder wo : listToUpdate) {
                if(wo.Status == Label.XC_CL_WorkOrder_CannotComplete) {
                    optyToUpdate = mapWOIdOpportunity.get(wo.XC_Opportunity__c);
                    optyToUpdate.StageName = Label.XC_CL_Opportunity_ClosedLost;
                    optyToUpdate.XC_LossReason__c = wo.XC_Reason_Cannot_Complete__c;
                    listOptyToUpdate.add(optyToUpdate);
                }  
            }
            if(!listOptyToUpdate.isEmpty()) {
                XC_UTIL_SObject.updateListRecords(listOptyToUpdate);
            }
        }
    }

    private static Map<String, Opportunity> getMapWOIdOpportunity(List<WorkOrder> listNew, Map<Id, Opportunity> mapOpportunity) {

        Map<String, Opportunity> mapWOIdOpportunity = new Map<String, Opportunity>();

        for(WorkOrder wo : listNew) {
            mapWOIdOpportunity.put(wo.XC_Opportunity__c, mapOpportunity.get(wo.XC_Opportunity__c));
        }

        return mapWOIdOpportunity;
    }

    /**
     * @author Dario Tramontin dtramontin@deloitte.it
     * @date Creation 03/09/2019
     * @date Modification 28/11/2019 by Monica Cutillo - mcutillo@deloitte.it
     * @description Create case closure disputability
     * @param listNew list of work order 
     * @param mapOld
     * @param mapNew
     */
    public static void caseCreationDisputability( List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){

        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }
        List<Id> woIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id, WorkOrder> woWithChildren = new Map<Id, WorkOrder>(
                                                [SELECT Id, AssetId, XC_Coverage__c, Asset.NE__ProdId__c, Asset.RootAssetId, 
                                                    (SELECT Id, Status, XC_StatusReason__c, XC_VerificationOfRepairRequested__c
                                                     FROM ChildWorkOrders
                                                     WHERE XC_WorkTypeCategory__c =: Label.XC_CL_Repair)
                                                FROM WorkOrder
                                                WHERE Id IN: woIds]);
        List<Case> newListCases = new List<Case>();
        List<WorkOrder> listChildToUpdate = new List<WorkOrder>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##caseCreationDisputability##');
        Map<String, String> newMap = getMapWorkAsset(woWithChildren.values());
        if(newMap.values().isEmpty()){
            return;
        }
        Map<Id,Asset> mapAsset = new Map<Id,Asset>([SELECT Id, NE__Bundle_Configuration__c,ContactId,AccountId,XC_Address__c,XC_Product_Type__c, NE__Root_Order_Item__c FROM Asset WHERE Id IN :newMap.values()]);
        List<String> caseSettingNames = new List<String>{Label.XC_CL_Disconnect_Disputability_Service, Label.XC_CL_Disconnect_Disputability_SSI};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        Case newCase;
        for( WorkOrder wr : listNew){

            if( !String.isBlank(wr.XC_WorkTypeCategory__c) && (wr.XC_WorkTypeCategory__c.equals(Label.XC_CL_WorkType_PlannedMaintenance) || wr.XC_WorkTypeCategory__c.equals(Label.XC_CL_WorkType_Repair)) &&  wr.Status.equals(Label.XC_CL_WorkOrder_CannotComplete) && wr.XC_StatusReason__c == Label.XC_CL_ContractViolation){
            //if( !String.isBlank(wr.XC_WorkTypeLabel__c) &&  (wr.XC_WorkTypeLabel__c == Label.XC_CL_WorkType_PlannedMaintenance || wr.XC_WorkTypeLabel__c == Label.XC_CL_Repair) &&  wr.Status == Label.XC_CL_WorkOrder_CannotComplete && wr.XC_StatusReason__c == Label.XC_CL_ContractViolation){
                if( !(String.isBlank(mapAsset.get(newMap.get(wr.Id)).NE__Bundle_Configuration__c) )) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Bundle: ' );
                    newCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_Disconnect_Disputability_SSI)); //Label.XC_CL_Disconnect_Disputability_Service
                    newCase.AssetId = newMap.get(wr.Id);
                    newCase.ContactId =mapAsset.get(newMap.get(wr.Id)).ContactId;
                    newCase.AccountId = mapAsset.get(newMap.get(wr.Id)).AccountId;
                    newCase.XC_Address__c =mapAsset.get(newMap.get(wr.Id)).XC_Address__c;
                    newCase.XC_LegalEntity__c = wr.XC_LegalEntity__c;
                    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
                    newListCases.add(newCase);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'AssetId:'+ newMap.get(wr.Id) );
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ContactId:'+ mapAsset.get(newMap.get(wr.Id)).ContactId );
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'AccountId:'+ mapAsset.get(newMap.get(wr.Id)).AccountId );
                if( mapAsset.get(newMap.get(wr.Id)).XC_Product_Type__c == Label.XC_CL_ProductTypeService || mapAsset.get(newMap.get(wr.Id)).XC_Product_Type__c == Label.XC_CL_ProductTypeCoverage){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Service: ' + mapAsset.get(newMap.get(wr.Id)).XC_Product_Type__c );
                    newCase =XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_Disconnect_Disputability_Service)); //Label.XC_CL_Disconnect_Disputability_SSI
                    if(!String.isBlank(wr.XC_Coverage__c)){
                    	newCase.AssetId = mapAsset.get(wr.XC_Coverage__c).NE__Root_Order_Item__c;//newMap.get(wr.Id);
                    }else{
                        newCase.AssetId = mapAsset.get(wr.AssetId).Id;//newMap.get(wr.Id);  
                    }
                    newCase.ContactId =mapAsset.get(newMap.get(wr.Id)).ContactId;
                    newCase.AccountId = mapAsset.get(newMap.get(wr.Id)).AccountId;
                    newCase.XC_Address__c =mapAsset.get(newMap.get(wr.Id)).XC_Address__c;  
                    newCase.XC_LegalEntity__c = wr.XC_LegalEntity__c;
                    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Management_Case').getRecordTypeId();
                    newListCases.add(newCase);
                }
                if(!woWithChildren.get(wr.Id).ChildWorkOrders.isEmpty()){
                    for(WorkOrder child : woWithChildren.get(wr.Id).ChildWorkOrders){
                        child.XC_VerificationOfRepairRequested__c = false;
                        listChildToUpdate.add(child);
                    }
                    //GDB - PERFORMANCE IMPROVEMENT - MAY 2022 - START 
                    XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                    XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                    List<XC_UTIL_Sobject.WrapperResult> resultUpdatedWos = XC_UTIL_SObject.updateListRecords(listChildToUpdate);
                    XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                    XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'End closeAction');
            }
        }  
           
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new caseCreationAsync(newListCases));
        }else{
            List<XC_UTIL_Sobject.WrapperResult>  insertCases = XC_UTIL_DML.insertRecords(newListCases);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@@@@@@@ insertCases caseCreationDisputability res= '+ insertCases);
        }                 
		//PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - END
    }

    /**
     * @author Dario Tramontin dtramontin@deloitte.it
     * @date Creation 03/09/2019
     * @description getMapWorkAsset
     * @param listWO
     * @return <workOrderId,assetId> map
     */
    private static Map<String, String> getMapWorkAsset(List<WorkOrder> listWO){
        Map<String, String> mapWoAsset = new Map<String, String>();
        
        for(WorkOrder wr: listWO){
            if(String.isNotBlank(wr.AssetId) && String.isNotBlank(wr.Asset.NE__ProdId__c)) {
                mapWoAsset.put(wr.Id, wr.AssetId);
            } else{
                mapWoAsset.put(wr.Id, wr.XC_Coverage__c);
            }
        }
        return mapWoAsset;
    }
    
   /**
    * @description INNER QUEABLE CLASS
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class caseCreationAsync implements Queueable{
        List<Case> newListCases;
        public caseCreationAsync(List<Case> newListCases){
            this.newListCases = newListCases;
        }

        public void execute(QueueableContext context) {
            XC_UTIL_DML.insertRecords(this.newListCases);
        }
    }
}