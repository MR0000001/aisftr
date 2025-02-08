/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com 
* @date Creation 07/11/2019
* @date Modification 26/01/2021 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrderLineItem_U_CheckOnClosure - Util class to check Status of WOLI
*/

public without sharing class XC_TR_WorkOrderLineItem_U_CheckOnClosure {

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - The new list of WorkOrderLineItem
     * @param mapOld - The old map of WorkOrderLineItem
     * @param mapNew - The new map of WorkOrderLineItem
     * @description Check Status of WOLI on Update
     */
    public static void checkStatus(List<WorkOrderLineItem> listNew, Map<Id, WorkOrderLineItem> mapOld, Map<Id, WorkOrderLineItem> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Id recordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_ESP_Woli_Photo').getRecordTypeId();
        List<WorkOrderLineItem> woliClosed = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem woli : listChanged) {
            if(woli.Status == Label.XC_CL_WorkOrderLineItem_Closed &&  woli.RecordTypeId == recordTypeId && !woli.XC_UpdatedByApp__c) {
                woliClosed.add(woli);
            }
        }
        if(!woliClosed.isEmpty()){
            checkDocumentType(woliClosed, mapNew);
        }
        for(WorkOrderLineItem woli : listNew) {
            woli.XC_UpdatedByApp__c = false;
        }
    }

    /**
      * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
      * @description Method to check document type photo to close WOLI
      * @param woliClosed - List<WorkOrderLineItem> 
      * @param mapNew - Map<Id, WorkOrderLineItem>
      */
    public static void checkDocumentType(List<WorkOrderLineItem> woliClosed, Map<Id, WorkOrderLineItem> mapNew) {
        List<String> listWoliId = XC_UTIL_Sobject.getIds(woliClosed);
        List<WorkOrderLineItem> listWoli = getListWoli(listWoliId);
        List<WorkOrderLineItem> woliError = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem woli : listWoli) {
            if(woli.Document_Types__r.isEmpty()) {
                WorkOrderLineItem actualRecord = mapNew.get(woli.Id);
                actualRecord.addError(Label.XC_CL_NoDocumentTypesOnWOLI);
            }
        } 
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to get Work Order Line Item filtered
     * @param listWoliId - List<String> 
     * @return List<WorkOrderLineItem> 
     **/
    public static List<WorkOrderLineItem> getListWoli(List<String> listWoliId) {
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>([
            SELECT Id,
                (SELECT Id FROM Document_Types__r) 
            FROM WorkOrderLineItem 
            WHERE Id IN :listWoliId AND WorkOrder.XC_UpdatedByApp__c = :false
        ]);
        return listWoli;
    }

        /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew - The new list of WorkOrderLineItem
     * @param mapOld - The old map of WorkOrderLineItem
     * @param mapNew - The new map of WorkOrderLineItem
     * @date Creation 05/11/2021 - EXSFDCSL-107
     * @description update Date On WO when the WOLIs with photos are closed
     */
    public static void updateDateOnWO(List<WorkOrderLineItem> listNew, Map<Id, WorkOrderLineItem> mapOld, Map<Id, WorkOrderLineItem> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<String> woIdList = new List<String>();
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        for(WorkOrderLineItem woli : listChanged) {
            if(woli.Status == Label.XC_CL_WorkOrderLineItem_Closed && !woli.XC_UploadNeeded__c && woli.XC_Segment__c == 'B2C') {
                woIdList.add(woli.WorkOrderId);
            }
        }
        if(woIdList.isEmpty()){
            return;
        }
        Map<String, List<WorkOrderLineItem>> woIdWoliMap = getWoliBrothers(woIdList);
        for(String woId : woIdWoliMap.keySet()){
            Boolean checkStatus = false;
            List<WorkOrderLineItem> woliList = woIdWoliMap.get(woId); 
            for(WorkOrderLineItem woli : woliList){
                if(woli.Status == Label.XC_CL_WorkOrderLineItem_Closed){
                    checkStatus = true;
                } else {
                    checkStatus = false;
                    break;
                }
            }
            if(checkStatus){
                WorkOrder wo = new WorkOrder(Id = woId, XC_UploadedPhotosDate__c = System.now() );
                woToUpdateList.add(wo);
            }
        }
        if(!woToUpdateList.isEmpty()){
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(woToUpdateList);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }

    /**
    * @description retrieve the Woli Brothers
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @date Creation 05/11/2021 - EXSFDCSL-107
    * @param woIdList 
    * @return Map<String, List<WorkOrderLineItem>> 
    **/
    private static Map<String, List<WorkOrderLineItem>> getWoliBrothers(List<String> woIdList) {
        Map<String, List<WorkOrderLineItem>> woIdWoliMap = new Map<String, List<WorkOrderLineItem>>();
        List<WorkOrderLineItem> woliQueried = new List<WorkOrderLineItem>([SELECT Id, XC_UploadNeeded__c, Status, WorkOrderId 
                                                                            FROM WorkOrderLineItem 
                                                                            WHERE WorkOrderId IN: woIdList
                                                                            AND XC_UploadNeeded__c =: false
                                                                            AND XC_Segment__c =: 'B2C']);
        for(WorkOrderLineItem woli : woliQueried){
            if(!woIdWoliMap.containsKey(woli.WorkOrderId)){
                woIdWoliMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
            }
            woIdWoliMap.get(woli.WorkOrderId).add(woli);
        }
        return woIdWoliMap;
    }
}