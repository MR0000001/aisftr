/**
 * The Trigger XC_TR_EmailMessage.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 15/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_TR_EmailMessage - Trigger for EmailMessage
 */ 

trigger XC_TR_EmailMessage on EmailMessage (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_EmailMessage_Handler(), Trigger.operationType);     
}