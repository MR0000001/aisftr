trigger Giic_TR_ProductSerial on gii__ProductSerial__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new giic_TR_ProductSerial_Handler(),  Trigger.operationType);  
 
}