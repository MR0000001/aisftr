/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 20/09/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_AssignedResource – Trigger on AssignedResource
*/ 

trigger XC_TR_AssignedResource on AssignedResource (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_AssignedResource_Handler(), Trigger.operationType,Constants.MDT_SKIP_ASSIGNEDRESOURCES);     
}