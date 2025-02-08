/**
* @author dpalamides
* @date 10/07/2020
* @description classes.XC_TR_ProductRequired_WOLI_InProgress
*/


public with sharing class XC_TR_ProductRequired_WOLI_InProgress {
    /**
     * @author dpalamides - dpalamides@deloitte.it
     * @description on PR creation WOLI goes in progress
     * @param mapNew Map<Id,ProductRequired>
    */
    public static void setInProgressWOLI(Map<Id,ProductRequired> mapNew){
        Boolean toExit = mapNew == null || mapNew.isEmpty() || !Schema.sObjectType.WorkOrderLineItem.isAccessible();
        if(toExit){
            return;
        }

        List<Id> woliId = new List<Id>();
        for (ProductRequired pr : mapNew.values()) {
            if(pr.ParentRecordId!=null && XC_UTIL_Sobject.getObjectType(pr.ParentRecordId)=='WorkOrderLineItem'){
                woliId.add(pr.ParentRecordId);
            }
        }

        if(woliId.isEmpty()){
            return;
        }

        Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([select id, Status from WorkOrderLineItem where id in :woliId]);

        for(WorkOrderLineItem woli : woliMap.values()){
            if(woli.Status != 'Completed'){
                woli.Status = 'In Progress';
            }
        }

        //XC_UTIL_Sobject.updateListRecords(woliMap.values());
        update woliMap.values();
    }
}