/**
 * @File Name          : XC_TR_DictamenItem.trigger
 * @description        : Trigger on Dictamen Item
 * @Author             : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Group              : 
 * @Last Modified By   : Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @Last Modified On   : 9/10/2019, 11:30:12
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/10/2019      Andrea Bravaccino         Initial Version
**/
trigger XC_TR_DictamenItem on XC_DictamenItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_DictamenItem_Handler(), Trigger.operationType);    
}