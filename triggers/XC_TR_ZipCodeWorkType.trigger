/**
* @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone Massimiliano.avallone@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_ZipCodeWorkType – Trigger on ZipCode WorkType
*/
trigger XC_TR_ZipCodeWorkType on XC_ZipCodeWorkType__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ZipCodeWorkType_Handler(), Trigger.operationType);   
}