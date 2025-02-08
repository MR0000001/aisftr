/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 13/02/2019
* @date Modification 16/07/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC079_RemovePreferencies - Controller for XC_LCP079_RemovePreferencies Component 
*/

public class XC_LCC079_RemovePreferences {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC079_RemovePreferences');

    /** @description ResultWrapper */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public String result = ''; 
    }

    /**
     * @description Method to remove Resource Preferences
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 16/07/2020
     * @param recordId - Id
     * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper removePreferences (Id recordId){   
        List<WorkOrder> listWorkOrder = XC_UTIL_Sobject.selectAllFields(recordId);
        List<WorkOrder> listWorkOrderNoSlot = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderOthers = new List<WorkOrder>();
        List<WorkOrder> listWorkOrderRefused = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'wo.XC_StatusReason__c ->' + wo.XC_StatusReason__c);
            if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_NoAvailability) {
                listWorkOrderNoSlot.add(wo);
            } else if(wo.XC_Refusing_Reason__c == Label.XC_CL_CurrentlyNotAvailable){
                listWorkOrderRefused.add(wo);
            } else {
                listWorkOrderOthers.add(wo);
            }
        }

        // For Work Orders with Status Reason No Slot:
        List<XC_UTIL_Sobject.WrapperResult> wrList = new List<XC_UTIL_Sobject.WrapperResult>();
        if(!listWorkOrderNoSlot.isEmpty()) {
            Map<Id, WorkOrder> mapResourcePreferenceRequired = XC_UTIL_ResourcePreference.getMapResourcePreference(XC_UTIL_Sobject.getIds(listWorkOrderNoSlot), 'Required');
            List<ResourcePreference> listToUpdate = new  List<ResourcePreference>();
            for(WorkOrder wo : mapResourcePreferenceRequired.values()) {
                for(ResourcePreference rp : wo.ResourcePreferences) {
                    rp.PreferenceType = 'Excluded';
                    listToUpdate.add(rp);
                }
            }
            wrList.addAll(XC_UTIL_Sobject.updateListRecords(listToUpdate));
        }
        // For Work Orders with Refusing Reason - Currently not Available:
        if(!listWorkOrderRefused.isEmpty()){
            wrList.addAll(XC_UTIL_ResourcePreference.removeResourcePreferences(listWorkOrderRefused));
        }
        // For others Work Orders
        if(!listWorkOrderOthers.isEmpty()) {
            wrList.addAll(XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(listWorkOrderOthers));  
        }

        // Manage Output:
        ResultWrapper rw = new ResultWrapper(); 
        rw.success = XC_UTIL_Sobject.checkDMLResults(wrList);
        if(!rw.success){ 
            rw.result = wrList[0].errorMessage;
        } 
        WorkOrder woToUpdate = listWorkOrder[0];
        List<ServiceAppointment> saToUpdate = ([
            SELECT Id, XC_RequiredPartnerId__c
            FROM ServiceAppointment
            WHERE XC_RequiredPartnerId__c != null
                AND ParentRecordId =: woToUpdate.Id
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'woToUpdate.XC_RequiredPartnerId__c->' + woToUpdate.XC_RequiredPartnerId__c);
        if(woToUpdate.XC_RequiredPartnerId__c != null){
            woToUpdate.XC_RequiredPartnerId__c = null;
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateRecord(woToUpdate);  
        }
        if(!saToUpdate.isEmpty()){
            saToUpdate[0].XC_RequiredPartnerId__c = null;
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateRecord(saToUpdate[0]);
        }
        return rw; 
    }

}