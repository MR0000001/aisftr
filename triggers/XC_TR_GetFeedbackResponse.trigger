/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella - fmelella@deloitte.it
* @date Creation 26/09/2019
* @date Modification 
* @description XC_TR_GetFeedbackResponse – Trigger on XC_GetFeedbackResponse__c 
*/


trigger XC_TR_GetFeedbackResponse on XC_GetFeedbackResponse__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_GetFeedbackResponse_Handler(), Trigger.operationType); 
}