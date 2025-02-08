trigger XC_TR_ConsentDescription on XC_ConsentDescription__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ConsentDescription_Handler(), Trigger.operationType);   
}