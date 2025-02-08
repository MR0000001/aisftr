/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Contract – Trigger on Contract
*/ 

trigger XC_TR_Contract on Contract (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Contract_Handler(), Trigger.operationType,Constants.MDT_SKIP_CONTRACT);
}