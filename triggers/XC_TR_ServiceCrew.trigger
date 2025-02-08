/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/09/2019
* @description XC_TR_ServiceCrew – Trigger on ServiceCrew
*/

trigger XC_TR_ServiceCrew on ServiceCrew (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_ServiceCrew_Handler(), Trigger.operationType);
}