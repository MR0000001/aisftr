/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrder_CloseWO  to close Delivery WO
*/
public without sharing class giic_TR_SalesOrder_CloseWO {

/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrder Trigger to close Delivery WO 
* @param lstPOChangeEvent list<gii__SalesOrder__c>
*/	
    public static void closedWorkOrder(List<gii__SalesOrder__c> lstSOChangeEvent){
        
        List<Id> woList = new List<Id>();
        List<Id> woliList = new List<Id>();
        for (gii__SalesOrder__c so : lstSOChangeEvent) { 
            System.debug('@@@@ SALES ORDER STATUS' + so.gii__OrderStatus__c);
            if( so.gii__OrderStatus__c == 'Shipped' && so.giic_IsDelivery__c  ) {
                if(so.giic_WorkOrderLineItem__c == null){
                   woList.add(so.giic_WorkOrder__c);  
                }else{
                   woliList.add(so.giic_WorkOrderLineItem__c); 
                }   
            }               
        }
        if(!woList.isEmpty()){
           closedWorkOrder(woList); 
        }
        if(!woliList.isEmpty()){
           closedWorkOrderLineItem(woliList); 
        }
        
    }
/**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrder Trigger to close Delivery WO 
* @param lstPOChangeEvent list<gii__SalesOrder__c>
*/	
    @future
    public static void closedWorkOrder(List<Id> woListId){
        
        List<WorkOrder>  woList = new List<WorkOrder>([SELECT Id, XC_EffectiveDeliveryDate__c,Status FROM WorkOrder 
                                                       WHERE Id IN :woListId 
                                                       AND XC_WorkTypeCategory__c = 'Delivery' ]);        
        if(!woList.isEmpty()){
            for(WorkOrder wo : woList ){
                wo.Status = Label.XC_CL_WorkOrder_Completed;
                wo.XC_EffectiveDeliveryDate__c = System.today();
            } 
            XC_UTIL_SObject.updateListRecords(woList);
        }else{
            return;
        } 
    }
    
    /**
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 17/10/2019
* @description Giic_TR_SalesOrder Trigger to close Delivery WO 
* @param lstPOChangeEvent list<gii__SalesOrder__c>
*/	
    @future
    public static void closedWorkOrderLineItem(List<Id> woliListId){
        
        List<WorkOrderLineItem>  woliList = new List<WorkOrderLineItem>([SELECT Id, Status FROM WorkOrderLineItem 
                                                       WHERE Id IN :woliListId 
                                                      ]);   // AND XC_WorkTypeCategory__c = 'Delivery'
        
        if(!woliList.isEmpty()){
            for(WorkOrderLineItem woli : woliList ){
                woli.Status = Label.XC_CL_WorkOrder_Completed;
            } 
            XC_UTIL_SObject.updateListRecords(woliList);
        }else{
            return;
        } 
    }
}