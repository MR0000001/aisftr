/**
* @author Benjamin Geronimo - WR
* @date Creation 12/04/2021
* @description TA_TR_WorkOrder_Handler – Handler for XC_TR_WorkOrder Trigger
*/

public without sharing class TA_TR_WorkOrder_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('TA_TR_WorkOrder_Handler');

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to stop recursion of the same event method in the same transaction
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to set to true the stop recursion variable on the current trigger event
    */
    public void executedTrigger() {
        //mapTriggerStopped.put(Trigger.operationType, true);
    }

    /**
     * @author Benjamin Geronimo - WR 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> sObjectListNew) {
        try {
            List<WorkOrder> workOrderListNew = (List<WorkOrder>) sObjectListNew;
            Map<String, String> lmcMap = new Map<String, String>();

            for(TA_Layout_Matrix_Configuration__c lmc : [SELECT TA_Phase__r.TA_DeveloperName__c, TA_WorkTypeCategory__c, TA_ConfigurationSet__c, TA_IndexPhase__c
                                                        FROM TA_Layout_Matrix_Configuration__c
                                                        WHERE TA_IndexPhase__c = 1
                                                        AND TA_Active__c = true]) {
                String key = lmc.TA_WorkTypeCategory__c + '/' + lmc.TA_ConfigurationSet__c;
                if(!lmcMap.containsKey(key)) {
                    lmcMap.put(key, lmc.TA_Phase__r.TA_DeveloperName__c);
                }
            }

            for(WorkOrder wo : workOrderListNew) {
                String segment = wo.XC_Segment__c == 'B2B' ? 'B2G' : wo.XC_Segment__c; //FIX [20210128AL] - INC000081536477
                String phase = lmcMap.get(wo.XC_WorkTypeCategory__c + '/' + segment + '_' + wo.XC_Country__c + '_Set');

                List<String> woTypeCategoryListToExclude = new List<String>{'Commercial Visit','Quality Check Inspection'};
                if( !woTypeCategoryListToExclude.contains(wo.XC_WorkTypeCategory__c) && wo.XC_Segment__c == 'B2C' ) {
                    wo.TA_Phase__c = 'PreService_Lock';
                } else if(phase != null) {
                    wo.TA_Phase__c = phase;
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_TR_WorkOrder_Handler] onAfterInsert - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_TR_WorkOrder_Handler', 'onAfterInsert', errorMessage, 0, errorMessage, null);
        }
    }

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    // public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
    //     XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    //     try
    //     {
    //         Map<Id, WorkOrder> mapNew = (Map<Id, WorkOrder>) mapNews;
    //         Map<Id, WorkOrder> mapOld = (Map<Id, WorkOrder>) mapOldS;         
    //         List<WorkOrder> woToUpdate = new List<WorkOrder>();
    //         for(WorkOrder wo : mapNew.values()){
    //             if(wo.XC_StatusReason__c == 'To be scheduled' && mapOld.get(wo.Id).XC_StatusReason__c != wo.XC_StatusReason__c && wo.XC_Segment__c == 'B2C'){
    //                 WorkOrder woUpdate = new WorkOrder( Id = wo.Id );
    //                 woUpdate.TA_Phase__c = 'PreService_Lock';
    //                 woToUpdate.add(woUpdate);
    //             }
    //         }
    //         XC_UTIL_Debug.debug(DEBUGACTIVE, '>_> woToUpdate ' + woToUpdate);
    //         XC_UTIL_Sobject.updateListRecords(woToUpdate);
    //     } 
    //     catch (Exception e) 
    //     {
    //         String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
    //         System.debug('[TA_TR_WorkOrder_Handler] onBeforeUpdate - EXCEPTION HANDLER: ' + errorMessage);
    //         TA_UTIL_LogManagement.createLog('TA_TR_WorkOrder_Handler', 'onBeforeUpdate', errorMessage, 0, errorMessage, null);
    //     }
    // }

    public void onBeforeUpdate(Map<Id, SObject> sObjectMapOld, Map<Id, SObject> sObjectMapNew) {
        try {
            Map<Id, WorkOrder> workOrderMapNew = (Map<Id, WorkOrder>) sObjectMapNew;
            Map<Id, WorkOrder> workOrderMapOld = (Map<Id, WorkOrder>) sObjectMapOld;
            
            Set<Id> preserviceUpdateWoIds = new Set<Id>();
            for(WorkOrder wo : workOrderMapNew.values()) {
                if(workOrderMapOld.get(wo.Id).XC_StatusReason__c != wo.XC_StatusReason__c && wo.XC_Segment__c == 'B2C') {
                    if(wo.XC_StatusReason__c == 'To be scheduled') {
                        wo.TA_Phase__c = 'PreService_Lock';
                    } else if(wo.XC_StatusReason__c == 'Assigned to the technician') {
                        wo.TA_Phase__c = 'PreService';
                        preserviceUpdateWoIds.add(wo.Id);   
                    }
                }
                if(workOrderMapOld.get(wo.Id).Status != wo.Status && wo.Status == 'Complete') {
                    wo.TA_Phase__c = 'CheckOut_Complete';
                }
                //START FIX [ADC26/08/2021] ENXCRM-199
                if(workOrderMapOld.get(wo.Id).Status != wo.Status && wo.Status == 'In Progress') {                    
                    if(wo.XC_WorkTypeCategory__c == 'Delivery & Installation') {
                        if(String.isBlank(wo.ParentWorkOrderId)) wo.TA_Phase__c = 'Action';  
                    } 
                    else if(wo.XC_WorkTypeCategory__c == 'Return') wo.TA_Phase__c = 'Action'; 
                    else if(wo.XC_WorkTypeCategory__c == 'Planned Maintenance' || wo.XC_WorkTypeCategory__c == 'Repair' || wo.XC_WorkTypeCategory__c == 'Site Inspection') wo.TA_Phase__c = 'Evaluation';                     
                }
                //END FIX [ADC26/08/2021] ENXCRM-199
            }

            if(!preserviceUpdateWoIds.isEmpty()){ //GDB - PERFORMANCE IMPROVEMENT - MAY 2022
                List<WorkOrder> preserviceUpdateWos = [SELECT Id FROM WorkOrder WHERE ParentWorkOrderId IN:preserviceUpdateWoIds];
                if(!preserviceUpdateWos.isEmpty()) {
                    for(WorkOrder wo : preserviceUpdateWos) {
                        wo.TA_Phase__c = 'PreService';
                    }
                }
                //GDB - PERFORMANCE IMPROVEMENT - MAY 2022
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.updateListRecords(preserviceUpdateWos);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            }

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_TR_WorkOrder_Handler] onBeforeUpdate - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_TR_WorkOrder_Handler', 'onBeforeUpdate', errorMessage, 0, errorMessage, null);
        }
    }

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }
    
    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    // public void onAfterInsert(Map<Id, SObject> mapNewS) { 
    //     XC_UTIL_Debug.debug(DEBUGACTIVE, '>_> Trigger on ' + Trigger.operationType);
    //     system.debug('>_> mapNews ' + mapNews);

    //     try
    //     {
    //         Map<Id, WorkOrder> mapNew = (Map<Id, WorkOrder>) mapNews;
    //         List<WorkOrder> listNew = mapNewS.values();
    //         List<WorkOrder> woToUpdate = new List<WorkOrder>();
    //         Map< String, String > lmcMap = new Map< String, String >( ); // { TA_WorkTypeCategory__c/TA_ConfigurationSet__c => TA_Phase__c }

    //         for (TA_Layout_Matrix_Configuration__c lmc : [  SELECT TA_Phase__r.TA_DeveloperName__c, TA_WorkTypeCategory__c, TA_ConfigurationSet__c, TA_IndexPhase__c
    //                                                         FROM TA_Layout_Matrix_Configuration__c
    //                                                         WHERE TA_IndexPhase__c = 1 and TA_Active__c = true ] ) 
    //         {
    //             String key = lmc.TA_WorkTypeCategory__c + '/' + lmc.TA_ConfigurationSet__c;
    //             if( !lmcMap.containsKey(key) ){
    //                 lmcMap.put( key, lmc.TA_Phase__r.TA_DeveloperName__c );
    //             } 
    //         }
    //         XC_UTIL_Debug.debug(DEBUGACTIVE,'>_> lmcMap ' + lmcMap);

    //         for(WorkOrder wo : listNew){
    //             WorkOrder woUpdate = new WorkOrder( Id = wo.Id );
    //             String phase = lmcMap.get( wo.XC_WorkTypeCategory__c + '/' + wo.XC_Segment__c + '_' + wo.XC_Country__c + '_Set' );
               
    //             if (wo.XC_StatusReason__c == 'To be scheduled' && wo.XC_Segment__c == 'B2C'){
    //                 woUpdate.TA_Phase__c = 'PreService_Lock';
    //                 woToUpdate.add(woUpdate);
    //             }
    //             else if ( phase != null)
    //             {
    //                 woUpdate.TA_Phase__c = phase;
    //                 woToUpdate.add(woUpdate);
    //             }
    //         }
    //         XC_UTIL_Debug.debug(DEBUGACTIVE, '>_> woToUpdate ' + woToUpdate);
    //         XC_UTIL_Sobject.updateListRecords(woToUpdate);
    //     } 
    //     catch (Exception e) 
    //     {
    //         String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
    //         System.debug('[TA_TR_WorkOrder_Handler] onAfterInsert - EXCEPTION HANDLER: ' + errorMessage);
    //         TA_UTIL_LogManagement.createLog('TA_TR_WorkOrder_Handler', 'onAfterInsert', errorMessage, 0, errorMessage, null);
    //     }
    // }

    public void onAfterInsert(Map<Id, SObject> sObjectMapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
    }

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record 
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }
    
    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
    }

    /**
     * @author Benjamin Geronimo - WR
     * @description Method to be executed on after undelete
     * @param mapOld - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapOld) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
    }

}