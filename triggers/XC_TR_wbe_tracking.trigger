trigger XC_TR_wbe_tracking on XC_WbeTracking__c(before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_WbeTracking_Handler(), Trigger.operationType,constants.MDT_SKIP_WBE_TRACKING);  
}