/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Voucher – Trigger on XC_Voucher__c
*/ 

trigger XC_TR_Voucher on XC_Voucher__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Voucher_Handler(), Trigger.operationType); 	
}