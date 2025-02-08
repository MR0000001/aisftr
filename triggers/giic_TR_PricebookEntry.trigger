trigger giic_TR_PricebookEntry on gii__PriceBookEntry__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new giic_TR_PriceBookEntry_Handler(), Trigger.operationType);  

}