/**
* @author Denise Avolio - denise.avolio@accenture.com
* @date Creation 15/109/2021
* @date Modification
* @description XC_TR_AffiliateBeneficiary – Trigger on XC_Affiliate_Beneficiary__c
*/ 

trigger XC_TR_AffiliateBeneficiary on XC_Affiliate_Beneficiary__c (before insert, before update, before delete, after insert, after update, after delete){
    system.debug('Trigger AffBen start ' + Trigger.operationType);
    XC_TR_Dispatcher.init(new XC_TR_AffiliateBeneficiary_Handler(), Trigger.operationType, Constants.MDT_SKIP_AFFILIATEBENEFICIARY); 	
}