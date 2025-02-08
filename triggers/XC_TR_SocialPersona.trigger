/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/01/2020
* @description XC_TR_SocialPersona – Trigger on SocialPersona
*/ 

trigger XC_TR_SocialPersona on SocialPersona (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_SocialPersona_Handler(), Trigger.operationType); 	
}