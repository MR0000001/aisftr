/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-04-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
trigger XC_TR_ContractService on XC_ContractItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_ContractService_Handler(), Trigger.operationType);   
}