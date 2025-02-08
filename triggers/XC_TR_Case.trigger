/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 17/01/2019
* @date Modification 19/03/2019 - Chiara Turco - cturco@deloitte.it & Monica Cutillo - monica.cutillo@nttdata.com
* @description XC_TR_Case – Trigger on Case
*/

trigger XC_TR_Case on Case (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Case_Handler(), Trigger.operationType,Constants.MDT_SKIP_CASE);     
}