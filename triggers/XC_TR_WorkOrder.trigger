/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder – Trigger on WorkOrder
*/ 

trigger XC_TR_WorkOrder on WorkOrder (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_WorkOrder_Handler(), Trigger.operationType,constants.MDT_SKIP_WORKORDER);    
    TA_TR_Dispatcher.init(new TA_TR_WorkOrder_Handler(), Trigger.operationType,constants.MDT_SKIP_WORKORDER); // Benjamin Geronimo 13042021   
}