/**
* @author Sara Miozza - sara.miozza@nttdata.com
* @date Creation 28/05/2019
* @date Modification 
* @description XC_TR_PersonalDocument – Trigger on XC_PersonalDocument__c
*/

trigger XC_TR_PersonalDocument on XC_PersonalDocument__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_PersonalDocument_Handler(), Trigger.operationType,Constants.MDT_SKIP_PERSONAL_DOCUMENT);

}