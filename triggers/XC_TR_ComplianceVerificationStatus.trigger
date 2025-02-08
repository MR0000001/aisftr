/**
* @author Simone Trenta - strenta@deloitte.it & Luca Tedeschi - ltedeschi@deloitte.it
* @date Creation 11/01/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ComplianceVerificationStatus – Trigger on XC_ComplianceVerificationStatus__c
*/ 

trigger XC_TR_ComplianceVerificationStatus on XC_ComplianceVerificationStatus__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ComplianceVerificationStat_Handler(), Trigger.operationType); 	
}