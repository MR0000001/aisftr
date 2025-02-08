/**
* @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 07/08/2019
* @date Modification ..
* @description XC_TR_VoucherUtilization – Trigger on VoucherUtilization
*/

trigger XC_TR_VoucherUtilization on XC_VoucherUtilization__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_VoucherUtilization_Handler(), Trigger.operationType);
}