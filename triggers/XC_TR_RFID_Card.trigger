/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_RFID_Card – Trigger on XC_RFID_Card__c
*/

trigger XC_TR_RFID_Card on XC_RFID_Card__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_RFID_Card_Handler(), Trigger.operationType);
}