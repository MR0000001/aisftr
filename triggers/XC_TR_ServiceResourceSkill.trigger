/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceResourceSkill – Trigger on ServiceResourceSkill
*/ 

trigger XC_TR_ServiceResourceSkill on ServiceResourceSkill (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ServiceResourceSkill_Handler(), Trigger.operationType); 	
}