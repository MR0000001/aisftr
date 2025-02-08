trigger XC_TR_ProductConsumed on XC_ProductConsumed__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ProductConsumed_Handler(), Trigger.operationType,Constants.MDT_SKIP_WOLI); 
}