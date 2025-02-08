/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/03/2019
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Address – Trigger on XC_Address__c
*/

trigger XC_TR_Address on XC_Address__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_Address_Handler(), Trigger.operationType,Constants.MDT_SKIP_ADDRESS); 	
}