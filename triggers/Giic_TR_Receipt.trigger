/**
* @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_TR_Receipt trigger will be used for 1) transfer order receipt
        
*/
trigger Giic_TR_Receipt on gii__Receipt__c (after insert,after update,after delete,before insert,before update,before delete) {
    XC_TR_Dispatcher.init(new Giic_TR_Receipt_Handler(), Trigger.operationType); 
}