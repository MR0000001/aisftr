/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @createdDate 27/01/2021
* @description classes. XC_AssignOwnerWorkOrder
*/
public with sharing class XC_AssignOwnerWorkOrder {
     /**
     * @author narrigo
     */
    public static void assignOwner(List<WorkOrderLineItem> listNew){
       system.debug('enter assignOwner');
        List<Id> woId=new List<id>();
       List<WorkOrderLineItem> woliTocheck=new List<WorkOrderLineItem>();
        for(WorkOrderLineItem woli:listNew){
            if(woli.XC_WOLIType__c=='Partner Engagement' ||
               woli.XC_WOLIType__c=='Material Supply'    ||
               woli.XC_WOLIType__c=='Delivery'           ||
               woli.XC_WOLIType__c=='Partner Payment'
            ){
                woId.add(woli.WorkOrderId);
                woliTocheck.add(woli);  
                system.debug('woli type '+woli.XC_WOLIType__c);
            }
        }
        if(woId.isEmpty()){
            return;
        }
        Map<id,WorkOrder> mapWorkOrder=new Map<id,WorkOrder> ([select id,XC_LegalEntity__c,XC_Segment__c,OwnerId from WorkOrder
                                                                where id IN:woId]);
       List <id> woToAsignOwnerId= checkWo(mapWorkOrder);
        if(woToAsignOwnerId.isEmpty()){
            return;
        }
        for(WorkOrderLineItem woli:woliTocheck){
            id ownerWO=mapWorkOrder.get(woli.WorkOrderId).OwnerId;
            if(woToAsignOwnerId.contains(woli.WorkOrderId)){
                system.debug('AssignWoOwner');
                woli.XC_OwnerWorkOrder__c=ownerWO;
                woli.XC_ProjectManager__c=ownerWO;
                system.debug(woli.XC_OwnerWorkOrder__c);
            }
        }
    }
    
    private static List<id> checkWo(Map<id,WorkOrder> mapWorkOrder){
      List<id> woToAsignOwnerId=new List<id>();
        for (WorkOrder wo:mapWorkOrder.values()){
           system.debug('wO Legal Entity '+wo.XC_LegalEntity__c);
        if( 
            ( wo.XC_LegalEntity__c=='EnelXItalia'         ||
              wo.XC_LegalEntity__c=='EnelXMSP'            ||
              wo.XC_LegalEntity__c=='Cogenio'             ||
              wo.XC_LegalEntity__c=='EnelSole'            ||
              wo.XC_LegalEntity__c=='YouSaveSpA'          ||
              wo.XC_LegalEntity__c=='ESCoComuniSrl'       ||
              wo.XC_LegalEntity__c=='EnelXMobility'       ||
              wo.XC_LegalEntity__c=='EnelXMobilityItalia' ||
              wo.XC_LegalEntity__c=='EnelXMobilityHolding'
           ) &&
           (
               wo.XC_Segment__c=='B2B' ||
               wo.XC_Segment__c=='B2G'
           )
         ){
            woToAsignOwnerId.add(wo.id);
            system.debug('wO  '+wo);
         }
       }
       return woToAsignOwnerId;
     }
     /**
     * @author narrigo
     */
     public static void onUpdate (List<WorkOrder> woList,Map<id,WorkOrder> mapWo){
        List<id> listNewId=new List<id>();
        Map<id,id> mapWoOnwerId=new Map<id,id>();
        List<WorkOrderLineItem> listToBeUpdated=new List<WorkOrderLineItem>();
        for(WorkOrder wo:woList){
             if(wo.OwnerId!=mapWo.get(wo.id).OwnerId &&
                 (  wo.XC_LegalEntity__c=='EnelXItalia'         ||
                    wo.XC_LegalEntity__c=='EnelXMSP'            ||
                    wo.XC_LegalEntity__c=='Cogenio'             ||
                    wo.XC_LegalEntity__c=='EnelSole'            ||
                    wo.XC_LegalEntity__c=='YouSaveSpA'          ||
                    wo.XC_LegalEntity__c=='ESCoComuniSrl'       ||
                    wo.XC_LegalEntity__c=='EnelXMobility'       ||
                    wo.XC_LegalEntity__c=='EnelXMobilityItalia' ||
                    wo.XC_LegalEntity__c=='EnelXMobilityHolding'
                    ) &&
                    (
                    wo.XC_Segment__c=='B2B' ||
                    wo.XC_Segment__c=='B2G'
                    ) 
                ){
                listNewId.add(wo.id);
                mapWoOnwerId.put(wo.id,wo.OwnerId);
                system.debug('MAP Wo Owner id '+mapWoOnwerId);
                }
            }
            if(listNewId.isEmpty()){
                return;
            }
           // XC_AssignOwnerWorkOrder.assignOwner(listNew);  
          List<WorkOrderLineItem>listWoli=[select id,XC_WOLIType__c,XC_OwnerWorkOrder__c,XC_ProjectManager__c,WorkOrderId from workorderlineitem 
                                          where WorkOrderId IN:listNewId and 
                                          (XC_WOLIType__c='Partner Engagement' or
                                           XC_WOLIType__c='Material Supply'    or
                                           XC_WOLIType__c='Delivery'           or
                                           XC_WOLIType__c='Partner Payment'
                                          )
                                         ];
         // assignOwner(listNew);
         if(listWoli.isEmpty()){
             return;
         }
        for(WorkOrderLineItem woli:listWoli){
            if(mapWoOnwerId.get(woli.WorkOrderId)!=null){
                woli.XC_OwnerWorkOrder__c=mapWoOnwerId.get(woli.WorkOrderId);
                woli.XC_ProjectManager__c=mapWoOnwerId.get(woli.WorkOrderId);
                listToBeUpdated.add(woli);
                system.debug('if condition to be Updated');
            }
        }
        if(listToBeUpdated.isEmpty()){
            return;
        }
        if(!listToBeUpdated.isEmpty()){
            update listToBeUpdated;
        }
        
     }
}