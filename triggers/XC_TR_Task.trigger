/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/2019
* @description XC_TR_Task – Trigger on Task
*/ 

trigger XC_TR_Task on Task (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Task_Handler(), Trigger.operationType); 	
}