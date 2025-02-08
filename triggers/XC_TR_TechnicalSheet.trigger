/**
 * @author Nicola Mariniello - nmariniello@deloitte.it
 * @date Creation 03/05/2020
 * @date Modification dd/mm/yyyy
 * @description XC_TR_TechnicalSheet - Trigger on XC_TechnicalSheet__c 
 */
 
trigger XC_TR_TechnicalSheet on XC_TechnicalSheet__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_TechnicalSheet_Handler(), Trigger.operationType, constants.MDT_SKIP_TECHNICALSHEET);    
}