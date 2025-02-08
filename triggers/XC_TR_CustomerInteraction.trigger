/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Federico Amici - federico.amici@nttdata.com
* @date Creation 19/04/2019
* @description XC_TR_CustomerInteraction
* @param insert
* @param 
*/
trigger XC_TR_CustomerInteraction  on XC_Customer_Interaction__c  (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_CustomerInteraction_Handler(), Trigger.operationType); 
     //et4ae5.triggerUtility.automate('XC_Customer_Interaction__c');
     //XC_TR_CustomerInteraction_Handler handler = new XC_TR_CustomerInteraction_Handler();
     //handler.onAfterUpdate(Trigger.oldmap, Trigger.newMap);
        
}