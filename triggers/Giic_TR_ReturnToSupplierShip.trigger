trigger Giic_TR_ReturnToSupplierShip on gii__ReturntoSupplierLineShipment__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new Giic_TR_ReturnToSupplierShip_Handler(), Trigger.operationType);  

}