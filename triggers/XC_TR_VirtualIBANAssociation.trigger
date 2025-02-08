/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-10-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-10-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
trigger XC_TR_VirtualIBANAssociation on XC_VirtualIBANAssociation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_VirtualIBANAssociation_Handler(), Trigger.operationType);
}