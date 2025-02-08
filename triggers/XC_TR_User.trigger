/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_User – Trigger on User
*/ 

trigger XC_TR_User on User (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_User_Handler(), Trigger.operationType); 	
}