trigger XC_TR_ProductRequired on ProductRequired (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ProductRequired_Handler(), Trigger.operationType,Constants.MDT_SKIP_WOLI); 	
}