trigger Giic_TR_ProductReference on gii__Product2Add__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new giic_TR_ProductReference_Handler(), Trigger.operationType);  
 
}