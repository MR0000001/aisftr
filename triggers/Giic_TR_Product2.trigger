trigger Giic_TR_Product2 on Product2 (after update, after insert,after delete,before update,before insert,before delete) {
    
    XC_TR_Dispatcher.init(new Giic_TR_Product2_Handler(), Trigger.operationType);   

}