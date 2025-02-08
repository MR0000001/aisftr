trigger giic_TR_ProductInventory on gii__ProductInventory__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new giic_TR_ProductInventory_Handler(), Trigger.operationType);  
 
}