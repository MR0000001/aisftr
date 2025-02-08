public with sharing class XC_IN075_CheckApprovalPartnerPayment {

    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String woliId;
        @Invocablevariable
        public string woliType;


    }
    /**
     * @author narrigo - narrigo@deloitte.it
     * @description fill fields on Partner Payment woli
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void checkInsertPartnerPayment(List<InputWrapper> inputWrapperList){
        if(inputWrapperList == null || inputWrapperList.isEmpty()){
            return;
        }else if(inputWrapperList[0].woliType!='Partner Payment'){
            return;
        }
     WorkOrderLineItem woli=[select id,WorkOrderId,XC_WOLIType__c,XC_ApprovalProcessCheckGoodIssue__c,WorkOrder.ParentWorkOrderId from WorkOrderLineItem
                              where id=:inputWrapperList[0].woliId];
       //WO relate to the woli
       Id woId;
       woId=woli.WorkOrderId; 
     WorkOrder woPartnerPayment=[select id,ParentWorkOrderId,XC_WorkTypeCategory__c from WorkOrder 
                                                  where id=:woId]; 
      //Wo Organizer
      Id woOrganizerId;
      woOrganizerId=woPartnerPayment.ParentWorkOrderId;
      WorkOrder woOrganizer=[select id,
                                    (select id from ChildWorkOrders) ,
                                    (select id,recordtype.developername,XC_WOLIType__c from WorkOrderLineItems where (recordtype.developername like '%MR_WOLI' or (XC_WOLIType__c='Good Issue' and status='Completed') )) 
                                    from WorkOrder
                                    where id=: woOrganizerId];
         
     //List Work Order related to the Organizer							
     Map<id,boolean> hasMR=new Map<id,boolean>();
     Map<id,boolean> hasGoodIssue=new Map<id,boolean>();
     List<WorkOrder> woList=[select id,ParentWorkOrderId, (select id,XC_WOLIType__c from WorkOrderLineItems where XC_WOLIType__c='Good Issue' and status='Completed') 
                              from WorkOrder
                              where ParentWorkOrderId=:woOrganizerId];
      if(!woOrganizer.WorkOrderLineItems.isEmpty()){
            for(WorkOrderLineItem woliOrganizer:woOrganizer.WorkOrderLineItems){
                if(woliOrganizer.XC_WOLIType__c!='Good Issue'){
                    hasMR.put(woOrganizer.id,true);
                }else{
                        hasGoodIssue.put(woOrganizer.id,true);     
                     }
              }
        }
        if(!woList.isEmpty()){
            for(WorkOrder wo: woList){
               if(!wo.WorkOrderLineItems.isEmpty()){
                hasGoodIssue.put(woOrganizer.id,true); 
               }
            }
        }
        system.debug('hasGoodissueMap '+hasGoodIssue); 
        system.debug('MR Request woli '+hasMR);
        if(hasMR.get(woOrganizerId)!=null){
            if(hasMR.get(woOrganizerId)==true){
                system.debug('if cycle organizer with woli');
                if(hasGoodIssue.get(woOrganizerId)==true){
                    system.debug('if condition Good Issue');
                     woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';                                   
                   }else{
                      system.debug('No Good Issue');
                       woli.XC_ApprovalProcessCheckGoodIssue__c='Non Esiste alcuna Good Issue associata';  
                   }
            }
        }else {
                  system.debug('Organizer with no Material Request');  
                  woli.XC_ApprovalProcessCheckGoodIssue__c='Abilita Partner Payment';	 
     }
     update woli;          
   }

}