trigger Giic_TR_Warehouse on gii__Warehouse__c(before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_Warehouse_Handler(), Trigger.operationType);  

}