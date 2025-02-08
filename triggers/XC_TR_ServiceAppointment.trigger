/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 08/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceAppointment – Trigger on ServiceAppointment
*/ 

trigger XC_TR_ServiceAppointment on ServiceAppointment (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ServiceAppointment_Handler(), Trigger.operationType,Constants.MDT_SKIP_SERVICEAPP);   
    TA_TR_Dispatcher.init(new TA_TR_ServiceAppointment_Handler(), Trigger.operationType,constants.MDT_SKIP_SERVICEAPP); // Andrea Liverani 20210621 
}