/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 23/01/2020
* @description XC_TR_ServiceTerritoryMember – Trigger on ServiceTerritoryMember
*/

trigger XC_TR_ServiceTerritoryMember on ServiceTerritoryMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_ServiceTerritoryMember_Handler(), Trigger.operationType);
}