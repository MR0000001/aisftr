/**
* @author FirstName : Milko Fatiga
* @date Creation 12/10/2021
* @date Modification dd/mm/yyyy
* @description Giic_TR_InventoryAdjustment
*/ 
trigger Giic_TR_InventoryAdjustment on gii__InventoryAdjustment__c (after update, after insert,before update,before insert) {
    XC_TR_Dispatcher.init(new Giic_TR_InventoryAdjustment_Handler(), Trigger.operationType);  
}