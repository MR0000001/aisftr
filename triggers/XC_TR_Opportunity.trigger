/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity – Trigger on Opportunity
*/ 

trigger XC_TR_Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Opportunity_Handler(), Trigger.operationType,constants.MDT_SKIP_OPPORTUNITY);   
}