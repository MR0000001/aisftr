/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrderLineItem – Trigger on WorkOrderLineItem
*/ 

trigger XC_TR_WorkOrderLineItem on WorkOrderLineItem (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_WorkOrderLineItem_Handler(), Trigger.operationType,constants.MDT_SKIP_WOLI); 	
}