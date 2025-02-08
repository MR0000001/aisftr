/**
* @author Roberta Porrega - roberta.porrega@nttdata.com &  Sara Miozza - sara.miozza@nttdata.com 
* @date Creation 24/04/2019
* @description XC_TR_LegalEntityConsent – Trigger on XC_LegalEntityConsent__c
*/

trigger XC_TR_LegalEntityConsent on XC_LegalEntityConsent__c (before insert, before update, before delete, after insert, after update, after delete) {
     XC_TR_Dispatcher.init(new XC_TR_LegalEntityConsent_Handler(), Trigger.operationType,Constants.MDT_LEGAL_ENTITY_CONSENT); 	
}