trigger giic_TR_PriceBook on gii__PriceBook__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new giic_TR_PriceBook_Handler(), Trigger.operationType);  

}