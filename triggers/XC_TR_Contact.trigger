/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/08/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Contact – Trigger on Contact
*/ 

trigger XC_TR_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Contact_Handler(), Trigger.operationType,Constants.MDT_SKIP_CONTACT, 'SFM');  
}