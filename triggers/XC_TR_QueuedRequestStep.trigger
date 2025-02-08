/**
 * @File Name          : XC_TR_QueuedRequestStep.trigger
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 27/5/2020, 12:20:43
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
trigger XC_TR_QueuedRequestStep on XC_QueuedRequestStep__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    XC_TR_Dispatcher.init(new XC_TR_QueuedRequestStep_Handler(), Trigger.operationType);
}