/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date 04/08/2020
* @description classes. XC_TR_ProductConsumed_WOLI_InProgress
*/
public with sharing class XC_TR_ProductConsumed_WOLI_InProgress {
   /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description on PC creation WOLI goes in progress
     * @param mapNew Map<Id,XC_ProductConsumed__c>
    */
    public static void setInProgressWOLI(Map<Id,XC_ProductConsumed__c> mapNew){
        Boolean toExit = mapNew == null || mapNew.isEmpty() || !Schema.sObjectType.WorkOrderLineItem.isAccessible();
        if(toExit){
            return;
        }
        List<Id> woliId = new List<Id>();
        for(XC_ProductConsumed__c pc:mapNew.values()){
           if(pc.XC_WorkOrderLineItem__c!=null){
            woliId.add(pc.XC_WorkOrderLineItem__c);
           }
        }
        if(woliId.isEmpty()){
            return;
        }

        Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([select id, Status from WorkOrderLineItem where id in :woliId]);
        for(WorkOrderLineItem woli : woliMap.values()){
            if(woli.Status == 'New'){
                woli.Status = 'In Progress';
            }
        }

        //XC_UTIL_Sobject.updateListRecords(woliMap.values());
        update woliMap.values();
    }
}