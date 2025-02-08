/**
 * @author Nicola Arrigo - narrigo@deloitte.it
 * @date Creation 25/03/2021
 * @description XC_TR_CheckApprovalPartnerPayment 
 */
public with sharing class XC_TR_CheckApprovalPartnerPayment {
     /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description checkInsertPartnerPayment
     * @param woliToInsert - list WorkOrderLineItems 
    */
    @InvocableMethod 
    public static void checkInsertPartnerPayment (List<WorkOrderLineItem> woliToInsert){
         List<WorkOrderLineItem> woliPartnerPayment=new List<WorkOrderLineItem>();  
         List<Id> woListId=new List<Id>(); 
         system.debug('enter method checkInsertPartnerPayment');
         system.debug('woliToInsert '+woliToInsert);
         system.debug('woliToInsert size '+woliToInsert.size());         
         //check woli type
         for(WorkOrderLineItem woli:woliToInsert){
               system.debug('woli record'+woli);
               system.debug('type work order line item insert '+woli.XC_WOLIType__c);
               if(woli.XC_WOLIType__c=='Partner Payment'){
                  system.debug('enter if condition type Partner Payment');
                 woliPartnerPayment.add(woli);
                 woListId.add(woli.WorkOrderId);  
               }
             else{
                 //XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.remove(Trigger.operationType);
                 system.debug('XC_TR_WorkOrderLineItem_Handler.mapTriggerStopped.remove');
             }
            }
        system.debug('List woli Partner Payment '+woliPartnerPayment);
         if(woliPartnerPayment.size()==0){
             return;
         }
            //check workorder not malfuntioning
            List<WorkOrder> woListPartnerPayment=[select id,ParentWorkOrderId,XC_WorkTypeCategory__c from WorkOrder 
                                                   where id IN:woListId and XC_WorkTypeCategory__c!=:'Malfunctioning' 
                                                   and (XC_Segment__c='B2B' or XC_Segment__c='B2G')]; 
         system.debug('woListPartnerPayment '+woListPartnerPayment);
             if(woListPartnerPayment.size()==0){
                 return;
             }
             //check OrganizerId
             List<id> woOrganizerListId=new List<id>();
             for(WorkOrder wo:woListPartnerPayment){
                 if(wo.ParentWorkOrderId!=null){
                     woOrganizerListId.add(wo.ParentWorkOrderId);
                     system.debug('woOrganizerListId '+woOrganizerListId);
                 }else if(wo.XC_WorkTypeCategory__c=='Organizer'){
                     woOrganizerListId.add(wo.id);
                     system.debug('woOrganizerListId 2°if '+woOrganizerListId);
                 }
             }
             //List WorkOrder for an Organizer
             Map<id,WorkOrder> woOrganizerMap=new Map<id,WorkOrder>([select id,(select id from ChildWorkOrders) ,(select id,recordtype.developername,XC_WOLIType__c from WorkOrderLineItems where (recordtype.developername like '%MR_WOLI' or (XC_WOLIType__c='Good Issue' and status='Completed') )) 
                                                                     from WorkOrder
                                                                     where id IN:woOrganizerListId]);
            //Organizer with wo related
           List<id> woOrgIdList=new List<id>();
        for(Workorder wo:woOrganizerMap.values()){
            if(wo.ChildWorkOrders.size()>0){
                woOrgIdList.add(wo.id);
            }
            
        }
             //woList is the list of the Work Order related to the Organizer																
             List<WorkOrder> woList=[select id,ParentWorkOrderId, (select id,XC_WOLIType__c from WorkOrderLineItems where XC_WOLIType__c='Good Issue' and status='Completed') 
                                                                     from WorkOrder
                                                                     where ParentWorkOrderId IN:woOrgIdList];
            // Map<id,Integer> goodIssueMapNum=new Map<id,Integer>();                                                        
            Map<id,boolean> hasMR=new Map<id,boolean>();
            Map<id,boolean> hasGoodIssue=new Map<id,boolean>();
            for(WorkOrder woOrganizer:woOrganizerMap.values()){
                system.debug('List Woli MR '+woOrganizer.WorkOrderLineItems);
                if(!woOrganizer.WorkOrderLineItems.isEmpty()){
                    for(WorkOrderLineItem woli:woOrganizer.WorkOrderLineItems){
                        system.debug('woli Organizer Type '+woli.XC_WOLIType__c);
                        if(woli.XC_WOLIType__c!='Good Issue'){
                            hasMR.put(woOrganizer.id,true);
                            system.debug('woli type diverso da Good Issue');
                        }else{
                            hasGoodIssue.put(woOrganizer.id,true);     
                        }
                     }
                }
                if(woList.size()>0){
                    for(WorkOrder wo:woList){
                        if(wo.ParentWorkOrderId==woOrganizer.id &&
                            wo.WorkOrderLineItems.size()>0){
                            /*integer y=wo.WorkOrderLineItems.size();
                            i=i+y;*/
                           // goodIssueMapNum.put(woOrganizer.id,wo.WorkOrderLineItems.size());
                           system.debug('List Woli GoodIssue '+wo.WorkOrderLineItems);
                           hasGoodIssue.put(woOrganizer.id,true);
                        }
                     }
                  //   system.debug('hasGoodissueMap '+hasGoodIssue);
                    }
                    system.debug('hasGoodissueMap '+hasGoodIssue); 
                    system.debug('MR Request woli '+hasMR);
                }                                                                                                                 
            Map<WorkOrderLineItem,id> idOrganizerMap=new Map<WorkOrderLineItem,id>();
            for(WorkOrderLineItem woli:woliPartnerPayment){
                for(WorkOrder wo:woListPartnerPayment){
                    if(wo.ParentWorkOrderId!=null &&
                         woli.WorkOrderId==wo.id){
                       idOrganizerMap.put(woli,wo.ParentWorkOrderId);
                       system.debug('id WO Organizer '+idOrganizerMap);
                         }else if(wo.ParentWorkOrderId==null){
                             idOrganizerMap.put(woli,wo.Id);
                             system.debug('id WO Organizer second if '+idOrganizerMap);
                         }
                 }
             }
             for(WorkOrderLineItem woli:woliPartnerPayment){
                if(idOrganizerMap.get(woli)!=null){
                   id woOrganizerId=idOrganizerMap.get(woli);
                     if( hasMR.get(woOrganizerId)!=null){
                        if(woOrganizerMap.get(woOrganizerId).WorkOrderLineItems.size()>0  &&
                        hasMR.get(woOrganizerId)==true ){
                       system.debug('if cycle organizer with woli');
                       //system.debug('Good Issue Number '+goodIssueMapNum.get(woOrganizerId));   
                    if(hasGoodIssue.get(woOrganizerId)==true){
                        system.debug('if condition Good Issue');
                         woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';                                   
                       }else{
                          system.debug('No Good Issue');
                           woli.XC_ApprovalProcessCheckGoodIssue__c='Non Esiste alcuna Good Issue associata';  
                         }
                       }
                     }else if(hasMR.get(woOrganizerId)==null){
                        system.debug('Organizer with no Material Request');  
                        woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';	   
                    }         
                }else{
                    system.debug('No WoOrganizer');
                    woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';
                }
             } 
     }
     /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @description checkInsertPartnerPayment
     * @param woliToInsert - list WorkOrderLineItems
     * @param  oldMap - map Id -> new value of record
    */
     public static void checkGoodIssueCompleted (List<WorkOrderLineItem> woliToInsert, Map<id,WorkOrderLineItem> oldMap){
        List<WorkOrderLineItem> woliPartnerPayment=new List<WorkOrderLineItem>();  
        List<Id> woListId=new List<Id>(); 
        for(WorkOrderLineItem woli:woliToInsert){
            if(woli.XC_WOLIType__c=='Good Issue' &&
                woli.Status=='Completed' &&
                woli.Status!=oldMap.get(woli.id).Status){
                  woliPartnerPayment.add(woli);
                  woListId.add(woli.WorkOrderId);
                }
            }
         if(woliPartnerPayment.isEmpty()){
             return;
         }
           //check workorder not malfuntioning
           List<WorkOrder> woListPartnerPayment=[select id,ParentWorkOrderId,XC_WorkTypeCategory__c from WorkOrder 
                                                    where id IN:woListId and XC_WorkTypeCategory__c!=:'Malfunctioning' 
                                                    and (XC_Segment__c='B2B' or XC_Segment__c='B2G')]; 
            if(woListPartnerPayment.size()==0){
                return;
             }
            //check OrganizerId
             List<id> woOrganizerListId=new List<id>();
             for(WorkOrder wo:woListPartnerPayment){
                  if(wo.ParentWorkOrderId!=null){
                      woOrganizerListId.add(wo.ParentWorkOrderId);
                  }else if(wo.ParentWorkOrderId==null &&
                           wo.XC_WorkTypeCategory__c=='Organizer'
                          ){
                      woOrganizerListId.add(wo.id);
                  }
             }
             //woList is the list of the Work Order related to the Organizer																
             List<WorkOrder> woList=[select id,ParentWorkOrderId, (select id,XC_ApprovalProcessCheckGoodIssue__c,status from WorkOrderLineItems 
                                                                    where XC_WOLIType__c='Partner Payment' and 
                                                                       (status!='To be approved' and status!='Completed')
                                                                    ) 
                                                                     from WorkOrder
                                                                     where (ParentWorkOrderId IN:woOrganizerListId OR id IN:woOrganizerListId) ];
             List<WorkOrderLineItem> woliListItems=new List<WorkOrderLineItem>(); 
             for(WorkOrder wo:woList){
                 if(!wo.WorkOrderLineItems.isEmpty()){
                    for(WorkOrderLineItem woli:wo.WorkOrderLineItems){
                        system.debug('woli status '+woli.status);
                        if(woli.XC_ApprovalProcessCheckGoodIssue__c=='Non Esiste alcuna Good Issue associata' ||
                             woli.XC_ApprovalProcessCheckGoodIssue__c==null){
                               woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';
                        }
                        woliListItems.add(woli);
                    }
                 }
             }
            update woliListItems;
     }
 }